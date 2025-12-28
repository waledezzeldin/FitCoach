const jwt = require('jsonwebtoken');

/**
 * Generate test JWT token
 */
exports.generateTestToken = (userId, role = 'user', tier = 'freemium') => {
  return jwt.sign(
    { userId, role, tier },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
};

/**
 * Create mock request object
 */
exports.mockRequest = (overrides = {}) => {
  return {
    body: {},
    params: {},
    query: {},
    headers: {},
    user: null,
    ...overrides
  };
};

/**
 * Create mock response object
 */
exports.mockResponse = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  res.send = jest.fn().mockReturnValue(res);
  res.set = jest.fn().mockReturnValue(res);
  return res;
};

/**
 * Create mock next function
 */
exports.mockNext = () => jest.fn();

/**
 * Create test user object
 */
exports.createTestUser = (overrides = {}) => {
  return {
    id: 'test-user-id',
    phone_number: '+966500000001',
    full_name: 'Test User',
    full_name_ar: 'مستخدم تجريبي',
    role: 'user',
    subscription_tier: 'freemium',
    is_verified: true,
    is_active: true,
    quota_reset_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    created_at: new Date(),
    updated_at: new Date(),
    ...overrides
  };
};

/**
 * Create test coach object
 */
exports.createTestCoach = (overrides = {}) => {
  return {
    id: 'test-coach-id',
    user_id: 'test-coach-user-id',
    bio: 'Test coach bio',
    bio_ar: 'السيرة الذاتية للمدرب التجريبي',
    certifications: ['ACE', 'NASM'],
    specializations: ['Weight Loss', 'Muscle Gain'],
    experience_years: 5,
    is_available: true,
    is_approved: true,
    hourly_rate: 200,
    average_rating: 4.5,
    total_ratings: 10,
    created_at: new Date(),
    updated_at: new Date(),
    ...overrides
  };
};

/**
 * Create test workout plan
 */
exports.createTestWorkoutPlan = (overrides = {}) => {
  return {
    id: 'test-workout-id',
    user_id: 'test-user-id',
    coach_id: 'test-coach-id',
    name: 'Test Workout Plan',
    name_ar: 'خطة التمرين التجريبية',
    description: 'Test description',
    goal: 'fat_loss',
    duration_weeks: 8,
    days_per_week: 4,
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
    ...overrides
  };
};

/**
 * Create test nutrition plan
 */
exports.createTestNutritionPlan = (overrides = {}) => {
  return {
    id: 'test-nutrition-id',
    user_id: 'test-user-id',
    coach_id: 'test-coach-id',
    name: 'Test Nutrition Plan',
    name_ar: 'خطة التغذية التجريبية',
    daily_calories: 2000,
    protein_target: 150,
    carbs_target: 200,
    fats_target: 60,
    start_date: new Date(),
    end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
    ...overrides
  };
};

/**
 * Create test exercise
 */
exports.createTestExercise = (overrides = {}) => {
  return {
    id: 'test-exercise-id',
    name: 'Test Exercise',
    name_ar: 'تمرين تجريبي',
    category: 'Chest',
    muscle_group: 'Chest, Triceps',
    equipment: 'Barbell',
    difficulty: 'intermediate',
    contraindications: ['shoulder_injury'],
    instructions: 'Test instructions',
    instructions_ar: 'تعليمات تجريبية',
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
    ...overrides
  };
};

/**
 * Create test rating
 */
exports.createTestRating = (overrides = {}) => {
  return {
    id: 'test-rating-id',
    user_id: 'test-user-id',
    coach_id: 'test-coach-id',
    context: 'video_call',
    reference_id: 'test-booking-id',
    rating: 5,
    feedback: 'Great session!',
    created_at: new Date(),
    ...overrides
  };
};

/**
 * Wait for async operations
 */
exports.waitFor = (ms) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Clean up test data
 */
exports.cleanupTestData = async (db, tables) => {
  for (const table of tables) {
    await db.query(`DELETE FROM ${table} WHERE id LIKE 'test-%'`);
  }
};
