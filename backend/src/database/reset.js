require('dotenv').config();
const db = require('./index');
const logger = require('../utils/logger');
const migrate = require('./migrate');
const seed = require('./seed');

/**
 * Reset database - drop all, migrate, and seed
 */
async function reset() {
  const client = await db.getClient();
  
  try {
    logger.info('⚠️  WARNING: This will destroy all data!');
    logger.info('Resetting database in 3 seconds...');
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    logger.info('Dropping all tables...');
    
    // Drop all tables
    await client.query(`
      DROP SCHEMA public CASCADE;
      CREATE SCHEMA public;
      GRANT ALL ON SCHEMA public TO postgres;
      GRANT ALL ON SCHEMA public TO public;
    `);
    
    logger.info('✅ All tables dropped');
    
  } catch (error) {
    logger.error('❌ Reset failed:', error);
    throw error;
  } finally {
    client.release();
  }
  
  // Run migration
  logger.info('\nRunning migration...');
  await migrate();
  
  // Run seed
  logger.info('\nRunning seed...');
  await seed();
  
  logger.info('\n🎉 Database reset completed!');
}

// Run reset
if (require.main === module) {
  reset()
    .then(() => {
      logger.info('\n✅ Reset completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Reset error:', error);
      process.exit(1);
    });
}

module.exports = reset;
