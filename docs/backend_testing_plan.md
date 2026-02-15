# Backend Testing Plan (100% Coverage Target)

This plan defines test scope for controllers, services, and routes.

## Coverage Targets
- Unit tests: 100% for services, validators, utilities.
- Integration tests: 100% for routes (happy paths + error paths).
- Contract tests: request/response schema validation for every endpoint.

## Test Matrix by Area
### Auth
- [ ] OTP send/verify/resend
- [ ] Login/register/refresh/logout
- [ ] Token expiry and invalid token cases

### Users & Intake
- [ ] Profile CRUD
- [x] Intake stage 1 + 2
- [ ] Quota checks, trial start
- [x] Photo upload validation

### Workouts & Exercises
- [ ] Template retrieval
- [ ] Workout generation
- [ ] Exercise completion
- [x] Injury substitution
- [x] Workout logging persistence (`POST /workouts/log`)
- [ ] Coach/admin plan CRUD

### Nutrition
- [x] Access status & trial unlock
- [ ] Plan generation
- [x] Meal completion
- [x] Coach/admin plan CRUD

### Messaging & Notifications
- [x] Conversation list and message send/read/delete
- [x] Attachments gating
- [ ] Notification preferences, register/unregister, history

### Store & Payments
- [x] Product CRUD and reviews
- [x] Orders (create, cancel, admin status updates)
- [ ] Payments (checkout/upgrade/cancel/subscription/history/invoice)
- [x] Webhook signature validation (Tap HMAC + Stripe signature path)

### Coach & Admin
- [ ] Coach analytics, earnings, appointments
- [ ] Client reports, fitness score assignment
- [x] Admin settings, subscription plan updates, audit logs
- [x] Admin create-coach route + role authorization checks

### InBody & Progress
- [ ] Scan CRUD
- [ ] Trends/progress/statistics
- [ ] Goals set/get
- [x] Progress entry CRUD

## Infrastructure
- [ ] Test DB fixtures and teardown
- [ ] Mock external services (Twilio, S3, payment gateways)
- [ ] Deterministic time/UUID providers
- [ ] Coverage gates in CI

## Progress Log
- [x] 2026-02-02: Added intake, messaging, nutrition, store/orders, progress tests.
- [x] 2026-02-12: Added workout logging controller tests.
- [x] 2026-02-12: Added Tap webhook signature verification controller tests.
- [x] 2026-02-12: Added AI extraction feature-flag behavior service tests.
- [x] 2026-02-12: Added users photo upload route contract/validation tests.
- [x] 2026-02-12: Added admin create-coach route authorization tests.
- [x] 2026-02-12: Added messaging response-wrapper contract tests.
