# UI/UX Alignment Plan

_Last updated: 30 Nov 2025_

## Objective
Bring the production Flutter mobile app (`mobile/lib`) and Express/Nest backend (`backend/src`) to feature-parity with the reference UI build in `UI_UX/src`. This document captures the deltas that were found during the comparative review and lays out the implementation order needed to synchronize experience, data contracts, and business rules.

## Reference Baselines (Deep-Dive Inputs)
- **React UI implementation** (`UI_UX/`): authoritative source for flows, copy, gradients, and interaction contracts. Key files include `App.tsx` (navigation shell), `components/HomeScreen.tsx`, `WorkoutScreen.tsx`, `ExerciseDetailScreen.tsx`, `CoachScreen.tsx`, `StoreScreen.tsx`, `AccountScreen.tsx`, and the supporting guides (e.g., `HOME_QUICK_ACCESS_GUIDE.md`, `COACH_PROFILE_SCREEN_IMPLEMENTATION.md`). These describe exactly how quota banners, quick-access tiles, tutorials, and booking widgets behave.
- **Software Requirements Document** (`SRS/SOFTWARE_REQUIREMENTS.md`): captures stakeholder expectations, especially sections 4–6 (Regular User, Coach, Admin experiences) and 11 (future considerations). Every migration item below cites the relevant SRD section(s) plus the React component(s) that already satisfy the requirement.
- **Current Production**: Flutter app under `mobile/` and Nest backend under `backend/`. Any plan item explicitly calls out the Flutter/BFF changes needed to match the React+SRD contract.

## Gap Summary

-### 1. Authentication & Access Control
- **Reference**: `UI_UX/src/components/AuthScreen.tsx` + SRD §3.1/§4.1 detail the phone-first OTP flow, demo gestures, and bilingual copy implemented within the React shell (`App.tsx`).
- **Flutter**: `mobile/lib/screens/auth/login_screen.dart` still centers on email/password with optional phone screen (`phone_login_screen.dart`), no language gate, no intro, and demo mode is hidden behind `Env.demo` rather than runtime gesture.
- **Backend**: `backend/src/auth.controller.ts` supports Firebase phone tokens, but `users.controller.ts` login/register endpoints remain email/password centric and do not store verified phone metadata or role inference rules.

### 2. Onboarding & Intake
- **Reference**: Two-stage intake (`FirstIntakeScreen`, `SecondIntakeScreen`) with ability to skip second stage, return later, and persist partial data (`App.tsx` state fields `firstIntakeData`, `previousScreen`).
- **Flutter**: `mobile/lib/screens/intake/intake_flow.dart` is a single nine-step wizard that blocks home access until completion and lacks the deferred second stage + reminders described in React.
- **Backend**: `backend/src/intake.controller.ts` only stores a single payload; no API to update partial intakes or resume second-stage capture.

### 3. Localization & Intro Experience
- **Reference**: App boot sequence enforces language selection (`LanguageSelectionScreen.tsx`) and intro slides (`AppIntroScreen.tsx`) before auth; RTL styles propagate everywhere via `LanguageContext`.
- **Flutter**: No localization scaffolding or intro flow in `app.dart`/`main.dart`; text copies are hard-coded English.
- **Backend**: No locale awareness in responses or content.

-### 4. Subscription Tiers & Quotas
- **Reference**: `UI_UX/src/components/SubscriptionManager.tsx`, `CoachScreen.tsx`, `NutritionScreen.tsx`, and SRD §3.3/§4.5 describe quota banners, lock messaging, and benefits matrices.
- **Flutter**: `AppState.subscriptionType` toggles `freemium` only for nutrition plan lock but does not enforce per-feature quotas, message caps, or upgrade prompts in `screens/coach`, `screens/chat`, or `NutritionPlanScreen`.
- **Backend**: `prisma.Subscription` has no fields for quotas; no middleware to enforce usage counts or expire nutrition access after seven days.

-### 5. Nutrition Module
- **Reference**: React `NutritionScreen.tsx`, `NutritionPreferencesIntake.tsx`, `FREEMIUM_NUTRITION_UPGRADE_FIX.md`, plus SRD §4.4.
- **Flutter**: `NutritionPlanScreen` simply fetches today’s plan; `isFreemium` flag never hides data nor prompts upgrades. No preference intake or expiry timers.
- **Backend**: `NutritionLog`/`NutritionService` endpoints don’t expose plan expiry, preference schemas, or gating logic expected by UI.

