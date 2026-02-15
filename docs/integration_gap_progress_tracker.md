# Flutter-Backend Integration Gap Progress Tracker

Last updated: 2026-02-12  
Scope: `mobile/` + `backend/` integration gaps, documentation updates, and frontend/backend testing coverage.

## How To Use This Tracker
- Status values: `Not Started`, `In Progress`, `Blocked`, `Done`.
- Update `Progress %` per item as work advances.
- When item reaches `Done`, add PR/commit ref in `Validation/Reference`.
- Keep this file as the single source of truth for integration closure.

## Overall Progress

| Stream | Total Items | Done | In Progress | Blocked | Not Started | Progress |
|---|---:|---:|---:|---:|---:|---:|
| Critical API/Contract Fixes | 9 | 9 | 0 | 0 | 0 | 100% |
| Frontend Feature Completion | 8 | 8 | 0 | 0 | 0 | 100% |
| Backend Feature Completion | 4 | 4 | 0 | 0 | 0 | 100% |
| Documentation Updates | 8 | 8 | 0 | 0 | 0 | 100% |
| Testing Updates (FE+BE) | 12 | 12 | 0 | 0 | 0 | 100% |
| **Total** | **41** | **41** | **0** | **0** | **0** | **100%** |

---

## A) Critical API/Contract Fixes

| ID | Gap | Frontend Work | Backend Work | Status | Progress % | Priority | Validation/Reference |
|---|---|---|---|---|---:|---|---|
| API-01 | `/users/subscription` used by mobile but not exposed by backend | Update `UserRepository.updateSubscription()` to real API path or remove call path | Add/confirm supported subscription update endpoint and contract | Done | 100 | P0 | `backend/src/routes/users.js`, `backend/src/controllers/userController.js` |
| API-02 | Profile photo upload flow broken (`_getUserId()` returns `null`) | Implement user-id resolution and upload contract in `user_repository.dart` and `profile_edit_screen.dart` | Align `uploadPhoto` to file upload flow (or clearly enforce URL-only contract) | Done | 100 | P0 | FE: `mobile/lib/data/repositories/user_repository.dart`; BE: `backend/src/controllers/userController.js`, `backend/src/services/s3Service.js` |
| API-03 | Admin create-coach endpoint missing (`POST /admin/coaches`) while Flutter uses it | Keep/create request model in `AdminRepository.createCoach()` | Add route/controller for create coach or remove unsupported frontend path | Done | 100 | P0 | `backend/src/routes/admin.js`, `backend/src/controllers/adminController.js` |
| API-04 | Admin repository lacks auth headers for protected admin endpoints | Add secure token header injection in `AdminRepository` | No change if contract stays protected | Done | 100 | P0 | `mobile/lib/data/repositories/admin_repository.dart` |
| API-05 | Subscription plan admin repo lacks auth headers | Add token headers in `SubscriptionPlanRepository` for admin CRUD | No change if contract stays protected | Done | 100 | P0 | `mobile/lib/data/repositories/subscription_plan_repository.dart` |
| API-06 | Store categories parsing mismatch (`name` expected, backend returns `category`) | Parse flexible category payload in `StoreRepository.getCategories()` | Optionally return normalized `name` field for compatibility | Done | 100 | P1 | `mobile/lib/data/repositories/store_repository.dart` |
| API-07 | Payment repo methods call unsupported verbs/paths for `/payments/subscription` | Align payment repository methods to actual routes | Add missing routes if product needs them (`POST/PUT /payments/subscription`) | Done | 100 | P0 | `mobile/lib/data/repositories/payment_repository.dart` |
| API-08 | Messaging attachment response parse bug (`sendMessageWithAttachment`) | Parse `response.data['message']` wrapper | Keep consistent response wrapper in controller | Done | 100 | P0 | `mobile/lib/data/repositories/messaging_repository.dart` |
| API-09 | Subscription manager may show success without real backend update (non-demo) | Ensure post-payment state refresh and no fake success paths | Ensure webhook/subscription status sync path is deterministic | Done | 100 | P1 | `mobile/lib/presentation/screens/subscription/subscription_manager_screen.dart` |

---

## B) Frontend Feature Completion Gaps

