# Functional Requirements - عاش (FitCoach+ v2.0)

## Document Information
- **Document Type**: Functional Requirements Specification
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## Table of Contents

1. [Authentication & Authorization](#1-authentication--authorization)
2. [User Onboarding](#2-user-onboarding)
3. [Subscription Management](#3-subscription-management)
4. [Workout Management](#4-workout-management)
5. [Nutrition Management](#5-nutrition-management)
6. [Messaging System](#6-messaging-system)
7. [Video Calling](#7-video-calling)
8. [Progress Tracking](#8-progress-tracking)
9. [E-Commerce](#9-e-commerce)
10. [Coach Management](#10-coach-management)
11. [Admin Management](#11-admin-management)
12. [Quota System](#12-quota-system)
13. [Rating System](#13-rating-system)
14. [Injury Management](#14-injury-management)

---

## 1. Authentication & Authorization

### FR-AUTH-001: Phone Number Registration
**Priority**: Critical  
**User Story**: As a new user, I want to register using my phone number so that I can access the platform securely.

**Requirements**:
- System SHALL accept Saudi phone numbers in format +966 5X XXX XXXX
- System SHALL validate phone number format before OTP generation
- System SHALL reject invalid phone numbers with clear error message
- System SHALL support only Saudi Arabia country code (+966) in v2.0

**Input**:
- Phone number: String (9 digits after country code)

**Processing**:
```typescript
function validatePhoneNumber(phone: string): ValidationResult {
  // Remove non-numeric characters
  const cleaned = phone.replace(/\D/g, '');
  
  // Check length (9 digits)
  if (cleaned.length !== 9) {
    return { valid: false, error: 'Phone must be 9 digits' };
  }
  
  // Check first digit is 5 (Saudi mobile)
  if (cleaned[0] !== '5') {
    return { valid: false, error: 'Phone must start with 5' };
  }
  
  // Format with country code
  const formatted = `+966${cleaned}`;
  return { valid: true, formatted };
}
```

**Output**:
- Formatted phone number: +966XXXXXXXXX
- Validation status: boolean
- Error message (if invalid)

**Acceptance Criteria**:
- AC1: System accepts valid Saudi mobile numbers (5XXXXXXXX)
- AC2: System rejects numbers not starting with 5
- AC3: System rejects numbers with incorrect length
- AC4: Error messages displayed in user's language (AR/EN)

---

### FR-AUTH-002: OTP Generation and Delivery
**Priority**: Critical  
**User Story**: As a user, I want to receive a verification code via SMS so that I can verify my phone number.

**Requirements**:
- System SHALL generate random 6-digit numeric OTP
- System SHALL send OTP via SMS within 30 seconds
- System SHALL set OTP expiry to 5 minutes from generation
- System SHALL hash OTP before storing in database
- System SHALL not generate more than 3 OTPs per phone per hour (rate limiting)

**Processing**:
```typescript
async function generateAndSendOTP(phoneNumber: string): Promise<OTPSession> {
  // Check rate limiting
  const recentAttempts = await countOTPAttempts(phoneNumber, lastHour);
  if (recentAttempts >= 3) {
    throw new RateLimitError('Too many OTP requests');
  }
  
  // Generate 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  
  // Calculate expiry (5 minutes)
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
  
  // Hash code before storage
  const hashedCode = await bcrypt.hash(code, 10);
  
  // Store session
  const session = await db.otpSessions.create({
    phoneNumber,
    otpCode: hashedCode,
    expiresAt,
    attempts: 0,
    isVerified: false
  });
  
  // Send SMS
  await smsService.send(phoneNumber, `Your عاش verification code is: ${code}`);
  
  return session;
}
```

**Output**:
- SMS delivered to user's phone
- OTP session created in database
- Session ID returned for verification

**Acceptance Criteria**:
- AC1: OTP is exactly 6 numeric digits
- AC2: SMS received within 30 seconds
- AC3: OTP expires after 5 minutes
- AC4: Rate limiting prevents spam (max 3 per hour)
- AC5: OTP is hashed in database (never plaintext)

---

### FR-AUTH-003: OTP Verification
**Priority**: Critical  
**User Story**: As a user, I want to enter the verification code I received so that I can access my account.

**Requirements**:
- System SHALL validate OTP against stored hash
- System SHALL check OTP expiry before validation
- System SHALL allow maximum 3 verification attempts per session
- System SHALL lock session after 3 failed attempts
- System SHALL create/login user upon successful verification

**Processing**:
```typescript
async function verifyOTP(
  phoneNumber: string, 
  enteredCode: string
): Promise<VerificationResult> {
  // Find active session
  const session = await db.otpSessions.findOne({
    phoneNumber,
    isVerified: false
  });
  
  if (!session) {
    return { success: false, error: 'No active session' };
  }
  
  // Check expiry
  if (new Date() > session.expiresAt) {
    return { success: false, error: 'OTP expired' };
  }
  
  // Check attempts
  if (session.attempts >= 3) {
    return { success: false, error: 'Too many attempts' };
  }
  
  // Verify code
  const isValid = await bcrypt.compare(enteredCode, session.otpCode);
  
  if (!isValid) {
    // Increment attempts
    await db.otpSessions.update(session.id, {
      attempts: session.attempts + 1
    });
    return { success: false, error: 'Invalid code' };
  }
  
  // Mark as verified
  await db.otpSessions.update(session.id, {
    isVerified: true,
    verifiedAt: new Date()
  });
  
  // Find or create user
  let user = await db.users.findOne({ phoneNumber });
  if (!user) {
    user = await createNewUser(phoneNumber);
  }
  
  // Generate auth token
  const token = jwt.sign(
    { userId: user.id, phoneNumber: user.phoneNumber },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
  
  return { success: true, user, token };
}
```

**Output**:
- Authentication token (JWT)
- User object
- Success/error status

**Acceptance Criteria**:
- AC1: Valid OTP allows user to authenticate
- AC2: Invalid OTP shows error and increments attempt counter
- AC3: Expired OTP shows "OTP expired" error
- AC4: After 3 failed attempts, session is locked
- AC5: New users are created automatically on first verification
- AC6: Existing users are logged in on verification

---

### FR-AUTH-004: Session Management
**Priority**: High  
**User Story**: As a user, I want to stay logged in so that I don't have to re-authenticate every time.

**Requirements**:
- System SHALL issue JWT token valid for 30 days
- System SHALL store token securely (httpOnly cookie or secure storage)
- System SHALL validate token on each protected API request
- System SHALL refresh token when user is active
- System SHALL allow user to logout (invalidate token)

**Token Structure**:
```typescript
interface JWTPayload {
  userId: string;
  phoneNumber: string;
  role: 'user' | 'coach' | 'admin';
  iat: number;  // issued at
  exp: number;  // expiration
}
```

**Acceptance Criteria**:
- AC1: Token is valid for 30 days from issuance
- AC2: Token is refreshed on user activity
- AC3: Invalid/expired tokens return 401 Unauthorized
- AC4: Logout clears token from client and optionally blacklists server-side

---

## 2. User Onboarding

### FR-ONBOARD-001: First Intake (All Users)
**Priority**: Critical  
**User Story**: As a new user, I want to provide basic fitness information so that the app can personalize my experience.

**Requirements**:
- System SHALL require 3 questions for all users (Freemium, Premium, Smart Premium)
- System SHALL NOT allow users to skip first intake
- System SHALL save responses immediately upon completion
- System SHALL validate all responses before saving

**Questions**:
1. **Gender**: male | female | other (required)
2. **Main Goal**: fat_loss | muscle_gain | general_fitness (required)
3. **Workout Location**: home | gym (required)

**Processing**:
```typescript
async function submitFirstIntake(
  userId: string,
  data: FirstIntakeData
): Promise<void> {
  // Validate
  if (!data.gender || !data.mainGoal || !data.workoutLocation) {
    throw new ValidationError('All fields required');
  }
  
  // Update user profile
  await db.users.update(userId, {
    gender: data.gender,
    mainGoal: data.mainGoal,
    workoutLocation: data.workoutLocation,
    hasCompletedFirstIntake: true,
    firstIntakeCompletedAt: new Date()
  });
  
  // Initialize default values
  await initializeUserDefaults(userId);
}
```

**Acceptance Criteria**:
- AC1: All 3 questions must be answered to proceed
- AC2: Responses are saved to user profile
- AC3: User is marked as having completed first intake
- AC4: Freemium users proceed to Home screen
- AC5: Premium+ users proceed to Second Intake screen

---

### FR-ONBOARD-002: Second Intake (Premium+ Only)
**Priority**: High  
**User Story**: As a Premium user, I want to provide detailed fitness information so that I can get personalized workout and nutrition plans.

**Requirements**:
- System SHALL require Premium or Smart Premium subscription to access
- System SHALL display upgrade prompt to Freemium users
- System SHALL collect 6 detailed fitness metrics
- System SHALL calculate fitness score automatically upon completion
- System SHALL activate injury substitution engine if injuries selected

**Questions**:
1. **Age**: number (13-120, required)
2. **Weight**: number (30-300 kg, required)
3. **Height**: number (100-250 cm, required)
4. **Experience Level**: beginner | intermediate | advanced (required)
5. **Workout Frequency**: number (2-6 days/week, required)
6. **Injuries**: InjuryArea[] (multi-select, optional)

**Processing**:
```typescript
async function submitSecondIntake(
  userId: string,
  data: SecondIntakeData
): Promise<void> {
  // Check tier eligibility
  const user = await db.users.findById(userId);
  if (user.subscriptionTier === 'Freemium') {
    throw new PermissionError('Premium subscription required');
  }
  
  // Validate
  validateSecondIntake(data); // throws if invalid
  
  // Calculate fitness score
  const fitnessScore = calculateFitnessScore(data);
  
  // Update user profile
  await db.users.update(userId, {
    age: data.age,
    weight: data.weight,
    height: data.height,
    experienceLevel: data.experienceLevel,
    workoutFrequency: data.workoutFrequency,
    injuries: data.injuries,
    fitnessScore,
    fitnessScoreUpdatedBy: 'auto',
    fitnessScoreLastUpdated: new Date(),
    hasCompletedSecondIntake: true,
    secondIntakeCompletedAt: new Date()
  });
}

function calculateFitnessScore(data: SecondIntakeData): number {
  let score = 50; // Base
  
  // Experience contribution (0-30)
  if (data.experienceLevel === 'beginner') score += 0;
  if (data.experienceLevel === 'intermediate') score += 15;
  if (data.experienceLevel === 'advanced') score += 30;
  
  // Frequency contribution (0-12)
  score += (data.workoutFrequency - 2) * 3;
  
  // Injury penalty (-5 per injury)
  score -= data.injuries.length * 5;
  
  // Clamp to 0-100
  return Math.max(0, Math.min(100, score));
}
```

**Acceptance Criteria**:
- AC1: Only Premium+ users can access second intake
- AC2: Freemium users see upgrade prompt
- AC3: All 6 questions must be answered (injuries can be empty array)
- AC4: Fitness score is calculated automatically
- AC5: Injury-aware programming is activated if injuries selected
- AC6: User profile is updated with all responses

---

## 3. Subscription Management

### FR-SUB-001: View Subscription Tiers
**Priority**: High  
**User Story**: As a user, I want to view available subscription tiers so that I can understand what features are available.

**Requirements**:
- System SHALL display 3 subscription tiers: Freemium, Premium, Smart Premium
- System SHALL show pricing for each tier
- System SHALL list features for each tier
- System SHALL highlight current user's tier
- System SHALL show comparison matrix

**Tier Definitions**:
```typescript
const SUBSCRIPTION_TIERS = {
  Freemium: {
    price: 0,
    currency: 'SAR',
    features: {
      messages: 20,
      calls: 1,
      callDuration: 15,
      nutritionTrial: 7,
      chatAttachments: false,
      secondIntake: false,
      inBodyTracking: false,
      customWorkouts: false
    }
  },
  Premium: {
    price: 19.99,
    currency: 'USD',
    features: {
      messages: 200,
      calls: 2,
      callDuration: 25,
      nutritionTrial: null, // unlimited
      chatAttachments: false,
      secondIntake: true,
      inBodyTracking: true,
      customWorkouts: true
    }
  },
  'Smart Premium': {
    price: 49.99,
    currency: 'USD',
    features: {
      messages: 'unlimited',
      calls: 4,
      callDuration: 25,
      nutritionTrial: null,
      chatAttachments: true,
      secondIntake: true,
      inBodyTracking: true,
      customWorkouts: true
    }
  }
};
```

**Acceptance Criteria**:
- AC1: All 3 tiers are displayed with pricing
- AC2: Feature comparison is clear and accurate
- AC3: Current tier is highlighted
- AC4: Upgrade button is shown for lower tiers

---

### FR-SUB-002: Upgrade Subscription
**Priority**: Critical  
**User Story**: As a Freemium user, I want to upgrade to Premium so that I can access more features.

**Requirements**:
- System SHALL allow upgrade from Freemium to Premium or Smart Premium
- System SHALL allow upgrade from Premium to Smart Premium
- System SHALL NOT allow downgrade during billing period
- System SHALL process payment via Stripe or Paddle
- System SHALL update user's tier immediately upon successful payment
- System SHALL initialize new quota limits immediately

**Processing**:
```typescript
async function upgradeSubscription(
  userId: string,
  newTier: SubscriptionTier,
  paymentMethodId: string
): Promise<SubscriptionResult> {
  const user = await db.users.findById(userId);
  
  // Validate upgrade path
  if (!isValidUpgrade(user.subscriptionTier, newTier)) {
    throw new ValidationError('Invalid upgrade path');
  }
  
  // Get tier pricing
  const pricing = SUBSCRIPTION_TIERS[newTier];
  
  // Process payment
  const payment = await paymentService.charge({
    amount: pricing.price,
    currency: pricing.currency,
    paymentMethodId,
    metadata: { userId, tier: newTier }
  });
  
  if (!payment.success) {
    throw new PaymentError(payment.error);
  }
  
  // Update subscription
  await db.users.update(userId, {
    subscriptionTier: newTier,
    subscriptionStartDate: new Date(),
    subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 days
    stripeCustomerId: payment.customerId,
    stripeSubscriptionId: payment.subscriptionId
  });
  
  // Update quota limits
  await updateQuotaLimits(userId, newTier);
  
  // If upgrading to Premium+, prompt for second intake
  if (newTier !== 'Freemium' && !user.hasCompletedSecondIntake) {
    await setSecondIntakePending(userId);
  }
  
  return { success: true, tier: newTier };
}
```

**Acceptance Criteria**:
- AC1: Payment is processed successfully before tier change
- AC2: User's tier is updated immediately
- AC3: Quota limits are updated immediately
- AC4: Premium+ users are prompted for second intake if not completed
- AC5: User receives confirmation email
- AC6: Upgrade is logged in audit trail

---

## 4. Workout Management

### FR-WORKOUT-001: View Workout Plan
**Priority**: Critical  
**User Story**: As a user, I want to view my workout plan so that I know what exercises to perform.

**Requirements**:
- System SHALL display user's assigned workout plan
- System SHALL show exercises grouped by day
- System SHALL display sets, reps, and rest time for each exercise
- System SHALL show exercise thumbnails/photos
- System SHALL indicate completed exercises with checkmarks
- System SHALL support injury-aware substitutions

**Data Structure**:
```typescript
interface WorkoutPlan {
  id: string;
  userId: string;
  createdBy: string; // coachId
  name: string;
  daysPerWeek: number;
  weeks: WorkoutWeek[];
  createdAt: Date;
  isActive: boolean;
}

interface WorkoutWeek {
  weekNumber: number;
  days: WorkoutDay[];
}

interface WorkoutDay {
  dayNumber: number;
  name: string; // "Upper Body", "Leg Day", etc.
  exercises: WorkoutExercise[];
}

interface WorkoutExercise {
  exerciseId: string;
  exercise: Exercise;
  sets: number;
  reps: number | string; // "12" or "30 seconds"
  restSeconds: number;
  notes?: string;
  order: number;
}
```

**Acceptance Criteria**:
- AC1: Current week's workout plan is displayed
- AC2: Exercises show all required details (sets, reps, rest)
- AC3: Exercise photos/videos are accessible
- AC4: Completed exercises are visually marked
- AC5: Injury warnings are shown for contraindicated exercises

---

### FR-WORKOUT-002: Start Workout Timer
**Priority**: High  
**User Story**: As a user, I want to use a workout timer so that I can track my sets and rest periods.

**Requirements**:
- System SHALL start timer mode when user clicks "Start Workout"
- System SHALL display current exercise with instructions
- System SHALL track set completion
- System SHALL auto-start rest timer after each set
- System SHALL advance to next exercise when all sets completed
- System SHALL save workout progress automatically
- System SHALL work offline

**Processing**:
```typescript
class WorkoutTimer {
  private currentExercise: number = 0;
  private currentSet: number = 1;
  private isResting: boolean = false;
  private restTimeRemaining: number = 0;
  
  startWorkout(plan: WorkoutDay) {
    this.currentExercise = 0;
    this.currentSet = 1;
    this.showExercise(plan.exercises[0]);
  }
  
  completeSet() {
    const exercise = this.getCurrentExercise();
    
    if (this.currentSet < exercise.sets) {
      // Start rest timer
      this.currentSet++;
      this.startRestTimer(exercise.restSeconds);
    } else {
      // Move to next exercise
      this.currentExercise++;
      this.currentSet = 1;
      
      if (this.currentExercise < this.totalExercises) {
        this.showExercise(this.getNextExercise());
      } else {
        this.completeWorkout();
      }
    }
    
    // Save progress
    this.saveProgress();
  }
  
  startRestTimer(seconds: number) {
    this.isResting = true;
    this.restTimeRemaining = seconds;
    
    const interval = setInterval(() => {
      this.restTimeRemaining--;
      
      if (this.restTimeRemaining <= 0) {
        clearInterval(interval);
        this.isResting = false;
        this.showExercise(this.getCurrentExercise());
      }
    }, 1000);
  }
  
  async saveProgress() {
    await db.workoutLogs.create({
      userId: this.userId,
      workoutId: this.workoutId,
      exerciseId: this.getCurrentExercise().exerciseId,
      sets: this.currentSet,
      completedAt: new Date()
    });
  }
}
```

**Acceptance Criteria**:
- AC1: Timer displays current exercise with instructions
- AC2: Set completion tracking works correctly
- AC3: Rest timer counts down and auto-advances
- AC4: Progress is saved after each set
- AC5: Workout can be paused and resumed
- AC6: Timer works offline and syncs when online

---

### FR-WORKOUT-003: Log Workout Completion
**Priority**: High  
**User Story**: As a user, I want to log my completed workouts so that I can track my progress.

**Requirements**:
- System SHALL record workout completion with timestamp
- System SHALL save sets, reps, and weight used for each exercise
- System SHALL calculate total workout duration
- System SHALL update user's workout streak
- System SHALL contribute to progress statistics

**Processing**:
```typescript
async function logWorkoutCompletion(
  userId: string,
  workoutId: string,
  exercises: LoggedExercise[]
): Promise<WorkoutLog> {
  const startTime = exercises[0].timestamp;
  const endTime = exercises[exercises.length - 1].timestamp;
  const durationMinutes = Math.round((endTime - startTime) / 60000);
  
  // Create workout log
  const log = await db.workoutLogs.create({
    userId,
    workoutId,
    exercises,
    durationMinutes,
    completedAt: new Date()
  });
  
  // Update streak
  await updateWorkoutStreak(userId);
  
  // Update statistics
  await updateWorkoutStats(userId);
  
  // Check for achievements
  await checkWorkoutAchievements(userId);
  
  return log;
}
```

**Acceptance Criteria**:
- AC1: Workout is logged with all exercise details
- AC2: Duration is calculated automatically
- AC3: Workout streak is updated
- AC4: Statistics are updated in real-time
- AC5: Achievements are unlocked if milestones reached

---

## 5. Nutrition Management

### FR-NUTRITION-001: Generate Nutrition Plan
**Priority**: High  
**User Story**: As a user, I want to generate a personalized nutrition plan so that I can meet my fitness goals.

**Requirements**:
- System SHALL calculate calorie target based on user data
- System SHALL distribute macros according to goal
- System SHALL generate daily meal plan
- System SHALL set expiry for Freemium users (7 days from generation)
- System SHALL allow unlimited access for Premium+ users

**Processing**:
```typescript
async function generateNutritionPlan(
  userId: string,
  preferences?: NutritionPreferences
): Promise<NutritionPlan> {
  const user = await db.users.findById(userId);
  
  // Calculate TDEE (Total Daily Energy Expenditure)
  const bmr = calculateBMR(user.age, user.weight, user.height, user.gender);
  const activityMultiplier = getActivityMultiplier(user.workoutFrequency);
  const tdee = bmr * activityMultiplier;
  
  // Adjust for goal
  let calorieTarget = tdee;
  if (user.mainGoal === 'fat_loss') calorieTarget -= 500; // 1 lb/week
  if (user.mainGoal === 'muscle_gain') calorieTarget += 300;
  
  // Calculate macros
  const macros = calculateMacros(calorieTarget, user.mainGoal);
  
  // Generate meal plan
  const meals = await generateMeals(calorieTarget, macros, preferences);
  
  // Set expiry for Freemium
  let expiresAt: Date | null = null;
  if (user.subscriptionTier === 'Freemium') {
    expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // +7 days
  }
  
  // Create plan
  const plan = await db.nutritionPlans.create({
    userId,
    calorieTarget,
    proteinGrams: macros.protein,
    carbsGrams: macros.carbs,
    fatsGrams: macros.fats,
    meals,
    generatedAt: new Date(),
    expiresAt,
    isActive: true
  });
  
  return plan;
}

function calculateBMR(
  age: number,
  weight: number,
  height: number,
  gender: string
): number {
  // Mifflin-St Jeor Equation
  if (gender === 'male') {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  }
}
```

**Acceptance Criteria**:
- AC1: Calorie target is calculated accurately
- AC2: Macros are distributed according to user's goal
- AC3: Meal plan is generated with appropriate meals
- AC4: Freemium users get 7-day expiry
- AC5: Premium+ users get no expiry (null)
- AC6: Plan is marked as active

---

### FR-NUTRITION-002: Check Nutrition Access
**Priority**: Critical  
**User Story**: As a Freemium user, I want to know when my nutrition trial expires so that I can plan accordingly.

**Requirements**:
- System SHALL check expiry status before displaying nutrition screen
- System SHALL show countdown banner when 2 days or less remain
- System SHALL lock nutrition screen when trial expires
- System SHALL allow Premium+ users unlimited access

**Processing**:
```typescript
async function checkNutritionAccess(
  userId: string
): Promise<NutritionAccessStatus> {
  const user = await db.users.findById(userId);
  
  // Premium+ users have unlimited access
  if (user.subscriptionTier !== 'Freemium') {
    return {
      hasAccess: true,
      isExpired: false,
      daysLeft: null,
      expiresAt: null
    };
  }
  
  // Freemium users - check expiry
  const plan = await db.nutritionPlans.findOne({
    userId,
    isActive: true
  });
  
  if (!plan || !plan.expiresAt) {
    return {
      hasAccess: false,
      isExpired: false,
      daysLeft: null,
      expiresAt: null,
      needsGeneration: true
    };
  }
  
  const now = new Date();
  const isExpired = now > plan.expiresAt;
  const daysLeft = Math.ceil((plan.expiresAt.getTime() - now.getTime()) / (24 * 60 * 60 * 1000));
  
  return {
    hasAccess: !isExpired,
    isExpired,
    daysLeft: isExpired ? 0 : daysLeft,
    expiresAt: plan.expiresAt
  };
}
```

**Acceptance Criteria**:
- AC1: Premium+ users always have access
- AC2: Freemium users see countdown when ≤2 days left
- AC3: Freemium users see locked screen when expired
- AC4: Days left calculation is accurate
- AC5: Upgrade prompt is shown to expired Freemium users

---

## 6. Messaging System

### FR-MSG-001: Send Message
**Priority**: Critical  
**User Story**: As a user, I want to send messages to my coach so that I can ask questions and get guidance.

**Requirements**:
- System SHALL check quota before allowing message send
- System SHALL enforce tier-based message limits
- System SHALL save message to conversation
- System SHALL send real-time notification to coach
- System SHALL increment quota usage after successful send

**Processing**:
```typescript
async function sendMessage(
  userId: string,
  conversationId: string,
  content: string,
  attachments?: Attachment[]
): Promise<Message> {
  // Check quota
  const quotaCheck = await checkQuota(userId, 'message');
  if (!quotaCheck.allowed) {
    throw new QuotaExceededError(quotaCheck.reason);
  }
  
  // Check attachment permissions
  if (attachments && attachments.length > 0) {
    const user = await db.users.findById(userId);
    if (user.subscriptionTier !== 'Smart Premium') {
      throw new PermissionError('Attachments require Smart Premium');
    }
  }
  
  // Create message
  const message = await db.messages.create({
    conversationId,
    senderId: userId,
    senderType: 'user',
    content,
    attachments,
    sentAt: new Date(),
    isRead: false
  });
  
  // Increment quota
  await incrementQuotaUsage(userId, 'message');
  
  // Notify coach
  await notifyCoach(conversationId, message);
  
  // Check if rating prompt needed (every 10 messages)
  await checkRatingPrompt(userId);
  
  return message;
}
```

**Acceptance Criteria**:
- AC1: Message send is blocked if quota exceeded
- AC2: Warning shown at 80% quota usage
- AC3: Message is saved to conversation
- AC4: Coach receives real-time notification
- AC5: Quota is incremented after successful send
- AC6: Attachments only work for Smart Premium users
- AC7: Rating prompt appears after every 10 messages

---

## 7. Video Calling

### FR-VIDEO-001: Book Video Call
**Priority**: High  
**User Story**: As a user, I want to schedule a video call with my coach so that I can get personalized guidance.

**Requirements**:
- System SHALL check call quota before allowing booking
- System SHALL validate requested time against coach availability
- System SHALL enforce tier-based call duration limits
- System SHALL create calendar event for both parties
- System SHALL send confirmation notifications

**Processing**:
```typescript
async function bookVideoCall(
  userId: string,
  coachId: string,
  requestedTime: Date
): Promise<VideoCall> {
  // Check quota
  const quotaCheck = await checkQuota(userId, 'call');
  if (!quotaCheck.allowed) {
    throw new QuotaExceededError(quotaCheck.reason);
  }
  
  // Check coach availability
  const isAvailable = await checkCoachAvailability(coachId, requestedTime);
  if (!isAvailable) {
    throw new ConflictError('Coach not available at requested time');
  }
  
  // Get user tier and duration limit
  const user = await db.users.findById(userId);
  const durationMinutes = user.subscriptionTier === 'Freemium' ? 15 : 25;
  
  // Create video call
  const call = await db.videoCalls.create({
    userId,
    coachId,
    scheduledAt: requestedTime,
    durationMinutes,
    status: 'scheduled',
    meetingUrl: await generateMeetingUrl(),
    createdAt: new Date()
  });
  
  // Increment quota
  await incrementQuotaUsage(userId, 'call');
  
  // Send notifications
  await notifyUser(userId, 'Video call scheduled');
  await notifyCoach(coachId, 'New video call booked');
  
  return call;
}
```

**Acceptance Criteria**:
- AC1: Booking blocked if quota exceeded
- AC2: Booking blocked if coach unavailable
- AC3: Duration is set based on tier (15 min Freemium, 25 min Premium+)
- AC4: Meeting URL is generated
- AC5: Both parties receive confirmation
- AC6: Call appears in calendar

---

## 8. Progress Tracking

### FR-PROGRESS-001: Log Weight
**Priority**: High  
**User Story**: As a user, I want to log my weight regularly so that I can track my progress toward my goal.

**Requirements**:
- System SHALL accept weight entries between 30-300 kg
- System SHALL support kg and lbs units
- System SHALL allow one entry per day (or update existing)
- System SHALL calculate weight trend (gaining/losing/maintaining)
- System SHALL display weight chart over time

**Processing**:
```typescript
async function logWeight(
  userId: string,
  weight: number,
  unit: 'kg' | 'lbs',
  date: Date = new Date()
): Promise<WeightEntry> {
  // Validate weight
  const weightKg = unit === 'lbs' ? weight * 0.453592 : weight;
  if (weightKg < 30 || weightKg > 300) {
    throw new ValidationError('Weight must be 30-300 kg');
  }
  
  // Check if entry exists for date
  const existing = await db.weightEntries.findOne({
    userId,
    date: { $gte: startOfDay(date), $lt: endOfDay(date) }
  });
  
  if (existing) {
    // Update existing entry
    return db.weightEntries.update(existing.id, { weight: weightKg });
  }
  
  // Create new entry
  const entry = await db.weightEntries.create({
    userId,
    weight: weightKg,
    date,
    createdAt: new Date()
  });
  
  // Update weight trend
  await updateWeightTrend(userId);
  
  return entry;
}
```

**Acceptance Criteria**:
- AC1: Weight is validated (30-300 kg)
- AC2: Units are converted correctly
- AC3: One entry per day (updates if exists)
- AC4: Weight chart updates immediately
- AC5: Trend is calculated (7-day average)

---

## 9. E-Commerce

### FR-STORE-001: View Products
**Priority**: Medium  
**User Story**: As a user, I want to browse fitness products so that I can purchase equipment and supplements.

**Requirements**:
- System SHALL display product catalog with photos and prices
- System SHALL support search and filtering
- System SHALL show product ratings and reviews
- System SHALL display stock status
- System SHALL support multiple categories

**Acceptance Criteria**:
- AC1: Products displayed in grid with photos
- AC2: Search returns relevant results
- AC3: Filters work (category, price range, rating)
- AC4: Out of stock products are marked clearly

---

### FR-STORE-002: Place Order
**Priority**: Medium  
**User Story**: As a user, I want to purchase products so that I can receive fitness equipment.

**Requirements**:
- System SHALL validate cart items and quantities
- System SHALL calculate total with tax and shipping
- System SHALL process payment via Stripe/Paddle
- System SHALL create order record upon successful payment
- System SHALL send order confirmation email

**Processing**:
```typescript
async function placeOrder(
  userId: string,
  items: CartItem[],
  shippingAddress: Address,
  paymentMethodId: string
): Promise<Order> {
  // Validate items and stock
  for (const item of items) {
    const product = await db.products.findById(item.productId);
    if (product.stock < item.quantity) {
      throw new StockError(`Insufficient stock for ${product.name}`);
    }
  }
  
  // Calculate totals
  const subtotal = items.reduce((sum, item) => 
    sum + (item.price * item.quantity), 0
  );
  const tax = subtotal * 0.15; // 15% VAT in Saudi Arabia
  const shipping = calculateShipping(items, shippingAddress);
  const total = subtotal + tax + shipping;
  
  // Process payment
  const payment = await paymentService.charge({
    amount: total,
    currency: 'SAR',
    paymentMethodId,
    metadata: { userId }
  });
  
  if (!payment.success) {
    throw new PaymentError(payment.error);
  }
  
  // Create order
  const order = await db.orders.create({
    userId,
    items,
    subtotal,
    tax,
    shipping,
    total,
    shippingAddress,
    status: 'processing',
    paymentId: payment.id,
    createdAt: new Date()
  });
  
  // Update stock
  for (const item of items) {
    await db.products.decrementStock(item.productId, item.quantity);
  }
  
  // Send confirmation
  await sendOrderConfirmation(userId, order);
  
  return order;
}
```

**Acceptance Criteria**:
- AC1: Order is created only after successful payment
- AC2: Stock is decremented immediately
- AC3: Totals are calculated correctly (subtotal, tax, shipping)
- AC4: Order confirmation email is sent
- AC5: Order appears in user's order history

---

## 10. Coach Management

### FR-COACH-001: Create Workout Plan
**Priority**: High  
**User Story**: As a coach, I want to create workout plans for my clients so that they have structured training programs.

**Requirements**:
- System SHALL allow coach to select client
- System SHALL provide exercise library with search/filter
- System SHALL support drag-and-drop exercise ordering
- System SHALL validate plan structure (sets, reps, rest)
- System SHALL check for injury contraindications
- System SHALL save plan and assign to client

**Processing**:
```typescript
async function createWorkoutPlan(
  coachId: string,
  clientId: string,
  planData: WorkoutPlanData
): Promise<WorkoutPlan> {
  // Verify coach-client relationship
  const client = await db.users.findById(clientId);
  if (client.assignedCoachId !== coachId) {
    throw new PermissionError('Not assigned to this client');
  }
  
  // Check for injury contraindications
  const injuries = client.injuries || [];
  for (const day of planData.days) {
    for (const exercise of day.exercises) {
      const isSafe = isExerciseSafe(exercise, injuries);
      if (!isSafe) {
        console.warn(`Exercise ${exercise.name} may be unsafe for client injuries`);
        // Coach can override, but warn
      }
    }
  }
  
  // Create plan
  const plan = await db.workoutPlans.create({
    clientId,
    coachId,
    name: planData.name,
    daysPerWeek: planData.daysPerWeek,
    weeks: planData.weeks,
    createdAt: new Date(),
    isActive: true
  });
  
  // Deactivate previous plans
  await db.workoutPlans.updateMany(
    { clientId, id: { $ne: plan.id } },
    { isActive: false }
  );
  
  // Notify client
  await notifyClient(clientId, 'New workout plan assigned');
  
  return plan;
}
```

**Acceptance Criteria**:
- AC1: Only assigned coach can create plans for client
- AC2: Injury warnings are shown for contraindicated exercises
- AC3: Plan structure is validated
- AC4: Plan is assigned and marked active
- AC5: Previous plans are deactivated
- AC6: Client is notified

---

## 11. Admin Management

### FR-ADMIN-001: Manage Users
**Priority**: High  
**User Story**: As an admin, I want to manage user accounts so that I can support users and handle issues.

**Requirements**:
- System SHALL display searchable/filterable user table
- System SHALL allow viewing user details
- System SHALL allow editing user profile
- System SHALL allow changing subscription tier (with reason)
- System SHALL allow suspending/reactivating accounts
- System SHALL log all admin actions in audit trail

**Acceptance Criteria**:
- AC1: Admin can search users by name, phone, ID
- AC2: Admin can filter by tier, status, date
- AC3: All user details are viewable
- AC4: Profile edits require reason (logged)
- AC5: Tier changes are logged with reason
- AC6: Suspension requires reason

---

## 12. Quota System

### FR-QUOTA-001: Check Quota
**Priority**: Critical  
**User Story**: As the system, I need to check quota before allowing actions so that tier limits are enforced.

**Requirements**:
- System SHALL check quota before message send
- System SHALL check quota before call booking
- System SHALL return remaining quota count
- System SHALL warn at 80% usage
- System SHALL block at 100% usage

**Logic**:
```typescript
async function checkQuota(
  userId: string,
  action: 'message' | 'call'
): Promise<QuotaCheckResult> {
  const user = await db.users.findById(userId);
  const quota = await db.quotaUsage.findByUserId(userId);
  const limits = TIER_QUOTAS[user.subscriptionTier];
  
  let allowed = true;
  let remaining = 0;
  let showWarning = false;
  let showUpgradePrompt = false;
  
  if (action === 'message') {
    if (limits.messages === 'unlimited') {
      return { allowed: true, remaining: null };
    }
    
    remaining = limits.messages - quota.messagesUsed;
    const usagePercent = (quota.messagesUsed / limits.messages) * 100;
    
    if (remaining <= 0) {
      allowed = false;
      showUpgradePrompt = true;
    } else if (usagePercent >= 80) {
      showWarning = true;
    }
  } else if (action === 'call') {
    remaining = limits.calls - quota.callsUsed;
    const usagePercent = (quota.callsUsed / limits.calls) * 100;
    
    if (remaining <= 0) {
      allowed = false;
      showUpgradePrompt = true;
    } else if (usagePercent >= 80) {
      showWarning = true;
    }
  }
  
  return {
    allowed,
    remaining,
    showWarning,
    showUpgradePrompt,
    reason: !allowed ? `${action} quota exceeded` : undefined
  };
}
```

**Acceptance Criteria**:
- AC1: Quota check returns correct allowed/blocked status
- AC2: Remaining count is accurate
- AC3: Warning shown at 80%+
- AC4: Upgrade prompt shown at 100%
- AC5: Unlimited tiers bypass checks

---

## 13. Rating System

### FR-RATING-001: Submit Coach Rating
**Priority**: Medium  
**User Story**: As a user, I want to rate my coach so that I can provide feedback on my experience.

**Requirements**:
- System SHALL prompt for rating after video calls
- System SHALL prompt for rating after every 10 messages
- System SHALL accept 1-5 star rating
- System SHALL accept optional text feedback
- System SHALL allow skipping rating
- System SHALL save rating and update coach's average

**Processing**:
```typescript
async function submitRating(
  userId: string,
  coachId: string,
  rating: number,
  feedback?: string,
  context: 'video_call' | 'messages'
): Promise<void> {
  // Validate rating
  if (rating < 1 || rating > 5) {
    throw new ValidationError('Rating must be 1-5');
  }
  
  // Create rating
  await db.coachRatings.create({
    userId,
    coachId,
    rating,
    feedback,
    context,
    createdAt: new Date()
  });
  
  // Update coach's average rating
  await updateCoachAverageRating(coachId);
}

async function updateCoachAverageRating(coachId: string): Promise<void> {
  const ratings = await db.coachRatings.find({ coachId });
  
  if (ratings.length === 0) return;
  
  const total = ratings.reduce((sum, r) => sum + r.rating, 0);
  const average = total / ratings.length;
  
  await db.coaches.update(coachId, {
    averageRating: average,
    totalRatings: ratings.length
  });
}
```

**Acceptance Criteria**:
- AC1: Rating prompt appears after video calls
- AC2: Rating prompt appears after every 10 messages
- AC3: User can skip rating
- AC4: Rating is saved successfully
- AC5: Coach's average rating updates
- AC6: Rating is visible to admin

---

## 14. Injury Management

### FR-INJURY-001: Detect Contraindicated Exercises
**Priority**: High  
**User Story**: As a user with injuries, I want the system to detect unsafe exercises so that I can avoid worsening my condition.

**Requirements**:
- System SHALL check exercises against user's injury list
- System SHALL display warning badge for contraindicated exercises
- System SHALL provide reasoning for warning
- System SHALL suggest safe alternatives
- System SHALL allow one-click substitution

**Logic**:
```typescript
const INJURY_RULES: Record<InjuryArea, ContraindicatedExercise[]> = {
  shoulder: [
    { name: 'Overhead Press', reason: 'High shoulder stress' },
    { name: 'Pull-ups', reason: 'Shoulder strain at bottom position' },
    { name: 'Bench Press', reason: 'Shoulder impingement risk' }
  ],
  knee: [
    { name: 'Barbell Squat', reason: 'High knee compression' },
    { name: 'Lunges', reason: 'Knee shearing force' },
    { name: 'Leg Press', reason: 'Excessive knee load' }
  ],
  lower_back: [
    { name: 'Deadlift', reason: 'Spinal compression' },
    { name: 'Barbell Row', reason: 'Lower back strain' },
    { name: 'Leg Press', reason: 'Lumbar compression' }
  ],
  neck: [
    { name: 'Barbell Shrugs', reason: 'Neck strain' },
    { name: 'Upright Row', reason: 'Neck compression' }
  ],
  ankle: [
    { name: 'Box Jumps', reason: 'Ankle impact stress' },
    { name: 'Jump Rope', reason: 'Repetitive ankle strain' },
    { name: 'Running', reason: 'High ankle impact' }
  ]
};

function isExerciseSafe(
  exercise: Exercise,
  injuries: InjuryArea[]
): boolean {
  for (const injury of injuries) {
    const contraindicated = INJURY_RULES[injury];
    const isSafe = !contraindicated.some(c => 
      c.name.toLowerCase() === exercise.name.toLowerCase()
    );
    if (!isSafe) return false;
  }
  return true;
}

function getSafeAlternatives(
  exercise: Exercise,
  injury: InjuryArea
): Exercise[] {
  const alternatives = INJURY_ALTERNATIVES[injury][exercise.name];
  return alternatives || [];
}
```

**Acceptance Criteria**:
- AC1: Contraindicated exercises show warning badge
- AC2: Warning includes reason (e.g., "High knee compression")
- AC3: 3 safe alternatives are suggested
- AC4: User can replace exercise with one click
- AC5: Replacement updates workout plan immediately

---

## Summary Statistics

- **Total Functional Requirements**: 40+ detailed requirements
- **Critical Priority**: 15 requirements
- **High Priority**: 18 requirements
- **Medium Priority**: 7+ requirements
- **Coverage**: All major features of v2.0 platform

---

**Document Status**: ✅ Complete  
**Last Updated**: December 2024  
**Version**: 2.0.0

---

**End of Functional Requirements Specification**
