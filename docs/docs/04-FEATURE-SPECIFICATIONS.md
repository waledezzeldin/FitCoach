# FitCoach+ v2.0 - Feature Specifications

## Document Information
- **Document**: Feature-Level Specifications
- **Version**: 2.0.0
- **Last Updated**: December 8, 2024
- **Purpose**: Deep dive into major v2.0 features and business logic

---

## Table of Contents

1. Phone OTP Authentication System
2. Two-Stage Intake System
3. Quota Management System
4. Time-Limited Nutrition Access
5. Chat Attachments Gating
6. Post-Interaction Rating System
7. Injury Substitution Engine
8. Subscription Management
9. Coach Assignment System
10. Progress Tracking System

---

## 1. Phone OTP Authentication System (v2.0)

### Overview
Password-less authentication using Saudi phone numbers with SMS-delivered one-time passwords (OTP). Eliminates password management overhead and provides secure access.

### Business Requirements

**Supported Phone Format**
- Country: Saudi Arabia only (v2.0)
- Format: +966 5X XXX XXXX
- First digit after country code: Must be "5" (mobile numbers)
- Total digits: 9 (after +966)

**OTP Specifications**
- Length: 6 digits
- Character set: Numeric only (0-9)
- Validity: 5 minutes from generation
- Delivery method: SMS via Twilio or AWS SNS
- Rate limiting: Max 3 OTP requests per phone number per hour

### Technical Implementation

#### Phone Number Validation

```typescript
interface PhoneValidationResult {
  isValid: boolean;
  formatted: string;  // +966512345678
  error?: string;
}

function validateSaudiPhoneNumber(input: string): PhoneValidationResult {
  // Remove all non-numeric characters
  const cleaned = input.replace(/\D/g, '');
  
  // Check length (9 digits for Saudi mobile)
  if (cleaned.length !== 9) {
    return {
      isValid: false,
      formatted: '',
      error: 'Phone number must be 9 digits'
    };
  }
  
  // Check first digit is 5 (Saudi mobile)
  if (cleaned[0] !== '5') {
    return {
      isValid: false,
      formatted: '',
      error: 'Phone number must start with 5'
    };
  }
  
  // Format with country code
  const formatted = `+966${cleaned}`;
  
  return {
    isValid: true,
    formatted,
    error: undefined
  };
}
```

#### OTP Generation

```typescript
function generateOTP(): string {
  // Generate random 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  return code;
}
```

#### OTP Storage (Server-Side)

```typescript
interface OTPSession {
  id: string;
  phoneNumber: string;
  otpCode: string;           // Hashed in production
  createdAt: Date;
  expiresAt: Date;
  attempts: number;
  isVerified: boolean;
  verifiedAt?: Date;
}

async function createOTPSession(phoneNumber: string): Promise<OTPSession> {
  const code = generateOTP();
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 5 * 60 * 1000); // +5 minutes
  
  const session: OTPSession = {
    id: generateUUID(),
    phoneNumber,
    otpCode: hashOTP(code),  // Hash before storage
    createdAt: now,
    expiresAt,
    attempts: 0,
    isVerified: false
  };
  
  await database.otpSessions.insert(session);
  await sendSMS(phoneNumber, `Your FitCoach+ verification code is: ${code}`);
  
  return session;
}
```

#### OTP Verification

```typescript
interface VerificationResult {
  success: boolean;
  user?: UserProfile;
  token?: string;
  error?: string;
}

async function verifyOTP(
  phoneNumber: string,
  enteredCode: string
): Promise<VerificationResult> {
  // Find active session
  const session = await database.otpSessions.findOne({
    phoneNumber,
    isVerified: false
  });
  
  if (!session) {
    return { success: false, error: 'No active session found' };
  }
  
  // Check expiry
  if (new Date() > session.expiresAt) {
    return { success: false, error: 'OTP expired' };
  }
  
  // Check attempts (max 3)
  if (session.attempts >= 3) {
    return { success: false, error: 'Too many attempts' };
  }
  
  // Verify code
  const isMatch = await compareOTP(enteredCode, session.otpCode);
  
  if (!isMatch) {
    // Increment attempts
    await database.otpSessions.update(session.id, {
      attempts: session.attempts + 1
    });
    return { success: false, error: 'Invalid code' };
  }
  
  // Mark as verified
  await database.otpSessions.update(session.id, {
    isVerified: true,
    verifiedAt: new Date()
  });
  
  // Check if user exists
  let user = await database.users.findOne({ phoneNumber });
  
  if (!user) {
    // New user - create minimal profile
    user = await createNewUser(phoneNumber);
  }
  
  // Generate auth token (JWT)
  const token = generateJWT(user.id, user.phoneNumber);
  
  return {
    success: true,
    user,
    token
  };
}
```

### Security Considerations

**Rate Limiting**
- Max 3 OTP send requests per phone per hour
- Max 3 verification attempts per OTP session
- 5-minute lockout after failed attempts
- IP-based rate limiting (max 10 requests per IP per hour)

