# Delivery Philosophy

This document captures the foundational thinking behind the `ai-native-delivery`
framework's approach to software delivery. Understanding this philosophy is essential
for making good decisions during scoping, design, and implementation.

---

## The Framework's Scope: Continuous Delivery

This framework implements **Continuous Delivery (CD¹)** — the discipline of keeping
software in a releasable state at all times. Every merge to `main` produces an artefact
that *could* be deployed to production.

**Continuous Deployment (CD²)** — the automatic deployment of every merge to production
without human intervention — is explicitly out of scope. The decision to deploy to
production is a human gate. The execution of that deployment should be automated, but
the trigger is not.

The pipeline covers: Requirements → Scoping → Design → Implementation → Releasable artefact.

It does not cover: Deployment execution, infrastructure provisioning, or production operations.

---

## Three Distinct Events

Clarity on these three events prevents conflation that leads to poor decisions:

### 1. Deployment

**Deployment** is a technical event. Code is loaded into a production environment.
It is continuous, invisible to customers, and owned by engineering. In a healthy
delivery process, deployments are frequent and unremarkable.

The agentic pipeline produces releasable code. Deployment is triggered by the human
and executed by automation.

### 2. Release

**Release** is a business event. A versioned snapshot of `main` is cut, tagged, and
made available. It represents a deliberate decision that a collection of work is
complete and coherent enough to be named.

A release does not automatically mean customers see new behaviour — that depends on
feature switches. A release is a coordination point: it defines what ships together,
enables release notes, and creates an auditable history.

Releases are triggered by humans. The release process should be automated but
human-initiated.

### 3. Enablement

**Enablement** is a product event. A feature becomes accessible to users. It is
controlled by feature switches and is a deliberate product decision, separate from
both deployment and release.

This separation is what allows trunk-based development at scale: code can be merged,
deployed, and released before it is enabled.

---

## Deploy ≠ Release ≠ Enablement

These three events can happen at different times, by different people, for different reasons:

| Event | Owner | Trigger | Visible to users? |
|---|---|---|---|
| Deployment | Engineering | Human decision, automated execution | No |
| Release | Product / Engineering | Human decision, automated execution | No (unless no switches) |
| Enablement | Product | Switch change or release decision | Yes |

A common anti-pattern is treating these as a single event. When deployment = release =
enablement, every code change is a release, every release is an enablement, and the
organisation loses the ability to decouple delivery velocity from release risk.

Feature switches are the primary mechanism that decouples these events. See
`base/concepts/feature-switches.md` for the full taxonomy.

---

## One-Click Deployment

Deployment should be fully automated — a single human action triggers an end-to-end
automated process that takes the releasable artefact and loads it into production.

The human gate exists to ensure accountability and coordination. It should not require
manual steps, script execution, or engineering involvement beyond the trigger. If
deployment requires manual effort, that effort should be automated as a delivery
requirement in its own right.

**The goal:** the human decides *when* to deploy. The automation decides *how*.

---

## Deployment Should Follow Release Quickly

A release that sits undeployed creates risk: it accumulates divergence from what is
running in production, it delays the feedback loop, and it increases the blast radius
of any issue discovered post-deployment.

The framework's position: deploy as soon as possible after release. The feature switch
model ensures this is safe — code in production behind a disabled switch is inert.
Deployment is cheap and reversible; delay is not.

---

## Integration Testing Position

Integration testing is an architectural decision, not a delivery decision. The framework's
position is:

- **Unit tests** are mandatory and enforced unconditionally
- **Contract and API tests** are required wherever an external interface exists
- **Integration test strategy** must be established from day one — not retrofitted
- **Integration test implementation** is delivered as requirements through the pipeline
- **Integration test infrastructure** is out of scope for the framework

A system not designed for integration testing cannot be cheaply retrofitted. The agent
identifies contract boundaries and flags them during scoping; the human decides the
testing strategy.

See `base/AGENTS.md` → Testing → Integration Tests for the enforcement rules.

---

## Feature Switches Enable Continuous Delivery

Without feature switches, continuous delivery collapses into continuous deployment:
every merge must be immediately releasable and immediately safe for users. This creates
pressure against merging incomplete work, which leads to long-lived branches, merge
conflicts, and integration risk.

Feature switches restore the safety of continuous merging:

- Incomplete work can be merged to `main` behind a `permanent disable` switch
- Complete but unreleased work sits behind a `toggle` switch
- Production can always be deployed from `main`
- Releases are a business decision, not a technical constraint

This is the framework's default: **features and enhancements deploy behind a feature switch**.
See `base/concepts/feature-switches.md` for the full taxonomy, modes, and lifecycle.

---

## What the Framework Does Not Own

To avoid overreach, these areas are explicitly out of scope:

- **Deployment execution** — how code gets from artefact to production environment
- **Infrastructure provisioning** — cloud resources, Kubernetes, databases
- **Production operations** — monitoring, alerting, incident response
- **Release scheduling** — when to cut a release is a product decision
- **Integration test infrastructure** — environments, test data, service stubs
- **Continuous Deployment (CD²)** — automatic production deployment without human gate

These are real engineering concerns. They belong to the repo and the organisation,
not to the delivery framework.
