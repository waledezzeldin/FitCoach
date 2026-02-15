# Payments Lifecycle (Checkout -> Webhook -> Subscription State)

Last updated: 2026-02-12

## Scope
- Frontend: `mobile/lib/presentation/screens/subscription/subscription_manager_screen.dart`
- Backend routes: `backend/src/routes/payments.js`
- Backend controller/service: `backend/src/controllers/paymentController.js`, `backend/src/services/paymentService.js`

## Lifecycle
1. Client initiates checkout.
   - Endpoint: `POST /v2/payments/create-checkout`
   - Payload: `{ tier, billingCycle, provider }`
   - Provider options:
     - `stripe` for international flow.
     - `tap` for KSA flow.
2. Backend creates a pending transaction.
   - Table: `payment_transactions`
   - Status starts as `pending`.
3. Provider redirects user to hosted payment page.
4. Provider sends webhook callback.
   - Stripe: `POST /v2/payments/webhook/stripe` (raw body, Stripe signature verified by Stripe SDK).
   - Tap: `POST /v2/payments/webhook/tap` (JSON body + HMAC signature verification).
5. On successful capture/completion:
   - Backend activates subscription (`users.subscription_tier`, start/end dates).
   - Backend marks transaction as `completed`.
6. Frontend refreshes subscription status.
   - Endpoint: `GET /v2/payments/subscription`
   - UI success is shown only after real backend status update.

## Tap Webhook Signature Contract
- Route captures raw request body before JSON parse.
- Accepted header names:
  - `tap-signature`
  - `x-tap-signature`
- Verification algorithm:
  - `HMAC-SHA256(rawBody, TAP_WEBHOOK_SECRET)` (fallback: `TAP_SECRET_KEY`)
  - Supports hex or base64 digest formats.
- Failure behavior:
  - Invalid signature -> `401`.
  - Missing webhook secret configuration -> `500`.

## Operational Notes
- Webhook routes are unauthenticated by design.
- Do not rely on frontend redirect alone for subscription activation.
- Webhook handling must remain idempotent at the transaction level.
