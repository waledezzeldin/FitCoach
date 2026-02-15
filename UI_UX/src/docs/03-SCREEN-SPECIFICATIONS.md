# FitCoach+ v2.0 - Screen Specifications

## Document Information
- **Document**: Detailed Screen-by-Screen Specifications
- **Version**: 2.0.0
- **Last Updated**: December 8, 2024
- **Purpose**: Comprehensive UI/UX requirements for all 28 screens

---

## Table of Contents

### User Journey Screens (12)
1. Language Selection Screen
2. App Intro Screen
3. Phone OTP Authentication Screen
4. First Intake Screen
5. Second Intake Screen
6. Home Dashboard Screen
7. Workout Screen
8. Nutrition Screen
9. Coach Messaging Screen
10. Store Screen
11. Account Settings Screen
12. Progress Detail Screen

### Coach Tools (6)
13. Coach Dashboard
14. Coach Calendar Screen
15. Coach Messaging Screen
16. Workout Plan Builder
17. Nutrition Plan Builder
18. Coach Earnings Screen

### Admin Dashboard (8)
19. Admin Main Dashboard
20. User Management Screen
21. Coach Management Screen
22. Content Management Screen
23. Store Management Screen
24. Subscription Management Screen
25. System Settings Screen
26. Analytics Dashboard

### Supporting Screens (2)
27. Exercise Library Screen (Modal)
28. Video Booking Screen (Modal)

---

# PART 1: USER JOURNEY SCREENS

## 1. Language Selection Screen

### Purpose
Initial screen for first-time users to select their preferred language (English or Arabic). This choice affects the entire app's text direction and content.

### Entry Point
- First screen shown when app loads (if no language previously selected)
- Accessible from Settings for language switching

### UI Components

#### Top Section
- **App Logo**: Centered, large FitCoach+ branding
- **Welcome Text**: "Welcome to FitCoach+" / "مرحباً بك في FitCoach+"
- **Subtitle**: "Select your language" / "اختر لغتك"

#### Language Options (Cards)
- **English Card**
  - Flag icon (🇬🇧 or 🇺🇸)
  - "English" label
  - Chevron right icon
  - Border highlight on hover
  - Full-width button style

- **Arabic Card**
  - Flag icon (🇸🇦)
  - "العربية" label
  - Chevron left icon (for RTL)
  - Border highlight on hover
  - Full-width button style

### User Interactions
1. User clicks/taps on language card
2. App immediately switches to selected language
3. App stores selection in localStorage: `fitcoach_language`
4. App reloads with selected language and direction
5. Navigate to App Intro Screen

### Data Requirements
- **Input**: None (initial screen)
- **Output**: `language` ('en' | 'ar')
- **Storage**: localStorage key `fitcoach_language`

### Validation
- No validation required (button selection only)

### Navigation Flow
- **Next**: App Intro Screen (automatic)
- **Back**: None (first screen)

### RTL Considerations
- English: LTR layout, icons on right
- Arabic: RTL layout, icons on left, Arabic font family

### Accessibility
- Large touch targets (minimum 44x44px)
- High contrast text
- Clear visual hierarchy
- Keyboard navigation support

---

## 2. App Intro Screen

### Purpose
Three-slide carousel introducing app features and value propositions. Creates excitement and sets expectations for new users.

### Entry Point
- Shown after Language Selection (if first time)
- Can be accessed from Help section (for returning users)

### UI Components

#### Slide Indicator
- 3 dots at bottom
- Current slide highlighted
- Smooth transition animations

#### Slide 1: "Track Your Fitness Journey"
- **Hero Image**: Illustration of person with workout tracker
- **Title**: "Track Your Fitness Journey" / "تتبع رحلة لياقتك"
- **Description**: "Get personalized workout and nutrition plans tailored to your goals" / "احصل على خطط تمارين وتغذية مخصصة لأهدافك"
- **Button**: "Next" / "التالي"

#### Slide 2: "Connect with Expert Coaches"
- **Hero Image**: Illustration of coach and client video call
- **Title**: "Connect with Expert Coaches" / "تواصل مع مدربين محترفين"
- **Description**: "Real-time messaging and video calls with certified fitness professionals" / "رسائل ومكالمات فيديو مباشرة مع محترفي اللياقة المعتمدين"
- **Button**: "Next" / "التالي"

#### Slide 3: "Achieve Your Goals"
- **Hero Image**: Illustration of person celebrating success
- **Title**: "Achieve Your Goals" / "حقق أهدافك"
- **Description**: "Join thousands of users transforming their lives with FitCoach+" / "انضم إلى آلاف المستخدمين الذين يغيرون حياتهم مع FitCoach+"
- **Button**: "Get Started" / "ابدأ الآن"

#### Skip Button
- Top-right corner (LTR) / Top-left corner (RTL)
- "Skip" / "تخطي"
- Available on all slides

### User Interactions
1. **Swipe**: Horizontal swipe to navigate slides
2. **Next Button**: Click to advance to next slide
3. **Skip Button**: Jump directly to auth screen
4. **Auto-advance**: Optional 5-second auto-advance per slide

### Data Requirements
- **Input**: None
- **Output**: Completion flag
- **Storage**: localStorage key `fitcoach_intro_seen` = 'true'

### Validation
- No validation required

### Navigation Flow
- **Next**: Phone OTP Authentication Screen
- **Back**: Language Selection Screen (via language switcher only)
- **Skip**: Phone OTP Authentication Screen

### RTL Considerations
- Swipe direction reversed for Arabic
- Skip button positioned top-left
- Text alignment right
- Slide transition from right to left

### Accessibility
- Alt text for images
- ARIA labels for navigation
- Keyboard arrow keys for navigation
- Focus indicators

---

## 3. Phone OTP Authentication Screen (v2.0)

### Purpose
Saudi phone number verification using one-time password (OTP) sent via SMS. Secure, password-less authentication.

### Entry Point
- After App Intro Screen
- When user logs out and needs to log back in

### UI Components

#### Phase 1: Phone Number Entry

**Header**
- Back button (top-left LTR / top-right RTL)
- Title: "Welcome Back" / "مرحباً بك مجدداً"
- Subtitle: "Enter your phone number to continue" / "أدخل رقم هاتفك للمتابعة"

**Phone Input Field**
- Label: "Phone Number" / "رقم الهاتف"
- Prefix: "+966" (Saudi country code, non-editable)
- Input: 9 digits (e.g., "512345678")
- Format: "+966 5X XXX XXXX" (auto-formatted as user types)
- Placeholder: "5X XXX XXXX"
- Error state: Red border with message
- Success state: Green checkmark icon

**Validation Messages**
- "Phone number is required" / "رقم الهاتف مطلوب"
- "Please enter a valid Saudi phone number" / "الرجاء إدخال رقم هاتف سعودي صحيح"
- "Phone number must start with 5" / "يجب أن يبدأ رقم الهاتف بـ 5"

**Send OTP Button**
- Full-width primary button
- "Send Code" / "إرسال الرمز"
- Disabled until valid phone entered
- Loading state with spinner