-### 6. Store, Cart, and Orders
- **Reference**: React `StoreScreen.tsx`, `components/store/*`, and SRD §4.6.
- **Flutter**: `supplements_store_screen.dart` and `categories_screen.dart` are static lists without search, filter, detail, promo pricing, intro, bundles, or order confirmation screens. `CartScreen` lacks coupons, shipping, and discount rows; `OrderDetailsScreen` has only invoice/close actions.
- **Backend**: `products.controller.ts` exposes only CRUD; `orders.controller.ts` has create/cancel/return but no GET endpoints for listing, tracking, or discount integration. Schema lacks per-item discount/original price, shipping statuses, tracking numbers, or bundle relations used in React store.

-### 7. Coach & Admin Surfaces
- **Reference**: React `CoachScreen.tsx`, `CoachDashboard.tsx`, `COACH_PROFILE_SCREEN_IMPLEMENTATION.md`, and SRD §4.5/§5.
- **Flutter**: Coach flows exist but are list/schedule centric (`coach_list_screen.dart`) and detached from the unified home navigation; no public coach profile view, no inline quota chips, and coach/admin dashboards differ visually from React.
- **Backend**: Coach endpoints (`coaches.controller.ts`) don’t publish the richer profile metadata (badges, rating, specialties) rendered in UI_UX, nor do admin endpoints aggregate metrics for the dashboard cards.

### 8. Demo Mode & Debug Tooling
- **Reference**: React app toggles demo via logo long-press, persists `localStorage` keys per phone, and shows `DemoModeIndicator` & `DemoUserSwitcher`.
- **Flutter**: Demo mode is compile-time (`Env.demo`). There is no runtime toggle or user switcher in `home_screen.dart`.
- **Backend**: No dedicated demo fixtures or safeguards; seeds required.

### 9. Home, Workouts & Coach (User-Facing)
- **Reference**: Per the SRS (§7–11) the Home tab is the command center showing calories burned/consumed, adherence %, quick access to Workouts, Coach, Nutrition, Store, and Account, plus quotas and CTA tiles (see `UI_UX/src/HOME_QUICK_ACCESS_GUIDE.md`). Workouts must expose a rolling two-week plan with timers, logging, first-time tutorials, and exercise swap/revert. Coach screens on the user side provide chat/video entry points, booking calendars, quota banners, and the richer coach profile from `UI_UX/src/COACH_PROFILE_SCREEN_IMPLEMENTATION.md`.
- **Flutter**: `home_screen.dart` currently lists a simple plan summary without the quota banner, quick access stack, InBody tiles, or coach booking shortcuts. `workout_plan_screen.dart` lacks the tutorial overlay and exercise swap described in the SRS/UI_UX build, and the coach tab does not surface the professional profile or booking CTA hierarchy—only a basic coach list.
- **Backend**: Presently no dedicated endpoints feed the new home aggregates (e.g., adherence%, InBody summaries), workout swap catalog/locks, or coach profile metadata (certifications, achievements) required by the React source of truth.

## Implementation Plan

### Phase 1 – Foundation & Entry Flows *(Completed 1 Dec 2025)*
1. **Localization Shell (SRD §9, React `LanguageContext.tsx`)**
   - *Flutter* ✅ `mobile/lib/localization/app_localizations.dart`, `mobile/lib/state/app_state.dart`, and `mobile/lib/screens/intro/language_selection_screen.dart` now provide bilingual strings, store the locale in `SharedPreferences`, and block navigation until `AppState.hasSelectedLanguage` is true. `MaterialApp` exposes `supportedLocales`, and `ApiService` forwards `Accept-Language` for every request.
   - *Backend* ✅ `preferredLocaleFromRequest` inside `backend/src/auth.controller.ts` persists the locale when exchanging Firebase tokens so mobile and server stay in sync.
2. **Intro & Demo Mode (SRD §4.1 + React `AppIntroScreen.tsx`, `DemoModeIndicator.tsx`)**
   - *Flutter* ✅ `mobile/lib/screens/intro/app_intro_screen.dart`, `mobile/lib/demo/demo_launcher.dart`, and `mobile/lib/widgets/demo_mode_indicator.dart` recreate the three-slide carousel, long-press demo toggle, persona picker, and persistent banner before any auth surface.
   - *Backend* ✅ `/v1/demo/fixtures` (see `backend/src/demo/*.ts`) serves persona-specific payloads consumed by `DemoLauncher`, ensuring demo traffic remains read-only.
