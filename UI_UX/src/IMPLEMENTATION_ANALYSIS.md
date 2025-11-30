# FitCoach+ v2.0 Implementation Analysis & Roadmap

**Date:** October 15, 2025  
**Status:** Draft for Development Team Review  
**Current Version:** v1.x (Baseline with translations complete)  
**Target Version:** v2.0 (Enhanced with new requirements)

---

## Executive Summary

This document analyzes the gap between the current FitCoach+ implementation and the v2.0 requirements, providing a comprehensive roadmap for implementation. The major changes involve:

1. **Phone-based authentication** replacing email/password
2. **Two-stage intake system** (First vs Second Intake)
3. **Tiered quota enforcement** for messaging and calls
4. **Time-limited nutrition access** for Freemium users
5. **Gated features** based on subscription tier
6. **Post-interaction rating system**
7. **Injury-aware exercise substitution**

---

## 1. Authentication System (A-01, A-02, A-03)

### Current State
- **File:** `/components/AuthScreen.tsx`
- Email/password authentication with social OAuth options
- Demo mode activation via long-press
- No phone number support

### Required Changes
**Priority: HIGH** | **Effort: MEDIUM-HIGH**

#### Changes Needed:
1. **Phone Number Input & Validation**
   - Replace email input with phone number field
   - Support E.164 format validation
   - Country code selector
   - Format as user types (e.g., +1 (555) 123-4567)

2. **OTP Flow**
   - "Request OTP" button (replaces password field on login)
   - 6-digit OTP input component
   - 10-minute expiration countdown
   - "Resend OTP" button with 60-second cooldown
   - Failed attempt tracking (5 attempts = 15-minute lockout)

3. **Account Linking**
   - After phone auth, offer optional email/OAuth linking
   - New UI flow: Phone OTP → Success → Optional Link Email/OAuth
   - Store multiple auth methods per user account

4. **Session Management**
   - JWT access token + refresh token
   - Device list management
   - Token rotation on refresh

#### Implementation Notes:
```typescript
// New interfaces needed
interface PhoneAuthState {
  phoneNumber: string;
  countryCode: string;
  otpSent: boolean;
  otpCode: string;
  attemptsRemaining: number;
  lockoutUntil: Date | null;
  resendAvailableAt: Date | null;
}

// API calls needed (mock for demo)
- POST /auth/phone/request_otp
- POST /auth/phone/verify
- POST /auth/link (for linking email/OAuth)
```

#### Files to Modify:
- `/components/AuthScreen.tsx` - Complete rewrite
- `/App.tsx` - Update authentication state management
- Create new component: `/components/OTPInput.tsx`

---

## 2. Two-Stage Intake System (UX-01, UX-02, WO-01, WO-02, WO-03)

### Current State
- **File:** `/components/OnboardingScreen.tsx`
- Single 8-step onboarding flow
- All questions asked at once
- Generates one type of workout plan

### Required Changes
**Priority: CRITICAL** | **Effort: HIGH**

#### Current Flow:
```
Step 1: Name
Step 2: Age + Gender
Step 3: Weight
Step 4: Height
Step 5: Main Goal + Location
Step 6: Workout Frequency
Step 7: Experience Level
Step 8: Injuries
```

#### New Flow - First Intake (All Users):
```
Step 1: Gender
Step 2: Fitness Goal (fat_loss, muscle_gain, general_fitness)
Step 3: Exercise Location (home, gym)
→ Generates "Starter Plan" (generic based on these 3 answers)
→ Navigate to Home immediately (≤60 seconds from signup)
```

#### New Flow - Second Intake (Premium+ Only):
```
Triggered by: Upgrade to Premium/Smart Premium
OR: Re-intake button in Account settings

Step 1: Age
Step 2: Weight + Height
Step 3: Experience Level
Step 4: Days/Week (2-6)
Step 5: Injuries (multi-select)
→ Generates "Customized Plan" with injury substitutions
```

### Implementation Strategy:

#### A. Split Components:
1. **FirstIntakeScreen.tsx** (New)
   - 3 questions only
   - Fast, simple UI
   - Progress: 1/3, 2/3, 3/3
   - Completion time target: <60 seconds

