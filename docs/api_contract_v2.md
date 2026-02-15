# FitCoach API Contract (v2)

Base URL: `/v2`
Last updated: 2026-02-12

## Auth
- `POST /auth/send-otp` → `{ phoneNumber }`
- `POST /auth/verify-otp` → `{ phoneNumber, otpCode }`
- `POST /auth/login` → `{ emailOrPhone, password }`
- `POST /auth/signup` → `{ name, email, phone, password }`
- `POST /auth/social-login`

### Auth response (Flutter-compatible)
```json
{ "token": "...", "user": { "id": "...", "name": "...", "subscriptionTier": "Premium" } }
```

## Users
- `GET /users/me`
- `PUT /users/:id`
- `PUT /users/:id` payload supports `{ fullName, fullNameAr, email, dateOfBirth, age, weight, height, gender, preferredLanguage, theme }`
- `GET /users/:id/quota`
- `GET /users/quota`
- `GET /users/:id/appointments`
- `POST /users/intake/first` → `{ gender, mainGoal, workoutLocation }`
- `POST /users/intake/second` → `{ age, weight, height, experienceLevel, workoutFrequency, injuries[] }`

## Intake
- `POST /intake/stage1`
- `POST /intake/stage2`
- `GET /intake/status`
- `GET /intake/prompt`

## Workouts
- `GET /workouts/plan` (active plan)
- `GET /workouts` (user workouts)
- `GET /workouts/:id`
- `GET /workouts/:id/progress`
- `GET /workouts/history`
- `POST /workouts/exercises/:exerciseId/complete`
- `POST /workouts/exercises/substitute`
- `POST /workouts/log`

## Exercises
- `GET /exercises`
- `GET /exercises/:id`
- `GET /exercises/muscle-group/:muscleGroup`
- `GET /exercises/favorites/list`
- `POST /exercises/favorites`
- `DELETE /exercises/favorites/:exerciseId`
- `POST /exercises/:id/alternatives` → `{ injuries: [] }`

## Messaging
- `GET /conversations`
- `GET /conversations/:id/messages`
- `DELETE /conversations/:id/messages`
- `POST /messages/send`
- `POST /messages/upload`
- `PATCH /messages/:id/read`
	- Socket event: `message:new` (payload: `{ id, conversationId, senderId, receiverId, content, type, attachmentUrl, attachmentType, isRead, createdAt, readAt }`)

Notes:
- `POST /messages/upload` returns `{ attachment: { url, type, name, size } }`.
- Attachments are allowed for Premium+ tiers; freemium users receive an upgrade-required response.

## Bookings
- `GET /bookings`
- `GET /bookings/available-slots`
- `POST /bookings`
- `PUT /bookings/:id`
- `DELETE /bookings/:id`

## Video Calls
- `POST /video-calls/:appointmentId/start`
- `GET /video-calls/:appointmentId/token`
- `POST /video-calls/:appointmentId/end`
- `GET /video-calls/:appointmentId/can-join`
- `GET /video-calls/:appointmentId/status`

Notes:
- Join window: users/coaches can join from 10 minutes before start until 15 minutes after the appointment end.

## Coaches
- `GET /coaches`
- `GET /coaches/:id`
- `GET /coaches/:id/profile`
- `GET /coaches/:id/clients`
- `GET /coaches/:id/appointments`
- `GET /coaches/:id/appointments/ics`
- `POST /coaches/:id/appointments`
- `PUT /coaches/:id/appointments/:appointmentId`

## Nutrition
- `GET /nutrition/plan`
- `GET /nutrition/trial-status`
- `POST /nutrition/meals/:mealId/log`
- `GET /nutrition/history`
- `GET /nutrition/access-status`
- `POST /nutrition/unlock-trial`
- `POST /nutrition/generate`
- `GET /coaches/:id/clients/:clientId/nutrition-plan`
- `PUT /coaches/:id/clients/:clientId/nutrition-plan`

Notes:
- `POST /nutrition/generate` uses rules-based BMR/TDEE/macros; AI extraction is not enabled by default.
- Clients should send nutrition preferences before generation (gender, age, weight, height, activity, goal).

## Store
- `GET /store/products`
- `GET /store/products/:id`
- `GET /store/products/:id/reviews`
- `POST /store/products/:id/reviews`
- `POST /store/products/:id/check-availability`
- `GET /store/categories`
- `POST /store/promo-codes/apply`
- `POST /store/shipping/calculate`

## Orders
- `POST /orders`
- `GET /orders`
- `GET /orders/:id`
- `PUT /orders/:id/cancel`
- `POST /orders/:id/cancel`
- `GET /orders/:id/track`

## Progress
- `GET /progress`
- `POST /progress`
- `PUT /progress/:id`
- `DELETE /progress/:id`

Notes:
- Progress payload supports `{ date, weight, bodyFatPercentage, chest, waist, hips, bicepsLeft, bicepsRight, thighLeft, thighRight, frontPhotoUrl, sidePhotoUrl, backPhotoUrl, notes }`.

## InBody
- `POST /inbody`
- `GET /inbody`
- `GET /inbody/latest`
- `GET /inbody/:id`
- `PUT /inbody/:id`
- `DELETE /inbody/:id`
- `POST /inbody/upload-image`
- `GET /inbody/trends`
- `GET /inbody/progress`
- `GET /inbody/statistics`
- `POST /inbody/goals`
- `GET /inbody/goals/current`

Notes:
- `POST /inbody/upload-image` is Premium+ only and returns `{ imageUrl, extractedData, confidence }`.
- If extraction fails, clients should fall back to manual entry via `POST /inbody`.
- Simulated extraction is disabled by default unless `ENABLE_SIMULATED_AI_EXTRACTION=true`.

## Payments
- `POST /payments/create-checkout`
- `POST /payments/upgrade`
- `POST /payments/cancel`
- `GET /payments/subscription`
- `GET /payments/history`
- `GET /payments/invoice/:paymentId`
- `POST /payments/webhook/stripe`
- `POST /payments/webhook/tap`

Notes:
- `GET /payments/subscription` returns `{ status, tier, isActive, daysRemaining, endsAt }` when available.
- Tap webhooks require valid HMAC signature (`tap-signature` or `x-tap-signature`) against raw request body.

## Admin
- `GET /admin/subscriptions/plans`
- `POST /admin/subscriptions/plans`
- `PUT /admin/subscriptions/plans/:id`
- `DELETE /admin/subscriptions/plans/:id`
- `POST /admin/products`
- `PUT /admin/products/:id`
- `DELETE /admin/products/:id`
- `GET /inbody/trends`
- `GET /inbody/progress`
- `GET /inbody/statistics`
- `POST /inbody/goals`
- `GET /inbody/goals/current`
- `POST /inbody/upload-image`

## Subscriptions
- `GET /subscriptions/plans`

Notes:
- Admin plan CRUD uses `/admin/subscriptions/plans`.

## Admin
- `GET /admin/users`
- `PUT /admin/users/:id`
- `GET /admin/coaches`
- `PUT /admin/coaches/:id/approve`
- `PUT /admin/coaches/:id/suspend`
- `GET /admin/subscription-plans`
- `GET /admin/subscriptions/plans`
- `POST /admin/subscriptions/plans`
- `PUT /admin/subscription-plans/:id`
- `PUT /admin/subscriptions/plans/:id`
- `DELETE /admin/subscriptions/plans/:id`

## Notifications
- `POST /notifications/register-device`
- `POST /notifications/unregister-device`
- `GET /notifications/preferences`
- `PUT /notifications/preferences`
- `GET /notifications/history`
- `POST /notifications/test`
