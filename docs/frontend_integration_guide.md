# Frontend Integration Guide (Flutter -> Backend)

Last updated: 2026-02-12

## Scope
Repository/provider mapping for production (non-demo) flows.

## Core Rules
- Use real APIs when `DemoConfig.isDemo == false`.
- Demo/mock data must only execute in demo mode.
- Protected endpoints must include bearer token from secure storage.

## Repository to Route Map
- `UserRepository`
  - `/users/me`, `/users/:id`, `/users/subscription`
  - `/users/:id/upload-photo`
  - `/settings/*` (notifications, profile sections, account actions)
- `AdminRepository`
  - `/admin/users/*`, `/admin/coaches*`, `/admin/analytics`, `/admin/revenue`
- `SubscriptionPlanRepository`
  - Public: `/subscriptions/plans`
  - Admin CRUD: `/admin/subscriptions/plans`
- `StoreRepository`
  - `/store/*`, `/orders/*`, `/admin/products/*`
- `PaymentRepository`
  - `/payments/create-checkout`, `/payments/upgrade`, `/payments/subscription`, `/payments/history`, `/payments/cancel`
- `MessagingRepository`
  - `/messages/*` and Socket.IO `message:new`
- `WorkoutRepository`
  - `/workouts/plan`, `/workouts/exercises/*`, `/workouts/log`, `/workouts/history`

## Provider Expectations
- `AuthProvider`: owns auth/session state and current user refresh.
- `WorkoutProvider`: only demo repository calls in demo mode.
- `MessagingProvider`: parsing must handle wrapped API payloads.
- `Subscription/Payment screens`: UI success only after backend-confirmed state.

## Validation Baseline
- Analyzer on edited files.
- Repository contract tests for route/auth/payload assumptions.
- Provider/widget tests for state transitions and error handling.
