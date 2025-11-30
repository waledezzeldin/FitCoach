# FitCoach+ v2.0 Quick Implementation Guide

## Files Created ✅

### Type Definitions & Utilities
- ✅ `/types/IntakeTypes.ts` - First and Second Intake types
- ✅ `/types/QuotaTypes.ts` - Quota system types and logic
- ✅ `/utils/phoneValidation.ts` - Phone number E.164 validation
- ✅ `/utils/nutritionExpiry.ts` - Nutrition time-window logic
- ✅ `/utils/injuryRules.ts` - Injury substitution engine

### New Components
- ✅ `/components/OTPInput.tsx` - 6-digit OTP input component
- ✅ `/components/PhoneNumberInput.tsx` - Phone number with country code
- ✅ `/components/FirstIntakeScreen.tsx` - 3-question quick start
- ✅ `/components/SecondIntakeScreen.tsx` - Full questionnaire (Premium+)
- ✅ `/components/RatingModal.tsx` - Post-interaction rating
- ✅ `/components/QuotaDisplay.tsx` - Quota usage display
- ✅ `/components/NutritionExpiryBanner.tsx` - Expiry countdown/warning

### Translations
- ✅ `/translations/v2-additions.ts` - All new translation keys

---

## Critical Files To Update

### 1. `/components/LanguageContext.tsx` [HIGH PRIORITY]
**Action:** Merge v2 translations from `/translations/v2-additions.ts`

```typescript
// Add these imports at the top
import { v2Translations } from '../translations/v2-additions';

// Then merge into existing translations:
const translations = {
  en: {
    // ... existing translations
    ...v2Translations.en
  },
  ar: {
    // ... existing translations
    ...v2Translations.ar
  }
};
```

---

### 2. `/components/AuthScreen.tsx` [CRITICAL]
**Current:** Email/password authentication  
**Needed:** Phone OTP authentication

**Key Changes:**
1. Replace email input with `<PhoneNumberInput />`
2. Add OTP flow after phone submission
3. Use `<OTPInput />` component
4. Demo OTP: `123456` always works
5. Remove password fields
6. Keep demo mode activation (long-press logo)

**State needed:**
```typescript
const [authStage, setAuthStage] = useState<'phone' | 'otp'>('phone');
const [phoneNumber, setPhoneNumber] = useState('');
const [otpAttempts, setOtpAttempts] = useState(5);
```

---

### 3. `/App.tsx` [CRITICAL]
**Current:** Single onboarding flow  
**Needed:** Two-stage intake system + quota tracking

**Key Changes:**

#### Update UserProfile Interface:
```typescript
export interface UserProfile {
  id: string;
  phone: string; // NEW - E.164 format
  name?: string; // Make optional
  email?: string; // Optional, linkable
  
  // First Intake (always present)
  gender: Gender;
  mainGoal: MainGoal;
  workoutLocation: WorkoutLocation;
  firstIntakeCompletedAt: Date;
  
  // Second Intake (Premium+ only)
  age?: number;
  weight?: number;
  height?: number;
  experienceLevel?: ExperienceLevel;
  workoutFrequency?: number;
  injuries?: InjuryArea[];
  secondIntakeCompletedAt?: Date;
  
  // System
  subscriptionTier: SubscriptionTier;
  planType: 'starter' | 'customized';
  quotaUsage?: QuotaUsage;
  nutritionPlan?: NutritionPlan;
  coachId?: string;
}
```

#### Update AppState:
```typescript
export interface AppState {
  isAuthenticated: boolean;
  isDemoMode: boolean;
  userType: UserType;
  userProfile: UserProfile | null;
  currentScreen: Screen;
  hasCompletedFirstIntake: boolean;
  hasCompletedSecondIntake: boolean; // NEW
  hasSeenIntro: boolean;
}
```

#### Update Routing Logic:
```typescript
// After phone auth → First Intake (if not completed)
// After First Intake → Home with Starter Plan
// Premium users can access Second Intake → Customized Plan
```

---

### 4. Delete `/components/OnboardingScreen.tsx`
**Action:** This is replaced by FirstIntakeScreen + SecondIntakeScreen

