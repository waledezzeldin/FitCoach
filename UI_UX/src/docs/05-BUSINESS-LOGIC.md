# FitCoach+ v2.0 - Business Logic & Algorithms

## Document Information
- **Document**: Core Business Logic and Algorithms
- **Version**: 2.0.0
- **Last Updated**: December 8, 2024
- **Purpose**: Implementation details for key business rules and calculations

---

## Table of Contents

1. Fitness Score Calculation
2. Injury Substitution Engine
3. Nutrition Macro Calculation
4. Calorie Burn Estimation
5. Workout Plan Generation Logic
6. Coach Matching Algorithm
7. Progress Tracking Calculations
8. Subscription Pricing Logic
9. Rating Aggregation
10. Notification Triggers

---

## 1. Fitness Score Calculation

### Purpose
Auto-calculate a user's fitness level (0-100) based on intake data to personalize workout difficulty and track improvement over time.

### Input Data
```typescript
interface FitnessScoreInputs {
  age: number;                         // 13-120
  experienceLevel: ExperienceLevel;    // beginner/intermediate/advanced
  workoutFrequency: number;            // 2-6 days/week
  injuries: InjuryArea[];              // Array of injuries
  weight?: number;                     // Optional, for BMI consideration
  height?: number;                     // Optional, for BMI consideration
}
```

### Algorithm

```typescript
function calculateFitnessScore(data: SecondIntakeData): number {
  let score = 50; // Base score (neutral starting point)
  
  // 1. Experience Level Contribution (0-30 points)
  switch (data.experienceLevel) {
    case 'beginner':
      score += 0;   // No bonus for beginners
      break;
    case 'intermediate':
      score += 15;  // Moderate fitness level
      break;
    case 'advanced':
      score += 30;  // High fitness level
      break;
  }
  
  // 2. Workout Frequency Contribution (0-12 points)
  // 2 days = 0 points, 3 days = 3 points, 4 days = 6 points, etc.
  const frequencyBonus = (data.workoutFrequency - 2) * 3;
  score += frequencyBonus;
  
  // 3. Age Factor (-10 to +5 points)
  // Optimal age: 20-35 (no penalty)
  // Under 20: -5 points (still developing)
  // Over 45: -1 point per 5 years (natural decline)
  if (data.age < 20) {
    score -= 5;
  } else if (data.age > 45) {
    const ageDecline = Math.floor((data.age - 45) / 5);
    score -= ageDecline;
  }
  
  // 4. Injury Penalty (-5 points per injury, max -20)
  const injuryPenalty = Math.min(data.injuries.length * 5, 20);
  score -= injuryPenalty;
  
  // 5. BMI Factor (Optional, if height/weight provided)
  if (data.weight && data.height) {
    const bmi = calculateBMI(data.weight, data.height);
    
    // Optimal BMI: 20-25 (no adjustment)
    // Underweight (<18.5): -10 points
    // Overweight (25-30): -5 points
    // Obese (>30): -10 points
    if (bmi < 18.5) {
      score -= 10;
    } else if (bmi >= 25 && bmi < 30) {
      score -= 5;
    } else if (bmi >= 30) {
      score -= 10;
    }
  }
  
  // 6. Clamp score to 0-100 range
  return Math.max(0, Math.min(100, Math.round(score)));
}

function calculateBMI(weightKg: number, heightCm: number): number {
  const heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}
```

### Score Interpretation

```typescript
function getFitnessLevel(score: number): {
  level: string;
  description: string;
  color: string;
} {
  if (score >= 80) {
    return {
      level: 'Elite',
      description: 'Outstanding fitness level with advanced training experience',
      color: '#10B981' // green
    };
  } else if (score >= 65) {
    return {
      level: 'Advanced',
      description: 'Strong fitness foundation with consistent training',
      color: '#3B82F6' // blue
    };
  } else if (score >= 50) {
    return {
      level: 'Intermediate',
      description: 'Moderate fitness level with room for improvement',
      color: '#F59E0B' // amber
    };
  } else if (score >= 30) {
    return {
      level: 'Beginner',
      description: 'Building fitness foundation, focus on consistency',
      color: '#F97316' // orange
    };
  } else {
    return {
      level: 'Novice',
      description: 'Starting fitness journey, gradual progression recommended',
      color: '#EF4444' // red
    };
  }
}
```

