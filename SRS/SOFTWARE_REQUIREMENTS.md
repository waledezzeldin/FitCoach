# FitCoach - Software Requirements Document (SRD)
**Version:** 1.0.0  
**Date:** October 29, 2025  
**Status:** Current Production Version

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [System Overview](#system-overview)
3. [Core Features](#core-features)
4. [User Experience - Regular User](#user-experience---regular-user)
5. [User Experience - Coach](#user-experience---coach)
6. [User Experience - Admin](#user-experience---admin)
7. [Technical Specifications](#technical-specifications)
8. [Data Models](#data-models)
9. [Internationalization](#internationalization)
10. [Demo Mode](#demo-mode)
11. [Future Considerations](#future-considerations)

---

## Executive Summary

FitCoach is a comprehensive fitness web application designed to provide personalized workout plans, nutrition tracking, and direct coach support. The application supports three distinct user types (Regular Users, Coaches, and Admins) and features full bilingual support (English and Arabic with RTL layout). The current version includes a complete demo authentication system, subscription management, and advanced workout tracking capabilities.

### Key Statistics
- **User Types:** 3 (Regular User, Coach, Admin)
- **Subscription Tiers:** 3 (Freemium, Premium, Smart Premium)
- **Supported Languages:** 2 (English, Arabic with RTL)
- **Total Screens:** 15+ distinct screens and interfaces
- **Translation Coverage:** 100% (670+ translation keys)

---

## System Overview

### 2.1 Application Architecture

FitCoach is built as a single-page application (SPA) using React with TypeScript. The application follows a component-based architecture with centralized state management and context-based internationalization.

**Main Application Flow:**
```
App.tsx (Root)
  ├── LanguageProvider (Context)
  └── AppContent
      ├── Language Selection Screen (First Time)
      ├── App Intro Screen (First Time)
      ├── Authentication Screen
      ├── Onboarding Screen (New Users Only)
      └── Main Application
          ├── Home/Dashboard (Role-based)
          ├── Workout System
          ├── Nutrition System (Premium+)
          ├── Coach Communication
          ├── Store
          └── Account Management
```

### 2.2 User Type Definitions

#### Regular User
- Primary end-user who consumes fitness content
- Can subscribe to different tiers
- Completes onboarding to create personalized profile
- Access based on subscription level

#### Coach
- Professional fitness coach managing clients
- Has dedicated dashboard for client management
- Can create workout and nutrition plans
- Manages sessions and communications
- Always has Smart Premium access

#### Admin
- System administrator with full access
- Manages users, coaches, and content
- Views analytics and system statistics
- Controls subscription plans and store inventory
- Always has Smart Premium access

### 2.3 Subscription Tiers

| Feature | Freemium | Premium | Smart Premium |
|---------|----------|---------|---------------|
| **Price** | Free | $19.99/month | $39.99/month |
| **Workout Plans** | 2-week cycle | 4-week cycle | Adaptive AI plans |
| **Nutrition Access** | ❌ | ✅ | ✅ |
| **Meal Personalization** | ❌ | Basic preferences | AI-powered |
| **Coach Messages** | 20/month | 200/month | Unlimited |
| **Video Sessions** | 1/month | 2/month | 4/month |
| **Chat Attachments** | Not available | Available | Available |
| **Nutrition Access** | 7-day rolling window | Persistent | Persistent |
| **Analytics** | Basic | Enhanced summaries | Detailed insights |

---

## Core Features

### 3.1 Authentication System

**Phone-First Flow:**
- Primary entry point uses an E.164 phone field plus OTP verification.
- OTP input supports resend, retry limits, and cooldown indicators.
- Phone number determines demo persona:
  - `+966507654321` → Coach dashboard
  - `+966509876543` → Admin dashboard
  - Any other valid number → Regular user journey

**Email & Social Fallbacks:**
- Email/password form remains available (with password visibility toggle) for both sign-in and sign-up.
- Demo personas can still be triggered via `coach@fitcoach.com` and `admin@fitcoach.com`, while any other email provisions a user account.
- Mock social providers (Google, Facebook, Apple) immediately succeed and route to the user experience.

**Additional Features:**
- OTP and phone forms validate format and readiness before submission.
- Forgot password link (non-functional placeholder) and demo credentials helper text remain visible.
- Demo mode can also be triggered without credentials by long-pressing the logo for >2 seconds or pressing **Try Demo Mode**, which immediately authenticates and marks the session as demo in `localStorage`.

### 3.2 Multi-Language System

**Supported Languages:**
- English (en) - LTR
- Arabic (ar) - RTL with full bidirectional support

**Translation Coverage:**
- 670+ translation keys
- 100% coverage across all screens
- Dynamic RTL layout switching
- Translated content includes:
  - UI labels and buttons
  - Exercise names
  - Food items
  - Cuisine types
  - Equipment names
  - Demo data content
  - Error messages and notifications

**Language Selection:**
- Initial selection screen on first launch
- Persisted language preference
- Changeable from Account Settings
- Real-time UI direction switching (LTR/RTL)

### 3.3 Demo Mode

**Activation Methods:**
1. Click "Try Demo Mode" button on auth screen
2. Long press app logo for 2+ seconds

**Demo Mode Features:**
- Persistent indicator badge
- Pre-populated realistic data
- All features functional
- Different demo profiles for each user type:
  - **User Demo:** Mina H., 28, Freemium tier
  - **Coach Demo:** Sarah Johnson, 32, Smart Premium
  - **Admin Demo:** Admin User, 30, Smart Premium

**Demo Data Includes:**
- Workout history
- Nutrition logs
- Coach messages
- Store cart items
- Client data (for coaches)
- System statistics (for admins)

---

## User Experience - Regular User

### 4.1 Initial User Journey

#### Language Selection Screen
**Purpose:** First-time language preference capture

**Features:**
- Large, prominent language buttons (English/Arabic)
- Bilingual labels showing both languages
- "Change later" notice in both languages
- Clean, welcoming design
- Persistent selection (saved to localStorage)

#### App Intro Screen
**Purpose:** Introduce app value proposition

**Features:**
- Welcome message: "Welcome to FitCoach"
- Tagline: "Your Personal Fitness Journey Starts Here"
- Three key features highlighted:
  1. **Custom Workouts** - Tailored to fitness level and goals
  2. **Nutrition Plans** - Personalized meal planning and macro tracking
  3. **Expert Coaches** - Direct access to certified professionals
- "Get Started" CTA button
- Shown once per device/session

#### Authentication Screen
**Components:**
- Entry picker between Phone (default) and Email flows.
- Phone mode includes a country picker, validation, OTP request, and OTP input with retry logic.
- Email mode supports sign-in and sign-up (Full Name, Email, Password, Confirm Password) plus a password visibility toggle.
- Social auth shortcuts (Google, Facebook, Apple) and a "Forgot password" placeholder link.
- Demo helpers: credentials legend and **Try Demo Mode** button.

#### Two-Stage Onboarding Flow
**Purpose:** Capture lightweight preferences quickly, then gather deeper metrics when the user is ready.

**Stage 1 – First Intake (3 Steps):**
1. **Gender** – Radio buttons (Male/Female/Other) with contextual cues.
2. **Primary Goal** – Fat Loss, Muscle Gain, or General Fitness, each with descriptive subtitles.
3. **Workout Location** – Home vs. Gym selection with guidance copy.

Completion immediately provisions a Freemium profile and unlocks the home experience; users can return later to finish the detailed intake.

**Stage 2 – Second Intake (5 Steps):**
1. **Age** – Numeric field with validation (13–120).
2. **Body Metrics** – Weight (kg) and Height (cm) capture.
3. **Experience Level** – Beginner / Intermediate / Advanced, each describing expectations.
4. **Workout Frequency** – Select 2–6 sessions per week via dropdown.
5. **Injuries & Restrictions** – Checkbox list (shoulder, knee, lower back, neck, ankle) with "None" state indicator.

Additional Behaviors:
- A progress header shows "Step X / 5" and renders contextual icons per stage.
- Second intake can be invoked from workouts, account, or upgrade flows; the system remembers the previous screen and returns the user there after completion.
- Completing Stage 2 updates fitness score baselines (unless a coach has overridden them) and stores timestamps for future analytics.

### 4.2 Home Screen

**Header Section:**
- Personalized greeting: "Hello, [First Name]! 👋"
- Subtitle: "Ready for today's workout?"
- User avatar button (navigates to Account)
- Subscription tier badge

**Statistics Cards (3 columns):**

1. **Calories Burned**
   - Fire icon
   - Total calories burned
   - Today's addition indicator
   - Example: "2850" with "+340 Today"

2. **Calories Consumed**
   - Apple icon
   - Consumed vs goal
   - Format: "1950 / 2200"

3. **Plan Adherence**
   - Target icon
   - Percentage completion
   - Streak counter (e.g., "🔥 5 days")

**Weekly Progress Bar:**
- Progress percentage
- Workouts completed / total (e.g., "12/14 workouts")
- "This week" label

**Today's Workout Card:**
- Workout name
- Duration estimate
- Exercise count
- Calendar badge showing "Today"
- "Start Workout" CTA button

**Navigation Grid (2x2):**

1. **Workouts** (Blue)
   - Dumbbell icon
   - "Personalized workout plans"
   - Always accessible

2. **Nutrition** (Green)
   - Apple icon
   - "Track your meals"
   - Locked for Freemium users
   - Shows "Premium" badge when locked

3. **Coach** (Purple)
   - Message icon
   - "Connect with your coach"
   - Notification badge if unread messages
   - Always accessible

4. **Store** (Orange)
   - Shopping bag icon
   - "Supplements & gear"
   - Always accessible

**Recent Activity Feed:**
- Chronological list of recent actions:
  - Completed workouts with calorie count
  - Coach messages (with "New" badge)
  - Progress updates
- Timestamp display (e.g., "2 hours ago")
- Color-coded activity indicators

**Premium Upgrade CTA (Freemium Users Only):**
- Purple gradient background
- Crown icon
- "Unlock Premium Features" headline
- Benefits list:
  - ✨ Personalized nutrition plans
  - 💬 Unlimited coach messages
  - 📊 Advanced analytics
- "Upgrade Now" button with crown icon
- Opens Subscription Manager

### 4.3 Workout Screen

#### Overview Mode (Default View)

**Header:**
- Back navigation to Home
- Workout title
- Week and Day indicators
- Duration and difficulty badges

**Workout Statistics:**
- Total exercises
- Estimated duration
- Muscle groups targeted
- Difficulty level

**Exercise List:**
Each exercise card displays:
- Exercise name (translated)
- Muscle group badge
- Sets x Reps format
- Rest time
- Status indicator:
  - ✓ Completed (green)
  - "Swapped" badge if substituted
  - In progress (blue)
  - Not started (gray)
- Logged sets count (e.g., "3/4 logged")
- Quick action buttons:
  - "Start" / "Continue"
  - "Review" (if completed)
  - Eye icon (view details)

**Exercise Actions:**
- Tap exercise card to enter Exercise Detail Screen
- Swipe gestures for quick actions
- Long press for additional options

#### Exercise Mode (During Workout)

**Active Exercise Display:**
- Large exercise name
- Current set indicator (e.g., "Set 2 of 4")
- Timer display (rest or active)
- Instructions and cues

**Set Logging Interface:**
- Weight input (kg)
- Reps completed input
- Optional time input (for timed exercises)
- "Log Set" button
- Previous set reference
- Auto-start rest timer after logging

**Rest Timer:**
- Countdown display
- Pause/Resume controls
- Skip rest option
- Audio/visual alert when complete
- Background: Changes color based on time remaining

**Navigation:**
- "Next Exercise" button
- "Previous Exercise" button
- "Finish Workout" button (on last exercise)
- Exit workout (with confirmation)

**Session Tracking:**
- Total workout time
- Calories burned estimate
- Sets completed counter
- Exercises remaining

#### Exercise Detail Screen

**Video Demo Section:**
- Placeholder for exercise video
- "Watch Video" button
- Video player controls

**Exercise Overview Card:**
- Sets, Reps, Rest time
- Difficulty level
- Equipment needed (translated)
- Primary and secondary muscle groups

**Step-by-Step Instructions:**
- Numbered list of movement steps
- Clear, concise descriptions
- Safety notes highlighted

**Key Cues Section:**
- Form tips
- Breathing cues
- Common mistakes to avoid

**Exercise Swap Feature:**
- "Swap Exercise" button
- Alternative exercises list
- Filtered by:
  - Same muscle group
  - Similar difficulty
  - Available equipment
  - User's injury restrictions
- One-tap swap confirmation
- Original exercise saved for reference

**First-Time Overlay:**
Shown on first exercise:
1. Watch the video tutorial
2. Review form and technique
3. Start your set
4. Log your reps after each set
"Got it" button to dismiss

### 4.4 Nutrition Screen

#### Access Control
**Freemium Users:**
- Full-screen lock state with hero illustration, feature callouts, and CTA to open the Subscription Manager.
- Highlights Premium/Smart Premium perks (personalized macros, custom meal suggestions, macro analytics) and clarifies that Freemium nutrition expires after a 7-day window.
- Upgrade button writes `pending_nutrition_intake_{phone}` to `localStorage`, ensuring the welcome flow appears immediately after upgrade.

**Premium/Smart Premium Users:**
- If a pending intake flag exists, users see a welcome screen before the main tabs.
- Completed preferences persist per phone number and can be edited via the settings icon in the header.

#### Initial Setup Flow (First Access)
**Welcome Screen:**
- "Welcome to Nutrition!" headline
- Explanation of nutrition features
- Three key benefits highlighted
- "Start Nutrition Setup" button
- Leads to Nutrition Preferences Intake

#### Nutrition Preferences Intake (Current Flow)

**Step 1: Proteins & Allergies**
- Dual-grid layout where users pick preferred protein sources (chicken, beef, tuna, shrimp, salmon, eggs, beans, tofu) and flag any allergies using the same set.
- Cards toggle color states for quick visual feedback.

**Step 2: Dinner Habits**
- Radio groups capture portion size (light/moderate/filling), prep speed (quick/normal/prep-ahead), and carb level (no carb/low carb/includes carbs).
- Cuisine chips (Egyptian, Arabic, Mediterranean, Asian, Western, Indian) and avoidance chips (spicy, fried, dairy, gluten, seafood, nuts, shellfish) enable multi-select preferences.

**Step 3: Restrictions & Notes**
- Repeats the avoidance chips for final confirmation, then exposes a free-text note box (e.g., "Prefer lighter dinners during weekdays").
- Completion persists the answers under `nutrition_preferences_{phone}` and marks the intake as finished so the user jumps straight into the Today tab next time.

**Setup Completion:**
- Success message
- Loading state: "Personalizing your meal plan..."
- Transitions to main Nutrition Screen

#### Main Nutrition Screen (Post-Setup)

**Tab Navigation:**
- Today (default)
- Meal Plans
- Macros

**"Today" Tab:**

*Daily Progress Section:*
- Circular progress indicators for:
  - Calories (e.g., 1840/2400)
  - Protein (120g/150g)
  - Carbs (180g/300g)
  - Fats (65g/80g)
- Water intake tracker
  - Current: 2200ml / 3000ml
  - "+250ml" quick add buttons

*Meal Log:*
Each meal card shows:
- Meal type icon and name
- Time
- Foods listed with serving sizes
- Macro breakdown
- Total calories
- "Add Food" button

**Breakfast Example:**
- 🍳 Breakfast
- 7:30 AM
- Oatmeal with Blueberries (1 cup)
  - 300 cal | 12g P | 54g C | 6g F
- Greek Yogurt (150g)
  - 100 cal | 15g P | 8g C | 2g F
- Total: 400 calories

**Food Logging Modal:**
- Search bar
- Recent foods
- Favorite foods
- Serving size input
- Macro preview
- "Add to [Meal]" button

**"Meal Plans" Tab:**

*Weekly Meal Plan Calendar:*
- 7-day view
- Each day shows:
  - Breakfast, Lunch, Dinner, Snacks
  - Total daily calories
  - Macro distribution
- Tap to view meal details
- Swap meal option
- Mark as prepared

*Meal Recommendations:*
- AI-generated suggestions (Smart Premium)
- Based on preferences and goals
- Nutrition information
- Preparation instructions
- Ingredient list
- "Add to Plan" button

**"Macros" Tab:**

*Target Overview:*
- Daily macro targets
- Based on user goals
- Editable targets (manual override)

*Weekly Progress Graph:*
- 7-day adherence chart
- Calories consumed vs target
- Protein intake trend
- Days on track indicator
- Average adherence percentage

*Nutrition Insights:*
- Recommendations based on patterns
- Example: "You're 30g short of protein target"
- Suggestions: "Try adding protein shake"
- Hydration status
- Adherence trends

**Action Buttons:**
- "Log Food" (quick access)
- "Add Water" (250ml increments)
- "Edit Preferences" (returns to intake form)

### 4.5 Coach Screen

**Coach Profile Card:**
- Avatar placeholder
- Name: "Sara A."
- Specialties: Strength Training, Weight Loss, Nutrition
- Rating: ⭐ 4.9
- Years of experience: 8 years

**Tab Navigation:**
- Messages (default)
- Sessions

#### Messages Tab

**Usage Indicator:**
- Progress bar showing messages used
- Text: "3/15 messages used this month" (Premium)
- Text: "Unlimited messages" (Smart Premium)
- Warning if limit approaching (Freemium)

**Message Thread:**
- Chronological conversation view
- Message bubbles:
  - Coach messages: Left-aligned, blue
  - User messages: Right-aligned, gray
- Timestamp display
  - "Today"
  - "Yesterday"
  - Date for older messages
- Avatar for coach messages

**Example Message:**
```
Coach: "Hi Mina! Great job on completing your workout 
yesterday. I noticed you increased the weight on your 
bench press. How did it feel?"
[2 hours ago]
```

**Message Composition:**
- Text input field
- Placeholder: "Type your message..."
- Send button
- Disabled if message limit reached
- Character counter (optional)

**Message Limit Handling:**
- Alert for Freemium users: "You've reached your monthly message limit"
- "Upgrade for more messages" button
- Soft lock on input field

**Auto-Reply System:**
- Simulated coach response
- 2-second delay
- Demo message: "Thanks for your message! I'll get back to you shortly..."

#### Sessions Tab

**Usage Indicator:**
- Sessions used: "1/4 sessions used" (Premium)
- "4 remaining this month"

**Book Video Session:**
- Calendar picker
- Available time slots
- Duration selection (30/45/60 minutes)
- "Book Session" button
- Confirmation dialog

**Session Limit Modal:**
- Shown when limit reached
- "Session Limit Reached" title
- Current plan limitation explained
- "Upgrade your subscription" button
- Comparison of session limits across tiers

**Upcoming Sessions:**
Each session card shows:
- Date and time
- Duration
- Status badge:
  - Pending (yellow)
  - Approved (green)
  - Completed (gray)
  - Rejected (red)
- Action buttons:
  - "Join" (when time arrives, approved sessions)
  - "Reschedule"
  - "Cancel"

**Past Sessions:**
- Scrollable list
- Date completed
- Duration
- Notes from coach (if any)
- "View Summary" option

**Empty State:**
- "No sessions booked yet"
- Illustration
- "Book your first video session above!" message

### 4.6 Store Screen

**Tab Navigation:**
- Products (default)
- Cart
- Orders

#### Products Tab

**Search & Filter Bar:**
- Gradient header contains a single search input with an inline icon; results filter live as the user types.
- Category filtering is handled via horizontally scrollable chips (All, Protein, Pre-Workout, Recovery, Vitamins, Fat Burners). There is no separate sort dropdown in the current build.

**Category Chips:**
- Chip list mirrors the categories above; selecting a chip immediately refines the product grid.

**Product Grid (2 columns):**
Each product card:
- Product image placeholder
- Brand name
- Product name
- Star rating (e.g., ⭐ 4.8)
- Review count (1,247 reviews)
- Price display:
  - Original price (strikethrough if discounted)
  - Current price (bold)
  - Discount percentage badge
  - Subscriber discount applied: "Premium: -10%" / "Smart Premium: -20%"
- "Add to Cart" button
  - Shows quantity selector if already in cart
  - "Out of Stock" badge if unavailable
- "Popular" badge for trending items

**Example Products:**
1. Whey Protein Isolate - $59.99 (was $69.99)
2. Resistance Bands Set - $29.99
3. Yoga Mat Premium - $39.99
4. BCAA Powder - $34.99
5. Pre-Workout Energy - $44.99
6. Omega-3 Fish Oil - $24.99

**Product Detail View (Tap product):**
- Large product image
- Full description
- Nutrition facts (supplements)
- Ingredients list
- Customer reviews section
- Quantity selector
- "Add to Cart" button
- Related products section

**Empty State:**
- "No products found"
- "Try adjusting your search or filter"

#### Cart Tab

**Cart Summary Header:**
- Items count: "3 items in cart"
- Estimated total

**Cart Items List:**
Each item shows:
- Product thumbnail
- Product name and brand
- Price per unit
- Quantity controls (-, count, +)
- Subtotal
- Remove button (trash icon)

**Pricing Breakdown:**
- Subtotal: running total of items in cart.
- Shipping: Displayed as "Free" in the current build (no tier-based discounting yet).
- **Total:** Mirrors the subtotal because discounts and tax are not applied inside the cart view.

**Action Buttons:**
- "Continue Shopping"
- "Proceed to Checkout" (primary button). In demo mode this instantly creates a mock order and shows confirmation without entering checkout details.

**Empty Cart State:**
- Shopping cart illustration
- "Your cart is empty"
- "Add some products to get started"
- "Browse Products" button

#### Orders Tab

**Order History List:**
Each order card shows:
- Order number: "#ORD-2024-1234"
- Order date
- Status badge:
  - Processing (blue)
  - Shipped (orange)
  - Delivered (green)
- Items count: "3 items"
- Total amount: $134.98
- "View Details" button

**Order Details View:**
- Displays item list, shipping address, masked payment method, optional tracking number, and a vertical status timeline.
- Action row currently supports tracking lookups and cancelation (when processing). Reorder and invoice download buttons are not implemented in this UI build.

**Empty State:**
- Package illustration
- "No orders yet"
- "Your order history will appear here"
- "Browse Products" button

### 4.7 Account Screen

**Tab Navigation:**
- Profile (default)
- Subscription
- Settings
- Support

#### Profile Tab

**Profile Header:**
- Large avatar placeholder
- Name display
- Email address
- Edit button (toggles edit mode)

**Personal Information Card:**
*View Mode:*
- Age: 28 Years
- Weight: 78 kg
- Height: 178 cm
- Gender: Male
- BMI: Auto-calculated
- Edit button

*Edit Mode:*
- Editable input fields
- Save Changes button
- Cancel button
- Form validation

**Fitness Profile Card:**
- Main Goal: Muscle Gain
- Experience Level: Intermediate
- Workout Location: Gym
- Workout Frequency: 4 days per week
- Current Injuries: Lower Back Pain
- "Update Fitness Goals" button

#### Subscription Tab

**Current Plan Card:**
- Large tier badge (Freemium/Premium/Smart Premium)
- Monthly price
- Status: "Active" badge
- Renewal date: "Your subscription renews on Nov 28, 2025"
- Feature list with checkmarks
- Limitations list (Freemium only)

**Available Plans Section:**
- Comparison cards for all three tiers
- "Popular" badge on Premium
- "Best Value" badge on Smart Premium
- "Current Plan" badge on active tier
- "Change Plan" / "Upgrade" buttons
- Opens Subscription Manager

**Billing History:**
- Past invoices list
- Date, amount, status
- Download invoice button

#### Settings Tab

**Language Settings:**
- Current language indicator
- Language switcher:
  - English
  - العربية (Arabic)
- Real-time UI direction update

**Notification Preferences:**

*Workout Reminders:*
- Toggle switch
- "Get notified about upcoming workouts"

*Coach Messages:*
- Toggle switch
- "New messages from your coach"

*Nutrition Tracking:*
- Toggle switch
- "Reminders to log your meals"

*Promotions & Updates:*
- Toggle switch
- "Special offers and app updates"

**Appearance Settings:**
- Theme: Light (default)
- (Dark mode - future enhancement)

**Data & Privacy:**
- Export My Data
- Privacy Settings
- Terms of Service (link)
- Privacy Policy (link)

#### Support Tab

**Help Center:**
- FAQ sections
- Getting Started Guide
- Video Tutorials
- Troubleshooting

**Contact Support:**
- Email support form
- Live chat button
- Expected response time: 24 hours

**App Information:**
- Version: v1.0.0
- "Made with ❤️ for your fitness journey"

**Demo Mode Indicator (if active):**
- Alert box with demo badge
- "You're currently in demo mode"
- "Some features may not work as expected"
- "Exit Demo" button

**Logout Section:**
- "Sign Out" button (red, prominent)
- Confirmation dialog
- Clears demo mode flag
- Returns to Auth screen
- Preserves language selection

---

## User Experience - Coach

### 5.1 Coach Dashboard (Home Screen)

**Header:**
- "Coach Dashboard" title
- "Manage clients and sessions" subtitle
- User avatar with coach badge
- Settings button
- Notification bell

**Statistics Overview (4 cards):**

1. **Total Clients**
   - Count: 4
   - Trending indicator (+1 this month)
   - Users icon

2. **Active Clients**
   - Count: 3
   - Percentage of total
   - User-check icon

3. **Monthly Revenue**
   - Amount: $2,400
   - Trend graph mini preview
   - Dollar sign icon

4. **Completion Rate**
   - Percentage: 87%
   - Client workout adherence
   - CheckCircle icon

**Tab Navigation:**
- Overview (default)
- Clients
- Schedule
- Analytics

#### Overview Tab

**Client Progress Section:**
Quick overview cards for active clients:
- Client name and avatar
- Current goal
- Progress percentage (circular indicator)
- Last activity timestamp
- Quick actions: "Create Plan", "Send Message"

**Upcoming Appointments:**
Calendar-style list:
- Next 7 days of appointments
- Client name
- Date and time
- Session type (Video, Chat, Assessment)
- Status (Upcoming, Confirmed)
- "Join" button (when time arrives)
- "Reschedule" option

**Recent Messages:**
- Last 5 unread/recent messages
- Client name and avatar
- Message preview
- Timestamp
- Badge for unread count
- Quick reply button
- "View All Messages" link

#### Clients Tab

**Client Management Header:**
- Total client count
- "New Client" button (manual add)
- Search bar: "Search clients..."
- Filter options:
  - All
  - Active
  - Inactive
  - New (last 30 days)

**Client List:**
Each client card contains:

*Client Information:*
- Avatar and name
- Email address
- Join date
- Last activity (relative time)

*Goal & Progress:*
- Main goal badge (Fat Loss, Muscle Gain, etc.)
- Progress bar (workout completion)
- Percentage text
- Status indicator (Active/Inactive/New)

*Subscription Info:*
- Tier badge (Freemium, Premium, Smart Premium)
- Revenue contribution (for Smart Premium clients)

*Quick Actions:*
- "Create Plan" button
- "View Progress" button
- "Send Message" button
- More options menu (...)

**Client Details View (Click client):**

*Profile Section:*
- Full name and contact
- Age, weight, height
- Fitness goals
- Experience level
- Injury history
- Dietary restrictions

*Activity Timeline:*
- Workout completion history
- Nutrition logging activity
- Communication history
- Progress photos (if shared)

*Plans & Programs:*
- Active workout plan
- Nutrition plan (if Premium+)
- Plan adherence statistics
- Modify/create plan options

*Communication:*
- Message thread with client
- Session history
- Notes and feedback

*Progress Tracking:*
- Weight trend graph
- Body measurements
- Performance metrics
- Progress photos comparison

**Create Client Plan Interface:**
- Opens ClientPlanManager component
- Workout plan builder
- Exercise selection from database
- Sets, reps, rest configuration
- Week and day assignment
- Exercise swap options
- Save and assign to client

#### Schedule Tab

**Calendar View:**
- Week/Month toggle
- Day cells showing appointments
- Color-coded by type:
  - Video sessions (blue)
  - Chat sessions (green)
  - Assessments (purple)
  - Blocked time (gray)

**Appointment List View:**
Filterable by:
- Today
- This Week
- This Month
- Past

Each appointment shows:
- Time slot
- Client name and avatar
- Session type icon
- Duration (30/45/60 min)
- Status badge
- Action buttons:
  - Join (video icon) - when session time
  - Reschedule (calendar icon)
  - Cancel (x icon)
  - Mark Complete (check icon)

**Time Blocking:**
- "Add Blocked Time" button
- Mark unavailable periods
- Recurring block option

**Appointment Detail Modal:**
- Client information
- Session type and duration
- Preparation notes
- Previous session summary
- Goals for this session
- Post-session notes field
- Action buttons

#### Analytics Tab

**Time Range Selector:**
- Last 7 days
- Last 30 days
- Last 3 months
- Custom range

**Performance Metrics:**

*Client Retention:*
- Percentage retained month-over-month
- Churn rate
- New client acquisition

*Session Statistics:*
- Total sessions conducted
- Average session rating
- Completion vs cancellation rate
- No-show rate

*Revenue Analytics:*
- Monthly recurring revenue
- Revenue by subscription tier
- Growth trend chart
- Top clients by revenue

*Engagement Metrics:*
- Average client workout completion rate
- Message response time
- Session booking rate
- Client satisfaction score

**Client Progress Summary:**
- Aggregate progress across all clients
- Average goal achievement percentage
- Most successful programs
- Areas for improvement

**Graphs and Charts:**
- Line graph: Revenue trend
- Bar chart: Sessions per week
- Pie chart: Client tier distribution
- Heat map: Availability utilization

### 5.2 Coach Messages

**Centralized Message Center:**
- All client conversations in one place
- Inbox/Sent toggle
- Filter by client
- Search messages
- Mark as read/unread
- Priority flag option

**Message Thread:**
- Full conversation history
- Timestamped messages
- Read receipts
- Typing indicators (mock)
- Rich text editor
- Attachment support (mock)
- Quick responses template

**Broadcasting:**
- Send message to multiple clients
- Group messaging (future)
- Announcements feature

### 5.3 Coach Navigation

**Available Screens:**
- Dashboard (Home)
- Client Management (Clients Tab)
- Schedule (Schedule Tab)
- Messages (if implemented separately)
- Analytics (Analytics Tab)
- Account Settings
- Store (access to store features)

**Special Features:**
- Client plan creation tool
- Exercise database access
- Template library (workout and nutrition)
- Resource center

---

## User Experience - Admin

### 6.1 Admin Dashboard (Home Screen)

**Header:**
- "Admin Dashboard" title
- "Manage users and system" subtitle
- Search global
- Notifications icon
- Settings icon
- Admin avatar

**Tab Navigation:**
- Overview (default)
- Users
- Coaches
- Store
- Analytics
- Settings

#### Overview Tab

**System Statistics (4 cards):**

1. **Total Users**
   - Count: 1,247
   - Growth rate: +12%
   - Trend: ↑ 134 this month
   - Users icon

2. **Active Users**
   - Count: 892
   - Percentage: 71.5%
   - Active today: 234
   - UserCheck icon

3. **Total Revenue**
   - Amount: $45,680
   - Monthly recurring: $38,200
   - Growth: +8.3%
   - DollarSign icon

4. **Growth Rate**
   - Percentage: +15.7%
   - Month-over-month
   - Trend indicator
   - TrendingUp icon

**Quick Actions:**
- "Add New User"
- "Create Coach Account"
- "Add Store Product"
- "Generate Report"

**System Health:**
- Server status: Online
- Database status: Healthy
- Last backup: 2 hours ago
- Storage used: 45% of 500GB

**Recent Activity Feed:**
Real-time system events:
- New user registrations
- Subscription changes
- Coach assignments
- Store orders
- System alerts
- User reports

**Charts & Graphs:**

*User Growth Chart:*
- Line graph
- Last 6 months
- New vs total users
- Churn visualization

*Revenue Breakdown:*
- Pie chart
- By subscription tier
- Freemium: 60% (users)
- Premium: 30% (revenue)
- Smart Premium: 10% (users), 60% (revenue)

*Geographic Distribution:*
- Map visualization (mock)
- User density by region
- Top countries list

#### Users Tab

**User Management Header:**
- Total user count: 1,247
- Active filters indicator
- "Add User" button
- Export to CSV button

**Search & Filter Bar:**
- Search input: "Search users..."
- Filter dropdowns:
  - Status: All, Active, Inactive, Suspended
  - Tier: All, Freemium, Premium, Smart Premium
  - Join Date: All time, Last 30 days, Last 90 days
  - Has Coach: All, Yes, No
- Sort options: Name, Join Date, Last Active, Tier

**User Table:**
Columns:
- User Name (with avatar)
- Email
- Subscription Tier (badge)
- Status (badge)
  - Active (green)
  - Inactive (gray)
  - Suspended (red)
- Join Date
- Last Active
- Coach Assigned
- Actions (dropdown)

**Actions Menu:**
- View Profile
- Edit User
- Change Subscription
- Assign Coach
- Suspend Account
- Send Message
- Delete User (with confirmation)

**Bulk Actions:**
- Select multiple users
- Bulk operations:
  - Change tier
  - Assign coach
  - Send notification
  - Export selection

**User Detail Modal:**

*Profile Section:*
- Full user information
- Contact details
- Fitness profile
- Onboarding data

*Activity:*
- Login history
- Workout completion
- Nutrition logs
- Coach interactions

*Subscription:*
- Current tier
- Billing history
- Payment method
- Upgrade/downgrade history

*Notes:*
- Admin notes (internal)
- Support ticket history
- Flags or warnings

**Pagination:**
- 25/50/100 per page
- Page navigation
- Total count display

#### Coaches Tab

**Coach Management Header:**
- Total coach count: 12
- "Add New Coach" button
- Performance metrics toggle

**Coach List:**
Each coach card displays:

*Coach Information:*
- Name and avatar
- Email and contact
- Join date
- Status (Active/Suspended)

*Specialization:*
- Listed specialties
- Certifications

*Performance Metrics:*
- Total clients: 4
- Active clients: 3
- Client capacity: 4/10
- Rating: ⭐ 4.9
- Monthly revenue: $2,400

*Client Management:*
- List of assigned clients
- Add/remove client buttons
- Client satisfaction scores

*Actions:*
- View Profile
- Edit Details
- Manage Clients
- View Schedule
- Suspend/Activate
- Delete (if no active clients)

**Coach Detail View:**

*Performance Analytics:*
- Client retention rate
- Average client progress
- Session completion rate
- Response time metrics
- Client feedback scores

*Schedule Overview:*
- Weekly availability
- Session bookings
- Utilization rate
- Peak hours

*Revenue Contribution:*
- Personal earnings
- Platform revenue share
- Bonus eligibility
- Payment history

**Add Coach Modal:**
- Basic information form
- Specialization selection
- Certification upload (mock)
- Client capacity setting
- Revenue share configuration
- Initial password setup

#### Store Tab

**Store Management Header:**
- Total products: 24
- Total revenue: $18,450 this month
- "Add Product" button
- Category management

**Product Management:**

*Filter & Search:*
- Search products
- Category filter
- Stock status filter
- Active/Inactive toggle

*Product Table:*
Columns:
- Product Image
- Product Name
- Category
- Price
- Stock Level
- Sales (this month)
- Status
- Actions

*Product Actions:*
- Edit Product
- Manage Inventory
- View Analytics
- Duplicate
- Archive
- Delete

**Product Detail View:**
- Full product information
- Pricing history
- Inventory tracking
- Sales analytics:
  - Units sold
  - Revenue generated
  - Popular variants
  - Return rate
- Customer reviews
- Related products

**Add/Edit Product Form:**
- Product name and description
- Category selection
- Pricing:
  - Base price
  - Subscriber discounts (Premium %, Smart Premium %)
- Images upload (mock)
- Inventory:
  - Current stock
  - Low stock alert threshold
  - Reorder point
- SEO:
  - Search keywords
  - Meta description
- Status: Active/Inactive

**Inventory Management:**
- Stock level tracking
- Automatic low stock alerts
- Supplier information
- Reorder history
- Stock adjustments log

**Order Management:**
- All orders list
- Order details view
- Status updates:
  - Pending
  - Processing
  - Shipped
  - Delivered
  - Cancelled
  - Refunded
- Fulfillment tracking
- Customer communication

#### Analytics Tab

**Dashboard Overview:**
- Key metrics summary
- Custom date range selector
- Export reports button

**User Analytics:**

*Acquisition:*
- New user signups (time series)
- Signup source tracking
- Conversion funnel
- Drop-off analysis

*Engagement:*
- Daily/Weekly/Monthly active users
- Session duration
- Feature usage statistics
- User cohort analysis

*Retention:*
- Retention curves
- Churn rate
- Lifetime value calculation
- Win-back campaigns performance

**Financial Analytics:**

*Revenue:*
- Total revenue trend
- Revenue by subscription tier
- Average revenue per user (ARPU)
- Monthly recurring revenue (MRR)
- Annual recurring revenue (ARR)

*Subscription Metrics:*
- New subscriptions
- Upgrades
- Downgrades
- Cancellations
- Reactivations

*Store Performance:*
- Product sales
- Category performance
- Revenue per category
- Discount impact analysis

**Content Analytics:**

*Workout Plans:*
- Most popular workouts
- Completion rates
- User ratings
- Equipment usage

*Nutrition Plans:*
- Meal plan engagement
- Most tracked foods
- Macro adherence rates

**Coach Performance:**
- Aggregate coach metrics
- Top performing coaches
- Client satisfaction trends
- Session booking rates
- Revenue per coach

**System Performance:**
- API response times
- Error rates
- User-reported issues
- Feature adoption rates

**Custom Reports:**
- Report builder interface
- Scheduled reports
- Email delivery
- Export formats (CSV, PDF)

#### Settings Tab

**Platform Configuration:**

*General Settings:*
- App name and branding
- Contact information
- Support email
- Business hours

*Subscription Plans:*
- Edit tier features
- Pricing updates
- Feature toggles
- Trial period configuration

*Coach Settings:*
- Default commission rate
- Client capacity limits
- Certification requirements
- Onboarding flow

*Store Settings:*
- Payment gateway configuration
- Shipping rates
- Tax settings
- Return policy

*Notification Settings:*
- Email templates
- Push notification rules
- SMS notifications (if enabled)
- Notification frequency limits

*Security Settings:*
- Password policies
- Session timeout
- Two-factor authentication
- API key management

*Localization:*
- Available languages
- Default language
- Translation management
- Regional settings

**System Maintenance:**
- Database backup
- System logs viewer
- Cache management
- Scheduled maintenance windows

**User Roles & Permissions:**
- Admin role management
- Custom permission sets
- Access control lists
- Audit log

### 6.2 Admin Special Features

**User Impersonation:**
- "View as User" feature
- Troubleshooting tool
- Audit trail logged
- Session recording

**Bulk Operations:**
- Mass user import/export
- Bulk subscription changes
- Batch communications
- Data cleanup tools

**Content Management:**
- Exercise database editing
- Nutrition database management
- Template creation
- Resource library

**System Monitoring:**
- Real-time dashboard
- Alert system
- Performance metrics
- Error tracking

---

## Technical Specifications

### 7.1 Technology Stack

**Frontend Framework:**
- React 18.x
- TypeScript 5.x
- Vite (build tool)

**UI Libraries:**
- Tailwind CSS 4.0
- shadcn/ui component library
- Lucide React (icons)
- Sonner (toast notifications)

**State Management:**
- React Context API (LanguageContext)
- React Hooks (useState, useEffect)
- Local component state

**Data Persistence:**
- localStorage for:
  - Language preference
  - Demo mode flag
  - Intro screen completion
  - (No real database in current version)

### 7.2 Component Architecture

**Core Components:**
```
/components
  ├── LanguageContext.tsx         # i18n provider
  ├── LanguageSelectionScreen.tsx # Initial language choice
  ├── AppIntroScreen.tsx          # Welcome screen
  ├── AuthScreen.tsx              # Authentication
  ├── OnboardingScreen.tsx        # User profile setup
  ├── DemoModeIndicator.tsx       # Demo mode badge
  ├── BackButton.tsx              # Reusable back navigation
  
  # User Screens
  ├── HomeScreen.tsx              # User dashboard
  ├── WorkoutScreen.tsx           # Workout interface
  ├── ExerciseDetailScreen.tsx    # Exercise details
  ├── WorkoutTimer.tsx            # Timer component
  ├── NutritionScreen.tsx         # Nutrition tracking
  ├── NutritionPreferencesIntake.tsx # Nutrition setup
  ├── CoachScreen.tsx             # Coach messaging
  ├── StoreScreen.tsx             # Store interface
  ├── AccountScreen.tsx           # Account management
  
  # Coach Components
  ├── CoachDashboard.tsx          # Coach home
  ├── ClientPlanManager.tsx       # Plan creation tool
  
  # Admin Components
  ├── AdminDashboard.tsx          # Admin home
  
  # Shared Components
  ├── SubscriptionManager.tsx     # Subscription plans
  ├── ExerciseDatabase.tsx        # Exercise data (basic)
  ├── EnhancedExerciseDatabase.tsx # Exercise data (enhanced)
  
  # UI Components (shadcn/ui)
  └── ui/
      ├── button.tsx
      ├── card.tsx
      ├── input.tsx
      ├── badge.tsx
      ├── progress.tsx
      ├── tabs.tsx
      ├── dialog.tsx
      ├── select.tsx
      ├── switch.tsx
      ├── calendar.tsx
      ├── avatar.tsx
      ├── alert.tsx
      └── [30+ more UI components]
```

### 7.3 Data Flow

**Authentication Flow:**
```
AuthScreen
  ↓ phone/email detection
  ├─ phone +966507654321 → Coach type
  ├─ phone +966509876543 → Admin type
  ├─ email coach@fitcoach.com → Coach type
  ├─ email admin@fitcoach.com → Admin type
  └─ any other credential → User type
  ↓
  [User type routing]
  ↓
  ├─ User → Onboarding (if new) → HomeScreen
  ├─ Coach → CoachDashboard
  └─ Admin → AdminDashboard
```

**State Management:**
```typescript
// App-level state (App.tsx)
interface AppState {
  isAuthenticated: boolean;
  isDemoMode: boolean;
  userType: 'user' | 'coach' | 'admin';
  userProfile: UserProfile | null;
  currentScreen: Screen;
  hasCompletedOnboarding: boolean;
  hasSeenIntro: boolean;
}
```

**Profile Propagation:**
- UserProfile passed as prop to all screens
- Update callbacks flow back to App.tsx
- Centralized state updates
- No global state library needed

### 7.4 Responsive Design

**Layout Strategy:**
- Mobile-first approach
- Max width container: 448px (max-w-md)
- Centered layout: mx-auto
- Full viewport height: min-h-screen

**Breakpoints:**
- Inherits Tailwind defaults
- Primary target: Mobile (375px - 428px)
- Secondary: Tablet (768px+)
- Desktop: 1024px+

**RTL Support:**
- Conditional flex-row-reverse
- Conditional text-align
- Icon positioning adjustments
- Margin/padding directional props

### 7.5 Performance Considerations

**Code Splitting:**
- Screen-level components
- Lazy loading potential (not implemented)

**Image Optimization:**
- ImageWithFallback component for error handling
- Placeholder usage
- (Production would use optimized images)

**Mock Data:**
- All demo data in-component
- No external API calls
- Instant state updates
- Simulated delays for realism

### 7.6 Browser Compatibility

**Target Browsers:**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Required Features:**
- ES6+ JavaScript
- CSS Grid
- CSS Flexbox
- localStorage API
- Touch events

---

## Data Models

### 8.1 User Profile

```typescript
interface UserProfile {
  id: string;                    // Unique identifier
  name: string;                  // Full name
  email: string;                 // Email address
  age: number;                   // Age in years
  weight: number;                // Weight in kg
  height: number;                // Height in cm
  gender: 'male' | 'female' | 'other';
  workoutFrequency: number;      // Days per week (2-6)
  workoutLocation: 'home' | 'gym';
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
  mainGoal: MainGoal;            // Primary fitness goal
  injuries: InjuryArea[];        // Current injuries/pain areas
  subscriptionTier: SubscriptionTier;
  coachId?: string;              // Assigned coach ID (optional)
}

type MainGoal = 'fat_loss' | 'muscle_gain' | 'general_fitness';

type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';

type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';
```

### 8.2 Exercise Data

```typescript
interface Exercise {
  id: string;                    // Exercise database ID
  name: string;                  // Translated exercise name
  exerciseId: string;            // Reference to exercise DB
  sets: number;                  // Number of sets
  reps: string;                  // Rep range (e.g., "8-10")
  restTime: number;              // Rest in seconds
  muscleGroup: string;           // Primary muscle group
  videoUrl?: string;             // Video demo URL
  completed: boolean;            // Completion status
  loggedSets: LoggedSet[];       // Set tracking
  isSwapped?: boolean;           // Was exercise swapped
  originalExerciseId?: string;   // Original before swap
}

interface LoggedSet {
  reps: number;                  // Actual reps completed
  weight?: number;               // Weight used (kg)
  time?: number;                 // Timestamp
}

interface ExerciseDetail {
  id: string;
  name: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  equipment: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  instructions: string[];
  tips: string[];
  commonMistakes: string[];
  alternatives: string[];        // Alternative exercise IDs
  videoUrl?: string;
}
```

### 8.3 Workout Plan

```typescript
interface WorkoutPlan {
  id: string;
  name: string;                  // Translated workout name
  week: number;                  // Week in program
  day: number;                   // Day in week
  duration: string;              // Estimated time
  difficulty: string;            // Translated difficulty
  exercises: Exercise[];         // List of exercises
}
```

### 8.4 Nutrition Data

```typescript
interface MacroTarget {
  calories: number;              // Daily calorie target
  protein: number;               // Protein in grams
  carbs: number;                 // Carbs in grams
  fats: number;                  // Fats in grams
  water: number;                 // Water in ml
}

interface FoodItem {
  id: string;
  name: string;                  // Translated food name
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  serving: string;               // Serving size description
}

interface Meal {
  id: string;
  name: string;                  // Breakfast/Lunch/Dinner/Snack
  time: string;                  // Meal time
  foods: FoodItem[];
  totalCalories: number;
}

interface NutritionPreferences {
  proteinSources: string[];      // Preferred proteins
  proteinAllergies: string[];    // Allergies/restrictions
  dinnerPreferences: {
    portionSize: 'light' | 'moderate' | 'large';
    prepSpeed: 'quick' | 'normal' | 'elaborate';
    carbLevel: 'low_carb' | 'includes_carbs' | 'high_carb';
    temperature: 'hot' | 'room_temp' | 'cold' | 'no_preference';
    cuisines: string[];
    avoid: string[];
  };
  additionalNotes: string;
}
```

### 8.5 Coach Data

```typescript
interface Coach {
  id: string;
  name: string;
  avatar?: string;
  specialties: string[];
  rating: number;                // 0-5 scale
  yearsExperience: number;
}

interface Message {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: Date;
  isFromCoach: boolean;
}

interface Session {
  id: string;
  date: Date;
  time: string;
  duration: number;              // Minutes
  status: 'pending' | 'approved' | 'rejected' | 'completed';
  type: 'chat' | 'video';
}
```

### 8.6 Client Data (Coach View)

```typescript
interface Client {
  id: string;
  name: string;
  email: string;
  joinDate: Date;
  lastActivity: Date;
  goal: string;
  status: 'active' | 'inactive' | 'new';
  subscriptionTier: string;
  progress: number;              // Percentage
}

interface Appointment {
  id: string;
  clientName: string;
  date: Date;
  time: string;
  duration: number;
  type: 'video' | 'chat' | 'assessment';
  status: 'upcoming' | 'completed' | 'missed';
}
```

### 8.7 Admin Data

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  subscriptionTier: string;
  status: 'active' | 'suspended' | 'inactive';
  joinDate: string;
  lastActive: string;
  coachId?: string;
}

interface Coach {
  id: string;
  name: string;
  email: string;
  specialization: string;
  clientCount: number;
  rating: number;
  status: 'active' | 'suspended';
  joinDate: string;
  revenue: number;
}

interface StoreItem {
  id: string;
  name: string;
  category: string;
  price: number;
  status: 'active' | 'inactive';
  sales: number;
  inventory: number;
}

interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  interval: 'monthly' | 'yearly';
  features: string[];
  subscriberCount: number;
  status: 'active' | 'inactive';
}
```

### 8.8 Store Data

```typescript
interface Product {
  id: string;
  name: string;
  brand: string;
  price: number;
  originalPrice?: number;
  rating: number;
  reviewCount: number;
  image: string;
  category: string;
  description: string;
  inStock: boolean;
  isPopular?: boolean;
  discount?: number;
}

interface CartItem {
  product: Product;
  quantity: number;
}

interface Order {
  id: string;
  date: Date;
  status: 'processing' | 'shipped' | 'delivered';
  total: number;
  items: CartItem[];
}
```

---

## Internationalization

### 9.1 Language System

**Implementation:**
- React Context API (LanguageContext)
- Hook: `useLanguage()`
- Translation function: `t(key: string)`

**Usage Example:**
```typescript
const { t, language, setLanguage, isRTL } = useLanguage();

// Translation
<h1>{t('home.hello')}</h1>
// Output (EN): "Hello"
// Output (AR): "مرحبا"

// Conditional RTL
<div className={isRTL ? 'flex-row-reverse' : 'flex-row'}>
```

### 9.2 Translation Structure

**Translation Files:**
Located in `LanguageContext.tsx` as a nested object:

```typescript
const translations = {
  en: {
    'category.key': 'Translation value',
    // 670+ keys
  },
  ar: {
    'category.key': 'قيمة الترجمة',
    // 670+ keys (matching English keys)
  }
};
```

**Translation Categories:**
1. Language selection (language.*)
2. App intro (intro.*)
3. Authentication (auth.*)
4. Onboarding (onboarding.*)
5. Home screen (home.*)
6. Workouts (workouts.*)
7. Nutrition (nutrition.*)
8. Subscription (subscription.*)
9. Account (account.*)
10. Store (store.*)
11. Coach (coach.*)
12. Admin (admin.*)
13. Exercise names (exercises.*)
14. Food items (foods.*)
15. Cuisines (cuisines.*)
16. Equipment (equipment.*)

### 9.3 RTL Support

**Layout Adjustments:**
```typescript
// Flex direction
className={`flex ${isRTL ? 'flex-row-reverse' : ''}`}

// Text alignment
className={isRTL ? 'text-right' : 'text-left'}

// Icon positioning
<Icon className={isRTL ? 'ml-2' : 'mr-2'} />

// Margins
{isRTL ? 'mr-4' : 'ml-4'}
```

**Automatic RTL Elements:**
- Text direction: `dir="rtl"` applied to container
- Input field alignment
- Scroll direction
- Animation direction

### 9.4 Translation Coverage

**100% Coverage Verified:**
- ✅ All UI labels
- ✅ All button text
- ✅ All screen titles
- ✅ All navigation items
- ✅ All form placeholders
- ✅ All error messages
- ✅ All demo content
- ✅ All exercise names
- ✅ All food items
- ✅ All success messages

**No Hardcoded Strings:**
- All user-facing text uses `t()` function
- Dynamic content properly translated
- Pluralization handled
- Number formatting locale-aware

### 9.5 Language Persistence

**Storage:**
```typescript
localStorage.setItem('fitcoach_language', language);
```

**Retrieval:**
```typescript
const savedLang = localStorage.getItem('fitcoach_language');
```

**Behavior:**
- Language choice persists across sessions
- Survives page refresh
- Survives logout/login
- Can be changed in Account Settings

---

## Demo Mode

### 10.1 Demo Mode Purpose

**Goals:**
- Allow users to explore app without registration
- Showcase all features with realistic data
- Test different user roles
- Evaluate app before commitment

### 10.2 Demo Mode Activation

**Method 1: Button**
- "Try Demo Mode" button on Auth screen
- Instant activation
- Uses email from input field to determine user type

**Method 2: Secret Gesture**
- Long press app logo (2+ seconds)
- Hidden activation method
- Activates default user demo profile

**Storage:**
```typescript
localStorage.setItem('fitcoach_demo_mode', 'true');
```

### 10.3 Demo Profiles

**User Demo Profile:**
```typescript
{
  id: 'demo_user_1',
  name: 'Mina H.',
  email: 'mina.h@demo.com',
  age: 28,
  weight: 78,
  height: 178,
  gender: 'male',
  workoutFrequency: 4,
  workoutLocation: 'gym',
  experienceLevel: 'intermediate',
  mainGoal: 'muscle_gain',
  injuries: ['lower_back'],
  subscriptionTier: 'Freemium',
  coachId: 'coach_sara'
}
```

**Coach Demo Profile:**
```typescript
{
  id: 'coach_1',
  name: 'Sarah Johnson',
  email: 'coach@fitcoach.com',
  age: 32,
  weight: 65,
  height: 168,
  gender: 'female',
  workoutFrequency: 6,
  workoutLocation: 'gym',
  experienceLevel: 'advanced',
  mainGoal: 'general_fitness',
  injuries: [],
  subscriptionTier: 'Smart Premium'
}
```

**Admin Demo Profile:**
```typescript
{
  id: 'admin_1',
  name: 'Admin User',
  email: 'admin@fitcoach.com',
  age: 30,
  weight: 75,
  height: 175,
  gender: 'other',
  workoutFrequency: 5,
  workoutLocation: 'gym',
  experienceLevel: 'advanced',
  mainGoal: 'general_fitness',
  injuries: [],
  subscriptionTier: 'Smart Premium'
}
```

### 10.4 Demo Data

**Pre-populated Data:**
- Workout history (12/14 workouts completed)
- Calories burned: 2,850
- Calories consumed: 1,950
- Weekly progress: 78%
- Plan adherence: 85%
- Streak days: 5
- Coach messages (3 message thread)
- Store cart (1 item)
- Recent activity feed
- Upcoming workout

**Coach Demo Data:**
- 4 clients with varying statuses
- Upcoming appointments
- Recent messages from clients
- Performance statistics
- Revenue data

**Admin Demo Data:**
- 1,247 total users
- 892 active users
- $45,680 total revenue
- 12 coaches
- 24 store products
- System statistics
- Activity feed

### 10.5 Demo Mode Indicator

**Visual Indicator:**
- Fixed badge in top-left corner
- Purple background
- "Demo Mode" text
- Always visible in demo mode
- Component: DemoModeIndicator

**Alert in Account:**
- Yellow alert box in Account > Support tab
- "You're currently in demo mode"
- Explanation of limitations
- "Exit Demo" button

### 10.6 Demo Mode Limitations

**What Works:**
- All UI interactions
- Screen navigation
- Form submissions (mock)
- Simulated API responses
- State updates
- Timer functionality
- Subscription upgrades (mock)

**What Doesn't Work:**
- No real data persistence (except localStorage)
- No actual payment processing
- No real email sending
- No actual video sessions
- No real coach responses (auto-replies only)

### 10.7 Exiting Demo Mode

**Exit Methods:**
1. "Exit Demo" button in Account Settings
2. "Sign Out" button
3. Manual localStorage clear

**Exit Behavior:**
```typescript
const handleLogout = () => {
  setAppState({
    isAuthenticated: false,
    isDemoMode: false,
    userType: 'user',
    userProfile: null,
    currentScreen: 'auth',
    hasCompletedOnboarding: false,
    hasSeenIntro: true,
  });
  localStorage.removeItem('fitcoach_demo_mode');
  // Language preference is preserved
};
```

**Post-Exit State:**
- Returns to Auth screen
- Demo flag cleared
- User data cleared
- Language selection preserved
- Intro screen not shown again

---

## Future Considerations

### 11.1 Backend Integration

**Planned Backend Features:**
- User authentication (Firebase, Auth0, or custom)
- Database integration (Supabase, PostgreSQL)
- Real-time messaging
- Video session integration
- Payment processing (Stripe)
- Email notifications
- Push notifications
- File storage (workout videos, user photos)

### 11.2 Additional Features

**Workout Enhancements:**
- Video recording of sets
- Form check with AI
- Progressive overload suggestions
- Workout plan creation wizard
- Custom exercise creation
- Superset and circuit support
- Deload week planning

**Nutrition Enhancements:**
- Barcode scanner
- Photo food logging
- Meal prep planner
- Recipe database
- Grocery list generation
- Restaurant meal finder
- Macro calculator with more variables

**Coach Features:**
- Live video sessions (Zoom/custom)
- Screen sharing for form review
- Workout plan templates
- Automated check-ins
- Progress photo comparison
- Body composition tracking
- Payment collection
- Contract management

**Admin Features:**
- Advanced analytics dashboard
- A/B testing tools
- Email campaign management
- Customer support ticket system
- Content management system
- API for third-party integrations
- Automated reporting

**Social Features:**
- Friend connections
- Workout sharing
- Leaderboards
- Challenges and competitions
- Community forums
- Success story sharing
- Group workouts

**Additional Integrations:**
- Wearable device sync (Fitbit, Apple Watch)
- Calendar integration (Google Calendar)
- Music streaming (Spotify)
- Social media sharing
- Export to other fitness apps

### 11.3 Platform Expansion

**Mobile Apps:**
- Native iOS app
- Native Android app
- Offline mode support
- Push notifications
- Camera integration
- GPS tracking for outdoor workouts

**Smart Watch Apps:**
- Apple Watch companion
- Android Wear companion
- Workout tracking
- Heart rate monitoring
- Quick logging

### 11.4 Accessibility Improvements

**Planned Enhancements:**
- Screen reader optimization
- Keyboard navigation
- High contrast mode
- Font size adjustment
- Voice commands
- Video captions/subtitles

### 11.5 Performance Optimizations

**Future Improvements:**
- Code splitting
- Lazy loading
- Image optimization
- Service worker for offline
- Progressive Web App (PWA)
- CDN integration

### 11.6 Additional Languages

**Expansion Plans:**
- Spanish
- French
- German
- Portuguese
- Hindi
- Chinese (Simplified/Traditional)
- Japanese
- Korean

### 11.7 Monetization Features

**Revenue Streams:**
- Subscription management (Stripe)
- In-app purchases
- Coach marketplace
- Affiliate store integration
- Sponsored content
- Premium content library
- Certification programs

---

## Appendix

### A. Screen Navigation Map

```
Language Selection (First time only)
  ↓
App Intro (First time only)
  ↓
Authentication
  ↓
[User Type Routing]
  ↓
  ├─ REGULAR USER PATH
  │   ↓
  │   Onboarding (if new user)
  │   ↓
  │   Home Screen
  │   ├─ Workout Screen
  │   │   └─ Exercise Detail Screen
  │   ├─ Nutrition Screen (Premium+)
  │   │   └─ Nutrition Preferences Intake
  │   ├─ Coach Screen
  │   ├─ Store Screen
  │   └─ Account Screen
  │       └─ Subscription Manager
  │
  ├─ COACH PATH
  │   ↓
  │   Coach Dashboard
  │   ├─ Client Management
  │   │   └─ Client Plan Manager
  │   ├─ Schedule
  │   ├─ Messages
  │   ├─ Analytics
  │   └─ Account Screen
  │
  └─ ADMIN PATH
      ↓
      Admin Dashboard
      ├─ User Management
      ├─ Coach Management
      ├─ Store Management
      ├─ Analytics
      ├─ Settings
      └─ Account Screen
```

### B. File Structure Reference

```
fitcoach/
├── public/
│   ├── favicon.ico
│   ├── manifest.json
│   └── vite.svg
│
├── components/
│   ├── Core/
│   │   ├── LanguageContext.tsx
│   │   ├── LanguageSelectionScreen.tsx
│   │   ├── AppIntroScreen.tsx
│   │   ├── AuthScreen.tsx
│   │   ├── OnboardingScreen.tsx
│   │   ├── DemoModeIndicator.tsx
│   │   └── BackButton.tsx
│   │
│   ├── User/
│   │   ├── HomeScreen.tsx
│   │   ├── WorkoutScreen.tsx
│   │   ├── ExerciseDetailScreen.tsx
│   │   ├── WorkoutTimer.tsx
│   │   ├── NutritionScreen.tsx
│   │   ├── NutritionPreferencesIntake.tsx
│   │   ├── CoachScreen.tsx
│   │   ├── StoreScreen.tsx
│   │   └── AccountScreen.tsx
│   │
│   ├── Coach/
│   │   ├── CoachDashboard.tsx
│   │   └── ClientPlanManager.tsx
│   │
│   ├── Admin/
│   │   └── AdminDashboard.tsx
│   │
│   ├── Shared/
│   │   ├── SubscriptionManager.tsx
│   │   ├── ExerciseDatabase.tsx
│   │   └── EnhancedExerciseDatabase.tsx
│   │
│   └── ui/
│       └── [shadcn components]
│
├── styles/
│   └── globals.css
│
├── App.tsx
├── main.tsx
├── index.html
├── package.json
├── vite.config.ts
├── tsconfig.json
└── README.md
```

### C. Key Dependencies

```json
{
  "dependencies": {
    "react": "^18.x",
    "react-dom": "^18.x",
    "lucide-react": "latest",
    "sonner": "^2.0.3",
    "tailwindcss": "^4.0",
    "@radix-ui/react-*": "latest"
  },
  "devDependencies": {
    "typescript": "^5.x",
    "vite": "latest",
    "@types/react": "latest",
    "@types/react-dom": "latest"
  }
}
```

### D. localStorage Keys

| Key | Purpose | Value Type |
|-----|---------|------------|
| `fitcoach_language` | User language preference | 'en' \| 'ar' |
| `fitcoach_demo_mode` | Demo mode activation | 'true' \| null |
| `fitcoach_intro_seen` | Intro screen completion | 'true' \| null |

### E. Color Scheme

**Primary Colors:**
- Primary: Blue (#3B82F6)
- Secondary: Purple (#A855F7)
- Success: Green (#10B981)
- Warning: Yellow (#F59E0B)
- Error: Red (#EF4444)

**Subscription Tier Colors:**
- Freemium: Gray (#6B7280)
- Premium: Purple (#A855F7)
- Smart Premium: Gold (#F59E0B)

**Status Colors:**
- Active: Green (#10B981)
- Inactive: Gray (#6B7280)
- Suspended: Red (#EF4444)
- Pending: Yellow (#F59E0B)

### F. Typography

**Font Stack:**
- System fonts (Tailwind default)
- -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif

**Arabic Font:**
- System Arabic fonts
- Optimized for RTL rendering

**Size Scale:**
- Defined in globals.css
- Responsive scaling
- Maintained through default HTML element styling

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | Oct 29, 2025 | AI Assistant | Initial comprehensive SRD |

---

## Approval Signatures

_This section would be used in a real production environment_

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | | | |
| Technical Lead | | | |
| QA Lead | | | |
| Stakeholder | | | |

---

**Document Status:** ✅ Complete  
**Last Updated:** October 29, 2025  
**Next Review:** TBD

---

_End of Software Requirements Document_
