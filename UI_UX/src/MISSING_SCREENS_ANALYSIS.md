# FitCoach+ v2.0 - Missing Screens & Features Analysis

## 📋 EXECUTIVE SUMMARY

This document provides a comprehensive analysis of all missing screens and incomplete features across the three user types (User, Coach, Admin). Each section identifies gaps and provides implementation priority.

---

## 🏃 USER EXPERIENCE

### ✅ COMPLETE SCREENS
- Language Selection Screen
- App Intro Screen
- Auth Screen (Phone OTP, Email/Password, Social)
- First Intake Screen (3 questions)
- Second Intake Screen (Full questionnaire)
- Home Screen (Dashboard with stats)
- Basic Workout Screen (Plan view, exercise execution)
- Basic Nutrition Screen (Macro tracking)
- Basic Coach Screen (Messaging, booking)
- Store Screen (Product browsing, cart)
- Account Screen (Profile, Health Metrics with InBody)

### ❌ MISSING/INCOMPLETE SCREENS

#### 🔴 HIGH PRIORITY

1. **Enhanced CoachScreen Features**
   - **Missing**: QuotaDisplay integration for messages/calls
   - **Missing**: RatingModal trigger after call completion
   - **Missing**: File attachment UI (gated for Premium+ only)
   - **Missing**: Quota warning when approaching limits
   - **Missing**: Complete booking flow with calendar
   - **Files to modify**: `/components/CoachScreen.tsx`
   - **Dependencies**: QuotaDisplay.tsx ✅, RatingModal.tsx ✅

2. **Injury Substitution Interface (WorkoutScreen)**
   - **Missing**: "Report Injury" button during workout
   - **Missing**: Visual indicator showing swapped exercises
   - **Missing**: Alternative exercise selection dialog
   - **Missing**: Injury impact explanation
   - **Files to modify**: `/components/WorkoutScreen.tsx`
   - **Dependencies**: EnhancedExerciseDatabase.tsx ✅, injuryRules.ts ✅

3. **Meal Details & Food Logging (NutritionScreen)**
   - **Missing**: Individual meal detail screen
   - **Missing**: Recipe view with ingredients
   - **Missing**: Custom food logging interface
   - **Missing**: Meal swap/substitution feature
   - **Missing**: Interactive water tracking
   - **Files to create**: `/components/MealDetailScreen.tsx`, `/components/FoodLoggingDialog.tsx`
   - **Files to modify**: `/components/NutritionScreen.tsx`

#### 🟡 MEDIUM PRIORITY

4. **Product Detail Screen (StoreScreen)**
   - **Missing**: Full product details view
   - **Missing**: Product reviews display
   - **Missing**: Related products section
   - **Missing**: Add to cart from detail screen
   - **Files to create**: `/components/ProductDetailScreen.tsx`
   - **Files to modify**: `/components/StoreScreen.tsx`

5. **Checkout Flow (StoreScreen)**
   - **Missing**: Checkout screen with order summary
   - **Missing**: Shipping address form
   - **Missing**: Payment method selection
   - **Missing**: Order confirmation screen
   - **Files to create**: `/components/CheckoutScreen.tsx`, `/components/OrderConfirmationScreen.tsx`

6. **Order Tracking Detail (StoreScreen)**
   - **Missing**: Individual order detail screen
   - **Missing**: Shipment tracking timeline
   - **Missing**: Order actions (cancel, return)
   - **Files to create**: `/components/OrderDetailScreen.tsx`

7. **Progress Detail Screen (HomeScreen)**
   - **Missing**: Detailed progress charts
   - **Missing**: Weight/measurement history
   - **Missing**: Workout adherence calendar
   - **Missing**: Achievements/badges display
   - **Files to create**: `/components/ProgressDetailScreen.tsx`

#### 🟢 LOW PRIORITY

8. **Settings Screen (AccountScreen)**
   - **Missing**: Notification preferences
   - **Missing**: Privacy settings
   - **Missing**: App preferences (units, theme)
   - **Missing**: Language switcher
   - **Files to create**: `/components/SettingsScreen.tsx`

9. **Payment Management (AccountScreen)**
   - **Missing**: Payment methods list
   - **Missing**: Add/edit payment method
   - **Missing**: Billing history
   - **Missing**: Invoice downloads
   - **Files to create**: `/components/PaymentManagementScreen.tsx`