| ID | Screen/Feature | Gap | Required Work | Status | Progress % | Priority | Validation/Reference |
|---|---|---|---|---|---:|---|---|
| FE-01 | `account_screen.dart` | Multiple `coming soon` paths | Implement or hide unavailable actions behind feature flags | Done | 100 | P1 | `mobile/lib/presentation/screens/account/account_screen.dart` |
| FE-02 | `payment_management_screen.dart` | Local mock-only payment methods | Integrate with payment APIs or remove from production nav | Done | 100 | P1 | `mobile/lib/presentation/screens/account/payment_management_screen.dart` |
| FE-03 | `profile_edit_screen.dart` | Photo upload actions are TODO | Camera/gallery/remove + upload end-to-end integration | Done | 100 | P0 | `mobile/lib/presentation/screens/profile/profile_edit_screen.dart`, `mobile/lib/data/repositories/user_repository.dart`, `backend/src/controllers/userController.js` |
| FE-04 | `progress_screen.dart` | Mixed real data with mock charts/stats | Replace remaining mock visuals with backend-driven metrics | Done | 100 | P1 | `mobile/lib/presentation/screens/progress/progress_screen.dart` |
| FE-05 | `workout_timer_screen.dart` | Rest-time adjustment TODO | Implement state update + persistence behavior | Done | 100 | P2 | `mobile/lib/presentation/screens/workout/workout_timer_screen.dart` |
| FE-06 | `video_call_screen.dart` rating | Rating modal does not submit to API | Add repository + API call to `/ratings` on submit | Done | 100 | P1 | `mobile/lib/data/repositories/rating_repository.dart`, `mobile/lib/presentation/screens/video_call/video_call_screen.dart` |
| FE-07 | Auth dead screens | `login_screen.dart` and `otp_auth_screen.dart` not used in main flow | Remove or wire intentionally; avoid dead maintenance surface | Done | 100 | P2 | `mobile/lib/presentation/screens/auth/login_screen.dart` (removed), `mobile/lib/presentation/screens/auth/otp_auth_screen.dart` (removed) |
| FE-08 | Account role sections | Coach/Admin sections partly local placeholders | Replace local state with backend-backed profile/settings | Done | 100 | P1 | `mobile/lib/presentation/screens/account/account_screen.dart`, `mobile/lib/data/repositories/user_repository.dart`, `backend/src/routes/settings.js`, `backend/src/controllers/settingsController.js` |

---

## C) Backend Feature Completion Gaps

| ID | Backend Module | Gap | Required Work | Status | Progress % | Priority | Validation/Reference |
|---|---|---|---|---|---:|---|---|
| BE-01 | `workoutController.logWorkoutCompat` | Stub-only success response | Implement real workout logging side effects/data writes | Done | 100 | P1 | `backend/src/controllers/workoutController.js`, `backend/__tests__/controllers/workoutController.test.js` |
| BE-02 | `userController.uploadPhoto` | S3/file handling TODO | Implement final upload flow and response contract | Done | 100 | P0 | `backend/src/controllers/userController.js`, `backend/src/services/s3Service.js` |
| BE-03 | `paymentController.tapWebhook` | Signature verification TODO | Implement Tap signature verification and tests | Done | 100 | P1 | `backend/src/controllers/paymentController.js`, `backend/src/routes/payments.js`, `backend/__tests__/controllers/paymentController.test.js` |
| BE-04 | `aiExtractionService` | Simulated extraction only | Integrate real OCR/AI provider or gate as beta feature | Done | 100 | P2 | `backend/src/services/aiExtractionService.js`, `backend/src/controllers/inbodyController.js`, `backend/__tests__/services/aiExtractionService.test.js` |

---

## D) Documentation Update Plan

| ID | Doc Update | Scope | Status | Progress % | Owner | Validation/Reference |
|---|---|---|---|---:|---|---|
| DOC-01 | API contract update | Update endpoint matrix with final FE/BE paths and payloads | Done | 100 | TBD | `docs/api_contract_v2.md` |
| DOC-02 | Frontend integration guide | Repositories/providers mapping to backend routes | Done | 100 | TBD | `docs/frontend_integration_guide.md` |
| DOC-03 | Backend integration guide | Route ownership, response wrappers, auth requirements | Done | 100 | TBD | `docs/backend_integration_guide.md` |
| DOC-04 | Profile/photo flow doc | Document selected upload contract (multipart vs URL) | Done | 100 | TBD | `docs/profile_photo_flow.md` |
| DOC-05 | Payments lifecycle doc | Checkout, webhook, subscription status refresh flow | Done | 100 | TBD | `docs/payments_lifecycle.md` |
| DOC-06 | Messaging contract doc | Conversation/message/attachment response formats | Done | 100 | TBD | `docs/messaging_contract.md` |
| DOC-07 | Feature flag/coming-soon policy | Rules for hiding incomplete production UI | Done | 100 | TBD | `docs/feature_flag_policy.md` |
| DOC-08 | Release readiness checklist update | Add integration closure gates for FE/BE | Done | 100 | TBD | `docs/release_readiness_checklist.md` |

