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
- [ ] Intake stage 1 + 2
- [ ] Quota checks, trial start
- [ ] Photo upload validation

### Workouts & Exercises
- [ ] Template retrieval
- [ ] Workout generation
- [ ] Exercise completion
- [ ] Injury substitution
- [ ] Coach/admin plan CRUD

### Nutrition
- [ ] Access status & trial unlock
- [ ] Plan generation
- [ ] Meal completion
- [ ] Coach/admin plan CRUD

### Messaging & Notifications
- [ ] Conversation list and message send/read/delete
- [ ] Attachments gating
- [ ] Notification preferences, register/unregister, history

### Store & Payments
- [ ] Product CRUD and reviews
- [ ] Orders (create, cancel, admin status updates)
- [ ] Payments (checkout/upgrade/cancel/subscription/history/invoice)
- [ ] Webhook signature validation

### Coach & Admin
- [ ] Coach analytics, earnings, appointments
- [ ] Client reports, fitness score assignment
- [ ] Admin settings, subscription plan updates, audit logs

### InBody & Progress
- [ ] Scan CRUD
- [ ] Trends/progress/statistics
- [ ] Goals set/get

## Infrastructure
- [ ] Test DB fixtures and teardown
- [ ] Mock external services (Twilio, S3, payment gateways)
- [ ] Deterministic time/UUID providers
- [ ] Coverage gates in CI

## Progress Log
- [ ] 2025-__-__: Backend testing plan created.