10. **Exercise Library Browser**
    - **Missing**: Full exercise database browser
    - **Missing**: Exercise search and filter
    - **Missing**: Favorite exercises
    - **Missing**: Custom exercise creation
    - **Files to create**: `/components/ExerciseLibraryScreen.tsx`

---

## 👨‍🏫 COACH EXPERIENCE

### ✅ COMPLETE SCREENS
- Coach Dashboard (Overview, clients list, appointments)
- Client Plan Manager (Basic workout plan assignment)
- Fitness Score Assignment Dialog

### ❌ MISSING/INCOMPLETE SCREENS

#### 🔴 HIGH PRIORITY

11. **Client Detail Screen**
    - **Missing**: Comprehensive client profile view
    - **Missing**: Progress charts and analytics
    - **Missing**: InBody history timeline
    - **Missing**: Workout completion history
    - **Missing**: Nutrition adherence tracking
    - **Missing**: Quick actions (message, call, assign plan)
    - **Files to create**: `/components/ClientDetailScreen.tsx`
    - **Files to modify**: `/components/CoachDashboard.tsx`

12. **Coach Messaging Interface**
    - **Missing**: Individual client chat screens
    - **Missing**: Message history with search
    - **Missing**: File sharing capability
    - **Missing**: Message templates/quick replies
    - **Files to create**: `/components/CoachMessagingScreen.tsx`
    - **Files to modify**: `/components/CoachDashboard.tsx`

13. **Workout Plan Builder**
    - **Missing**: Drag-and-drop plan creation
    - **Missing**: Exercise library integration
    - **Missing**: Template management (save/load plans)
    - **Missing**: Progressive overload automation
    - **Missing**: Plan preview before assignment
    - **Files to create**: `/components/WorkoutPlanBuilder.tsx`
    - **Files to modify**: `/components/ClientPlanManager.tsx`

#### 🟡 MEDIUM PRIORITY

14. **Nutrition Plan Builder**
    - **Missing**: Meal plan creation interface
    - **Missing**: Macro calculator
    - **Missing**: Recipe library
    - **Missing**: Client dietary restrictions consideration
    - **Missing**: Plan templates
    - **Files to create**: `/components/NutritionPlanBuilder.tsx`

15. **Schedule/Calendar Management**
    - **Missing**: Full calendar view
    - **Missing**: Session scheduling interface
    - **Missing**: Availability settings
    - **Missing**: Appointment reminders
    - **Missing**: Reschedule/cancel functionality
    - **Files to create**: `/components/CoachCalendarScreen.tsx`

16. **Client Progress Reports**
    - **Missing**: Generate progress reports
    - **Missing**: Custom date range selection
    - **Missing**: Export to PDF
    - **Missing**: Share with client
    - **Files to create**: `/components/ClientReportGenerator.tsx`

#### 🟢 LOW PRIORITY

17. **Coach Earnings Dashboard**
    - **Missing**: Revenue tracking
    - **Missing**: Payment history
    - **Missing**: Payout requests
    - **Missing**: Financial analytics
    - **Files to create**: `/components/CoachEarningsScreen.tsx`

18. **Coach Profile Settings**
    - **Missing**: Bio/credentials editing
    - **Missing**: Specialization tags
    - **Missing**: Availability schedule
    - **Missing**: Pricing settings
    - **Files to create**: `/components/CoachSettingsScreen.tsx`

---

## 👨‍💼 ADMIN EXPERIENCE

### ✅ COMPLETE SCREENS
- Admin Dashboard (Overview with stats)

### ❌ MISSING/INCOMPLETE SCREENS

#### 🔴 HIGH PRIORITY

19. **User Management Screen**
    - **Missing**: User search and filter
    - **Missing**: User detail view
    - **Missing**: Subscription modification
    - **Missing**: Account suspension/activation
    - **Missing**: User activity logs
    - **Files to create**: `/components/admin/UserManagementScreen.tsx`
    - **Files to modify**: `/components/AdminDashboard.tsx`

20. **Coach Management Screen**
    - **Missing**: Coach verification workflow
    - **Missing**: Coach approval/rejection
    - **Missing**: Coach performance analytics
    - **Missing**: Commission management
    - **Missing**: Coach suspension controls
    - **Files to create**: `/components/admin/CoachManagementScreen.tsx`

