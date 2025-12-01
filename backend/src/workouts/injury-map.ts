export interface AlternativeExercise {
  id: string;
  name: string;
  muscleGroup: string;
  difficulty: 'low' | 'medium' | 'high';
  equipment?: string;
  videoUrl?: string;
  description?: string;
}

const SHOULDER_ALTERNATIVES: AlternativeExercise[] = [
  {
    id: 'resistance-band-row',
    name: 'Resistance Band Rows',
    muscleGroup: 'back',
    difficulty: 'low',
    equipment: 'Resistance Band',
    videoUrl: 'https://cdn.fitcoach.app/videos/resistance_band_row.mp4',
    description: 'Keeps the shoulder neutral while strengthening the upper back.',
  },
  {
    id: 'incline-pushup',
    name: 'Incline Push Ups',
    muscleGroup: 'chest',
    difficulty: 'medium',
    equipment: 'Bench',
    videoUrl: 'https://cdn.fitcoach.app/videos/incline_pushup.mp4',
    description: 'Reduces shoulder loading by changing the angle of attack.',
  },
];

const KNEE_ALTERNATIVES: AlternativeExercise[] = [
  {
    id: 'glute-bridge',
    name: 'Glute Bridge',
    muscleGroup: 'glutes',
    difficulty: 'low',
    equipment: 'Bodyweight',
    videoUrl: 'https://cdn.fitcoach.app/videos/glute_bridge.mp4',
    description: 'Posterior chain activation without knee flexion.',
  },
  {
    id: 'reverse-lunge-slider',
    name: 'Reverse Lunge on Slider',
    muscleGroup: 'legs',
    difficulty: 'medium',
    equipment: 'Slider',
    videoUrl: 'https://cdn.fitcoach.app/videos/reverse_lunge_slider.mp4',
    description: 'Keeps knee tracking behind toes and allows range control.',
  },
];

const LOWER_BACK_ALTERNATIVES: AlternativeExercise[] = [
  {
    id: 'bird-dog',
    name: 'Bird Dog',
    muscleGroup: 'core',
    difficulty: 'low',
    equipment: 'Mat',
    videoUrl: 'https://cdn.fitcoach.app/videos/bird_dog.mp4',
    description: 'Teaches spinal stability with contralateral movement.',
  },
  {
    id: 'half-kneeling-pallof',
    name: 'Half-Kneeling Pallof Press',
    muscleGroup: 'core',
    difficulty: 'medium',
    equipment: 'Cable/Band',
    videoUrl: 'https://cdn.fitcoach.app/videos/pallof_press.mp4',
    description: 'Anti-rotation core drill to reduce lumbar stress.',
  },
];

const NECK_ALTERNATIVES: AlternativeExercise[] = [
  {
    id: 'wall-angel',
    name: 'Wall Angels',
    muscleGroup: 'upper_back',
    difficulty: 'low',
    equipment: 'Bodyweight',
    videoUrl: 'https://cdn.fitcoach.app/videos/wall_angel.mp4',
    description: 'Promotes thoracic extension and scapular control.',
  },
];

const ANKLE_ALTERNATIVES: AlternativeExercise[] = [
  {
    id: 'seated-calf-raise-band',
    name: 'Seated Calf Raises with Band',
    muscleGroup: 'calves',
    difficulty: 'low',
    equipment: 'Resistance Band',
    videoUrl: 'https://cdn.fitcoach.app/videos/band_calf_raise.mp4',
    description: 'Restores plantar flexion strength without axial load.',
  },
  {
    id: 'single-leg-balance-pad',
    name: 'Single-Leg Balance on Pad',
    muscleGroup: 'ankle',
    difficulty: 'medium',
    equipment: 'Balance Pad',
    videoUrl: 'https://cdn.fitcoach.app/videos/balance_pad_drill.mp4',
  },
];

const MAP: Record<string, AlternativeExercise[]> = {
  shoulder: SHOULDER_ALTERNATIVES,
  knee: KNEE_ALTERNATIVES,
  lower_back: LOWER_BACK_ALTERNATIVES,
  neck: NECK_ALTERNATIVES,
  ankle: ANKLE_ALTERNATIVES,
};

export const getAlternativesForInjury = (injuryArea: string, muscleGroup?: string): AlternativeExercise[] => {
  const key = injuryArea as keyof typeof MAP;
  const base = MAP[key] ?? [];
  if (!muscleGroup) {
    return base;
  }
  return base.filter((exercise) => exercise.muscleGroup === muscleGroup || injuryArea === 'lower_back');
};
