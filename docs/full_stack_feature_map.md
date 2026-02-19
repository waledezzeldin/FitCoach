# FitCoach Full-Stack Feature Map (Frontend ↔ Backend ↔ DB)

Date: 2026-02-03

## Profiles (User / Coach / Admin)
- Frontend
  - User profile edit: mobile/lib/presentation/screens/profile/profile_edit_screen.dart
  - Account view: mobile/lib/presentation/screens/account/account_screen.dart
  - Coach profile: mobile/lib/data/repositories/coach_repository.dart (GET /coaches/:id/profile)
- Backend
  - GET /v2/users/me
  - PUT /v2/users/:id
  - GET /v2/coaches/:id/profile
  - Admin user management: GET/PUT /v2/admin/users
- DB
  - users (full_name, email, age, weight, height, gender, preferred_language, theme, subscription_tier)
  - coaches (coach profile fields)

## InBody (Manual + AI)
- Frontend
  - InBody entry + AI: mobile/lib/presentation/screens/inbody/inbody_input_screen.dart
  - Repository: mobile/lib/data/repositories/workout_repository.dart
- Backend
  - POST /v2/inbody
  - GET /v2/inbody, /v2/inbody/latest, /v2/inbody/:id
  - POST /v2/inbody/upload-image (AI extraction)
  - GET /v2/inbody/trends, /v2/inbody/progress, /v2/inbody/statistics
  - POST /v2/inbody/goals, GET /v2/inbody/goals/current
- DB
  - inbody_scans
  - inbody goals (if stored elsewhere)

## Progress Tracking
- Frontend
  - Progress screen: mobile/lib/presentation/screens/progress/progress_screen.dart
  - Repository: mobile/lib/data/repositories/progress_repository.dart
- Backend
  - GET/POST/PUT/DELETE /v2/progress
- DB
  - progress_entries

## Nutrition (Access + Generation + Coach Plans)
- Frontend
  - Nutrition screens: mobile/lib/presentation/screens/nutrition/**
  - Repository: mobile/lib/data/repositories/nutrition_repository.dart
  - Coach builder/editor: mobile/lib/presentation/screens/coach/nutrition_plan_builder_screen.dart
- Backend
  - GET /v2/nutrition/plan
  - POST /v2/nutrition/generate
  - POST /v2/nutrition/meals/:mealId/log
  - GET /v2/nutrition/history
  - GET /v2/nutrition/trial-status
  - Coach nutrition: GET/PUT /v2/coaches/:id/clients/:clientId/nutrition-plan
- DB
  - nutrition_plans, day_meal_plans, meals, food_items

## Store (User + Admin)
- Frontend
  - Store screens: mobile/lib/presentation/screens/store/**
  - Store provider: mobile/lib/presentation/providers/store_provider.dart
  - Admin store: mobile/lib/presentation/screens/admin/store_management_screen.dart
- Backend
  - Store catalog: GET /v2/store/products, /v2/store/products/:id
  - Reviews: GET/POST /v2/store/products/:id/reviews
  - Availability: POST /v2/store/products/:id/check-availability
  - Categories: GET /v2/store/categories
  - Promo: POST /v2/store/promo-codes/apply
  - Shipping: POST /v2/store/shipping/calculate
  - Orders: GET/POST /v2/orders, GET /v2/orders/:id, PUT/POST /v2/orders/:id/cancel, GET /v2/orders/:id/track
  - Admin products: POST/PUT/DELETE /v2/admin/products
- DB
  - products, product_reviews
  - orders, order_items

## Messaging
- Frontend
  - Messaging provider: mobile/lib/presentation/providers/messaging_provider.dart
  - Repository: mobile/lib/data/repositories/messaging_repository.dart
- Backend
  - GET /v2/messages/conversations
  - GET /v2/messages/conversations/:id/messages
  - DELETE /v2/messages/conversations/:id/messages
  - POST /v2/messages/send
  - POST /v2/messages/upload
  - PATCH /v2/messages/:id/read
  - Socket event: message:new
- DB
  - conversations, messages

## Video Calls
- Frontend
  - Video call provider: mobile/lib/presentation/providers/video_call_provider.dart
  - Video call screen: mobile/lib/presentation/screens/video_call/video_call_screen.dart
- Backend
  - POST /v2/video-calls/:appointmentId/start
  - GET /v2/video-calls/:appointmentId/token
  - POST /v2/video-calls/:appointmentId/end
  - GET /v2/video-calls/:appointmentId/can-join
  - GET /v2/video-calls/:appointmentId/status
- DB
  - appointments
  - video_call_sessions

## Subscriptions
- Frontend
  - Subscription manager/upgrade: mobile/lib/presentation/screens/subscription/**
  - Plan provider: mobile/lib/presentation/providers/subscription_plan_provider.dart
- Backend
  - Public plans: GET /v2/subscriptions/plans
  - Admin plans: GET/POST/PUT/DELETE /v2/admin/subscriptions/plans
  - Payments: POST /v2/payments/create-checkout, POST /v2/payments/cancel, GET /v2/payments/subscription
- DB
  - subscription_plans
  - subscriptions / subscription quotas (as configured)
