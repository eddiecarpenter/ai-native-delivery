#!/usr/bin/env bash
# bootstrap.sh — Agentic Development Environment Bootstrap
# Fetched from: https://github.com/eddiecarpenter/agentic-development
#
# Usage (verify then run):
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
NC='\033[0m'

info()    { echo -e "${CYAN}▸ $*${NC}"; }
success() { echo -e "${GREEN}✔ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✖ $*${NC}"; exit 1; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Agentic Development Bootstrap v0.1.0     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── Pre-flight checks ──────────────────────────────────────────────────────────
info "Running pre-flight checks..."

# git
if ! command -v git &>/dev/null; then
  error "git is not installed. Please install git and re-run."
fi
success "git found: $(git --version)"

# gh
if ! command -v gh &>/dev/null; then
  error "GitHub CLI (gh) is not installed. See https://cli.github.com and re-run."
fi
success "gh found: $(gh --version | head -1)"

# gh auth
if ! gh auth status &>/dev/null; then
  error "GitHub CLI is not authenticated. Run: gh auth login"
fi
success "gh authenticated"

# Agent CLI
AGENT=""
if command -v goose &>/dev/null; then
  AGENT="goose"
fi
if command -v claude &>/dev/null; then
  if [[ -z "$AGENT" ]]; then
    AGENT="claude"
  fi
fi

if [[ -z "$AGENT" ]]; then
  error "No agent CLI found. Please install Goose (https://block.github.io/goose) or Claude Code (https://claude.ai/code) and re-run."
fi

# If both are available, let the user choose
if command -v goose &>/dev/null && command -v claude &>/dev/null; then
  echo ""
  echo "Both Goose and Claude Code are installed."
  echo "  [1] Goose"
  echo "  [2] Claude Code"
  read -rp "Which agent would you like to use? [1/2]: " agent_choice
  case "$agent_choice" in
    1) AGENT="goose" ;;
    2) AGENT="claude" ;;
    *) error "Invalid choice." ;;
  esac
fi

success "Agent: $AGENT"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
info "Pre-flight checks passed. Ready to bootstrap."
echo ""
echo -e "  Template repo : ${CYAN}${TEMPLATE_REPO}${NC}"
echo -e "  Agent         : ${CYAN}${AGENT}${NC}"
echo -e "  Working dir   : ${CYAN}${WORKING_DIR}${NC}"
echo ""
read -rp "Proceed? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }

# ── Launch bootstrap session ───────────────────────────────────────────────────
echo ""
info "Launching Phase 0a — Environment Bootstrap Session..."
info "Fetching protocol from template — this may take a moment..."
echo ""

BOOTSTRAP_PROMPT="You are starting a Phase 0a Environment Bootstrap Session as defined in the agentic development protocol.

The template repo this environment is being bootstrapped from is: ${TEMPLATE_REPO}

Begin by reading the Phase 0a session steps from:
  ${TEMPLATE_RAW}/base/AGENTS.md

Note: pre-flight checks (gh auth, git) have already been completed by bootstrap.sh.
Tell the human the pre-flight checks passed and proceed directly to step 2.

The new agentic repo must be cloned into: ${WORKING_DIR}/<repo-name>

Then follow the steps exactly:
1. ✔ Pre-flight checks complete (done by bootstrap.sh)
2. Ask the topology question (embedded or organisation)
3. Fetch org list if organisation, present with clean/dirty flags
4. Collect project questions (name, description, stack, Antora)
5. Create the agentic repo from the template
6. Configure branch protection, labels, GitHub Project
7. Populate REPOS.md and AGENTS.local.md — record template source as: ${TEMPLATE_REPO}
8. Confirm the new agentic repo URL to the human

Do not skip any step. Do not ask for permission to run gh commands — bootstrap has full authorisation to use gh.

When presenting choices to the human, always use numbered options so the human can respond with a number, for example:
  1. Embedded
  2. Organisation"

case "$AGENT" in
  goose)
    goose session --instructions "$BOOTSTRAP_PROMPT"
    ;;
  claude)
    claude --dangerously-skip-permissions --system-prompt "$BOOTSTRAP_PROMPT" "Begin the Phase 0a Environment Bootstrap Session now. Pre-flight checks are complete. Start at Step 1 — ask the topology question."
    ;;
esac

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
success "Bootstrap session complete."
echo ""
info "Next steps:"
echo "  1. Open your new agentic repo in your desktop agent (Goose or Claude Code)"
echo "  2. Start a Requirements Session (Phase 1) to capture your first requirement"
echo ""