2. **SecondIntakeScreen.tsx** (New)
   - 5 detailed questions
   - Only accessible to Premium+
   - Paywall if Freemium user tries to access
   - Can be re-run after upgrade

3. **Update App.tsx**
   - Track `hasCompletedFirstIntake` and `hasCompletedSecondIntake`
   - Default new users to Freemium tier
   - Route to Home after First Intake
   - Show "Unlock Customized Plan" CTA in Home

#### B. Update UserProfile Interface:
```typescript
export interface UserProfile {
  id: string;
  phone: string; // NEW - E.164 format
  name?: string; // Optional until Second Intake
  email?: string; // Optional, linkable
  
  // First Intake (IntakeV1)
  gender: 'male' | 'female' | 'other';
  mainGoal: MainGoal;
  workoutLocation: 'home' | 'gym';
  firstIntakeCompletedAt: Date;
  
  // Second Intake (IntakeV2) - Optional, Premium+ only
  age?: number;
  weight?: number;
  height?: number;
  experienceLevel?: 'beginner' | 'intermediate' | 'advanced';
  workoutFrequency?: number; // 2-6 days/week
  injuries?: InjuryArea[];
  secondIntakeCompletedAt?: Date;
  
  // System fields
  subscriptionTier: SubscriptionTier;
  planType: 'starter' | 'customized'; // NEW
  coachId?: string;
  createdAt: Date;
}
```

#### C. Update Workout Generation:
1. **Starter Plan Logic:**
   - Based only on gender, goal, location
   - Generic templates
   - Labeled "Starter Plan" in UI
   - Available immediately

2. **Customized Plan Logic:**
   - Based on full Second Intake data
   - Incorporates injury substitutions
   - Split variations (2-6 days/week)
   - Labeled "Customized Plan" in UI

#### Files to Create/Modify:
- Create: `/components/FirstIntakeScreen.tsx`
- Create: `/components/SecondIntakeScreen.tsx`
- Modify: `/App.tsx` - Update routing and state
- Modify: `/components/HomeScreen.tsx` - Show plan type
- Modify: `/components/WorkoutScreen.tsx` - Display plan type
- Modify: `/components/AccountScreen.tsx` - Add re-intake option

---

## 3. Subscription Tiers & Quotas (SUB-01, SUB-02, SUB-03)

### Current State
- **File:** `/components/SubscriptionManager.tsx`
- Three tiers defined (Freemium, Premium, Smart Premium)
- Static feature comparison
- No quota enforcement

### Required Changes
**Priority: HIGH** | **Effort: MEDIUM**

#### New Quota System:

| Feature | Freemium | Premium | Smart Premium |
|---------|----------|---------|---------------|
| **First Intake** | ✔ | ✔ | ✔ |
| **Starter Plan** | ✔ | ✖ (Customized) | ✖ (Customized) |
| **Second Intake** | ✖ | ✔ | ✔ |
| **Customized Plan** | ✖ | ✔ | ✔ |
| **Coach Messages/mo** | 20 | 200 | Unlimited |
| **Video Calls/mo** | 1×15min | 2×25min | 4×25min |
| **Chat Attachments** | ✖ | ✔ | ✔ |
| **Nutrition Generation** | ✔ | ✔ | ✔ |
| **Nutrition Access** | 7 days | Persistent | Persistent |
| **Store Access** | ✔ | ✔ | ✔ |

#### Implementation:

1. **Add Quota Tracking to UserProfile:**
```typescript
interface QuotaUsage {
  messagesRemaining: number;
  messagesTotal: number;
  callsRemaining: number;
  callsTotal: number;
  resetDate: Date; // Next monthly reset
}

// Add to UserProfile
quotaUsage?: QuotaUsage;
```

2. **Create Quota Enforcement Service:**
```typescript
// /components/QuotaService.tsx
export const checkQuota = (
  userProfile: UserProfile, 
  action: 'message' | 'call' | 'attachment'
): { allowed: boolean; reason?: string } => {
  // Check tier entitlements
  // Return quota status
};
```

