const fs = require('fs');
const path = require('path');

const catalogPath = path.resolve(__dirname, '../../mobile/assets/data/exercises_catalog_v1.json');

const missing = [
  'kneeling_push_up',
  'bodyweight_squat',
  'db_overhead_press_seated'
];

const toTitle = (value) => value
  .split('_')
  .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
  .join(' ');

const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));
const existing = new Set((catalog.exercises || []).map((ex) => ex.ex_id));

const placeholder = {
  video_id: null,
  video_url: null,
  thumbnail_url: null,
  equip: [],
  muscles: [],
  instructions_en: 'Instructions coming soon.',
  instructions_ar: 'سيتم إضافة التعليمات قريبًا.',
  common_mistakes_en: 'Common mistakes will be added soon.',
  common_mistakes_ar: 'سيتم إضافة الأخطاء الشائعة قريبًا.',
  default_sets: null,
  default_reps: null,
  default_rest_seconds: null
};

let added = 0;

for (const exId of missing) {
  if (existing.has(exId)) continue;
  catalog.exercises.push({
    ex_id: exId,
    name_en: toTitle(exId),
    name_ar: null,
    ...placeholder
  });
  existing.add(exId);
  added += 1;
}

catalog.total = catalog.exercises.length;
catalog.generated_at = new Date().toISOString();

fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2));

console.log(`Added ${added} missing exercises to catalog.`);
