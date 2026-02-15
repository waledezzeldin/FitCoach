# FitCoach — Flutter ↔ Node Backend Parity Report (MVP)

Date: 2026-02-02

## Purpose
This report maps **Flutter feature surfaces** (providers + repositories + screens) to **Node.js backend routes**. It highlights:

- What is already implemented in the backend.
- What is missing or placeholder.
- Where the Flutter app expects endpoints/shapes that differ from backend.

> Source of truth for backend routes: `backend/src/routes/*`
> Source of truth for Flutter network calls: `mobile/lib/data/repositories/*` and `mobile/lib/presentation/providers/*`

---

## High-level inventory

### Flutter repositories (network entrypoints)
- `AuthRepository`
- `UserRepository`
- `WorkoutRepository`
- `MessagingRepository`
- `AppointmentRepository`
- `CoachRepository`
- `AdminRepository`
- `NutritionRepository`
- `StoreRepository`
- `Order/PaymentRepository` (`payment_repository.dart`)
- `SubscriptionPlanRepository`

### Flutter providers (state orchestration)
- `AuthProvider`, `UserProvider`, `WorkoutProvider`
- `MessagingProvider`
- `AppointmentProvider`, `VideoCallProvider`
- `CoachProvider`, `AdminProvider`
- `NutritionProvider`, `StoreProvider`
- `QuotaProvider`, `SubscriptionPlanProvider`

### Backend routes (Express)
- `auth`, `users`, `intake`
- `workouts`, `exercises`
- `messages`, `notifications`
- `bookings`, `videoCalls` (mounted as `/video-calls`)
- `coaches`, `admin`
- `nutrition`, `products`, `orders`, `payments`, `ratings`, `progress`, `inbody`, `settings`

---

## Parity matrix (what’s implemented vs missing)

Legend:
- **OK**: implemented and likely usable
- **GAP**: missing/placeholder
- **MISMATCH**: exists but endpoint/path/shape differs from Flutter

### P0 — Workout generation + workout consumption
Backend status:
- **OK**: template library + generation pipeline exists.
- **OK**: Flutter-compatible endpoints now exist (`/workouts/plan`, `/workouts/exercises/...`, `/workouts/log`, `/workouts/history`).

Key Flutter expectations (from `WorkoutRepository` / `WorkoutProvider`):
- `GET /v2/workouts/plan` (active plan)
- `POST /v2/workouts/exercises/:exerciseId/complete`
- `POST /v2/workouts/exercises/substitute`
- `POST /v2/workouts/log`
- `GET /v2/workouts/history`
- Exercise library detail + favorites

Backend routes involved:
- `backend/src/routes/workouts.js`
- `backend/src/routes/exercises.js`

Result:
- **OK**: compatibility endpoints added; Flutter can use existing routes.

### P0 — Intake (Starter vs Premium gating)
Backend status:
- **OK**: 2-stage intake exists in `backend/src/routes/intake.js` using `IntakeService`.
- **OK**: Flutter compatibility routes `/v2/users/intake/first|second` map to `IntakeService`.

Result:
- **OK**: compatibility routes added; no Flutter change required.

### P1 — Video calls
Backend status:
- **OK**: Agora-based call sessions exist.

Flutter expectations (from `VideoCallProvider`):
- `POST /v2/video-calls/:appointmentId/start`
- `GET /v2/video-calls/:appointmentId/token`
- `POST /v2/video-calls/:appointmentId/end`
- `GET /v2/video-calls/:appointmentId/can-join`
- `GET /v2/video-calls/:appointmentId/status`

Backend routes involved:
- `backend/src/routes/videoCalls.js` (mounted as `/v2/video-calls`)

Result:
- **OK** (minor naming inconsistency in server “endpoints” output vs mount path; functional endpoints exist).

### P1 — Bookings (video call booking)
Backend status:
- **OK**: bookings controller/service implemented with availability, create, update, cancel.

Flutter expectations (from booking screens/providers):
- Create booking
- List bookings/appointments
- Show join window, status

Result:
- **OK**: booking flow implemented and linked to appointments.

### P1 — Appointments (user calendar)
Backend status:
- **OK**: `/v2/users/:userId/appointments` added with Flutter-friendly fields.

Result:
- **OK**: compatibility route exists.

### P1 — Messaging (coach↔user)
Backend status:
- **OK**: conversations/messages exist under `backend/src/routes/messages.js`.
- **OK**: compatibility endpoints added for `/v2/conversations/*` and `/v2/messages/send`.

Result:
- **OK**: compatibility endpoints added; socket event `message:new` emitted.

### P1 — Coach dashboard (clients, plans, calendar)
Backend status:
- **OK**: coach plan editing aligned to structured workout plan tables; user plan consumption remains consistent.

Result:
- **OK**: standardized plan storage and edit flow.

### P1 — Admin dashboard (users/coaches management)
Backend status:
- **OK**: `backend/src/routes/admin.js` covers users, coaches, analytics, audit logs, exercises CRUD.
- **OK**: assignment now updates `users.assigned_coach_id`, maintains `user_coaches`, and sends notifications.

Result:
- **OK**: assignment logic and tests added.

### P2+ — Nutrition
Backend status:
- **OK**: Flutter-compatible endpoints (`/nutrition/plan`, `/trial-status`, `/meals/:mealId/log`, `/history`) added.

Result:
- **OK**: endpoints aligned and tests added.

### P2+ — Store / Products / Orders / Payments
Backend status:
- **OK**: `/store/*` compatibility routes added; orders track/cancel align to Flutter.

Result:
- **OK**: store and order endpoints aligned; tests added.

### P2+ — Progress / InBody / Ratings / Settings
Backend status:
- **OK**: progress routes now backed by real controller and tests.

Result:
- **OK**: endpoints aligned with Flutter usage.

---

## Top mismatches to resolve early (highest integration risk)
All top mismatches have been resolved with compatibility routes and aligned responses.

---

## Recommendation (fastest path to MVP)
- Keep backend services as-is (template generation, Agora, messaging), but add **compatibility routes** matching Flutter’s current endpoints.
- Implement bookings properly and ensure bookings create appointments compatible with video calls.
- Standardize workout plan storage so both user and coach views operate on the same plan records.

