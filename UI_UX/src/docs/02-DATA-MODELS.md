# FitCoach+ v2.0 - Data Models & Schema

## Document Information
- **Document**: Data Models & Database Schema
- **Version**: 2.0.0
- **Last Updated**: December 8, 2024
- **Purpose**: Complete data structure definitions for platform-agnostic migration

---

## 1. Core Type Definitions

### 1.1 Enumeration Types

```typescript
// User Roles
type UserType = 'user' | 'coach' | 'admin';

// Subscription Tiers
type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';

// Gender
type Gender = 'male' | 'female' | 'other';

// Fitness Goals
type MainGoal = 'fat_loss' | 'muscle_gain' | 'general_fitness';

// Workout Locations
type WorkoutLocation = 'home' | 'gym';

// Experience Levels
type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';

// Injury Areas
type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';

// Screen Navigation
type Screen = 
  | 'intro' 
  | 'auth' 
  | 'firstIntake' 
  | 'secondIntake' 
  | 'home' 
  | 'workout' 
  | 'nutrition' 
  | 'coach' 
  | 'store' 
  | 'account' 
  | 'coachProfile' 
  | 'publicCoachProfile';

// Languages
type Language = 'en' | 'ar';

// Payment Status
type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';

// Order Status
type OrderStatus = 'processing' | 'shipped' | 'delivered' | 'cancelled';

// Message Type
type MessageType = 'text' | 'image' | 'file';

// Call Status
type CallStatus = 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
```

---

## 2. User & Authentication Models

### 2.1 User Profile Model

**Purpose**: Core user account information and fitness profile

```typescript
interface UserProfile {
  // Identity
  id: string;                          // UUID primary key
  phoneNumber: string;                 // Unique, Saudi format: +966XXXXXXXXX
  name: string;                        // Full name
  email?: string;                      // Optional email
  
  // Physical Attributes
  age: number;                         // 13-120 years
  weight: number;                      // kg, 30-300
  height: number;                      // cm, 100-250
  gender: Gender;                      // 'male' | 'female' | 'other'
  
  // Fitness Profile
  workoutFrequency: number;            // 2-6 days per week
  workoutLocation: WorkoutLocation;    // 'home' | 'gym'
  experienceLevel: ExperienceLevel;    // 'beginner' | 'intermediate' | 'advanced'
  mainGoal: MainGoal;                  // 'fat_loss' | 'muscle_gain' | 'general_fitness'
  injuries: InjuryArea[];              // Array of injury areas
  
  // Subscription
  subscriptionTier: SubscriptionTier;  // 'Freemium' | 'Premium' | 'Smart Premium'
  subscriptionStartDate?: Date;
  subscriptionEndDate?: Date;
  
  // Coach Assignment
  coachId?: string;                    // FK to Coach.id (nullable)
  
  // Intake Status
  hasCompletedSecondIntake?: boolean;  // true if Premium+ completed detailed intake
  
  // Fitness Score (v2.0)
  fitnessScore?: number;               // 0-100, calculated or coach-assigned
  fitnessScoreUpdatedBy?: 'auto' | 'coach';
  fitnessScoreLastUpdated?: Date;
  
  // InBody History (v2.0)
  inBodyHistory?: InBodyHistory;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt?: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  
  age INTEGER CHECK (age BETWEEN 13 AND 120),
  weight DECIMAL(5,2) CHECK (weight BETWEEN 30 AND 300),
  height INTEGER CHECK (height BETWEEN 100 AND 250),
  gender VARCHAR(10) NOT NULL,
  
  workout_frequency INTEGER CHECK (workout_frequency BETWEEN 2 AND 6),
  workout_location VARCHAR(10) NOT NULL,
  experience_level VARCHAR(20) NOT NULL,
  main_goal VARCHAR(30) NOT NULL,
  injuries TEXT[], -- PostgreSQL array
  
  subscription_tier VARCHAR(20) NOT NULL DEFAULT 'Freemium',
  subscription_start_date TIMESTAMP,
  subscription_end_date TIMESTAMP,
  
  coach_id UUID REFERENCES coaches(id),
  
  has_completed_second_intake BOOLEAN DEFAULT FALSE,
  
  fitness_score INTEGER CHECK (fitness_score BETWEEN 0 AND 100),
  fitness_score_updated_by VARCHAR(10),
  fitness_score_last_updated TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login_at TIMESTAMP
);

CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_coach ON users(coach_id);
CREATE INDEX idx_users_tier ON users(subscription_tier);
```

---

### 2.2 Coach Profile Model

**Purpose**: Coach account information and metadata

