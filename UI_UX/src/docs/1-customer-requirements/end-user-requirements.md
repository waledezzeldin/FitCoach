# End User Requirements - عاش (FitCoach+ v2.0)

## Document Information
- **User Type**: End Users (Fitness Enthusiasts)
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## 1. User Personas

### Primary Persona: Ahmed (Busy Professional)
- **Age**: 28-35
- **Location**: Riyadh, Saudi Arabia
- **Occupation**: Corporate employee
- **Goals**: Lose weight, improve fitness, build muscle
- **Pain Points**: No time for gym, don't know proper form, lack accountability
- **Tech Savviness**: High (smartphone user, familiar with apps)
- **Language**: Bilingual (Arabic/English)
- **Budget**: Willing to pay for premium features if value is clear

### Secondary Persona: Fatimah (Stay-at-Home Mom)
- **Age**: 30-40
- **Location**: Jeddah, Saudi Arabia
- **Goals**: Get fit at home, regain pre-pregnancy fitness
- **Pain Points**: No access to gym, need flexible schedule, prefer Arabic
- **Budget**: Prefers free/low-cost options initially

### Tertiary Persona: Khalid (Young Athlete)
- **Age**: 18-25
- **Goals**: Build muscle, improve athletic performance
- **Experience Level**: Intermediate to Advanced
- **Budget**: Willing to invest in coaching

---

## 2. User Journey Map

### 2.1 First-Time User Journey

```
Discover App → Select Language → View Intro Slides → 
Phone Verification → First Intake (3 questions) → Home Screen →
Access Workout → Second Intake Prompt → [Complete Intake OR Schedule Call OR Try Later] →
Explore Features → Generate First Plan → Start Training
```

#### Detailed Steps

**Step 1: Language Selection**
- **Requirement**: User must select preferred language (Arabic/English)
- **Screen**: Language Selection Screen
- **User Need**: "I want the app in my preferred language"
- **Success Criteria**: Language applies to entire app, including RTL for Arabic

**Step 2: App Introduction**
- **Requirement**: 3-slide carousel showcasing key features
- **Screen**: App Intro Screen
- **User Need**: "I want to understand what this app offers before signing up"
- **Success Criteria**: User can swipe through slides or skip to signup

**Step 3: Phone Authentication**
- **Requirement**: Saudi phone number verification via OTP
- **Screen**: Phone OTP Authentication Screen
- **User Need**: "I want secure access without remembering passwords"
- **Success Criteria**: 
  - Phone number validated (+966 5X XXX XXXX format)
  - OTP received within 30 seconds
  - Can resend OTP after 60 seconds
  - Successful verification creates/logs in account

**Step 4: First Intake**
- **Requirement**: Quick 3-question profile setup
- **Screen**: First Intake Screen
- **User Need**: "I want to tell the app about my basic fitness goals"
- **Questions**:
  1. Gender (male/female/other)
  2. Main Goal (fat loss/muscle gain/general fitness)
  3. Workout Location (home/gym)
- **Success Criteria**: All questions answered, profile saved

**Step 5: Home Dashboard**
- **Requirement**: Central hub showing fitness overview (ALL users arrive here after first intake)
- **Screen**: Home Screen
- **User Need**: "I want to see my progress and quickly access key features"
- **Success Criteria**: Displays workout plan, nutrition summary, quota usage, quick actions

**Step 6: Second Intake Prompt (When Accessing Workout)**
- **Requirement**: Prompt for detailed profile when user first accesses workout section
- **Trigger**: User taps "Start Workout" or "Workout" from Home (first time only)
- **Screen**: Second Intake Prompt Modal
- **User Need**: "I want to get personalized workouts but I'm not sure if I should fill detailed info now"
- **Prompt Content**:
  - Title: "Get Personalized Workouts" / "احصل على تمارين مخصصة"
  - Message: "Answer 6 quick questions to get a workout plan tailored to your fitness level and injuries"
  - **Option 1**: "Complete Profile Now" → Second Intake Screen
  - **Option 2**: "Schedule Video Call with Coach" → Video Booking Screen
  - **Option 3**: "Try Later" → Skip to Workout (use defaults)
- **Success Criteria**: 
  - Modal appears only once (first workout access)
  - Available to ALL tiers (Freemium, Premium, Smart Premium)
  - User's choice is respected and remembered

**Step 7: Second Intake (Optional - All Users)**
- **Requirement**: Detailed 6-question profile (Available to ALL users)
- **Screen**: Second Intake Screen (if user chose "Complete Profile Now")
- **User Need**: "I want personalized plans based on my detailed profile"
- **Questions**:
  1. Age (13-120)
  2. Weight (30-300 kg)
  3. Height (100-250 cm)
  4. Experience Level (beginner/intermediate/advanced)
  5. Workout Frequency (2-6 days/week)
  6. Injuries (shoulder/knee/lower back/neck/ankle/none)
- **Success Criteria**: 
  - All questions answered with valid data
  - Fitness score auto-calculated
  - Injury-aware programming activated if injuries selected
  - Available to Freemium, Premium, and Smart Premium users
  - After completion → Return to Workout Screen

**Step 8: Begin Workout Journey**
- User sees Workout Welcome Screen (first time) or goes directly to Workout Screen
- Workout plan is generated based on available data:
  - If second intake completed: Highly personalized
  - If only first intake: Generic plan based on goal and location
  - If scheduled call: Coach will create custom plan after call

---

## 3. Feature Requirements by Screen

### 3.1 Home Dashboard Screen

#### Purpose
Central navigation and overview screen showing user's fitness status, quick access to main features, and subscription information.

#### Requirements

**FR-HOME-01: Greeting Display**
- System displays time-based greeting with user's name
- Formats: "Good Morning/Afternoon/Evening/Night, [Name]"
- Available in Arabic and English

**FR-HOME-02: Subscription Tier Badge**
- Clearly shows current tier (Freemium/Premium/Smart Premium)
- Visual differentiation with colors/icons
- Tap to view tier benefits and upgrade options

**FR-HOME-03: Quota Display**
- Shows remaining messages for month (Freemium: X/20, Premium: X/200, Smart Premium: Unlimited)
- Shows remaining video calls for month
- Progress bars with color coding:
  - Green: < 80% used
  - Yellow: 80-99% used
  - Red: 100% used (exceeded)