**OTP Storage**
- Hash OTP codes before database storage (bcrypt or similar)
- Auto-delete expired OTP sessions (scheduled job)
- Never log OTP codes in plaintext

**SMS Provider Security**
- Use dedicated SMS provider credentials
- Rotate API keys quarterly
- Monitor for unusual sending patterns
- Implement SMS cost alerts

### Error Handling

**User-Facing Error Messages**
- "Invalid phone number format"
- "Code expired. Please request a new one."
- "Invalid code. Please try again."
- "Too many attempts. Please try again in 5 minutes."
- "Unable to send SMS. Please check your phone number."

**Server-Side Logging**
- Log OTP send events (without code)
- Log verification attempts (success/failure)
- Alert on unusual patterns (high failure rate)

### Testing Strategy

**Unit Tests**
- Phone number validation (valid/invalid formats)
- OTP generation (format, uniqueness)
- Expiry calculation
- Attempt counting

**Integration Tests**
- Full authentication flow (send → verify)
- Rate limiting enforcement
- Expiry handling
- SMS delivery (use test phone numbers)

**Manual Testing**
- Real device SMS reception
- Network failure scenarios
- Concurrent OTP requests
- Browser back button behavior

---

## 2. Two-Stage Intake System (v2.0)

### Overview
Progressive user onboarding with two distinct intake forms:
- **First Intake (IntakeV1)**: 3 quick questions, required for all users
- **Second Intake (IntakeV2)**: 6 detailed questions, exclusive to Premium+ users

### Business Requirements

**First Intake (All Users)**
- **When**: Immediately after phone verification (new users)
- **Cannot skip**: Required for account activation
- **Purpose**: Collect minimum viable fitness profile
- **Questions**: 3
  1. Gender (male/female/other)
  2. Main Goal (fat loss/muscle gain/general fitness)
  3. Workout Location (home/gym)

**Second Intake (Premium+ Only)**
- **When**: Immediately after first intake (Premium+) OR on upgrade
- **Can defer**: Premium+ users can complete later from settings
- **Purpose**: Detailed fitness profile for personalized plans
- **Gating**: Freemium users see upgrade prompt
- **Questions**: 6
  1. Age (13-120 years)
  2. Weight (30-300 kg)
  3. Height (100-250 cm)
  4. Experience Level (beginner/intermediate/advanced)
  5. Workout Frequency (2-6 days/week)
  6. Injuries (multi-select: shoulder/knee/lower back/neck/ankle/none)

### Data Flow

#### New User Journey

```
Phone OTP Verification (✓)
         ↓
   First Intake (3 questions)
         ↓
   Save to UserProfile
         ↓
    Check Tier
         ↓
   ┌─────┴─────┐
   ↓           ↓
Freemium    Premium+
   ↓           ↓
  Home    Second Intake (6 questions)
               ↓
          Save to UserProfile
               ↓
       Calculate Fitness Score
               ↓
              Home
```

#### Upgrade Journey

```
User Upgrades (Freemium → Premium)
         ↓
    Check if Second Intake Completed
         ↓
   ┌─────┴─────┐
   ↓           ↓
  Yes          No
   ↓           ↓
  Home    Set Pending Flag
          (localStorage)
               ↓
          Show Toast Prompt
               ↓
    "Complete your detailed profile"
               ↓
    User clicks → Second Intake
```

### Implementation

#### First Intake Submission

```typescript
async function submitFirstIntake(data: FirstIntakeData): Promise<void> {
  // Validate
  const validation = validateFirstIntake(data);
  if (!validation.isValid) {
    throw new Error(validation.errors.join(', '));
  }
  
  // Update user profile
  await database.users.update(userId, {
    gender: data.gender,
    mainGoal: data.mainGoal,
    workoutLocation: data.workoutLocation
  });
  
  // Mark intake as complete
  await localStorage.setItem(`first_intake_completed_${phoneNumber}`, 'true');
  
  // Decide next screen
  const user = await database.users.findById(userId);
  if (user.subscriptionTier === 'Freemium') {
    navigate('home');
  } else {
    navigate('secondIntake');
  }
}
```

#### Second Intake Submission

```typescript
async function submitSecondIntake(data: SecondIntakeData): Promise<void> {
  // Validate
  const validation = validateSecondIntake(data);
  if (!validation.isValid) {
    throw new Error(validation.errors.join(', '));
  }
  
  // Calculate fitness score
  const fitnessScore = calculateFitnessScore(data);
  
  // Update user profile
  await database.users.update(userId, {
    age: data.age,
    weight: data.weight,
    height: data.height,
    experienceLevel: data.experienceLevel,
    workoutFrequency: data.workoutFrequency,
    injuries: data.injuries,
    hasCompletedSecondIntake: true,
    fitnessScore,
    fitnessScoreUpdatedBy: 'auto',
    fitnessScoreLastUpdated: new Date()
  });
  
  // Clear pending flag
  localStorage.removeItem(`pending_nutrition_intake_${phoneNumber}`);
  
  // Mark intake as complete
  localStorage.setItem(`second_intake_completed_${phoneNumber}`, 'true');
  
  // Navigate to home
  navigate('home');
  
  // Show success toast
  toast.success('Profile completed! Your personalized plan is ready.');
}
```

