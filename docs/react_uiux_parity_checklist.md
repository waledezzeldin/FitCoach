# React UI_UX Parity Checklist (Source of Truth)

This checklist defines the visual tokens, screen flows, and required screens
from the React UI_UX codebase and SRS. Use it to drive Flutter parity.

## Sources
- UI tokens: `UI_UX/src/index.css`
- Screen flow: `UI_UX/src/App.tsx`
- Screen inventory: `UI_UX/src/components/*.tsx`, `UI_UX/src/components/admin/*.tsx`
- SRS screens (Part 1 only): `docs/docs/03-SCREEN-SPECIFICATIONS.md`

## Theme Tokens (React)
### Base Colors
- [ ] background: `#ffffff`
- [ ] foreground: `oklch(.145 0 0)`
- [ ] card: `#ffffff`
- [ ] card-foreground: `oklch(.145 0 0)`
- [ ] popover: `oklch(1 0 0)`
- [ ] popover-foreground: `oklch(.145 0 0)`
- [ ] primary: `#3b82f6`
- [ ] primary-foreground: `oklch(1 0 0)`
- [ ] secondary: `#e9d5ff`
- [ ] secondary-foreground: `#7c5fdc`
- [ ] muted: `#ececf0`
- [ ] muted-foreground: `#717182`
- [ ] accent: `#f59e0b`
- [ ] accent-foreground: `#ffffff`
- [ ] destructive: `#d4183d`
- [ ] destructive-foreground: `#ffffff`
- [ ] border: `#0000001a`
- [ ] ring: `#7c5fdc`

### Inputs and Controls
- [ ] input: `transparent`
- [ ] input-background: `#f3f3f5`
- [ ] switch-background: `#cbced4`

### Charts
- [ ] chart-1: `#3b82f6`
- [ ] chart-2: `#7c5fdc`
- [ ] chart-3: `#f59e0b`
- [ ] chart-4: `#60a5fa`
- [ ] chart-5: `#a78bfa`

### Radius
- [ ] radius: `0.625rem` (10px)
- [ ] radius-xs: `0.125rem` (2px)
- [ ] radius-2xl: `1rem` (16px)
- [ ] radius-3xl: `1.5rem` (24px)

### Sidebar Tokens
- [ ] sidebar: `oklch(.985 0 0)`
- [ ] sidebar-foreground: `oklch(.145 0 0)`
- [ ] sidebar-primary: `#3b82f6`
- [ ] sidebar-primary-foreground: `oklch(.985 0 0)`
- [ ] sidebar-accent: `oklch(.97 0 0)`
- [ ] sidebar-accent-foreground: `oklch(.205 0 0)`
- [ ] sidebar-border: `oklch(.922 0 0)`
- [ ] sidebar-ring: `#7c5fdc`

### Dark Mode (Core Tokens)
- [ ] background: `oklch(.145 0 0)`
- [ ] foreground: `oklch(.985 0 0)`
- [ ] card: `oklch(.145 0 0)`
- [ ] card-foreground: `oklch(.985 0 0)`
- [ ] primary: `oklch(.985 0 0)`
- [ ] secondary: `oklch(.269 0 0)`
- [ ] muted: `oklch(.269 0 0)`
- [ ] accent: `oklch(.269 0 0)`
- [ ] border: `oklch(.269 0 0)`
- [ ] ring: `oklch(.439 0 0)`

## Screen Flow (React App.tsx)
- [ ] Splash -> Language Selection -> Onboarding Carousel -> Auth (OTP)
- [ ] First Intake -> Second Intake -> Home
- [ ] Home tabs: Workout, Nutrition, Coach, Store, Account
- [ ] Coach/Admin demo mode paths (phone numbers trigger role)

## Screen Inventory by Role
### User Journey
- [ ] SplashScreen
- [ ] LanguageSelectionScreen
- [ ] OnboardingCarousel / OnboardingScreen
- [ ] AuthScreen (OTP)
- [ ] FirstIntakeScreen
- [ ] SecondIntakeScreen
- [ ] HomeScreen (Dashboard)
- [ ] WorkoutScreen
- [ ] NutritionScreen
- [ ] CoachScreen (user-facing coach messaging)
- [ ] StoreScreen
- [ ] AccountScreen
- [ ] ProgressDetailScreen
- [ ] ExerciseLibraryScreen
- [ ] ExerciseDetailScreen
- [ ] VideoBookingScreen
- [ ] InBodyInputScreen
- [ ] SubscriptionManager
- [ ] CheckoutScreen
- [ ] OrderConfirmationScreen
- [ ] OrderDetailScreen
- [ ] ProductDetailScreen
- [ ] MealDetailScreen
- [ ] PaymentManagementScreen
- [ ] SettingsScreen

### Coach Journey
- [ ] CoachDashboard
- [ ] CoachMessagingScreen
- [ ] CoachCalendarScreen
- [ ] CoachEarningsScreen
- [ ] CoachProfileScreen
- [ ] CoachSettingsScreen
- [ ] ClientDetailScreen
- [ ] ClientPlanManager
- [ ] ClientReportGenerator
- [ ] WorkoutPlanBuilder
- [ ] NutritionPlanBuilder
- [ ] PublicCoachProfileScreen

### Admin Journey
- [ ] AdminDashboard
- [ ] UserManagementScreen
- [ ] CoachManagementScreen
- [ ] ContentManagementScreen
- [ ] AnalyticsDashboard
- [ ] StoreManagementScreen
- [ ] SubscriptionManagementScreen
- [ ] SystemSettingsScreen
- [ ] AuditLogsScreen

### Supporting/Shared UI
- [ ] AppIntroScreen
- [ ] WorkoutIntroScreen
- [ ] NutritionIntroScreen
- [ ] StoreIntroScreen
- [ ] CoachIntroScreen
- [ ] QuotaDisplay
- [ ] RatingModal
- [ ] NutritionPreferencesIntake
- [ ] NutritionExpiryBanner
- [ ] WorkoutTimer
- [ ] FoodLoggingDialog
- [ ] FitnessScoreAssignmentDialog
- [ ] DemoModeIndicator
- [ ] DemoUserSwitcher

## SRS Coverage Notes
- Part 1 exists for screens 1-8 in `docs/docs/03-SCREEN-SPECIFICATIONS.md`.
- Part 2 is referenced but missing; use React components as source until SRS is complete.

## Progress Log
- [ ] 2025-__-__: Checklist created from React UI_UX sources.
- [x] 2026-01-06: Store Arabic content fixed, account actions wired to real screens, demo role routing updated, coach/admin labels centralized.
