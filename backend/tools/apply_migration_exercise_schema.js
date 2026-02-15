const fs = require('fs').promises;
const path = require('path');
const db = require('../src/database');

const migrationPath = path.resolve(__dirname, '../src/database/migrations/008_exercise_schema_alignment.sql');

const main = async () => {
  const content = await fs.readFile(migrationPath, 'utf8');

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    await client.query(content);
    await client.query('COMMIT');
    // eslint-disable-next-line no-console
    console.log('Migration applied successfully.');
  } catch (error) {
    await client.query('ROLLBACK');
    // eslint-disable-next-line no-console
    console.error('Migration failed:', error.message);
    process.exitCode = 1;
  } finally {
    client.release();
    await db.end();
  }
};

main();
