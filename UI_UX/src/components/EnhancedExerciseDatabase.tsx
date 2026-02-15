import React from 'react';

export interface ExerciseDetail {
  id: string;
  nameKey: string; // Translation key for exercise name
  category: string;
  muscleGroup: string;
  equipment: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  videoUrl?: string;
  instructionKeys: string[]; // Translation keys for instructions
  cueKeys: string[]; // Translation keys for cues
  mistakeKeys: string[]; // Translation keys for common mistakes
  alternatives: string[]; // IDs of alternative exercises
  defaultSets: number;
  defaultReps: string;
  defaultRestTime: number; // in seconds
}

// Helper to convert snake_case exercise ID to camelCase for translation keys
const exerciseIdToKey = (id: string): string => {
  // Map of special cases
  const specialCases: Record<string, string> = {
    'bench_press': 'benchPress',
    'dumbbell_press': 'dumbbellPress',
    'push_ups': 'pushUps',
    'pull_ups': 'pullUps',
    'barbell_rows': 'barbellRows',
    'overhead_press': 'overheadPress',
    'squats': 'squats',
    'deadlifts': 'deadlift',
  };
  
  return specialCases[id] || id.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
};

export const exerciseDatabase: ExerciseDetail[] = [
  // Chest Exercises
  {
    id: 'bench_press',
    nameKey: 'exercises.benchPress',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['barbell', 'bench'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.benchPress.instruction1',
      'exercises.benchPress.instruction2',
      'exercises.benchPress.instruction3',
      'exercises.benchPress.instruction4'
    ],
    cueKeys: [
      'exercises.benchPress.cue1',
      'exercises.benchPress.cue2',
      'exercises.benchPress.cue3',
      'exercises.benchPress.cue4'
    ],
    mistakeKeys: [
      'exercises.benchPress.mistake1',
      'exercises.benchPress.mistake2',
      'exercises.benchPress.mistake3',
      'exercises.benchPress.mistake4'
    ],
    alternatives: ['dumbbell_press', 'push_ups', 'incline_press'],
    defaultSets: 4,
    defaultReps: '8-10',
    defaultRestTime: 90
  },
  {
    id: 'dumbbell_press',
    nameKey: 'exercises.dumbbellPress',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['dumbbells', 'bench'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.dumbbellPress.instruction1',
      'exercises.dumbbellPress.instruction2',
      'exercises.dumbbellPress.instruction3',
      'exercises.dumbbellPress.instruction4'
    ],
    cueKeys: [
      'exercises.dumbbellPress.cue1',
      'exercises.dumbbellPress.cue2',
      'exercises.dumbbellPress.cue3',
      'exercises.dumbbellPress.cue4'
    ],
    mistakeKeys: [
      'exercises.dumbbellPress.mistake1',
      'exercises.dumbbellPress.mistake2',
      'exercises.dumbbellPress.mistake3',
      'exercises.dumbbellPress.mistake4'
    ],
    alternatives: ['bench_press', 'push_ups', 'flies'],
    defaultSets: 4,
    defaultReps: '8-12',
    defaultRestTime: 90
  },
  {
    id: 'push_ups',
    nameKey: 'exercises.pushUps',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['bodyweight'],
    difficulty: 'beginner',
    instructionKeys: [
      'exercises.pushUps.instruction1',
      'exercises.pushUps.instruction2',
      'exercises.pushUps.instruction3',
      'exercises.pushUps.instruction4'
    ],
    cueKeys: [
      'exercises.pushUps.cue1',
      'exercises.pushUps.cue2',
      'exercises.pushUps.cue3',
      'exercises.pushUps.cue4'
    ],
    mistakeKeys: [
      'exercises.pushUps.mistake1',
      'exercises.pushUps.mistake2',
      'exercises.pushUps.mistake3',
      'exercises.pushUps.mistake4'
    ],
    alternatives: ['incline_push_ups', 'knee_push_ups', 'bench_press'],
    defaultSets: 3,
    defaultReps: '8-15',
    defaultRestTime: 60
  },

  // Back Exercises
  {
    id: 'pull_ups',
    nameKey: 'exercises.pullUps',
    category: 'pull',
    muscleGroup: 'back',
    equipment: ['pull_up_bar'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.pullUps.instruction1',
      'exercises.pullUps.instruction2',
      'exercises.pullUps.instruction3',
      'exercises.pullUps.instruction4'
    ],
    cueKeys: [
      'exercises.pullUps.cue1',
      'exercises.pullUps.cue2',
      'exercises.pullUps.cue3',
      'exercises.pullUps.cue4'
    ],
    mistakeKeys: [
      'exercises.pullUps.mistake1',
      'exercises.pullUps.mistake2',
      'exercises.pullUps.mistake3',
      'exercises.pullUps.mistake4'
    ],
    alternatives: ['lat_pulldown', 'assisted_pull_ups', 'barbell_rows'],
    defaultSets: 3,
    defaultReps: '6-10',
    defaultRestTime: 120
  },
  {
    id: 'barbell_rows',
    nameKey: 'exercises.barbellRows',
    category: 'pull',
    muscleGroup: 'back',
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.barbellRows.instruction1',
      'exercises.barbellRows.instruction2',
      'exercises.barbellRows.instruction3',
      'exercises.barbellRows.instruction4'
    ],
    cueKeys: [
      'exercises.barbellRows.cue1',
      'exercises.barbellRows.cue2',
      'exercises.barbellRows.cue3',
      'exercises.barbellRows.cue4'
    ],
    mistakeKeys: [
      'exercises.barbellRows.mistake1',
      'exercises.barbellRows.mistake2',
      'exercises.barbellRows.mistake3',
      'exercises.barbellRows.mistake4'
    ],
    alternatives: ['dumbbell_rows', 'seated_cable_rows', 'pull_ups'],
    defaultSets: 4,
    defaultReps: '8-10',
    defaultRestTime: 90
  },

  // Shoulder Exercises
  {
    id: 'overhead_press',
    nameKey: 'exercises.overheadPress',
    category: 'push',
    muscleGroup: 'shoulders',
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.overheadPress.instruction1',
      'exercises.overheadPress.instruction2',
      'exercises.overheadPress.instruction3',
      'exercises.overheadPress.instruction4'
    ],
    cueKeys: [
      'exercises.overheadPress.cue1',
      'exercises.overheadPress.cue2',
      'exercises.overheadPress.cue3',
      'exercises.overheadPress.cue4'
    ],
    mistakeKeys: [
      'exercises.overheadPress.mistake1',
      'exercises.overheadPress.mistake2',
      'exercises.overheadPress.mistake3',
      'exercises.overheadPress.mistake4'
    ],
    alternatives: ['dumbbell_press', 'seated_press', 'pike_push_ups'],
    defaultSets: 4,
    defaultReps: '6-8',
    defaultRestTime: 90
  },

  // Leg Exercises
  {
    id: 'squats',
    nameKey: 'exercises.squats',
    category: 'legs',
    muscleGroup: 'quadriceps',
    equipment: ['barbell', 'squat_rack'],
    difficulty: 'intermediate',
    instructionKeys: [
      'exercises.squats.instruction1',
      'exercises.squats.instruction2',
      'exercises.squats.instruction3',
      'exercises.squats.instruction4'
    ],
    cueKeys: [
      'exercises.squats.cue1',
      'exercises.squats.cue2',
      'exercises.squats.cue3',
      'exercises.squats.cue4'
    ],
    mistakeKeys: [
      'exercises.squats.mistake1',
      'exercises.squats.mistake2',
      'exercises.squats.mistake3',
      'exercises.squats.mistake4'
    ],
    alternatives: ['goblet_squats', 'front_squats', 'leg_press'],
    defaultSets: 4,
    defaultReps: '8-12',
    defaultRestTime: 120
  },
  {
    id: 'deadlifts',
    nameKey: 'exercises.deadlift',
    category: 'pull',
    muscleGroup: 'posterior_chain',
    equipment: ['barbell'],
    difficulty: 'advanced',
    instructionKeys: [
      'exercises.deadlift.instruction1',
      'exercises.deadlift.instruction2',
      'exercises.deadlift.instruction3',
      'exercises.deadlift.instruction4'
    ],
    cueKeys: [
      'exercises.deadlift.cue1',
      'exercises.deadlift.cue2',
      'exercises.deadlift.cue3',
      'exercises.deadlift.cue4'
    ],
    mistakeKeys: [
      'exercises.deadlift.mistake1',
      'exercises.deadlift.mistake2',
      'exercises.deadlift.mistake3',
      'exercises.deadlift.mistake4'
    ],
    alternatives: ['trap_bar_deadlifts', 'romanian_deadlifts', 'sumo_deadlifts'],
    defaultSets: 4,
    defaultReps: '5-6',
    defaultRestTime: 180
  }
];