3. **Update UI Components:**
   - Show remaining quota in coach screen
   - Display warning at 80% usage
   - Block action at 100% with upgrade prompt
   - Show "Unlimited" badge for Smart Premium

#### Files to Modify:
- Modify: `/components/SubscriptionManager.tsx` - Update feature matrix
- Create: `/components/QuotaService.tsx`
- Modify: `/components/CoachScreen.tsx` - Enforce quotas
- Modify: `/App.tsx` - Add quota tracking to state

---

## 4. Chat Attachments Gating (CHAT-03)

### Current State
- **File:** `/components/CoachScreen.tsx`
- No attachment functionality implemented yet

### Required Changes
**Priority: MEDIUM** | **Effort: LOW-MEDIUM**

#### Implementation:
1. Add attachment button to message composer
2. Check tier before showing upload UI
3. For Freemium: Show disabled button with tooltip
4. For Premium+: Allow image uploads (jpg/png/webp, ≤10MB)

```typescript
// In CoachScreen.tsx
const canSendAttachments = 
  userProfile.subscriptionTier !== 'Freemium';

// UI
<Button 
  disabled={!canSendAttachments}
  onClick={handleAttachment}
  title={!canSendAttachments ? 
    t('coach.attachmentRequiresPremium') : 
    t('coach.addAttachment')
  }
>
  <Paperclip />
</Button>
```

#### Files to Modify:
- Modify: `/components/CoachScreen.tsx`
- Add translations for attachment gating

---

## 5. Nutrition Time-Window (NUT-01, NUT-02, NUT-03)

### Current State
- **File:** `/components/NutritionScreen.tsx`
- Shows full nutrition plan for Premium+ users
- Locked entirely for Freemium users

### Required Changes
**Priority: HIGH** | **Effort: MEDIUM**

#### New Behavior:

**Freemium Users:**
1. Can generate nutrition plan
2. Full access for 7 days (configurable)
3. After 7 days: Content locked, shows upgrade prompt
4. Can regenerate (restarts 7-day window, replaces old plan)
5. Upgrading unlocks existing plan permanently

**Premium+ Users:**
1. Generate nutrition plan
2. Persistent access (no expiry)
3. Can regenerate anytime

#### Implementation:

1. **Add to UserProfile:**
```typescript
interface NutritionPlan {
  id: string;
  generatedAt: Date;
  expiresAt: Date | null; // null = persistent
  isLocked: boolean; // true if past expiry
  preferences: NutritionPreferences;
}

// Add to UserProfile
nutritionPlan?: NutritionPlan;
```

2. **Nutrition Screen Logic:**
```typescript
const isNutritionLocked = () => {
  if (!userProfile.nutritionPlan) return true;
  if (userProfile.subscriptionTier !== 'Freemium') return false;
  
  const now = new Date();
  const expiresAt = userProfile.nutritionPlan.expiresAt;
  
  return expiresAt && now > expiresAt;
};

// Show countdown for Freemium
const daysRemaining = () => {
  if (!userProfile.nutritionPlan?.expiresAt) return null;
  const days = Math.ceil(
    (userProfile.nutritionPlan.expiresAt.getTime() - Date.now()) 
    / (1000 * 60 * 60 * 24)
  );
  return days;
};
```

3. **UI Updates:**
   - Banner showing days remaining for Freemium
   - Lock overlay when expired
   - "Upgrade to Keep Access" CTA
   - "Regenerate Plan" button (restarts timer)

#### Files to Modify:
- Modify: `/components/NutritionScreen.tsx`
- Modify: `/App.tsx` - Add nutrition plan to state
- Add countdown UI component

---

## 6. Post-Interaction Ratings (RATE-01)

### Current State
- No rating system implemented

### Required Changes
**Priority: MEDIUM** | **Effort: MEDIUM**

#### Triggers:
1. **After video call ends** - Immediate prompt
2. **After chat inactivity ≥30 min** - Check if last message was from coach

#### Implementation:

1. **Create Rating Modal Component:**
```typescript
// /components/RatingModal.tsx
interface RatingModalProps {
  interactionType: 'chat' | 'call';
  coachName: string;
  onSubmit: (rating: Rating) => void;
  onSkip: () => void;
}

interface Rating {
  stars: 1 | 2 | 3 | 4 | 5;
  comment?: string;
  timestamp: Date;
}
```

2. **Add Rating Tracking:**
```typescript
// In CoachScreen.tsx
const [showRatingModal, setShowRatingModal] = useState(false);
const [ratingContext, setRatingContext] = useState<'chat' | 'call' | null>(null);

// After call ends
const handleCallEnd = () => {
  setRatingContext('call');
  setShowRatingModal(true);
};

// Track chat inactivity
useEffect(() => {
  const lastMessage = messages[messages.length - 1];
  if (lastMessage?.isFromCoach) {
    const timer = setTimeout(() => {
      setRatingContext('chat');
      setShowRatingModal(true);
    }, 30 * 60 * 1000); // 30 minutes
    
    return () => clearTimeout(timer);
  }
}, [messages]);
```

3. **Storage & Display:**
   - Store ratings in user history
   - Show aggregate ratings in coach profile
   - Admin can view detailed ratings

#### Files to Create/Modify:
- Create: `/components/RatingModal.tsx`
- Modify: `/components/CoachScreen.tsx`
- Modify: `/components/CoachDashboard.tsx` - Show ratings
- Modify: `/components/AdminDashboard.tsx` - Rating moderation

---

## 7. Injury Substitution System (INJ-01, INJ-02, WO-03)

### Current State
- **File:** `/components/EnhancedExerciseDatabase.tsx`
- Exercise database exists
- No injury substitution logic

### Required Changes
**Priority: MEDIUM** | **Effort: HIGH**

#### Implementation:

1. **Create Injury Rules Database:**
```typescript
// /components/InjurySubstitutionEngine.tsx
interface InjuryRule {
  injuryCode: InjuryArea;
  avoidKeywords: string[];
  substitutes: ExerciseSubstitute[];
}

interface ExerciseSubstitute {
  originalCategory: string;
  replacementExercises: string[];
  targetMuscles: string[];
  movementPattern: string;
}

const INJURY_RULES: InjuryRule[] = [
  {
    injuryCode: 'knee',
    avoidKeywords: ['squat', 'lunge', 'jump', 'leg press'],
    substitutes: [
      {
        originalCategory: 'quad_compound',
        replacementExercises: [
          'Leg Extension',
          'Bulgarian Split Squat (shallow)',
          'Step-ups (low box)'
        ],
        targetMuscles: ['quadriceps'],
        movementPattern: 'knee_extension'
      }
    ]
  },
  {
    injuryCode: 'shoulder',
    avoidKeywords: ['overhead press', 'pullup', 'dip', 'behind neck'],
    substitutes: [
      {
        originalCategory: 'shoulder_press',
        replacementExercises: [
          'Landmine Press',
          'Neutral Grip Dumbbell Press',
          'Machine Shoulder Press'
        ],
        targetMuscles: ['anterior_deltoid', 'lateral_deltoid'],
        movementPattern: 'shoulder_flexion'
      }
    ]
  },
  {
    injuryCode: 'lower_back',
    avoidKeywords: ['deadlift', 'bent over row', 'good morning', 'hyperextension'],
    substitutes: [
      {
        originalCategory: 'hip_hinge',
        replacementExercises: [
          'Trap Bar Deadlift',
          'Romanian Deadlift (light)',
          'Hip Thrust',
          'Cable Pull-through'
        ],
        targetMuscles: ['glutes', 'hamstrings'],
        movementPattern: 'hip_extension'
      }
    ]
  },
  {
    injuryCode: 'neck',
    avoidKeywords: ['barbell squat', 'behind neck press', 'heavy overhead'],
    substitutes: [
      {
        originalCategory: 'squat_pattern',
        replacementExercises: [
          'Goblet Squat',
          'Front Squat (light)',
          'Safety Bar Squat',
          'Leg Press'
        ],
        targetMuscles: ['quadriceps', 'glutes'],
        movementPattern: 'squat'
      }
    ]
  },
  {
    injuryCode: 'ankle',
    avoidKeywords: ['calf raise', 'jump', 'sprint', 'lunge'],
    substitutes: [
      {
        originalCategory: 'lower_leg',
        replacementExercises: [
          'Seated Calf Raise (if tolerated)',
          'Resistance Band Ankle Work',
          'Swimming'
        ],
        targetMuscles: ['gastrocnemius', 'soleus'],
        movementPattern: 'ankle_plantarflexion'
      }
    ]
  }
];
```

