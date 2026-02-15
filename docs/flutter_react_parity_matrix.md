# Flutter vs React Parity Matrix

This matrix maps React UI_UX screens to Flutter screens and flags gaps.
Source references: `UI_UX/src/components`, `UI_UX/src/components/admin`,
`mobile/lib/presentation/screens`, `mobile/docs/REACT_VS_FLUTTER_COMPARISON.md`.

Legend:
- Match: Flutter screen exists and is intended to mirror React.
- Partial: Flutter exists but differs (modal vs screen, placeholders, integrated tab).
- Missing: No Flutter screen found.
- Extra: Flutter screen not present in React.

## User Journey Screens
| React Screen | Flutter Screen | Status | Notes |
| --- | --- | --- | --- |
| SplashScreen | `mobile/lib/presentation/screens/splash_screen.dart` | Match | |
| LanguageSelectionScreen | `mobile/lib/presentation/screens/language_selection_screen.dart` | Match | |
| AppIntroScreen | `mobile/lib/presentation/screens/intro/feature_intro_screen.dart` | Partial | Flutter uses generic intro; needs AppIntro parity. |
| OnboardingCarousel / OnboardingScreen | `mobile/lib/presentation/screens/onboarding_screen.dart` | Match | |
| AuthScreen (OTP) | `mobile/lib/presentation/screens/auth/otp_auth_screen.dart` | Match | React uses OTP-only auth. |
| FirstIntakeScreen | `mobile/lib/presentation/screens/intake/first_intake_screen.dart` | Match | |
| SecondIntakeScreen | `mobile/lib/presentation/screens/intake/second_intake_screen.dart` | Match | |
| HomeScreen | `mobile/lib/presentation/screens/home/home_dashboard_screen.dart` | Match | |
| WorkoutScreen | `mobile/lib/presentation/screens/workout/workout_screen.dart` | Match | |
| NutritionScreen | `mobile/lib/presentation/screens/nutrition/nutrition_screen.dart` | Match | |
| CoachScreen | `mobile/lib/presentation/screens/messaging/coach_messaging_screen.dart` | Partial | React uses CoachScreen container; Flutter has messaging screen only. |
| StoreScreen | `mobile/lib/presentation/screens/store/store_screen.dart` | Match | |
| AccountScreen | `mobile/lib/presentation/screens/account/account_screen.dart` | Match | |
| ProgressDetailScreen | `mobile/lib/presentation/screens/progress/progress_screen.dart` | Match | Flutter uses Progress screen. |
| ExerciseLibraryScreen | `mobile/lib/presentation/screens/exercise/exercise_library_screen.dart` | Match | |
| ExerciseDetailScreen | (Modal or detail view) | Partial | React uses full screen; Flutter likely modal/detail view. |
| VideoBookingScreen | `mobile/lib/presentation/screens/booking/video_booking_screen.dart` | Match | |
| InBodyInputScreen | `mobile/lib/presentation/screens/inbody/inbody_input_screen.dart` | Partial | Exists, verify parity vs React. |
| SubscriptionManager | `mobile/lib/presentation/screens/subscription/subscription_manager_screen.dart` | Match | |
| CheckoutScreen | Not found | Missing | |
| OrderConfirmationScreen | Not found | Missing | |
| OrderDetailScreen | Not found | Missing | |
| ProductDetailScreen | Not found | Missing | React uses full screen. |
| MealDetailScreen | Not found | Missing | React uses full screen. |
| PaymentManagementScreen | Not found | Missing | |
| SettingsScreen | `mobile/lib/presentation/screens/settings/notification_settings_screen.dart` | Partial | Flutter has notification settings only. |

