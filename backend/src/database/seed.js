require('dotenv').config();
const db = require('./index');
const logger = require('../utils/logger');
const bcrypt = require('bcryptjs');

/**
 * Seed database with sample data
 */
async function seed() {
  const client = await db.getClient();
  
  try {
    logger.info('Starting database seeding...');
    
    await client.query('BEGIN');

    const testPassword = 'TestPass123!';
    const passwordHash = await bcrypt.hash(testPassword, 10);
    
    // 1. Create admin user
    logger.info('Creating admin user...');
    const adminResult = await client.query(`
      INSERT INTO users (
        phone_number, full_name, full_name_ar, role, subscription_tier, password_hash,
        is_verified, is_active, quota_reset_date
      ) VALUES (
        '+966500000001', 'Admin User', 'U.O_USO? OU,U+O,OU.', 'admin', 'smart_premium', $1,
        TRUE, TRUE, NOW() + INTERVAL '1 month'
      ) RETURNING id
    `, [passwordHash]);
    const adminId = adminResult.rows[0].id;
    logger.info(`✅ Admin created: ${adminId}`);
    
    // 2. Create sample coaches
    logger.info('Creating sample coaches...');
    const coaches = [];
    for (let i = 1; i <= 3; i++) {
      const coachUserResult = await client.query(`
        INSERT INTO users (
          phone_number, full_name, full_name_ar, role, subscription_tier, password_hash,
          is_verified, is_active, quota_reset_date
        ) VALUES (
          $1, $2, $3, 'coach', 'smart_premium', $4, TRUE, TRUE, NOW() + INTERVAL '1 month'
        ) RETURNING id
      `, [`+96650000000${i + 1}`, `Coach ${i}`, `مدرب ${i}`, passwordHash]);
      
      const coachUserId = coachUserResult.rows[0].id;
      
      const coachResult = await client.query(`
        INSERT INTO coaches (
          user_id, bio, bio_ar, certifications, specializations,
          experience_years, is_available, is_approved, hourly_rate
        ) VALUES (
          $1, $2, $3, $4, $5, $6, TRUE, TRUE, $7
        ) RETURNING id
      `, [
        coachUserId,
        `Certified fitness coach with ${i + 3} years of experience`,
        `مدرب لياقة معتمد مع ${i + 3} سنوات من الخبرة`,
        ['ACE Certified', 'NASM CPT'],
        ['Weight Loss', 'Muscle Gain', 'Athletic Performance'],
        i + 3,
        150 + (i * 50)
      ]);
      
      coaches.push(coachResult.rows[0].id);
    }
    logger.info(`✅ ${coaches.length} coaches created`);
    
    // 3. Create sample users
    logger.info('Creating sample users...');
    const users = [];
    for (let i = 1; i <= 10; i++) {
      const tier = i <= 3 ? 'smart_premium' : (i <= 7 ? 'premium' : 'freemium');
      const userResult = await client.query(`
        INSERT INTO users (
          phone_number, full_name, full_name_ar, subscription_tier, password_hash,
          is_verified, is_active, quota_reset_date,
          goal, fitness_level, age, weight, height, activity_level,
          first_intake_completed
        ) VALUES (
          $1, $2, $3, $4, $5, TRUE, TRUE, NOW() + INTERVAL '1 month',
          'fat_loss', 'beginner', ${20 + i}, ${70 + i}, ${170 + i}, 'moderately_active',
          TRUE
        ) RETURNING id
      `, [`+96650000${1000 + i}`, `User ${i}`, `مستخدم ${i}`, tier, passwordHash]);
      
      users.push(userResult.rows[0].id);
    }
    logger.info(`✅ ${users.length} users created`);
    
    // 4. Create sample exercises
    logger.info('Creating sample exercises...');
    const exercises = [
      {
        name: 'Barbell Bench Press',
        nameAr: 'ضغط البار المسطح',
        category: 'Chest',
        muscleGroup: 'Chest, Triceps, Shoulders',
        equipment: 'Barbell',
        difficulty: 'intermediate',
        contraindications: ['shoulder_injury', 'wrist_pain']
      },
      {
        name: 'Squat',
        nameAr: 'السكوات',
        category: 'Legs',
        muscleGroup: 'Quadriceps, Glutes, Hamstrings',
        equipment: 'Barbell',
        difficulty: 'intermediate',
        contraindications: ['knee_injury', 'back_pain']
      },
      {
        name: 'Deadlift',
        nameAr: 'الرفعة المميتة',
        category: 'Back',
        muscleGroup: 'Back, Hamstrings, Glutes',
        equipment: 'Barbell',
        difficulty: 'advanced',
        contraindications: ['back_injury', 'herniated_disc']
      },
      {
        name: 'Push-ups',
        nameAr: 'تمارين الضغط',
        category: 'Chest',
        muscleGroup: 'Chest, Triceps, Core',
        equipment: 'Bodyweight',
        difficulty: 'beginner',
        contraindications: ['shoulder_injury', 'wrist_pain']
      },
      {
        name: 'Pull-ups',
        nameAr: 'العقلة',
        category: 'Back',
        muscleGroup: 'Back, Biceps',
        equipment: 'Pull-up Bar',
        difficulty: 'intermediate',
        contraindications: ['shoulder_injury', 'elbow_pain']
      },
      {
        name: 'Dumbbell Shoulder Press',
        nameAr: 'ضغط الكتف بالدمبل',
        category: 'Shoulders',
        muscleGroup: 'Shoulders, Triceps',
        equipment: 'Dumbbell',
        difficulty: 'beginner',
        contraindications: ['shoulder_injury', 'rotator_cuff_injury']
      },
      {
        name: 'Lunges',
        nameAr: 'الطعنات',
        category: 'Legs',
        muscleGroup: 'Quadriceps, Glutes',
        equipment: 'Bodyweight',
        difficulty: 'beginner',
        contraindications: ['knee_injury']
      },
      {
        name: 'Plank',
        nameAr: 'البلانك',
        category: 'Core',
        muscleGroup: 'Core, Shoulders',
        equipment: 'Bodyweight',
        difficulty: 'beginner',
        contraindications: ['back_pain', 'shoulder_injury']
      }
    ];
    
    const exerciseIds = [];
    for (const ex of exercises) {
      const result = await client.query(`
        INSERT INTO exercises (
          name, name_ar, name_en, category, muscle_group,
          equipment, difficulty, contraindications,
          instructions, instructions_ar, instructions_en,
          is_active
        ) VALUES ($1, $2, $1, $3, $4, $5, $6, $7, $8, $9, $8, TRUE)
        RETURNING id
      `, [
        ex.name, ex.nameAr, ex.category, ex.muscleGroup,
        ex.equipment, ex.difficulty, ex.contraindications,
        `Perform ${ex.name} with proper form`,
        `قم بأداء ${ex.nameAr} بالشكل الصحيح`
      ]);
      exerciseIds.push(result.rows[0].id);
    }
    logger.info(`✅ ${exerciseIds.length} exercises created`);
    
    // 5. Create sample products
    logger.info('Creating sample products...');
    const products = [
      { name: 'Whey Protein', nameAr: 'بروتين واي', category: 'supplements', price: 199.99 },
      { name: 'Resistance Bands', nameAr: 'أحزمة المقاومة', category: 'equipment', price: 79.99 },
      { name: 'Yoga Mat', nameAr: 'سجادة يوغا', category: 'equipment', price: 49.99 },
      { name: 'Gym Gloves', nameAr: 'قفازات رياضية', category: 'apparel', price: 29.99 },
      { name: 'BCAA', nameAr: 'بي سي اي اي', category: 'supplements', price: 149.99 }
    ];
    
    for (const product of products) {
      await client.query(`
        INSERT INTO products (
          name, name_ar, name_en, description, description_ar, description_en,
          category, price, currency, stock_quantity, is_active, is_featured
        ) VALUES ($1, $2, $1, $3, $4, $3, $5, $6, 'SAR', 100, TRUE, FALSE)
      `, [
        product.name, product.nameAr,
        `High quality ${product.name}`,
        `${product.nameAr} عالي الجودة`,
        product.category, product.price
      ]);
    }
    logger.info(`✅ ${products.length} products created`);
    
    await client.query('COMMIT');
    
    logger.info('\n🎉 Database seeded successfully!');
    logger.info('\n📊 Summary:');
    logger.info(`   ✓ 1 Admin user`);
    logger.info(`   ✓ ${coaches.length} Coaches`);
    logger.info(`   ✓ ${users.length} Regular users`);
    logger.info(`   ✓ ${exerciseIds.length} Exercises`);
    logger.info(`   ✓ ${products.length} Products`);
    
    logger.info('\n🔑 Test Credentials:');
    logger.info('   Admin: +966500000001');
    logger.info('   Coach 1: +966500000002');
    logger.info('   User 1: +966500001001 (Smart Premium)');
    logger.info('   User 8: +966500001008 (Freemium)');
    logger.info(`   Password: ${testPassword}`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('❌ Seeding failed:', error);
    throw error;
  } finally {
    client.release();
    await db.end();
  }
}

// Run seed
if (require.main === module) {
  seed()
    .then(() => {
      logger.info('\n✅ Seeding completed!');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Seeding error:', error);
      process.exit(1);
    });
}

module.exports = seed;