3. **Phone-First Authentication (SRD §3.1, React `AuthScreen.tsx`)**
   - *Flutter* ✅ `mobile/lib/screens/auth/login_screen.dart` defaults to the phone tab and embeds `PhoneLoginPanel`, which mirrors the React OTP UX (resend timers, auto-fill, error banners) via `firebase_auth`. Email/SSO alternatives remain on the second tab; routing honors the language → intro → phone auth order via `AppState.resolveLandingRoute()`.
   - *Backend* ✅ `backend/src/auth.controller.ts` verifies Firebase tokens, auto-promotes mapped demo phones to coach/admin tiers, and returns `{ access_token, refresh_token, subscriptionType, preferredLocale }` so Flutter can hydrate `AppState` in one call.
   - *Theme & Visuals* ✅ `mobile/lib/theme/app_theme.dart` plus `design_system/` assets reproduce the React gradients, frosted cards, and CTA treatments across language, intro, and auth screens (RTL-safe paddings included).
   - *Testing* ✅ `flutter test test/widget_test.dart test/widgets/demo_mode_indicator_test.dart` assert the gating order + demo banner, while `npm test -- --runInBand` executes `backend/tests/auth.controller.test.ts` to lock the Firebase/locale contract.

Phase 1 deliverables are now production-ready; subsequent work will build on this foundation for Phase 2.

### Phase 2 – Onboarding & Profile Continuity *(Completed 1 Dec 2025)*
1. **Two-Stage Intake Workflow (SRD §4.1, React `OnboardingScreen.tsx`, `SECOND_INTAKE_FIX.md`)**
   - *Flutter* ✅ `mobile/lib/screens/intake/intake_flow.dart` now chooses between `FirstIntakeScreen` and `SecondIntakeScreen` based on `AppState.intakeProgress`. Both screens live in `mobile/lib/screens/intake/first_intake_screen.dart` and `second_intake_screen.dart`, matching the React copy, iconography, gradients, and validation states. Users can skip Stage 2, resume later, and see hydrated answers thanks to the shared `IntakeState` + `AppState` storage.
   - *Backend* ✅ `backend/src/intake.controller.ts` exposes `/v1/intake/first`, `/v1/intake/second`, and `/v1/intake/skip-second`, persisting timestamps (`firstCompletedAt`, `secondCompletedAt`) and injury arrays so mobile and React consume the same JSON contract.
2. **Profile Persistence (SRD §8, React `AccountScreen.tsx`)**
   - *Flutter* ✅ `mobile/lib/state/app_state.dart` tracks the enriched `user` object (role, subscription, intake snapshot, locale, plans). Methods such as `saveFirstIntake`, `saveSecondIntake`, `skipSecondIntake`, `updatePlans`, and `_hydrateIntakeFromUser` keep Account, Workout, Coach, and Nutrition screens in sync with backend state.
   - *Backend* ✅ Prisma’s `UserIntake` + `User` records surfaced via `backend/src/users.controller.ts` and the intake router return the same fields React expects (`preferredLocale`, subscription tier, injury arrays), so Flutter renders consistent profile data.
   - *Theme & Visuals* ✅ Intake screens leverage the shared gradients (`FitCoachSurfaces` extension in `design_system/theme_extensions.dart`) to match the UI/UX glass panels, while plan generation uses `mobile/lib/screens/intake/plan_generation_screen.dart` for the same celebratory visuals before landing users on Home.
   - *Testing* ✅ `flutter test test/intake_flow_test.dart` covers Stage 1/Stage 2 submissions, gradient theming, and skip flows; backend parity is locked via `npm test -- --runInBand`, which runs `backend/tests/intake.controller.test.ts` to confirm payload contracts and guard against regressions.

Phase 2 is therefore fully delivered; subsequent phases (subscription/nutrition, home/workouts/coach, etc.) can now build on top of the stable intake/profile foundation.

### Phase 3 – Subscription & Nutrition Parity
1. **Quota Enforcement (SRD §3.3/§4.5, React `SubscriptionManager.tsx`, `NutritionExpiryBanner.tsx`, `CoachScreen.tsx`)**
   - *Flutter*: implement a shared quota model (mirroring `UI_UX/src/types/QuotaTypes.ts`) and render usage chips in coach/chat/nutrition screens with identical gradients, badges, and lock messaging. Ensure freemium nutrition expires after seven days and banners route to the Subscription paywall.
   - *Backend*: add quota counters + reset schedulers, expose `/usage/quota` payloads, and wire nutrition expiry enforcement. Provide Jest coverage for counter increments, expiry calculations, and payload contracts consumed by mobile.
