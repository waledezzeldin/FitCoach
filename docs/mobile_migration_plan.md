# FitCoach+ Mobile Migration Plan

## 1. Overview
This document defines the end-to-end plan to migrate the existing React/Tailwind UI (UI_UX) to Flutter for the FitCoach+ mobile app, achieving visual and functional parity while aligning with the FitCoach+ v2.0 requirements in `SRS/SOFTWARE_REQUIREMENTS.md`.

## 2. Scope
- Port visual design tokens, components, and screens to Flutter.
- Implement core flows: Language → Auth → Intakes → Home → Workouts/Nutrition/Coach/Store.
- Provide localization (EN/AR) with RTL support.
- Establish robust testing (unit, widget/goldens, integration) and CI gates.
- Prepare for release with flavors, icons/splash, and build instructions.

Out of scope for this phase: backend feature changes, new product features beyond v2.0 SRS, and non-mobile web.

## 3. Architecture Baseline
- Flutter: Material 3, `ThemeExtension` for brand tokens.
- Routing: `go_router`.
- State: `ChangeNotifier` (AppState) + `Provider`; can evolve as needed.
- I18n: `intl` + platform localizations; custom `AppLocalizations`.
- Testing: `flutter_test`, goldens (optional later), `integration_test`.

Repo anchors:
- Theme tokens: `mobile/lib/theme/fitcoach_theme.dart`
- App shell: `mobile/lib/app.dart`, `mobile/lib/main.dart`
- I18n stub: `mobile/lib/l10n/app_localizations.dart`
- UI primitives: `mobile/lib/ui/*`

## 4. Phases, Deliverables, and Tests

### Phase 1: Baseline Setup + Tests
- Deliverables:
  - Dependencies installed and compatible with SDK 3.8.x.
  - Light/dark `ThemeData` with `FitCoachBrand` tokens.
  - Initial primitives: Primary/Ghost Buttons, Surface Card.
- Tests:
  - Theme smoke tests.
  - Widget tests for buttons and card.
- DoD:
  - `flutter analyze` clean (no errors) and core tests passing.

### Phase 2: Design System Parity
- Deliverables:
  - Inputs (filled/outlined), chips (filter/choice), tabs (primary/secondary), badges, progress, list tiles, bottom navigation.
  - Exact radii, spacing, borders, and colors matching UI_UX.
- Tests:
  - Widget/golden tests for light/dark and interaction states (focus/pressed/disabled/selected).
- DoD:
  - Component library renders with tokens; goldens approved.

### Phase 3: Localization + RTL
- Deliverables:
  - Expanded `en/ar` strings; bidi layouts; locale-aware numbers/dates.
  - Directionality-safe widgets and paddings.
- Tests:
  - String lookup tests; RTL mirroring widget tests (goldens optional).
- DoD:
  - Screens render correctly in EN/AR; basic copy complete.

### Phase 4: Routing + App State
- Deliverables:
  - GoRouter configuration for all target screens.
  - AppState: demo mode, persisted flags (hydration via `shared_preferences`).
- Tests:
  - Route navigation tests; deep link parsing; persistence round-trip tests.
- DoD:
  - Core navigation works; state transitions are deterministic.

### Phase 5: Auth Flow
- Deliverables:
  - Phone login UI (masking/validation), OTP screen, handoff to backend service layer.
- Tests:
  - Form validation tests; UI navigation on success/failure; mocked service responses.
- DoD:
  - Happy and failure paths tested; navigation to Intakes/Home functional.

### Phase 6: Intake Flows (First/Second)
- Deliverables:
  - Intake screens, models, gating rules, and persistence.
- Tests:
  - State machine unit tests; widget tests for required fields and resume flow.
- DoD:
  - Users can complete/restore intakes; constraints enforced.

### Phase 7: Home Dashboard
- Deliverables:
  - Quick stats, macro summary, weekly progress chart, quick actions grid.
- Tests:
  - Widget/golden tests; data mapping unit tests; navigation from quick actions.
- DoD:
  - Visual parity with UI_UX; navigation works.

### Phase 8: Workouts Module
- Deliverables:
  - Plan list/details, session player, rest timers, completion flow.
- Tests:
  - Session state tests; timers; end-of-session behaviors.
