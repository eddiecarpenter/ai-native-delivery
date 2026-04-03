#!/usr/bin/env bash
# bootstrap.sh — Agentic Development Environment Bootstrap
# Fetched from: https://github.com/eddiecarpenter/agentic-development
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/eddiecarpenter/agentic-development/main/bootstrap.sh -o /tmp/bootstrap.sh \
#     && bash /tmp/bootstrap.sh

set -euo pipefail

TEMPLATE_REPO="eddiecarpenter/agentic-development"
TEMPLATE_RAW="https://raw.githubusercontent.com/${TEMPLATE_REPO}/main"
WORKING_DIR="$(pwd)"

# ── Colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}▸ $*${NC}"; }
success() { echo -e "${GREEN}✔ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✖ $*${NC}"; exit 1; }
header()  { echo -e "\n${BOLD}$*${NC}"; }

# ── Banner ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Agentic Development Bootstrap v0.1.0     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── Pre-flight checks ──────────────────────────────────────────────────────────
info "Running pre-flight checks..."

if ! command -v git &>/dev/null; then
  error "git is not installed. Please install git and re-run."
fi
success "git found: $(git --version)"

if ! command -v gh &>/dev/null; then
  error "GitHub CLI (gh) is not installed. See https://cli.github.com and re-run."
fi
success "gh found: $(gh --version | head -1)"

if ! gh auth status &>/dev/null; then
  error "GitHub CLI is not authenticated. Run: gh auth login"
fi
success "gh authenticated"

AGENT=""
if command -v goose &>/dev/null; then AGENT="goose"; fi
if command -v claude &>/dev/null; then
  [[ -z "$AGENT" ]] && AGENT="claude"
fi
if [[ -z "$AGENT" ]]; then
  error "No agent CLI found. Install Goose (https://block.github.io/goose) or Claude Code (https://claude.ai/code) and re-run."
fi

if command -v goose &>/dev/null && command -v claude &>/dev/null; then
  echo ""
  echo "Both Goose and Claude Code are installed."
  echo "  1. Goose"
  echo "  2. Claude Code"
  read -rp "Which agent would you like to use? [1/2]: " agent_choice
  case "$agent_choice" in
    1) AGENT="goose" ;;
    2) AGENT="claude" ;;
    *) error "Invalid choice." ;;
  esac
fi
success "Agent: $AGENT"

# ── Step 1 — Topology ──────────────────────────────────────────────────────────
header "Step 1 — Topology"
echo ""
echo "  1. Embedded     — single repo (agentic process lives in the project repo)"
echo "  2. Organisation — multi-repo (separate agentic control plane)"
echo ""
read -rp "Select topology [1/2]: " topology_choice

TOPOLOGY=""
OWNER=""
ORG=""

case "$topology_choice" in
  1) TOPOLOGY="embedded" ;;
  2) TOPOLOGY="organisation" ;;
  *) error "Invalid choice." ;;
esac
success "Topology: $TOPOLOGY"