2. **Substitution Algorithm:**
```typescript
const applyInjurySubstitutions = (
  workoutPlan: WorkoutPlan,
  injuries: InjuryArea[]
): WorkoutPlan => {
  const modifiedPlan = { ...workoutPlan };
  
  injuries.forEach(injury => {
    const rule = INJURY_RULES.find(r => r.injuryCode === injury);
    if (!rule) return;
    
    // Scan all exercises in plan
    modifiedPlan.weeks.forEach(week => {
      week.days.forEach(day => {
        day.exercises = day.exercises.map(exercise => {
          // Check if exercise contains avoid keywords
          const shouldSubstitute = rule.avoidKeywords.some(
            keyword => exercise.name.toLowerCase().includes(keyword.toLowerCase())
          );
          
          if (shouldSubstitute) {
            // Find appropriate substitute
            const substitute = findSubstitute(exercise, rule);
            return {
              ...substitute,
              originalExercise: exercise.name,
              substitutionReason: `Modified due to ${injury} injury`
            };
          }
          
          return exercise;
        });
      });
    });
  });
  
  return modifiedPlan;
};
```

3. **Volume Safety Check:**
```typescript
const validateVolume = (
  originalPlan: WorkoutPlan,
  modifiedPlan: WorkoutPlan
): ValidationResult => {
  const muscleGroups = ['chest', 'back', 'legs', 'shoulders', 'arms'];
  const warnings: string[] = [];
  
  muscleGroups.forEach(group => {
    const originalVolume = calculateVolume(originalPlan, group);
    const modifiedVolume = calculateVolume(modifiedPlan, group);
    const difference = Math.abs(
      (modifiedVolume - originalVolume) / originalVolume * 100
    );
    
    if (difference > 15) {
      warnings.push(
        `${group} volume changed by ${difference.toFixed(0)}% - Coach review recommended`
      );
    }
  });
  
  return { valid: warnings.length === 0, warnings };
};
```

4. **UI Indication:**
   - Show injury badge on substituted exercises
   - Tooltip explaining why exercise was modified
   - Link to view original exercise
   - Option to request coach review

#### Files to Create/Modify:
- Create: `/components/InjurySubstitutionEngine.tsx`
- Modify: `/components/WorkoutScreen.tsx` - Show substitution badges
- Modify: `/components/EnhancedExerciseDatabase.tsx` - Tag exercises with injury risk

---

## 8. Updated Home Screen (UX-02, UX-03)

### Current State
- **File:** `/components/HomeScreen.tsx`
- Shows generic home for all users

### Required Changes
**Priority: MEDIUM** | **Effort: LOW**

#### Updates Needed:

1. **Show Plan Type:**
```typescript
// Add to HomeScreen
const planTypeInfo = {
  starter: {
    label: t('home.starterPlan'),
    description: t('home.starterPlanDesc'),
    icon: Star,
    color: 'bg-blue-100 text-blue-800'
  },
  customized: {
    label: t('home.customizedPlan'),
    description: t('home.customizedPlanDesc'),
    icon: Sparkles,
    color: 'bg-purple-100 text-purple-800'
  }
};

const currentPlanType = userProfile.planType || 'starter';
```

2. **Upgrade CTA for Freemium:**
   - Already exists, enhance messaging
   - Add "Unlock Customized Plan" specific CTA
   - Show benefits: injury-aware, adaptive, etc.

3. **Direct to Home After First Intake:**
   - Remove intermediate screens
   - Show starter plan immediately
   - Target: ≤60 seconds from signup to seeing workout