#### Fitness Score Auto-Calculation

```typescript
function calculateFitnessScore(data: SecondIntakeData): number {
  let score = 50; // Base score
  
  // Experience level contribution (0-30 points)
  switch (data.experienceLevel) {
    case 'beginner':
      score += 0;
      break;
    case 'intermediate':
      score += 15;
      break;
    case 'advanced':
      score += 30;
      break;
  }
  
  // Workout frequency contribution (0-12 points)
  // 2 days = 0, 3 days = 3, 4 days = 6, 5 days = 9, 6 days = 12
  score += (data.workoutFrequency - 2) * 3;
  
  // Injury penalty (-5 points per injury)
  score -= data.injuries.length * 5;
  
  // Clamp to 0-100 range
  return Math.max(0, Math.min(100, score));
}
```

### Upgrade Prompt (Freemium Access Control)

```typescript
function SecondIntakeScreen() {
  const { userProfile } = useApp();
  
  // Gate check
  if (userProfile.subscriptionTier === 'Freemium') {
    return (
      <UpgradePromptScreen
        icon="🔒"
        title={t('intake.premiumRequired')}
        message={t('intake.premiumMessage')}
        benefits={[
          t('intake.benefit1'), // "Detailed fitness profile"
          t('intake.benefit2'), // "Personalized workout plans"
          t('intake.benefit3'), // "Injury-aware programming"
          t('intake.benefit4')  // "Advanced progress tracking"
        ]}
        requiredTier="Premium"
        currentTier={userProfile.subscriptionTier}
        onUpgrade={() => navigate('checkout')}
        onCancel={() => navigate('home')}
      />
    );
  }
  
  // Premium+ users see the actual intake form
  return <SecondIntakeForm />;
}
```

### Data Validation

**First Intake Rules**
```typescript
const FIRST_INTAKE_RULES = {
  gender: {
    required: true,
    options: ['male', 'female', 'other']
  },
  mainGoal: {
    required: true,
    options: ['fat_loss', 'muscle_gain', 'general_fitness']
  },
  workoutLocation: {
    required: true,
    options: ['home', 'gym']
  }
};
```

**Second Intake Rules**
```typescript
const SECOND_INTAKE_RULES = {
  age: {
    required: true,
    type: 'number',
    min: 13,
    max: 120,
    errorMessage: 'Age must be between 13 and 120'
  },
  weight: {
    required: true,
    type: 'number',
    min: 30,
    max: 300,
    unit: 'kg',
    errorMessage: 'Weight must be between 30 and 300 kg'
  },
  height: {
    required: true,
    type: 'number',
    min: 100,
    max: 250,
    unit: 'cm',
    errorMessage: 'Height must be between 100 and 250 cm'
  },
  experienceLevel: {
    required: true,
    options: ['beginner', 'intermediate', 'advanced']
  },
  workoutFrequency: {
    required: true,
    type: 'number',
    min: 2,
    max: 6,
    errorMessage: 'Workout frequency must be 2-6 days per week'
  },
  injuries: {
    required: false, // Can be empty array
    type: 'array',
    options: ['shoulder', 'knee', 'lower_back', 'neck', 'ankle']
  }
};
```

### Edge Cases

**Scenario 1: User Exits Mid-Intake**
- First Intake: Data not saved, must restart on next login
- Second Intake: Draft saved to localStorage, can resume

**Scenario 2: User Upgrades During Onboarding**
- If on first intake screen → Complete first, then second
- If already completed first → Prompt for second intake

**Scenario 3: User Downgrades from Premium to Freemium**
- Second intake data retained in database
- Still accessible for analytics
- Re-activates if user upgrades again

**Scenario 4: Coach Override**
- Coach can view and edit user's intake data
- Coach can manually adjust fitness score
- Updates tracked: `fitnessScoreUpdatedBy: 'coach'`

### Analytics & Metrics

**Track These Events**
- `first_intake_started`
- `first_intake_completed`
- `first_intake_abandoned` (if user exits)
- `second_intake_started`
- `second_intake_completed`
- `second_intake_upgrade_prompt_shown`
- `second_intake_upgrade_clicked`
- `fitness_score_calculated`

**Key Metrics**
- First intake completion rate: Target 95%+
- Second intake completion rate (Premium+): Target 80%+
- Upgrade conversion from second intake gate: Track %
- Average time to complete each intake

---

## 3. Quota Management System (v2.0)

### Overview
Tier-based usage limits for messages and video calls, with real-time tracking, visual progress indicators, and hard enforcement to drive subscription upgrades.

### Business Requirements

**Quota Definitions by Tier**

```typescript
const TIER_QUOTAS: Record<SubscriptionTier, QuotaLimits> = {
  'Freemium': {
    messages: 20,
    calls: 1,
    callDuration: 15,  // minutes
    chatAttachments: false,
    nutritionPersistent: false,
    nutritionWindowDays: 7
  },
  'Premium': {
    messages: 200,
    calls: 2,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null  // unlimited
  },
  'Smart Premium': {
    messages: 'unlimited',
    calls: 4,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null
  }
};
```

