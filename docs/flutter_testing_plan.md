# Flutter Testing Plan (100% Coverage Target)

This plan defines the test scope required for full parity and quality.

## Coverage Targets
- Unit tests: 100% for core utilities, models, services, repositories.
- Widget tests: 100% for design-system components.
- Screen tests: 100% for user/coach/admin screens.
- Golden tests: light/dark + RTL for all core screens and components.
- Integration tests: all critical flows and edge cases.

## Test Matrix by Module
### Core
- [ ] `lib/core/config` (API config, env switching)
- [ ] `lib/core/constants` (colors, text styles, spacing)
- [ ] `lib/core/utils` (date/formatting, validators)

### Data Layer
- [ ] Repositories: auth, user, workout, nutrition, messaging, coach, admin, store, payment
- [ ] Models: user/profile, intake, workout, nutrition, store, progress, inbody
- [ ] Error handling and API response mapping

### Presentation
- [ ] Design system widgets (buttons, cards, inputs, tabs, chips, badges)
- [ ] Navigation scaffolds (bottom nav, app bar, drawers)
- [ ] Screen widgets for each role

### Flows
- [ ] Auth: OTP happy path + failure paths
- [ ] Intake: stage 1 + stage 2 completion and resume
- [ ] Home: quotas, banners, CTA behavior
- [ ] Workout: exercise completion + injury substitution
- [ ] Nutrition: trial gating + plan generation
- [ ] Messaging: quota enforcement + attachments gating
- [ ] Store: cart, checkout, order history
- [ ] Coach: client plans, reports, scheduling
- [ ] Admin: user/coach/content/store/subscription/system settings

## Golden Test Coverage
- [ ] Light/Dark + RTL for each core screen
- [ ] All design-system components (including hover/disabled states)
- [ ] Critical dialogs/modals (ratings, logging, confirmation)

## Tooling and Setup
- [ ] Use test fakes for APIs (Dio mock, repository fakes)
- [ ] Use deterministic time/date providers
- [ ] Lock golden baselines once parity is achieved
- [ ] CI gate for coverage thresholds and golden diffs

## Progress Log
- [ ] 2025-__-__: Flutter testing plan created.