```typescript
interface CoachProfile {
  // Identity
  id: string;                          // UUID primary key
  userId: string;                      // FK to UserProfile.id
  
  // Professional Info
  bio: string;                         // 500 char max
  specialties: string[];               // e.g., ['Weight Loss', 'Strength Training']
  certifications: string[];            // e.g., ['NASM-CPT', 'Precision Nutrition L1']
  yearsExperience: number;             // Years of coaching experience
  
  // Public Profile
  profileImageUrl?: string;
  coverImageUrl?: string;
  isPublicProfileEnabled: boolean;     // Can users find this coach?
  
  // Stats
  totalClients: number;
  activeClients: number;
  averageRating: number;               // 0-5, calculated from ratings
  totalRatings: number;
  
  // Availability
  isAcceptingClients: boolean;
  maxClients: number;                  // Capacity limit
  
  // Earnings (v2.0)
  totalEarnings: number;               // All-time earnings
  monthlyEarnings: number;             // Current month
  pendingPayout: number;               // Awaiting transfer
  
  // Metadata
  approvalStatus: 'pending' | 'approved' | 'suspended';
  approvedAt?: Date;
  approvedBy?: string;                 // Admin user ID
  createdAt: Date;
  updatedAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE coaches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id),
  
  bio TEXT,
  specialties TEXT[],
  certifications TEXT[],
  years_experience INTEGER,
  
  profile_image_url TEXT,
  cover_image_url TEXT,
  is_public_profile_enabled BOOLEAN DEFAULT TRUE,
  
  total_clients INTEGER DEFAULT 0,
  active_clients INTEGER DEFAULT 0,
  average_rating DECIMAL(2,1) DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  
  is_accepting_clients BOOLEAN DEFAULT TRUE,
  max_clients INTEGER DEFAULT 50,
  
  total_earnings DECIMAL(10,2) DEFAULT 0,
  monthly_earnings DECIMAL(10,2) DEFAULT 0,
  pending_payout DECIMAL(10,2) DEFAULT 0,
  
  approval_status VARCHAR(20) DEFAULT 'pending',
  approved_at TIMESTAMP,
  approved_by UUID REFERENCES users(id),
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_coaches_user ON coaches(user_id);
CREATE INDEX idx_coaches_approval ON coaches(approval_status);
```

---

### 2.3 OTP Authentication Model

**Purpose**: Temporary storage for phone verification codes

```typescript
interface OTPSession {
  id: string;
  phoneNumber: string;
  otpCode: string;                     // 6-digit numeric code
  createdAt: Date;
  expiresAt: Date;                     // Usually createdAt + 5 minutes
  attempts: number;                    // Failed verification attempts
  isVerified: boolean;
  verifiedAt?: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE otp_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone_number VARCHAR(15) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  attempts INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP
);

CREATE INDEX idx_otp_phone ON otp_sessions(phone_number);
CREATE INDEX idx_otp_expires ON otp_sessions(expires_at);

-- Auto-delete expired OTP sessions
CREATE OR REPLACE FUNCTION delete_expired_otp_sessions()
RETURNS void AS $$
BEGIN
  DELETE FROM otp_sessions WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;
```

---

## 3. Intake Models (v2.0)

### 3.1 First Intake Data

**Purpose**: Initial 3-question intake for all users

```typescript
interface FirstIntakeData {
  gender: Gender;                      // 'male' | 'female' | 'other'
  mainGoal: MainGoal;                  // 'fat_loss' | 'muscle_gain' | 'general_fitness'
  workoutLocation: WorkoutLocation;    // 'home' | 'gym'
  completedAt?: Date;
}
```

**Storage**: Merged into UserProfile after completion (no separate table)

**Validation Rules**:
```typescript
interface IntakeValidation {
  isValid: boolean;
  errors: string[];
}

function validateFirstIntake(data: Partial<FirstIntakeData>): IntakeValidation {
  const errors: string[] = [];
  
  if (!data.gender) errors.push('Gender is required');
  if (!data.mainGoal) errors.push('Fitness goal is required');
  if (!data.workoutLocation) errors.push('Workout location is required');
  
  return {
    isValid: errors.length === 0,
    errors
  };
}
```

---

### 3.2 Second Intake Data

**Purpose**: Detailed 6-question intake for Premium+ users only

```typescript
interface SecondIntakeData {
  age: number;                         // 13-120 years
  weight: number;                      // kg, 30-300
  height: number;                      // cm, 100-250
  experienceLevel: ExperienceLevel;    // 'beginner' | 'intermediate' | 'advanced'
  workoutFrequency: number;            // 2-6 days per week
  injuries: InjuryArea[];              // Array of injury areas
  completedAt?: Date;
}
```

**Storage**: Merged into UserProfile after completion (no separate table)

**Validation Rules**:
```typescript
function validateSecondIntake(data: Partial<SecondIntakeData>): IntakeValidation {
  const errors: string[] = [];
  
  if (!data.age || data.age < 13 || data.age > 120) {
    errors.push('Valid age is required (13-120)');
  }
  if (!data.weight || data.weight < 30 || data.weight > 300) {
    errors.push('Valid weight is required (30-300 kg)');
  }
  if (!data.height || data.height < 100 || data.height > 250) {
    errors.push('Valid height is required (100-250 cm)');
  }
  if (!data.experienceLevel) {
    errors.push('Experience level is required');
  }
  if (!data.workoutFrequency || data.workoutFrequency < 2 || data.workoutFrequency > 6) {
    errors.push('Workout frequency must be 2-6 days per week');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}
```

---

## 4. Quota & Subscription Models (v2.0)

### 4.1 Quota Limits Configuration

**Purpose**: Define tier-based usage limits (server-side config)

```typescript
interface QuotaLimits {
  messages: number | 'unlimited';      // Monthly message limit
  calls: number;                       // Monthly video call limit
  callDuration: number;                // Minutes per call
  chatAttachments: boolean;            // Can send files in chat?
  nutritionPersistent: boolean;        // Unlimited nutrition access?
  nutritionWindowDays: number | null;  // Trial period (null = unlimited)
}

// Tier Configuration
const TIER_QUOTAS: Record<SubscriptionTier, QuotaLimits> = {
  'Freemium': {
    messages: 20,
    calls: 1,
    callDuration: 15,
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
    nutritionWindowDays: null
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

---

### 4.2 Quota Usage Tracking

**Purpose**: Track user consumption against limits

```typescript
interface QuotaUsage {
  userId: string;                      // FK to UserProfile.id
  tier: SubscriptionTier;
  