- DoD:
  - End-to-end workout session flow stable.

### Phase 9: Nutrition Module
- Deliverables:
  - Preferences flow, expiry banners, plan UI, macro editor (if in scope).
- Tests:
  - Preference serialization; expiry computations; banner visibility logic.
- DoD:
  - Access gating correct; UI parity validated.

### Phase 10: Coach Module
- Deliverables:
  - Schedule view, session requests list, simple chat/notifications view.
- Tests:
  - Schedule list widget tests; mock coach actions.
- DoD:
  - Core coach interactions rendered and navigable.

### Phase 11: Store Module
- Deliverables:
  - Product list/details, cart, checkout integration hooks.
- Tests:
  - Cart arithmetic; validation; mocked checkout path.
- DoD:
  - Add/remove cart works; mocked checkout navigates correctly.

### Phase 12: Notifications + Tokens
- Deliverables:
  - Permission prompts, device token storage, topic subscriptions.
- Tests:
  - Token persistence; permission gating; mock message routing.
- DoD:
  - Tokens registered and retrievable; basic topic sub works (mocked).

### Phase 13: Offline + Persistence
- Deliverables:
  - Local cache (shared_prefs / hive), retry queues for critical actions.
- Tests:
  - Cache read/write; offline enqueue/dequeue; replay on connectivity.
- DoD:
  - App resilient to intermittent connectivity.

### Phase 14: Theming Polish + Goldens
- Deliverables:
  - Final pass for spacing/gradients/state colors to match React.
- Tests:
  - Golden suite for components and key screens in light/dark.
- DoD:
  - Goldens stabilized and approved.

### Phase 15: E2E Integration Tests
- Deliverables:
  - integration_test flows: Language→Auth→Intakes→Home, Workouts, Nutrition.
- Tests:
  - Device/emulator E2E with fixtures and mocks.
- DoD:
  - Flows pass consistently locally and in CI.

### Phase 16: Release Readiness + CI
- Deliverables:
  - App icons/splash, flavors, CI (analyze/test/goldens), signing docs.
- Tests:
  - CI green; minimal performance/size checks.
- DoD:
  - Releasable artifacts build for debug/release.

## 5. Milestones & Acceptance Criteria
- M1 (Phases 1–4): App shell + design system + routing/state; tests green.
- M2 (Phases 5–7): Auth + Intakes + Home functional; goldens for key pages.
- M3 (Phases 8–11): Workouts/Nutrition/Coach/Store navigable with mocks.
- M4 (Phases 12–16): Notifications/offline; polish; E2E; CI; release readiness.

## 5.1 Current Status (2025-12-07)
- Phase 1: Completed (theme, deps, primitives, tests; analyzer clean).
- Phase 2: In progress (inputs/chips/tabs/badges/progress/bottom nav partial; goldens scaffolded).
- Phase 3: In progress (EN/AR localization wired; broaden copy + RTL validations pending).
- Phase 4: Completed (`go_router`, `AppState` hydration for demo/locale, persistence; navigation tests stable).
- Phase 5: Completed (UI scope) — Login/Signup flow routes to Quick Start intake; social CTAs (Google/Facebook/Apple) route to Quick Start; phone path stub at `/auth_phone`; backend OTP/linking pending.
- Phase 6: Completed — First Intake via Quick Start and Second Intake (3-step: experience → days/week → injuries multi-select). Second Intake accessible to all tiers; workouts reminder CTA starts at step 1; persistence wired; splash gate routes to Quick Start when incomplete.
- Phase 7: Completed — Home dashboard widgets integrated; quick actions navigate; tests pass.
- Phase 8: Completed — Workouts list/detail/session player, completion screen; localized session controls; tests pass.
- Phase 9: Completed (client gating/persistence) — Nutrition prefs/plan UI, expiry window, Premium unlock; algorithm/backend pending.
- Phase 10: In progress — Coach quotas UI + attachments gating; scheduling/chat lists pending.
- Phase 11: In progress — Store stub screen; product/cart/checkout hooks pending.
- Phase 12: Not started — Notifications/tokens.
- Phase 13: In progress — SharedPreferences hydration; offline queues/replay pending.
- Phase 14: In progress — Theming polish + golden suite not locked.
- Phase 15: In progress — Integration_test flows not authored.
- Phase 16: Not started — Icons/splash/flavors/CI/signing.

