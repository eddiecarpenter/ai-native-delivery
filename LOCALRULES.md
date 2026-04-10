# Local Rules

This file contains project-specific rules and overrides that extend or
supersede the global protocol defined in `.ai/RULEBOOK.md`.

This file is optional. If it does not exist, no local rules are applied.

---

## GitHub Actions Sync

This is the `ai-native-delivery` template repo. Unlike downstream repos, there is no
upstream to sync from — `.github/workflows/` must be kept in sync with `.ai/.github/workflows/`
manually whenever a workflow file is added or changed.

**After any change to `.ai/.github/workflows/`:**
```bash
cp .ai/.github/workflows/<changed-file>.yml .github/workflows/<changed-file>.yml
git add .github/workflows/<changed-file>.yml
git commit -m "chore: sync <changed-file>.yml from .ai/"
```

Check for drift at any time:
```bash
diff -r .ai/.github/workflows/ .github/workflows/
```

---

## Local Skills

Local skills for this repo live in `skills/`. See `skills/release.md` for the release process.
