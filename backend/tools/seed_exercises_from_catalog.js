const fs = require('fs').promises;
const path = require('path');
const db = require('../src/database');

const catalogPath = path.resolve(__dirname, '../../mobile/assets/data/exercises_catalog_v1.json');

const normalizeJsonArray = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  return [value];
};

const main = async () => {
  const content = await fs.readFile(catalogPath, 'utf8');
  const catalog = JSON.parse(content);
  const exercises = catalog.exercises || [];

  const client = await db.getClient();

  let inserted = 0;
  let updated = 0;

  try {
    await client.query('BEGIN');

    for (const ex of exercises) {
      const exId = ex.ex_id;
      if (!exId) continue;

      const existing = await client.query(
        'SELECT id FROM exercises WHERE ex_id = $1',
        [exId]
      );

        const resolvedName = ex.name_en || exId;
        const resolvedNameAr = ex.name_ar || resolvedName;

        const values = [
          exId,
          resolvedName,
          resolvedNameAr,
            normalizeJsonArray(ex.muscles),
            normalizeJsonArray(ex.equip),
            ex.video_url || null,
            ex.thumbnail_url || null,
            ex.instructions_en || null,
            ex.instructions_ar || null,
            ex.common_mistakes_en || null,
            ex.common_mistakes_ar || null,
            ex.default_sets || null,
            ex.default_reps || null,
            ex.default_rest_seconds || null
          ];

      if (existing.rows.length > 0) {
        await client.query(
          `UPDATE exercises
           SET name = $2,
               name_en = $2,
               name_ar = $3,
               muscle_groups = $4,
               equipment = $5,
               video_url = $6,
               thumbnail_url = $7,
               instructions_en = $8,
               instructions_ar = $9,
               common_mistakes_en = $10,
               common_mistakes_ar = $11,
               default_sets = $12,
               default_reps = $13,
               default_rest_seconds = $14,
               updated_at = NOW()
           WHERE ex_id = $1`,
          values
        );
        updated += 1;
      } else {
        await client.query(
          `INSERT INTO exercises (
            ex_id, name, name_en, name_ar, muscle_groups, equipment,
            video_url, thumbnail_url, instructions_en, instructions_ar,
            common_mistakes_en, common_mistakes_ar,
            default_sets, default_reps, default_rest_seconds,
            created_at, updated_at
          ) VALUES (
            $1, $2, $2, $3, $4, $5,
            $6, $7, $8, $9,
            $10, $11,
            $12, $13, $14,
            NOW(), NOW()
          )`,
          values
        );
        inserted += 1;
      }
    }

    await client.query('COMMIT');
    // eslint-disable-next-line no-console
    console.log(`Exercises seeded. Inserted: ${inserted}, Updated: ${updated}`);
  } catch (error) {
    await client.query('ROLLBACK');
    // eslint-disable-next-line no-console
    console.error('Failed to seed exercises:', error.message);
    process.exitCode = 1;
  } finally {
    client.release();
    await db.end();
  }
};

main();