  // Message Tracking
  messagesUsed: number;
  messagesTotal: number | 'unlimited';
  
  // Call Tracking
  callsUsed: number;
  callsTotal: number;
  
  // Reset Information
  resetDate: Date;                     // First day of next month
  lastResetAt?: Date;
  
  // Metadata
  updatedAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE quota_usage (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  tier VARCHAR(20) NOT NULL,
  
  messages_used INTEGER DEFAULT 0,
  messages_total VARCHAR(20) NOT NULL, -- Can be 'unlimited'
  
  calls_used INTEGER DEFAULT 0,
  calls_total INTEGER NOT NULL,
  
  reset_date TIMESTAMP NOT NULL,
  last_reset_at TIMESTAMP,
  
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Monthly reset job (scheduled task)
CREATE OR REPLACE FUNCTION reset_monthly_quotas()
RETURNS void AS $$
BEGIN
  UPDATE quota_usage
  SET messages_used = 0,
      calls_used = 0,
      last_reset_at = NOW(),
      reset_date = DATE_TRUNC('month', NOW() + INTERVAL '1 month')
  WHERE reset_date <= NOW();
END;
$$ LANGUAGE plpgsql;
```

---

### 4.3 Quota Check Logic

**Purpose**: Verify if action is allowed

```typescript
interface QuotaCheckResult {
  allowed: boolean;
  reason?: string;                     // Why denied (e.g., "Message quota exceeded")
  remaining?: number;                  // How many left
  showWarning?: boolean;               // true if at 80% usage
}

function checkQuota(
  tier: SubscriptionTier,
  usage: QuotaUsage,
  action: 'message' | 'call' | 'attachment'
): QuotaCheckResult {
  const limits = TIER_QUOTAS[tier];
  
  switch (action) {
    case 'message': {
      if (limits.messages === 'unlimited') {
        return { allowed: true };
      }
      
      const remaining = limits.messages - usage.messagesUsed;
      
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Message quota exceeded',
          remaining: 0
        };
      }
      
      const usagePercent = (usage.messagesUsed / limits.messages) * 100;
      
      return {
        allowed: true,
        remaining,
        showWarning: usagePercent >= 80
      };
    }
    
    case 'call': {
      const remaining = limits.calls - usage.callsUsed;
      
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Video call quota exceeded',
          remaining: 0
        };
      }
      
      const usagePercent = (usage.callsUsed / limits.calls) * 100;
      
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
          reason: 'Attachments require Premium subscription'
        };
      }
      
      return { allowed: true };
    }
  }
}
```

---

## 5. InBody Tracking Models (v2.0)

### 5.1 InBody Scan Data

**Purpose**: Store professional body composition measurements

```typescript
interface InBodyData {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  scanDate: Date;
  
  // Weight Measurements
  totalWeight: number;                 // kg
  bodyFatMass: number;                 // kg
  leanBodyMass: number;                // kg
  skeletalMuscleMass: number;          // kg
  
  // Percentages
  bodyFatPercentage: number;           // %
  muscleMassPercentage: number;        // %
  
  // Body Water
  totalBodyWater: number;              // kg
  intracellularWater: number;          // kg
  extracellularWater: number;          // kg
  
  // Segmental Analysis (optional)
  rightArmMuscleMass?: number;         // kg
  leftArmMuscleMass?: number;          // kg
  trunkMuscleMass?: number;            // kg
  rightLegMuscleMass?: number;         // kg
  leftLegMuscleMass?: number;          // kg
  
  // Metabolic Data
  basalMetabolicRate: number;          // kcal/day
  
  // Visceral Fat
  visceralFatLevel: number;            // 1-20 scale
  
  // Notes
  notes?: string;
  createdBy?: string;                  // User or Coach ID
  
  createdAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE inbody_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  scan_date TIMESTAMP NOT NULL,
  
  total_weight DECIMAL(5,2) NOT NULL,
  body_fat_mass DECIMAL(5,2),
  lean_body_mass DECIMAL(5,2),
  skeletal_muscle_mass DECIMAL(5,2),
  
  body_fat_percentage DECIMAL(4,2),
  muscle_mass_percentage DECIMAL(4,2),
  
  total_body_water DECIMAL(5,2),
  intracellular_water DECIMAL(5,2),
  extracellular_water DECIMAL(5,2),
  
  right_arm_muscle_mass DECIMAL(4,2),
  left_arm_muscle_mass DECIMAL(4,2),
  trunk_muscle_mass DECIMAL(4,2),
  right_leg_muscle_mass DECIMAL(4,2),
  left_leg_muscle_mass DECIMAL(4,2),
  
  basal_metabolic_rate INTEGER,
  visceral_fat_level INTEGER,
  
