# Navigation Map - عاش (FitCoach+ v2.0)

## Document Information
- **Purpose**: Visual navigation flow reference for all user types
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Reference Guide

---

## Overview

This document provides a comprehensive navigation map showing how users flow through the عاش fitness application across all 28 screens.

---

## User Navigation Flow

### Onboarding & Authentication

```
Start
  ↓
Language Selection Screen
  ↓
App Intro Screen (3 slides)
  ├─→ Skip
  └─→ Next → Next → Next
      ↓
Phone OTP Auth Screen
  ├─→ Enter Phone
  └─→ Enter OTP
      ↓
  [New User?]
      ↓ Yes
First Intake Screen (3 questions)
      ↓
Home Screen (Dashboard)
```

### Main Navigation (Bottom Tab Bar)

```
┌─────────────────────────────────────────────┐
│  Home  │  Workout  │  Nutrition  │  Progress  │  Account  │
└─────────────────────────────────────────────┘
```

### Home Screen Connections

```
Home Screen
  ├─→ Start Workout → Workout Screen
  ├─→ View Nutrition → Nutrition Screen
  ├─→ Chat with Coach → Coach Messaging Screen
  ├─→ View Progress → Progress Screen
  ├─→ Visit Store → Store Screen
  ├─→ Upgrade Plan → Checkout Screen
  └─→ Profile Picture → Account Screen
```

### Workout Flow

```
Workout Screen
  ├─→ [First Time + No Second Intake?]
  │     ↓ Yes
  │   Second Intake Prompt Modal
  │     ├─→ Complete Profile → Second Intake Screen
  │     ├─→ Talk to Coach → Video Booking Screen
  │     └─→ Try Later → Continue to Workout
  │
  ├─→ Exercise Detail → Exercise Detail Screen
  ├─→ Show Alternative → Exercise substitution list
  ├─→ Start Timer → Workout Timer
  └─→ Complete Workout → Rating Modal
```

### Nutrition Flow

```
Nutrition Screen
  ├─→ [Freemium + No Trial Started?]
  │     ↓ Generate First Plan
  │   Start 7-Day Trial
  │   Show Expiry Banner
  │
  ├─→ [Freemium + Trial Expired?]
  │     ↓
  │   Upgrade Prompt → Checkout Screen
  │
  ├─→ Meal Detail → Meal Detail Screen
  ├─→ Log Food → Food Logging Dialog
  └─→ Generate New Plan → [Check access]
```

### Progress Flow

```
Progress Screen
  ├─→ Add Weight → Weight Entry Dialog
  ├─→ Add InBody [Premium+ Only] → InBody Input Screen
  ├─→ View Details → Progress Detail Screen
  └─→ View Achievements → Achievement List
```

### Messaging Flow

```
Coach Messaging Screen
  ├─→ [Quota Exceeded?]
  │     ↓ Yes
  │   Upgrade Prompt → Checkout Screen
  │
  ├─→ Send Message → [Check quota] → Increment usage
  ├─→ Attach File [Smart Premium Only] → File picker
  └─→ [Every 10 messages] → Rating Modal
```

### Store Flow

```
Store Screen
  ├─→ Category Filter → Filter products
  ├─→ Product Card → Product Detail Screen
  │     ├─→ Add to Cart → Update cart
  │     └─→ Buy Now → Checkout Screen
  │
  └─→ Cart Icon → Checkout Screen
      ├─→ Complete Purchase → Order Confirmation Screen
      └─→ View Order → Order Detail Screen
```

### Account Flow

```
Account Screen
  ├─→ Edit Profile → [Edit mode]
  ├─→ Second Intake → Second Intake Screen
  ├─→ Subscription → Subscription Manager
  │     └─→ Upgrade → Checkout Screen
  ├─→ Settings → Settings Screen
  │     ├─→ Language → Language Selection Screen
  │     └─→ Notifications → [Toggle settings]
  ├─→ Video Calls → Video Booking Screen
  └─→ Logout → Language Selection Screen
```

---

## Coach Navigation Flow

### Coach Entry

```
[Admin assigns Coach role]
  ↓
Home Screen → Toggle to Coach View
  ↓
Coach Intro Screen
  ↓
Coach Dashboard
```

### Coach Main Navigation

```
Coach Dashboard
  ├─→ View Clients → Client Detail Screen
  │     ├─→ Create Plan → Workout Plan Builder
  │     │                 OR
  │     │                 Nutrition Plan Builder
  │     ├─→ View Progress → Client stats
  │     └─→ Message Client → Coach Messaging Screen
  │
  ├─→ Calendar → Coach Calendar Screen
  │     ├─→ View Appointments
  │     └─→ Set Availability
  │
  ├─→ Messages → Coach Messaging Screen
  │     └─→ Reply to Client
  │
  ├─→ Profile → Coach Profile Screen
  │     └─→ Edit Profile
  │
  └─→ Settings → Coach Settings Screen
      └─→ Preferences
```