**Reset Schedule**
- **Frequency**: Monthly
- **Reset Date**: First day of each month (00:00:00 UTC)
- **Carried Over**: No rollover of unused quota
- **Pro-rated**: New subscriptions get full month quota regardless of start date

### Implementation

#### Initialize Quota on Account Creation

```typescript
async function initializeQuotaUsage(
  userId: string,
  tier: SubscriptionTier
): Promise<QuotaUsage> {
  const limits = TIER_QUOTAS[tier];
  const now = new Date();
  const resetDate = new Date(now.getFullYear(), now.getMonth() + 1, 1);
  
  const quotaUsage: QuotaUsage = {
    userId,
    tier,
    messagesUsed: 0,
    messagesTotal: limits.messages,
    callsUsed: 0,
    callsTotal: limits.calls,
    resetDate,
    lastResetAt: now,
    updatedAt: now
  };
  
  await database.quotaUsage.insert(quotaUsage);
  return quotaUsage;
}
```

#### Check Quota Before Action

```typescript
async function checkQuota(
  userId: string,
  action: 'message' | 'call' | 'attachment'
): Promise<QuotaCheckResult> {
  const user = await database.users.findById(userId);
  const quota = await database.quotaUsage.findByUserId(userId);
  const limits = TIER_QUOTAS[user.subscriptionTier];
  
  switch (action) {
    case 'message': {
      // Unlimited check
      if (limits.messages === 'unlimited') {
        return { allowed: true };
      }
      
      // Calculate remaining
      const remaining = limits.messages - quota.messagesUsed;
      
      // Hard block if exceeded
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Message quota exceeded',
          remaining: 0,
          showUpgradePrompt: true
        };
      }
      
      // Warning if at 80%+
      const usagePercent = (quota.messagesUsed / limits.messages) * 100;
      
      return {
        allowed: true,
        remaining,
        showWarning: usagePercent >= 80
      };
    }
    
    case 'call': {
      const remaining = limits.calls - quota.callsUsed;
      
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Video call quota exceeded',
          remaining: 0,
          showUpgradePrompt: true
        };
      }
      
      const usagePercent = (quota.callsUsed / limits.calls) * 100;
      
      return {
        allowed: true,
        remaining,
        showWarning: usagePercent >= 80
      };
    }
    
    case 'attachment': {
      if (!limits.chatAttachments) {
        return {
          allowed: false,
          reason: 'Attachments require Premium subscription',
          showUpgradePrompt: true
        };
      }
      
      return { allowed: true };
    }
  }
}
```

#### Increment Quota Usage

```typescript
async function incrementQuotaUsage(
  userId: string,
  action: 'message' | 'call'
): Promise<void> {
  const quota = await database.quotaUsage.findByUserId(userId);
  
  switch (action) {
    case 'message':
      await database.quotaUsage.update(userId, {
        messagesUsed: quota.messagesUsed + 1,
        updatedAt: new Date()
      });
      break;
      
    case 'call':
      await database.quotaUsage.update(userId, {
        callsUsed: quota.callsUsed + 1,
        updatedAt: new Date()
      });
      break;
  }
  
  // Log event for analytics
  await analytics.track('quota_incremented', {
    userId,
    action,
    tier: quota.tier,
    remaining: await getQuotaRemaining(userId, action)
  });
}
```

#### Monthly Reset Job

```typescript
// Scheduled task (cron job) runs daily at 00:05 UTC
async function resetMonthlyQuotas(): Promise<void> {
  const now = new Date();
  
  // Find all quotas that need reset (resetDate <= now)
  const quotasToReset = await database.quotaUsage.find({
    resetDate: { $lte: now }
  });
  
  for (const quota of quotasToReset) {
    const user = await database.users.findById(quota.userId);
    const limits = TIER_QUOTAS[user.subscriptionTier];
    
    // Calculate next reset date
    const nextResetDate = new Date(now.getFullYear(), now.getMonth() + 1, 1);
    
    // Reset usage
    await database.quotaUsage.update(quota.userId, {
      messagesUsed: 0,
      callsUsed: 0,
      messagesTotal: limits.messages,
      callsTotal: limits.calls,
      resetDate: nextResetDate,
      lastResetAt: now,
      updatedAt: now
    });
    
    // Notify user (optional)
    await sendNotification(user, {
      title: 'Quota Reset',
      message: 'Your monthly message and call quota has been reset.'
    });
  }
  
  console.log(`Reset ${quotasToReset.length} quotas`);
}
```

### UI Integration

#### Quota Display Component