#### Files to Modify:
- Modify: `/components/HomeScreen.tsx`
- Add translations for plan types

---

## 9. Translation Updates

### Current State
- Comprehensive English and Arabic translations exist
- All UI elements localized

### Required Changes
**Priority: LOW** | **Effort: LOW**

#### New Translation Keys Needed:

```typescript
// Phone Auth
'auth.phoneNumber': 'Phone Number',
'auth.phoneNumberAr': 'رقم الهاتف',
'auth.enterOTP': 'Enter OTP Code',
'auth.resendOTP': 'Resend Code',
'auth.otpSent': 'Code sent to',
'auth.attemptsRemaining': 'attempts remaining',

// Intake
'intake.first.title': 'Quick Start',
'intake.first.subtitle': "Let's get you started in under a minute",
'intake.second.title': 'Complete Your Profile',
'intake.second.subtitle': 'Unlock your customized plan',
'intake.second.locked': 'Available for Premium members',

// Plan Types
'plan.starter': 'Starter Plan',
'plan.customized': 'Customized Plan',
'plan.starterDesc': 'Generic plan based on your goals',
'plan.customizedDesc': 'Personalized plan with injury accommodations',

// Quotas
'quota.messages': 'Messages',
'quota.calls': 'Video Calls',
'quota.remaining': 'remaining this month',
'quota.unlimited': 'Unlimited',
'quota.exceeded': 'Quota exceeded',
'quota.upgradePrompt': 'Upgrade to continue',

// Nutrition Window
'nutrition.expiresIn': 'Expires in',
'nutrition.days': 'days',
'nutrition.expired': 'Access Expired',
'nutrition.upgradeToKeep': 'Upgrade to keep permanent access',
'nutrition.regenerate': 'Regenerate Plan',
'nutrition.regenerateWarning': 'This will restart your 7-day access period',

// Ratings
'rating.title': 'Rate Your Experience',
'rating.howWas': 'How was your',
'rating.chatSession': 'chat session',
'rating.videoCall': 'video call',
'rating.optional': 'Add a comment (optional)',
'rating.submit': 'Submit Rating',
'rating.skip': 'Skip',
'rating.thankYou': 'Thank you for your feedback!',

// Injuries
'injury.substituted': 'Modified for safety',
'injury.original': 'Original exercise',
'injury.reason': 'Modified due to',
```

#### Files to Modify:
- Modify: `/components/LanguageContext.tsx`

---

## 10. Demo Mode Updates

### Current State
- **File:** `/App.tsx`, `/components/DemoModeIndicator.tsx`
- Demo mode works with email-based auth
- Demo users have various tiers

### Required Changes
**Priority: LOW** | **Effort: LOW**

#### Updates:
1. Support phone-based demo auth
2. Add demo OTP: `123456` (always works)
3. Demo users with various quota states
4. Demo nutrition plans with different expiry states

```typescript
// Demo users
const demoUsers = {
  freemium: {
    phone: '+966501234567',
    name: 'Mina H.',
    tier: 'Freemium',
    quotaUsage: {
      messagesRemaining: 5,
      messagesTotal: 20,
      callsRemaining: 1,
      callsTotal: 1
    },
    nutritionPlan: {
      generatedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      expiresAt: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 days left
      isLocked: false
    }
  },
  premium: {
    phone: '+966507654321',
    name: 'Sara A.',
    tier: 'Premium',
    quotaUsage: {
      messagesRemaining: 150,
      messagesTotal: 200,
      callsRemaining: 2,
      callsTotal: 2
    }
  }
};
```

#### Files to Modify:
- Modify: `/App.tsx`
- Modify: `/components/AuthScreen.tsx`

---

## Implementation Priority Matrix

### Phase 1: Core Changes (Week 1-2)
**CRITICAL - Must Have for v2.0 Launch**
1. ✅ Phone OTP Authentication
2. ✅ Two-Stage Intake (First + Second)
3. ✅ Subscription Tiers with Quotas
4. ✅ Nutrition Time-Window for Freemium