  notes TEXT,
  created_by UUID REFERENCES users(id),
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_inbody_user ON inbody_scans(user_id);
CREATE INDEX idx_inbody_date ON inbody_scans(scan_date);
```

---

### 5.2 InBody History

**Purpose**: Aggregate view of user's InBody scan history

```typescript
interface InBodyHistory {
  scans: InBodyData[];                 // Array of all scans, sorted by date
  latestScan?: InBodyData;             // Most recent scan
}
```

**Implementation**: Not a separate table, constructed from `inbody_scans` query

---

## 6. Workout Models

### 6.1 Exercise Definition

**Purpose**: Exercise library database

```typescript
interface Exercise {
  id: string;                          // UUID or slug (e.g., 'bench-press')
  name: string;
  nameArabic: string;                  // Arabic translation
  muscleGroup: string;                 // 'chest', 'back', 'legs', etc.
  category: string;                    // 'compound', 'isolation', 'cardio'
  equipment: string[];                 // ['barbell', 'bench'], ['dumbbells'], etc.
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  
  // Defaults
  defaultSets: number;
  defaultReps: string;                 // e.g., '8-12', '15-20', 'AMRAP'
  defaultRestTime: number;             // seconds
  
  // Media
  thumbnailUrl?: string;
  videoUrl?: string;
  instructionSteps: string[];          // Step-by-step instructions
  
  // Contraindications (v2.0)
  avoidWithInjuries?: InjuryArea[];    // If present, flag for substitution
  
  // Metadata
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  muscle_group VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  equipment TEXT[],
  difficulty VARCHAR(20) NOT NULL,
  
  default_sets INTEGER NOT NULL,
  default_reps VARCHAR(20) NOT NULL,
  default_rest_time INTEGER NOT NULL,
  
  thumbnail_url TEXT,
  video_url TEXT,
  instruction_steps TEXT[],
  
  avoid_with_injuries TEXT[],
  
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_exercises_muscle ON exercises(muscle_group);
CREATE INDEX idx_exercises_category ON exercises(category);
```

---

### 6.2 Workout Plan

**Purpose**: Template or assigned workout program

```typescript
interface WorkoutPlan {
  id: string;                          // UUID
  name: string;
  nameArabic: string;
  
  // Ownership
  createdBy: string;                   // Coach ID
  assignedTo?: string;                 // User ID (if assigned)
  isTemplate: boolean;                 // true = reusable template
  
  // Program Details
  description: string;
  durationWeeks: number;
  workoutsPerWeek: number;
  goal: MainGoal;
  level: ExperienceLevel;
  
  // Workouts
  workouts: Workout[];                 // Array of daily workouts
  
  // Metadata
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

---

### 6.3 Workout (Single Session)

**Purpose**: One training session within a plan

```typescript
interface Workout {
  id: string;                          // UUID
  planId: string;                      // FK to WorkoutPlan.id
  dayNumber: number;                   // 1-7 (day of week)
  weekNumber: number;                  // 1-N
  
  name: string;                        // e.g., 'Upper Body Strength'
  nameArabic: string;
  
  exercises: WorkoutExercise[];        // Ordered list of exercises
  
  // Stats
  estimatedDuration: number;           // minutes
  totalExercises: number;
  
  // Completion
  completedAt?: Date;
  completedBy?: string;                // User ID
}
```

---

### 6.4 Workout Exercise

**Purpose**: Exercise instance within a workout session

```typescript
interface WorkoutExercise {
  id: string;                          // UUID
  workoutId: string;                   // FK to Workout.id
  exerciseId: string;                  // FK to Exercise.id
  order: number;                       // Position in workout (1, 2, 3...)
  
  // Prescription
  sets: number;
  reps: string;                        // e.g., '10-12', '15', 'AMRAP'
  restTime: number;                    // seconds between sets
  weight?: number;                     // kg (optional, user fills in)
  
  // Injury Substitution (v2.0)
  isSubstituted?: boolean;             // true if replaced due to injury
  originalExerciseId?: string;         // FK to Exercise.id (what it replaced)
  substitutionReason?: string;         // e.g., 'Knee injury - reduced loading'
  
  // Completion Tracking
  completedSets: number;               // How many sets user finished
  isCompleted: boolean;
  completedAt?: Date;
  
  // Notes
  coachNotes?: string;
  userNotes?: string;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE workout_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  created_by UUID NOT NULL REFERENCES coaches(id),
  assigned_to UUID REFERENCES users(id),
  is_template BOOLEAN DEFAULT FALSE,
  description TEXT,
  duration_weeks INTEGER,
  workouts_per_week INTEGER,
  goal VARCHAR(30),
  level VARCHAR(20),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL,
  week_number INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  estimated_duration INTEGER,
  total_exercises INTEGER,
  completed_at TIMESTAMP,
  completed_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  order_position INTEGER NOT NULL,
  sets INTEGER NOT NULL,
  reps VARCHAR(20) NOT NULL,
  rest_time INTEGER NOT NULL,
  weight DECIMAL(5,2),
  is_substituted BOOLEAN DEFAULT FALSE,
  original_exercise_id UUID REFERENCES exercises(id),
  substitution_reason TEXT,
  completed_sets INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP,
  coach_notes TEXT,
  user_notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_workout_plans_coach ON workout_plans(created_by);
CREATE INDEX idx_workout_plans_user ON workout_plans(assigned_to);
CREATE INDEX idx_workouts_plan ON workouts(plan_id);
CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);
```

---

## 7. Nutrition Models

### 7.1 Nutrition Plan

**Purpose**: Meal plan template or assignment

```typescript
interface NutritionPlan {
  id: string;                          // UUID
  name: string;
  nameArabic: string;
  
  // Ownership
  createdBy: string;                   // Coach ID
  assignedTo?: string;                 // User ID (if assigned)
  isTemplate: boolean;
  
  // Macros
  dailyCalories: number;               // kcal
  proteinGrams: number;
  carbGrams: number;
  fatGrams: number;
  
  // Plan Details
  durationDays: number;                // 7, 14, 30, etc.
  mealsPerDay: number;                 // 3-6
  goal: MainGoal;
  
  // Meals
  meals: Meal[];
  
  // Access Control (v2.0)
  generatedAt?: Date;                  // When first generated
  expiresAt?: Date;                    // For Freemium users (generatedAt + 7 days)
  isExpired?: boolean;                 // Calculated field
  
  // Metadata
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

---

### 7.2 Meal

**Purpose**: Single meal within nutrition plan

```typescript
interface Meal {
  id: string;                          // UUID
  planId: string;                      // FK to NutritionPlan.id
  dayNumber: number;                   // 1-N
  mealNumber: number;                  // 1 (breakfast), 2 (lunch), etc.
  