```typescript
function QuotaDisplay({ userId }: { userId: string }) {
  const [quota, setQuota] = useState<QuotaUsage | null>(null);
  const [user, setUser] = useState<UserProfile | null>(null);
  
  useEffect(() => {
    loadQuota();
  }, [userId]);
  
  async function loadQuota() {
    const q = await api.getQuotaUsage(userId);
    const u = await api.getUser(userId);
    setQuota(q);
    setUser(u);
  }
  
  if (!quota || !user) return <Skeleton />;
  
  const limits = TIER_QUOTAS[user.subscriptionTier];
  const messagePercent = limits.messages === 'unlimited' 
    ? 0 
    : (quota.messagesUsed / limits.messages) * 100;
  const callPercent = (quota.callsUsed / limits.calls) * 100;
  
  return (
    <div className="quota-display">
      {/* Messages */}
      <div className="quota-item">
        <div className="quota-header">
          <span>💬 Messages</span>
          <span>
            {limits.messages === 'unlimited' 
              ? 'Unlimited'
              : `${quota.messagesUsed} / ${limits.messages}`
            }
          </span>
        </div>
        {limits.messages !== 'unlimited' && (
          <ProgressBar 
            value={messagePercent} 
            variant={messagePercent >= 80 ? 'warning' : 'default'}
          />
        )}
      </div>
      
      {/* Calls */}
      <div className="quota-item">
        <div className="quota-header">
          <span>📞 Video Calls</span>
          <span>{quota.callsUsed} / {limits.calls}</span>
        </div>
        <ProgressBar 
          value={callPercent} 
          variant={callPercent >= 80 ? 'warning' : 'default'}
        />
      </div>
      
      {/* Reset Date */}
      <div className="quota-footer">
        <span>Resets on {formatDate(quota.resetDate)}</span>
      </div>
    </div>
  );
}
```

#### Message Send with Quota Check

```typescript
async function sendMessage(content: string, conversationId: string) {
  const userId = getCurrentUserId();
  
  // Check quota before sending
  const quotaCheck = await checkQuota(userId, 'message');
  
  if (!quotaCheck.allowed) {
    // Show upgrade prompt
    showUpgradeModal({
      title: 'Message Quota Exceeded',
      message: quotaCheck.reason,
      currentTier: user.subscriptionTier,
      suggestedTier: user.subscriptionTier === 'Freemium' ? 'Premium' : 'Smart Premium',
      onUpgrade: () => navigate('checkout')
    });
    return;
  }
  
  // Show warning if at 80%+
  if (quotaCheck.showWarning) {
    toast.warning(
      `You have ${quotaCheck.remaining} messages remaining this month`,
      { duration: 3000 }
    );
  }
  
  // Send message
  const message = await api.sendMessage({
    conversationId,
    content,
    senderId: userId,
    senderType: 'user'
  });
  
  // Increment quota
  await incrementQuotaUsage(userId, 'message');
  
  return message;
}
```

### Edge Cases

**Scenario 1: Tier Upgrade Mid-Month**
- User upgrades from Freemium (20 msg) to Premium (200 msg)
- Current usage: 15 messages
- **Solution**: Quota total updates immediately, usage retained
- New quota: 15 / 200 messages used

**Scenario 2: Tier Downgrade Mid-Month**
- User downgrades from Premium (200 msg) to Freemium (20 msg)
- Current usage: 50 messages
- **Solution**: Usage exceeds new limit → hard block immediately
- Display: "50 / 20 messages used (quota exceeded)"

**Scenario 3: Timezone Considerations**
- Reset happens at 00:00 UTC
- User in Saudi Arabia (UTC+3) sees reset at 3:00 AM local
- **Display**: Show reset date in user's local timezone

**Scenario 4: Concurrent Actions**
- Multiple messages sent simultaneously
- **Solution**: Use database transactions/locks
- Ensure quota doesn't go negative

### Testing Strategy

**Unit Tests**
- Quota calculation (remaining, percentage)
- Tier configuration validation
- Reset date calculation

**Integration Tests**
- Full quota check flow
- Increment and decrement
- Monthly reset job
- Upgrade/downgrade scenarios

**Load Tests**
- Concurrent quota checks (1000+ users)
- Database lock behavior
- API response times under load

---

## 4. Time-Limited Nutrition Access (v2.0)

### Overview
Freemium users receive a 7-day trial window for nutrition features starting from first meal plan generation. Premium+ users have unlimited persistent access.

### Business Requirements

**Access Rules**
- **Freemium**: 7-day trial from first generation
- **Premium**: Unlimited persistent access
- **Smart Premium**: Unlimited persistent access
- **Trial Extension**: Not allowed (must upgrade)
- **Re-activation**: Yes, if user upgrades later

**Trial Lifecycle**

```
Freemium User Generates First Nutrition Plan
         ↓
   Trial Starts (Day 1)
         ↓
   Days 1-4: Full Access (No warnings)
         ↓
   Day 5: Info banner "2 days left"
         ↓
   Day 6: Warning banner "1 day left"
         ↓
   Day 7: Critical banner "Last day!"
         ↓
   Day 8+: Locked screen (Upgrade required)
```

### Implementation

#### Generate Nutrition Plan (Sets Expiry)