---

### 5. `/components/HomeScreen.tsx` [HIGH PRIORITY]
**Additions:**
1. Import and use `QuotaDisplay` component (compact mode)
2. Show plan type badge (Starter vs Customized)
3. Add "Complete Your Profile" CTA for Freemium users who haven't done Second Intake
4. Display quota warnings when low

```typescript
// Add to HomeScreen
import { QuotaDisplay } from './QuotaDisplay';

// In render:
{userProfile.quotaUsage && (
  <QuotaDisplay 
    quota={userProfile.quotaUsage} 
    compact={true}
  />
)}
```

---

### 6. `/components/NutritionScreen.tsx` [HIGH PRIORITY]
**Additions:**
1. Import `NutritionExpiryBanner`
2. Import `checkNutritionExpiry` from utils
3. Show expiry banner for Freemium users
4. Lock content when expired
5. Add "Regenerate Plan" button (restarts 7-day window)

```typescript
import { NutritionExpiryBanner } from './NutritionExpiryBanner';
import { checkNutritionExpiry } from '../utils/nutritionExpiry';

// In component:
const expiryStatus = checkNutritionExpiry(
  userProfile.nutritionPlan,
  userProfile.subscriptionTier
);

// In render:
<NutritionExpiryBanner
  status={expiryStatus}
  tier={userProfile.subscriptionTier}
  onUpgrade={() => navigate('subscription')}
  onRegenerate={handleRegenerate}
/>

{expiryStatus.canAccess ? (
  // Show nutrition content
) : (
  // Show locked state
)}
```

---

### 7. `/components/CoachScreen.tsx` [MEDIUM PRIORITY]
**Additions:**
1. Import `QuotaDisplay` and `RatingModal`
2. Check quota before sending message
3. Gate attachments based on tier
4. Show rating prompt after call or 30min inactivity
5. Track quota usage

```typescript
import { QuotaDisplay } from './QuotaDisplay';
import { RatingModal } from './RatingModal';
import { checkQuota } from '../types/QuotaTypes';

// Before sending message:
const quotaCheck = checkQuota(
  userProfile.subscriptionTier,
  userProfile.quotaUsage!,
  'message'
);

if (!quotaCheck.allowed) {
  // Show upgrade prompt
  return;
}

// Attachment button:
const canAttach = checkQuota(..., 'attachment').allowed;

<Button disabled={!canAttach} ...>
  <Paperclip />
  {!canAttach && <Lock />}
</Button>
```

---

### 8. `/components/WorkoutScreen.tsx` [MEDIUM PRIORITY]
**Additions:**
1. Show plan type badge (Starter vs Customized)
2. Display injury modification badges on substituted exercises
3. Show tooltip explaining substitution

```typescript
// For each exercise:
{exercise.wasSubstituted && (
  <Badge variant="outline" className="bg-orange-50">
    <AlertTriangle className="w-3 h-3" />
    {t('plan.injuryModified')}
  </Badge>
)}

<Tooltip>
  <TooltipTrigger>ℹ️</TooltipTrigger>
  <TooltipContent>
    Original: {exercise.originalExercise}
    <br />
    Reason: {exercise.reason}
  </TooltipContent>
</Tooltip>
```

---

### 9. `/components/AccountScreen.tsx` [LOW PRIORITY]
**Additions:**
1. Add "Re-take Second Intake" button for Premium+ users
2. Show phone number (masked)
3. Option to link email/OAuth

---

### 10. `/components/SubscriptionManager.tsx` [MEDIUM PRIORITY]
**Updates:**
1. Update quota matrix to match v2.0 spec
2. Update feature comparison table

Current quota needs updating to:
- Freemium: 20 messages, 1 call (15min), NO attachments, 7-day nutrition
- Premium: 200 messages, 2 calls (25min), attachments, persistent nutrition
- Smart Premium: Unlimited messages, 4 calls (25min), attachments, persistent nutrition

---

## Implementation Checklist

