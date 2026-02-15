# Flutter Migration Gap Closure Checklist

This checklist provides a step-by-step, trackable plan to close all gaps and achieve full parity with the original UI_UX React code, as well as the requirements in the migration plan and SRS. Each step is a checkbox for tracking progress.

---

## 1. Design System & Theming
- [ ] Implement all missing design system components:
  - [ ] Tabs (primary/secondary)
  - [ ] Badges (all states)
  - [ ] Chips (filter/choice)
  - [ ] Bottom navigation bar
  - [ ] Advanced list tiles
  - [ ] Progress indicators (all variants)
- [ ] Match all radii, spacing, borders, and colors to React UI_UX
- [ ] Polish gradients, shadows, and state colors
- [ ] Lock and approve golden tests for all components (light/dark, RTL)

## 2. Localization & RTL
- [ ] Expand all EN/AR strings to match React copy
- [ ] Validate all screens for RTL mirroring and layout
- [ ] Ensure locale-aware number/date formatting
- [ ] Add/validate directionality-safe paddings and widgets
- [ ] Lock goldens for RTL screens

## 3. Routing & Navigation
- [ ] Deep link parsing and navigation tests for all routes
- [ ] Validate all navigation flows (including edge cases)
- [ ] Add missing navigation transitions/animations as in React

## 4. Intake Flows
- [ ] Second Intake: Complete multi-step form UI (age, weight, height, experience, days/week, injuries)
- [ ] Implement plan generation logic from Second Intake data
- [ ] Connect plan generation to backend (if applicable)
- [ ] Validate persistence and resume flow for all intake steps
- [ ] Add widget/integration tests for all intake flows

## 5. Home Dashboard
- [ ] Polish Starter Plan card to match React (label, layout, data source)
- [ ] Add/validate Upgrade CTA and banners
- [ ] Match all quick stats, macro summary, and progress visuals
- [ ] Add goldens for Home dashboard (light/dark, RTL)

## 6. Workouts Module
- [ ] Validate plan list, detail, session player, and completion flows
- [ ] Implement advanced session logic (timers, logs, offline save)
- [ ] Add widget/integration tests for all workout flows
- [ ] Lock goldens for workouts screens

## 7. Nutrition Module
- [ ] Complete preferences flow and expiry banners
- [ ] Implement nutrition plan generation algorithm (if not done)
- [ ] Connect to backend for nutrition plans (if applicable)
- [ ] Add widget/integration tests for nutrition flows
- [ ] Lock goldens for nutrition screens

## 8. Coach Module
- [ ] Complete quotas UI and attachments gating
- [ ] Implement scheduling, chat, ratings, and calls UI
- [ ] Connect to backend for coach features (if applicable)
- [ ] Add widget/integration tests for coach flows
- [ ] Lock goldens for coach screens

## 9. Store Module
- [ ] Complete product list, cart, and checkout UI
- [ ] Implement cart arithmetic and validation
- [ ] Connect to backend for store/checkout (if applicable)
- [ ] Add widget/integration tests for store flows
- [ ] Lock goldens for store screens

## 10. Notifications & Offline
- [ ] Implement device token storage and topic subscriptions
- [ ] Add permission prompts for notifications
- [ ] Implement offline queues and retry/replay logic
- [ ] Add tests for offline and notification flows


## 11. Testing & CI
- [ ] Refactor all test code to achieve 100% unit test coverage for each component/module
  - [ ] Home dashboard: 100% unit test coverage
  - [ ] Workouts module: 100% unit test coverage
  - [ ] Nutrition module: 100% unit test coverage
  - [ ] Coach module: 100% unit test coverage
  - [ ] Store module: 100% unit test coverage
  - [ ] Intake flows: 100% unit test coverage
  - [ ] Design system components: 100% unit test coverage
- [ ] Refactor all test code to achieve 100% integration test coverage for each component/module
  - [ ] Home dashboard: 100% integration test coverage
  - [ ] Workouts module: 100% integration test coverage
  - [ ] Nutrition module: 100% integration test coverage
  - [ ] Coach module: 100% integration test coverage
  - [ ] Store module: 100% integration test coverage
  - [ ] Intake flows: 100% integration test coverage
  - [ ] Design system components: 100% integration test coverage
- [ ] Expand widget/integration test coverage for all modules
- [ ] Author E2E integration tests for all core user journeys
- [ ] Lock and approve all goldens (light/dark, RTL)
- [ ] Ensure CI workflow is green for all branches

## 12. Release Readiness
- [ ] Finalize app icons and splash screens
- [ ] Configure flavors (dev, prod) for Android/iOS
- [ ] Document build and release instructions
- [ ] Prepare app store metadata and screenshots
- [ ] Ensure all tests pass in CI
- [ ] Sign and build release artifacts

---

## Tracking Table (Example)
| Step | Status | Notes |
|------|--------|-------|
| Design System: Tabs | [ ] |  |
| Design System: Badges | [ ] |  |
| ... | ... | ... |

---

**Instructions:**
- Check off each item as it is completed.
- Add notes for blockers, design clarifications, or backend dependencies.
- Use this document as the single source of truth for migration progress.

---

For any step, refer to the original React UI_UX code and the SRS for exact requirements and visual details.
