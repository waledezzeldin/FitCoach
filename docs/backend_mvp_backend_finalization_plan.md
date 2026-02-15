# FitCoach — Backend Finalization Plan (Flutter MVP)

Date: 2026-02-02

## Goal
Finalize the Node.js backend so the Flutter mobile app has a complete MVP with:

1) **Workout generation (highest priority)** driven by the JSON templates in `mobile/assets/data/new/`:
- **Starter**: generic plan for users who answered only the first 3 intake questions.
- **Premium**: customized plan for users who completed the second intake stage.
- **Injury swap**: automatically substitute exercises for users with injuries.

2) **Coach flow (second priority)** fully working end-to-end:
- Booking video calls, joining calls, and quota enforcement.
- Coach can message assigned users.
- Coach can view/edit generated workout plans for assigned users.
- Coach calendar reflects booked calls.
- Admin can manage users/coaches and assign a coach to users.

3) Generate an **exercise catalog JSON** (from templates) that contains all exercises used in plans, with the fields required by the Flutter exercise detail screens.

4) After priorities are done: finish remaining MVP features (nutrition, store, dashboards, admin) + full wiring + testing.

---

## How to use this plan (progress tracking)
- Each checklist item uses `[ ]` / `[x]`.
- Add status labels: **NS** (not started), **IP** (in progress), **DONE**.
- Add an owner: **BE** (backend), **FE** (Flutter), **DATA** (data/content), **QA**.

Example:
- [ ] **IP / BE** Implement `GET /v2/workouts/plan` (Flutter-compatible shape)

---

## Repo reality check (what exists today)

### Flutter (mobile) feature surfaces (high-level)
Flutter screens in `mobile/lib/presentation/screens/` include:
- **Intake**: first + second intake.
- **Workout**: plan view, session, timer, exercise details, substitutions.
- **Messaging**: user↔coach chat.
- **Booking**: book video session.
- **Video call**: join/start/end call.
- **Coach**: dashboard, clients, plan editor/builder, calendar, earnings, messages.
- **Admin**: dashboard, users, coaches, revenue, audit logs.
- **Nutrition**: plan view + preferences.
- **Store**: products, checkout, orders.
- **Progress/InBody/Ratings/Settings**: tracked.

Flutter repositories expect specific endpoints (examples):
- Workout: `GET /v2/workouts/plan`, `POST /v2/workouts/exercises/:id/complete`, `POST /v2/workouts/exercises/substitute`, `POST /v2/workouts/log`, `GET /v2/workouts/history`
- Intake: `POST /v2/users/intake/first`, `POST /v2/users/intake/second`
- Messaging: `GET /v2/conversations`, `GET /v2/conversations/:id/messages`, `POST /v2/messages/send`, `PATCH /v2/messages/:id/read`
- Appointments: `GET /v2/users/:userId/appointments`
- Video calls: `POST /v2/video-calls/:appointmentId/start`, `GET /v2/video-calls/:appointmentId/token`, `POST /v2/video-calls/:appointmentId/end`

### Backend (Node.js) capability snapshot
Backend routes exist for most domains (workouts, exercises, messages, coaches, admin, video-calls, nutrition, store, payments, quotas). However:

- **Workout templates** already exist in `backend/src/data/workout-templates/{starter,advanced}/` and match the intent of `mobile/assets/data/new/`.
- **IntakeService** already supports 2-stage intake + auto starter plan generation (but the Flutter endpoint names/payloads currently differ).
- **Video call** is implemented using **Agora** (`backend/src/services/videoCallService.js`).
- **Bookings** route is currently **placeholder** in `backend/src/routes/bookings.js` (major gap).
- There are **API contract mismatches** (Flutter expects endpoints/JSON shapes that don’t match current backend routes).
- There appear to be **schema/model mismatches** across workout tables (e.g., different table names used in controllers/services). This must be resolved early.

---