2. **Nutrition Preferences Intake (SRD §4.4, React `NutritionPreferencesIntake.tsx`)**
   - *Flutter*: port the three-step intake (proteins, dinner habits, restrictions) and welcome/lock states exactly as in React, including AsyncStorage-equivalent flags (`pending_nutrition_intake`). Wire CTA buttons to the Subscription Manager when users upgrade mid-flow.
   - *Backend*: extend Prisma (`NutritionPreference`, `NutritionAccess`) and controllers to persist preferences, expiry windows, and pending flags. Ensure responses include `plan.generatedAt`, `expiresAt`, `status` field identical to React, and cover them with Jest tests.
   - *Theme & Visuals*: ensure Flutter nutrition and quota banners reuse the UI_UX gradients, pill borders, frosted cards, and background imagery so the entire subscription/nutrition experience matches color-for-color with React.
   - *Testing Scripts*: automate `flutter test test/widget/nutrition/nutrition_preferences_flow_test.dart` and quota expiry tests, plus backend `cd backend; npx jest tests/subscription_quota.service.test.ts tests/nutrition_preferences.controller.test.ts`.

### Phase 3b – Home, Workouts & Coach (User Experience)
1. **Home Hub Rebuild (SRD §4.2, React `HomeScreen.tsx`, `HOME_QUICK_ACCESS_GUIDE.md`)**
   - *Flutter*: rebuild `home_screen.dart` using the React composition—greeting header with tier badge, stat cards, weekly progress, "Today's Workout" card, navigation grid, activity feed, quick-access tile card, and freemium upgrade banner. Honor RTL spacing, icon colors, and the InBody CTA behavior.
   - *Backend*: create a `/v1/home/summary` service that aggregates workout adherence, nutrition macros, quotas, coach unread counts, and store promos so the Flutter UI can render with a single payload like the React mock data.
2. **Workout Plan & Exercise Tools (SRD §4.3, React `WorkoutScreen.tsx`, `ExerciseDetailScreen.tsx`)**
   - *Flutter*: implement the rolling two-week plan, exercise cards with statuses, tutorial overlay, rest timer, swap flow, and logging UI identical to React (including statuses like Swapped/In Progress). Introduce persistent `tutorial_seen` flags and rest timers with the same color coding.
   - *Backend*: extend workout templates to include swap-compatible exercise lists, lock flags, and logging endpoints that store swapped exercise metadata and completion stats.
3. **Coach Tab & Professional Profiles (SRD §4.5, React `CoachScreen.tsx`, `COACH_PROFILE_SCREEN_IMPLEMENTATION.md`)**
   - *Flutter*: recreate the message usage banner, chat thread styling, upgrade tip, booking calendar, session cards, and professional coach profile detail view. Hook quick-access buttons (Book Video, View Profile) into the home quick actions.
   - *Backend*: expose credential endpoints returning certificates/experience/achievements, booking slots, and quota snapshots so Flutter can render the same view as React.
4. **Testing & Verification**
   - Flutter: widget/golden tests for the home quick-access stack, exercise tutorial modal, swap controls, and coach profile sections; integration tests that simulate swap/revert and coach booking CTA flows.
   - Backend: Jest suites for the home summary resolver, swap eligibility logic, and coach credential endpoints; add contract tests to keep quota banner payloads aligned with client expectations.
   - *Theme & Visuals*: update shared Flutter theme tokens (colors, gradients, corner radii, shadows) so Home, Workout, and Coach modules mirror the React glass panels, dark surfaces, and neon accents; validate via golden tests against UI_UX references.
   - *Testing Scripts*: schedule `flutter test test/widget/home/home_quick_actions_golden_test.dart test/widget/workout/workout_swap_flow_test.dart` and `flutter drive --target=integration_test/coach_booking_test.dart`; backend runs `cd backend; npx jest tests/home_summary.resolver.test.ts tests/workout_swap.controller.test.ts tests/coach_profiles.controller.test.ts`.

### Phase 4 – Store, Cart, Checkout, Orders
1. **Store UI Enhancements (SRD §4.6, React `StoreScreen.tsx`)**
   - *Flutter*: clone the React product grid, category chips, discount badges, and product detail overlays; ensure search is live-filtered and includes subscriber discount ribbons.
2. **Cart & Checkout (React `CheckoutScreen.tsx`, `OrderDetailScreen.tsx`)**
   - *Flutter*: implement the pricing breakdown rows, confirmation modal, and order history cards with the same statuses and icons; include empty states per React.
