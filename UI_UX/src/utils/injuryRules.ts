// Injury Substitution Rules Engine

import { InjuryArea } from "../types/IntakeTypes";

export interface InjuryRule {
  injuryCode: InjuryArea;
  displayName: string;
  avoidKeywords: string[];
  substitutes: ExerciseSubstitute[];
}

export interface ExerciseSubstitute {
  originalCategory: string;
  replacementExercises: string[];
  targetMuscles: string[];
  movementPattern: string;
  reasoning: string;
}

export interface SubstitutionResult {
  wasSubstituted: boolean;
  originalExercise?: string;
  newExercise?: string;
  reason?: string;
  injuryCode?: InjuryArea;
}

export const INJURY_RULES: InjuryRule[] = [
  {
    injuryCode: "knee",
    displayName: "Knee",
    avoidKeywords: [
      "squat",
      "lunge",
      "jump",
      "leg press",
      "step up",
      "pistol",
    ],
    substitutes: [
      {
        originalCategory: "quad_compound",
        replacementExercises: [
          "Leg Extension",
          "Bulgarian Split Squat (shallow)",
          "Wall Sit",
          "Seated Leg Curl",
        ],
        targetMuscles: ["quadriceps"],
        movementPattern: "knee_extension",
        reasoning:
          "Reduced knee loading while maintaining quad stimulus",
      },
      {
        originalCategory: "leg_compound",
        replacementExercises: [
          "Glute Bridge",
          "Hip Thrust",
          "Romanian Deadlift (light)",
          "Cable Pull-through",
        ],
        targetMuscles: ["glutes", "hamstrings"],
        movementPattern: "hip_hinge",
        reasoning:
          "Minimal knee flexion with posterior chain emphasis",
      },
    ],
  },
  {
    injuryCode: "shoulder",
    displayName: "Shoulder",
    avoidKeywords: [
      "overhead press",
      "military press",
      "pullup",
      "pull-up",
      "chin up",
      "dip",
      "behind neck",
      "upright row",
      "lateral raise",
    ],
    substitutes: [
      {
        originalCategory: "shoulder_press",
        replacementExercises: [
          "Landmine Press",
          "Neutral Grip Dumbbell Press",
          "Machine Shoulder Press",
          "Push-up (elevated hands)",
        ],
        targetMuscles: ["anterior_deltoid", "lateral_deltoid"],
        movementPattern: "shoulder_flexion",
        reasoning:
          "Reduced shoulder external rotation and overhead stress",
      },
      {
        originalCategory: "vertical_pull",
        replacementExercises: [
          "Lat Pulldown (wide grip)",
          "Seated Cable Row",
          "Chest-Supported Row",
          "Inverted Row",
        ],
        targetMuscles: ["latissimus_dorsi", "rhomboids"],
        movementPattern: "shoulder_extension",
        reasoning:
          "Controlled range of motion, reduced shoulder strain",
      },
    ],
  },
  {
    injuryCode: "lower_back",
    displayName: "Lower Back",
    avoidKeywords: [
      "deadlift",
      "bent over row",
      "good morning",
      "hyperextension",
      "back extension",
      "barbell row",
    ],
    substitutes: [
      {
        originalCategory: "hip_hinge",
        replacementExercises: [
          "Trap Bar Deadlift",
          "Romanian Deadlift (light)",
          "Hip Thrust",
          "Cable Pull-through",
          "Glute-Ham Raise",
        ],
        targetMuscles: ["glutes", "hamstrings"],
        movementPattern: "hip_extension",
        reasoning:
          "Neutral spine position with reduced spinal loading",
      },
      {
        originalCategory: "horizontal_pull",
        replacementExercises: [
          "Chest-Supported Row",
          "Seated Cable Row",
          "Machine Row",
          "Inverted Row",
        ],
        targetMuscles: [
          "latissimus_dorsi",
          "rhomboids",
          "traps",
        ],
        movementPattern: "shoulder_extension",
        reasoning:
          "Supported position eliminates lower back strain",
      },
    ],
  },
  {
    injuryCode: "neck",
    displayName: "Neck",
    avoidKeywords: [
      "barbell squat",
      "back squat",
      "behind neck press",
      "heavy overhead",
      "barbell shrug",
    ],
    substitutes: [
      {
        originalCategory: "squat_pattern",
        replacementExercises: [
          "Goblet Squat",
          "Front Squat (light)",
          "Safety Bar Squat",
          "Leg Press",
          "Hack Squat",
        ],
        targetMuscles: ["quadriceps", "glutes"],
        movementPattern: "squat",
        reasoning:
          "Removes barbell from neck/traps, maintains squat pattern",
      },
      {
        originalCategory: "trap_shrug",
        replacementExercises: [
          "Dumbbell Shrug",
          "Cable Shrug",
          "Face Pull",
          "Farmer Carry",
        ],
        targetMuscles: ["trapezius", "rhomboids"],
        movementPattern: "scapular_elevation",
        reasoning: "Reduced cervical spine compression",
      },
    ],
  },
  {
    injuryCode: "ankle",
    displayName: "Ankle",
    avoidKeywords: [
      "calf raise",
      "jump",
      "sprint",
      "lunge",
      "box jump",
      "jumping",
    ],
    substitutes: [
      {
        originalCategory: "lower_leg",
        replacementExercises: [
          "Seated Calf Raise (if tolerated)",
          "Resistance Band Ankle Work",
          "Tibialis Raise",
          "Ankle Mobility Drills",
        ],
        targetMuscles: ["gastrocnemius", "soleus"],
        movementPattern: "ankle_plantarflexion",
        reasoning:
          "Reduced load on ankle joint with controlled ROM",
      },
      {
        originalCategory: "plyometric",
        replacementExercises: [
          "Cycling",
          "Swimming",
          "Elliptical",
          "Upper Body Cardio",
        ],
        targetMuscles: ["cardiovascular"],
        movementPattern: "low_impact",
        reasoning:
          "Maintains cardio fitness without ankle impact",
      },
    ],
  },
];