## Priority Phases

### Phase 0 — Contract + Data Model Stabilization (do this first)
Objective: remove ambiguity by locking (A) DB schema for workouts/appointments/messaging and (B) API contract used by Flutter.

- [x] **DONE / BE** Confirm canonical DB schema for workouts (tables + columns) and fix any mismatches between:
  - `backend/src/services/workoutGenerationService.js` inserts
  - `backend/src/controllers/workoutController.js` reads/updates
  - Views referenced (e.g., `active_workout_plans_with_progress`)
- [x] **DONE / BE** Decide “single source of truth” for workout plans:
  - Option A (recommended): structured tables (`workout_plans`, `workout_weeks`, `workout_days`, `workout_day_exercises`, …)
  - Option B: JSON blob tables (`user_workout_plans.plan_data`) + thin API
  - **Do not keep both** for MVP—pick one and map the other to it.
- [x] **DONE / BE** Publish an API contract doc for Flutter MVP (OpenAPI or Markdown):
  - Endpoints + payload/response shapes
  - Error codes (quota exceeded, upgrade required, etc.)
- [x] **DONE / BE** Implement temporary compatibility routes if needed (to avoid changing Flutter while backend is finalized).
- [x] **DONE / BE** Update backend documentation for Phase 0 changes (API contract + schema alignment).

Acceptance criteria:
- A single, consistent workout plan persistence model.
- Flutter-required endpoints exist (even if internally forwarded).

---

### Phase 1 — Workout Generation MVP (highest priority)
Objective: a user can complete first intake and immediately receive a **Starter** plan; premium users completing second intake receive **Premium** plan; injuries trigger substitutions.

#### 1.1 Template source-of-truth & prioritization
- [x] **DONE / DATA+BE** Treat `mobile/assets/data/new/` as the canonical “product templates” folder.
  - Either:
    - (A) copy/sync them into `backend/src/data/workout-templates/` at build time, or
    - (B) load them directly from a shared top-level folder.
- [x] **DONE / BE** Ensure template IDs align:
  - Starter: `starter_*_3d_v1.json`
  - Premium: `premium_{2..6}d_v1.json`
  - Injury swaps: `injury_swap_table.json`

#### 1.2 Intake → plan generation wiring (Starter)
Flutter first intake payload today: `{ gender, mainGoal, workoutLocation }`.

Backend should:
- persist intake stage 1
- generate starter plan using:
  - goal = `mainGoal` (mapped to `fat_loss | muscle_gain | general_fitness`)
  - location = `workoutLocation` (`home | gym`)
  - days/week fixed to **3** (starter)

Tasks:
- [x] **DONE / BE** Add `POST /v2/users/intake/first` (Flutter contract) to call `intakeService.submitStage1()` after mapping fields.
- [x] **DONE / BE** Ensure the created starter plan is queryable via `GET /v2/workouts/plan`.
- [x] **DONE / BE** Add a “plan type” marker in stored plan metadata (starter/premium) for UI labels.

#### 1.3 Intake → plan generation wiring (Premium)
Flutter second intake payload today: `{ age, weight, height, experienceLevel, workoutFrequency, injuries[] }`.

Backend should:
- enforce subscription tier (Premium/Smart Premium)
- persist stage 2
- generate premium plan with:
  - template: `premium_${workoutFrequency}d_v1`
  - experience: apply `experience_adjustments`
  - injuries: apply `injury_swaps` (also record substitution reason + original exercise)

Tasks:
- [x] **DONE / BE** Add `POST /v2/users/intake/second` (Flutter contract) to call `intakeService.submitStage2()` and then generate the premium plan.
- [x] **DONE / BE** Return a response shape Flutter can use to refresh the dashboard (profile + new plan id).

#### 1.4 Injury swap behavior (Starter + Premium)
- [x] **DONE / BE** Ensure injury swap mapping is applied consistently:
  - Auto-swaps at generation time (preferred)
  - Optional user-initiated swaps inside a plan session