export const getExerciseById = (id: string): ExerciseDetail | undefined => {
  return exerciseDatabase.find(exercise => exercise.id === id);
};

export const getExercisesByCategory = (category: string): ExerciseDetail[] => {
  return exerciseDatabase.filter(exercise => exercise.category === category);
};

export const getExercisesByMuscleGroup = (muscleGroup: string): ExerciseDetail[] => {
  return exerciseDatabase.filter(exercise => exercise.muscleGroup === muscleGroup);
};

export const getExercisesByEquipment = (equipment: string[]): ExerciseDetail[] => {
  return exerciseDatabase.filter(exercise => 
    exercise.equipment.some(eq => equipment.includes(eq))
  );
};

export const getAlternativeExercises = (exerciseId: string): ExerciseDetail[] => {
  const exercise = getExerciseById(exerciseId);
  if (!exercise) return [];
  
  return exercise.alternatives
    .map(altId => getExerciseById(altId))
    .filter((alt): alt is ExerciseDetail => alt !== undefined);
};

// Helper function to get translated exercise data
// This should be used by components that consume exercise data
export interface TranslatedExercise extends Omit<ExerciseDetail, 'nameKey' | 'instructionKeys' | 'cueKeys' | 'mistakeKeys'> {
  name: string;
  instructions: string[];
  cues: string[];
  commonMistakes: string[];
}

export const translateExercise = (exercise: ExerciseDetail, t: (key: string) => string): TranslatedExercise => {
  return {
    ...exercise,
    name: t(exercise.nameKey),
    instructions: exercise.instructionKeys.map(key => t(key)),
    cues: exercise.cueKeys.map(key => t(key)),
    commonMistakes: exercise.mistakeKeys.map(key => t(key))
  };
};
