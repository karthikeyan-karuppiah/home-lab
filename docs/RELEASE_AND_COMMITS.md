# Release Process & Conventional Commits Reference

This repository uses **Release Please** (by Google) together with **Conventional Commits** to automatically manage versioning, changelogs, and GitHub Releases.

---

## How the Release Process Works

1. Developers push commits to the `main` branch using Conventional Commit messages.
2. On every push to `main`, the CI workflow runs:
   - Lint & security scans
   - Release Please
3. Release Please analyses the commits since the last release and either:
   - Opens a new **Release PR**, or
   - Updates an existing Release PR
4. The Release PR contains:
   - Updated `CHANGELOG.md`
   - Updated version in `.release-please-manifest.json`
5. When the Release PR is merged, Release Please automatically:
   - Creates a Git tag (e.g. `v1.2.0`)
   - Creates a GitHub Release

You never need to create tags or releases manually.

---

## Conventional Commit Format

### Allowed Types

| Type        | Description                                              | Version Impact     | Shown in Changelog? |
|-------------|----------------------------------------------------------|--------------------|---------------------|
| `feat`      | A new feature or capability                              | **Minor** bump     | Yes – Features      |
| `fix`       | A bug fix                                                | **Patch** bump     | Yes – Bug Fixes     |
| `perf`      | A performance improvement                                | Patch bump         | Yes – Performance   |
| `revert`    | Reverts a previous commit                                | Patch bump         | Yes – Reverts       |
| `docs`      | Documentation only changes                               | Patch (or none)    | Yes – Documentation |
| `chore`     | Routine tasks, dependency updates, maintenance           | Patch (or none)    | Yes – Miscellaneous |
| `refactor`  | Code change that neither fixes a bug nor adds a feature  | Patch              | Yes – Refactoring   |
| `test`      | Adding or correcting tests                               | None               | No (hidden)         |
| `build`     | Changes to build system or external dependencies         | None               | No (hidden)         |
| `ci`        | Changes to CI configuration and scripts                  | None               | No (hidden)         |
| `style`     | Formatting, whitespace, missing semicolons, etc.         | None               | No (hidden)         |

---