### Coach Override

```typescript
async function updateFitnessScoreByCoach(
  userId: string,
  coachId: string,
  newScore: number,
  reason?: string
): Promise<void> {
  // Validate coach permission
  const user = await database.users.findById(userId);
  if (user.coachId !== coachId) {
    throw new Error('Coach not assigned to this user');
  }
  
  // Validate score range
  if (newScore < 0 || newScore > 100) {
    throw new Error('Score must be between 0 and 100');
  }
  
  // Update score
  await database.users.update(userId, {
    fitnessScore: newScore,
    fitnessScoreUpdatedBy: 'coach',
    fitnessScoreLastUpdated: new Date()
  });
  
  // Log the change
  await database.auditLogs.create({
    userId: coachId,
    action: 'fitness_score_updated',
    entity: 'User',
    entityId: userId,
    changes: {
      newScore,
      reason,
      method: 'coach_override'
    }
  });
  
  // Notify user
  await sendNotification(userId, {
    title: 'Fitness Score Updated',
    message: `Your coach updated your fitness score to ${newScore}/100`
  });
}
```

---

## 2. Injury Substitution Engine

### Purpose
Automatically detect exercises that may aggravate user injuries and suggest safe alternatives that maintain muscle stimulus while reducing risk.

### Injury Rules Database

```typescript
const INJURY_RULES: InjuryRule[] = [
  {
    injuryCode: 'knee',
    displayName: 'Knee',
    avoidKeywords: ['squat', 'lunge', 'jump', 'leg press', 'step up', 'pistol'],
    substitutes: [
      {
        originalCategory: 'quad_compound',
        replacementExercises: [
          'Leg Extension',
          'Bulgarian Split Squat (shallow)',
          'Wall Sit',
          'Seated Leg Curl'
        ],
        targetMuscles: ['quadriceps'],
        movementPattern: 'knee_extension',
        reasoning: 'Reduced knee loading while maintaining quad stimulus'
      },
      {
        originalCategory: 'leg_compound',
        replacementExercises: [
          'Glute Bridge',
          'Hip Thrust',
          'Romanian Deadlift (light)',
          'Cable Pull-through'
        ],
        targetMuscles: ['glutes', 'hamstrings'],
        movementPattern: 'hip_hinge',
        reasoning: 'Minimal knee flexion with posterior chain emphasis'
      }
    ]
  },
  // ... additional injury rules for shoulder, lower_back, neck, ankle
];
```

### Exercise Contraindication Check

```typescript
function shouldSubstituteExercise(
  exerciseName: string,
  userInjuries: InjuryArea[]
): {
  shouldSub: boolean;
  injury?: InjuryArea;
  rule?: InjuryRule;
} {
  // Check each injury the user has
  for (const injury of userInjuries) {
    const rule = findInjuryRule(injury);
    if (!rule) continue;
    
    // Normalize exercise name for comparison
    const lowerExercise = exerciseName.toLowerCase();
    
    // Check if exercise contains any avoid keywords
    const hasKeyword = rule.avoidKeywords.some(keyword =>
      lowerExercise.includes(keyword.toLowerCase())
    );
    
    if (hasKeyword) {
      return {
        shouldSub: true,
        injury,
        rule
      };
    }
  }
  
  return { shouldSub: false };
}
```

### Find Safe Alternatives

```typescript
function findSafeAlternatives(
  originalExerciseId: string,
  injuryArea: InjuryArea,
  targetMuscleGroup?: string
): Exercise[] {
  const rule = findInjuryRule(injuryArea);
  if (!rule) return [];
  
  const alternatives: Exercise[] = [];
  
  // Collect all replacement exercises from all substitute categories
  rule.substitutes.forEach(substitute => {
    // If target muscle specified, filter by muscle group
    if (targetMuscleGroup) {
      const muscleMatch = substitute.targetMuscles.some(muscle =>
        muscle.toLowerCase().includes(targetMuscleGroup.toLowerCase())
      );
      if (!muscleMatch) return; // Skip this substitute group
    }
    
    // Create exercise objects from replacement names
    substitute.replacementExercises.forEach(exerciseName => {
      // Look up full exercise details from database
      const exercise = exerciseDatabase.find(ex =>
        ex.name.toLowerCase() === exerciseName.toLowerCase()
      );
      
      if (exercise) {
        alternatives.push({
          ...exercise,
          substitutionReasoning: substitute.reasoning
        });
      }
    });
  });
  
  return alternatives;
}
```

