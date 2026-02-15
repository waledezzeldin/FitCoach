# Flutter -> Backend Integration Parity Audit

This audit compares Flutter repositories with backend routes and flags mismatches.
Sources: `mobile/lib/data/repositories/*`, `backend/src/routes/*`.

## Summary of Mismatches (Action Required)
### StoreRepository vs Backend
- Flutter uses `/store/products`, `/store/categories`, `/store/products/:id/reviews`
  but backend exposes `/products`, `/products/categories`, `/products/:id/reviews`.
- Flutter uses `PUT /orders/:id/cancel`; backend expects `POST /orders/:id/cancel`.
- Flutter uses `GET /orders/:id/track`; backend has no `/orders/:id/track`.

### PaymentRepository vs Backend
- Flutter uses Stripe/Tap endpoints:
  - `/payments/stripe/create-intent`, `/payments/stripe/confirm`
  - `/payments/tap/create-charge`, `/payments/tap/status/:chargeId`
  - `/payments/prices`, `/payments/cancel-subscription`, `/payments/payment-method`, `/payments/apply-promo`
- Backend exposes:
  - `/payments/create-checkout`, `/payments/upgrade`, `/payments/cancel`
  - `/payments/subscription`, `/payments/history`, `/payments/invoice/:paymentId`
  - Webhooks: `/payments/webhook/stripe`, `/payments/webhook/tap`

### MessagingRepository vs Backend
- Flutter uses `/conversations/*` and `/messages/send`.
- Backend exposes `/messages/conversations`, `/messages/conversations/:id`,
  and `POST /messages` for sending.

### WorkoutRepository vs Backend
- Flutter uses `/workouts/exercises/:exerciseId/complete` and `/workouts/exercises/substitute`.
- Backend expects `/workouts/:id/exercises/:exerciseId/complete`
  and `/workouts/:id/substitute-exercise`.

## Repository Coverage Notes
- InBody endpoints are implemented in `workout_repository.dart` and map to `/inbody/*`.
- Notification settings use `/settings/notifications` (backend exists).
- No dedicated Flutter repositories found for:
  - `/bookings/*`
  - `/video-calls/*`
  - `/notifications/*`
  - `/progress/*`
  - `/ratings/*`
  - `/exercises/stats` (admin)
  - `/admin/*` settings and subscriptions (Flutter has admin screens, but repo coverage needs verification)

## Next Actions
- Align Flutter endpoints to backend or update backend to match Flutter paths.
- Add missing repositories or move endpoints into appropriate existing repos.
- Validate request/response models for each mapped endpoint.

## Progress Log
- [ ] 2025-__-__: Integration mismatches documented.