21. **Content Management**
    - **Missing**: Exercise database CRUD
    - **Missing**: Nutrition database management
    - **Missing**: Recipe management
    - **Missing**: Content approval workflow
    - **Files to create**: `/components/admin/ContentManagementScreen.tsx`

#### 🟡 MEDIUM PRIORITY

22. **Analytics Dashboard**
    - **Missing**: Revenue analytics
    - **Missing**: User growth charts
    - **Missing**: Engagement metrics
    - **Missing**: Subscription conversion funnel
    - **Missing**: Coach performance metrics
    - **Files to create**: `/components/admin/AnalyticsDashboard.tsx`

23. **Store Management**
    - **Missing**: Product CRUD operations
    - **Missing**: Inventory management
    - **Missing**: Order management
    - **Missing**: Vendor management
    - **Files to create**: `/components/admin/StoreManagementScreen.tsx`

24. **Subscription Management**
    - **Missing**: Plan configuration
    - **Missing**: Pricing management
    - **Missing**: Feature flags per tier
    - **Missing**: Promotional codes
    - **Files to create**: `/components/admin/SubscriptionManagementScreen.tsx`

#### 🟢 LOW PRIORITY

25. **System Settings**
    - **Missing**: App configuration
    - **Missing**: Email template management
    - **Missing**: Notification settings
    - **Missing**: API key management
    - **Files to create**: `/components/admin/SystemSettingsScreen.tsx`

26. **Audit Logs**
    - **Missing**: System activity logs
    - **Missing**: Admin action history
    - **Missing**: Security events
    - **Missing**: Log search and filter
    - **Files to create**: `/components/admin/AuditLogsScreen.tsx`

---

## 📊 IMPLEMENTATION PRIORITY MATRIX

### PHASE 1: Critical User Features (Week 1-2)
- [ ] Enhanced CoachScreen with quota/rating integration
- [ ] Injury substitution interface in WorkoutScreen
- [ ] Meal details & food logging in NutritionScreen
- [ ] Client Detail Screen for coaches
- [ ] Coach Messaging Interface

### PHASE 2: Core Coach & Store Features (Week 3-4)
- [ ] Workout Plan Builder for coaches
- [ ] Product Detail & Checkout Flow
- [ ] Order Tracking
- [ ] Nutrition Plan Builder for coaches
- [ ] Schedule/Calendar Management

### PHASE 3: Admin & Analytics (Week 5-6)
- [ ] User Management Screen
- [ ] Coach Management Screen
- [ ] Content Management
- [ ] Analytics Dashboard
- [ ] Store Management

### PHASE 4: Enhanced Features (Week 7-8)
- [ ] Progress Detail Screen
- [ ] Settings Screen
- [ ] Payment Management
- [ ] Client Progress Reports
- [ ] Coach Earnings Dashboard
- [ ] Exercise Library Browser

### PHASE 5: System & Admin Tools (Week 9-10)
- [ ] Subscription Management (admin)
- [ ] System Settings
- [ ] Audit Logs
- [ ] Coach Profile Settings
- [ ] Additional refinements

---

## 🛠️ TECHNICAL REQUIREMENTS

### New Component Files Needed: **26 new screens**

### Existing Files to Modify: **8 files**
1. `/components/CoachScreen.tsx`
2. `/components/WorkoutScreen.tsx`
3. `/components/NutritionScreen.tsx`
4. `/components/StoreScreen.tsx`
5. `/components/HomeScreen.tsx`
6. `/components/CoachDashboard.tsx`
7. `/components/AdminDashboard.tsx`
8. `/components/ClientPlanManager.tsx`

### New Translation Keys Needed: ~300-400 new keys

### State Management Considerations:
- Some screens will need shared state (shopping cart, messages)
- Consider Context providers for complex flows
- Workout/nutrition plan builders may need multi-step state

---

## 📝 NOTES

- All screens must maintain bilingual support (English/Arabic with RTL)
- All screens must respect subscription tier access controls
- All interactive elements must have loading states
- All forms must have validation
- All data displays must handle empty states gracefully
- Demo mode must work for all new screens

**Total Missing Screens: 26**
**Estimated Implementation Time: 8-10 weeks for complete implementation**