# ── Owner / Org selection ──────────────────────────────────────────────────────
echo ""
if [[ "$TOPOLOGY" == "organisation" ]]; then
  info "Fetching your organisations..."
  mapfile -t ORGS < <(gh org list 2>/dev/null || true)

  if [[ ${#ORGS[@]} -eq 0 ]]; then
    warn "No organisations found. Please create one on GitHub, then press Enter to retry."
    read -rp "" _
    mapfile -t ORGS < <(gh org list 2>/dev/null || true)
    [[ ${#ORGS[@]} -eq 0 ]] && error "Still no organisations found. Exiting."
  fi

  while true; do
    echo ""
    echo "Available organisations:"
    for i in "${!ORGS[@]}"; do
      org="${ORGS[$i]}"
      repo_count=$(gh repo list "$org" --limit 1 --json name 2>/dev/null | grep -c '"name"' || true)
      if [[ "$repo_count" -gt 0 ]]; then
        echo "  $((i+1)). $org  ⚠ has existing repos"
      else
        echo "  $((i+1)). $org  ✔ clean"
      fi
    done
    echo "  0. Create a new organisation"
    echo ""
    read -rp "Select an organisation: " org_choice

    if [[ "$org_choice" == "0" ]]; then
      echo ""
      warn "Please create the organisation on GitHub, then press Enter to continue."
      read -rp "" _
      mapfile -t ORGS < <(gh org list 2>/dev/null || true)
      continue
    fi

    if [[ "$org_choice" -lt 1 || "$org_choice" -gt ${#ORGS[@]} ]] 2>/dev/null; then
      warn "Invalid selection. Try again."
      continue
    fi

    ORG="${ORGS[$((org_choice-1))]}"
    repo_count=$(gh repo list "$ORG" --limit 1 --json name 2>/dev/null | grep -c '"name"' || true)

    if [[ "$repo_count" -gt 0 ]]; then
      echo ""
      warn "This organisation already has repositories. Bootstrap is designed for a clean organisation."
      read -rp "Continue anyway? (y = proceed manually, n = pick different org) [y/N]: " dirty_confirm
      if [[ "$dirty_confirm" =~ ^[Yy]$ ]]; then
        error "Please follow the brownfield onboarding process manually for existing organisations."
      fi
      continue
    fi

    OWNER="$ORG"
    success "Organisation: $OWNER"
    break
  done

else
  # Embedded — personal account or org?
  GH_USER=$(gh api user --jq '.login')
  echo "  1. Personal account ($GH_USER)"
  echo "  2. An organisation"
  echo ""
  read -rp "Where will this repo live? [1/2]: " owner_choice

  case "$owner_choice" in
    1) OWNER="$GH_USER" ;;
    2)
      info "Fetching your organisations..."
      mapfile -t ORGS < <(gh org list 2>/dev/null || true)
      if [[ ${#ORGS[@]} -eq 0 ]]; then
        error "No organisations found."
      fi
      echo ""
      for i in "${!ORGS[@]}"; do
        echo "  $((i+1)). ${ORGS[$i]}"
      done
      echo ""
      read -rp "Select an organisation: " org_choice
      OWNER="${ORGS[$((org_choice-1))]}"
      ;;
    *) error "Invalid choice." ;;
  esac
  success "Owner: $OWNER"
fi

# ── Step 2 — Project Details Form ─────────────────────────────────────────────
PROJ_NAME=""
PROJ_DESC=""
PROJ_STACK=""
PROJ_ANTORA=""

STACK_OPTIONS=("Go" "Java / Quarkus" "Java / Spring Boot" "TypeScript / Node.js" "Python" "Rust" "Other")

display_form() {
  echo ""
  echo -e "${BOLD}Project Setup${NC}"
  echo "  ──────────────────────────────────────────────────────"
  echo "  1. Name        : ${PROJ_NAME:-(not set)}"
  echo "  2. Description : ${PROJ_DESC:-(not set)}"
  echo "  3. Stack       : ${PROJ_STACK:-(not set)}"
  echo "  4. Antora site : ${PROJ_ANTORA:-(not set)}"
  echo "  ──────────────────────────────────────────────────────"
  echo "  Enter a field number to set it, or 0 when done."
  echo ""
}

while true; do
  display_form
  read -rp "  Choice: " form_choice

  case "$form_choice" in
    1)
      read -rp "  Project name: " PROJ_NAME
      ;;
    2)
      read -rp "  Description: " PROJ_DESC
      ;;
    3)
      echo ""
      echo "  Select stack:"
      for i in "${!STACK_OPTIONS[@]}"; do
        echo "    $((i+1)). ${STACK_OPTIONS[$i]}"
      done
      echo ""
      read -rp "  Choice: " stack_choice
      if [[ "$stack_choice" -ge 1 && "$stack_choice" -le ${#STACK_OPTIONS[@]} ]] 2>/dev/null; then
        if [[ "$stack_choice" -eq ${#STACK_OPTIONS[@]} ]]; then
          read -rp "  Specify stack: " PROJ_STACK
        else
          PROJ_STACK="${STACK_OPTIONS[$((stack_choice-1))]}"
        fi
      else
        warn "Invalid choice."
      fi
      ;;
    4)
      echo ""
      echo "  Antora documentation site?"
      echo "    1. Yes — external consumers or non-technical stakeholders will use it"
      echo "    2. No  — README is sufficient"
      echo ""
      read -rp "  Choice: " antora_choice
      case "$antora_choice" in
        1) PROJ_ANTORA="Yes" ;;
        2) PROJ_ANTORA="No" ;;
        *) warn "Invalid choice." ;;
      esac
      ;;
    0)
      MISSING=()
      [[ -z "$PROJ_NAME" ]]   && MISSING+=("Name")
      [[ -z "$PROJ_DESC" ]]   && MISSING+=("Description")
      [[ -z "$PROJ_STACK" ]]  && MISSING+=("Stack")
      [[ -z "$PROJ_ANTORA" ]] && MISSING+=("Antora site")

      if [[ ${#MISSING[@]} -gt 0 ]]; then
        warn "The following fields are required: ${MISSING[*]}"
      else
        break
      fi
      ;;
    *)
      warn "Invalid choice."
      ;;
  esac
done

success "Project details collected."

# ── Summary & confirm ──────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Summary${NC}"
echo "  ──────────────────────────────────────────────────────"
echo "  Topology   : $TOPOLOGY"
echo "  Owner      : $OWNER"
echo "  Name       : $PROJ_NAME"
echo "  Description: $PROJ_DESC"
echo "  Stack      : $PROJ_STACK"
echo "  Antora     : $PROJ_ANTORA"
echo "  Working dir: $WORKING_DIR"
echo "  Template   : $TEMPLATE_REPO"
echo "  ──────────────────────────────────────────────────────"
echo ""
read -rp "Proceed with bootstrap? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }

# ── Launch agent to execute ────────────────────────────────────────────────────
echo ""
info "Launching bootstrap agent — executing Steps 3-7..."
info "This may take a moment..."
echo ""

BOOTSTRAP_PROMPT="Execute Phase 0a Environment Bootstrap Steps 3-9 as defined in base/AGENTS.md at ${TEMPLATE_RAW}/base/AGENTS.md.

All project details have been confirmed by the human. Do not ask for confirmation of these values.

Confirmed settings:
  Topology    : ${TOPOLOGY}
  Owner       : ${OWNER}
  Name        : ${PROJ_NAME}
  Description : ${PROJ_DESC}
  Stack       : ${PROJ_STACK}
  Antora      : ${PROJ_ANTORA}
  Working dir : ${WORKING_DIR}
  Template    : ${TEMPLATE_REPO}

Repo naming:
  - Embedded: repo name is '${PROJ_NAME}', clone into ${WORKING_DIR}/${PROJ_NAME}
  - Organisation: repo name is '${PROJ_NAME}-agentic', clone into ${WORKING_DIR}/${PROJ_NAME}-agentic

Execute steps 3-7 now. Do not ask for permission to run gh commands — you have full authorisation."

case "$AGENT" in
  goose)
    PROMPT_FILE=$(mktemp /tmp/goose-bootstrap-XXXX.md)
    echo "$BOOTSTRAP_PROMPT" > "$PROMPT_FILE"
    goose run "$PROMPT_FILE"
    rm -f "$PROMPT_FILE"
    ;;
  claude)
    claude --dangerously-skip-permissions --system-prompt "$BOOTSTRAP_PROMPT" "Execute the bootstrap now."
    ;;
esac

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
success "Bootstrap complete."
echo ""
info "Next steps:"
echo "  1. Open your new agentic repo in your desktop agent"
echo "  2. Start a Requirements Session (Phase 1) to capture your first requirement"
echo ""