```typescript
async function generateNutritionPlan(
  userId: string,
  preferences: NutritionPreferences
): Promise<NutritionPlan> {
  const user = await database.users.findById(userId);
  
  // Generate plan based on preferences
  const plan = await nutritionAI.generatePlan(user, preferences);
  
  // Set expiry for Freemium users only
  const now = new Date();
  let expiresAt: Date | null = null;
  
  if (user.subscriptionTier === 'Freemium') {
    // Trial = 7 days from now
    expiresAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
  }
  
  // Save plan with expiry
  const savedPlan = await database.nutritionPlans.create({
    ...plan,
    userId,
    generatedAt: now,
    expiresAt,
    isActive: true
  });
  
  // Track event
  await analytics.track('nutrition_plan_generated', {
    userId,
    tier: user.subscriptionTier,
    expiresAt,
    trialDays: expiresAt ? 7 : null
  });
  
  return savedPlan;
}
```

#### Check Nutrition Access

```typescript
interface NutritionAccessResult {
  hasAccess: boolean;
  isExpired: boolean;
  daysLeft: number;
  expiresAt?: Date;
  reason?: string;
}

async function checkNutritionAccess(userId: string): Promise<NutritionAccessResult> {
  const user = await database.users.findById(userId);
  
  // Premium+ always has access
  if (user.subscriptionTier === 'Premium' || user.subscriptionTier === 'Smart Premium') {
    return {
      hasAccess: true,
      isExpired: false,
      daysLeft: Infinity
    };
  }
  
  // Freemium: Check for plan
  const plan = await database.nutritionPlans.findActiveByUserId(userId);
  
  if (!plan) {
    // No plan generated yet
    return {
      hasAccess: true,  // Can generate first plan
      isExpired: false,
      daysLeft: 7
    };
  }
  
  if (!plan.expiresAt) {
    // Plan exists but no expiry (shouldn't happen for Freemium, but handle it)
    return {
      hasAccess: true,
      isExpired: false,
      daysLeft: Infinity
    };
  }
  
  // Calculate days left
  const now = new Date();
  const msLeft = plan.expiresAt.getTime() - now.getTime();
  const daysLeft = Math.ceil(msLeft / (1000 * 60 * 60 * 24));
  
  if (daysLeft <= 0) {
    // Expired
    return {
      hasAccess: false,
      isExpired: true,
      daysLeft: 0,
      expiresAt: plan.expiresAt,
      reason: 'Trial period ended. Upgrade to continue.'
    };
  }
  
  // Still within trial
  return {
    hasAccess: true,
    isExpired: false,
    daysLeft,
    expiresAt: plan.expiresAt
  };
}
```

#### Nutrition Screen Access Control

```typescript
function NutritionScreen() {
  const { userProfile } = useApp();
  const [accessResult, setAccessResult] = useState<NutritionAccessResult | null>(null);
  
  useEffect(() => {
    checkAccess();
  }, [userProfile.id]);
  
  async function checkAccess() {
    const result = await checkNutritionAccess(userProfile.id);
    setAccessResult(result);
  }
  
  // Loading state
  if (!accessResult) {
    return <LoadingScreen />;
  }
  
  // Expired - show locked screen
  if (accessResult.isExpired) {
    return (
      <LockedNutritionScreen
        title="Nutrition Access Expired"
        message={accessResult.reason}
        expiresAt={accessResult.expiresAt}
        onUpgrade={() => navigate('checkout')}
      />
    );
  }
  
  // Has access - show nutrition plan
  return (
    <>
      {/* Show expiry warning banner if within 3 days */}
      {accessResult.daysLeft <= 3 && accessResult.daysLeft > 0 && (
        <ExpiryBanner
          daysLeft={accessResult.daysLeft}
          onUpgrade={() => navigate('checkout')}
        />
      )}
      
      <NutritionPlanView />
    </>
  );
}
```

#### Expiry Banner Component

```typescript
function ExpiryBanner({ daysLeft, onUpgrade }: ExpiryBannerProps) {
  const { t } = useLanguage();
  
  // Determine severity
  const severity = daysLeft <= 1 ? 'critical' : daysLeft <= 2 ? 'warning' : 'info';
  
  // Icon and color
  const icon = severity === 'critical' ? '🔴' : severity === 'warning' ? '⚠️' : 'ℹ️';
  const bgColor = severity === 'critical' ? 'bg-red-50' : severity === 'warning' ? 'bg-orange-50' : 'bg-blue-50';
  
  return (
    <div className={`expiry-banner ${bgColor} p-4 flex items-center justify-between`}>
      <div className="flex items-center gap-2">
        <span className="text-2xl">{icon}</span>
        <div>
          <p className="font-semibold">
            {t('nutrition.expiryWarning', { days: daysLeft })}
          </p>
          <p className="text-sm text-gray-600">
            {t('nutrition.upgradeToKeepAccess')}
          </p>
        </div>
      </div>
      <Button onClick={onUpgrade} variant="primary">
        {t('common.upgradeNow')}
      </Button>
    </div>
  );
}
```

### Upgrade Flow

#### When User Upgrades from Freemium