### Apply Substitution to Workout

```typescript
async function substituteExerciseInWorkout(
  workoutId: string,
  originalExerciseId: string,
  newExerciseId: string,
  reason: string
): Promise<WorkoutExercise> {
  // Find the workout exercise
  const workoutExercise = await database.workoutExercises.findOne({
    workoutId,
    exerciseId: originalExerciseId
  });
  
  if (!workoutExercise) {
    throw new Error('Exercise not found in workout');
  }
  
  // Update exercise with substitution
  const updated = await database.workoutExercises.update(workoutExercise.id, {
    exerciseId: newExerciseId,
    isSubstituted: true,
    originalExerciseId,
    substitutionReason: reason
  });
  
  // Log event
  await analytics.track('exercise_substituted', {
    workoutId,
    originalExerciseId,
    newExerciseId,
    reason
  });
  
  return updated;
}
```

### Real-Time Substitution Flow

```
User Opens Workout Screen
         ↓
   Load Workout Plan
         ↓
For Each Exercise in Plan:
   Check Against User Injuries
         ↓
   Contraindication Found?
    ┌──────┴──────┐
    ↓             ↓
   Yes           No
    ↓             ↓
Flag Exercise  Continue
with Warning
    ↓
Show "⚠️ Injury Alert" Badge
    ↓
Auto-Open Alternatives Modal
    ↓
Display 3-5 Safe Alternatives
    ↓
User Selects Preferred Exercise
    ↓
Apply Substitution to Workout
    ↓
Update Exercise List
    ↓
Continue Workout
```

---

## 3. Nutrition Macro Calculation

### Purpose
Calculate personalized daily macronutrient targets based on user goals, activity level, and body composition.

### Input Data
```typescript
interface MacroCalculationInputs {
  weight: number;              // kg
  height: number;              // cm
  age: number;
  gender: Gender;
  mainGoal: MainGoal;          // fat_loss | muscle_gain | general_fitness
  activityLevel: number;       // 1-5 (sedentary to very active)
  workoutFrequency: number;    // 2-6 days/week
}
```

### Algorithm

```typescript
function calculateMacros(data: MacroCalculationInputs): {
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
} {
  // 1. Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  let bmr: number;
  
  if (data.gender === 'male') {
    bmr = (10 * data.weight) + (6.25 * data.height) - (5 * data.age) + 5;
  } else {
    bmr = (10 * data.weight) + (6.25 * data.height) - (5 * data.age) - 161;
  }
  
  // 2. Calculate Total Daily Energy Expenditure (TDEE)
  // Activity multipliers based on workout frequency
  const activityMultiplier = getActivityMultiplier(data.workoutFrequency);
  const tdee = bmr * activityMultiplier;
  
  // 3. Adjust calories based on goal
  let targetCalories: number;
  
  switch (data.mainGoal) {
    case 'fat_loss':
      // 20% caloric deficit
      targetCalories = tdee * 0.80;
      break;
      
    case 'muscle_gain':
      // 10% caloric surplus
      targetCalories = tdee * 1.10;
      break;
      
    case 'general_fitness':
      // Maintenance calories
      targetCalories = tdee;
      break;
  }
  
  // 4. Calculate protein target
  // Fat loss: 2.2g/kg, Muscle gain: 2.0g/kg, Maintenance: 1.8g/kg
  let proteinMultiplier: number;
  switch (data.mainGoal) {
    case 'fat_loss':
      proteinMultiplier = 2.2;
      break;
    case 'muscle_gain':
      proteinMultiplier = 2.0;
      break;
    case 'general_fitness':
      proteinMultiplier = 1.8;
      break;
  }
  const proteinGrams = Math.round(data.weight * proteinMultiplier);
  const proteinCalories = proteinGrams * 4; // 4 cal/g
  
  // 5. Calculate fat target
  // 25-30% of total calories
  const fatPercentage = 0.27;
  const fatCalories = targetCalories * fatPercentage;
  const fatGrams = Math.round(fatCalories / 9); // 9 cal/g
  
  // 6. Calculate carbs (remaining calories)
  const carbCalories = targetCalories - proteinCalories - fatCalories;
  const carbGrams = Math.round(carbCalories / 4); // 4 cal/g
  
  return {
    calories: Math.round(targetCalories),
    protein: proteinGrams,
    carbs: carbGrams,
    fats: fatGrams
  };
}

function getActivityMultiplier(workoutFrequency: number): number {
  // Based on number of workout days per week
  switch (workoutFrequency) {
    case 2:
      return 1.375; // Lightly active
    case 3:
      return 1.465;
    case 4:
      return 1.55;  // Moderately active
    case 5:
      return 1.635;
    case 6:
      return 1.725; // Very active
    default:
      return 1.55;
  }
}
```

