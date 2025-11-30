// Intake Types for FitCoach+ v2.0

export type MainGoal = 'fat_loss' | 'muscle_gain' | 'general_fitness';
export type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';
export type WorkoutLocation = 'home' | 'gym';
export type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';
export type Gender = 'male' | 'female' | 'other';

// First Intake (IntakeV1) - 3 questions, all users
export interface FirstIntakeData {
  gender: Gender;
  mainGoal: MainGoal;
  workoutLocation: WorkoutLocation;
  completedAt?: Date;
}

// Second Intake (IntakeV2) - Full questionnaire, Premium+ only
export interface SecondIntakeData {
  age: number;
  weight: number; // kg
  height: number; // cm
  experienceLevel: ExperienceLevel;
  workoutFrequency: number; // 2-6 days per week
  injuries: InjuryArea[];
  completedAt?: Date;
}

export interface IntakeValidation {
  isValid: boolean;
  errors: string[];
}

export const validateFirstIntake = (data: Partial<FirstIntakeData>): IntakeValidation => {
  const errors: string[] = [];
  
  if (!data.gender) errors.push('Gender is required');
  if (!data.mainGoal) errors.push('Fitness goal is required');
  if (!data.workoutLocation) errors.push('Workout location is required');
  
  return {
    isValid: errors.length === 0,
    errors
  };
};

export const validateSecondIntake = (data: Partial<SecondIntakeData>): IntakeValidation => {
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
};
