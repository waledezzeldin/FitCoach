export interface Exercise {
  id: string;
  name: string;
  category: string;
  muscleGroup: string;
  equipment: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  description: string;
  instructions: string[];
  videoUrl?: string;
  defaultSets: number;
  defaultReps: string; // e.g., "8-12", "30 seconds"
  defaultRestTime: number; // in seconds
  location: 'home' | 'gym' | 'both';
  alternatives: string[]; // IDs of alternative exercises
}

export const EXERCISE_DATABASE: Exercise[] = [
  // Push Exercises
  {
    id: 'push_up',
    name: 'Push-up',
    category: 'push',
    muscleGroup: 'chest',
    equipment: 'bodyweight',
    difficulty: 'beginner',
    description: 'Classic bodyweight exercise targeting chest, shoulders, and triceps.',
    instructions: [
      'Start in a plank position with hands slightly wider than shoulder-width',
      'Lower your body until chest nearly touches the floor',
      'Push back up to starting position',
      'Keep your core tight throughout'
    ],
    defaultSets: 3,
    defaultReps: '8-15',
    defaultRestTime: 60,
    location: 'both',
    alternatives: ['incline_push_up', 'knee_push_up', 'diamond_push_up']
  },
  {
    id: 'bench_press',
    name: 'Barbell Bench Press',
    category: 'push',
    muscleGroup: 'chest',
    equipment: 'barbell',
    difficulty: 'intermediate',
    description: 'Fundamental compound movement for building chest, shoulder, and tricep strength.',
    instructions: [
      'Lie on bench with eyes under the bar',
      'Grip bar slightly wider than shoulder-width',
      'Unrack and lower bar to chest with control',
      'Press bar up in straight line',
      'Keep shoulder blades retracted'
    ],
    defaultSets: 4,
    defaultReps: '6-10',
    defaultRestTime: 120,
    location: 'gym',
    alternatives: ['dumbbell_press', 'incline_bench_press', 'push_up']
  },
  {
    id: 'dumbbell_press',
    name: 'Dumbbell Chest Press',
    category: 'push',
    muscleGroup: 'chest',
    equipment: 'dumbbells',
    difficulty: 'beginner',
    description: 'Versatile chest exercise allowing for greater range of motion.',
    instructions: [
      'Lie on bench holding dumbbells at chest level',
      'Press weights up and slightly together',
      'Lower with control to starting position',
      'Keep wrists straight and core engaged'
    ],
    defaultSets: 3,
    defaultReps: '8-12',
    defaultRestTime: 90,
    location: 'both',
    alternatives: ['bench_press', 'push_up', 'incline_dumbbell_press']
  },

  // Pull Exercises
  {
    id: 'pull_up',
    name: 'Pull-up',
    category: 'pull',
    muscleGroup: 'back',
    equipment: 'pull_up_bar',
    difficulty: 'intermediate',
    description: 'Challenging upper body exercise targeting lats, rhomboids, and biceps.',
    instructions: [
      'Hang from bar with palms facing away',
      'Pull your body up until chin clears bar',
      'Lower with control to full arm extension',
      'Keep core tight and avoid swinging'
    ],
    defaultSets: 3,
    defaultReps: '5-10',
    defaultRestTime: 120,
    location: 'both',
    alternatives: ['assisted_pull_up', 'lat_pulldown', 'inverted_row']
  },
  {
    id: 'lat_pulldown',
    name: 'Lat Pulldown',
    category: 'pull',
    muscleGroup: 'back',
    equipment: 'cable_machine',
    difficulty: 'beginner',
    description: 'Machine-based pulling exercise great for building back width.',
    instructions: [
      'Sit at lat pulldown machine with thighs secured',
      'Grip bar wider than shoulder-width',
      'Pull bar down to upper chest',
      'Squeeze shoulder blades together',
      'Control the weight back up'
    ],
    defaultSets: 3,
    defaultReps: '8-12',
    defaultRestTime: 90,
    location: 'gym',
    alternatives: ['pull_up', 'assisted_pull_up', 'cable_row']
  },

  // Leg Exercises
  {
    id: 'bodyweight_squat',
    name: 'Bodyweight Squat',
    category: 'legs',
    muscleGroup: 'quadriceps',
    equipment: 'bodyweight',
    difficulty: 'beginner',
    description: 'Fundamental lower body movement pattern.',
    instructions: [
      'Stand with feet shoulder-width apart',
      'Lower by pushing hips back and bending knees',
      'Go down until thighs are parallel to floor',
      'Drive through heels to return to standing',
      'Keep chest up and knees tracking over toes'
    ],
    defaultSets: 3,
    defaultReps: '12-20',
    defaultRestTime: 60,
    location: 'both',
    alternatives: ['goblet_squat', 'jump_squat', 'wall_sit']
  },
  {
    id: 'barbell_squat',
    name: 'Barbell Back Squat',
    category: 'legs',
    muscleGroup: 'quadriceps',
    equipment: 'barbell',
    difficulty: 'intermediate',
    description: 'The king of lower body exercises for building strength and mass.',
    instructions: [
      'Position bar on upper back/traps',
      'Step back from rack with feet shoulder-width apart',
      'Initiate movement by pushing hips back',
      'Descend until hip crease is below knee cap',
      'Drive through heels to stand up'
    ],
    defaultSets: 4,
    defaultReps: '6-10',
    defaultRestTime: 180,
    location: 'gym',
    alternatives: ['goblet_squat', 'leg_press', 'bodyweight_squat']
  },

  // Core Exercises
  {
    id: 'plank',
    name: 'Plank',
    category: 'core',
    muscleGroup: 'core',
    equipment: 'bodyweight',
    difficulty: 'beginner',
    description: 'Isometric core exercise building stability and endurance.',
    instructions: [
      'Start in push-up position on forearms',
      'Keep body in straight line from head to heels',
      'Engage core and glutes',
      'Breathe normally while holding position',
      'Avoid letting hips sag or pike up'
    ],
    defaultSets: 3,
    defaultReps: '30-60 seconds',
    defaultRestTime: 60,
    location: 'both',
    alternatives: ['side_plank', 'mountain_climbers', 'dead_bug']
  }
];

export const getExerciseById = (id: string): Exercise | undefined => {
  return EXERCISE_DATABASE.find(exercise => exercise.id === id);
};

export const getExercisesByCategory = (category: string): Exercise[] => {
  return EXERCISE_DATABASE.filter(exercise => exercise.category === category);
};

export const getExercisesByLocation = (location: 'home' | 'gym'): Exercise[] => {
  return EXERCISE_DATABASE.filter(exercise => 
    exercise.location === location || exercise.location === 'both'
  );
};

export const getAlternativeExercises = (exerciseId: string): Exercise[] => {
  const exercise = getExerciseById(exerciseId);
  if (!exercise) return [];
  
  return exercise.alternatives
    .map(id => getExerciseById(id))
    .filter((ex): ex is Exercise => ex !== undefined);
};