### Macro Distribution by Goal

```typescript
// Typical macro ratios (as % of calories)
const MACRO_RATIOS = {
  fat_loss: {
    protein: 35,  // High protein for satiety
    carbs: 35,    // Moderate carbs
    fats: 30      // Moderate fats
  },
  muscle_gain: {
    protein: 30,  // High protein for growth
    carbs: 45,    // High carbs for energy
    fats: 25      // Lower fats
  },
  general_fitness: {
    protein: 30,
    carbs: 40,
    fats: 30
  }
};
```

---

## 4. Calorie Burn Estimation

### Purpose
Estimate calories burned during workouts to track energy expenditure and progress.

### Algorithm

```typescript
function estimateCaloriesBurned(
  exerciseType: string,
  durationMinutes: number,
  userWeight: number,
  intensity: 'low' | 'moderate' | 'high'
): number {
  // MET (Metabolic Equivalent of Task) values
  const MET_VALUES = {
    'strength_training': {
      low: 3.5,
      moderate: 5.0,
      high: 6.0
    },
    'cardio': {
      low: 5.0,
      moderate: 7.0,
      high: 10.0
    },
    'hiit': {
      low: 8.0,
      moderate: 10.0,
      high: 12.0
    }
  };
  
  // Get MET value for exercise type and intensity
  const met = MET_VALUES[exerciseType]?.[intensity] || 5.0;
  
  // Calories = MET × weight (kg) × time (hours)
  const hours = durationMinutes / 60;
  const calories = met * userWeight * hours;
  
  return Math.round(calories);
}

// Workout-specific estimation
function estimateWorkoutCalories(
  workout: Workout,
  userProfile: UserProfile
): number {
  let totalCalories = 0;
  
  workout.exercises.forEach(exercise => {
    // Calculate work time (sets × reps × ~3 seconds per rep)
    const avgReps = parseReps(exercise.reps); // e.g., "8-12" → 10
    const workTime = exercise.sets * avgReps * 3 / 60; // minutes
    
    // Add rest time
    const totalRestTime = (exercise.sets - 1) * (exercise.restTime / 60); // minutes
    
    const exerciseDuration = workTime + totalRestTime;
    
    // Determine intensity based on exercise type
    const intensity = exercise.muscleGroup === 'cardio' ? 'high' : 'moderate';
    
    // Calculate calories for this exercise
    const exerciseCalories = estimateCaloriesBurned(
      'strength_training',
      exerciseDuration,
      userProfile.weight,
      intensity
    );
    
    totalCalories += exerciseCalories;
  });
  
  return Math.round(totalCalories);
}
```

---

## 5. Workout Plan Generation Logic

### Purpose
Generate personalized workout plans based on user goals, experience level, available equipment, and training frequency.

### Algorithm