**Demo Mode Link**
- Bottom of screen
- "Try Demo Mode" / "جرب الوضع التجريبي"
- Opens demo mode switcher

---

#### Phase 2: OTP Verification

**Header**
- Back button (returns to phone entry)
- Title: "Verify Phone Number" / "تأكيد رقم الهاتف"
- Subtitle: "Enter the 6-digit code sent to +966 5X XXX XXXX" / "أدخل الرمز المكون من 6 أرقام المرسل إلى..."

**OTP Input**
- 6 separate input boxes (digit-by-digit)
- Auto-focus on next box after digit entered
- Auto-submit when all 6 digits entered
- Clear button to reset all inputs
- Numeric keyboard on mobile

**Timer & Resend**
- "Resend code in 0:45" / "إعادة إرسال الرمز خلال 0:45"
- Countdown from 60 seconds
- After timeout: "Didn't receive code? Resend" / "لم تستلم الرمز؟ إعادة إرسال"
- Resend button triggers new OTP

**Verify Button**
- Full-width primary button
- "Verify" / "تأكيد"
- Disabled until 6 digits entered
- Loading state during verification

**Error Messages**
- "Invalid code. Please try again." / "رمز غير صحيح. حاول مرة أخرى."
- "Code expired. Please request a new one." / "انتهت صلاحية الرمز. اطلب رمزاً جديداً."
- "Too many attempts. Please try again in 5 minutes." / "محاولات كثيرة جداً. حاول مرة أخرى بعد 5 دقائق."

### User Interactions

**Phone Entry Flow**
1. User enters phone number
2. Input validates format in real-time
3. User clicks "Send Code"
4. API generates and sends OTP via SMS
5. Screen transitions to OTP entry phase

**OTP Verification Flow**
1. User receives SMS with 6-digit code
2. User enters code digit by digit
3. Auto-submit when complete OR manual verify click
4. API validates OTP
5. If valid: Check if user exists
   - **New User**: Navigate to First Intake
   - **Existing User**: Load profile, navigate to Home
6. If invalid: Show error, allow retry

**Resend Flow**
1. User waits for countdown (60 seconds)
2. Clicks "Resend" when available
3. New OTP generated and sent
4. Timer resets

### Data Requirements

**Input**
- Phone number (string, 9 digits)
- OTP code (string, 6 digits)

**Output**
- Authentication token (JWT or session ID)
- User profile data (if existing user)

**API Endpoints**
- `POST /api/auth/send-otp` → { phoneNumber: "+966512345678" }
- `POST /api/auth/verify-otp` → { phoneNumber: "+966512345678", otpCode: "123456" }