## 5.2 Implementation TODO Checklist

### Completed
- Phase 1: Baseline Setup + Tests
- Phase 4: Routing + App State
- Phase 5: Auth Flow (UI + tests; backend OTP pending)
- Phase 6: First Intake (Quick Start) + Splash gating
- Phase 7: Home Dashboard (widgets, navigation)
- Phase 8: Workouts Module (session player + completion)
- Phase 9: Nutrition Module (prefs, plan UI, expiry window, Premium unlock)

### In Progress
- Phase 2: Design System Parity (components + goldens)
- Phase 3: Localization + RTL (expand copy; RTL validations)
- Phase 10: Coach Module (quotas UI; attachments gating)
- Phase 11: Store Module (stub; implement product/cart)
- Phase 13: Offline + Persistence (extend beyond shared_prefs)
- Phase 14: Theming Polish + Goldens (lock goldens)
- Phase 15: E2E Integration Tests (author flows)

### Not Started / Pending
- Phase 5 backend: Phone OTP service and linking
- Phase 6: Personalized plan generation from Second Intake data
- Phase 9 backend: Nutrition generation algorithm + backend integration
- Phase 10: Scheduling, calls, ratings flows
- Phase 12: Notifications + tokens
- Phase 16: Release Readiness + CI (icons/splash/flavors/CI/signing)

### Next 3 Priorities
- Implement Starter Plan card on `HomeScreen` (label per SRS WO-01) sourced from Quick Start/Second Intake.
- Add Nutrition expiry countdown banner in `NutritionPlanScreen` based on `expiresAt`.
- Polish Paywall tier matrix in `SubscriptionScreen` with localized pricing/benefits and upgrade CTA.

## 5.3 Routes & Persistence Guide
- Routes:
  - Language: `/language`
  - Onboarding: `/onboarding`
  - Auth: `/login`, `/signup`, `/auth_phone`
  - Quick Start Intake: `/quickstart/1`, `/quickstart/2`, `/quickstart/3`
  - Second Intake (3-step): `/intake/second/1` (experience), `/intake/second/2` (days/week), `/intake/second/3` (injuries + complete)
  - Home: `/home`
  - Workouts: `/workouts`, `/workouts/:id`, `/workouts/:id/session`, `/workouts/:id/session/complete`
  - Nutrition: `/nutrition`, `/nutrition/preferences`
  - Coach: `/coach`
  - Store: `/store`
  - Subscription: `/subscription`

- Persistence:
  - AppState: `app.locale`, `app.demo` via `SharedPreferences`.
  - AuthState: basic login email persisted (stub).
  - IntakeState:
    - Quick Start: gender/location/basic profile.
    - Second Intake: `experience`, `daysPerWeek`, `injuries` (boolean presence from multi-select chips). Data saved incrementally per step.
  - NutritionState: preferences and expiry window.

- Gating:
  - SplashGate routes: unauth → `/language`; logged-in with incomplete Quick Start → `/quickstart/1`; else → `/home`.
  - Workouts not gated; shows Second Intake reminder banner with CTA to `/intake/second/1`.
  - Nutrition gated by tier for freemium.

## 5.4 QA Test Cases (Draft)
- Language → Onboarding → Login
  - Select EN/AR; verify locale persisted; onboarding Next → login.
- Login/Signup → Quick Start
  - Email login and signup navigate to `/quickstart/1`.
  - Social CTAs (Google/Facebook/Apple) navigate to `/quickstart/1`.
- Quick Start (1→3)
  - Complete each step; verify completion routes to `/home`.
- Second Intake (1→3)
  - Step 1: select experience; Next enabled; persists value.
  - Step 2: choose days/week; Next enabled; persists value.
  - Step 3: select injuries chips; Complete saves and marks intake complete; routes `/home`.
- Workouts Reminder
  - When Second Intake incomplete, banner visible; CTA routes to `/intake/second/1`.
  - Generic continue allows workout navigation.
- Nutrition
  - Freemium tier routes to `/subscription`; premium opens `/nutrition`.
- Localization
  - Verify key strings in EN/AR and RTL layout sanity.