```typescript
async function generateWorkoutPlan(
  user: UserProfile,
  duration: number // weeks
): Promise<WorkoutPlan> {
  const { mainGoal, experienceLevel, workoutFrequency, workoutLocation, injuries } = user;
  
  // 1. Determine training split based on frequency
  const split = getTrainingSplit(workoutFrequency, experienceLevel);
  
  // 2. Select exercises for each muscle group
  const exercisePool = await getExercisePool(workoutLocation, injuries);
  
  // 3. Build weekly template
  const weeklyWorkouts: Workout[] = [];
  
  for (let day = 1; day <= workoutFrequency; day++) {
    const muscleGroups = split[day - 1];
    const exercises = selectExercises(
      exercisePool,
      muscleGroups,
      experienceLevel,
      mainGoal
    );
    
    weeklyWorkouts.push({
      id: generateUUID(),
      dayNumber: day,
      name: getDayName(muscleGroups),
      exercises,
      estimatedDuration: calculateDuration(exercises)
    });
  }
  
  // 4. Duplicate weekly template for program duration
  const allWorkouts: Workout[] = [];
  for (let week = 1; week <= duration; week++) {
    weeklyWorkouts.forEach(workout => {
      allWorkouts.push({
        ...workout,
        id: generateUUID(),
        weekNumber: week,
        // Progressive overload: increase reps or weight each week
        exercises: applyProgressiveOverload(workout.exercises, week)
      });
    });
  }
  
  return {
    id: generateUUID(),
    name: `${duration}-Week ${mainGoal.replace('_', ' ')} Program`,
    userId: user.id,
    durationWeeks: duration,
    workoutsPerWeek: workoutFrequency,
    goal: mainGoal,
    level: experienceLevel,
    workouts: allWorkouts,
    isActive: true
  };
}

function getTrainingSplit(
  frequency: number,
  level: ExperienceLevel
): string[][] {
  // Training splits by frequency
  const SPLITS = {
    2: [['full_body'], ['full_body']],
    3: [['push'], ['pull'], ['legs']],
    4: [['upper'], ['lower'], ['upper'], ['lower']],
    5: [['chest_triceps'], ['back_biceps'], ['legs'], ['shoulders'], ['full_body']],
    6: [['chest'], ['back'], ['legs'], ['shoulders'], ['arms'], ['cardio_core']]
  };
  
  return SPLITS[frequency] || SPLITS[3];
}
```

---

## 6. Coach Matching Algorithm

### Purpose
Match users with compatible coaches based on specialties, availability, ratings, and user preferences.

### Algorithm

```typescript
interface CoachMatch {
  coach: CoachProfile;
  score: number;
  reasons: string[];
}

async function findBestCoaches(
  user: UserProfile,
  limit: number = 5
): Promise<CoachMatch[]> {
  // Get all active coaches
  const coaches = await database.coaches.find({
    approvalStatus: 'approved',
    isAcceptingClients: true,
    activeClients: { $lt: database.Raw('max_clients') }
  });
  
  // Score each coach
  const matches: CoachMatch[] = coaches.map(coach => {
    let score = 0;
    const reasons: string[] = [];
    
    // 1. Specialty match (0-40 points)
    const specialtyMatch = hasSpecialtyMatch(coach, user);
    if (specialtyMatch) {
      score += 40;
      reasons.push(`Specializes in ${specialtyMatch}`);
    }
    
    // 2. Rating (0-30 points)
    const ratingScore = (coach.averageRating / 5) * 30;
    score += ratingScore;
    if (coach.averageRating >= 4.5) {
      reasons.push(`Highly rated (${coach.averageRating}/5)`);
    }
    
    // 3. Experience (0-20 points)
    const expScore = Math.min(coach.yearsExperience * 2, 20);
    score += expScore;
    if (coach.yearsExperience >= 5) {
      reasons.push(`${coach.yearsExperience} years experience`);
    }
    
    // 4. Availability (0-10 points)
    const capacity = coach.maxClients - coach.activeClients;
    const availabilityScore = (capacity / coach.maxClients) * 10;
    score += availabilityScore;
    
    return {
      coach,
      score,
      reasons
    };
  });
  
  // Sort by score descending
  matches.sort((a, b) => b.score - a.score);
  
  // Return top N matches
  return matches.slice(0, limit);
}

function hasSpecialtyMatch(
  coach: CoachProfile,
  user: UserProfile
): string | null {
  const goalToSpecialty = {
    'fat_loss': 'Weight Loss',
    'muscle_gain': 'Muscle Building',
    'general_fitness': 'General Fitness'
  };
  
  const desiredSpecialty = goalToSpecialty[user.mainGoal];
  
  if (coach.specialties.includes(desiredSpecialty)) {
    return desiredSpecialty;
  }
  
  return null;
}
```

---

## 7. Progress Tracking Calculations

### Purpose
Calculate progress metrics and trends from user data over time.

### Weight Loss/Gain Tracking

