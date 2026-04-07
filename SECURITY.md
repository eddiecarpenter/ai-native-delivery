# Security

This document covers the security model for the agentic pipeline, including
runner isolation, supply chain controls, and credential management.

---

## Self-Hosted Runner Isolation

The pipeline defaults to **GitHub-hosted runners** (`ubuntu-latest`). GitHub-hosted
runners are ephemeral — each job runs on a fresh virtual machine that is destroyed
after the job completes. There is no persistent state between runs: no leftover
credentials, no cached source code, no residual build artefacts.

Self-hosted runners are **opt-in** via the `RUNNER_LABEL` repository variable. Set
it to the label of your self-hosted runner to route all agent jobs there:

```bash
gh variable set RUNNER_LABEL --body "my-self-hosted-label"
```

### Persistent state risk (self-hosted only)

Self-hosted runners retain state between jobs unless explicitly configured otherwise.
This means credentials, source code, and build artefacts from one job may be visible
to the next. If you opt into self-hosted runners:

- Use **dedicated runners** for this pipeline — do not share with untrusted workloads
- Use **ephemeral runners** (e.g. auto-scaling with fresh instances per job) where possible
- Ensure the runner workspace is cleaned between jobs
- Restrict network access to only what the pipeline requires (GitHub API, Anthropic API)

GitHub-hosted runners have none of these concerns — they are the recommended default.

---

## Supply Chain

All third-party GitHub Actions are pinned to a specific commit SHA to prevent
supply chain attacks from compromised tags. Never pin to a mutable tag (`v1`,
`latest`) — always use the full 40-character commit SHA.

### Pinned actions

| Action | SHA | Purpose |
|---|---|---|
| `actions/checkout` | `v4` (GitHub first-party) | Checkout repository code |

### Goose installation

Goose is installed via the official Block install script (`download_cli.sh`) rather than a third-party GitHub Action. The `clouatre-labs/setup-goose-action` was evaluated but rejected because it performs SLSA attestation verification that Goose releases do not currently publish, causing every run to fail. The official script is sourced directly from the `block/goose` GitHub releases and is the installation method documented by Block.

### Upgrade guidance

When upgrading a pinned action:

1. Review the release notes and diff between the old and new SHA
2. Verify the new SHA by checking out the action repo and inspecting the code
3. Update the SHA in `base/.github/workflows/agentic-pipeline.yml`
4. Copy the updated workflow to `.github/workflows/agentic-pipeline.yml`
5. Test the pipeline on a feature branch before merging to `main`
6. Commit both workflow files together

---

## Setup Requirements — Secrets and Variables

### Secrets

#### `GOOSE_AGENT_PAT`

A GitHub Personal Access Token (PAT) with `repo` and `workflow` scopes. Used by
the pipeline to:

- Check out code with write access
- Create and manage branches
- Open and update pull requests
- Read and close issues

Store as a GitHub repository secret. Rotate periodically per your organisation's
token lifecycle policy.

#### `CLAUDE_CREDENTIALS_JSON`

A base64-encoded copy of the Claude Code OAuth credentials file
(`~/.claude/.credentials.json`). Used to authenticate the Claude Code CLI on
ephemeral runners where interactive `claude auth login` is not possible.

**How to generate:**

```bash
# 1. Authenticate Claude Code on your local machine
claude auth login

# 2. Base64-encode the credentials and store as a GitHub secret
base64 ~/.claude/.credentials.json | gh secret set CLAUDE_CREDENTIALS_JSON
```

**Storage:** GitHub repository secret. The value is base64-encoded and injected
into the runner at job time, then written to `~/.claude/.credentials.json` with
`chmod 0600` permissions.

**Expiry and renewal:** The OAuth token in the credentials file has a limited
lifetime (determined by Anthropic's OAuth configuration). When it expires, Goose
runs will fail with an authentication error. To renew:

1. Re-authenticate locally: `claude auth login`
2. Re-encode and update the secret: `base64 ~/.claude/.credentials.json | gh secret set CLAUDE_CREDENTIALS_JSON`

This follows the same operational model as `GOOSE_AGENT_PAT` — a human-managed
credential that is renewed when it expires.

### Variables

| Variable | Default | Purpose |
|---|---|---|
| `RUNNER_LABEL` | `ubuntu-latest` | Runner label for all agent jobs |
| `GOOSE_PROVIDER` | `claude-code` | Goose LLM provider |
| `GOOSE_MODEL` | `default` | Goose model name |
| `AGENT_USER` | *(required)* | GitHub username of the agent account |
| `AGENTIC_REPO` | Current repo | Agentic control plane repo (federated topology) |

### Self-hosted runner prerequisites

If using a self-hosted runner, the following must be pre-installed:

- **Node.js** (v18+) — required for Claude Code CLI installation
- **`gh` CLI** — GitHub CLI, authenticated with a token that has `repo` scope
- **git** — for repository operations
- **Network access** — to GitHub API (`api.github.com`) and Anthropic API (`api.anthropic.com`)

Goose and Claude Code CLI are installed automatically by the workflow on every
run, regardless of runner type.