### Coach Plan Creation Flow

```
Workout Plan Builder
  ├─→ Select Days
  ├─→ Add Exercises → Exercise Database
  ├─→ Set Sets/Reps
  ├─→ Check for Injuries → [Auto-detect contraindications]
  └─→ Save Plan → Assign to Client

Nutrition Plan Builder
  ├─→ Set Calories/Macros
  ├─→ Add Meals → Meal Database
  ├─→ Configure Substitutions
  └─→ Save Plan → Assign to Client
```

---

## Admin Navigation Flow

### Admin Entry

```
[Super Admin creates Admin account]
  ↓
Home Screen → Admin Access
  ↓
Admin Dashboard
```

### Admin Main Navigation

```
Admin Dashboard
  ├─→ User Management → User Management Screen
  │     ├─→ View Users
  │     ├─→ Edit Subscription
  │     ├─→ Suspend User
  │     └─→ View Activity Log
  │
  ├─→ Coach Management → Coach Management Screen
  │     ├─→ View Coaches
  │     ├─→ Add Coach
  │     ├─→ Edit Coach Profile
  │     ├─→ View Ratings
  │     └─→ Deactivate Coach
  │
  ├─→ Content Management → Content Management Screen
  │     ├─→ Exercises Tab
  │     │     ├─→ Add Exercise
  │     │     ├─→ Edit Exercise
  │     │     └─→ Mark Contraindications
  │     │
  │     └─→ Meals Tab
  │           ├─→ Add Meal
  │           ├─→ Edit Meal
  │           └─→ Set Nutritional Info
  │
  ├─→ Store Management → Store Management Screen
  │     ├─→ Products
  │     │     ├─→ Add Product
  │     │     └─→ Edit Product
  │     │
  │     └─→ Orders
  │           ├─→ View Orders
  │           └─→ Update Status
  │
  ├─→ Subscription Management → Subscription Management Screen
  │     ├─→ View Plans
  │     ├─→ Edit Pricing
  │     └─→ View Subscribers
  │
  ├─→ Analytics → Analytics Dashboard
  │     ├─→ User Metrics
  │     ├─→ Revenue Charts
  │     └─→ Engagement Stats
  │
  ├─→ System Settings → System Settings Screen
  │     ├─→ Feature Flags
  │     ├─→ Configuration
  │     └─→ Email Templates
  │
  └─→ Audit Logs → Audit Logs Screen
        └─→ View System Activity
```

---

## Cross-Cutting Flows

### Upgrade Flow (Any Tier)

```
[Feature Gated or Quota Exceeded]
  ↓
Upgrade Prompt Modal
  ├─→ View Plans
  ├─→ Select Plan (Premium or Smart Premium)
  └─→ Checkout Screen
      ├─→ Payment Success → Subscription Manager
      └─→ Payment Failed → [Retry or Cancel]
```

### Rating Flow

```
[Trigger: After Video Call OR Every 10 Messages]
  ↓
Rating Modal
  ├─→ 1-5 Stars
  ├─→ Optional Feedback (text)
  └─→ Submit
      ↓
  [Save to coach_ratings table]
  Update Coach Average Rating
```

### Second Intake Flow

```
[Trigger: First Workout Access + No Second Intake]
  ↓
Second Intake Prompt Modal
  ├─→ "Complete Profile Now"
  │     ↓
  │   Second Intake Screen (6 questions)
  │     ├─→ Age, Weight, Height
  │     ├─→ Experience Level
  │     ├─→ Workout Frequency
  │     └─→ Injuries
  │         ↓
  │   Calculate Fitness Score
  │   Save to Database
  │   Return to Workout Screen
  │
  ├─→ "Talk to My Coach"
  │     ↓
  │   [Check Video Call Quota]
  │     ├─→ Available → Video Booking Screen
  │     └─→ Exceeded → Upgrade Prompt
  │
  └─→ "Try Later"
      ↓
  Increment Deferral Count
  [Show again if count < 3]
  Proceed to Workout Screen
```

---

## Modal & Overlay Flows

### Modals in Application

1. **Second Intake Prompt Modal**
   - Trigger: First workout access
   - Actions: Complete profile, Talk to coach, Try later

2. **Rating Modal**
   - Trigger: After video call OR every 10 messages
   - Actions: Rate 1-5 stars, Add feedback, Submit

3. **Upgrade Prompt Modal**
   - Trigger: Feature gated or quota exceeded
   - Actions: View plans, Select plan, Cancel

4. **Food Logging Dialog**
   - Trigger: Log meal button
   - Actions: Search food, Add portions, Save log