```typescript
interface ProgressStats {
  currentWeight: number;
  startingWeight: number;
  weightChange: number;
  weeklyAverage: number;
  trend: 'improving' | 'stable' | 'declining';
  projectedGoal: Date | null;
}

function calculateWeightProgress(
  entries: WeightEntry[],
  goal: MainGoal,
  targetWeight?: number
): ProgressStats {
  if (entries.length === 0) {
    return {
      currentWeight: 0,
      startingWeight: 0,
      weightChange: 0,
      weeklyAverage: 0,
      trend: 'stable',
      projectedGoal: null
    };
  }
  
  // Sort by date
  entries.sort((a, b) => a.date.getTime() - b.date.getTime());
  
  const startingWeight = entries[0].weight;
  const currentWeight = entries[entries.length - 1].weight;
  const weightChange = currentWeight - startingWeight;
  
  // Calculate weekly average change
  const daysTracked = Math.floor(
    (entries[entries.length - 1].date.getTime() - entries[0].date.getTime()) / (1000 * 60 * 60 * 24)
  );
  const weeksTracked = daysTracked / 7;
  const weeklyAverage = weeksTracked > 0 ? weightChange / weeksTracked : 0;
  
  // Determine trend based on goal
  let trend: 'improving' | 'stable' | 'declining' = 'stable';
  
  if (goal === 'fat_loss') {
    if (weeklyAverage < -0.3) trend = 'improving'; // Losing weight
    else if (weeklyAverage > 0.1) trend = 'declining'; // Gaining weight
  } else if (goal === 'muscle_gain') {
    if (weeklyAverage > 0.2) trend = 'improving'; // Gaining weight
    else if (weeklyAverage < -0.1) trend = 'declining'; // Losing weight
  }
  
  // Project goal date
  let projectedGoal: Date | null = null;
  if (targetWeight && weeklyAverage !== 0) {
    const remainingWeight = targetWeight - currentWeight;
    const weeksRemaining = remainingWeight / weeklyAverage;
    if (weeksRemaining > 0) {
      projectedGoal = new Date();
      projectedGoal.setDate(projectedGoal.getDate() + weeksRemaining * 7);
    }
  }
  
  return {
    currentWeight,
    startingWeight,
    weightChange,
    weeklyAverage,
    trend,
    projectedGoal
  };
}
```

### Workout Adherence Tracking

```typescript
function calculateWorkoutAdherence(
  workouts: Workout[],
  timeframe: 'week' | 'month'
): {
  completed: number;
  total: number;
  percentage: number;
  streak: number;
} {
  const now = new Date();
  const startDate = new Date();
  
  if (timeframe === 'week') {
    startDate.setDate(now.getDate() - 7);
  } else {
    startDate.setDate(now.getDate() - 30);
  }
  
  // Filter workouts in timeframe
  const relevantWorkouts = workouts.filter(w =>
    w.scheduledDate >= startDate && w.scheduledDate <= now
  );
  
  const completed = relevantWorkouts.filter(w => w.isCompleted).length;
  const total = relevantWorkouts.length;
  const percentage = total > 0 ? Math.round((completed / total) * 100) : 0;
  
  // Calculate current streak
  const streak = calculateStreak(workouts);
  
  return {
    completed,
    total,
    percentage,
    streak
  };
}

function calculateStreak(workouts: Workout[]): number {
  // Sort workouts by date, most recent first
  const sorted = workouts
    .filter(w => w.isCompleted)
    .sort((a, b) => b.completedAt!.getTime() - a.completedAt!.getTime());
  
  if (sorted.length === 0) return 0;
  
  let streak = 0;
  let currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);
  
  for (const workout of sorted) {
    const workoutDate = new Date(workout.completedAt!);
    workoutDate.setHours(0, 0, 0, 0);
    
    const daysDiff = Math.floor(
      (currentDate.getTime() - workoutDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    
    if (daysDiff === 0 || daysDiff === 1) {
      streak++;
      currentDate = workoutDate;
    } else {
      break;
    }
  }
  
  return streak;
}
```

---

## 8. Subscription Pricing Logic

### Purpose
Calculate subscription costs, prorations, and billing cycles.

### Price Calculation