- Display next reset date

**FR-HOME-04: Today's Workout Card**
- Shows current day's workout plan
- Displays exercise count and estimated duration
- "Start Workout" button
- If no workout: "Rest Day" or "Create Plan" prompt

**FR-HOME-05: Nutrition Summary**
- Shows today's calorie target and consumed
- Macros progress rings (protein/carbs/fats)
- "View Meal Plan" button
- Freemium: Shows expiry countdown if trial active

**FR-HOME-06: Progress Stats Card**
- Current weight
- Fitness score (if Premium+)
- Recent trend (up/down/stable)
- "Track Progress" button

**FR-HOME-07: Quick Actions**
- Message Coach button
- View Store button
- Settings button

**FR-HOME-08: Demo Mode Indicator**
- When in demo mode, show prominent badge
- "Exit Demo" option

#### User Scenarios

**Scenario 1: Morning Routine Check**
```
User opens app at 7 AM
→ Sees "Good Morning, Ahmed"
→ Views today's workout (5 exercises, 45 min)
→ Checks nutrition plan (2000 cal target)
→ Taps "Start Workout"
```

**Scenario 2: Freemium User Checking Quota**
```
User opens home
→ Sees "5/20 messages remaining"
→ Progress bar at 75% (yellow warning)
→ Considers upgrading to Premium
→ Taps tier badge to view upgrade options
```

---

### 3.1.1 Second Intake Prompt Modal

#### Purpose
Modal dialog that appears when user first accesses the workout section, offering options to complete detailed profile, schedule a coach call, or try the workout feature later.

#### Requirements

**FR-SECOND-INTAKE-PROMPT-01: Trigger Condition**
- Modal appears when user taps "Start Workout" or "Workout" button from Home
- Triggers only if:
  - User has completed first intake
  - User has NOT completed second intake
  - User has NOT seen this prompt before (or chose "Try Later")
- Available to ALL subscription tiers (Freemium, Premium, Smart Premium)

**FR-SECOND-INTAKE-PROMPT-02: Modal Design**
- Semi-transparent backdrop (blocks interaction with background)
- Centered modal card with rounded corners
- Icon/illustration at top (personalization/customization theme)
- Title: "Get Personalized Workouts" / "احصل على تمارين مخصصة"
- Description: "Complete your fitness profile for workouts tailored to your level, goals, and injuries. Or schedule a video call with your coach for expert guidance."

**FR-SECOND-INTAKE-PROMPT-03: Option 1 - Complete Profile Now**
- Primary button: "Complete Profile Now" / "أكمل الملف الآن"
- Icon: 📋 or ✍️
- Description: "6 quick questions (2 min)"
- Action: Navigate to Second Intake Screen
- Emphasized as recommended option

**FR-SECOND-INTAKE-PROMPT-04: Option 2 - Schedule Video Call**
- Secondary button: "Talk to My Coach" / "تحدث مع مدربي"
- Icon: 📞 or 👨‍⚕️
- Description: "Get personalized help via video call"
- Quota check:
  - If user has video call quota remaining: Navigate to Video Booking Screen
  - If user has 0 calls remaining: Show upgrade prompt
- Note: Shows remaining calls "1/1 call available this month"

**FR-SECOND-INTAKE-PROMPT-05: Option 3 - Try Later**
- Tertiary button/link: "Try Later" / "جرب لاحقاً"
- Subtle styling (text link, not prominent button)
- Description: "Use default workout plan for now"
- Action: 
  - Dismiss modal
  - Navigate to Workout Welcome Screen (if first time) OR Workout Screen
  - Generate generic workout based on first intake data only
  - Set flag: `second_intake_prompt_deferred_${userId}`
- User can access second intake later from Settings

**FR-SECOND-INTAKE-PROMPT-06: Persistence Logic**
- If user chooses "Complete Profile Now" → Mark prompt as completed, don't show again
- If user chooses "Talk to My Coach" → Mark prompt as completed, don't show again
- If user chooses "Try Later" → Don't show in THIS session, but show again next app launch
- After 3 "Try Later" selections → Stop showing prompt, allow user to access from Settings only
- Reset available in Settings > Edit Fitness Profile

**FR-SECOND-INTAKE-PROMPT-07: Close Behavior**
- Tap outside modal: Same as "Try Later"
- Back button / Escape key: Same as "Try Later"
- No "X" close button (force user to make explicit choice)

**FR-SECOND-INTAKE-PROMPT-08: Accessibility**
- Modal announced by screen reader
- Keyboard navigation between options (Tab/Arrow keys)
- Enter key activates selected option
- Escape key: Same as "Try Later"

**FR-SECOND-INTAKE-PROMPT-09: Localization**
- All text fully translated (Arabic/English)
- Button order may be reversed for RTL
- Icon direction adjusted for RTL if applicable

#### User Scenarios

**Scenario 1: Freemium User Chooses to Complete Profile**
```
Freemium user completes first intake
→ Arrives at Home screen
→ Taps "Start Workout"
→ Second Intake Prompt Modal appears
→ User reads three options
→ Wants personalized plan, taps "Complete Profile Now"
→ Modal closes
→ Navigates to Second Intake Screen (6 questions)
→ User completes all questions:
   - Age: 28
   - Weight: 85 kg
   - Height: 175 cm
   - Experience: Beginner
   - Frequency: 3 days/week
   - Injuries: None
→ Fitness score calculated: 65
→ Profile saved
→ Returns to Workout section
→ Sees Workout Welcome Screen (first time)
→ Taps "Start Your First Workout"
→ Workout plan generated based on detailed profile
→ Plan is highly personalized
```

**Scenario 2: Premium User Schedules Video Call**
```
Premium user at Home screen
→ Taps "Workout"
→ Second Intake Prompt appears
→ User prefers talking to coach, taps "Talk to My Coach"
→ System checks video call quota: 1/2 available
→ Modal closes
→ Video Booking Screen opens
→ User selects:
   - Date: Tomorrow, 3 PM
   - Purpose: "Help me create personalized workout plan"
→ Booking confirmed
→ Coach receives notification
→ User returns to Home
→ Can access workout later with coach's help
```

