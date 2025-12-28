# Flutter Implementation Backlog (React Parity)

This backlog lists concrete Flutter work to reach React UI/UX parity.
Use `docs/flutter_react_parity_matrix.md` and `docs/react_uiux_parity_checklist.md`
as input references.

## Priority 0 - Visual Token Parity
- [ ] Sync theme tokens with React (`UI_UX/src/index.css`):
  - [ ] Primary/secondary/accent/muted/border/ring colors
  - [ ] Destructive colors and states
  - [ ] Radius scale (10px base) and component radii
  - [ ] Input background and switch colors
  - [ ] Chart palette
- [ ] Verify typography scale and weights align with React.

## Priority 1 - Missing User Screens
- [ ] Checkout screen
- [ ] Order confirmation screen
- [ ] Order detail / order history screens
- [ ] Payment management screen
- [ ] Product detail full-screen view (React uses full screen)
- [ ] Meal detail full-screen view (React uses full screen)
- [ ] Exercise detail full-screen view (React uses full screen)
- [ ] Settings screen parity (React settings vs Flutter notifications-only)

## Priority 1 - Coach Screens
- [ ] Coach profile screen
- [ ] Coach settings screen
- [ ] Client plan manager
- [ ] Client report generator
- [ ] Workout plan builder parity (React layout and flows)
- [ ] Nutrition plan builder parity (React layout and flows)

## Priority 1 - Admin Screens
- [ ] Content management screen
- [ ] Subscription management screen
- [ ] System settings screen
- [ ] Analytics dashboard parity (React charts, KPIs)

## Priority 2 - Intro/Walkthrough Screens
- [ ] App intro screen
- [ ] Workout intro screen
- [ ] Nutrition intro screen
- [ ] Store intro screen
- [ ] Coach intro screen

## Priority 2 - UI Components & Design System
- [ ] Tabs (primary/secondary)
- [ ] Badges (all variants)
- [ ] Chips (filter/choice)
- [ ] Bottom navigation parity (height, icons, labels, active state)
- [ ] Advanced list tiles (icons, badges, trailing actions)
- [ ] Progress indicators (linear, circular, segmented)
- [ ] Card + button variants (ghost/link/outline) parity

## Priority 2 - RTL and Localization
- [ ] Full RTL mirroring and spacing audit
- [ ] Locale-aware number/date formatting
- [ ] RTL-specific goldens for all core screens

## Priority 2 - Navigation and Flow
- [ ] Deep link handling for all routes
- [ ] Auth/intake gating behavior matches React
- [ ] Demo mode parity and role switching
- [ ] Coach/admin flows accessible via role gating

## Priority 3 - Refactors for Modularity
- [ ] Split screen logic into feature modules (widgets + view models)
- [ ] Extract reusable UI tokens and spacing constants
- [ ] Centralize navigation route definitions
- [ ] Standardize screen scaffolds and app bars

## Progress Log
- [ ] 2025-__-__: Backlog created.