export const findInjuryRule = (
  injuryCode: InjuryArea,
): InjuryRule | undefined => {
  return INJURY_RULES.find(
    (rule) => rule.injuryCode === injuryCode,
  );
};

export const shouldSubstituteExercise = (
  exerciseName: string,
  injuries: InjuryArea[],
): {
  shouldSub: boolean;
  injury?: InjuryArea;
  rule?: InjuryRule;
} => {
  for (const injury of injuries) {
    const rule = findInjuryRule(injury);
    if (!rule) continue;

    const lowerExercise = exerciseName.toLowerCase();
    const hasKeyword = rule.avoidKeywords.some((keyword) =>
      lowerExercise.includes(keyword.toLowerCase()),
    );

    if (hasKeyword) {
      return { shouldSub: true, injury, rule };
    }
  }

  return { shouldSub: false };
};

export const getSubstituteExercise = (
  originalExercise: string,
  injury: InjuryArea,
  category?: string,
): ExerciseSubstitute | null => {
  const rule = findInjuryRule(injury);
  if (!rule) return null;

  // Try to find best matching substitute based on category or movement pattern
  // For simplicity, return first substitute group
  if (rule.substitutes.length > 0) {
    return rule.substitutes[0];
  }

  return null;
};

export const applyInjurySubstitution = (
  exerciseName: string,
  injuries: InjuryArea[],
): SubstitutionResult => {
  const check = shouldSubstituteExercise(
    exerciseName,
    injuries,
  );

  if (!check.shouldSub || !check.injury || !check.rule) {
    return { wasSubstituted: false };
  }

  const substitute = getSubstituteExercise(
    exerciseName,
    check.injury,
  );

  if (
    !substitute ||
    substitute.replacementExercises.length === 0
  ) {
    return { wasSubstituted: false };
  }

  // Pick first replacement exercise
  const newExercise = substitute.replacementExercises[0];

  return {
    wasSubstituted: true,
    originalExercise: exerciseName,
    newExercise,
    reason: substitute.reasoning,
    injuryCode: check.injury,
  };
};

// v2.0: Find safe exercise alternatives based on injury area
export const findSafeAlternatives = (
  originalExerciseId: string,
  injuryArea: string,
  targetMuscleGroup?: string,
): any[] => {
  // Map injury area to InjuryArea type
  const injuryCode = injuryArea as InjuryArea;
  const rule = findInjuryRule(injuryCode);

  if (!rule) {
    return [];
  }

  // Get all substitute exercises from all categories
  const alternatives: any[] = [];
  let alternativeIndex = 0; // Use a running counter to ensure unique keys

  rule.substitutes.forEach((substitute) => {
    substitute.replacementExercises.forEach((exerciseName) => {
      alternatives.push({
        id: `${injuryCode}_alt_${alternativeIndex}`,
        name: exerciseName,
        muscleGroup: substitute.targetMuscles.join(", "),
        defaultSets: 3,
        defaultReps: "10-12",
        defaultRestTime: 60,
        reason: substitute.reasoning,
        category: substitute.originalCategory,
      });
      alternativeIndex++; // Increment for each exercise to ensure unique IDs
    });
  });

  return alternatives;
};