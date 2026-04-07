# Self-Hosted Runners

This guide covers the recommended approach for running the agentic pipeline on
self-hosted infrastructure. GitHub-hosted runners remain the default and require
no setup — this guide is for teams that need self-hosted runners for cost,
compliance, or network reasons.

---

## Why Kubernetes + ARC

The core problem with conventional self-hosted runners is **shared persistent state**.
The pipeline writes credentials to `~/.claude/.credentials.json` and configuration to
`~/.config/goose/config.yaml` on each run. On a conventional self-hosted runner:

- Credentials persist between jobs and are readable by subsequent jobs
- Multiple repos on the same host share the same home directory and clobber each other
- A crash mid-job can leave credentials on disk indefinitely

The solution is **ephemeral runners** — a fresh, isolated environment per job that is
destroyed on completion. [Actions Runner Controller (ARC)](https://github.com/actions/actions-runner-controller)
on Kubernetes provides this: each workflow job spawns a new pod, which is deleted when
the job finishes. No state persists. Multiple repos can have independent runner scale
sets that never share a filesystem.

Any Kubernetes distribution works — k3s is a convenient choice for a single-node
setup, but an existing k8s cluster works equally well.

---

## Architecture

```
GitHub Actions  →  ARC controller  →  RunnerScaleSet (per repo)  →  ephemeral pod
                                                                      (job runs here,
                                                                       pod deleted on exit)
```

Each repo gets its own `RunnerScaleSet`. Pods only exist while a job is running —
zero idle overhead.

---

## Setup

### 1. Kubernetes cluster

Any Kubernetes cluster works. For a single-node setup with no existing cluster,
[k3s](https://k3s.io) is a convenient starting point:

```bash
curl -sfL https://get.k3s.io | sh -
kubectl get nodes
```

### 2. Install ARC

```bash
helm install arc \
  --namespace arc-systems \
  --create-namespace \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

### 3. Create a RunnerScaleSet per repo (or org)

For each repository (or organisation), create a scale set. The Helm release name
(`arc-runner-my-repo`) becomes the value you set in `RUNNER_LABEL` for that repo.
`githubConfigUrl` accepts either a repo URL or an organisation URL.

```bash
helm install arc-runner-my-repo \
  --namespace arc-runners \
  --create-namespace \
  --set githubConfigUrl="https://github.com/<owner>/<repo-or-org>" \
  --set githubConfigSecret.github_token="<PAT with repo and workflow scopes>" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

Repeat for each repo, using a distinct release name each time.

### 4. Verify

```bash
kubectl get pods -n arc-systems
kubectl get pods -n arc-runners

helm list -n arc-runners
```

### 5. Set RUNNER_LABEL in each repo

```bash
gh variable set RUNNER_LABEL --body "arc-runner-my-repo" --repo owner/my-repo
```

The pipeline's `runs-on: ${{ vars.RUNNER_LABEL || 'ubuntu-latest' }}` will route
jobs to the ARC scale set automatically.

---

## Management

### List installed scale sets

```bash
helm list -n arc-runners
```

### Remove a scale set

```bash
helm uninstall arc-runner-my-repo -n arc-runners
```

---

## Network Requirements

Each runner pod needs outbound access to:

| Endpoint | Purpose |
|---|---|
| `api.github.com` | GitHub API (issues, PRs, labels) |
| `github.com` | Git operations, `gh` CLI |
| `ghcr.io` | Pulling runner container images |
| `api.anthropic.com` | Claude Code CLI (OAuth token validation) |
| `objects.githubusercontent.com` | Downloading Goose binary from GitHub releases |
| `registry.npmjs.org` | Installing Claude Code CLI via npm |

---

## Isolation Properties

| Property | GitHub-hosted | Conventional self-hosted | Kubernetes + ARC |
|---|---|---|---|
| Fresh environment per job | Yes | No | Yes |
| Credentials persist after job | No | Yes | No |
| Multiple repos share filesystem | No | Yes (same host user) | No |
| Scales to zero when idle | N/A | No | Yes |

---

## References

- [ARC documentation](https://github.com/actions/actions-runner-controller)
- [k3s documentation](https://docs.k3s.io) — single-node Kubernetes option