**Response**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "phoneNumber": "+966512345678",
    "name": "Ahmed",
    "isNewUser": false
  }
}
```

### Validation

**Phone Number**
```typescript
function validateSaudiPhone(phone: string): boolean {
  // Must be exactly 9 digits starting with 5
  const regex = /^5[0-9]{8}$/;
  return regex.test(phone);
}
```

**OTP Code**
```typescript
function validateOTP(code: string): boolean {
  // Must be exactly 6 digits
  const regex = /^[0-9]{6}$/;
  return regex.test(code);
}
```

### Security Considerations
- OTP expires after 5 minutes
- Maximum 3 failed verification attempts before lockout
- 5-minute lockout after excessive attempts
- Rate limiting on send-otp endpoint (max 3 requests per hour per phone)
- SMS provider: Twilio or AWS SNS

### Navigation Flow
- **Back** (Phase 1): App Intro Screen
- **Back** (Phase 2): Return to phone entry (Phase 1)
- **Next** (New User): First Intake Screen
- **Next** (Existing User): Home Dashboard Screen
- **Demo Mode**: Opens Demo Mode Switcher overlay

### RTL Considerations
- Phone input: LTR for digits (always)
- OTP boxes: LTR for digits
- Back button: Top-right for Arabic
- Text alignment: Right for Arabic

### Error States
- Network error: "Connection failed. Please check your internet." / "فشل الاتصال. تحقق من الإنترنت."
- Server error: "Something went wrong. Please try again." / "حدث خطأ ما. حاول مرة أخرى."
- Timeout: "Request timed out. Please try again." / "انتهى وقت الطلب. حاول مرة أخرى."

---

## 4. First Intake Screen (v2.0)

### Purpose
Quick 3-question intake for ALL users (Freemium, Premium, Smart Premium). Collects essential fitness profile data to personalize experience.

### Entry Point
- After successful OTP verification (new users only)
- Cannot be skipped (required for onboarding)

### UI Components

#### Progress Indicator
- Top of screen
- "Step 1 of 2" / "الخطوة 1 من 2"
- Progress bar: 33% filled (1 of 3 questions answered)

#### Header
- Back button (returns to auth - rare case)
- Title: "Let's Get Started" / "لنبدأ"
- Subtitle: "Tell us about your fitness goals" / "أخبرنا عن أهداف لياقتك"

---

#### Question 1: Gender

**Label**: "What is your gender?" / "ما هو جنسك؟"

**Options** (Radio buttons / Cards)
- 🚹 Male / ذكر
- 🚺 Female / أنثى
- ⚧ Other / آخر

**Design**: Large card buttons with icons, single selection

---

#### Question 2: Main Goal

**Label**: "What is your main fitness goal?" / "ما هو هدفك الرئيسي للياقة؟"

**Options** (Cards with icons)
- 🔥 Fat Loss / خسارة الدهون
  - Subtitle: "Lose weight and get leaner" / "اخسر وزناً واحصل على جسم أنحف"
  
- 💪 Muscle Gain / بناء العضلات
  - Subtitle: "Build muscle and strength" / "ابنِ عضلات وقوة"
  
- 🎯 General Fitness / لياقة عامة
  - Subtitle: "Stay healthy and active" / "ابقَ بصحة جيدة ونشيط"

**Design**: 3 cards in grid (1 column mobile, 2 columns tablet), single selection

---

#### Question 3: Workout Location

**Label**: "Where will you workout?" / "أين ستتمرن؟"

**Options** (Large toggle buttons)
- 🏠 Home / المنزل
  - Subtitle: "Bodyweight and minimal equipment" / "وزن الجسم ومعدات قليلة"
  
- 🏋️ Gym / صالة الألعاب الرياضية
  - Subtitle: "Full access to gym equipment" / "وصول كامل لمعدات الصالة"

**Design**: 2 equal-width cards, single selection

---

#### Navigation Buttons

**Bottom Section**
- **Next Button**
  - Full-width primary button
  - "Continue" / "متابعة"
  - Disabled until all 3 questions answered
  - Smooth color transition when enabled

### User Interactions

**Selection Flow**
1. Screen loads with all questions visible (scrollable)
2. User selects gender → question 1 marked complete (✓)
3. User selects goal → question 2 marked complete (✓)
4. User selects location → question 3 marked complete (✓)
5. "Continue" button becomes enabled
6. User clicks Continue
7. Data validated and saved
8. Navigate to home (Freemium) or Second Intake prompt (Premium+)

**Visual Feedback**
- Selected option: Border color change, checkmark icon
- Completed question: Green checkmark next to question label
- Progress bar updates: 33% → 66% → 100%

### Data Requirements

**Data Structure**
```typescript
interface FirstIntakeData {
  gender: 'male' | 'female' | 'other';
  mainGoal: 'fat_loss' | 'muscle_gain' | 'general_fitness';
  workoutLocation: 'home' | 'gym';
  completedAt: Date;
}
```

**Storage**
- Merged into UserProfile immediately
- No separate table needed
- API endpoint: `POST /api/users/{userId}/first-intake`

### Validation

**Rules**
- All 3 questions required (no skip option)
- Must select exactly one option per question
- Client-side validation before API call

**Validation Function**
```typescript
function validateFirstIntake(data: Partial<FirstIntakeData>): boolean {
  return !!(data.gender && data.mainGoal && data.workoutLocation);
}
```

**Error Messages**
- Generic: "Please answer all questions to continue" / "الرجاء الإجابة على جميع الأسئلة للمتابعة"
- (No per-question errors since all visible)

### Navigation Flow

**Logic After Completion**
```typescript
// After successful first intake submission:
if (userProfile.subscriptionTier === 'Freemium') {
  navigate('home');
} else if (userProfile.subscriptionTier === 'Premium' || userProfile.subscriptionTier === 'Smart Premium') {
  navigate('secondIntake');
}
```

- **Freemium Users**: → Home Dashboard (intake complete)
- **Premium/Smart Premium Users**: → Second Intake Screen (detailed questions)

**Back Navigation**
- Disabled during intake (prevent incomplete profiles)
- If user really wants to go back, logout and restart

### Post-Submission Actions

1. **Save to database**
```json
PUT /api/users/{userId}
{
  "gender": "male",
  "mainGoal": "muscle_gain",
  "workoutLocation": "gym"
}
```

2. **Update UserProfile state**
```typescript
setUserProfile({
  ...userProfile,
  gender,
  mainGoal,
  workoutLocation
});
```

3. **Set localStorage flag**
```typescript
localStorage.setItem(`first_intake_completed_${phoneNumber}`, 'true');
```

4. **Navigate to next screen** (see logic above)

### RTL Considerations
- Question text: Right-aligned for Arabic
- Option cards: Maintain icon → text order (reversed in RTL)
- Progress bar: Fills right-to-left for Arabic
- Checkmarks: Positioned on left side of questions for Arabic

### Accessibility
- Labels for screen readers on all options
- ARIA attributes for progress indicator
- Keyboard navigation (Tab, Enter to select)
- High contrast for selected states

### Demo Mode Behavior
- Pre-filled with mock data
- All questions answered by default
- Can be changed before submission

---

## 5. Second Intake Screen (v2.0)

### Purpose
Detailed 6-question intake exclusively for **Premium and Smart Premium users**. Collects comprehensive fitness data for personalized plans and injury-aware programming.

### Entry Point
- After First Intake Screen (Premium+ users only)
- Accessible from Account Settings for profile updates
- **Freemium users**: See upgrade prompt instead

### Gate Check

#### For Freemium Users
```typescript
if (userProfile.subscriptionTier === 'Freemium') {
  // Show upgrade prompt modal
  return <UpgradePrompt
    title="Unlock Detailed Profile"
    message="Upgrade to Premium to complete your detailed fitness profile and get personalized plans."
    requiredTier="Premium"
  />;
}
```

**Upgrade Prompt UI**
- 🔒 Lock icon
- Title: "Premium Feature" / "ميزة مميزة"
- Message explaining benefit
- "Upgrade Now" button → Checkout Screen
- "Maybe Later" button → Home Screen

---

### UI Components (Premium+ Users Only)

#### Progress Indicator
- Top of screen
- "Step 2 of 2" / "الخطوة 2 من 2"
- Progress bar updates as questions answered (0% → 100%)

#### Header
- Back button (returns to first intake - if editing)
- Title: "Complete Your Profile" / "أكمل ملفك الشخصي"
- Subtitle: "Help us personalize your fitness plan" / "ساعدنا في تخصيص خطة لياقتك"

---

#### Question 1: Age

**Label**: "What is your age?" / "ما هو عمرك؟"

**Input Type**: Number input with stepper buttons

**Components**
- Decrement button (-)
- Number display (large, centered)
- Increment button (+)
- Keyboard input enabled (tap number to type)

**Constraints**
- Min: 13 years
- Max: 120 years
- Default: 25 (pre-filled)

**Validation Message**
- "Age must be between 13 and 120" / "يجب أن يكون العمر بين 13 و 120"

---

#### Question 2: Weight

**Label**: "What is your current weight?" / "ما هو وزنك الحالي؟"

**Input Type**: Number input with unit toggle

**Components**
- Decrement button (- 0.5 kg steps)
- Weight display: "75.5 kg" (large, bold)
- Increment button (+ 0.5 kg steps)
- Unit toggle: kg ⇄ lbs (conversion automatic)
- Keyboard input enabled

**Constraints**
- Min: 30 kg (66 lbs)
- Max: 300 kg (661 lbs)
- Default: 70 kg (154 lbs)
- Step: 0.5 kg (1 lb)

**Validation Message**
- "Weight must be between 30-300 kg" / "يجب أن يكون الوزن بين 30-300 كجم"

---

#### Question 3: Height

**Label**: "What is your height?" / "ما هو طولك؟"

**Input Type**: Number input with unit toggle

**Components**
- Decrement button (- 1 cm steps)
- Height display: "175 cm" (large, bold)
- Increment button (+ 1 cm steps)
- Unit toggle: cm ⇄ ft/in (conversion automatic)
- Keyboard input enabled

**Constraints**
- Min: 100 cm (3'3")
- Max: 250 cm (8'2")
- Default: 170 cm (5'7")
- Step: 1 cm

**Validation Message**
- "Height must be between 100-250 cm" / "يجب أن يكون الطول بين 100-250 سم"

---

#### Question 4: Experience Level

**Label**: "What is your fitness experience level?" / "ما هو مستوى خبرتك في اللياقة؟"

**Options** (Cards with icons and descriptions)

- 🌱 **Beginner** / مبتدئ
  - "Little to no gym experience" / "خبرة قليلة أو معدومة في الصالة"
  - "Learning basic movements" / "تعلم الحركات الأساسية"

- 🔄 **Intermediate** / متوسط
  - "Regular training for 6+ months" / "تمارين منتظمة لأكثر من 6 أشهر"
  - "Comfortable with most exercises" / "راحة مع معظم التمارين"

- 💎 **Advanced** / متقدم
  - "Years of consistent training" / "سنوات من التمارين المستمرة"
  - "Advanced techniques and programs" / "تقنيات وبرامج متقدمة"

**Design**: 3 vertical cards, single selection

---

#### Question 5: Workout Frequency

**Label**: "How many days per week can you workout?" / "كم يوماً في الأسبوع تستطيع التمرين؟"

**Input Type**: Segmented control / Slider

**Options**
- 2 days
- 3 days
- 4 days
- 5 days
- 6 days

**Components**
- Horizontal segmented control (mobile)
- Slider with number display (alternative)

**Constraints**
- Min: 2 days
- Max: 6 days
- Default: 4 days

**Visual Indicator**
- Selected option: Filled background, white text
- Unselected: Outline only

---

#### Question 6: Injuries (Critical for v2.0)

**Label**: "Do you have any existing injuries?" / "هل لديك أي إصابات حالية؟"

**Subtitle**: "We'll suggest safe alternatives" / "سنقترح بدائل آمنة"

**Input Type**: Multi-select checkboxes (can select multiple or none)

**Options** (Checkboxes with injury icons)
- 💪 Shoulder / الكتف
- 🦵 Knee / الركبة
- 🔙 Lower Back / أسفل الظهر
- 🙍 Neck / الرقبة
- 🦶 Ankle / الكاحل
- ✅ None / لا يوجد (clears all others if selected)

**Design**
- 2-column grid (mobile), 3-column (tablet)
- Checkboxes with icon, label, and checkmark when selected
- "None" option clears all others automatically

**Special Behavior**
- If "None" checked → uncheck all injury boxes
- If any injury checked → auto-uncheck "None"
- Can select multiple injuries simultaneously

---

#### Navigation Buttons

**Bottom Section**
- **Complete Profile Button**
  - Full-width primary button
  - "Complete Profile" / "أكمل الملف الشخصي"
  - Disabled until all 6 questions answered
  - Loading state during submission
  - Success animation on completion

### User Interactions

**Progressive Disclosure Flow**
1. Screen loads with all questions visible (scrollable)
2. User scrolls through questions, answering each
3. Progress bar updates: 0% → 16.67% per question → 100%
4. Each answered question gets green checkmark
5. "Complete Profile" button enables when all valid
6. User submits
7. Success toast: "Profile completed! 🎉"
8. Navigate to Home Dashboard

**Input Interactions**
- **Number inputs**: Tap +/- buttons or tap number to type
- **Toggles**: Tap to switch units (kg/lbs, cm/ft)
- **Cards**: Tap to select (single selection)
- **Checkboxes**: Tap to toggle (multi-selection)

### Data Requirements

**Data Structure**
```typescript
interface SecondIntakeData {
  age: number;                         // 13-120
  weight: number;                      // kg, 30-300
  height: number;                      // cm, 100-250
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
  workoutFrequency: number;            // 2-6
  injuries: InjuryArea[];              // ['shoulder', 'knee', ...]
  completedAt: Date;
}
```

**Storage**
- Merged into UserProfile
- Flag set: `hasCompletedSecondIntake = true`
- API endpoint: `POST /api/users/{userId}/second-intake`

**Fitness Score Calculation** (Automatic)
```typescript
function calculateFitnessScore(data: SecondIntakeData): number {
  let score = 50; // Base score
  
  // Experience boost
  if (data.experienceLevel === 'beginner') score += 0;
  if (data.experienceLevel === 'intermediate') score += 15;
  if (data.experienceLevel === 'advanced') score += 30;
  
  // Frequency boost
  score += (data.workoutFrequency - 2) * 3;
  
  // Injury penalty
  score -= data.injuries.length * 5;
  
  return Math.max(0, Math.min(100, score));
}
```

### Validation

**Individual Question Validation**
```typescript
function validateSecondIntake(data: Partial<SecondIntakeData>): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];
  
  if (!data.age || data.age < 13 || data.age > 120) {
    errors.push('Age must be between 13-120');
  }
  if (!data.weight || data.weight < 30 || data.weight > 300) {
    errors.push('Weight must be between 30-300 kg');
  }
  if (!data.height || data.height < 100 || data.height > 250) {
    errors.push('Height must be between 100-250 cm');
  }
  if (!data.experienceLevel) {
    errors.push('Experience level is required');
  }
  if (!data.workoutFrequency || data.workoutFrequency < 2 || data.workoutFrequency > 6) {
    errors.push('Workout frequency must be 2-6 days');
  }
  // Injuries can be empty array (valid)
  
  return {
    isValid: errors.length === 0,
    errors
  };
}
```

**Real-Time Validation**
- Age: Shows error if < 13 or > 120
- Weight: Shows error if < 30 or > 300 kg
- Height: Shows error if < 100 or > 250 cm
- Experience: Required selection
- Frequency: Required selection (2-6)
- Injuries: Optional (none selected is valid)

### Navigation Flow
- **Back**: First Intake Screen (if editing)
- **Next**: Home Dashboard Screen
- **On Freemium**: Upgrade Prompt Modal

### Post-Submission Actions

1. **Calculate fitness score**
```typescript
const fitnessScore = calculateFitnessScore(secondIntakeData);
```

2. **Update UserProfile**
```typescript
PUT /api/users/{userId}
{
  "age": 28,
  "weight": 75,
  "height": 175,
  "experienceLevel": "intermediate",
  "workoutFrequency": 4,
  "injuries": ["knee"],
  "hasCompletedSecondIntake": true,
  "fitnessScore": 65,
  "fitnessScoreUpdatedBy": "auto"
}
```

3. **Set localStorage flag**
```typescript
localStorage.setItem(`second_intake_completed_${phoneNumber}`, 'true');
```

4. **Show success notification**
```typescript
toast.success('Profile completed! Your personalized plan is ready.');
```

5. **Navigate to Home**
```typescript
navigate('home');
```

### Injury Substitution Setup

**On Submission**
- If injuries selected → store in `userProfile.injuries`
- Exercise substitution engine activated automatically
- All workout plans will check against injury list
- WorkoutScreen shows "⚠️ Safe Alternative" badges

### RTL Considerations
- Number inputs: Digits always LTR
- Unit toggles: Label text RTL, but kg/lbs/cm/ft always LTR
- Progress bar: Fills right-to-left for Arabic
- Checkbox grid: RTL order (right to left)
- +/- buttons: Positions swapped for RTL (+ on left, - on right)

### Accessibility
- ARIA labels for all inputs
- Screen reader announces progress
- Keyboard navigation for all inputs
- High contrast for selected states
- Error messages announced by screen reader

### Demo Mode Behavior
- Pre-filled with realistic data
- Age: 28
- Weight: 75 kg
- Height: 175 cm
- Experience: Intermediate
- Frequency: 4 days
- Injuries: ["knee"] (demonstrates substitution feature)

---

## 6. Home Dashboard Screen

### Purpose
Central hub displaying user's fitness overview, quick access to main features, subscription status, quota usage, and daily workout/nutrition summaries. Primary navigation point for the entire app.

### Entry Point
- After successful authentication (existing users)
- After completing intake (new users)
- Bottom navigation "Home" button
- Default screen for logged-in users

### UI Components

#### Header Section

**Top Bar**
- **Greeting**
  - "Good Morning, [Name]" / "صباح الخير، [الاسم]"
  - Time-based: Morning (6am-12pm), Afternoon (12pm-6pm), Evening (6pm-12am), Night (12am-6am)
  
- **Settings Icon**
  - Top-right (LTR) / Top-left (RTL)
  - Gear icon
  - Navigates to Account Settings

- **Demo Mode Indicator** (if active)
  - Badge showing "Demo Mode"
  - User switcher access

---

#### Subscription Card (v2.0)

**For All Tiers**
- Card with gradient background (color per tier)
  - Freemium: Gray gradient
  - Premium: Purple gradient
  - Smart Premium: Gold gradient

**Content**
- 👑 Tier icon (crown for Premium+)
- **Tier Name**: "Freemium" / "Premium" / "Smart Premium"
- **Upgrade Button** (if Freemium or Premium)
  - "Upgrade" / "ترقية"
  - Navigates to Checkout Screen
  
**For Premium+ Users**
- "Active" badge
- Expiry date: "Renews on Dec 15, 2024"

---

#### Quota Display (v2.0)

**Visible to All Tiers**

**Messages Quota**
- 💬 Icon
- Progress bar (filled based on usage)
- Text: "8 / 20 messages used" / "8 / 20 رسالة مستخدمة"
- Warning color if ≥ 80% used
- "Unlimited" text for Smart Premium

**Calls Quota**
- 📞 Icon
- Progress bar
- Text: "1 / 2 calls used" / "1 / 2 مكالمة مستخدمة"
- Reset date: "Resets on Jan 1" / "يتجدد في 1 يناير"

**Design**: Two-column grid, compact cards

---

#### Fitness Score Card (Premium+ Only)

**Visible if**: `userProfile.hasCompletedSecondIntake === true`

**Content**
- 📊 Icon
- **Score**: Large number "65/100"
- **Label**: "Fitness Score" / "نقاط اللياقة"
- **Updated**: "Last updated: 2 days ago" / "آخر تحديث: منذ يومين"
- **Updated By**: "Auto-calculated" or "Set by Coach [Name]"
- Circular progress indicator

---

#### Today's Workout Card

**If Workout Assigned**
- 💪 Icon
- **Workout Name**: "Upper Body Strength"
- **Details**: "6 exercises • 45 min"
- **Status**: "Not started" / "In Progress" / "Completed ✓"
- **Button**: "Start Workout" / "ابدأ التمرين" → WorkoutScreen

**If No Workout**
- Empty state illustration
- "No workout scheduled for today"
- "View Workout Plan" button → WorkoutScreen

---

#### Nutrition Card

**If Plan Generated**
- 🥗 Icon
- **Daily Calories**: "2,200 kcal"
- **Macros Progress**:
  - Protein: 120/140g (progress bar)
  - Carbs: 245/275g (progress bar)
  - Fats: 65/75g (progress bar)
- **Button**: "View Meal Plan" / "عرض خطة الوجبات" → NutritionScreen

**If Freemium Expired** (v2.0)
- 🔒 Lock icon
- "Nutrition access expired"
- "Upgrade to continue" button → CheckoutScreen

**If No Plan**
- Empty state
- "Generate your nutrition plan"
- "Get Started" button → NutritionScreen

---

#### Quick Actions Grid

**4-Icon Grid** (2x2 on mobile, 4x1 on tablet)

1. **Workouts** 💪
   - Label: "Workouts" / "التمارين"
   - Navigate → WorkoutScreen

2. **Nutrition** 🥗
   - Label: "Nutrition" / "التغذية"
   - Navigate → NutritionScreen
   - Lock badge if Freemium expired

3. **Coach** 💬
   - Label: "Coach" / "المدرب"
   - Badge with unread count (if messages)
   - Navigate → CoachMessagingScreen

4. **Store** 🛒
   - Label: "Store" / "المتجر"
   - Navigate → StoreScreen

**Design**: Large icon buttons with labels, cards with hover effect

---

#### Progress Summary Card

**Stats Display**
- **Current Weight**: "75 kg"
- **Weight Change**: "-2.5 kg this month" (green if loss, red if gain for fat loss goal)
- **Workouts This Week**: "3 / 4 completed"
- **Current Streak**: "🔥 5 days"

**Button**: "View Full Progress" → ProgressDetailScreen

---

#### Coach Card (If Assigned)

**Content**
- Coach avatar image
- **Coach Name**: "Coach Ahmed"
- **Specialties**: "Weight Loss, Strength"
- **Rating**: ⭐⭐⭐⭐⭐ 4.8/5.0
- **Button**: "Message Coach" / "راسل المدرب" → CoachMessagingScreen

**If No Coach**
- "Find a coach to get started"
- "Browse Coaches" button → Coach browsing screen

---

#### Bottom Navigation Bar

**Always Visible** (Sticky bottom)

**5 Navigation Items**
1. **Home** 🏠 (current, highlighted)
2. **Workouts** 💪 → WorkoutScreen
3. **Nutrition** 🥗 → NutritionScreen
4. **Coach** 💬 → CoachMessagingScreen (badge if unread)
5. **Account** 👤 → AccountScreen

**Design**
- Icon + label below
- Selected item: Primary color, bold label
- Unselected: Gray, regular weight
- Smooth transition on switch

---

### User Interactions

**On Screen Load**
1. Fetch user profile data
2. Load quota usage
3. Fetch today's workout (if assigned)
4. Load nutrition summary
5. Calculate progress stats
6. Load coach info (if assigned)

**Quick Actions**
- Tap any card → Navigate to respective screen
- Swipe left/right for next day's workout (if implemented)

**Quota Warnings**
- If messages ≥ 80% used: Show warning toast
- If calls exceeded: Show upgrade prompt

**Nutrition Expiry** (Freemium Only)
- If within 3 days of expiry: Show banner at top
- If expired: Nutrition card locked, upgrade prompt

### Data Requirements

**API Endpoints**
- `GET /api/users/{userId}` → UserProfile
- `GET /api/users/{userId}/quota` → QuotaUsage
- `GET /api/users/{userId}/workouts/today` → Workout
- `GET /api/users/{userId}/nutrition/summary` → NutritionSummary
- `GET /api/users/{userId}/progress/summary` → ProgressSummary
- `GET /api/coaches/{coachId}` → CoachProfile

**Data Refresh**
- On screen mount
- On pull-to-refresh gesture
- After returning from other screens (if data changed)

### Validation
- No validation required (read-only screen)

### Navigation Flow
- **Quick Actions**: → Respective feature screens
- **Bottom Nav**: → Main app sections
- **Settings Icon**: → AccountScreen
- **Upgrade Button**: → CheckoutScreen

### Conditional Rendering

**Freemium Users**
- Quota display with limits
- Upgrade prompts on cards
- Locked features (chat attachments, second intake)
- Nutrition expiry banner (if applicable)

**Premium+ Users**
- Full quota display (higher limits)
- Fitness score visible (if second intake completed)
- No locks on features
- Persistent nutrition access

**No Coach Assigned**
- Hide coach card
- Show "Find Coach" CTA in coach quick action

**No Workout Plan**
- Empty state with "Get Started" button

### RTL Considerations
- All text: Right-aligned for Arabic
- Progress bars: Fill right-to-left
- Quick actions grid: RTL order (right to left)
- Bottom navigation: RTL order (Home on right)
- Settings icon: Top-left for Arabic

### Accessibility
- ARIA labels for all navigation items
- Screen reader announces quota status
- High contrast for progress bars
- Focus indicators on interactive elements

### Performance Optimization
- Lazy load non-critical data (coach info, progress stats)
- Cache quota data for 5 minutes
- Skeleton screens while loading

### Demo Mode Behavior
- Pre-filled with realistic mock data
- All stats populated
- Coach assigned: "Demo Coach Ahmed"
- Quota usage: 8/20 messages, 1/2 calls

---

## 7. Workout Screen

### Purpose
Display user's workout plan, track exercise completion, show exercise details, and provide injury-aware exercise substitutions. Includes workout timer functionality.

### Entry Point
- Home quick action "Workouts"
- Bottom navigation "Workouts" tab
- Today's workout card on Home

### UI Components

#### Header Section

**Top Bar**
- Back button (if navigated from Home)
- Title: "Workouts" / "التمارين"
- Calendar icon → View week view
- Settings icon (3-dot menu)

**Tabs** (if multiple workout plans)
- "Current Week"
- "All Plans"
- "History"

---

#### Intro Screen (If No Plan Assigned)

**Empty State**
- Large illustration (person lifting weights)
- **Heading**: "Start Your Fitness Journey" / "ابدأ رحلة لياقتك"
- **Description**: "Get a personalized workout plan tailored to your goals and fitness level"
- **Button**: "Generate Workout Plan" / "إنشاء خطة تمارين"
  - Navigates to plan generation (or coach request for Freemium)

**For Freemium**
- "Request plan from coach" button
- Opens coach messaging with template message

---

#### Current Workout Display (If Plan Exists)

**Workout Header Card**
- **Workout Name**: "Upper Body Strength"
- **Day**: "Day 3 of 6" • "Week 2 of 4"
- **Duration**: "⏱️ 45 min"
- **Exercises**: "📋 6 exercises"
- **Status Badge**: "Not Started" / "In Progress" / "Completed ✓"
- **Start/Resume Button**: Full-width primary button

**Quick Stats Bar**
- Today: "3/6 exercises"
- This Week: "2/4 workouts"
- Total: "12 workouts completed"

---

#### Exercise List (Expandable Cards)

**Each Exercise Card** (Collapsed View)
- **Order Number**: "1", "2", "3"...
- **Exercise Name**: "Barbell Bench Press"
- **Muscle Group**: "Chest" (small badge)
- **Prescription**: "3 sets × 8-12 reps"
- **Rest**: "90 sec rest"
- **Status**:
  - ⚪ Not started (gray)
  - 🔵 In progress (blue)
  - ✅ Completed (green)

**Injury Warning Badge** (v2.0)
- If exercise contraindicated: "⚠️ Injury Alert"
- Orange border on card
- Auto-opens alternative exercises modal

**Expanded View** (When Card Tapped)
- Exercise thumbnail/video preview
- Full exercise name
- Muscle group tags
- **Prescription Details**:
  - Sets: 3
  - Reps: 8-12
  - Rest: 90 sec
  - Weight: [User input field] kg
- **Action Buttons**:
  - "View Details" → ExerciseDetailScreen (modal)
  - "Find Alternatives" → Alternative exercises modal (v2.0)
  - "Mark Complete" → Check off exercise
- **Instructions** (collapsible):
  - Step-by-step text
  - "Watch Video" link (if available)
- **Coach Notes** (if any):
  - Speech bubble icon
  - Text from coach

---

#### Alternative Exercises Modal (v2.0)

**Triggered When**
- User has injury that contraindicates exercise
- User clicks "Find Alternatives" button
- Auto-shown if exercise flagged on workout start

**Modal Content**

**Header**
- ⚠️ Icon
- **Title**: "Safe Alternatives for [Exercise]"
- **Subtitle**: "Due to your [Injury Area] injury"
- Close button (X)

**Original Exercise Card**
- Exercise name
- ❌ "Not recommended due to [injury]"
- Reasoning: "This exercise involves [movement] which may aggravate your [injury]"

**Alternative Exercises List**
- **3-5 alternative exercises** (cards)
- Each card shows:
  - Exercise name
  - Muscle group
  - ✅ "Safe for [injury]"
  - Reasoning: "Reduced [body part] loading while maintaining stimulus"
  - Default sets/reps
  - "Use This" button

**User Actions**
1. Review alternatives
2. Click "Use This" on preferred alternative
3. Exercise substituted in workout plan
4. Substitution logged (isSubstituted: true, originalExerciseId saved)
5. Modal closes
6. Workout list updates with new exercise

**No Alternatives Found**
- "No safe alternatives found"
- "Consult your coach" button → Message coach
- "Skip Exercise" button → Mark as skipped

---

#### Workout Timer (Floating Button)

**Timer FAB (Floating Action Button)**
- Bottom-right corner (LTR) / Bottom-left (RTL)
- 🎯 Icon
- "Start Timer" / "ابدأ المؤقت"
- Expands into timer modal

**Timer Modal** (Full-Screen Overlay)

**Exercise Phase**
- **Large Exercise Name**: "Barbell Bench Press"
- **Set Counter**: "Set 1 of 3"
- **Rep Counter**: "0 / 8-12 reps"
- **Weight Input**: "Enter weight used" (optional)
- **Done Button**: "Set Complete" → Advances to rest

**Rest Phase**
- **Large Countdown**: "01:30" (90 seconds)
- **Next Exercise Preview**: "Next: Incline Dumbbell Press"
- **Progress Bar**: Visual countdown
- **Skip Rest** button
- **Add Time** (+15 sec) / **Reduce Time** (-15 sec) buttons

**Controls**
- ⏸️ Pause button
- ⏹️ Stop workout (confirmation)
- 🔊 Sound on/off toggle
- Vibration toggle

**Auto-Advance**
- Completes rest → Auto-advance to next set
- Completes all sets → Auto-advance to next exercise
- Completes workout → Completion screen

---

#### Workout Completion Screen

**Celebration UI**
- 🎉 Confetti animation
- "Workout Complete!" / "اكتمل التمرين!"
- **Stats**:
  - Duration: "46 min"
  - Exercises: "6/6 completed"
  - Calories burned: "~340 kcal" (estimated)
  - Personal record: "New PR on Bench Press!" (if applicable)

**Rating Prompt** (v2.0)
- "Rate your trainer's workout plan"
- 1-5 stars
- Optional comment
- Submit button

**Actions**
- "View Summary" → Detailed workout log
- "Back to Home" → HomeScreen

---

### User Interactions

**Typical Flow**
1. User opens WorkoutScreen
2. Sees current workout plan
3. Taps "Start Workout"
4. First exercise card expands
5. Reviews exercise details, watches video
6. **If injury warning**: Alternative exercises modal auto-opens
7. Taps "Start Timer" FAB
8. Timer modal opens
9. Completes set → Logs weight → "Set Complete"
10. Rest timer starts (90 sec)
11. Rest completes → Next set begins
12. Repeats for all sets and exercises
13. Workout completes → Completion screen
14. Rates workout plan → Submits
15. Returns to Home

**Alternative Exercise Flow**
1. User sees "⚠️ Injury Alert" on exercise
2. Taps "Find Alternatives"
3. Modal opens with safe alternatives
4. Reviews options
5. Taps "Use This" on preferred exercise
6. Exercise substituted
7. Continues workout with new exercise

### Data Requirements

**API Endpoints**
- `GET /api/users/{userId}/workouts/current` → Current workout
- `GET /api/workouts/{workoutId}` → Workout details
- `GET /api/exercises/{exerciseId}` → Exercise details
- `POST /api/users/{userId}/workouts/{workoutId}/complete` → Log completion
- `POST /api/users/{userId}/workouts/{workoutId}/substitute` → Log substitution
- `POST /api/ratings/trainer` → Submit trainer rating

**Data Models**
```typescript
interface Workout {
  id: string;
  name: string;
  dayNumber: number;
  weekNumber: number;
  exercises: WorkoutExercise[];
  estimatedDuration: number;
  completedAt?: Date;
}

