# AGENTS.local.md — Local Overrides

This file contains project-specific rules and overrides that extend or
supersede the global protocol defined in `base/AGENTS.md`.

This file is never overwritten by a template sync.

---

<!-- Add local rules below this line -->

## GitHub Actions Sync

This is the `agentic-development` template repo. Unlike downstream repos, there is no
upstream to sync from — `.github/workflows/` must be kept in sync with `base/.github/workflows/`
manually whenever a workflow file is added or changed.

**After any change to `base/.github/workflows/`:**
```bash
cp base/.github/workflows/<changed-file>.yml .github/workflows/<changed-file>.yml
git add .github/workflows/<changed-file>.yml
git commit -m "chore: sync <changed-file>.yml from base/"
```

Check for drift at any time:
```bash
diff -r base/.github/workflows/ .github/workflows/
```

---

## Local Skills

Local skills for this repo live in `skills/`. See `skills/release.md` for the release process.
