# Backend Parity + Modularization Audit

This audit lists current backend routes and services, and flags doc gaps.
Sources: `backend/src/routes`, `backend/src/services`, `backend/docs/README.md`.

## Route Modules and Endpoints (Current Code)
### auth.js
- POST `/auth/send-otp`
- POST `/auth/verify-otp`
- POST `/auth/resend-otp`
- POST `/auth/login`
- POST `/auth/register`
- POST `/auth/refresh-token`
- POST `/auth/logout`
- GET `/auth/me`

### users.js
- GET `/users/:id`
- PUT `/users/:id`
- GET `/users/me`
- GET `/users/quota`
- POST `/users/first-intake`
- POST `/users/second-intake`
- POST `/users/intake/first`
- POST `/users/intake/second`
- GET `/users/:id/quota`
- POST `/users/start-trial`
- POST `/users/:id/upload-photo`
- GET `/users/:id/appointments`

### intake.js
- POST `/intake/stage1`
- POST `/intake/stage2`
- GET `/intake/status`
- GET `/intake/prompt`

### workouts.js
- GET `/workouts/templates`
- GET `/workouts/templates/:id`
- POST `/workouts/generate-from-template`
- GET `/workouts/recommend-template/:userId?`
- GET `/workouts/plan`
- POST `/workouts/exercises/:exerciseId/complete`
- POST `/workouts/exercises/substitute`
- POST `/workouts/log`
- GET `/workouts/history`
- GET `/workouts`
- GET `/workouts/:id`
- POST `/workouts/:id/exercises/:exerciseId/complete`
- GET `/workouts/:id/progress`
- POST `/workouts/:id/substitute-exercise`
- POST `/workouts` (coach/admin)
- PUT `/workouts/:id` (coach/admin)
- DELETE `/workouts/:id` (coach/admin)
- POST `/workouts/:id/clone` (coach/admin)
- PUT `/workouts/:id/exercises/:exerciseId` (coach/admin)
- POST `/workouts/:id/days/:dayId/note` (coach/admin)
- GET `/workouts/customization-history/:userId` (coach/admin)

### nutrition.js
- GET `/nutrition/access-status`
- GET `/nutrition/trial-status`
- POST `/nutrition/unlock-trial`
- POST `/nutrition/generate`
- GET `/nutrition/plan`
- POST `/nutrition/meals/:mealId/log`
- GET `/nutrition/history`
- GET `/nutrition`
- GET `/nutrition/:id`
- POST `/nutrition/:id/meals/:mealId/complete`
- POST `/nutrition` (coach/admin)
- PUT `/nutrition/:id` (coach/admin)
- DELETE `/nutrition/:id` (coach/admin)

### messages.js
- GET `/messages/conversations`
- GET `/messages/conversations/:id`
- POST `/messages`
- POST `/messages/send`
- PUT `/messages/:id/read`
- PATCH `/messages/:id/read`
- DELETE `/messages/:id`
- POST `/messages/upload`
- GET `/messages/unread/count`
- GET `/messages/search`

### conversations (compat)
- GET `/conversations`
- GET `/conversations/:id/messages`

### coaches.js
- GET `/coaches/:id/profile`
- GET `/coaches`
- GET `/coaches/:id`
- GET `/coaches/:id/clients` (coach/admin)
- GET `/coaches/:id/appointments` (coach/admin)
- GET `/coaches/:id/appointments/ics`
- POST `/coaches/:id/appointments` (coach/admin)
- PUT `/coaches/:id/appointments/:appointmentId` (coach/admin)
- GET `/coaches/:id/earnings` (coach/admin)
- PUT `/coaches/:id/clients/:clientId/fitness-score` (coach)
- GET `/coaches/:id/analytics` (coach/admin)
- GET `/coaches/:id/clients/:clientId/report` (coach/admin)
- GET `/coaches/:id/clients/:clientId/workout-plan` (coach/admin)
- PUT `/coaches/:id/clients/:clientId/workout-plan` (coach/admin)
- GET `/coaches/:id/clients/:clientId/nutrition-plan` (coach/admin)
- PUT `/coaches/:id/clients/:clientId/nutrition-plan` (coach/admin)
- GET `/coaches/:id/plans` (coach/admin)
- POST `/coaches/:id/plans` (coach/admin)
- PUT `/coaches/:id/plans/:planId` (coach/admin)
- DELETE `/coaches/:id/plans/:planId` (coach/admin)