**Scenario 3: User Chooses Try Later**
```
User not ready to fill profile now
→ Taps "Try Later"
→ Modal closes
→ Navigates to Workout Screen with generic plan
→ Workout based on first intake only:
   - Goal: Muscle Gain
   - Location: Gym
   - Level: Default (Beginner assumed)
→ User can complete workouts
→ Next app launch, prompt appears again
→ After 3 deferrals, prompt stops appearing
→ User can access from Settings > Edit Fitness Profile anytime
```

**Scenario 4: Freemium User Wants Video Call but No Quota**
```
Freemium user taps "Talk to My Coach"
→ System checks quota: 0/1 calls (already used)
→ Quota exceeded modal appears:
   "Video Call Quota Exceeded
    You've used your 1 free video call this month.
    Upgrade to Premium for 2 calls/month.
    [Upgrade Now] [Go Back]"
→ User can upgrade or go back to prompt
→ If user taps "Go Back", returns to Second Intake Prompt Modal
→ User can choose different option
```

**Scenario 5: Returning User Re-accesses Prompt**
```
User previously chose "Try Later"
→ User uses app for a week with generic plan
→ User wants personalized workouts now
→ Opens Settings
→ Taps "Edit Fitness Profile"
→ System checks: Second intake not completed
→ Second Intake Prompt Modal appears again (or directly to Second Intake Screen)
→ User taps "Complete Profile Now"
→ Completes second intake
→ Workout plans now highly personalized
```

#### Data Storage

**Prompt Status Flags (localStorage or database)**
```typescript
interface SecondIntakePromptStatus {
  userId: string;
  hasSeenPrompt: boolean;
  lastShownAt: Date | null;
  timesDeferred: number;  // Count of "Try Later" selections
  hasCompletedSecondIntake: boolean;
  hasScheduledCoachCall: boolean;
  permanentlyDismissed: boolean;  // After 3 deferrals
}
```

**Example Values**:
```typescript
// User chose "Try Later" once
{
  userId: "user_123",
  hasSeenPrompt: true,
  lastShownAt: "2024-12-18T10:30:00Z",
  timesDeferred: 1,
  hasCompletedSecondIntake: false,
  hasScheduledCoachCall: false,
  permanentlyDismissed: false
}

// User completed second intake
{
  userId: "user_456",
  hasSeenPrompt: true,
  lastShownAt: "2024-12-18T09:00:00Z",
  timesDeferred: 0,
  hasCompletedSecondIntake: true,
  hasScheduledCoachCall: false,
  permanentlyDismissed: true  // Don't show again
}
```

---

### 3.2 Workout Screen

#### Purpose
Display and execute workout plans with exercise instructions, timer, and injury-aware substitutions.

#### Requirements

**FR-WORKOUT-01: Workout Plan Display**
- Show all exercises for current day
- Each exercise shows:
  - Name (translated)
  - Thumbnail/illustration
  - Sets x Reps (e.g., "3 x 12")
  - Target muscle groups
- Grouped by workout phase (Warm-up, Main, Cool-down)

**FR-WORKOUT-02: Exercise Details**
- Tap exercise to view full details
- Details include:
  - Instructions (step-by-step)
  - Form tips
  - Common mistakes
  - Video demonstration (if available)

**FR-WORKOUT-03: Workout Timer**
- "Start Workout" initiates timer mode
- Displays current exercise
- Rest timer between sets
- Auto-advance or manual next
- Progress tracking (Exercise 2 of 8)
- Can pause/resume/exit

**FR-WORKOUT-04: Exercise Completion Tracking**
- Check off completed sets
- Mark entire exercise as complete
- Visual progress bar
- Save progress automatically

**FR-WORKOUT-05: Injury Substitution (v2.0)**
- Automatic detection of contraindicated exercises
- Show "⚠️ Safe Alternative" badge
- Display explanation: "Original exercise may worsen [injury]"
- Suggest 3 alternative exercises
- One-click replacement
- User can keep original if desired

**FR-WORKOUT-06: Custom Plan Generation**
- "Generate Custom Plan" button
- Select:
  - Days per week
  - Experience level
  - Available equipment
  - Focus areas
- Premium+ required for custom plans

**FR-WORKOUT-07: Exercise Library Access**
- "Browse Exercises" button
- Search by:
  - Muscle group
  - Equipment
  - Difficulty
- Filter by injury contraindications

#### User Scenarios

**Scenario 1: Completing Workout**
```
User starts workout
→ Views Exercise 1: Push-ups (3 x 12)
→ Completes set 1, checks off
→ Rest timer starts (60 seconds)
→ Completes set 2 and 3
→ Moves to next exercise
→ Completes entire workout
→ System logs completion
```

**Scenario 2: Injury Substitution**
```
User with knee injury opens workout
→ Exercise 4: Barbell Squats has ⚠️ badge
→ Taps to view alternatives
→ Modal shows:
   - Original: Barbell Squats
   - Reason: "High knee compression, may worsen knee injury"
   - Alternatives: Leg Press, Bulgarian Split Squats, Box Squats
→ User selects "Leg Press"
→ Workout plan updated
→ Continues workout safely
```

---

### 3.3 Nutrition Screen

#### Purpose
Display personalized meal plans, track food intake, and manage nutrition goals with tier-based access control.

#### Requirements

**FR-NUTRITION-01: Meal Plan Display**
- Show daily meal plan with:
  - Breakfast, Lunch, Dinner, Snacks
  - Each meal shows: Name, Calories, Macros, Photo
- Tap meal to view detailed recipe
- Substitution options for each meal

**FR-NUTRITION-02: Calorie Tracking**
- Daily calorie target based on goal
- Progress circle showing consumed vs. target
- Color coding (under/on-track/over)

**FR-NUTRITION-03: Macro Tracking**
- Three progress rings:
  - Protein (grams)
  - Carbs (grams)
  - Fats (grams)
- Percentage of daily target
- Tap to view detailed breakdown

**FR-NUTRITION-04: Food Logging**
- "Log Food" button
- Search food database
- Manual entry option
- Meal category selection
- Portion size adjustment

**FR-NUTRITION-05: Generate Plan**
- "Generate Nutrition Plan" button
- Premium+ users: Immediate access
- Freemium users: Access with 7-day trial

