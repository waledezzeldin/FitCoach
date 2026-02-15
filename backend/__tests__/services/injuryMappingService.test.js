const injuryMappingService = require('../../src/services/injuryMappingService');

jest.mock('../../src/utils/logger', () => ({
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn()
}));

describe('InjuryMappingService', () => {
  beforeEach(() => {
    injuryMappingService.injuryMappings = {
      shoulder: {
        description_en: 'Shoulder pain',
        description_ar: 'ألم الكتف',
        avoid_keywords: ['bench'],
        substitute_exercises: ['push_up']
      }
    };
    injuryMappingService.loaded = true;
  });

  it('applies injury swaps and records substitution reason', async () => {
    const session = {
      work: [
        {
          ex_id: 'bench_press',
          name_en: 'Bench Press',
          name_ar: 'بنش برس',
          sets: 3,
          reps: '10'
        }
      ]
    };

    const exerciseLibrary = {
      push_up: {
        name_en: 'Push Up',
        name_ar: 'ضغط',
        video_id: 'vid1',
        equip: [],
        muscles: []
      }
    };

    const updated = await injuryMappingService.applyInjurySwapsToSession(
      session,
      ['shoulder'],
      exerciseLibrary
    );

    const swapped = updated.work[0];
    expect(swapped.was_substituted).toBe(true);
    expect(swapped.original_ex_id).toBe('bench_press');
    expect(swapped.substitution_reason).toContain('bench');
    expect(swapped.ex_id).toBe('push_up');
  });
});