  name: string;                        // e.g., 'Breakfast', 'Post-Workout Snack'
  nameArabic: string;
  time?: string;                       // e.g., '7:00 AM', '12:30 PM'
  
  // Macros
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  
  // Foods
  foods: FoodItem[];
  
  // Notes
  instructions?: string;
  instructionsArabic?: string;
  
  // Logging
  isLogged?: boolean;
  loggedAt?: Date;
}
```

---

### 7.3 Food Item

**Purpose**: Individual food within a meal

```typescript
interface FoodItem {
  id: string;                          // UUID or slug
  name: string;
  nameArabic: string;
  
  // Serving
  servingSize: number;                 // grams or ml
  servingUnit: 'g' | 'ml' | 'piece' | 'cup' | 'tbsp';
  quantity: number;                    // How many servings
  
  // Macros per serving
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  
  // Category
  category: string;                    // 'protein', 'carb', 'vegetable', 'fruit', etc.
  
  // Database or Custom
  isCustom: boolean;                   // User-created food item
  createdBy?: string;                  // User ID if custom
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE nutrition_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  created_by UUID NOT NULL REFERENCES coaches(id),
  assigned_to UUID REFERENCES users(id),
  is_template BOOLEAN DEFAULT FALSE,
  daily_calories INTEGER NOT NULL,
  protein_grams INTEGER NOT NULL,
  carb_grams INTEGER NOT NULL,
  fat_grams INTEGER NOT NULL,
  duration_days INTEGER,
  meals_per_day INTEGER,
  goal VARCHAR(30),
  generated_at TIMESTAMP,
  expires_at TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES nutrition_plans(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL,
  meal_number INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  time VARCHAR(10),
  calories INTEGER NOT NULL,
  protein INTEGER NOT NULL,
  carbs INTEGER NOT NULL,
  fats INTEGER NOT NULL,
  instructions TEXT,
  instructions_arabic TEXT,
  is_logged BOOLEAN DEFAULT FALSE,
  logged_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE food_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  serving_size DECIMAL(6,2) NOT NULL,
  serving_unit VARCHAR(10) NOT NULL,
  calories INTEGER NOT NULL,
  protein INTEGER NOT NULL,
  carbs INTEGER NOT NULL,
  fats INTEGER NOT NULL,
  category VARCHAR(50),
  is_custom BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE meal_food_items (
  meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
  food_item_id UUID NOT NULL REFERENCES food_items(id),
  quantity DECIMAL(4,2) NOT NULL,
  PRIMARY KEY (meal_id, food_item_id)
);

CREATE INDEX idx_nutrition_plans_coach ON nutrition_plans(created_by);
CREATE INDEX idx_nutrition_plans_user ON nutrition_plans(assigned_to);
CREATE INDEX idx_meals_plan ON meals(plan_id);
```

---

## 8. Messaging Models

### 8.1 Message

**Purpose**: Chat message between user and coach

```typescript
interface Message {
  id: string;                          // UUID
  conversationId: string;              // FK to Conversation.id
  
  // Sender
  senderId: string;                    // User or Coach ID
  senderType: 'user' | 'coach';
  
  // Content
  type: MessageType;                   // 'text' | 'image' | 'file'
  content: string;                     // Text content or file URL
  fileName?: string;                   // For attachments
  fileSize?: number;                   // bytes
  
  // Status
  isRead: boolean;
  readAt?: Date;
  
  // Metadata
  createdAt: Date;
}
```

---

### 8.2 Conversation

**Purpose**: Message thread between user and coach

```typescript
interface Conversation {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  coachId: string;                     // FK to CoachProfile.id
  
  // Status
  isActive: boolean;
  
  // Tracking
  lastMessageAt: Date;
  lastMessagePreview: string;          // First 100 chars of last message
  unreadCount: number;                 // For user or coach
  
  // Rating (v2.0)
  lastRatedAt?: Date;                  // When user last rated this coach
  messagesSinceRating: number;         // Counter for rating prompt (every 10)
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  coach_id UUID NOT NULL REFERENCES coaches(id),
  is_active BOOLEAN DEFAULT TRUE,
  last_message_at TIMESTAMP,
  last_message_preview TEXT,
  unread_count INTEGER DEFAULT 0,
  last_rated_at TIMESTAMP,
  messages_since_rating INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, coach_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id),
  sender_type VARCHAR(10) NOT NULL,
  type VARCHAR(10) NOT NULL DEFAULT 'text',
  content TEXT NOT NULL,
  file_name VARCHAR(255),
  file_size INTEGER,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_coach ON conversations(coach_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created ON messages(created_at);
```

---

## 9. Video Call Models (v2.0)

### 9.1 Video Call

**Purpose**: Scheduled or completed video training session

```typescript
interface VideoCall {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  coachId: string;                     // FK to CoachProfile.id
  
  // Scheduling
  scheduledAt: Date;
  duration: number;                    // minutes (15 or 25 based on tier)
  status: CallStatus;                  // 'scheduled' | 'in_progress' | 'completed' | 'cancelled'
  
  // Completion
  actualDuration?: number;             // minutes (if different from scheduled)
  startedAt?: Date;
  endedAt?: Date;
  
  // Video Platform
  meetingUrl?: string;                 // Agora/Twilio room URL
  meetingId?: string;                  // External platform ID
  
  // Rating (v2.0)
  rating?: number;                     // 1-5 stars
  ratingComment?: string;
  ratedAt?: Date;
  
  // Notes
  coachNotes?: string;
  userNotes?: string;
  
  // Cancellation
  cancelledBy?: string;                // User or Coach ID
  cancelledAt?: Date;
  cancellationReason?: string;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE video_calls (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  coach_id UUID NOT NULL REFERENCES coaches(id),
  scheduled_at TIMESTAMP NOT NULL,
  duration INTEGER NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
  actual_duration INTEGER,
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  meeting_url TEXT,
  meeting_id VARCHAR(255),
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  rating_comment TEXT,
  rated_at TIMESTAMP,
  coach_notes TEXT,
  user_notes TEXT,
  cancelled_by UUID REFERENCES users(id),
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_video_calls_user ON video_calls(user_id);
CREATE INDEX idx_video_calls_coach ON video_calls(coach_id);
CREATE INDEX idx_video_calls_scheduled ON video_calls(scheduled_at);
CREATE INDEX idx_video_calls_status ON video_calls(status);
```

---

## 10. Rating Models (v2.0)

### 10.1 Coach Rating

**Purpose**: Post-interaction quality ratings

```typescript
interface CoachRating {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  coachId: string;                     // FK to CoachProfile.id
  
  // Rating
  rating: number;                      // 1-5 stars
  comment?: string;                    // Optional feedback
  
  // Context
  interactionType: 'video_call' | 'messaging';
  relatedVideoCallId?: string;         // FK to VideoCall.id (if applicable)
  relatedConversationId?: string;      // FK to Conversation.id (if applicable)
  
  // Metadata
  createdAt: Date;
}
```

---

### 10.2 Trainer Rating

**Purpose**: Rate quality of generated plans

```typescript
interface TrainerRating {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  
  // Rating
  rating: number;                      // 1-5 stars
  comment?: string;
  
  // Context
  planType: 'workout' | 'nutrition';
  relatedPlanId?: string;              // FK to WorkoutPlan.id or NutritionPlan.id
  
  // Metadata
  createdAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE coach_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  coach_id UUID NOT NULL REFERENCES coaches(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  interaction_type VARCHAR(20) NOT NULL,
  related_video_call_id UUID REFERENCES video_calls(id),
  related_conversation_id UUID REFERENCES conversations(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE trainer_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  plan_type VARCHAR(20) NOT NULL,
  related_plan_id UUID,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_coach_ratings_coach ON coach_ratings(coach_id);
CREATE INDEX idx_coach_ratings_user ON coach_ratings(user_id);
CREATE INDEX idx_trainer_ratings_user ON trainer_ratings(user_id);
```

---

## 11. E-Commerce Models

### 11.1 Product

**Purpose**: Fitness products and supplements for sale

```typescript
interface Product {
  id: string;                          // UUID
  name: string;
  nameArabic: string;
  description: string;
  descriptionArabic: string;
  
  // Pricing
  price: number;                       // SAR
  compareAtPrice?: number;             // Original price (if on sale)
  
  // Inventory
  stockQuantity: number;
  isInStock: boolean;
  lowStockThreshold: number;
  
  // Media
  imageUrl: string;
  additionalImages?: string[];
  
  // Category
  category: string;                    // 'supplement', 'equipment', 'apparel', etc.
  tags: string[];
  
  // Ratings
  averageRating: number;               // 0-5
  totalRatings: number;
  totalSales: number;
  
  // Status
  isActive: boolean;
  isFeatured: boolean;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}
```

---

### 11.2 Order

**Purpose**: User purchase transaction

```typescript
interface Order {
  id: string;                          // UUID
  orderNumber: string;                 // Human-readable (e.g., 'ORD-2024-00123')
  userId: string;                      // FK to UserProfile.id
  
  // Items
  items: OrderItem[];
  
  // Pricing
  subtotal: number;                    // SAR
  tax: number;                         // 15% VAT in Saudi
  shippingFee: number;
  discount: number;
  total: number;
  
  // Payment
  paymentStatus: PaymentStatus;        // 'pending' | 'completed' | 'failed' | 'refunded'
  paymentMethod: string;               // 'credit_card', 'apple_pay', 'mada', etc.
  paymentTransactionId?: string;
  paidAt?: Date;
  
  // Fulfillment
  status: OrderStatus;                 // 'processing' | 'shipped' | 'delivered' | 'cancelled'
  shippingAddress: Address;
  trackingNumber?: string;
  shippedAt?: Date;
  deliveredAt?: Date;
  
  // Cancellation
  cancelledAt?: Date;
  cancellationReason?: string;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}
```

---

### 11.3 Order Item

**Purpose**: Individual product within an order

```typescript
interface OrderItem {
  id: string;                          // UUID
  orderId: string;                     // FK to Order.id
  productId: string;                   // FK to Product.id
  
  // Snapshot (in case product changes later)
  productName: string;
  productNameArabic: string;
  productImageUrl: string;
  
  // Pricing
  quantity: number;
  unitPrice: number;                   // SAR
  totalPrice: number;                  // quantity * unitPrice
}
```

---

### 11.4 Address

**Purpose**: Shipping address

```typescript
interface Address {
  fullName: string;
  phoneNumber: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;                     // Default: 'Saudi Arabia'
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  name_arabic VARCHAR(255),
  description TEXT,
  description_arabic TEXT,
  price DECIMAL(10,2) NOT NULL,
  compare_at_price DECIMAL(10,2),
  stock_quantity INTEGER DEFAULT 0,
  is_in_stock BOOLEAN DEFAULT TRUE,
  low_stock_threshold INTEGER DEFAULT 10,
  image_url TEXT NOT NULL,
  additional_images TEXT[],
  category VARCHAR(50),
  tags TEXT[],
  average_rating DECIMAL(2,1) DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(50) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id),
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) NOT NULL,
  shipping_fee DECIMAL(10,2) DEFAULT 0,
  discount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  payment_status VARCHAR(20) NOT NULL,
  payment_method VARCHAR(50),
  payment_transaction_id VARCHAR(255),
  paid_at TIMESTAMP,
  status VARCHAR(20) NOT NULL,
  shipping_address JSONB NOT NULL,
  tracking_number VARCHAR(100),
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  product_name VARCHAR(255) NOT NULL,
  product_name_arabic VARCHAR(255),
  product_image_url TEXT,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
```

---

## 12. Progress Tracking Models

### 12.1 Weight Entry

**Purpose**: User weight tracking over time

```typescript
interface WeightEntry {
  id: string;                          // UUID
  userId: string;                      // FK to UserProfile.id
  weight: number;                      // kg
  date: Date;
  notes?: string;
  createdAt: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE weight_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  weight DECIMAL(5,2) NOT NULL,
  date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_weight_entries_user ON weight_entries(user_id);
CREATE INDEX idx_weight_entries_date ON weight_entries(date);
```

---

## 13. Admin & System Models

### 13.1 Audit Log

**Purpose**: Track administrative actions and system events

```typescript
interface AuditLog {
  id: string;                          // UUID
  
  // Who
  userId?: string;                     // FK to UserProfile.id (nullable for system events)
  userType?: UserType;                 // 'user' | 'coach' | 'admin'
  
  // What
  action: string;                      // e.g., 'user_created', 'subscription_upgraded', 'coach_suspended'
  entity: string;                      // e.g., 'User', 'Coach', 'Product'
  entityId?: string;                   // ID of affected entity
  
  // Details
  changes?: Record<string, any>;       // JSON of what changed
  metadata?: Record<string, any>;      // Additional context
  
  // When & Where
  ipAddress?: string;
  userAgent?: string;
  timestamp: Date;
}
```

**Database Schema (SQL)**:
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  user_type VARCHAR(10),
  action VARCHAR(100) NOT NULL,
  entity VARCHAR(50) NOT NULL,
  entity_id UUID,
  changes JSONB,
  metadata JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
```

---

### 13.2 System Settings

**Purpose**: Platform-wide configuration

```typescript
interface SystemSettings {
  id: string;
  key: string;                         // Unique setting key
  value: string | number | boolean;    // Setting value
  description?: string;
  category: string;                    // 'subscription', 'features', 'limits', etc.
  isEditable: boolean;                 // Can admin change this?
  updatedAt: Date;
  updatedBy?: string;                  // Admin user ID
}
```

**Example Settings**:
```typescript
const DEFAULT_SYSTEM_SETTINGS = [
  { key: 'freemium_nutrition_trial_days', value: 7, category: 'subscription' },
  { key: 'freemium_message_limit', value: 20, category: 'subscription' },
  { key: 'premium_message_limit', value: 200, category: 'subscription' },
  { key: 'enable_chat_attachments', value: true, category: 'features' },
  { key: 'max_inbody_scans_per_user', value: 100, category: 'limits' },
  { key: 'platform_commission_rate', value: 0.30, category: 'business' },
  { key: 'vat_rate_saudi', value: 0.15, category: 'business' },
];
```

**Database Schema (SQL)**:
```sql
CREATE TABLE system_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  category VARCHAR(50),
  is_editable BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID REFERENCES users(id)
);
```

---

## 14. Application State Models

### 14.1 AppState

**Purpose**: Client-side application state (React context)

```typescript
interface AppState {
  // Authentication
  isAuthenticated: boolean;
  isDemoMode: boolean;
  
  // User Context
  userType: UserType;                  // 'user' | 'coach' | 'admin'
  userProfile: UserProfile | null;
  
  // Navigation
  currentScreen: Screen;
  previousScreen?: Screen;             // For back navigation
  
  // Onboarding
  hasCompletedOnboarding: boolean;
  hasSeenIntro: boolean;
  
  // Intake
  firstIntakeData: FirstIntakeData | null;
}
```

---

## 15. Injury Substitution Models (v2.0)

### 15.1 Injury Rule

**Purpose**: Define contraindicated exercises and safe alternatives

```typescript
interface InjuryRule {
  injuryCode: InjuryArea;              // 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle'
  displayName: string;                 // Human-readable name
  avoidKeywords: string[];             // Exercise names to flag (e.g., ['squat', 'lunge'])
  substitutes: ExerciseSubstitute[];   // Safe alternatives
}
```

---

### 15.2 Exercise Substitute

**Purpose**: Replacement exercise details

```typescript
interface ExerciseSubstitute {
  originalCategory: string;            // Type of exercise being replaced
  replacementExercises: string[];      // List of safe alternatives
  targetMuscles: string[];             // Which muscles are targeted
  movementPattern: string;             // Type of movement
  reasoning: string;                   // Why this is a safe substitute
}
```

---

### 15.3 Substitution Result

**Purpose**: Outcome of substitution check

```typescript
interface SubstitutionResult {
  wasSubstituted: boolean;
  originalExercise?: string;
  newExercise?: string;
  reason?: string;
  injuryCode?: InjuryArea;
}
```

**Example Injury Rules**:
```typescript
const INJURY_RULES: InjuryRule[] = [
  {
    injuryCode: 'knee',
    displayName: 'Knee',
    avoidKeywords: ['squat', 'lunge', 'jump', 'leg press'],
    substitutes: [
      {
        originalCategory: 'quad_compound',
        replacementExercises: ['Leg Extension', 'Wall Sit', 'Bulgarian Split Squat (shallow)'],
        targetMuscles: ['quadriceps'],
        movementPattern: 'knee_extension',
        reasoning: 'Reduced knee loading while maintaining quad stimulus'
      }
    ]
  },
  // ... more rules for other injuries
];
```

---

## 16. Translation System Models

### 16.1 Translation Key Structure

**Purpose**: Organize 2,904 translation keys

```typescript
interface Translations {
  common: {
    back: string;
    next: string;
    save: string;
    cancel: string;
    // ... more common keys
  };
  auth: {
    phoneNumber: string;
    enterOTP: string;
    // ... auth-specific keys
  };
  workout: {
    title: string;
    exercises: string;
    // ... workout-specific keys
  };
  // ... more namespaces
}
```

**Storage**: Exported separately in `/components/translations-data.ts` for code-splitting

---

## 17. Data Relationships Diagram

```
┌─────────────┐
│    User     │──────┬──────────────┐
└─────────────┘      │              │
       │             │              │
       │             ▼              ▼
       │      ┌───────────┐  ┌──────────────┐
       │      │   Coach   │  │ QuotaUsage   │
       │      └───────────┘  └──────────────┘
       │             │
       │             ├──────────────┐
       │             │              │
       │             ▼              ▼
       │      ┌─────────────┐ ┌──────────────┐
       │      │ WorkoutPlan │ │NutritionPlan │
       │      └─────────────┘ └──────────────┘
       │             │              │
       │             ▼              ▼
       │      ┌─────────────┐ ┌──────────┐
       │      │   Workout   │ │   Meal   │
       │      └─────────────┘ └──────────┘
       │             │              │
       │             ▼              ▼
       │      ┌──────────────┐ ┌──────────┐
       │      │WorkoutExercise│ │FoodItem  │
       │      └──────────────┘ └──────────┘
       │
       ├──────────────┬──────────────┬──────────────┐
       │              │              │              │
       ▼              ▼              ▼              ▼
┌──────────┐  ┌──────────────┐ ┌───────────┐ ┌──────────┐
│ Message  │  │  VideoCall   │ │   Order   │ │ InBody   │
└──────────┘  └──────────────┘ └───────────┘ └──────────┘
       │              │              │              
       ▼              ▼              ▼              
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│Conversation  │ │  Rating  │ │  OrderItem   │
└──────────────┘ └──────────┘ └──────────────┘
```

---

## 18. Index Strategy

### 18.1 Critical Indexes
```sql
-- User lookups
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_coach ON users(coach_id);
CREATE INDEX idx_users_tier ON users(subscription_tier);

-- Workout queries
CREATE INDEX idx_workouts_plan ON workouts(plan_id);
CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);

-- Message queries
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created ON messages(created_at);

-- Order queries
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Audit logs
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
```

---

## 19. Migration Checklist

When migrating this data model to another platform/language:

### Phase 1: Core Models
- [ ] User & Authentication (UserProfile, OTPSession)
- [ ] Subscription & Quotas (QuotaLimits, QuotaUsage)
- [ ] Intake System (FirstIntakeData, SecondIntakeData)

### Phase 2: Content Models
- [ ] Exercise Library (Exercise)
- [ ] Workout System (WorkoutPlan, Workout, WorkoutExercise)
- [ ] Nutrition System (NutritionPlan, Meal, FoodItem)

### Phase 3: Interaction Models
- [ ] Messaging (Message, Conversation)
- [ ] Video Calls (VideoCall)
- [ ] Ratings (CoachRating, TrainerRating)

### Phase 4: Business Models
- [ ] E-Commerce (Product, Order, OrderItem)
- [ ] Progress Tracking (WeightEntry, InBodyData)
- [ ] Coach System (CoachProfile, Earnings)

### Phase 5: Admin Models
- [ ] Audit Logs
- [ ] System Settings

### Phase 6: Business Logic
- [ ] Quota enforcement algorithms
- [ ] Injury substitution engine
- [ ] Nutrition expiry calculation
- [ ] Rating trigger logic

---

**End of Data Models Document**

*Next: See 03-SCREEN-SPECIFICATIONS.md for detailed UI requirements*
