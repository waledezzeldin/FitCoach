export interface AlternativeExercise {
    id: string;
    name: string;
    muscleGroup: string;
    difficulty: 'low' | 'medium' | 'high';
    equipment?: string;
    videoUrl?: string;
    description?: string;
}
export declare const getAlternativesForInjury: (injuryArea: string, muscleGroup?: string) => AlternativeExercise[];