```typescript
async function handleUpgradeToPremuim(userId: string, newTier: SubscriptionTier) {
  const user = await database.users.findById(userId);
  
  // Update subscription tier
  await database.users.update(userId, {
    subscriptionTier: newTier,
    subscriptionStartDate: new Date()
  });
  
  // If user had nutrition plan, remove expiry
  const nutritionPlan = await database.nutritionPlans.findActiveByUserId(userId);
  
  if (nutritionPlan && nutritionPlan.expiresAt) {
    await database.nutritionPlans.update(nutritionPlan.id, {
      expiresAt: null  // Remove expiry = unlimited access
    });
    
    // Track event
    await analytics.track('nutrition_access_unlocked', {
      userId,
      previousTier: user.subscriptionTier,
      newTier,
      hadExistingPlan: true
    });
  }
  
  // Show success message
  toast.success('Upgrade successful! Your nutrition access is now unlimited.');
}
```

### Edge Cases

**Scenario 1: User Generates Plan, Never Opens Nutrition Screen**
- Trial still starts from generation date
- When user finally opens nutrition screen 8 days later → Locked
- **Solution**: Track generation date, not first access date

**Scenario 2: User Upgrades on Day 7 (Last Day)**
- Trial about to expire in hours
- User upgrades
- **Solution**: Expiry removed immediately, full access granted

**Scenario 3: User Downgrades from Premium to Freemium**
- Previously had unlimited access
- Now on Freemium
- **Solution**: 
  - If no plan expiry set → Set expiry to 7 days from downgrade
  - If plan already had expiry → Keep existing expiry

**Scenario 4: Clock Manipulation (User Changes Device Time)**
- **Prevention**: Use server time for all expiry checks
- API endpoint returns current server time
- Client syncs periodically

### Testing Strategy

**Unit Tests**
- Expiry calculation (days left)
- Access check logic (all tiers)
- Banner severity determination

**Integration Tests**
- Full nutrition flow (generate → access → expire)
- Upgrade flow (Freemium → Premium)
- Downgrade flow (Premium → Freemium)

**Manual Testing**
- Generate plan as Freemium
- Check banners appear on correct days
- Verify locked screen after expiry
- Test upgrade unlock

**Time-Travel Testing**
- Mock current date to simulate day progression
- Test banner changes day by day
- Verify expiry at exact moment

---

## 5. Chat Attachments Gating (v2.0)

### Overview
Only Premium+ users can send file attachments (images, PDFs) in coach chat. Freemium and basic Premium users see disabled upload button with tooltip explaining the feature.

### Business Requirements

**Access Rules**
- **Freemium**: ❌ No attachments (disabled)
- **Premium**: ❌ No attachments (disabled)
- **Smart Premium**: ✅ Attachments enabled

**Allowed File Types**
- Images: JPG, PNG, HEIC (max 10MB each)
- Documents: PDF (max 5MB)
- Max attachments per message: 3 files

**Storage**
- Cloud storage: AWS S3 or similar
- File naming: `{userId}/{conversationId}/{messageId}_{timestamp}_{filename}`
- Retention: Permanent (unless user deletes account)

### Implementation

#### Check Attachment Permission

```typescript
function canSendAttachments(tier: SubscriptionTier): boolean {
  const limits = TIER_QUOTAS[tier];
  return limits.chatAttachments === true;
}
```

#### Message Input Component

```typescript
function MessageInput({ conversationId, currentUserTier }: MessageInputProps) {
  const [message, setMessage] = useState('');
  const [attachments, setAttachments] = useState<File[]>([]);
  const canAttach = canSendAttachments(currentUserTier);
  
  function handleFileSelect(event: React.ChangeEvent<HTMLInputElement>) {
    if (!canAttach) {
      // Show upgrade prompt
      showUpgradeModal({
        feature: 'Chat Attachments',
        requiredTier: 'Smart Premium',
        currentTier
      });
      return;
    }
    
    const files = Array.from(event.target.files || []);
    
    // Validate file types
    const validFiles = files.filter(file => {
      const ext = file.name.split('.').pop()?.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'heic', 'pdf'].includes(ext || '');
    });
    
    // Validate file sizes
    const validSizedFiles = validFiles.filter(file => {
      const maxSize = file.type.startsWith('image/') ? 10 * 1024 * 1024 : 5 * 1024 * 1024;
      return file.size <= maxSize;
    });
    
    // Limit to 3 files
    const finalFiles = validSizedFiles.slice(0, 3);
    
    setAttachments(finalFiles);
  }
  
  async function handleSend() {
    // Upload attachments first
    const uploadedUrls: string[] = [];
    
    for (const file of attachments) {
      const url = await uploadFile(file, conversationId);
      uploadedUrls.push(url);
    }
    
    // Send message with attachments
    await sendMessage({
      conversationId,
      content: message,
      attachments: uploadedUrls
    });
    
    // Clear inputs
    setMessage('');
    setAttachments([]);
  }
  
  return (
    <div className="message-input">
      <textarea
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        placeholder="Type your message..."
      />
      
      {/* Attachment Previews */}
      {attachments.length > 0 && (
        <div className="attachment-previews">
          {attachments.map((file, index) => (
            <AttachmentPreview
              key={index}
              file={file}
              onRemove={() => setAttachments(prev => prev.filter((_, i) => i !== index))}
            />
          ))}
        </div>
      )}
      
      <div className="input-actions">
        {/* Attachment Button */}
        <Tooltip
          content={
            canAttach
              ? 'Attach files (images, PDFs)'
              : '📎 Attachments available with Smart Premium'
          }
        >
          <label>
            <input
              type="file"
              multiple
              accept="image/*,.pdf"
              onChange={handleFileSelect}
              disabled={!canAttach}
              className="hidden"
            />
            <Button
              variant="ghost"
              size="icon"
              disabled={!canAttach}
              className={!canAttach ? 'opacity-50 cursor-not-allowed' : ''}
            >
              📎
            </Button>
          </label>
        </Tooltip>
        
        {/* Send Button */}
        <Button
          onClick={handleSend}
          disabled={!message.trim() && attachments.length === 0}
        >
          Send
        </Button>
      </div>
    </div>
  );
}
```