### Phase 2: Enhanced Features (Week 3)
**HIGH - Important for Complete v2.0**
5. ✅ Chat Attachment Gating
6. ✅ Quota Enforcement UI
7. ✅ Updated Home Screen (Plan Types)
8. ✅ Translation Updates

### Phase 3: Advanced Features (Week 4)
**MEDIUM - Polish & Completeness**
9. ✅ Post-Interaction Rating System
10. ✅ Injury Substitution Engine
11. ✅ Demo Mode Updates
12. ✅ Admin Configuration UI

### Phase 4: Testing & Polish (Week 5)
**ALL PHASES**
13. ✅ End-to-end testing
14. ✅ Performance optimization
15. ✅ Bug fixes
16. ✅ Documentation

---

## Technical Debt & Considerations

### Performance
- Quota checks on every message/call → Consider caching
- Injury substitution computation → Pre-compute on plan generation
- OTP resend cooldown → Client-side tracking + server validation

### Security
- Phone numbers are PII → Encryption at rest
- OTP codes → Secure transmission, short TTL
- Session tokens → Rotation policy
- Admin actions → Full audit log

### Scalability
- Message quotas → Monthly reset job needed
- Nutrition expiry → Background job to lock plans
- Rating aggregation → Denormalize for performance

### User Experience
- First Intake → Must complete in <60 seconds
- OTP delivery → Fallback to WhatsApp if SMS fails
- Quota warnings → Show at 80% before hard block
- Upgrade flow → Seamless, no app restart required

---

## Testing Strategy

### Unit Tests
- Phone number validation (E.164)
- OTP generation/verification
- Quota calculations
- Injury substitution algorithm
- Nutrition expiry logic

### Integration Tests
- First Intake → Home → Workout flow
- Upgrade → Second Intake → Customized Plan flow
- Message sending with quota enforcement
- Nutrition generation → Expiry → Upgrade unlock

### User Acceptance Tests
- New user signup (First Intake only)
- Freemium user hits message quota
- Freemium nutrition expires after 7 days
- Premium user completes Second Intake
- Rating submission after call/chat

### Demo Mode Tests
- Phone OTP demo flow
- All tier scenarios
- Quota states (full, partial, exceeded)
- Nutrition expiry states

---

## Migration Strategy

### For Existing Users (if any)
1. **Email → Phone Migration:**
   - Prompt to add phone number
   - Keep email as linked account
   - Grandfather existing features

2. **Onboarding → Intake Mapping:**
   - Map old 8-step → First + Second Intake
   - Preserve all existing data
   - Auto-mark both intakes complete

3. **Plan Type Assignment:**
   - Freemium users → Starter Plan
   - Premium+ users → Customized Plan
   - Re-intake option available

---

## API Endpoints Needed

### Authentication
```
POST   /auth/phone/request_otp
POST   /auth/phone/verify
POST   /auth/link
POST   /auth/refresh
DELETE /auth/logout
GET    /auth/devices
DELETE /auth/devices/:id
```

### Intake
```
POST   /intake/v1          # First Intake
GET    /intake/v1
POST   /intake/v2          # Second Intake (requires Premium+)
GET    /intake/v2
```

### Plans
```
POST   /plans/generate     # { type: 'starter' | 'custom' }
GET    /plans/current
PATCH  /plans/current      # For injury resubstitution
GET    /plans/history
```

### Quotas
```
GET    /quotas
POST   /quotas/check       # { action: 'message' | 'call' | 'attachment' }
```

### Ratings
```
POST   /ratings            # Submit rating
GET    /ratings/coach/:id  # Aggregate (user/coach)
GET    /ratings/mine       # User's ratings
```

### Admin
```
POST   /admin/tiers/config
POST   /admin/flags
GET    /admin/ratings
PATCH  /admin/ratings/:id  # Moderate
GET    /admin/analytics
```

---

## File Change Summary