**FR-NUTRITION-06: Freemium Trial Management (v2.0)**
- First generation starts 7-day trial
- Days 1-4: No warnings
- Day 5: Info banner "2 days left in trial"
- Day 6: Warning banner "1 day left"
- Day 7: Critical banner "Last day of trial!"
- Day 8+: Locked screen with upgrade prompt
- Banner shows countdown and "Upgrade" button

**FR-NUTRITION-07: Premium+ Persistent Access**
- Unlimited plan generations
- No expiry warnings
- Lifetime access to all nutrition features

**FR-NUTRITION-08: Meal Detail View**
- Recipe ingredients list
- Cooking instructions
- Nutrition facts
- Prep time and cook time
- Serving size
- Substitution suggestions

#### User Scenarios

**Scenario 1: Freemium User Trial**
```
Day 1: User generates first nutrition plan
→ System starts 7-day trial
→ User accesses plan normally for 4 days
Day 5: User sees "2 days left" banner
Day 7: User sees "Last day!" critical warning
Day 8: User opens nutrition
→ Locked screen appears
→ Message: "Your 7-day nutrition trial has expired"
→ "Upgrade to Premium" button
→ User upgrades or loses access
```

**Scenario 2: Premium User Daily Tracking**
```
User opens nutrition screen
→ Sees daily meal plan (2000 cal target)
→ Eaten breakfast (450 cal)
→ Logs snack manually (150 cal)
→ Checks progress: 600/2000 cal (30%)
→ Views macro rings:
   - Protein: 45/150g (30%)
   - Carbs: 60/200g (30%)
   - Fats: 20/67g (30%)
→ Reviews dinner recipe for meal prep
```

---

### 3.4 Coach Messaging Screen

#### Purpose
Real-time messaging with assigned fitness coach, including quota enforcement and optional attachments.

#### Requirements

**FR-MESSAGING-01: Message Display**
- Chat interface with:
  - User messages (right-aligned for LTR, left for RTL)
  - Coach messages (opposite side)
  - Timestamps
  - Read receipts
  - Message status (sending/sent/delivered/read)

**FR-MESSAGING-02: Send Messages**
- Text input field
- Send button (disabled when over quota)
- Character limit: 1000 per message
- Real-time quota check before sending

**FR-MESSAGING-03: Quota Enforcement (v2.0)**
- Before sending each message:
  - Check remaining quota
  - If at 0: Block send, show upgrade prompt
  - If at 80%+: Show warning toast
- Display quota in header: "5/20 messages left"

**FR-MESSAGING-04: Attachments (Premium+ Only)**
- Paper clip icon button
- Freemium/Premium: Button disabled with tooltip "Upgrade to Smart Premium for attachments"
- Smart Premium: 
  - Can attach images (JPEG, PNG, up to 5MB)
  - Can attach PDFs (up to 10MB)
  - Preview before sending
  - Multiple attachments per message

**FR-MESSAGING-05: Coach Info Header**
- Coach photo and name
- Online status indicator
- Tap to view coach profile

**FR-MESSAGING-06: Message Types**
- Text messages
- Images (Premium+)
- PDFs (Premium+)
- System messages (plan generated, workout completed)

**FR-MESSAGING-07: Video Call Booking**
- "Book Video Call" button in header
- Opens booking modal
- Shows remaining call quota
- Select date/time
- Duration based on tier (Freemium: 15min, Premium+: 25min)

**FR-MESSAGING-08: Post-Interaction Rating**
- After every 10 messages sent
- Modal appears: "How's your coaching experience?"
- 1-5 star rating
- Optional text feedback
- Can skip rating

#### User Scenarios

**Scenario 1: Freemium User Hits Quota**
```
User has sent 19/20 messages
→ Sends message 20
→ Toast warning: "Last message remaining this month!"
→ Tries to send message 21
→ Send button disabled
→ Modal appears:
   "Message Quota Exceeded
    You've used all 20 messages this month.
    Upgrade to Premium for 200 messages/month
    [Upgrade Now] [Maybe Later]"
→ User must upgrade or wait for monthly reset
```

**Scenario 2: Smart Premium Attachment**
```
User types message
→ Clicks attachment icon
→ Selects photo from device
→ Photo preview appears
→ Taps send
→ Message with photo delivered
→ Coach sees image in chat
```

**Scenario 3: Rating Prompt**
```
User sends 10th message
→ Message sends successfully
→ Rating modal appears:
   "How's your coaching experience?"
   ⭐⭐⭐⭐⭐
   [Optional feedback text box]
   [Submit] [Skip]
→ User selects 5 stars
→ Adds: "Great advice on form!"
→ Submits rating
→ Toast: "Thanks for your feedback!"
```

---

### 3.5 Store Screen

#### Purpose
Browse and purchase fitness products (equipment, supplements, apparel) with seamless checkout.

#### Requirements

**FR-STORE-01: Product Catalog**
- Grid display of products
- Each product card shows:
  - Product photo
  - Name
  - Price (SAR)
  - Star rating
  - "Add to Cart" button

**FR-STORE-02: Product Categories**
- Filter by category:
  - Equipment (weights, bands, mats)
  - Supplements (protein, pre-workout)
  - Apparel (shirts, shorts)
  - Accessories (bottles, bags)
- Category tabs or dropdown

**FR-STORE-03: Product Search**
- Search bar at top
- Real-time search results
- Shows matching products as user types

**FR-STORE-04: Product Detail View**
- Tap product to view details
- Shows:
  - Multiple product photos (swipeable)
  - Full description
  - Specifications
  - Price and stock status
  - Customer reviews
  - Related products
- Quantity selector
- "Add to Cart" button

**FR-STORE-05: Shopping Cart**
- Cart icon with item count badge
- View cart items
- Update quantities
- Remove items
- See subtotal, tax, shipping
- "Proceed to Checkout" button

**FR-STORE-06: Checkout Process**
- Shipping address form
- Payment method selection (Stripe/Paddle)
- Order summary
- Confirm and pay
- Order confirmation screen

**FR-STORE-07: Order History**
- "My Orders" section in Account
- List of past orders
- Order status (processing/shipped/delivered)
- Track shipment
- View order details
- Reorder option