## Coach Journey Screens
| React Screen | Flutter Screen | Status | Notes |
| --- | --- | --- | --- |
| CoachDashboard | `mobile/lib/presentation/screens/coach/coach_dashboard_screen.dart` | Match | |
| CoachMessagingScreen | `mobile/lib/presentation/screens/messaging/coach_messaging_screen.dart` | Match | |
| CoachCalendarScreen | `mobile/lib/presentation/screens/coach/coach_calendar_screen.dart` | Match | |
| CoachEarningsScreen | `mobile/lib/presentation/screens/coach/coach_earnings_screen.dart` | Match | |
| CoachProfileScreen | Not found | Missing | |
| CoachSettingsScreen | Not found | Missing | |
| ClientDetailScreen | `mobile/lib/presentation/screens/coach/coach_client_detail_screen.dart` | Partial | Verify parity vs React. |
| ClientPlanManager | Not found | Missing | |
| ClientReportGenerator | Not found | Missing | |
| WorkoutPlanBuilder | `mobile/lib/presentation/screens/coach/workout_plan_builder_screen.dart` | Partial | Verify parity vs React. |
| NutritionPlanBuilder | `mobile/lib/presentation/screens/coach/nutrition_plan_builder_screen.dart` | Partial | Verify parity vs React. |
| PublicCoachProfileScreen | `mobile/lib/presentation/screens/coach/public_coach_profile_screen.dart` | Match | |

## Admin Journey Screens
| React Screen | Flutter Screen | Status | Notes |
| --- | --- | --- | --- |
| AdminDashboard | `mobile/lib/presentation/screens/admin/admin_dashboard_screen.dart` | Match | |
| UserManagementScreen | `mobile/lib/presentation/screens/admin/admin_users_screen.dart` | Match | |
| CoachManagementScreen | `mobile/lib/presentation/screens/admin/admin_coaches_screen.dart` | Match | |
| ContentManagementScreen | Not found | Missing | |
| AnalyticsDashboard | `mobile/lib/presentation/screens/admin/admin_revenue_screen.dart` | Partial | Verify parity vs React analytics. |
| StoreManagementScreen | `mobile/lib/presentation/screens/admin/store_management_screen.dart` | Match | |
| SubscriptionManagementScreen | Not found | Missing | |
| SystemSettingsScreen | Not found | Missing | |
| AuditLogsScreen | `mobile/lib/presentation/screens/admin/admin_audit_logs_screen.dart` | Match | |

## Intro/Walkthrough Screens (React)
| React Screen | Flutter Screen | Status | Notes |
| --- | --- | --- | --- |
| AppIntroScreen | `mobile/lib/presentation/screens/intro/feature_intro_screen.dart` | Partial | Needs dedicated App Intro flow. |
| WorkoutIntroScreen | Not found | Missing | |
| NutritionIntroScreen | Not found | Missing | |
| StoreIntroScreen | Not found | Missing | |
| CoachIntroScreen | Not found | Missing | |

## Flutter-Only Screens (Extras)
| Flutter Screen | Status | Notes |
| --- | --- | --- |
| `mobile/lib/presentation/screens/auth/login_screen.dart` | Extra | React uses OTP auth only. |
| `mobile/lib/presentation/screens/auth/signup_screen.dart` | Extra | React uses OTP auth only. |
| `mobile/lib/presentation/screens/booking/appointment_detail_screen.dart` | Extra | No React equivalent found. |
| `mobile/lib/presentation/screens/video_call/video_call_screen.dart` | Extra | React uses video booking + calls inside coach screen. |
| `mobile/lib/presentation/screens/coach/coach_clients_screen.dart` | Extra | React coach dashboard may embed client list. |
| `mobile/lib/presentation/screens/coach/workout_plan_editor_screen.dart` | Extra | No React equivalent found. |
| `mobile/lib/presentation/screens/coach/nutrition_plan_editor_screen.dart` | Extra | No React equivalent found. |
| `mobile/lib/presentation/screens/profile/profile_edit_screen.dart` | Extra | Not in React as a standalone screen. |

## Notes for Step 2 Verification
- React SRS `docs/docs/03-SCREEN-SPECIFICATIONS.md` only includes screens 1-8.
- Use React components list as authoritative until SRS Part 2 is restored.
- Some Flutter screens may be placeholders; mark as Partial until verified.