interface WorkoutExercise {
  id: string;
  exerciseId: string;
  exerciseName: string;
  muscleGroup: string;
  sets: number;
  reps: string;
  restTime: number;
  weight?: number;
  isSubstituted?: boolean;
  originalExerciseId?: string;
  completedSets: number;
  isCompleted: boolean;
}
```

### Validation
- Weight input: Optional, 0-500 kg
- Reps completed: Optional, 1-100
- Timer: Min 0 sec, max 10 min

### Navigation Flow
- **Back**: HomeScreen or previous screen
- **Exercise Details**: ExerciseDetailScreen (modal)
- **Alternative Exercises**: Alternative Exercises Modal
- **Timer**: Timer Modal (full-screen overlay)
- **Completion**: Workout Summary → HomeScreen

### Injury Substitution Logic (v2.0)

**On Workout Load**
```typescript
function checkExerciseForInjuries(
  exercise: WorkoutExercise,
  userInjuries: InjuryArea[]
): boolean {
  const result = shouldSubstituteExercise(exercise.exerciseName, userInjuries);
  return result.shouldSub;
}
```

**Auto-Flag Contraindicated Exercises**
```typescript
workoutExercises.forEach(exercise => {
  if (checkExerciseForInjuries(exercise, userProfile.injuries)) {
    // Add warning badge
    exercise.needsSubstitution = true;
    exercise.injuryReason = result.reason;
  }
});
```

**Find Safe Alternatives**
```typescript
function findAlternatives(
  exerciseId: string,
  injury: InjuryArea
): Exercise[] {
  return findSafeAlternatives(exerciseId, injury, targetMuscleGroup);
}
```

**Apply Substitution**
```typescript
function substituteExercise(
  workoutId: string,
  originalExerciseId: string,
  newExerciseId: string
) {
  // Update workout plan
  // Log substitution event
  // Notify coach (optional)
}
```

### RTL Considerations
- Exercise list: Right-aligned text for Arabic
- Timer: Numbers always LTR
- Progress bars: Fill right-to-left
- FAB: Bottom-left for Arabic

### Accessibility
- Screen reader announces exercise name, sets, reps
- Timer announces time remaining every 30 seconds
- High contrast for timer display
- Haptic feedback on set completion (mobile)

### Demo Mode Behavior
- Pre-populated workout plan
- Mock completion data
- All exercises available
- Injury warning shown for demo (knee injury)

---

## 8. Nutrition Screen

### Purpose
Display meal plans, log food intake, track macros, and manage nutrition access (with 7-day trial for Freemium users in v2.0).

### Entry Point
- Home quick action "Nutrition"
- Bottom navigation "Nutrition" tab
- Nutrition card on HomeScreen

### UI Components

#### Header Section

**Top Bar**
- Back button (if navigated from Home)
- Title: "Nutrition" / "التغذية"
- Calendar icon → Select date
- Settings icon (3-dot menu)

---

#### Access Control (v2.0 - Freemium Only)

**If Nutrition Plan Not Generated Yet**
- Welcome screen (see "Intro Screen" below)

**If Nutrition Plan Exists & Within Trial (Freemium)**
- **Expiry Banner** (top of screen)
  - 3+ days left: ℹ️ "Your nutrition trial ends in 5 days"
  - 2 days left: ⚠️ "2 days left in your trial"
  - 1 day left: 🔴 "Last day of your nutrition trial!"
  - Background color: Blue → Orange → Red
  - "Upgrade Now" button (inline)

**If Trial Expired (Freemium)**
- **Locked Screen Overlay**
  - 🔒 Lock icon
  - **Title**: "Nutrition Access Expired" / "انتهى وصول التغذية"
  - **Message**: "Your 7-day nutrition trial has ended. Upgrade to Premium for unlimited access."
  - **Upgrade Button**: "Upgrade to Premium" / "الترقية إلى بريميوم"
  - **Secondary**: "View Plans" → CheckoutScreen
  - Blurred nutrition plan visible in background (teaser)

**If Premium+ User**
- Full access, no banners, no expiry

---

#### Intro Screen (If No Plan Generated)

**Empty State**
- Illustration (healthy meal)
- **Heading**: "Personalized Nutrition Plans" / "خطط تغذية مخصصة"
- **Description**: "Get meal plans tailored to your goals with macro tracking"

**Feature List**
- ✅ Daily meal plans
- ✅ Macro tracking (protein, carbs, fats)
- ✅ Calorie goals
- ✅ Food logging
- ✅ Recipe database

**Call-to-Action**

**For Freemium**
- "Generate Your Plan (7-Day Trial)" / "إنشاء خطتك (تجربة 7 أيام)"
- Small text: "Upgrade anytime for unlimited access"

**For Premium+**
- "Generate Your Nutrition Plan"

**Button Action**
- Opens nutrition preferences intake (mini-questionnaire)
- Collects: Dietary preferences, allergies, meal frequency
- Generates plan
- Stores `generatedAt` timestamp (Freemium trial starts)

---

#### Nutrition Plan Display (If Plan Exists & Accessible)

**Daily Summary Card**
- **Date Selector**: "← Today, Dec 8 →" (swipe or arrow buttons)
- **Calorie Goal**: "2,200 kcal"
- **Calories Consumed**: "1,850 / 2,200" (progress bar)
- **Macros Progress**:
  - Protein: 120g / 140g (85%) - Green bar
  - Carbs: 245g / 275g (89%) - Blue bar
  - Fats: 65g / 75g (87%) - Orange bar

---

#### Meals List

**Meal Cards** (4-6 meals per day)

**Meal 1: Breakfast**
- 🌅 Icon + Time "7:00 AM"
- **Meal Name**: "High-Protein Breakfast"
- **Calories**: "450 kcal"
- **Macros**: P: 35g • C: 45g • F: 15g
- **Status**: ⚪ Not logged / ✅ Logged
- **Expand/Collapse**: Tap to see foods

**Expanded Meal View**
- **Food Items List**:
  1. Scrambled Eggs (3 large) - 210 kcal
  2. Whole Wheat Toast (2 slices) - 160 kcal
  3. Avocado (1/2 medium) - 120 kcal
  4. Orange Juice (1 cup) - 110 kcal

- **Instructions** (if any):
  - "Cook eggs in 1 tsp olive oil. Toast bread. Slice avocado."

- **Actions**:
  - "Log Meal" button (marks as completed)
  - "Edit Meal" (Premium+ only)
  - "View Recipe" (if recipe available)

**Logged Meal**
- ✅ Checkmark icon
- Green border
- "Logged at 7:35 AM"

---

#### Quick Actions (Floating Buttons)

**Food Logging Dialog** (Modal)
- Triggered by "+" FAB or "Edit Meal" button
- **Search Food Database**
  - Search bar: "Search foods..."
  - Common foods list
  - Recent foods
  - Custom food entry
- **Manual Entry**
  - Food name
  - Serving size
  - Calories, Protein, Carbs, Fats
- **Scan Barcode** (future feature, placeholder)
- **Add to Meal** button

---

#### Weekly View Tab (Optional)

**Calendar Grid**
- 7 days (Mon-Sun)
- Each day shows:
  - Date
  - Calorie adherence: "1,950 / 2,200" (color-coded)
  - Checkmark if all meals logged
- Tap day → Load that day's meals

---

#### Preferences & Settings

**Accessible via 3-dot menu**
- Edit nutrition preferences
- Change calorie goal
- Adjust macros (Premium+ only)
- Food allergies and restrictions
- Meal frequency (3-6 meals/day)

---

### User Interactions

**Typical Flow (First Time)**
1. User navigates to Nutrition screen
2. Sees intro screen
3. Taps "Generate Your Plan"
4. Completes nutrition preferences intake:
   - Dietary type: Standard / Vegetarian / Vegan / Keto / Paleo
   - Allergies: Nuts, Dairy, Gluten, etc.
   - Meal frequency: 3-6 meals/day
   - Snacks: Yes / No
5. Plan generated (7-day trial starts for Freemium)
6. Returns to Nutrition screen
7. Sees daily meal plan
8. Expands breakfast meal
9. Reviews foods
10. Taps "Log Meal" → Meal marked complete
11. Macros progress updates
12. Repeats for other meals

**Expiry Flow (Freemium)**
1. Day 5 of trial: Blue banner "2 days left"
2. Day 6 of trial: Orange banner "1 day left"
3. Day 7 of trial: Red banner "Last day!"
4. Day 8: Locked screen overlay
5. User taps "Upgrade to Premium"
6. Navigates to CheckoutScreen
7. Completes upgrade
8. Returns to Nutrition screen
9. Full access unlocked

### Data Requirements

**API Endpoints**
- `GET /api/users/{userId}/nutrition/plan` → Nutrition plan
- `POST /api/users/{userId}/nutrition/generate` → Generate new plan
- `POST /api/users/{userId}/nutrition/log-meal` → Log meal completion
- `GET /api/foods/search?q={query}` → Search food database
- `POST /api/users/{userId}/nutrition/preferences` → Update preferences

**Data Models**
```typescript
interface NutritionPlan {
  id: string;
  userId: string;
  dailyCalories: number;
  proteinGrams: number;
  carbGrams: number;
  fatGrams: number;
  mealsPerDay: number;
  generatedAt?: Date;              // v2.0: Trial start
  expiresAt?: Date;                // v2.0: generatedAt + 7 days (Freemium only)
  meals: Meal[];
}