### Phase 1: Core Authentication & Intake (Day 1-2)
- [ ] Update LanguageContext with v2 translations
- [ ] Rewrite AuthScreen for phone OTP
- [ ] Update App.tsx interfaces and routing
- [ ] Delete OnboardingScreen.tsx
- [ ] Test: New user → Phone OTP → First Intake → Home (< 60 sec)

### Phase 2: Quota System (Day 3)
- [ ] Update HomeScreen with QuotaDisplay
- [ ] Update CoachScreen with quota enforcement
- [ ] Update SubscriptionManager with new quotas
- [ ] Test: Message quota, call quota, upgrade flow

### Phase 3: Nutrition Time-Window (Day 4)
- [ ] Update NutritionScreen with expiry logic
- [ ] Add regenerate plan functionality
- [ ] Test: Freemium 7-day expiry, upgrade unlock

### Phase 4: Secondary Features (Day 5)
- [ ] Add rating prompts to CoachScreen
- [ ] Add injury substitution display to WorkoutScreen
- [ ] Update AccountScreen with re-intake option
- [ ] Test: Rating submission, injury badges

### Phase 5: Testing & Polish (Day 6-7)
- [ ] End-to-end testing all user flows
- [ ] Demo mode updates (phone-based demos)
- [ ] Performance optimization
- [ ] Bug fixes

---

## Demo Mode Updates

### Demo Users:
```typescript
const demoUsers = {
  freemium: {
    phone: '+966501234567',
    otp: '123456', // Always works in demo
    name: 'Mina H.',
    tier: 'Freemium',
    quotaUsage: {
      messagesUsed: 15,
      messagesTotal: 20,
      callsUsed: 0,
      callsTotal: 1,
      resetDate: new Date(/* next month */)
    },
    nutritionPlan: {
      generatedAt: new Date(/* 5 days ago */),
      expiresAt: new Date(/* 2 days from now */),
      isLocked: false
    },
    hasCompletedSecondIntake: false
  },
  premium: {
    phone: '+966507654321',
    otp: '123456',
    name: 'Sara A.',
    tier: 'Premium',
    quotaUsage: {
      messagesUsed: 50,
      messagesTotal: 200,
      callsUsed: 1,
      callsTotal: 2,
      resetDate: new Date(/* next month */)
    },
    hasCompletedSecondIntake: true
  }
};
```

---

## Testing Scenarios

### Scenario 1: New Freemium User
1. Open app → Language selection
2. Phone OTP auth (+966501234567, OTP: 123456)
3. First Intake (3 questions, < 60 sec)
4. Home screen with Starter Plan
5. Try to access Nutrition → Generate plan → 7-day access
6. Try to send 21st message → Quota exceeded → Upgrade prompt

### Scenario 2: Premium Upgrade
1. Freemium user in Home
2. Click "Upgrade to Premium"
3. Complete payment flow
4. Immediately see Second Intake prompt
5. Complete Second Intake → Customized Plan generated
6. Nutrition plan unlocked permanently
7. Message quota increased to 200

### Scenario 3: Injury Substitution
1. Premium user completes Second Intake
2. Select "Knee Pain" injury
3. Generate Customized Plan
4. View workout → See "Leg Extension" instead of "Barbell Squat"
5. Badge shows "Modified for safety"
6. Tooltip explains substitution reason

---

## Next Steps

1. **Merge v2 translations** into LanguageContext
2. **Rewrite AuthScreen** for phone OTP
3. **Update App.tsx** with new state management
4. **Test core flow** (auth → intake → home)
5. **Add quota enforcement** to CoachScreen
6. **Add nutrition expiry** to NutritionScreen
7. **Polish and test**

---

## Notes

- All new components are standalone and don't require modifying existing components
- Quota logic is centralized in `/types/QuotaTypes.ts`
- Nutrition expiry logic is centralized in `/utils/nutritionExpiry.ts`
- Injury substitution is centralized in `/utils/injuryRules.ts`
- Demo mode uses OTP `123456` for all demo phone numbers
- Phone numbers are always E.164 format in database
- First Intake is mandatory for ALL users
- Second Intake is optional but gates Customized Plan (Premium+ only)

