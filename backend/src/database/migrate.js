require('dotenv').config();
const fs = require('fs');
const path = require('path');
const db = require('./index');
const logger = require('../utils/logger');

/**
 * Run database migrations
 */
async function migrate() {
  const client = await db.getClient();
  
  try {
    logger.info('Starting database migration...');
    
    // Read schema file
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    // Execute schema
    await client.query(schema);
    
    logger.info('✅ Database migration completed successfully');
    logger.info('📊 Created:');
    logger.info('   - 20+ tables');
    logger.info('   - 10+ enums');
    logger.info('   - 3 views');
    logger.info('   - 15+ triggers');
    logger.info('   - 40+ indexes');
    
    // Verify tables
    const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `);
    
    logger.info(`\n📋 Tables created (${result.rows.length}):`);
    result.rows.forEach(row => {
      logger.info(`   ✓ ${row.table_name}`);
    });
    
  } catch (error) {
    logger.error('❌ Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await db.end();
  }
}

// Run migration
if (require.main === module) {
  migrate()
    .then(() => {
      logger.info('\n🎉 Migration completed!');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Migration error:', error);
      process.exit(1);
    });
}

module.exports = migrate;
