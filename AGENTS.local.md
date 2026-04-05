# AGENTS.local.md — Local Overrides

This file contains project-specific rules and overrides that extend or
supersede the global protocol defined in `base/AGENTS.md`.

This file is never overwritten by a template sync.

---

<!-- Add local rules below this line -->

## Release Process

This is the `agentic-development` template repo. Releasing a new version is a deliberate
human action — not every merge needs a release.

### When to release
Batch related changes into a meaningful version. Use semantic versioning:
- `fix:` commits only → patch bump (e.g. v0.1.2 → v0.1.3)
- `feat:` commits → minor bump (e.g. v0.1.2 → v0.2.0)
- Breaking changes → major bump (e.g. v0.1.2 → v1.0.0)

### How to release
1. Review commits since the last release:
   ```bash
   gh release list --limit 1
   git log --oneline <last-tag>..HEAD
   ```
2. Create the release:
   ```bash
   gh release create vX.Y.Z --generate-notes --target main
   ```

### Note
`TEMPLATE_VERSION` in this repo is not updated on release — the git tag is the version.
Downstream repos track their own sync version in their local `TEMPLATE_VERSION` file.