```typescript
const SUBSCRIPTION_PRICES = {
  'Freemium': 0,
  'Premium': 19.99,      // USD/month
  'Smart Premium': 49.99 // USD/month
};

function calculateSubscriptionCost(
  tier: SubscriptionTier,
  billingCycle: 'monthly' | 'annual',
  currency: 'USD' | 'SAR' = 'USD'
): number {
  const monthlyPrice = SUBSCRIPTION_PRICES[tier];
  
  let cost: number;
  
  if (billingCycle === 'monthly') {
    cost = monthlyPrice;
  } else {
    // Annual billing: 2 months free (10 months cost for 12 months service)
    cost = monthlyPrice * 10;
  }
  
  // Convert to SAR if needed (1 USD = 3.75 SAR)
  if (currency === 'SAR') {
    cost = cost * 3.75;
  }
  
  return cost;
}
```

### Proration on Upgrade

```typescript
function calculateProration(
  currentTier: SubscriptionTier,
  newTier: SubscriptionTier,
  daysRemainingInCycle: number
): number {
  const currentMonthlyPrice = SUBSCRIPTION_PRICES[currentTier];
  const newMonthlyPrice = SUBSCRIPTION_PRICES[newTier];
  
  // Daily rate difference
  const dailyDifference = (newMonthlyPrice - currentMonthlyPrice) / 30;
  
  // Charge for remaining days at new rate
  const prorationAmount = dailyDifference * daysRemainingInCycle;
  
  return Math.max(0, prorationAmount);
}
```

---

## 9. Rating Aggregation

### Purpose
Calculate average coach ratings and identify quality trends.

### Algorithm

```typescript
async function updateCoachAverageRating(coachId: string): Promise<void> {
  // Get all ratings for this coach
  const ratings = await database.coachRatings.find({ coachId });
  
  if (ratings.length === 0) {
    await database.coaches.update(coachId, {
      averageRating: 0,
      totalRatings: 0
    });
    return;
  }
  
  // Calculate simple average
  const sum = ratings.reduce((acc, r) => acc + r.rating, 0);
  const average = sum / ratings.length;
  
  // Apply recency weighting (ratings from last 30 days count more)
  const now = new Date();
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  
  let weightedSum = 0;
  let weightedCount = 0;
  
  ratings.forEach(r => {
    const weight = r.createdAt > thirtyDaysAgo ? 1.5 : 1.0;
    weightedSum += r.rating * weight;
    weightedCount += weight;
  });
  
  const weightedAverage = weightedSum / weightedCount;
  
  // Update coach profile
  await database.coaches.update(coachId, {
    averageRating: Math.round(weightedAverage * 10) / 10, // Round to 1 decimal
    totalRatings: ratings.length
  });
}
```

---

## 10. Notification Triggers

### Purpose
Define business rules for when to send notifications to users.

### Trigger Conditions

```typescript
// Check daily for notification triggers
async function processDailyNotifications(): Promise<void> {
  const users = await database.users.find({ isActive: true });
  
  for (const user of users) {
    // 1. Workout reminder (if workout scheduled for today and not completed)
    await checkWorkoutReminder(user);
    
    // 2. Nutrition logging reminder (if no meals logged today)
    await checkNutritionReminder(user);
    
    // 3. Quota warning (if at 80% usage)
    await checkQuotaWarning(user);
    
    // 4. Nutrition expiry warning (Freemium, 2 days before expiry)
    await checkNutritionExpiryWarning(user);
    
    // 5. Streak celebration (if reached milestone: 7, 14, 30 days)
    await checkStreakMilestone(user);
    
    // 6. Weight tracking reminder (if no entry in 7 days)
    await checkWeightTrackingReminder(user);
  }
}

async function checkWorkoutReminder(user: UserProfile): Promise<void> {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const workout = await database.workouts.findOne({
    userId: user.id,
    scheduledDate: today,
    isCompleted: false
  });
  
  if (workout) {
    await sendNotification(user.id, {
      type: 'workout_reminder',
      title: 'Time to Work Out! 💪',
      message: `Your ${workout.name} workout is scheduled for today`,
      action: 'open_workout',
      actionData: { workoutId: workout.id }
    });
  }
}
```

---

**End of Business Logic Document**

This document provides the core algorithms and calculations used throughout the FitCoach+ application. All formulas and business rules are designed to be platform-agnostic and can be implemented in any programming language.
