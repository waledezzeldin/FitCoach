# Backend Integration Guide (Routes, Controllers, Contracts)

Last updated: 2026-02-12

## Scope
Operational ownership for backend integration points consumed by Flutter.

## Route Ownership
- `routes/users.js` + `controllers/userController.js`
  - Profile, quota, intake, subscription compatibility updates, profile photo upload/remove.
- `routes/settings.js` + `controllers/settingsController.js`
  - Notifications, coach/admin profile settings, account-level preferences.
- `routes/payments.js` + `controllers/paymentController.js` + `services/paymentService.js`
  - Checkout/upgrade/cancel/subscription/history/invoice and provider webhooks.
- `routes/messages.js` + `controllers/messageController.js`
  - Conversations, messages, uploads, read state.
- `routes/workouts.js` + `controllers/workoutController.js`
  - Active plan, completion/substitution, workout log compatibility path.
- `routes/inbody.js` + `controllers/inbodyController.js` + `services/aiExtractionService.js`
  - Manual scan APIs and gated AI extraction path.

## Response Wrapper Policy
- Keep wrappers stable for frontend parsing:
  - Messaging send/upload wrappers (`message`, `attachment`).
  - Payment/subscription wrappers.
  - Settings/profile wrappers where applicable.
- Compatibility endpoints should avoid breaking field names expected by mobile models.

## Auth and Access
- Protected business routes require bearer auth middleware.
- Webhook routes are unauthenticated but must verify provider signature.
- Tier-gated features must fail clearly with upgrade/error response.

## Fail-Closed Requirements
- Invalid/missing payment webhook signatures: reject.
- Simulated/experimental services must be disabled by default behind explicit flag.

## Backend Validation Baseline
- `node --check` on modified controllers/routes/services.
- Controller/route tests for newly changed behavior.
- Integration tests for critical auth + role-protected flows.