interface Meal {
  id: string;
  dayNumber: number;
  mealNumber: number;              // 1 = Breakfast, 2 = Lunch, etc.
  name: string;
  time?: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  foods: FoodItem[];
  isLogged: boolean;
  loggedAt?: Date;
}

interface FoodItem {
  id: string;
  name: string;
  servingSize: number;
  servingUnit: string;
  quantity: number;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
}
```

### Nutrition Expiry Calculation (v2.0)

**On Plan Generation (Freemium Only)**
```typescript
function setNutritionExpiry(userId: string, tier: SubscriptionTier): Date | null {
  if (tier !== 'Freemium') return null; // Premium+ = no expiry
  
  const now = new Date();
  const expiresAt = new Date(now.getTime() + (7 * 24 * 60 * 60 * 1000)); // +7 days
  
  // Store in database
  nutritionPlan.generatedAt = now;
  nutritionPlan.expiresAt = expiresAt;
  
  return expiresAt;
}
```

**Check Expiry on Screen Load**
```typescript
function checkNutritionExpiry(plan: NutritionPlan, tier: SubscriptionTier): {
  isExpired: boolean;
  daysLeft: number;
} {
  if (tier !== 'Freemium') {
    return { isExpired: false, daysLeft: Infinity };
  }
  
  if (!plan.expiresAt) {
    return { isExpired: false, daysLeft: 7 };
  }
  
  const now = new Date();
  const msLeft = plan.expiresAt.getTime() - now.getTime();
  const daysLeft = Math.ceil(msLeft / (1000 * 60 * 60 * 24));
  
  return {
    isExpired: daysLeft <= 0,
    daysLeft: Math.max(0, daysLeft)
  };
}
```

**Banner Display Logic**
```typescript
function getExpiryBannerProps(daysLeft: number): {
  show: boolean;
  color: string;
  icon: string;
  message: string;
} {
  if (daysLeft > 3) {
    return { show: false, color: '', icon: '', message: '' };
  } else if (daysLeft === 3) {
    return {
      show: true,
      color: 'blue',
      icon: 'ℹ️',
      message: `Your nutrition trial ends in ${daysLeft} days`
    };
  } else if (daysLeft === 2) {
    return {
      show: true,
      color: 'orange',
      icon: '⚠️',
      message: `${daysLeft} days left in your trial`
    };
  } else if (daysLeft === 1) {
    return {
      show: true,
      color: 'red',
      icon: '🔴',
      message: 'Last day of your nutrition trial!'
    };
  }
  return { show: false, color: '', icon: '', message: '' };
}
```

### Validation
- Calorie goal: 1,200 - 5,000 kcal
- Macro percentages: Must sum to 100%
- Food quantities: > 0
- Meal logging: Can only log meals for today or past dates

### Navigation Flow
- **Back**: HomeScreen
- **Generate Plan**: Nutrition Preferences Intake → Nutrition Screen
- **Upgrade**: CheckoutScreen
- **Food Search**: Food Logging Dialog (modal)
- **View Recipe**: Recipe Detail Screen (modal)

### RTL Considerations
- All text: Right-aligned for Arabic
- Progress bars: Fill right-to-left
- Date selector arrows: Reversed (← becomes →)
- Food list: Right-aligned

### Accessibility
- Screen reader announces calorie progress
- High contrast for macro bars
- Focus indicators on meal cards
- ARIA labels for logged/unlogged status

### Demo Mode Behavior
- Pre-generated nutrition plan
- Some meals marked as logged
- Macros partially completed (realistic progress)
- No expiry warning (simulate Premium user)

---

*(Continued in next section due to length...)*

---

**End of Part 1 (User Journey Screens 1-8)**

**Next: Part 2 will cover:**
- Coach Messaging Screen
- Store Screen
- Account Settings Screen
- Progress Detail Screen
- Coach Tools (6 screens)
- Admin Dashboard (8 screens)
- Supporting Screens

*This document is comprehensive and designed for platform-agnostic migration. Each screen specification includes all necessary details for reimplementation in any programming language or framework.*