#### User Scenarios

**Scenario 1: Buying Resistance Bands**
```
User taps "Store" from home
→ Views welcome screen (first time)
→ Taps "Start Shopping"
→ Browses products
→ Filters by "Equipment"
→ Taps "Resistance Bands Set - 5 Pieces"
→ Views product details
→ Sees 4.8★ rating, SAR 89.99
→ Reads 12 customer reviews
→ Selects quantity: 1
→ Taps "Add to Cart"
→ Toast: "Added to cart!"
→ Taps cart icon (1 item)
→ Reviews cart
→ Taps "Checkout"
→ Enters shipping address
→ Selects payment (credit card)
→ Confirms order
→ Order confirmation: "#FIT-1234"
→ Receives email confirmation
```

---

### 3.6 Progress Detail Screen

#### Purpose
Track and visualize fitness progress over time with weight trends, InBody scans, workout stats, and fitness score.

#### Requirements

**FR-PROGRESS-01: Weight Tracking**
- Line chart showing weight over time
- Data points for each weigh-in
- Trend line (gaining/losing/maintaining)
- Time range selector (1 week, 1 month, 3 months, all time)
- "Log Weight" button
- Shows starting weight, current weight, change

**FR-PROGRESS-02: Weight Logging**
- Quick weight entry
- Date selector (defaults to today)
- Weight input with kg/lbs toggle
- Optional notes field
- Save to history

**FR-PROGRESS-03: InBody Tracking (Premium+ Only)**
- List of InBody scans
- Each scan shows:
  - Date
  - Body fat %
  - Muscle mass
  - Visceral fat level
  - Body water %
- "Add InBody Scan" button
- Detailed input form with 10+ metrics

**FR-PROGRESS-04: Workout Statistics**
- Total workouts completed
- Current streak (consecutive days)
- Longest streak
- Total training time
- Most trained muscle groups
- Exercise completion rate

**FR-PROGRESS-05: Nutrition Statistics**
- Average daily calories
- Macro adherence rate
- Meal plan completion rate
- Days logged

**FR-PROGRESS-06: Fitness Score**
- Large circular progress indicator
- Current score (0-100)
- Score trend (up/down)
- Score factors breakdown:
  - Experience level
  - Workout frequency
  - Injury adjustments
- History of score changes

**FR-PROGRESS-07: Achievements/Milestones**
- Badges for milestones:
  - First workout completed
  - 7-day streak
  - 30-day streak
  - 10 workouts completed
  - 50 workouts completed
- Progress toward next milestone

#### User Scenarios

**Scenario 1: Tracking Weight Loss**
```
User opens Progress screen
→ Sees weight chart (last 3 months)
→ Starting weight: 95 kg
→ Current weight: 87 kg
→ Change: -8 kg (8.4% decrease)
→ Trend: Steady decline
→ Taps "Log Weight"
→ Enters today's weight: 86.5 kg
→ Adds note: "Feeling great!"
→ Saves entry
→ Chart updates with new data point
```

**Scenario 2: Premium+ InBody Tracking**
```
User visits gym, gets InBody scan
→ Opens Progress screen
→ Taps "Add InBody Scan"
→ Enters 12 metrics:
   - Weight: 87 kg
   - Body fat: 18.5%
   - Muscle mass: 68 kg
   - Visceral fat: 8
   - Body water: 60%
   - (+ 7 more metrics)
→ Saves scan
→ Views comparison with previous scan (4 weeks ago)
→ Muscle mass increased by 2 kg
→ Body fat decreased by 2%
→ Progress visualized in charts
```

---

### 3.7 Account Settings Screen

#### Purpose
Manage user profile, subscription, preferences, and app settings.

#### Requirements

**FR-ACCOUNT-01: Profile Information**
- Edit name
- Phone number (display only, verified)
- Gender
- Main goal
- Workout location
- Profile photo upload

**FR-ACCOUNT-02: Edit Intake Responses**
- "Edit Fitness Profile" button
- Access to first intake (all users)
- Access to second intake (Premium+ only, Freemium sees upgrade prompt)
- Update any responses
- Re-calculates fitness score if second intake changed

**FR-ACCOUNT-03: Subscription Management**
- Current tier display with badge
- Tier benefits list
- "Upgrade" button (if not on Smart Premium)
- Payment method on file
- Next billing date
- Billing history
- Cancel subscription option (with confirmation)

**FR-ACCOUNT-04: Coach Assignment**
- Current assigned coach
- Coach photo, name, specialization
- "Request Coach Change" button
- Admin approval required message

**FR-ACCOUNT-05: App Preferences**
- Language selection (English/Arabic)
- Notification settings
  - Workout reminders
  - Message notifications
  - Progress updates
- Theme (light/dark mode)
- Units (metric/imperial)

**FR-ACCOUNT-06: Help & Support**
- FAQ section
- Contact support
- App version info
- Terms of service
- Privacy policy

**FR-ACCOUNT-07: Logout**
- "Logout" button
- Confirmation dialog
- Clears session, returns to auth screen

#### User Scenarios

**Scenario 1: Upgrading Subscription**
```
User taps Settings
→ Views subscription section
→ Current: Freemium
→ Sees benefits of Premium:
   - 200 messages/month
   - 2 video calls
   - Unlimited nutrition access
   - Detailed fitness profile
→ Taps "Upgrade to Premium"
→ Navigates to checkout
→ Reviews price: $19.99/month
→ Enters payment info
→ Confirms subscription
→ Tier updates to Premium
→ Quota limits increased immediately
→ Prompt to complete second intake
```

---

### 3.8 Splash Screen

#### Purpose
Initial app loading screen shown when application first launches, providing brand recognition and smooth transition into the app.

#### Requirements

**FR-SPLASH-01: Brand Display**
- App logo (عاش branding) centered
- App name in both Arabic and English
- Brand colors (primary gradient or solid)
- Loading indicator (spinner or progress bar)
- Version number at bottom (small text)

**FR-SPLASH-02: Loading Duration**
- Minimum display time: 1.5 seconds
- Maximum display time: 3 seconds
- Smooth fade-out transition to next screen

