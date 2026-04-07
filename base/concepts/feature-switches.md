# Feature Switches

This document defines the three types of switches used in this framework and their
operating modes. Understanding the distinction is essential — the wrong switch type
leads to the wrong lifecycle, the wrong owner, and the wrong exit condition.

---

## The Deploy ≠ Release Principle

**Deployment** is a technical event. Code reaches production. It is continuous and
invisible to customers. The agentic pipeline owns this.

**Release** is a business event. A feature becomes customer-facing. It is deliberate,
coordinated, and involves stakeholders beyond engineering. The pipeline does not own this.

Switches are the mechanism that decouples the two. Without switches, every deployment
is a release. With switches, code can be deployed freely and released on the
organisation's schedule.

---

## The Three Switch Types

### 1. Feature Switch

**Owner:** Engineering
**Lifecycle:** Temporary — must be removed after full rollout
**Purpose:** Controls deployment of new features and enhancements during development

A feature switch exists solely to make continuous deployment safe. It allows incomplete
or unvalidated code to be merged to `main` and deployed to production without being
accessible to users. Once the feature is released and stable, the switch is removed —
it is technical debt the moment it is no longer serving its purpose.

**Applies to:**
- New features
- Enhancements to existing features

**Does not apply to:**
- Bug fixes — deploy directly, no switch needed
- Functionality switches — the switch IS the feature
- Preview switches — the switch IS the feature

**Exit condition:** Remove the switch as a follow-up task once the feature is fully
enabled and stable. Track this as a separate requirement.

---

### 2. Functionality Switch

**Owner:** Product / Commercial
**Lifecycle:** Permanent — part of the product's commercial model
**Purpose:** Gates access to features based on licence, tier, or entitlement

A functionality switch controls what customers can use based on what they have paid for
or been granted. It is not a temporary development tool — it is a permanent part of the
product architecture. It evolves with the pricing model, not with feature delivery.

**Examples:** premium features, enterprise-only capabilities, add-on modules

**Exit condition:** None — functionality switches are permanent. They are retired only
when the commercial model changes.

---

### 3. Preview Switch

**Owner:** Product / UX
**Lifecycle:** Medium-term — retired when the old version is removed
**Purpose:** User-controlled opt-in to a new experience before it becomes the default

A preview switch lets users choose to try a new version of something (a dashboard,
a workflow, a UI) while the old version remains available. It exists as long as both
versions coexist. When the old version is retired, the switch and the old version
are removed together.

**Example:** "Try the new dashboard" — users can opt in, revert to the old one, and
the old one remains the default until the product team decides to retire it.

**Exit condition:** Remove when the old version is retired. This is a product decision,
not an engineering one.

---

## Feature Switch Modes

A feature switch operates in one of two modes. The mode must be decided at scoping
time — it determines the implementation pattern.

### Toggle Mode

The code is safe to execute. The switch controls whether users can access the feature.
It can be flipped at runtime without a deployment.

- Feature exists and works correctly
- Access is simply enabled or disabled
- Appropriate when the feature is complete but release is pending

### Permanent Disable Mode

The code must not execute. The switch is a deployment safety guard preventing broken,
incomplete, or potentially destructive code from running in production.

- Feature code is deployed but execution is blocked at the code level
- Protects against incomplete migrations, breaking API changes, or partially wired logic
- Requires a code change (not just a config change) to move to toggle mode

**This mode is what makes trunk-based development safe.** It allows incomplete work
to be merged to `main` continuously without deployment risk.

---

## Lifecycle Summary

```
Feature switch (permanent disable)
    → development complete
Feature switch (toggle off)
    → release decision made
Feature switch (toggle on)
    → stable and fully rolled out
Switch removed
```

Functionality and preview switches do not follow this lifecycle — they are permanent
or semi-permanent product artefacts, not temporary delivery tools.

---

## Decision Guide

During scoping, the agent asks: *"How should this feature reach users?"*

| Answer | Switch type | Mode | Lifecycle |
|---|---|---|---|
| Immediately on deployment | None | — | — |
| Hidden until release decision | Feature switch | Permanent disable → toggle | Remove after rollout |
| Gated by licence or tier | Functionality switch | Toggle (permanent) | Never removed |
| User opt-in preview | Preview switch | Toggle (user-controlled) | Remove when old version retired |

---

## Exceptions

The feature switch default (features and enhancements deploy behind a switch) may be
waived by the human during scoping. Common valid exceptions:

- **MVP / greenfield development** — no existing users to protect, everything is new
- **Infrastructure changes** — internal refactoring with no user-facing behaviour change
- **Early-stage repos** — product not yet live; the product itself is the ultimate switch

The exception and its reason must be recorded in the feature issue Deployment Strategy
section.