### admin.js
- GET `/admin/audit-logs`
- GET `/admin/exercises`
- POST `/admin/exercises`
- PUT `/admin/exercises/:id`
- DELETE `/admin/exercises/:id`
- GET `/admin/subscription-plans`
- GET `/admin/subscriptions/plans`
- POST `/admin/subscriptions/plans`
- PUT `/admin/subscription-plans/:id`
- PUT `/admin/subscriptions/plans/:id`
- DELETE `/admin/subscriptions/plans/:id`
- GET `/admin/settings`
- PUT `/admin/settings`

### bookings.js
- GET `/bookings`
- GET `/bookings/available-slots`
- POST `/bookings`
- PUT `/bookings/:id`
- DELETE `/bookings/:id`

### videoCalls.js
- POST `/video-calls/:appointmentId/start`
- GET `/video-calls/:appointmentId/token`
- POST `/video-calls/:appointmentId/end`
- GET `/video-calls/:appointmentId/can-join`
- GET `/video-calls/:appointmentId/status`

### notifications.js
- POST `/notifications/register-device`
- POST `/notifications/unregister-device`
- GET `/notifications/preferences`
- PUT `/notifications/preferences`
- GET `/notifications/history`
- PUT `/notifications/:notificationId/clicked`
- POST `/notifications/test`

### settings.js
- GET `/settings/notifications`
- PUT `/settings/notifications`
- GET `/settings/coach-profile`
- PUT `/settings/coach-profile`
- GET `/settings/admin-profile`
- POST `/settings/change-password`
- DELETE `/settings/delete-account`

### inbody.js
- POST `/inbody`
- GET `/inbody`
- GET `/inbody/latest`
- GET `/inbody/trends`
- GET `/inbody/progress`
- GET `/inbody/statistics`
- GET `/inbody/:id`
- PUT `/inbody/:id`
- DELETE `/inbody/:id`
- POST `/inbody/goals`
- GET `/inbody/goals/current`
- POST `/inbody/upload-image`

### exercises.js
- GET `/exercises`
- GET `/exercises/muscle-group/:muscleGroup`
- GET `/exercises/stats` (admin)
- GET `/exercises/:id`
- GET `/exercises/favorites/list`
- POST `/exercises/favorites`
- DELETE `/exercises/favorites/:exerciseId`

### progress.js
- GET `/progress`
- POST `/progress`
- PUT `/progress/:id`
- DELETE `/progress/:id`

### products.js
- GET `/products`
- GET `/products/categories`
- GET `/products/featured`
- GET `/products/:id`
- POST `/products` (admin)
- PUT `/products/:id` (admin)
- DELETE `/products/:id` (admin)
- POST `/products/:id/reviews`
- PUT `/products/:id/stock` (admin)

### orders.js
- GET `/orders`
- GET `/orders/stats` (admin)
- GET `/orders/all` (admin)
- GET `/orders/:id`
- POST `/orders`
- PUT `/orders/:id/status` (admin)
- POST `/orders/:id/cancel`
- PUT `/orders/:id/cancel`
- GET `/orders/:id/track`

### store.js
- GET `/store/products`
- GET `/store/products/:id`
- GET `/store/products/:id/reviews`
- POST `/store/products/:id/reviews`
- POST `/store/products/:id/check-availability`
- GET `/store/categories`
- POST `/store/promo-codes/apply`
- POST `/store/shipping/calculate`

### subscriptions.js
- GET `/subscriptions/plans`

### payments.js
- POST `/payments/create-checkout`
- POST `/payments/upgrade`
- POST `/payments/cancel`
- GET `/payments/subscription`
- GET `/payments/history`
- GET `/payments/invoice/:paymentId`
- POST `/payments/webhook/stripe`
- POST `/payments/webhook/tap`

### ratings.js
- POST `/ratings`
- GET `/ratings/coach/:id`
- GET `/ratings/user/:id`

## Service Modules (Current)
- aiExtractionService, coachCustomizationService, emailService
- injuryMappingService, intakeService
- nutritionAccessService, nutritionGenerationService
- paymentService, pushNotificationService, quotaService
- s3Service, twilioService
- videoCallService
- workoutGenerationService, workoutRecommendationService, workoutTemplateService

## Doc Gaps Found
- Backend docs reference API docs that are missing on disk:
  - `backend/docs/API_OVERVIEW.md` (missing)
  - `backend/docs/AUTH_API.md`, `USER_API.md`, `WORKOUT_API.md`, `NUTRITION_API.md`,
    `COACH_API.md`, `ADMIN_API.md`, `STORE_API.md` (missing)
- API contract is now tracked in [docs/api_contract_v2.md](api_contract_v2.md).

## Modularization Notes (Next Actions)
- Validate controller -> service separation and move any business logic out of controllers.
- Standardize response schema and error payloads across routes.
- Add request validation for all endpoints (shared validators).

## Progress Log
- [x] 2026-02-02: Route inventory updated for compatibility endpoints and store/subscriptions.