3. **Backend Support**
   - Create product/discount schemas, GET/POST cart endpoints, and full order CRUD (list/detail/cancel/track). Return the same JSON fields React expects (discounts, shipping, tracking numbers) so Flutter can drop-in replace the mocks.
   - *Theme & Visuals*: synchronize store/cart Flutter widgets with the React theme—category chip palettes, hero gradients, product card shadows, checkout background textures, and order status color coding—to achieve pixel-level parity.
   - *Testing Scripts*: add `flutter test test/widget/store/store_grid_theme_test.dart test/widget/orders/order_history_flow_test.dart` plus Cypress-style integration via `flutter drive --target=integration_test/checkout_flow_test.dart`; backend executes `cd backend; npx jest tests/store.controller.test.ts tests/cart_checkout.service.test.ts tests/orders.controller.test.ts`.

### Phase 5 – Coach/Admin Experiences
1. **Coach Module (SRD §5, React `CoachDashboard.tsx`, `CoachScreen.tsx`)**
   - *Flutter*: unify coach list/schedule views into the main tab, add the pro profile detail with testimonials, ratings, and session stats, and mirror the React dashboard cards (active clients, adherence heatmap, alerts).
   - *Backend*: expand coach endpoints to deliver metrics aggregates, testimonials, and quota usage so Flutter dashboards and admin screens can mirror React behavior.
2. **Admin Dashboard (SRD §6, React `AdminDashboard.tsx`)**
   - *Flutter*: implement revenue, engagement, and inventory tiles with the same visual treatment; include alerts tables and coach approval queues.
   - *Backend*: add analytics pipelines + endpoints returning revenue, engagement, supplement sales, pending approvals, and real-time alerts expected by the React admin build.
   - *Theme & Visuals*: extend the shared theme to cover coach/admin dashboards so charts, cards, and alert banners replicate the UI_UX gradients, typography, and background panels exactly.
   - *Testing Scripts*: build dashboard widget tests `flutter test test/widget/admin/admin_dashboard_cards_test.dart` and data-pipeline integration `flutter drive --target=integration_test/admin_alerts_test.dart`; backend runs `cd backend; npx jest tests/coach_dashboard.resolver.test.ts tests/admin_metrics.controller.test.ts`.

### Phase 6 – Demo, Testing, and Release Hardening
1. **Demo Fixtures (SRD §11, React `DemoModeIndicator.tsx`, `DemoUserSwitcher.tsx`)**
   - *Flutter*: add an in-app persona switcher, banner, and safeguards identical to React’s demo tooling to avoid mixing demo + production data.
   - *Backend*: craft seed scripts + read-only feature flags for demo tenants aligned with the phone/email constants in React.
2. **End-to-End Validation**
   - *Testing*: run Flutter integration suites for freemium expiry, checkout, and resume-able intake; add backend contract tests + OpenAPI docs so payloads stay in sync.
   - *Theme & Visuals*: capture golden snapshots for all critical flows (demo, checkout, intake) to confirm Flutter renders the same backgrounds, color tokens, and GUI treatments as the React source during final QA.
   - *Testing Scripts*: automate regression packs via `flutter test --coverage` plus `flutter drive --target=integration_test/demo_mode_switcher_test.dart`, and backend CI command `cd backend; npm run test:e2e` (covering Jest + supertest suites) before release tags.

## Risks & Dependencies
- **Firebase Phone Auth** must be consistent between frontends; ensure backend verifies tokens both for phone-first login and demo flows.
- **Data Contract Drift**: Aligning `UserProfile` shapes requires coordinated schema updates plus versioning to avoid breaking the existing Flutter build.
- **Timeline**: Store/order upgrades depend on backend endpoints that do not yet exist; prioritize backend delivery before Flutter rewiring to avoid rework.

## Validation Log (1 Dec 2025)
- `backend` – `npm test -- --runInBand` (Node 18, ts-jest): **PASS 8/8 suites** after fixing duplicate `userId` spread in `src/nutrition/nutrition.controller.ts` (`parseMealPayload` now enforces the persisted owner). Console still emits expected warnings when Firebase service creds and legacy Stripe webhook stubs are absent in local env.
- `mobile` – `flutter test` (Flutter 3.24, Windows): **PASS 7/7 tests** covering intake wizard widgets and nutrition helpers; logs confirm intake submission callbacks run without regressions.
- Follow-up: keep Firebase/Stripe secrets in `.env.local` to silence warnings, and expand widget coverage once the remaining Coach messaging UI lands.

## Next Steps
1. Confirm whether React UI is the single source of truth for copy/layout or if design tokens exist separately.
2. Decide on localization framework for Flutter (Intl vs. Easy Localization) and map translations from `UI_UX/src/locales` (if available).
3. Schedule backend schema migration (products, orders, subscriptions) before mobile work begins Phase 4.
