export type DemoPersona = 'user' | 'coach' | 'admin';
export interface DemoFixture {
    user: Record<string, unknown>;
    subscription: string;
    stats: Record<string, unknown>;
    workoutPlan: Record<string, unknown>;
    nutritionPlan: Record<string, unknown>;
}
export declare const getDemoFixture: (persona: string) => DemoFixture;
export declare const availableDemoPersonas: DemoPersona[];