### Files to Create (16 new files)
1. `/components/FirstIntakeScreen.tsx`
2. `/components/SecondIntakeScreen.tsx`
3. `/components/OTPInput.tsx`
4. `/components/PhoneNumberInput.tsx`
5. `/components/RatingModal.tsx`
6. `/components/InjurySubstitutionEngine.tsx`
7. `/components/QuotaService.tsx`
8. `/components/QuotaDisplay.tsx`
9. `/components/NutritionExpiryBanner.tsx`
10. `/components/AttachmentGate.tsx`
11. `/utils/phoneValidation.ts`
12. `/utils/quotaCalculations.ts`
13. `/utils/nutritionExpiry.ts`
14. `/utils/injuryRules.ts`
15. `/types/IntakeTypes.ts`
16. `/types/QuotaTypes.ts`

### Files to Modify (12 existing files)
1. `/App.tsx` - Complete state management overhaul
2. `/components/AuthScreen.tsx` - Phone OTP rewrite
3. `/components/HomeScreen.tsx` - Plan type display
4. `/components/WorkoutScreen.tsx` - Injury badges
5. `/components/NutritionScreen.tsx` - Time-window logic
6. `/components/CoachScreen.tsx` - Quotas + attachments + ratings
7. `/components/SubscriptionManager.tsx` - Updated quota matrix
8. `/components/AccountScreen.tsx` - Re-intake options
9. `/components/CoachDashboard.tsx` - Rating display
10. `/components/AdminDashboard.tsx` - Rating moderation + config
11. `/components/LanguageContext.tsx` - New translations
12. `/components/DemoModeIndicator.tsx` - Phone-based demos

### Files to Delete (1 file)
1. `/components/OnboardingScreen.tsx` - Replaced by First + Second Intake

---

## Success Metrics

### Technical Metrics
- [ ] First Intake completion time <60 seconds (p95)
- [ ] Phone OTP delivery <30 seconds (p95)
- [ ] Plan generation <5 seconds (p95)
- [ ] Zero quota enforcement bypasses
- [ ] Nutrition expiry enforcement 100% accurate

### User Experience Metrics
- [ ] New user activation rate ≥80%
- [ ] Freemium → Premium conversion ≥15%
- [ ] Second Intake completion rate ≥60% (for Premium)
- [ ] Rating submission rate ≥40%
- [ ] Demo mode adoption ≥30% of first-time visitors

### Business Metrics
- [ ] Freemium users hit message quota ≥50%
- [ ] Nutrition expiry drives upgrade ≥20%
- [ ] Average rating score ≥4.2/5.0
- [ ] Coach satisfaction with ratings ≥85%

---

## Open Questions for Product Team

1. **OTP Delivery:**
   - Which SMS provider? (Twilio, AWS SNS, local provider)
   - WhatsApp fallback for all regions or specific?
   - Cost per OTP → Factor into freemium economics

2. **Nutrition Window:**
   - 7 days = hard requirement or configurable by admin?
   - Can Freemium users have multiple plans (oldest expires first)?
   - What happens to expired plans on upgrade? (Unlock most recent? All?)

3. **Quotas:**
   - Monthly reset on calendar month or 30-day rolling?
   - Unused quotas roll over? (Suggest: No)
   - Quota upgrades mid-month: prorate or apply next cycle?

4. **Ratings:**
   - Show individual ratings to coach or aggregate only?
   - Minimum N before displaying (suggest: 5 ratings)
   - Coach can respond to ratings? (Suggest: No, to preserve anonymity)

5. **Injury Substitutions:**
   - Coach review required for all substitutions?
   - User can reject substitution and request original?
   - Update plan mid-cycle if injury resolves?

6. **Demo Mode:**
   - Demo OTP code = `123456` (static) or random but displayed?
   - Demo quotas reset daily/weekly/never?
   - Demo data: synthetic or anonymized production data?

---

## Next Steps

1. **Product Sign-off:** Review this document with stakeholders
2. **Design Review:** Update UI mockups for new flows
3. **Backend Alignment:** Share API requirements with backend team
4. **Sprint Planning:** Break down into 2-week sprints
5. **Kickoff:** Begin Phase 1 implementation

---

**Document Owner:** Development Team  
**Last Updated:** October 15, 2025  
**Next Review:** Upon Phase 1 completion  
**Status:** ✅ Ready for Implementation
