# Utilities & Business Logic Reference

## Document Information
- **Purpose**: Complete reference for utility functions and business logic
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Total Utilities**: 15+ modules

---

## Table of Contents

1. [Injury Substitution Engine](#injury-substitution-engine)
2. [Quota Management](#quota-management)
3. [Nutrition Expiry](#nutrition-expiry)
4. [Phone Validation](#phone-validation)
5. [Fitness Score Calculation](#fitness-score-calculation)
6. [Translation System](#translation-system)
7. [Date & Time Utilities](#date--time-utilities)
8. [Storage Utilities](#storage-utilities)
9. [Validation Utilities](#validation-utilities)
10. [API Helpers](#api-helpers)

---

## Injury Substitution Engine

**File**: `/utils/injuryRules.ts`

**Purpose**: Detect exercises contraindicated for user injuries and suggest safe alternatives.

### Type Definitions

```typescript
type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';

interface Exercise {
  id: string;
  name: string;
  nameAr: string;
  muscleGroups: string[];
  equipment: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  contraindications: InjuryArea[];
  alternatives?: string[]; // Exercise IDs
}

interface SubstitutionResult {
  original: Exercise;
  reason: string;
  alternatives: Exercise[];
  injuryArea: InjuryArea;
}
```

### Core Functions

#### isExerciseSafe()

```typescript
/**
 * Check if an exercise is safe for user with given injuries
 * @param exercise - Exercise to check
 * @param userInjuries - Array of user's injury areas
 * @returns boolean - true if safe, false if contraindicated
 */
export function isExerciseSafe(
  exercise: Exercise, 
  userInjuries: InjuryArea[]
): boolean {
  if (!exercise.contraindications || exercise.contraindications.length === 0) {
    return true;
  }
  
  return !exercise.contraindications.some(injury => 
    userInjuries.includes(injury)
  );
}
```

**Example**:
```typescript
const pushup: Exercise = {
  id: 'pushup',
  name: 'Push-ups',
  contraindications: ['shoulder']
};

const userInjuries: InjuryArea[] = ['knee', 'shoulder'];

const safe = isExerciseSafe(pushup, userInjuries);
console.log(safe); // false - contraindicated for shoulder
```

---

#### getSafeAlternatives()

```typescript
/**
 * Get safe exercise alternatives for contraindicated exercise
 * @param exercise - Original exercise
 * @param userInjuries - User's injury areas
 * @param exerciseLibrary - Full exercise library
 * @returns Array of alternative exercises
 */
export function getSafeAlternatives(
  exercise: Exercise,
  userInjuries: InjuryArea[],
  exerciseLibrary: Exercise[]
): Exercise[] {
  // 1. Check if exercise has predefined alternatives
  if (exercise.alternatives && exercise.alternatives.length > 0) {
    const alternatives = exerciseLibrary.filter(ex => 
      exercise.alternatives!.includes(ex.id) &&
      isExerciseSafe(ex, userInjuries)
    );
    
    if (alternatives.length > 0) return alternatives;
  }
  
  // 2. Find exercises targeting same muscle groups
  const sameMuscleExercises = exerciseLibrary.filter(ex => 
    ex.id !== exercise.id &&
    ex.muscleGroups.some(mg => exercise.muscleGroups.includes(mg)) &&
    isExerciseSafe(ex, userInjuries)
  );
  
  // 3. Sort by difficulty similarity
  const sorted = sameMuscleExercises.sort((a, b) => {
    const diffA = Math.abs(difficultyScore(a.difficulty) - difficultyScore(exercise.difficulty));
    const diffB = Math.abs(difficultyScore(b.difficulty) - difficultyScore(exercise.difficulty));
    return diffA - diffB;
  });
  
  return sorted.slice(0, 3); // Return top 3
}

function difficultyScore(difficulty: string): number {
  const scores = { beginner: 1, intermediate: 2, advanced: 3 };
  return scores[difficulty] || 2;
}
```

**Example**:
```typescript
const benchPress: Exercise = {
  id: 'bench_press',
  name: 'Bench Press',
  muscleGroups: ['chest', 'triceps'],
  contraindications: ['shoulder'],
  alternatives: ['dumbbell_press', 'machine_chest_press']
};

const userInjuries: InjuryArea[] = ['shoulder'];
const library: Exercise[] = [...]; // Full exercise library

const alternatives = getSafeAlternatives(benchPress, userInjuries, library);
console.log(alternatives);
// [
//   { id: 'dumbbell_press', name: 'Dumbbell Press', ... },
//   { id: 'machine_chest_press', name: 'Machine Chest Press', ... }
// ]
```

---

#### getContraindicatedExercises()

```typescript
/**
 * Get all contraindicated exercises from workout plan
 * @param workoutPlan - User's workout plan
 * @param userInjuries - User's injury areas
 * @returns Array of contraindicated exercises with substitution info
 */
export function getContraindicatedExercises(
  workoutPlan: WorkoutPlan,
  userInjuries: InjuryArea[],
  exerciseLibrary: Exercise[]
): SubstitutionResult[] {
  const contraindicated: SubstitutionResult[] = [];
  
  workoutPlan.days.forEach(day => {
    day.exercises.forEach(exercise => {
      if (!isExerciseSafe(exercise, userInjuries)) {
        const affectedInjury = exercise.contraindications.find(injury =>
          userInjuries.includes(injury)
        );
        
        contraindicated.push({
          original: exercise,
          reason: `Contraindicated for ${affectedInjury} injury`,
          alternatives: getSafeAlternatives(exercise, userInjuries, exerciseLibrary),
          injuryArea: affectedInjury!
        });
      }
    });
  });
  
  return contraindicated;
}
```

**Example**:
```typescript
const workout: WorkoutPlan = {
  name: 'Full Body Week 1',
  days: [
    {
      name: 'Monday',
      exercises: [
        { id: 'squats', name: 'Squats', contraindications: ['knee'] },
        { id: 'overhead_press', name: 'Overhead Press', contraindications: ['shoulder'] }
      ]
    }
  ]
};

const userInjuries: InjuryArea[] = ['knee'];
const issues = getContraindicatedExercises(workout, userInjuries, exerciseLibrary);

console.log(issues);
// [
//   {
//     original: { id: 'squats', ... },
//     reason: 'Contraindicated for knee injury',
//     alternatives: [{ id: 'leg_press', ... }, { id: 'lunges', ... }],
//     injuryArea: 'knee'
//   }
// ]
```

---

### Injury-Specific Rules

```typescript
/**
 * Predefined injury contraindication rules
 */
export const INJURY_RULES: Record<InjuryArea, string[]> = {
  shoulder: [
    'overhead_press',
    'military_press',
    'handstand_pushup',
    'lateral_raise',
    'front_raise',
    'upright_row',
    'bench_press',
    'dips',
    'pullup'
  ],
  knee: [
    'squats',
    'lunges',
    'leg_press',
    'leg_extension',
    'box_jumps',
    'burpees',
    'jump_squats',
    'running'
  ],
  lower_back: [
    'deadlifts',
    'romanian_deadlift',
    'good_mornings',
    'bent_over_row',
    'squat',
    'leg_press',
    'hyperextensions'
  ],
  neck: [
    'overhead_press',
    'shrugs',
    'upright_row',
    'handstand_pushup',
    'headstand'
  ],
  ankle: [
    'running',
    'jump_rope',
    'box_jumps',
    'burpees',
    'lunges',
    'calf_raises',
    'jumping_jacks'
  ]
};
```

---

## Quota Management

**File**: `/utils/quotaEnforcement.ts`

**Purpose**: Enforce message and video call limits based on subscription tier.

### Type Definitions

```typescript
type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';

interface QuotaLimits {
  messagesPerMonth: number | 'unlimited';
  videoCallsPerMonth: number;
  videoDurationMinutes: number;
  attachmentsAllowed: boolean;
}

interface QuotaStatus {
  messagesSent: number;
  messagesRemaining: number | 'unlimited';
  videoCallsUsed: number;
  videoCallsRemaining: number;
  periodStart: Date;
  periodEnd: Date;
  tier: SubscriptionTier;
}

interface QuotaCheckResult {
  allowed: boolean;
  remaining: number | 'unlimited';
  reason?: string;
  suggestedTier?: SubscriptionTier;
}
```

### Tier Limits

```typescript
/**
 * Quota limits by subscription tier
 */
export const QUOTA_LIMITS: Record<SubscriptionTier, QuotaLimits> = {
  'Freemium': {
    messagesPerMonth: 20,
    videoCallsPerMonth: 1,
    videoDurationMinutes: 15,
    attachmentsAllowed: false
  },
  'Premium': {
    messagesPerMonth: 200,
    videoCallsPerMonth: 2,
    videoDurationMinutes: 25,
    attachmentsAllowed: false
  },
  'Smart Premium': {
    messagesPerMonth: 'unlimited',
    videoCallsPerMonth: 4,
    videoDurationMinutes: 25,
    attachmentsAllowed: true
  }
};
```

---

### Core Functions

#### checkQuota()

```typescript
/**
 * Check if user can perform action based on quota
 * @param userId - User ID
 * @param action - Action type ('message' | 'call')
 * @param tier - User's subscription tier
 * @returns QuotaCheckResult with allowed status
 */
export async function checkQuota(
  userId: string,
  action: 'message' | 'call',
  tier: SubscriptionTier
): Promise<QuotaCheckResult> {
  const status = await getQuotaStatus(userId, tier);
  const limits = QUOTA_LIMITS[tier];
  
  if (action === 'message') {
    // Smart Premium has unlimited messages
    if (limits.messagesPerMonth === 'unlimited') {
      return {
        allowed: true,
        remaining: 'unlimited'
      };
    }
    
    // Check if under limit
    if (status.messagesSent < limits.messagesPerMonth) {
      return {
        allowed: true,
        remaining: limits.messagesPerMonth - status.messagesSent
      };
    }
    
    // Quota exceeded
    return {
      allowed: false,
      remaining: 0,
      reason: 'Message quota exceeded for this month',
      suggestedTier: tier === 'Freemium' ? 'Premium' : 'Smart Premium'
    };
  }
  
  if (action === 'call') {
    if (status.videoCallsUsed < limits.videoCallsPerMonth) {
      return {
        allowed: true,
        remaining: limits.videoCallsPerMonth - status.videoCallsUsed
      };
    }
    
    return {
      allowed: false,
      remaining: 0,
      reason: 'Video call quota exceeded for this month',
      suggestedTier: tier === 'Freemium' ? 'Premium' : 'Smart Premium'
    };
  }
  
  return { allowed: false, remaining: 0, reason: 'Invalid action' };
}
```

**Example**:
```typescript
const result = await checkQuota('user_123', 'message', 'Freemium');

if (!result.allowed) {
  console.log(result.reason); // "Message quota exceeded for this month"
  console.log('Upgrade to:', result.suggestedTier); // "Premium"
  showUpgradePrompt();
} else {
  console.log('Messages remaining:', result.remaining); // 5
  await sendMessage();
}
```

---

#### incrementQuota()

```typescript
/**
 * Increment quota usage after successful action
 * @param userId - User ID
 * @param action - Action type
 */
export async function incrementQuota(
  userId: string,
  action: 'message' | 'call'
): Promise<void> {
  const currentUsage = await getQuotaUsage(userId);
  
  if (action === 'message') {
    await updateQuotaUsage(userId, {
      ...currentUsage,
      messagesSent: currentUsage.messagesSent + 1,
      lastMessageAt: new Date()
    });
  }
  
  if (action === 'call') {
    await updateQuotaUsage(userId, {
      ...currentUsage,
      videoCallsUsed: currentUsage.videoCallsUsed + 1,
      lastCallAt: new Date()
    });
  }
}
```

**Example**:
```typescript
// After sending message
await sendMessage(content, conversationId);
await incrementQuota(userId, 'message');

// Refresh quota display
const newStatus = await getQuotaStatus(userId, userTier);
setQuotaStatus(newStatus);
```

---

#### resetMonthlyQuotas()

```typescript
/**
 * Reset all user quotas (scheduled monthly job)
 * Runs on 1st of each month at midnight
 */
export async function resetMonthlyQuotas(): Promise<void> {
  const allUsers = await getAllUsers();
  
  for (const user of allUsers) {
    await updateQuotaUsage(user.id, {
      messagesSent: 0,
      videoCallsUsed: 0,
      periodStart: new Date(),
      periodEnd: getEndOfMonth(new Date())
    });
  }
  
  console.log(`Reset quotas for ${allUsers.length} users`);
}
```

---

#### getQuotaWarningLevel()

```typescript
/**
 * Determine warning level based on remaining quota
 * @param remaining - Remaining quota amount
 * @param limit - Total quota limit
 * @returns 'none' | 'low' | 'critical' | 'exceeded'
 */
export function getQuotaWarningLevel(
  remaining: number | 'unlimited',
  limit: number | 'unlimited'
): 'none' | 'low' | 'critical' | 'exceeded' {
  if (remaining === 'unlimited') return 'none';
  if (remaining === 0) return 'exceeded';
  
  if (limit === 'unlimited') return 'none';
  
  const percentage = (remaining / limit) * 100;
  
  if (percentage <= 10) return 'critical'; // 10% or less
  if (percentage <= 25) return 'low';      // 25% or less
  return 'none';
}
```

**Example**:
```typescript
const warning = getQuotaWarningLevel(2, 20);
console.log(warning); // "critical"

// Show appropriate warning
if (warning === 'critical') {
  showWarningBanner('Only 2 messages remaining this month. Upgrade to Premium for 200 messages.');
}
```

---

## Nutrition Expiry

**File**: `/utils/nutritionExpiry.ts`

**Purpose**: Manage time-limited nutrition access for Freemium users.

### Type Definitions

```typescript
interface NutritionAccessStatus {
  hasAccess: boolean;
  isExpired: boolean;
  isTrial: boolean;
  startDate: Date | null;
  expiryDate: Date | null;
  daysLeft: number;
  tier: SubscriptionTier;
}

interface NutritionTrialData {
  userId: string;
  startDate: Date;
  expiryDate: Date;
  isActive: boolean;
}
```

---

### Core Functions

#### getNutritionAccessStatus()

```typescript
/**
 * Get nutrition access status for user
 * @param userId - User ID
 * @param tier - User's subscription tier
 * @returns NutritionAccessStatus with access details
 */
export async function getNutritionAccessStatus(
  userId: string,
  tier: SubscriptionTier
): Promise<NutritionAccessStatus> {
  // Premium+ users have unlimited access
  if (tier === 'Premium' || tier === 'Smart Premium') {
    return {
      hasAccess: true,
      isExpired: false,
      isTrial: false,
      startDate: null,
      expiryDate: null,
      daysLeft: -1, // -1 = unlimited
      tier
    };
  }
  
  // Freemium users have 7-day trial
  const trialData = await getNutritionTrial(userId);
  
  if (!trialData) {
    // No trial started yet
    return {
      hasAccess: false,
      isExpired: false,
      isTrial: false,
      startDate: null,
      expiryDate: null,
      daysLeft: 7, // 7 days available if they start
      tier
    };
  }
  
  // Calculate days left
  const now = new Date();
  const daysLeft = Math.ceil(
    (trialData.expiryDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
  );
  
  const isExpired = daysLeft <= 0;
  
  return {
    hasAccess: !isExpired,
    isExpired,
    isTrial: true,
    startDate: trialData.startDate,
    expiryDate: trialData.expiryDate,
    daysLeft: Math.max(0, daysLeft),
    tier
  };
}
```

**Example**:
```typescript
const status = await getNutritionAccessStatus('user_123', 'Freemium');

if (status.isExpired) {
  return <UpgradePrompt message="Your 7-day nutrition trial has expired" />;
}

if (status.isTrial && status.daysLeft <= 2) {
  showExpiryBanner(`${status.daysLeft} days left in your nutrition trial`);
}

return <NutritionScreen />;
```

---

#### startNutritionTrial()

```typescript
/**
 * Start 7-day nutrition trial for Freemium user
 * @param userId - User ID
 * @returns NutritionTrialData with trial details
 */
export async function startNutritionTrial(
  userId: string
): Promise<NutritionTrialData> {
  const now = new Date();
  const expiryDate = new Date(now);
  expiryDate.setDate(expiryDate.getDate() + 7); // 7 days from now
  
  const trialData: NutritionTrialData = {
    userId,
    startDate: now,
    expiryDate,
    isActive: true
  };
  
  await saveNutritionTrial(userId, trialData);
  
  // Track event
  trackEvent('nutrition_trial_started', {
    userId,
    startDate: now,
    expiryDate
  });
  
  return trialData;
}
```

**Example**:
```typescript
const handleGenerateNutritionPlan = async () => {
  const status = await getNutritionAccessStatus(userId, 'Freemium');
  
  if (!status.isTrial && !status.hasAccess) {
    // Start trial on first nutrition generation
    await startNutritionTrial(userId);
    toast.success('Your 7-day nutrition trial has started!');
  }
  
  // Generate plan
  const plan = await generateNutritionPlan(userId);
  setMealPlan(plan);
};
```

---

#### shouldShowExpiryBanner()

```typescript
/**
 * Determine if expiry banner should be shown
 * @param status - Nutrition access status
 * @returns boolean
 */
export function shouldShowExpiryBanner(
  status: NutritionAccessStatus
): boolean {
  return (
    status.isTrial &&
    !status.isExpired &&
    status.daysLeft <= 3 &&
    status.daysLeft > 0
  );
}
```

**Example**:
```typescript
const status = await getNutritionAccessStatus(userId, tier);

{shouldShowExpiryBanner(status) && (
  <NutritionExpiryBanner
    daysLeft={status.daysLeft}
    onUpgrade={() => navigate('/upgrade')}
  />
)}
```

---

## Phone Validation

**File**: `/utils/phoneValidation.ts`

**Purpose**: Validate Saudi phone numbers for OTP authentication.

### Type Definitions

```typescript
interface ValidationResult {
  isValid: boolean;
  formatted?: string; // +966XXXXXXXXX format
  error?: string;
}
```

---

### Core Functions

#### validateSaudiPhone()

```typescript
/**
 * Validate Saudi phone number
 * Format: +966 5X XXX XXXX (starts with 5, 9 digits after country code)
 * @param phone - Phone number string
 * @returns ValidationResult
 */
export function validateSaudiPhone(phone: string): ValidationResult {
  // Remove all non-digit characters
  const cleaned = phone.replace(/\D/g, '');
  
  // Check if starts with country code
  let number = cleaned;
  if (cleaned.startsWith('966')) {
    number = cleaned.slice(3); // Remove country code
  } else if (cleaned.startsWith('+966')) {
    number = cleaned.slice(4);
  }
  
  // Must be 9 digits
  if (number.length !== 9) {
    return {
      isValid: false,
      error: 'Phone number must be 9 digits'
    };
  }
  
  // Must start with 5
  if (!number.startsWith('5')) {
    return {
      isValid: false,
      error: 'Saudi mobile numbers must start with 5'
    };
  }
  
  // Valid!
  return {
    isValid: true,
    formatted: `+966${number}`
  };
}
```

**Example**:
```typescript
const inputs = [
  '512345678',
  '966512345678',
  '+966512345678',
  '412345678',  // Invalid: doesn't start with 5
  '5123456',    // Invalid: too short
];

inputs.forEach(phone => {
  const result = validateSaudiPhone(phone);
  console.log(`${phone}: ${result.isValid ? result.formatted : result.error}`);
});

// Output:
// 512345678: +966512345678
// 966512345678: +966512345678
// +966512345678: +966512345678
// 412345678: Saudi mobile numbers must start with 5
// 5123456: Phone number must be 9 digits
```

---

#### formatPhoneNumber()

```typescript
/**
 * Format phone number for display
 * @param phone - Raw phone number
 * @returns Formatted string (e.g., "+966 512 345 678")
 */
export function formatPhoneNumber(phone: string): string {
  const validation = validateSaudiPhone(phone);
  
  if (!validation.isValid || !validation.formatted) {
    return phone; // Return original if invalid
  }
  
  const number = validation.formatted.slice(4); // Remove +966
  
  // Format: +966 5XX XXX XXX
  return `+966 ${number.slice(0, 3)} ${number.slice(3, 6)} ${number.slice(6)}`;
}
```

**Example**:
```typescript
const formatted = formatPhoneNumber('512345678');
console.log(formatted); // "+966 512 345 678"
```

---

## Fitness Score Calculation

**File**: `/utils/fitnessScore.ts`

**Purpose**: Calculate user's fitness score (0-100) based on second intake data.

### Type Definitions

```typescript
interface SecondIntakeData {
  age: number;
  weight: number;
  height: number;
  experience: 'beginner' | 'intermediate' | 'advanced';
  frequency: number; // 2-6 days/week
  injuries: InjuryArea[];
}
```

---

### Core Function

#### calculateFitnessScore()

```typescript
/**
 * Calculate fitness score (0-100)
 * Formula weighs: experience (30%), frequency (30%), injuries (20%), age (10%), BMI (10%)
 * @param data - Second intake data
 * @returns score (0-100)
 */
export function calculateFitnessScore(data: SecondIntakeData): number {
  let score = 0;
  
  // 1. Experience Level (0-30 points)
  const experiencePoints = {
    'beginner': 10,
    'intermediate': 20,
    'advanced': 30
  };
  score += experiencePoints[data.experience];
  
  // 2. Workout Frequency (0-30 points)
  // 2 days = 10 pts, 3 days = 15 pts, 4 days = 20 pts, 5 days = 25 pts, 6 days = 30 pts
  score += Math.min(30, ((data.frequency - 2) * 5) + 10);
  
  // 3. Injuries (0-20 points)
  // No injuries = 20 pts, 1 injury = 15 pts, 2 injuries = 10 pts, 3+ injuries = 5 pts
  const injuryPenalty = Math.min(data.injuries.length, 4) * 5;
  score += 20 - injuryPenalty;
  
  // 4. Age Factor (0-10 points)
  // Peak age 18-35 = 10 pts, decreases outside this range
  if (data.age >= 18 && data.age <= 35) {
    score += 10;
  } else if (data.age < 18) {
    score += Math.max(5, 10 - (18 - data.age));
  } else {
    score += Math.max(5, 10 - ((data.age - 35) / 5));
  }
  
  // 5. BMI Factor (0-10 points)
  const heightInMeters = data.height / 100;
  const bmi = data.weight / (heightInMeters * heightInMeters);
  
  // Optimal BMI 18.5-24.9 = 10 pts, decreases outside range
  if (bmi >= 18.5 && bmi <= 24.9) {
    score += 10;
  } else if (bmi < 18.5) {
    score += Math.max(5, 10 - ((18.5 - bmi) * 2));
  } else {
    score += Math.max(5, 10 - ((bmi - 24.9) * 0.5));
  }
  
  // Round to nearest integer
  return Math.round(Math.max(0, Math.min(100, score)));
}
```

**Example**:
```typescript
const userData: SecondIntakeData = {
  age: 28,
  weight: 75,
  height: 175,
  experience: 'intermediate',
  frequency: 4,
  injuries: ['knee']
};

const score = calculateFitnessScore(userData);
console.log(score); // 75

// Breakdown:
// Experience (intermediate): 20 pts
// Frequency (4 days): 20 pts
// Injuries (1 injury): 15 pts
// Age (28): 10 pts
// BMI (24.5): 10 pts
// Total: 75
```

---

## Translation System

**File**: `/utils/translations.ts`

**Purpose**: Manage bilingual support (Arabic/English).

### Core Functions

#### useLanguage() Hook

```typescript
import { useContext } from 'react';
import { LanguageContext } from '../components/LanguageContext';

export function useLanguage() {
  const context = useContext(LanguageContext);
  
  if (!context) {
    throw new Error('useLanguage must be used within LanguageProvider');
  }
  
  return context;
}
```

**Usage**:
```typescript
const { t, language, setLanguage } = useLanguage();

const greeting = t('home.greeting'); // "Good Morning" or "صباح الخير"
```

---

#### t() Function

```typescript
/**
 * Translate key to current language
 * @param key - Translation key (e.g., 'home.greeting')
 * @param params - Optional parameters for interpolation
 * @returns Translated string
 */
export function t(key: string, params?: Record<string, any>): string {
  const { language } = useLanguage();
  const translations = getTranslations(language);
  
  let text = translations[key] || key;
  
  // Parameter interpolation
  if (params) {
    Object.keys(params).forEach(param => {
      text = text.replace(`{${param}}`, params[param]);
    });
  }
  
  return text;
}
```

**Example**:
```typescript
// Simple translation
const title = t('workout.title'); // "Workout" or "تمرين"

// With parameters
const message = t('quota.messagesRemaining', { count: 5 });
// English: "5 messages remaining"
// Arabic: "5 رسائل متبقية"
```

---

## Date & Time Utilities

**File**: `/utils/dateUtils.ts`

### formatDate()

```typescript
/**
 * Format date for display
 * @param date - Date object or string
 * @param format - 'short' | 'long' | 'time'
 * @param language - 'ar' | 'en'
 * @returns Formatted date string
 */
export function formatDate(
  date: Date | string,
  format: 'short' | 'long' | 'time' = 'short',
  language: 'ar' | 'en' = 'en'
): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  
  const options: Intl.DateTimeFormatOptions = {
    short: { year: 'numeric', month: 'short', day: 'numeric' },
    long: { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' },
    time: { hour: '2-digit', minute: '2-digit' }
  }[format];
  
  const locale = language === 'ar' ? 'ar-SA' : 'en-US';
  
  return d.toLocaleDateString(locale, options);
}
```

**Example**:
```typescript
const date = new Date('2024-12-18');

formatDate(date, 'short', 'en');  // "Dec 18, 2024"
formatDate(date, 'short', 'ar');  // "١٨ ديسمبر ٢٠٢٤"
formatDate(date, 'long', 'en');   // "Wednesday, December 18, 2024"
```

---

### getRelativeTime()

```typescript
/**
 * Get relative time string (e.g., "2 hours ago")
 * @param date - Date to compare
 * @param language - Language for output
 * @returns Relative time string
 */
export function getRelativeTime(
  date: Date | string,
  language: 'ar' | 'en' = 'en'
): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diffMs = now.getTime() - d.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  
  if (language === 'en') {
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
    return formatDate(d, 'short', 'en');
  } else {
    if (diffMins < 1) return 'الآن';
    if (diffMins < 60) return `منذ ${diffMins} دقيقة`;
    if (diffHours < 24) return `منذ ${diffHours} ساعة`;
    if (diffDays < 7) return `منذ ${diffDays} يوم`;
    return formatDate(d, 'short', 'ar');
  }
}
```

**Example**:
```typescript
const messageTime = new Date(Date.now() - 3600000); // 1 hour ago

getRelativeTime(messageTime, 'en'); // "1 hour ago"
getRelativeTime(messageTime, 'ar'); // "منذ ١ ساعة"
```

---

## Storage Utilities

**File**: `/utils/storage.ts`

### localStorage Helpers

```typescript
/**
 * Save data to localStorage with prefix
 */
export function saveLocal<T>(key: string, value: T): void {
  try {
    const prefixed = `fitcoach_${key}`;
    localStorage.setItem(prefixed, JSON.stringify(value));
  } catch (error) {
    console.error('Failed to save to localStorage:', error);
  }
}

/**
 * Load data from localStorage
 */
export function loadLocal<T>(key: string): T | null {
  try {
    const prefixed = `fitcoach_${key}`;
    const item = localStorage.getItem(prefixed);
    return item ? JSON.parse(item) : null;
  } catch (error) {
    console.error('Failed to load from localStorage:', error);
    return null;
  }
}

/**
 * Remove data from localStorage
 */
export function removeLocal(key: string): void {
  const prefixed = `fitcoach_${key}`;
  localStorage.removeItem(prefixed);
}
```

**Example**:
```typescript
// Save user preferences
saveLocal('language', 'ar');
saveLocal('theme', 'dark');

// Load user preferences
const language = loadLocal<string>('language'); // 'ar'
const theme = loadLocal<string>('theme'); // 'dark'

// Remove preference
removeLocal('theme');
```

---

## Validation Utilities

**File**: `/utils/validation.ts`

### Input Validators

```typescript
/**
 * Validate age input
 */
export function validateAge(age: number): { isValid: boolean; error?: string } {
  if (age < 13) return { isValid: false, error: 'Minimum age is 13' };
  if (age > 120) return { isValid: false, error: 'Maximum age is 120' };
  return { isValid: true };
}

/**
 * Validate weight input
 */
export function validateWeight(weight: number, unit: 'kg' | 'lbs' = 'kg'): { isValid: boolean; error?: string } {
  const min = unit === 'kg' ? 30 : 66;
  const max = unit === 'kg' ? 300 : 660;
  
  if (weight < min) return { isValid: false, error: `Minimum weight is ${min} ${unit}` };
  if (weight > max) return { isValid: false, error: `Maximum weight is ${max} ${unit}` };
  return { isValid: true };
}

/**
 * Validate height input
 */
export function validateHeight(height: number, unit: 'cm' | 'ft' = 'cm'): { isValid: boolean; error?: string } {
  const min = unit === 'cm' ? 100 : 3.3;
  const max = unit === 'cm' ? 250 : 8.2;
  
  if (height < min) return { isValid: false, error: `Minimum height is ${min} ${unit}` };
  if (height > max) return { isValid: false, error: `Maximum height is ${max} ${unit}` };
  return { isValid: true };
}
```

**Example**:
```typescript
const ageResult = validateAge(15);
console.log(ageResult); // { isValid: true }

const weightResult = validateWeight(25, 'kg');
console.log(weightResult); // { isValid: false, error: 'Minimum weight is 30 kg' }
```

---

## API Helpers

**File**: `/utils/api.ts`

### HTTP Request Wrapper

```typescript
/**
 * Make API request with error handling
 */
export async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const baseURL = import.meta.env.VITE_API_URL || 'https://api.fitcoachplus.com';
  
  try {
    const response = await fetch(`${baseURL}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
}
```

**Example**:
```typescript
// GET request
const user = await apiRequest<UserProfile>('/users/123');

// POST request
const newWorkout = await apiRequest<WorkoutPlan>('/workouts', {
  method: 'POST',
  body: JSON.stringify({ name: 'New Plan', days: [...] })
});
```

---

**Total Utilities Documented**: 15+ utility modules covering all core business logic

**End of Utilities Reference**
