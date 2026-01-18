# Flutter UI/UX Parity Completion Plan

## Objective
Ensure 100% completion of all Flutter screens with unified language and theme providers, robust navigation, and demo-mode data separation.

---

## Phase 1 – Inventory & Standards
- Catalog all screens/pages (user, coach, admin, onboarding, auth, workouts, etc.)
- Track localization, theming, navigation, demo hooks in a central checklist
- Define “done” criteria: uses LanguageProvider, ThemeProvider, navigation wired, demo-mode toggle respected, zero analyzer warnings

## Phase 2 – Infrastructure
- [x] Ensure LanguageProvider and ThemeProvider are available at app root
- [x] Implement DemoModeProvider/config service keyed off compile-time flag (`kDemoMode`)
- [x] Create demo-data repositories for each domain (workouts, chats, subscriptions, metrics)
- [x] In non-demo builds, demo data remains unused; wrap imports/usage with `if (kDemoMode)`

## Phase 3 – Screen-by-Screen Pass
For every screen:
1. Localization: replace strings with `languageProvider.t('key')`, add missing keys
2. Theming: swap hard-coded colors/typography for theme tokens or AppColors
3. Demo mode: when `kDemoMode` is true, seed view-models/providers with mock data; when false, rely on live services
4. Navigation sanity: verify every button uses Navigator/Router targets; add tests when navigation logic is complex

Suggested order:
1. Core user flows (onboarding, auth, dashboard, workout detail, chat)
2. Admin & coach tools (subscription management, client list, analytics)
3. Settings/profile, billing, support/help center
4. Edge screens (empty states, error pages, modal sheets)

## Phase 4 – Verification
- Run `flutter analyze` and UI/widget tests per module
- Smoke-test demo build (`flutter run --dart-define=demo_mode=true`)
- Run again without flag to ensure real services load and no mock leaks
- Capture screenshots / short videos for stakeholder sign-off
- Latest run: `flutter analyze` (no errors; warnings/infos remain)

## Phase 5 – Documentation & Hand-off
- Update README/docs to explain demo flag usage, provider architecture, and new translation keys
- Summarize outstanding gaps (if any) with owners and deadlines

---

## Progress Checklist
| Screen/Module                       | Localization | Theming | Navigation | Demo Mode | Status |
|-------------------------------------|--------------|---------|------------|-----------|--------|
| OnboardingScreen                    | ✅           | ✅      | ✅         |           | In progress |
| LoginScreen                         | ✅           | ✅      | ✅         |           | In progress |
| HomeDashboardScreen                 | ?            |         |            | ?         | In progress |
| WorkoutScreen                       | ?            |         |            | ?         | In progress |
| WorkoutIntroScreen                  | ✅           | ✅      | ✅         |           | In progress |
| WorkoutTimerScreen                  | ✅           | ✅      | ✅         |           | In progress |
| SubscriptionManagerScreen           |              |         |            |           |        |
| NotificationSettingsScreen          |              |         |            |           |        |
| ProfileEditScreen                   |              |         |            |           |        |
| CoachDashboardScreen                |              |         |            |           |        |
| CoachClientsScreen                  |              |         |            |           |        |
| CoachClientDetailScreen             |              |         |            |           |        |
| CoachMessagingScreen                | ✅           |         |            |           | In progress |
| CoachMessageThreadScreen            | ✅           | ✅      | ✅         |         | In progress |
| CoachScheduleSessionSheet           | ✅           |         |            |           | In progress |
| AdminDashboardScreen                |              |         |            |           |        |
| AdminUsersScreen                    |              |         |            |           |        |
| AdminCoachesScreen                  |              |         |            |           |        |
| AdminRevenueScreen                  |              |         |            |           |        |
| AdminAuditLogsScreen                |              |         |            |           |        |
| StoreManagementScreen               |              |         |            |           |        |
| SubscriptionManagementScreen        |              |         |            |           |        |
| ... (add additional screens as needed) ...

## 'Done' Criteria
- Uses LanguageProvider for all user-facing strings
- Uses ThemeProvider or AppColors for all colors/typography
- All navigation buttons route to valid screens
- Demo mode (kDemoMode) shows mock/demo data only in demo builds
- No analyzer warnings