**FR-SPLASH-03: Next Screen Logic**
- If user not authenticated → Language Selection Screen
- If user authenticated + no intake → First Intake Screen
- If user authenticated + intake complete → Home Screen
- If returning user → Home Screen (direct)

**FR-SPLASH-04: Offline Behavior**
- Show cached content if available
- Display "Connecting..." message if network slow
- Timeout after 5 seconds → Show offline message

#### User Scenarios

**Scenario 1: First Launch**
```
User opens app for first time
→ Sees splash screen with عاش logo
→ Loading animation plays (2 seconds)
→ Fades to Language Selection Screen
```

**Scenario 2: Returning User**
```
Returning user opens app
→ Sees splash screen (1.5 seconds)
→ Fades directly to Home Screen
→ Shows latest workout and nutrition data
```

---

### 3.9 Welcome Screens (Feature Intro)

#### Purpose
One-time welcome/intro screens shown when user first accesses a major feature (Workout, Nutrition, Store), explaining key features and benefits.

---

### 3.9.1 Workout Welcome Screen

#### Purpose
First-time introduction to workout features when user taps workout section from home.

#### Requirements

**FR-WORKOUT-WELCOME-01: Visual Design**
- Large hero illustration/image of person working out
- Title: "Welcome to Your Workout Journey" / "مرحباً برحلة تمارينك"
- Subtitle explaining workout features

**FR-WORKOUT-WELCOME-02: Key Features Highlight**
- 3-4 feature cards with icons:
  1. 📋 **Personalized Plans** - "Custom workout plans tailored to your goals"
  2. ⏱️ **Smart Timer** - "Built-in timer with rest periods"
  3. ⚠️ **Injury Safe** - "Safe alternatives for your injuries"
  4. 📊 **Track Progress** - "Log sets and track completion"

**FR-WORKOUT-WELCOME-03: Call-to-Action**
- Primary button: "Start Your First Workout" / "ابدأ أول تمرين"
- Secondary link: "Skip" / "تخطي"
- Checkbox: "Don't show this again" / "لا تظهر هذا مرة أخرى"

**FR-WORKOUT-WELCOME-04: Persistence**
- Show only once per user (unless reset in settings)
- Store flag in localStorage: `workout_intro_seen_${userId}`
- Can be re-accessed from Settings > Help > View Tutorials

#### User Scenarios

**Scenario 1: First Workout Access**
```
User completes second intake
→ Arrives at Home screen
→ Taps "Start Workout" button
→ Workout Welcome Screen appears
→ User reads feature highlights
→ Checks "Don't show this again"
→ Taps "Start Your First Workout"
→ Navigates to Workout Screen
→ Sees first workout plan
```

---

### 3.9.2 Nutrition Welcome Screen

#### Purpose
First-time introduction to nutrition features when user taps nutrition section.

#### Requirements

**FR-NUTRITION-WELCOME-01: Visual Design**
- Hero image of healthy meals
- Title: "Fuel Your Fitness Journey" / "اغذِّ رحلة لياقتك"
- Subtitle explaining nutrition tracking

**FR-NUTRITION-WELCOME-02: Key Features Highlight**
- 3-4 feature cards:
  1. 🍽️ **Meal Plans** - "Personalized daily meal plans"
  2. 📈 **Macro Tracking** - "Track protein, carbs, and fats"
  3. 🔄 **Meal Substitutions** - "Swap meals you don't like"
  4. 📱 **Easy Logging** - "Log food with one tap"

**FR-NUTRITION-WELCOME-03: Trial Information (Freemium)**
- Info box for Freemium users:
  - "✨ You get a 7-day free trial"
  - "Trial starts when you generate your first plan"
  - "Upgrade to Premium for unlimited access"
- No info box for Premium+ users

**FR-NUTRITION-WELCOME-04: Call-to-Action**
- Primary button: "Generate My Meal Plan" / "إنشاء خطة وجباتي"
- Secondary link: "Skip" / "تخطي"
- Checkbox: "Don't show this again"

**FR-NUTRITION-WELCOME-05: Persistence**
- Show only once per user
- Store flag: `nutrition_intro_seen_${userId}`
- Re-accessible from Settings

#### User Scenarios

**Scenario 1: Freemium First Access**
```
Freemium user taps "Nutrition" from home
→ Nutrition Welcome Screen appears
→ Sees feature highlights
→ Reads "7-day free trial" information
→ Taps "Generate My Meal Plan"
→ System generates nutrition plan
→ 7-day trial starts
→ Navigates to Nutrition Screen showing meal plan
```

**Scenario 2: Premium First Access**
```
Premium user taps "Nutrition"
→ Nutrition Welcome Screen appears
→ Sees feature highlights (no trial info)
→ Taps "Generate My Meal Plan"
→ System generates nutrition plan
→ No expiry set (unlimited access)
→ Navigates to Nutrition Screen
```

---

### 3.9.3 Store Welcome Screen

#### Purpose
First-time introduction to store features when user accesses shop.

#### Requirements

**FR-STORE-WELCOME-01: Visual Design**
- Hero image of fitness products (equipment, supplements)
- Title: "Shop Fitness Essentials" / "تسوق أساسيات اللياقة"
- Subtitle: "Everything you need for your fitness journey"

**FR-STORE-WELCOME-02: Key Features Highlight**
- 3-4 feature cards:
  1. 🏋️ **Quality Equipment** - "Weights, bands, and training gear"
  2. 💊 **Supplements** - "Protein, pre-workout, and vitamins"
  3. 👕 **Apparel** - "Workout clothes and accessories"
  4. 🚚 **Fast Delivery** - "Free shipping on orders over SAR 200"

**FR-STORE-WELCOME-03: Promotional Banner (Optional)**
- Highlight current promotions:
  - "🎉 New users get 10% off first order"
  - "Code: WELCOME10"
- Expiry date shown if applicable

**FR-STORE-WELCOME-04: Call-to-Action**
- Primary button: "Start Shopping" / "ابدأ التسوق"
- Secondary link: "Browse Categories" / "تصفح الفئات"
- Checkbox: "Don't show this again"

**FR-STORE-WELCOME-05: Persistence**
- Show only once per user
- Store flag: `store_intro_seen_${userId}`
- Re-accessible from Settings

#### User Scenarios

