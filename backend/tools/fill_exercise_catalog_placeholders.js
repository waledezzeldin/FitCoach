const fs = require('fs');
const path = require('path');

const catalogPath = path.resolve(__dirname, '../../mobile/assets/data/exercises_catalog_v1.json');

const placeholder = {
  instructions_en: 'Instructions coming soon.',
  instructions_ar: 'سيتم إضافة التعليمات قريبًا.',
  common_mistakes_en: 'Common mistakes will be added soon.',
  common_mistakes_ar: 'سيتم إضافة الأخطاء الشائعة قريبًا.'
};

const shouldFill = (value) => value === null || value === undefined || String(value).trim().length === 0;

const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));

let updated = 0;

catalog.exercises = (catalog.exercises || []).map((exercise) => {
  const updatedExercise = { ...exercise };

  for (const key of Object.keys(placeholder)) {
    if (shouldFill(updatedExercise[key])) {
      updatedExercise[key] = placeholder[key];
      updated += 1;
    }
  }

  return updatedExercise;
});

catalog.generated_at = new Date().toISOString();

fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2));

console.log(`Updated ${updated} placeholder fields in exercises catalog.`);
