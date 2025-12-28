# Documentation Audit & Restructure Plan

This audit identifies outdated/missing docs and proposes a restructure.

## Findings
### Mobile Docs (`mobile/docs`)
- Duplicate files: `README.md` and `README2.md`, `QUICK_START.md` and `QUICK_START2.md`.
- Status docs claim 100% completion while parity reports indicate gaps.
- Multiple overlapping status reports (`STATUS.md`, `PROGRESS.md`, `COMPLETION_STATUS.md`) without a single source of truth.

### Backend Docs (`backend/docs`)
- `backend/docs/README.md` references missing files:
  - `API_OVERVIEW.md`, `AUTH_API.md`, `USER_API.md`, `WORKOUT_API.md`,
    `NUTRITION_API.md`, `COACH_API.md`, `ADMIN_API.md`, `STORE_API.md`.

### SRS Docs (`docs/docs`)
- `03-SCREEN-SPECIFICATIONS.md` is explicitly Part 1 only (screens 1-8).
- Part 2 (coach/admin/supporting screens) is missing.

### UI_UX Docs (`UI_UX/src/docs`)
- Multiple reorganization logs and indexes; needs a single master index.
- Some migration references duplicate the SRS content and conflict with current status.

## Restructure Proposal
### 1) Create a Single Master Index
- New `docs/DOCUMENTATION_INDEX.md` with links to:
  - SRS (requirements)
  - UI_UX React source
  - Flutter docs
  - Backend docs
  - Parity plans/reports

### 2) Mobile Docs Cleanup
- Pick one `README.md` and one `QUICK_START.md` as canonical.
- Archive duplicates under `mobile/docs/archive/`.
- Add a single `STATUS.md` for current parity + test coverage.

### 3) Backend Docs Completion
- Create missing API docs or update README to point to actual route inventory.
- Add `backend/docs/API_OVERVIEW.md` generated from routes.

### 4) SRS Completion
- Restore Part 2 screen specs or link to React components as source-of-truth.

### 5) UI_UX Docs Consolidation
- Add `UI_UX/src/docs/INDEX.md` as single entry point.
- Move reorganization logs to `archive/`.

## Progress Log
- [ ] 2025-__-__: Documentation audit created.