5. **Weight Entry Dialog**
   - Trigger: Add weight button
   - Actions: Enter weight, Select date, Save

6. **Nutrition Expiry Banner**
   - Trigger: Freemium user with ≤3 days remaining
   - Actions: Upgrade now, Dismiss

---

## Navigation Patterns

### Bottom Navigation (User View)

```
Always Visible (except during Onboarding):
┌─────────────────────────────────────────────┐
│  [Home] [Workout] [Nutrition] [Progress] [Account]  │
└─────────────────────────────────────────────┘
```

### Top Navigation (Coach/Admin View)

```
[Logo/Title]  [Navigation Links]  [Profile Menu]
```

### Back Navigation

- **Physical Back Button (Mobile)**: Navigates to previous screen
- **Header Back Button**: Appears on detail screens
- **Breadcrumbs (Admin)**: Shows navigation path

---

## State Transitions

### User Status States

```
New User
  ↓ Complete Phone Auth
Authenticated (No Intake)
  ↓ Complete First Intake
Active User (Basic Profile)
  ↓ Complete Second Intake
Active User (Full Profile)
  ↓ Subscribe to Premium
Premium User
  ↓ Upgrade to Smart Premium
Smart Premium User
```

### Nutrition Access States (Freemium)

```
No Trial Started
  ↓ Generate First Plan
Trial Active (Day 1-7)
  ├─→ [Day 5-7] Show Expiry Banner
  └─→ [Day 7] Trial Expired
      ↓
Nutrition Locked
  ↓ Upgrade to Premium
Unlimited Access
```

### Quota States

```
Within Quota
  ↓ Use Feature (Message/Call)
Low Quota (≤25% remaining)
  ├─→ Show Warning Banner
  └─→ Continue Using
      ↓
Quota Exceeded (0 remaining)
  ↓
Feature Locked
  ├─→ Wait for Monthly Reset
  └─→ OR Upgrade to Higher Tier
```

---

## Screen Inventory by Category

### Onboarding (3 screens)
1. Language Selection Screen
2. App Intro Screen
3. Phone OTP Auth Screen

### User Core (9 screens)
4. First Intake Screen
5. Second Intake Screen
6. Home Screen
7. Workout Screen
8. Nutrition Screen
9. Coach Messaging Screen
10. Store Screen
11. Progress Screen
12. Account Screen

### User Detail Screens (6 screens)
13. Exercise Detail Screen
14. Meal Detail Screen
15. Product Detail Screen
16. Order Confirmation Screen
17. Order Detail Screen
18. Progress Detail Screen

### User Supporting Screens (3 screens)
19. Exercise Library Screen
20. Video Booking Screen
21. Checkout Screen

### Coach Screens (6 screens)
22. Coach Dashboard
23. Coach Calendar Screen
24. Workout Plan Builder
25. Nutrition Plan Builder
26. Coach Profile Screen
27. Coach Settings Screen

### Admin Screens (8 screens)
28. Admin Dashboard
29. User Management Screen
30. Coach Management Screen
31. Content Management Screen
32. Store Management Screen
33. Subscription Management Screen
34. Analytics Dashboard
35. System Settings Screen
36. Audit Logs Screen

**Total**: 35 screens (includes intro/welcome screens)
**Core App**: 28 screens (documented in main specifications)

---

## Deep Linking & External Entry Points

### Deep Link Patterns

```
fitcoach://workout/{workoutId}
fitcoach://nutrition/{planId}
fitcoach://store/product/{productId}
fitcoach://coach/{coachId}
fitcoach://video/booking/{callId}
```

### External Entry (Push Notifications)

```
Notification Received
  ├─→ "New message from coach" → Coach Messaging Screen
  ├─→ "Workout reminder" → Workout Screen
  ├─→ "Nutrition plan ready" → Nutrition Screen
  ├─→ "Video call in 15 min" → Video Booking Screen
  └─→ "Order shipped" → Order Detail Screen
```

---

## Navigation Guard Rules

### Authentication Guards

- **Requires Auth**: All screens except Language Selection, App Intro, Phone OTP Auth
- **Requires First Intake**: Home Screen and beyond
- **Requires Second Intake**: None (optional, prompted at first workout)

### Role-Based Guards

- **Coach Screens**: Requires `userRole = 'coach'`
- **Admin Screens**: Requires `userRole = 'admin'`

### Tier-Based Guards

- **Second Intake**: Available to ALL users (updated v2.0)
- **InBody Tracking**: Requires Premium or Smart Premium
- **Chat Attachments**: Requires Smart Premium
- **Unlimited Messages**: Requires Smart Premium

---

**Total Screens**: 28 core + 7 intro/welcome = 35 screens
**Navigation Complexity**: Medium-High (role-based + tier-based gating)

**End of Navigation Map**
