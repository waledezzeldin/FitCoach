# CI/CD & Quality Gates Plan

Current workflows:
- `/.github/workflows/ci.yml` (backend lint, Flutter analyze)
- `/.github/workflows/flutter_ci.yml` (Flutter analyze/test/build)

## Required Gates
### Backend
- [ ] Install + test (unit + integration)
- [ ] Enforce coverage threshold (100% target)
- [ ] Lint + format checks
- [ ] Optional: DB service for integration tests

### Flutter
- [ ] Flutter analyze + test
- [ ] Enforce coverage threshold (100% target)
- [ ] Run golden tests (light/dark/RTL)
- [ ] Fail on unapproved golden diffs

### Docs & Contracts
- [ ] Validate API contract snapshots
- [ ] Fail builds on doc drift for endpoint specs

## Proposed Pipeline Updates
- [ ] Merge Flutter and backend tests into a single pipeline stage matrix.
- [ ] Add coverage upload (summary + artifacts).
- [ ] Add golden test approvals (PR comment or artifact).
- [ ] Add environment matrix for dev/staging if needed.

## Progress Log
- [ ] 2025-__-__: CI/CD quality gates plan created.