- [x] **DONE / BE** Implement “alternatives” endpoint expected by Flutter:
  - `POST /v2/exercises/:exerciseId/alternatives` with `{ injuries: [...] }`

#### 1.5 Workout plan consumption endpoints required by Flutter
Flutter expects simplified “active plan” endpoints.

- [x] **DONE / BE** Implement `GET /v2/workouts/plan` (active plan for current user)
- [x] **DONE / BE** Implement `POST /v2/workouts/exercises/:exerciseId/complete`
- [x] **DONE / BE** Implement `POST /v2/workouts/exercises/substitute`
- [x] **DONE / BE** Implement `POST /v2/workouts/log`
- [x] **DONE / BE** Implement `GET /v2/workouts/history`

(These can forward to existing `/v2/workouts/*` endpoints if you keep the structured model.)

#### 1.6 Testing for Phase 1
- [x] **DONE / QA+BE** Unit tests:
  - template selection (starter vs premium)
  - mapping of goal/location
  - injury swaps applied + reasons recorded
- [x] **DONE / QA+BE** Integration tests:
  - `POST /users/intake/first` → plan exists
  - `POST /users/intake/second` (premium) → premium plan exists
  - `GET /workouts/plan` returns Flutter-compatible response
- [x] **DONE / BE** Update backend documentation for Phase 1 changes (intake + workouts + injury swaps).

Acceptance criteria:
- New user completes first intake → sees Starter plan.
- Premium user completes second intake → sees Premium plan.
- Injury selections swap exercises (both auto and optional manual swap).

---

### Phase 2 — Coach Flow + Video Calls + Admin impacts (second priority)
Objective: the entire coaching loop works: assigned users ↔ coach messaging, booking, joining calls, coach edits plans.

#### 2.1 Booking system (replace placeholder)
`backend/src/routes/bookings.js` currently returns empty placeholders.

Backend must support:
- user requests booking with assigned coach
- available slot calculation
- conflict prevention
- appointment lifecycle statuses
- quota enforcement (call limits)

Tasks:
- [x] **DONE / BE** Implement bookings controller/service backed by DB tables:
  - `GET /v2/bookings` (my bookings)
  - `GET /v2/bookings/available-slots` (per coach + date range)
  - `POST /v2/bookings` (create booking)
  - `PUT /v2/bookings/:id` (reschedule/update notes)
  - `DELETE /v2/bookings/:id` (cancel)
- [x] **DONE / BE** Ensure bookings create `appointments` rows compatible with Agora call flows.
- [x] **DONE / BE** Add notifications on booking create/update/cancel (user + coach).

#### 2.2 Coach calendar (in-app) + optional external calendar
- [x] **DONE / BE** Ensure coach appointments endpoint is complete:
  - `GET /v2/coaches/:id/appointments`
  - filtering by date range/status
- [x] **DONE / FE+BE** Confirm Flutter coach calendar expects which fields (timezone, display names, duration).
- [x] **DONE / BE** Optional: provide `.ics` export endpoint for coach (low-friction calendar “reflection”).

#### 2.3 Video call flow (user + coach)
Backend already has:
- `POST /v2/video-calls/:appointmentId/start`
- `GET /v2/video-calls/:appointmentId/token`
- `POST /v2/video-calls/:appointmentId/end`

Tasks:
- [x] **DONE / BE** Ensure `canJoin` logic matches Flutter UI join window (10 min before, +15 min after).
- [x] **DONE / BE** Ensure call quota increments exactly once per completed call.
- [x] **DONE / QA+BE** Add tests for:
  - unauthorized join attempts
  - join window boundaries
  - status transitions (confirmed → in_progress → completed)

#### 2.4 Coach can view/edit generated workout plans
Flutter coach screens include plan builder/editor.

