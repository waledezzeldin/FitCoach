# Flutter-React Parity & Full-Quality Plan

## Status
- Target: Flutter + Backend fully functional, modular, 100% test coverage, docs current.
- Source of truth: React UI_UX and SRS.

## How to use this plan
- Check items as they are completed.
- Add brief notes/links to PRs or files touched.
- Keep parity notes updated when requirements change.

## 1) Source-of-Truth Alignment
- [ ] Freeze visual tokens from React (`UI_UX/src/index.css`) into a parity checklist.
- [ ] Freeze screen flow and state expectations using `UI_UX/src/components/*`.
- [ ] Cross-reference SRS `docs/docs/03-SCREEN-SPECIFICATIONS.md` to lock UX states, errors, and RTL.
- [ ] Produce a single parity matrix by role (user/coach/admin).

## 2) Flutter UI/Flow Gap Audit
- [ ] Map every React screen/component to Flutter (`mobile/lib/presentation/screens/*`, widgets).
- [ ] Record missing screens (per `mobile/docs/REACT_VS_FLUTTER_COMPARISON.md`).
- [ ] Record modal-vs-screen mismatches (React screen vs Flutter modal).
- [ ] Record token mismatches: colors, radii, typography, spacing, shadows.
- [ ] Record RTL/layout deviations and copy differences.

## 3) Flutter Implementation Backlog (UI/Flow)
- [ ] Add missing user screens:
  - [ ] InBody input
  - [ ] Order history
  - [ ] Order detail
  - [ ] Payment management
- [ ] Add missing coach tools:
  - [ ] Coach profile
  - [ ] Coach settings
  - [ ] Client plan manager
  - [ ] Client report generator
  - [ ] Workout plan builder
  - [ ] Nutrition plan builder
  - [ ] Public coach profile
- [ ] Add missing admin tools:
  - [ ] Store management
  - [ ] Subscription management
  - [ ] System settings
  - [ ] Audit logs
- [ ] Add optional intro/walkthrough screens:
  - [ ] App intro
  - [ ] Workout intro
  - [ ] Nutrition intro
  - [ ] Store intro
  - [ ] Coach intro
- [ ] Convert modal-only views to full screens where React uses screens.
- [ ] Finish design-system components:
  - [ ] Tabs (primary/secondary)
  - [ ] Badges
  - [ ] Chips
  - [ ] Bottom navigation parity
  - [ ] Advanced list tiles
  - [ ] Progress indicators (all variants)
- [ ] Finalize theme parity (radii, spacing, borders, gradients, shadows).
- [ ] Lock RTL parity (layout mirroring, spacing, locale formatting).

## 4) Backend Parity + Modularization
- [ ] Audit backend endpoints vs `backend/docs` + SRS.
- [ ] Ensure all 61 endpoints exist and match request/response schema.
- [ ] Modularize into domain services:
  - [ ] Auth
  - [ ] User
  - [ ] Workout
  - [ ] Nutrition
  - [ ] Coach
  - [ ] Admin
  - [ ] Store
  - [ ] Notifications/Quotas
- [ ] Enforce validation, error handling, and response consistency.
- [ ] Add/update schema contracts for each endpoint.

## 5) Flutter-Backend Integration Parity
- [ ] Validate repositories against backend endpoints.
- [ ] Align request/response models and adapters.
- [ ] Ensure flows: OTP, intake, quotas, nutrition trials, checkout, coach tools, admin ops.
- [ ] Add missing data models and mappers.

## 6) Testing (Flutter) - 100% Coverage
- [ ] Unit tests: core utilities, services, models.
- [ ] Widget tests: all design-system components.
- [ ] Screen tests: all core screens per role.
- [ ] Golden tests: light/dark + RTL for all core UI.
- [ ] Navigation tests: deep links, edge flows, gated features.
- [ ] Localization tests: RTL layouts, formatting, pluralization.

## 7) Testing (Backend) - 100% Coverage
- [ ] Unit tests: controllers/services/validators.
- [ ] Integration tests: all endpoints, auth/permissions, error cases.
- [ ] Contract tests: request/response schema validation.
- [ ] Data fixtures and teardown to keep tests deterministic.

## 8) CI/CD & Quality Gates
- [ ] Enforce coverage thresholds for Flutter + backend.
- [ ] Add linting/formatting gates.
- [ ] Add golden test approval workflow.
- [ ] Ensure full pipeline runs per module and aggregate.

## 9) Documentation Audit & Restructure
- [ ] Audit `mobile/docs` for outdated status claims.
- [ ] Audit `backend/docs` for API drift vs code.
- [ ] Audit SRS `docs/docs` for mismatched screen/feature claims.
- [ ] Audit `UI_UX/src/docs` for outdated requirements.
- [ ] Consolidate duplicate readmes into a master index.
- [ ] Create parity reports:
  - [ ] React -> Flutter parity
  - [ ] SRS -> Backend parity

## 10) Final Validation & Release Readiness
- [ ] Run full test suites and record results.
- [ ] Build artifacts (APK/IPA, backend build).
- [ ] Verify env configs, secrets, monitoring, logging.
- [ ] Complete release readiness checklist.

## Progress Log
- [ ] 2025-__-__: Plan created.