**Scenario 1: First Store Visit**
```
User taps "Store" from home
→ Store Welcome Screen appears
→ Views product categories and features
→ Sees "10% off first order" promotion
→ Taps "Start Shopping"
→ Navigates to Store Screen (product grid)
→ Can browse and shop immediately
```

---

### 3.9.4 Progress Welcome Screen

#### Purpose
First-time introduction to progress tracking features.

#### Requirements

**FR-PROGRESS-WELCOME-01: Visual Design**
- Hero image of progress charts/graphs
- Title: "Track Your Transformation" / "تتبع تحولك"
- Subtitle: "See your fitness journey visualized"

**FR-PROGRESS-WELCOME-02: Key Features Highlight**
- 3-4 feature cards:
  1. ⚖️ **Weight Tracking** - "Log weight and see trends"
  2. 💯 **Fitness Score** - "Your overall fitness rating"
  3. 📊 **Workout Stats** - "Streaks, totals, and achievements"
  4. 🏆 **Milestones** - "Earn badges for accomplishments"

**FR-PROGRESS-WELCOME-03: Quick Action**
- "Log Your Starting Weight" pre-filled form
- Optional: Take "before" photo
- Skip option available

**FR-PROGRESS-WELCOME-04: Call-to-Action**
- Primary button: "Log My Weight" / "تسجيل وزني"
- Secondary link: "Skip for Now" / "تخطي الآن"
- Checkbox: "Don't show this again"

**FR-PROGRESS-WELCOME-05: Persistence**
- Show only once per user
- Store flag: `progress_intro_seen_${userId}`

#### User Scenarios

**Scenario 1: First Progress Access**
```
User taps "Progress" from home
→ Progress Welcome Screen appears
→ Views feature highlights
→ Sees "Log Your Starting Weight" form
→ Enters starting weight: 95 kg
→ Taps "Log My Weight"
→ Weight saved as baseline
→ Navigates to Progress Screen
→ Sees weight chart with first data point
```

---

### 3.9.5 Welcome Screen Common Requirements

#### Requirements for All Welcome Screens

**FR-WELCOME-COMMON-01: Animation**
- Smooth fade-in animation (300ms)
- Slide-up animation for content (400ms)
- Staggered appearance of feature cards

**FR-WELCOME-COMMON-02: Accessibility**
- Screen reader announces screen purpose
- All buttons have ARIA labels
- Skip button always accessible
- Keyboard navigation supported

**FR-WELCOME-COMMON-03: Responsive Design**
- Mobile: Single column layout
- Tablet: 2-column feature grid
- Desktop: Centered content, max 800px width

**FR-WELCOME-COMMON-04: Localization**
- All text translated (Arabic/English)
- RTL layout for Arabic
- Images culturally appropriate

**FR-WELCOME-COMMON-05: Settings Access**
- All welcome screens accessible from Settings > Help > Tutorials
- "Reset Tutorial Screens" option in settings
- Clears all intro_seen flags

#### User Scenarios

**Scenario: Rewatching Tutorials**
```
User wants to review workout features
→ Opens Settings
→ Taps "Help & Support"
→ Taps "View Tutorials"
→ List shows:
   - Workout Tutorial
   - Nutrition Tutorial  
   - Store Tutorial
   - Progress Tutorial
→ User taps "Workout Tutorial"
→ Workout Welcome Screen appears
→ User can review features
→ "Don't show again" checkbox unchecked by default
```

---

## 4. Subscription Tier Feature Matrix

### Feature Access by Tier

| Feature | Freemium | Premium | Smart Premium |
|---------|----------|---------|---------------|
| **Authentication** | ✅ Phone OTP | ✅ Phone OTP | ✅ Phone OTP |
| **First Intake** | ✅ 3 questions | ✅ 3 questions | ✅ 3 questions |
| **Second Intake** | ✅ 6 questions | ✅ 6 questions | ✅ 6 questions |
| **Workout Plans** | ✅ Pre-made only | ✅ Custom plans | ✅ Custom plans |
| **Injury Substitution** | ✅ Basic | ✅ Advanced | ✅ Advanced |
| **Nutrition Plans** | ✅ 7-day trial | ✅ Unlimited | ✅ Unlimited |
| **Messages/Month** | ✅ 20 | ✅ 200 | ✅ Unlimited |
| **Video Calls/Month** | ✅ 1 (15 min) | ✅ 2 (25 min) | ✅ 4 (25 min) |
| **Chat Attachments** | ❌ Disabled | ❌ Disabled | ✅ Enabled |
| **InBody Tracking** | ❌ Upgrade prompt | ✅ Unlimited | ✅ Unlimited |
| **Progress Analytics** | ✅ Basic | ✅ Advanced | ✅ Advanced |
| **Store Access** | ✅ All products | ✅ All products | ✅ All products |
| **Language Support** | ✅ AR/EN | ✅ AR/EN | ✅ AR/EN |

---

## 5. User Acceptance Criteria

### Global Acceptance Criteria (Apply to All Features)

**AC-GLOBAL-01: Bilingual Support**
- GIVEN user selects Arabic language
- WHEN viewing any screen
- THEN all text is displayed in Arabic with RTL layout

**AC-GLOBAL-02: Responsive Design**
- GIVEN user accesses app on different devices
- WHEN screen size changes (mobile/tablet/desktop)
- THEN UI adapts to screen size appropriately

**AC-GLOBAL-03: Loading States**
- GIVEN any async operation (API call, data load)
- WHEN operation is in progress
- THEN user sees loading indicator (spinner/skeleton)

**AC-GLOBAL-04: Error Handling**
- GIVEN any operation fails
- WHEN error occurs
- THEN user sees clear error message in their language
- AND can retry or take corrective action

**AC-GLOBAL-05: Offline Behavior**
- GIVEN user loses internet connection
- WHEN attempting online action
- THEN user sees "Connection lost" message
- AND data is queued for retry when back online

### Feature-Specific Acceptance Criteria

**AC-AUTH-01: Phone OTP Authentication**
- GIVEN new user enters valid Saudi phone number (+966 5X XXX XXXX)
- WHEN user submits phone
- THEN OTP is sent within 30 seconds
- AND user can enter 6-digit code
- AND upon correct code, user is authenticated