#### File Upload

```typescript
async function uploadFile(
  file: File,
  conversationId: string
): Promise<string> {
  const userId = getCurrentUserId();
  const messageId = generateUUID();
  const timestamp = Date.now();
  const ext = file.name.split('.').pop();
  
  // Generate unique filename
  const filename = `${userId}/${conversationId}/${messageId}_${timestamp}.${ext}`;
  
  // Upload to cloud storage (AWS S3, etc.)
  const formData = new FormData();
  formData.append('file', file);
  formData.append('filename', filename);
  
  const response = await api.post('/api/files/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  
  return response.data.url; // https://cdn.fitcoachplus.com/files/{filename}
}
```

#### Message Display with Attachments

```typescript
function MessageBubble({ message }: { message: Message }) {
  return (
    <div className="message-bubble">
      {/* Text Content */}
      {message.content && (
        <p>{message.content}</p>
      )}
      
      {/* Attachments */}
      {message.attachments && message.attachments.length > 0 && (
        <div className="message-attachments">
          {message.attachments.map((url, index) => {
            const isPDF = url.endsWith('.pdf');
            
            return (
              <div key={index} className="attachment">
                {isPDF ? (
                  <a href={url} target="_blank" rel="noopener noreferrer" className="pdf-attachment">
                    📄 View PDF
                  </a>
                ) : (
                  <img
                    src={url}
                    alt="Attachment"
                    className="image-attachment"
                    onClick={() => openLightbox(url)}
                  />
                )}
              </div>
            );
          })}
        </div>
      )}
      
      {/* Timestamp */}
      <span className="message-timestamp">
        {formatTime(message.createdAt)}
      </span>
    </div>
  );
}
```

### Security Considerations

**File Validation (Server-Side)**
```typescript
function validateUpload(file: Express.Multer.File): { valid: boolean; error?: string } {
  // Check file type
  const allowedMimes = [
    'image/jpeg',
    'image/png',
    'image/heic',
    'application/pdf'
  ];
  
  if (!allowedMimes.includes(file.mimetype)) {
    return { valid: false, error: 'Invalid file type' };
  }
  
  // Check file size
  const maxSize = file.mimetype.startsWith('image/') ? 10 * 1024 * 1024 : 5 * 1024 * 1024;
  
  if (file.size > maxSize) {
    return { valid: false, error: 'File too large' };
  }
  
  // Scan for malware (optional, using ClamAV or similar)
  const isSafe = await scanFileForMalware(file);
  if (!isSafe) {
    return { valid: false, error: 'File failed security scan' };
  }
  
  return { valid: true };
}
```

**Access Control**
- File URLs should be signed (temporary access tokens)
- Only conversation participants can access files
- Files deleted when conversation deleted
- Rate limiting: Max 10 file uploads per minute per user

### Edge Cases

**Scenario 1: User Attaches Files, Then Cancels Message**
- **Solution**: Delete uploaded files if message not sent within 5 minutes
- Implement cleanup job for orphaned files

**Scenario 2: User Attaches Large Image (>10MB)**
- **Solution**: Show error toast: "Image too large. Maximum 10MB."
- Offer image compression on client-side (future feature)

**Scenario 3: User Upgrades to Smart Premium Mid-Conversation**
- **Solution**: Attachment button becomes enabled immediately
- Show success toast: "You can now send attachments!"

**Scenario 4: User Tries to Upload Video**
- **Solution**: File rejected with error: "Video not supported. Please upload images or PDFs only."

### Testing Strategy

**Unit Tests**
- Permission check (all tiers)
- File type validation
- File size validation

**Integration Tests**
- Full upload flow (select → upload → send → display)
- Upgrade flow (disabled → enabled)
- Error handling (invalid file, too large, etc.)

**Security Tests**
- Malicious file upload attempts
- Oversized files
- SQL injection in filenames
- Path traversal attempts

---

*(Continued in next message due to length limit...)*

**End of Part 1 - Features 1-5**

Next sections to cover:
6. Post-Interaction Rating System
7. Injury Substitution Engine
8. Subscription Management
9. Coach Assignment System
10. Progress Tracking System