## 5.5 Remaining Work Breakdown
- Phase 2: Finish component parity (tabs, badges, progress, bottom nav) and add goldens.
- Phase 3: Expand localization copy; thorough RTL validations; date/number formatting.
- Phase 5 backend: Implement phone OTP flow and account linking; service layer + mocks.
- Phase 6: Generate personalized plan from Second Intake data; tie into workouts recommendation.
- Phase 10: Coach scheduling, calls, ratings; simple chat persistence (mock).
- Phase 11: Store product/cart/checkout hooks; cart math and validation.
- Phase 12: Notifications/tokens; permission prompts; token storage.
- Phase 13: Offline queues for critical actions; retry/replay.
- Phase 14: Polish theming; lock golden suite.
- Phase 15: Author integration_test flows for core journeys; CI runner config.
- Phase 16: Release readiness: icons/splash, flavors, CI (analyze/test/goldens), signing docs.

## 6. Quality Gates
- Analyze: zero errors; warnings triaged.
- Unit/widget coverage: grows per phase; critical logic covered.
- Goldens: locked after design sign-off.
- E2E: passing core user journeys.

## 7. Runbook (Local)
```powershell
Push-Location "d:\mobile applicatio\Git_Repo\FitCoach\mobile"
flutter pub get
flutter analyze
flutter test -r expanded
Pop-Location
```

## 8. Risks & Assumptions
- Visual parity may surface Tailwind/shadcn features requiring custom widgets.
- Some tests on Windows shells may need tweaks to avoid hangs; mitigate with simpler pumps, verbose, or headless flags.
- Backend integration points will be mocked until endpoints are ready/verified.

## 9. Change Log
- 2025-12-05: Initial plan authored; Baseline (Phase 1) implemented (theme, deps, primitives, tests). Phase 2 in progress: inputs, chips, tabs, badges, progress, bottom nav added with tests; golden tests scaffolded (skipped by default). Phase 3 underway: localization RTL tests added. Phase 4: added AppState persistence (locale/demo) using shared_preferences with unit test.
- 2025-12-05: Phase 6 completed (intake state/screens, splash gating, tests). Phase 7 started: implemented Home dashboard widgets (`QuickStatsRow`, `MacroSummary`, `WeeklyProgress`, `QuickActionsGrid`), refactored `HomeScreen` to use them, and added widget tests. Goldens to be enabled after visual approval.
 - 2025-12-05: Phase 6 completed (intake state/screens, splash gating, tests). Phase 7: wired Home quick actions to GoRouter (`/workouts`, `/nutrition`, `/coach`, `/store`) and added stub screens; added navigation test using `GoRouter` to validate taps navigate correctly. Fixed test stability by making Home/Intake scrollable and ensuring tests pump theme/localizations.
 - 2025-12-05: Phase 8 started: added workouts list/detail screens and `SessionController`; created `SessionPlayerScreen` and route `/workouts/:id/session`; wrote tests for list→detail, detail→session, and session controller behavior. Analyzer clean except planned theme deprecation infos.
 - 2025-12-05: Phase 8 progressed: implemented `SessionResult` model and `SessionCompleteScreen` at route `/workouts/:id/session/complete`. Wired "Complete Session" button to navigate with summary data. Added widget/navigation test `session_completion_test.dart`. All workouts tests passing locally.
 - 2025-12-06: Phase 9 completed: Nutrition preferences and plan screens, macro targets, refresh banner, persistence; polished UI using brand components (`SurfaceCard`, `PrimaryButton`). Fixed tests with shared_prefs mock and Provider wiring. Analyzer clean.
 - 2025-12-06: Auth flow implemented (Phase 5 scope adjusted): added `AuthState` with persistence, `LoginScreen` and `SignUpScreen`, routed via `/login` and `/signup`. Updated `SplashGate` to require login before routing to Intake/Home. Added auth widget tests (`auth_flow_test.dart`) verifying navigation to Home after login/sign-up. Analyzer and tests passing.
- 2025-12-07: Flow updates per SRS: Language → Onboarding → Login → Quick Start; social CTAs navigate directly to Quick Start; Second Intake accessible to everyone and split into 3 screens (`/intake/second/1..3`) with injuries multi-select chips; workouts reminder CTA updated to start Second Intake at step 1. Plan doc status and priorities updated.