Tasks:
- [x] **DONE / BE** Choose and implement **one** coach-edit approach:
  - **Approach A (recommended):** coach edits the structured plan (swap exercises, adjust sets/reps/rest, add notes)
    - store change history (`coach_customization_history` already exists in routes)
  - Approach B: coach replaces plan with a JSON blob (fast, but harder to query/progress-track)
- [x] **DONE / BE** Ensure coach permissions are tied to assignments (`user_coaches` + `users.assigned_coach_id`).
- [x] **DONE / BE** Ensure user sees coach edits immediately via `GET /workouts/plan`.

#### 2.5 Messaging (user↔coach) + socket wiring
Backend exposes messaging under `/v2/messages/*`, while Flutter repositories currently call `/v2/conversations` and `/v2/messages/send`.

Tasks:
- [x] **DONE / BE** Add compatibility endpoints (or update Flutter):
  - `GET /v2/conversations` → forward to `GET /v2/messages/conversations`
  - `GET /v2/conversations/:id/messages` → forward to `GET /v2/messages/conversations/:id`
  - `POST /v2/messages/send` → forward to `POST /v2/messages`
  - `PATCH /v2/messages/:id/read` → forward to `PUT /v2/messages/:id/read`
- [x] **DONE / BE** Validate Socket.IO event names expected by Flutter (`message:new`).
- [x] **DONE / QA+BE** Add integration tests for messaging (send/read/unread counts + quota).

#### 2.6 Admin: manage users/coaches and assign coach
Admin endpoints exist:
- `GET /v2/admin/users`, `PUT /v2/admin/users/:id`, `GET /v2/admin/coaches`, etc.

Tasks:
- [x] **DONE / BE** Confirm `PUT /v2/admin/users/:id` supports assigning coach reliably:
  - update `users.assigned_coach_id`
  - maintain `user_coaches` history (active assignment)
  - notify coach + user
- [x] **DONE / QA+BE** Add tests: assign coach, reassign coach, unassign coach.
- [x] **DONE / BE** Update backend documentation for Phase 2 changes (bookings, messaging, video calls, admin).

Acceptance criteria:
- User books a call → coach sees it → both can join video call.
- Coach can message user and user can reply.
- Coach can edit plan for assigned user and user sees the changes.
- Admin can assign coach to user.

---

### Phase 3 — Exercise catalog JSON generation (from templates)
Objective: produce a single JSON containing all `ex_id`s used across starter+premium templates and the required exercise detail fields.

Output (recommended):
- `mobile/assets/data/exercises_catalog_v1.json`

Fields required (minimum):
- `ex_id`, `name_en`, `name_ar`
- `equip[]`, `muscles[]`
- `video_url` or `video_id` mapping
- `thumbnail_url`
- `instructions_en/ar`, `common_mistakes_en/ar` (can start as placeholders)
- recommended defaults: sets/reps/rest

Tasks:
- [x] **DONE / DATA+BE** Create a generator script (Node or Python) that:
  1) reads all `mobile/assets/data/new/*.json`
  2) collects all `ex_id`s in sessions
  3) merges with any embedded `exercises[]` blocks inside premium templates
  4) outputs a deduped catalog JSON
- [x] **DONE / DATA** Generate `mobile/assets/data/exercises_catalog_v1.json`
- [x] **DONE / DATA** Fill missing instruction fields (content pass) and link media.
- [x] **DONE / BE** Seed backend `exercises` table from this catalog (idempotent upsert).

Testing:
- [x] **DONE / QA+BE** Add a test that validates all templates reference exercises present in the catalog.
- [x] **DONE / BE** Update backend documentation for Phase 3 changes (catalog generation + seeding).

---

### Phase 4 — Remaining MVP features (after priorities)
Objective: complete “everything else” to reach a coherent MVP.

#### 4.1 Nutrition
Backend has nutrition routes/services; Flutter has nutrition screens/providers.

