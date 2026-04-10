# Release Process

This is the `ai-native-delivery` template repo. Releasing a new version is a deliberate
human action — not every merge needs a release.

## When to release

Batch related changes into a meaningful version. Use semantic versioning:
- `fix:` commits only → patch bump (e.g. v0.1.2 → v0.1.3)
- `feat:` commits → minor bump (e.g. v0.1.2 → v0.2.0)
- Breaking changes → major bump (e.g. v0.1.2 → v1.0.0)

## How to release

Push a tag — that is the complete release act:

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

The automated release chain fires:

1. **`publish-release.yml`** — updates `.ai/config.yml` to the new tag, creates
   the GitHub release stub
2. **`release.yml`** — triggered by the release being published, runs the Goose
   release recipe, generates AI release notes from commits since the previous tag,
   updates the release body

No manual steps required after pushing the tag.

## Review commits before tagging (optional)

```bash
gh release list --limit 1
git log --oneline <last-tag>..HEAD
```
