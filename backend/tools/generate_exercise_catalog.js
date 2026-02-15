const fs = require('fs').promises;
const path = require('path');

const templatesDir = path.resolve(__dirname, '../../mobile/assets/data/new');
const outputPath = path.resolve(__dirname, '../../mobile/assets/data/exercises_catalog_v1.json');

const normalizeArray = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value.filter(Boolean);
  return [value].filter(Boolean);
};

const mergeUnique = (target, values) => {
  const set = new Set(target);
  values.forEach((val) => set.add(val));
  return Array.from(set);
};

const collectExercise = (map, ex) => {
  if (!ex || !ex.ex_id) return;
  const existing = map.get(ex.ex_id) || {
    ex_id: ex.ex_id,
    name_en: ex.name_en || ex.name || null,
    name_ar: ex.name_ar || null,
    equip: [],
    muscles: [],
    video_id: ex.video_id || null,
    video_url: null,
    thumbnail_url: null,
    instructions_en: '',
    instructions_ar: '',
    common_mistakes_en: '',
    common_mistakes_ar: '',
    default_sets: null,
    default_reps: null,
    default_rest_seconds: null
  };

  if (!existing.name_en && (ex.name_en || ex.name)) {
    existing.name_en = ex.name_en || ex.name;
  }
  if (!existing.name_ar && ex.name_ar) {
    existing.name_ar = ex.name_ar;
  }
  if (!existing.video_id && ex.video_id) {
    existing.video_id = ex.video_id;
  }

  existing.equip = mergeUnique(existing.equip, normalizeArray(ex.equip));
  existing.muscles = mergeUnique(existing.muscles, normalizeArray(ex.muscles));

  map.set(ex.ex_id, existing);
};

const readJson = async (filePath) => {
  const content = await fs.readFile(filePath, 'utf8');
  return JSON.parse(content);
};

const getAllTemplateFiles = async () => {
  const files = await fs.readdir(templatesDir);
  return files
    .filter((file) => file.endsWith('.json') && !file.startsWith('.'))
    .filter((file) => !file.includes('injury_swap_table'))
    .map((file) => path.join(templatesDir, file));
};

const collectFromTemplate = (map, template) => {
  if (!template || typeof template !== 'object') return;

  if (Array.isArray(template.exercises)) {
    template.exercises.forEach((exercise) => collectExercise(map, exercise));
  }

  if (Array.isArray(template.sessions)) {
    template.sessions.forEach((session) => {
      if (!session.work) return;
      session.work.forEach((exercise) => collectExercise(map, exercise));
    });
  }

  if (template.programs && typeof template.programs === 'object') {
    Object.values(template.programs).forEach((goals) => {
      if (!goals || typeof goals !== 'object') return;
      Object.values(goals).forEach((experiences) => {
        if (!experiences || typeof experiences !== 'object') return;
        Object.values(experiences).forEach((sessions) => {
          if (!Array.isArray(sessions)) return;
          sessions.forEach((session) => {
            if (!session.work) return;
            session.work.forEach((exercise) => collectExercise(map, exercise));
          });
        });
      });
    });
  }
};

const main = async () => {
  const exerciseMap = new Map();
  const files = await getAllTemplateFiles();

  for (const file of files) {
    try {
      const template = await readJson(file);
      collectFromTemplate(exerciseMap, template);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.warn(`Skipping invalid JSON: ${file}`);
      // eslint-disable-next-line no-console
      console.warn(error.message);
    }
  }

  const exercises = Array.from(exerciseMap.values())
    .sort((a, b) => a.ex_id.localeCompare(b.ex_id));

  const output = {
    generated_at: new Date().toISOString(),
    source: 'mobile/assets/data/new',
    total: exercises.length,
    exercises
  };

  await fs.writeFile(outputPath, JSON.stringify(output, null, 2), 'utf8');
  // eslint-disable-next-line no-console
  console.log(`Generated ${exercises.length} exercises → ${outputPath}`);
};

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