- [x] **DONE / BE** Align nutrition endpoints to Flutter repository expectations (plan, logs, preferences intake).
- [x] **DONE / QA+BE** Add tests for nutrition plan fetch + meal logging + trial logic.

#### 4.2 Store + orders + payments
Backend has products/orders/payments routes; Flutter has store provider.

- [x] **DONE / BE** Ensure endpoints exist for:
  - product list + categories
  - availability checks
  - order create/list/detail
  - promo codes + shipping calculation
  - payment intent/session (if used)
- [x] **DONE / QA+BE** Add integration tests for order flow.

#### 4.3 Progress + InBody + Ratings
- [x] **DONE / BE** Validate endpoints expected by Flutter providers and fill gaps.
- [x] **DONE / QA+BE** Add tests for CRUD + authorization.

#### 4.4 Admin completeness
- [x] **DONE / BE** Ensure admin screens can operate fully using backend endpoints (filters, pagination, audit logs, etc.).
- [x] **DONE / BE** Update backend documentation for Phase 4 changes (nutrition, store, progress, admin).

---

## Risk list (things to address explicitly)
- **API mismatch risk:** Flutter is currently calling endpoint names that don’t exist in backend; solve via compatibility routes or update Flutter.
- **Workout schema mismatch risk:** controllers and services appear to use different workout table names; resolve before building features.
- **Booking gap:** bookings route is placeholder; without it coach flow cannot be completed.
- **Data consistency:** templates exist in two places (mobile assets and backend data); define a single source-of-truth.

---

## Suggested execution order (what I would do first)
1) Phase 0 contract + schema alignment
2) Phase 1 starter plan generation via first intake + `GET /workouts/plan`
3) Phase 1 premium generation via second intake + injury swaps
4) Phase 2 bookings + appointments + video calls
5) Phase 2 messaging compatibility + socket verification
6) Phase 2 coach edits plan + admin assignment hardening
7) Phase 3 exercise catalog generator + seed
8) Phase 4 remaining features + testing

---

## Phase 5 — Full-Stack Parity Closure (remaining gaps + completeness)
Objective: close all remaining backend/frontend/database/API linkage gaps, verify admin/coach/user profile flows, store coverage, messaging/video integration, documentation, and testing completeness.

### 5.1 Profiles: user, coach, admin (data + UI + API)
- [x] **DONE / FE+BE** User profile: confirm all profile fields used in Flutter are persisted and editable (phone, email, name, gender, DOB, goals, preferences, photos).
- [x] **DONE / BE+DATA** Ensure DB schema includes all profile fields used by mobile + admin (audit `users`, `coaches`, `admin` views).
- [x] **DONE / FE+BE** Coach profile: confirm coach-specific fields (bio, specialties, certifications, availability, earnings) are editable and displayed.
- [x] **DONE / FE+BE** Admin profile/permissions: confirm role checks and admin profile fields used by admin screens are supported.
- [x] **DONE / QA+BE** Add tests for profile CRUD + role-based access controls.
- [x] **DONE / BE** Update backend documentation for profile fields + endpoints.

### 5.2 InBody (AI + manual) parity + DB schema
- [x] **DONE / FE+BE** Wire Flutter InBody AI scan to backend `/inbody/upload-image` and use returned extracted data.
- [x] **DONE / FE+BE** Ensure manual input uses backend save (`POST /inbody`) consistently and refreshes history.
- [x] **DONE / BE+DATA** Add missing `inbody_scans` schema definition to DB docs (if not already in schema file).
- [ ] **NS / QA+BE** Add integration tests for AI upload + manual save + stats/trends endpoints.
- [x] **DONE / QA+BE** Add integration tests for AI upload + manual save + stats/trends endpoints.
- [x] **DONE / BE** Document AI extraction behavior and fallbacks.

