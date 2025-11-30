// InBody Scan Types
// Comprehensive body composition analysis parameters

export interface InBodyData {
  // Body Composition Analysis
  totalBodyWater: number; // kg
  intracellularWater: number; // kg
  extracellularWater: number; // kg
  dryLeanMass: number; // kg
  bodyFatMass: number; // kg
  weight: number; // kg
  
  // Muscle-Fat Analysis
  skeletalMuscleMass: number; // kg (SMM)
  bodyShape: 'C' | 'I' | 'D'; // C-shaped, I-shaped, D-shaped
  
  // Obesity Analysis
  bmi: number; // Body Mass Index
  percentBodyFat: number; // %
  
  // Segmental Lean Analysis (muscle distribution)
  segmentalLean: {
    leftArm: number; // % of sufficient muscle (0-150%)
    rightArm: number;
    trunk: number;
    leftLeg: number;
    rightLeg: number;
  };
  
  // Other Important Parameters
  basalMetabolicRate: number; // calories/day (BMR)
  visceralFatLevel: number; // 1-20 scale (VFL)
  ecwTbwRatio: number; // Extracellular Water / Total Body Water ratio
  inBodyScore: number; // 0-100 score
  
  // Metadata
  scanDate: Date;
  scanLocation?: string;
  notes?: string;
}

export interface InBodyHistory {
  scans: InBodyData[];
  latestScan?: InBodyData;
}

// Helper function to calculate body shape based on values
export function calculateBodyShape(
  weight: number,
  smm: number,
  bodyFatMass: number
): 'C' | 'I' | 'D' {
  const smmRatio = smm / weight;
  const fatRatio = bodyFatMass / weight;
  
  if (smmRatio < 0.35) return 'C'; // Less muscle, more fat
  if (smmRatio > 0.42) return 'D'; // High muscle, lower fat (athletic)
  return 'I'; // Balanced
}

// Helper to determine BMI category
export function getBMICategory(bmi: number): string {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal weight';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

// Helper to determine body fat percentage category (varies by gender)
export function getBodyFatCategory(pbf: number, gender: 'male' | 'female' | 'other'): string {
  if (gender === 'male') {
    if (pbf < 6) return 'Essential fat';
    if (pbf < 14) return 'Athletic';
    if (pbf < 18) return 'Fitness';
    if (pbf < 25) return 'Average';
    return 'Obese';
  } else if (gender === 'female') {
    if (pbf < 14) return 'Essential fat';
    if (pbf < 21) return 'Athletic';
    if (pbf < 25) return 'Fitness';
    if (pbf < 32) return 'Average';
    return 'Obese';
  }
  return 'N/A';
}

// Helper to determine visceral fat level category
export function getVisceralFatCategory(vfl: number): string {
  if (vfl < 10) return 'Normal';
  if (vfl < 15) return 'Elevated';
  return 'High Risk';
}

// Helper to get InBody Score interpretation
export function getInBodyScoreCategory(score: number): string {
  if (score >= 90) return 'Excellent';
  if (score >= 80) return 'Good';
  if (score >= 70) return 'Average';
  return 'Needs Improvement';
}
