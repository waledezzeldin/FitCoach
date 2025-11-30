import React from 'react';

export interface ExerciseDetail {
  id: string;
  name: string;
  category: string;
  muscleGroup: string;
  equipment: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  videoUrl?: string;
  instructions: string[];
  cues: string[];
  commonMistakes: string[];
  alternatives: string[]; // IDs of alternative exercises
  defaultSets: number;
  defaultReps: string;
  defaultRestTime: number; // in seconds
}

export const exerciseDatabase: ExerciseDetail[] = [
  // Chest Exercises
  {
    id: 'bench_press',
    name: 'Bench Press',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['barbell', 'bench'],
    difficulty: 'intermediate',
    instructions: [
      'Lie flat on the bench with feet firmly on the ground',
      'Grip the bar slightly wider than shoulder-width',
      'Lower the bar to chest with control',
      'Press the bar up explosively while keeping shoulders back'
    ],
    cues: [
      'Keep your core tight throughout the movement',
      'Maintain natural arch in lower back',
      'Drive through your heels',
      'Touch chest briefly, don\'t bounce'
    ],
    commonMistakes: [
      'Lifting feet off the ground',
      'Bouncing bar off chest',
      'Not maintaining shoulder position',
      'Partial range of motion'
    ],
    alternatives: ['dumbbell_press', 'push_ups', 'incline_press'],
    defaultSets: 4,
    defaultReps: '8-10',
    defaultRestTime: 90
  },
  {
    id: 'dumbbell_press',
    name: 'Dumbbell Bench Press',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['dumbbells', 'bench'],
    difficulty: 'intermediate',
    instructions: [
      'Lie on bench holding dumbbells at chest level',
      'Press dumbbells up and slightly inward',
      'Lower with control until elbows are below chest',
      'Press back up in smooth motion'
    ],
    cues: [
      'Keep wrists neutral and strong',
      'Squeeze chest at the top',
      'Control the negative portion',
      'Don\'t let dumbbells drift away from body'
    ],
    commonMistakes: [
      'Going too deep and straining shoulders',
      'Using momentum instead of control',
      'Not squeezing at the top',
      'Allowing dumbbells to drift too wide'
    ],
    alternatives: ['bench_press', 'push_ups', 'flies'],
    defaultSets: 4,
    defaultReps: '8-12',
    defaultRestTime: 90
  },
  {
    id: 'push_ups',
    name: 'Push-ups',
    category: 'push',
    muscleGroup: 'chest',
    equipment: ['bodyweight'],
    difficulty: 'beginner',
    instructions: [
      'Start in plank position with hands under shoulders',
      'Lower body as one unit until chest nearly touches ground',
      'Push back up to starting position',
      'Maintain straight line from head to heels'
    ],
    cues: [
      'Keep core engaged throughout',
      'Don\'t let hips sag or pike up',
      'Full range of motion',
      'Control both up and down phases'
    ],
    commonMistakes: [
      'Partial range of motion',
      'Letting hips sag',
      'Head position too high or low',
      'Hands too wide or too narrow'
    ],
    alternatives: ['incline_push_ups', 'knee_push_ups', 'bench_press'],
    defaultSets: 3,
    defaultReps: '8-15',
    defaultRestTime: 60
  },

  // Back Exercises
  {
    id: 'pull_ups',
    name: 'Pull-ups',
    category: 'pull',
    muscleGroup: 'back',
    equipment: ['pull_up_bar'],
    difficulty: 'intermediate',
    instructions: [
      'Hang from bar with palms facing away',
      'Pull body up until chin clears the bar',
      'Lower with control to full extension',
      'Repeat for desired reps'
    ],
    cues: [
      'Lead with chest, not chin',
      'Squeeze shoulder blades together',
      'Don\'t swing or use momentum',
      'Full range of motion'
    ],
    commonMistakes: [
      'Partial range of motion',
      'Swinging or kipping',
      'Not engaging lats properly',
      'Rushing the negative'
    ],
    alternatives: ['lat_pulldown', 'assisted_pull_ups', 'barbell_rows'],
    defaultSets: 3,
    defaultReps: '6-10',
    defaultRestTime: 120
  },
  {
    id: 'barbell_rows',
    name: 'Barbell Rows',
    category: 'pull',
    muscleGroup: 'back',
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand with feet hip-width apart holding barbell',
      'Hinge at hips, keeping back straight',
      'Pull bar to lower chest/upper abdomen',
      'Lower with control to starting position'
    ],
    cues: [
      'Keep back straight throughout',
      'Pull with elbows, not hands',
      'Squeeze shoulder blades at top',
      'Don\'t round the back'
    ],
    commonMistakes: [
      'Rounding the back',
      'Using too much momentum',
      'Not maintaining hip hinge position',
      'Pulling too high or too low'
    ],
    alternatives: ['dumbbell_rows', 'seated_cable_rows', 'pull_ups'],
    defaultSets: 4,
    defaultReps: '8-10',
    defaultRestTime: 90
  },

  // Shoulder Exercises
  {
    id: 'overhead_press',
    name: 'Overhead Press',
    category: 'push',
    muscleGroup: 'shoulders',
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand with feet hip-width apart, bar at shoulder level',
      'Press bar straight up overhead',
      'Lower with control to starting position',
      'Keep core tight throughout'
    ],
    cues: [
      'Drive through heels',
      'Keep bar path vertical',
      'Squeeze glutes for stability',
      'Don\'t arch back excessively'
    ],
    commonMistakes: [
      'Pressing bar forward instead of up',
      'Excessive back arch',
      'Not keeping core tight',
      'Partial range of motion'
    ],
    alternatives: ['dumbbell_press', 'seated_press', 'pike_push_ups'],
    defaultSets: 4,
    defaultReps: '6-8',
    defaultRestTime: 90
  },

  // Leg Exercises
  {
    id: 'squats',
    name: 'Back Squats',
    category: 'legs',
    muscleGroup: 'quadriceps',
    equipment: ['barbell', 'squat_rack'],
    difficulty: 'intermediate',
    instructions: [
      'Position bar on upper back, stand with feet shoulder-width apart',
      'Lower by pushing hips back and bending knees',
      'Descend until thighs are parallel to floor',
      'Drive through heels to return to starting position'
    ],
    cues: [
      'Keep chest up and core tight',
      'Knees track over toes',
      'Weight balanced across whole foot',
      'Hip hinge initiates the movement'
    ],
    commonMistakes: [
      'Knees caving inward',
      'Not reaching proper depth',
      'Forward lean of torso',
      'Rising on toes'
    ],
    alternatives: ['goblet_squats', 'front_squats', 'leg_press'],
    defaultSets: 4,
    defaultReps: '8-12',
    defaultRestTime: 120
  },
  {
    id: 'deadlifts',
    name: 'Deadlifts',
    category: 'pull',
    muscleGroup: 'posterior_chain',
    equipment: ['barbell'],
    difficulty: 'advanced',
    instructions: [
      'Stand with feet hip-width apart, bar over mid-foot',
      'Hinge at hips and grip bar with hands outside legs',
      'Drive through heels and hips to lift bar',
      'Stand tall, then reverse the movement'
    ],
    cues: [
      'Keep bar close to body throughout',
      'Maintain neutral spine',
      'Drive hips forward at top',
      'Control the descent'
    ],
    commonMistakes: [
      'Rounding the back',
      'Bar drifting away from body',
      'Not engaging lats',
      'Hyperextending at the top'
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