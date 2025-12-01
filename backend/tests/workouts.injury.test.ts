import { getAlternativesForInjury } from '../src/workouts/injury-map';

describe('getAlternativesForInjury', () => {
  it('returns alternatives for known injury', () => {
    const result = getAlternativesForInjury('shoulder');
    expect(result.length).toBeGreaterThan(0);
    expect(result[0]).toHaveProperty('name');
  });

  it('filters by muscle group when provided', () => {
    const result = getAlternativesForInjury('shoulder', 'back');
    expect(result.every((item) => item.muscleGroup === 'back' || item.muscleGroup === 'lower_back')).toBe(true);
  });

  it('returns empty array for unknown injuries', () => {
    expect(getAlternativesForInjury('unknown').length).toBe(0);
  });
});