**AC-AUTH-02: OTP Expiry**
- GIVEN user receives OTP
- WHEN 5 minutes pass without verification
- THEN OTP expires
- AND user must request new code

**AC-INTAKE-01: First Intake Completion**
- GIVEN new authenticated user
- WHEN user completes all 3 questions (gender, goal, location)
- THEN profile is saved
- AND user is navigated to home (Freemium) or second intake (Premium+)

**AC-INTAKE-02: Second Intake Gating**
- GIVEN Freemium user attempts second intake
- WHEN accessing second intake screen
- THEN upgrade prompt is shown
- AND second intake form is not accessible

**AC-QUOTA-01: Message Quota Enforcement**
- GIVEN Freemium user has sent 20/20 messages
- WHEN user attempts to send message 21
- THEN send button is disabled
- AND upgrade modal is shown
- AND message is not sent

**AC-QUOTA-02: Quota Visual Warning**
- GIVEN user has used 80% or more of message quota
- WHEN user sends a message
- THEN warning toast appears: "X messages remaining"
- AND message is sent successfully

**AC-NUTRITION-01: Freemium Trial Expiry**
- GIVEN Freemium user generated first plan 7 days ago
- WHEN user opens nutrition screen on day 8
- THEN locked screen appears
- AND upgrade prompt is shown
- AND meal plan is not accessible

**AC-NUTRITION-02: Premium Persistent Access**
- GIVEN Premium user generated nutrition plan
- WHEN any number of days pass
- THEN user can access nutrition screen without restrictions
- AND no expiry warnings are shown

**AC-INJURY-01: Exercise Substitution**
- GIVEN user has selected "knee" injury in second intake
- WHEN viewing workout with barbell squats
- THEN "⚠️ Safe Alternative" badge is shown
- AND tap opens substitution modal
- AND 3 alternative exercises are suggested
- AND user can replace with one click

**AC-ATTACHMENT-01: Freemium Attachment Blocking**
- GIVEN Freemium user in message screen
- WHEN user taps attachment icon
- THEN button is disabled
- AND tooltip shows "Upgrade to Smart Premium for attachments"
- AND no file picker opens

**AC-ATTACHMENT-02: Smart Premium Attachment**
- GIVEN Smart Premium user in message screen
- WHEN user taps attachment icon
- THEN file picker opens
- AND user can select image or PDF
- AND file is attached to message
- AND message sends with attachment

---

## 6. Non-Functional Requirements (User Perspective)

### Performance
- **NFR-PERF-01**: App loads within 3 seconds on 4G connection
- **NFR-PERF-02**: Screen transitions complete within 300ms
- **NFR-PERF-03**: Search results appear within 1 second of typing

### Usability
- **NFR-USE-01**: Touch targets are minimum 44x44px for finger taps
- **NFR-USE-02**: Text is readable (minimum 14px font size)
- **NFR-USE-03**: Color contrast meets WCAG 2.1 AA standards
- **NFR-USE-04**: Error messages are clear and actionable

### Reliability
- **NFR-REL-01**: App doesn't crash during normal usage
- **NFR-REL-02**: Data is auto-saved to prevent loss
- **NFR-REL-03**: Workout timer works offline

### Security
- **NFR-SEC-01**: User data is encrypted in transit (HTTPS)
- **NFR-SEC-02**: Phone numbers are verified before account creation
- **NFR-SEC-03**: No PII is visible in URLs or logs

### Accessibility
- **NFR-ACC-01**: Screen readers can navigate all screens
- **NFR-ACC-02**: Keyboard navigation is supported (web)
- **NFR-ACC-03**: RTL layout works correctly for Arabic

---

## 7. User Feedback & Improvement Tracking

### Success Metrics

**Engagement Metrics**
- Daily Active Users (DAU): Target 60%
- Workout Completion Rate: Target 70%
- Nutrition Plan Generation Rate: Target 50%
- Message Activity: Average 10 messages/month per user

**Conversion Metrics**
- Freemium to Premium: Target 15% within 30 days
- Premium to Smart Premium: Target 10%
- Churn Rate: Target < 10% monthly

**Quality Metrics**
- Average Coach Rating: Target 4.5+ stars
- App Store Rating: Target 4.7+ stars
- Support Tickets: Target < 5% of active users

### User Feedback Channels

1. **In-App Ratings**: After video calls and every 10 messages
2. **App Store Reviews**: Monitored weekly
3. **Support Tickets**: Customer service team
4. **User Surveys**: Quarterly NPS surveys
5. **Coach Feedback**: Coaches report user pain points

---

## 8. Future Enhancements (User Requests)

### Planned for v2.1
- Push notifications for workout reminders
- Social features (friend challenges, leaderboards)
- Integration with wearable devices (Apple Watch, Fitbit)
- Video library of exercise demonstrations
- Meal prep calculator

### Under Consideration for v3.0
- AI-powered form checking via camera
- Voice-guided workouts
- Nutrition barcode scanner
- Group coaching sessions
- Corporate wellness programs

---

## Appendix A: User Journey Flowcharts

### First-Time User Complete Journey

```
[App Launch] → [Language Selection] → [Intro Slides] → [Phone Auth]
                                                             ↓
                                                    [Phone Number Entry]
                                                             ↓
                                                    [OTP Verification]
                                                             ↓
                                                      [First Intake]
                                                             ↓
                                        ┌────────────────────┴────────────────────┐
                                        ↓                                         ↓
                                   [Freemium]                              [Premium/Smart]
                                        ↓                                         ↓
                                    [Home]                                [Second Intake]
                                                                                  ↓
                                                                              [Home]
```

### Weekly User Activity Journey

```
Monday: Login → Home → Start Workout → Complete → Log Progress
Tuesday: Login → Home → Check Nutrition → Message Coach
Wednesday: Rest Day → Check Progress → Browse Store
Thursday: Login → Home → Start Workout → Complete
Friday: Login → Home → Book Video Call → Message Coach
```

---

## Document Maintenance

- **Owner**: Product Manager
- **Contributors**: UX Designer, Customer Success Team
- **Review Cycle**: Monthly or on major feature changes
- **Last Review**: December 2024
- **Next Review**: January 2025

---

**End of End User Requirements Document**