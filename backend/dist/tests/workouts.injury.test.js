"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const injury_map_1 = require("../src/workouts/injury-map");
describe('getAlternativesForInjury', () => {
    it('returns alternatives for known injury', () => {
        const result = (0, injury_map_1.getAlternativesForInjury)('shoulder');
        expect(result.length).toBeGreaterThan(0);
        expect(result[0]).toHaveProperty('name');
    });
    it('filters by muscle group when provided', () => {
        const result = (0, injury_map_1.getAlternativesForInjury)('shoulder', 'back');
        expect(result.every((item) => item.muscleGroup === 'back' || item.muscleGroup === 'lower_back')).toBe(true);
    });
    it('returns empty array for unknown injuries', () => {
        expect((0, injury_map_1.getAlternativesForInjury)('unknown').length).toBe(0);
    });
});
//# sourceMappingURL=workouts.injury.test.js.map