---

## E) Testing Update Plan (Frontend + Backend)

### Frontend Tests

| ID | Test Task | Scope | Status | Progress % | Validation/Reference |
|---|---|---|---|---:|---|
| T-FE-01 | `UserRepository` contract tests | Subscription endpoint + profile upload + error handling | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-02 | `AdminRepository` auth tests | Protected route auth header enforcement | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-03 | `SubscriptionPlanRepository` auth tests | Admin plan CRUD with auth | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-04 | `StoreRepository` parsing tests | Categories payload compatibility | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-05 | `PaymentRepository` contract tests | Correct route/verb usage and response parsing | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-06 | `MessagingRepository` tests | Attachment send wrapper parsing | Done | 100 | `mobile/test/repositories/repository_contract_coverage_test.dart` |
| T-FE-07 | Widget/integration tests | Profile photo flow, account settings save, rating submit | Done | 100 | `mobile/test/widgets/feature_flow_widget_test.dart`, `mobile/lib/presentation/screens/profile/profile_edit_screen.dart`, `mobile/lib/presentation/screens/settings/notification_settings_screen.dart`, `mobile/lib/presentation/screens/video_call/video_call_screen.dart` |

### Backend Tests

| ID | Test Task | Scope | Status | Progress % | Validation/Reference |
|---|---|---|---|---:|---|
| T-BE-01 | Route tests for new/changed admin endpoints | `POST /admin/coaches` and auth-role checks | Done | 100 | `backend/__tests__/integration/admin.integration.test.js` |
| T-BE-02 | Users route tests | Profile photo upload contract and validation | Done | 100 | `backend/__tests__/routes/users.photo.routes.test.js` |
| T-BE-03 | Payments route tests | Tap signature verification and subscription routes | Done | 100 | `backend/__tests__/controllers/paymentController.test.js` |
| T-BE-04 | Workout logging tests | Verify real persistence for log flow | Done | 100 | `backend/__tests__/controllers/workoutController.test.js` |
| T-BE-05 | Messaging tests | Ensure response wrappers remain stable | Done | 100 | `backend/__tests__/controllers/messageController.contract.test.js` |

---

## F) Milestones

| Milestone | Exit Criteria | Target Date | Status |
|---|---|---|---|
| M1: P0 Contract Closure | API-01, API-02, API-03, API-04, API-05, API-07, API-08 done | TBD | Done |
| M2: UI Completion Pass | FE-01..FE-06 done or intentionally gated | TBD | Done |
| M3: Backend Completion Pass | BE-01..BE-04 done/gated with explicit docs | TBD | Done |
| M4: Docs + Tests Green | DOC-01..DOC-08 and all T-FE/T-BE complete | TBD | Done |

---

## G) Change Log