### 5.3 Progress tracking parity
- [x] **DONE / FE+BE** Replace mocked progress UI data with real API calls (`GET/POST/PUT/DELETE /progress`).
- [x] **DONE / BE+DATA** Verify `progress_entries` table matches UI fields (photos, measurements, notes).
- [x] **DONE / QA+BE** Add integration tests for progress CRUD + authorization.
- [x] **DONE / BE** Update docs for progress endpoints and payloads.

### 5.4 Nutrition generation (AI + rules), access, and coach plans
- [x] **DONE / BE** Document that nutrition generation is rules-based (BMR/TDEE/macros) unless AI is added; clarify in API docs.
- [x] **DONE / FE+BE** Confirm Flutter nutrition preferences intake posts to backend and triggers plan generation (if required).
- [x] **DONE / FE+BE** Coach nutrition plan builder/editor screens: confirm save/update endpoints and data shape.
- [x] **DONE / QA+BE** Add tests for nutrition plan generation, access gating, meal logging, and coach plan edits.
- [x] **DONE / BE** Update docs for nutrition preferences intake + coach nutrition endpoints.

### 5.5 Subscriptions (user + admin) end-to-end
- [x] **DONE / FE+BE** Verify user subscription upgrade/checkout flow matches backend payments endpoints (Stripe/Tap).
- [x] **DONE / FE+BE** Confirm admin subscription plan CRUD screens map to `/admin/subscriptions/plans`.
- [x] **DONE / BE+DATA** Confirm `subscription_plans` schema includes metadata needed by Flutter (quotas, features, availability).
- [x] **DONE / QA+BE** Add tests for plan list + create/update/delete + subscription status.
- [x] **DONE / BE** Update API contract for subscription flows and billing endpoints.

### 5.6 Store (user + admin) parity audit
- [x] **DONE / FE+BE** Verify Flutter store screens connect to products + orders APIs (list, detail, add to cart, checkout).
- [x] **DONE / FE+BE** Verify admin store management screens map to product/category CRUD and inventory controls.
- [x] **DONE / BE+DATA** Confirm DB schema for products, categories, orders, payments matches UI fields.
- [x] **DONE / QA+BE** Add integration tests for store list/detail, order create/cancel, admin product CRUD.
- [x] **DONE / BE** Update docs for store APIs (user + admin).

### 5.7 Messaging + video integration (user/coach/admin)
- [x] **DONE / FE+BE** Confirm Flutter chat uses Socket.IO event `message:new` and REST compatibility endpoints.
- [x] **DONE / BE** Add conversation message clear endpoint for Flutter.
- [x] **DONE / FE+BE** Confirm attachments gating aligns with subscription quotas.
- [x] **DONE / FE+BE** Verify video call flow from booking → start → token → end matches Flutter screens.
- [x] **DONE / QA+BE** Add tests for messaging (send/read/attachments/quota) and video call windows.
- [x] **DONE / BE** Update docs for messaging + video call APIs and event payloads.

### 5.8 Documentation + API linkage audit
- [x] **DONE / BE** Produce a single consolidated API contract covering all v2 endpoints (user/coach/admin) and compatibility routes.
- [x] **DONE / BE** Add a full “frontend ↔ backend ↔ DB” mapping table per feature (profiles, workouts, nutrition, store, progress, InBody, messaging, calls, subscriptions).
- [x] **DONE / QA** Verify test coverage aligns with the mapping table; document gaps.

### 5.9 Testing completeness
- [x] **DONE / QA+BE** End-to-end smoke suite for critical flows: intake→plan, booking→call, nutrition access→log, InBody AI→save, progress CRUD, store order, subscription upgrade.
- [x] **DONE / QA+BE** Regression suite for compatibility endpoints and admin CRUD.

Acceptance criteria:
- All UI screens call real endpoints (no mocked data for core features).
- Every feature has DB schema alignment, API contract coverage, docs, and tests.
- Admin, coach, and user experiences are fully operational end-to-end.