- 2026-02-12: Initial tracker created from full-stack audit findings.
- 2026-02-12: Closed API-04/API-05/API-06/API-08 in mobile repositories; added auth headers for admin flows and response/category parsing compatibility.
- 2026-02-12: Advanced API-02 and BE-02 by implementing user-id lookup in frontend profile upload and backend multipart profile-photo upload with S3 service integration.
- 2026-02-12: Closed API-01 by adding `PATCH /users/subscription` backend compatibility route/controller.
- 2026-02-12: Closed API-03 by adding `POST /admin/coaches` backend route/controller with user+coach creation transaction.
- 2026-02-12: Validation run completed for edited files (`dart analyze` targeted repositories, `node --check` for updated backend controllers/routes/services, and Flutter tests for `test/repositories/messaging_repository_test.dart` + `test/providers/auth_provider_test.dart`).
- 2026-02-12: Closed API-07 by aligning payment repository methods to existing backend routes (`/payments/subscription` GET and `/payments/upgrade` POST usage only).
- 2026-02-12: Ran full `dart analyze mobile/lib mobile/test` and backend `node --check` sweep; analyzer reported existing warnings plus fixed test-level messaging signature errors.
- 2026-02-12: Closed API-09 by removing optimistic success path in subscription manager and requiring real subscription update + profile refresh before success confirmation.
- 2026-02-12: Closed FE-03 by implementing profile photo camera/gallery/remove actions wired to backend upload/remove API flow.
- 2026-02-12: Hardened demo-mode gating so demo identifiers/data are only used when build-time demo flag is enabled (`DEMO_MODE`/`DMO_MODE`).
- 2026-02-12: Closed FE-05 by implementing workout rest-time adjustment state updates in timer flow.
- 2026-02-12: Closed FE-06 by wiring post-call rating submission to backend `/ratings` via new `RatingRepository`.
- 2026-02-12: Advanced FE-02 by integrating real payment history loading in non-demo mode while keeping local method editing demo-only.
- 2026-02-12: Closed FE-04 by deriving non-demo progress summaries/charts/achievements from backend progress entries and limiting mock data to demo mode only.
- 2026-02-12: Closed FE-01 by hiding unresolved account actions in production and leaving coming-soon entries demo-gated only.
- 2026-02-12: Closed FE-02 by removing mock payment-method management from production mode and using real payment history integration.
- 2026-02-12: Closed FE-08 by replacing non-demo coach/admin account placeholders with backend-backed settings profile cards and loading/error state handling.
- 2026-02-12: Closed FE-07 by removing dead auth placeholder screens (`login_screen.dart`, `otp_auth_screen.dart`) that are not used in the active auth flow.
- 2026-02-12: Closed BE-01 by implementing real workout logging persistence in `logWorkoutCompat` (marks `workout_day_exercises` complete for the authenticated user and records session audit metadata).
- 2026-02-12: Closed T-BE-04 by adding controller-level tests for workout logging validation and successful persistence path.
- 2026-02-12: Closed BE-03 by implementing Tap webhook signature verification (HMAC validation against raw payload) and failing closed for invalid/missing signatures.
- 2026-02-12: Closed T-BE-03 by adding Tap webhook signature verification tests (reject invalid signature, accept valid signature).
- 2026-02-12: Closed BE-04 by gating simulated InBody AI extraction behind explicit feature flag (`ENABLE_SIMULATED_AI_EXTRACTION`) with 503 response when disabled.
- 2026-02-12: Closed DOC-05 with end-to-end payment lifecycle documentation, including webhook verification behavior and subscription refresh expectations.
- 2026-02-12: Closed DOC-07 with explicit feature-flag policy for demo/simulated/incomplete functionality across frontend and backend.
- 2026-02-12: Closed T-FE-01..T-FE-06 by adding repository contract/auth/parsing coverage for user/admin/subscription/store/payment/messaging repositories.
- 2026-02-12: Closed DOC-01 by updating API contract with webhook endpoints, Tap signature requirements, and AI extraction flag behavior.
- 2026-02-12: Closed DOC-02/DOC-03 by adding dedicated frontend/backend integration guides with repository/route ownership mapping.
- 2026-02-12: Closed DOC-04 by documenting production profile photo upload/remove contract and error handling path.
- 2026-02-12: Closed DOC-06 by documenting messaging response wrappers, socket payload contract, and tier-gated attachment rules.
- 2026-02-12: Closed DOC-08 by updating release readiness checklist with FE/BE integration closure gates and production flag checks.
- 2026-02-12: Closed T-BE-01 by extending admin integration coverage for `POST /admin/coaches` and non-admin access denial.
- 2026-02-12: Closed T-BE-02 by adding users photo route tests for upload contract success, validation error, and ownership authorization.
- 2026-02-12: Closed T-BE-05 by adding messaging controller contract tests that lock response wrapper shape for message send/upload flows.
- 2026-02-12: Closed T-FE-07 by adding widget flow tests for profile photo removal action, notification settings save behavior, and video-call rating submission path.
- 2026-02-12: Final hardening pass completed for remaining diagnostics in profile/photo, notification settings, and video-call flows (async context safety, deprecated API migration, constructor/import cleanup).
- 2026-02-12: Full verification executed: `flutter test` passed (198 tests), backend Jest suite passed with `--runInBand --forceExit` (188 passed, 54 skipped), and messages integration test mock aligned with current `checkMessageQuota` middleware stack.
- 2026-02-15: Mobile analyzer warning cleanup pass completed (warning count reduced to 0); removed dead/unused warning sources and redundant null assertions while preserving feature behavior.
