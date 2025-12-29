-- ============================================
-- FitCoach+ v2.0 Database Schema (PostgreSQL)
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE user_role AS ENUM ('user', 'coach', 'admin');
CREATE TYPE subscription_tier AS ENUM ('freemium', 'premium', 'smart_premium');
CREATE TYPE gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE goal_type AS ENUM ('fat_loss', 'muscle_gain', 'maintenance', 'athletic_performance', 'general_fitness');
CREATE TYPE fitness_level AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE activity_level AS ENUM ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active');
CREATE TYPE message_type AS ENUM ('text', 'image', 'video', 'audio', 'file');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- ============================================
-- USERS TABLE
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    phone_country_code VARCHAR(5) DEFAULT '+966',
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    
    -- Profile Information
    full_name VARCHAR(255),
    full_name_ar VARCHAR(255),
    date_of_birth DATE,
    gender gender,
    profile_photo_url TEXT,
    
    -- Role & Subscription
    role user_role DEFAULT 'user',
    subscription_tier subscription_tier DEFAULT 'freemium',
    subscription_start_date TIMESTAMP,
    subscription_end_date TIMESTAMP,
    
    -- First Intake (5 questions - all users)
    goal goal_type,
    fitness_level fitness_level,
    age INTEGER,
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    activity_level activity_level,
    dietary_preferences TEXT[],
    first_intake_completed BOOLEAN DEFAULT FALSE,
    
    -- Second Intake (6 questions - Premium+ only)
    health_history TEXT,
    injuries TEXT[],
    medications TEXT[],
    medical_conditions TEXT[],
    specific_goals TEXT,
    training_history TEXT,
    second_intake_completed BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    preferred_language VARCHAR(2) DEFAULT 'ar', -- 'ar' or 'en'
    theme VARCHAR(10) DEFAULT 'light', -- 'light' or 'dark'
    notifications_enabled BOOLEAN DEFAULT TRUE,
    
    -- Nutrition Trial (Freemium)
    nutrition_trial_start_date TIMESTAMP,
    nutrition_trial_active BOOLEAN DEFAULT FALSE,
    
    -- Quotas (reset monthly)
    messages_sent_this_month INTEGER DEFAULT 0,
    video_calls_this_month INTEGER DEFAULT 0,
    quota_reset_date TIMESTAMP,
    
    -- Coach Assignment
    assigned_coach_id UUID,

    -- Fitness Score
    fitness_score INTEGER,
    fitness_score_updated_by VARCHAR(20),
    fitness_score_last_updated TIMESTAMP,

    -- Tracking
    last_login TIMESTAMP,
    login_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    suspension_reason TEXT,
    suspended_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_phone CHECK (phone_number ~ '^\+?[1-9]\d{1,14}$')
);

-- ============================================
-- OTP VERIFICATION TABLE
-- ============================================

CREATE TABLE otp_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    attempts INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_otp CHECK (otp_code ~ '^\d{4,6}$')
);

CREATE INDEX idx_otp_phone ON otp_verifications(phone_number);
CREATE INDEX idx_otp_expiry ON otp_verifications(expires_at);

-- ============================================
-- COACHES TABLE
-- ============================================

CREATE TABLE coaches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Professional Info
    bio TEXT,
    bio_ar TEXT,
    certifications TEXT[],
    specializations TEXT[],
    experience_years INTEGER,
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    max_clients INTEGER DEFAULT 50,
    current_client_count INTEGER DEFAULT 0,
    
    -- Pricing
    hourly_rate DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'SAR',
    
    -- Commission (for store sales)
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    
    -- Rating
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INTEGER DEFAULT 0,
    
    -- Approval
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    suspension_reason TEXT,
    suspended_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coaches_user ON coaches(user_id);
CREATE INDEX idx_coaches_available ON coaches(is_available);

-- ============================================
-- USER_COACHES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS user_coaches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, coach_id)
);

CREATE INDEX idx_user_coaches_user ON user_coaches(user_id);
CREATE INDEX idx_user_coaches_coach ON user_coaches(coach_id);
CREATE INDEX idx_user_coaches_active ON user_coaches(is_active);

-- ============================================
-- APPOINTMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    scheduled_at TIMESTAMP NOT NULL,
    duration_minutes INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_coach ON appointments(coach_id);
CREATE INDEX idx_appointments_user ON appointments(user_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_scheduled_at ON appointments(scheduled_at);

-- ============================================
-- COACH_EARNINGS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS coach_earnings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    coach_commission DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'paid',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coach_earnings_coach ON coach_earnings(coach_id);
CREATE INDEX idx_coach_earnings_status ON coach_earnings(status);

-- ============================================
-- COACH_RATINGS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS coach_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coach_ratings_coach ON coach_ratings(coach_id);

-- ============================================
-- FITNESS_SCORE_HISTORY TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS fitness_score_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    notes TEXT,
    assigned_by VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fitness_score_user ON fitness_score_history(user_id);
CREATE INDEX idx_fitness_score_coach ON fitness_score_history(coach_id);

-- ============================================
-- COACH_CERTIFICATES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS coach_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    issuer VARCHAR(255),
    date_obtained DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coach_certificates_coach ON coach_certificates(coach_id);

-- ============================================
-- COACH_EXPERIENCES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS coach_experiences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coach_experiences_coach ON coach_experiences(coach_id);

-- ============================================
-- COACH_ACHIEVEMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS coach_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coach_achievements_coach ON coach_achievements(coach_id);

-- ============================================
-- PAYMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'SAR',
    status payment_status DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================
-- SUBSCRIPTION_PLANS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'SAR',
    duration_months INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscription_plans_active ON subscription_plans(is_active);

-- ============================================
-- SYSTEM_SETTINGS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- EXERCISES TABLE
-- ============================================

CREATE TABLE exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Names
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    
    -- Details
    category VARCHAR(100), -- 'Chest', 'Back', 'Legs', etc.
    muscle_group VARCHAR(100),
    equipment VARCHAR(100), -- 'Barbell', 'Dumbbell', 'Bodyweight', etc.
    difficulty fitness_level DEFAULT 'beginner',
    
    -- Media
    video_url TEXT,
    thumbnail_url TEXT,
    
    -- Instructions
    instructions TEXT,
    instructions_ar TEXT,
    instructions_en TEXT,
    
    -- Safety
    contraindications TEXT[], -- List of injuries that conflict with this exercise
    alternatives UUID[], -- Array of alternative exercise IDs
    
    -- Tags
    tags TEXT[],
    
    -- Tracking
    is_active BOOLEAN DEFAULT TRUE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_exercises_category ON exercises(category);
CREATE INDEX idx_exercises_muscle ON exercises(muscle_group);
CREATE INDEX idx_exercises_equipment ON exercises(equipment);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);

-- ============================================
-- WORKOUT PLANS TABLE
-- ============================================

CREATE TABLE workout_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id),
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    start_date DATE NOT NULL,
    end_date DATE,
    
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workout_plans_user ON workout_plans(user_id);
CREATE INDEX idx_workout_plans_coach ON workout_plans(coach_id);
CREATE INDEX idx_workout_plans_active ON workout_plans(is_active);

-- ============================================
-- WORKOUT DAYS TABLE
-- ============================================

CREATE TABLE workout_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_plan_id UUID NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
    
    day_name VARCHAR(50) NOT NULL, -- 'Monday', 'Tuesday', etc.
    day_number INTEGER NOT NULL CHECK (day_number BETWEEN 1 AND 7),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(workout_plan_id, day_number)
);

CREATE INDEX idx_workout_days_plan ON workout_days(workout_plan_id);

-- ============================================
-- WORKOUT EXERCISES TABLE
-- ============================================

CREATE TABLE workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_day_id UUID NOT NULL REFERENCES workout_days(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    
    sets INTEGER NOT NULL,
    reps VARCHAR(50) NOT NULL, -- Can be '8-10', '12', 'AMRAP', etc.
    rest_time VARCHAR(20), -- '90s', '2min', etc.
    tempo VARCHAR(20), -- '2-0-2-0', etc.
    notes TEXT,
    
    order_index INTEGER NOT NULL,
    
    -- Substitution
    was_substituted BOOLEAN DEFAULT FALSE,
    original_exercise_id UUID REFERENCES exercises(id),
    substitution_reason TEXT,
    
    -- Completion
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workout_exercises_day ON workout_exercises(workout_day_id);
CREATE INDEX idx_workout_exercises_exercise ON workout_exercises(exercise_id);

-- ============================================
-- NUTRITION PLANS TABLE
-- ============================================

CREATE TABLE nutrition_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id),
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    daily_calories INTEGER NOT NULL,
    protein_target DECIMAL(6,2) NOT NULL,
    carbs_target DECIMAL(6,2) NOT NULL,
    fats_target DECIMAL(6,2) NOT NULL,
    
    start_date DATE NOT NULL,
    end_date DATE,
    
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nutrition_plans_user ON nutrition_plans(user_id);
CREATE INDEX idx_nutrition_plans_coach ON nutrition_plans(coach_id);
CREATE INDEX idx_nutrition_plans_active ON nutrition_plans(is_active);

-- ============================================
-- DAY MEAL PLANS TABLE
-- ============================================

CREATE TABLE day_meal_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nutrition_plan_id UUID NOT NULL REFERENCES nutrition_plans(id) ON DELETE CASCADE,
    
    day_name VARCHAR(50) NOT NULL,
    day_number INTEGER NOT NULL CHECK (day_number BETWEEN 1 AND 7),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(nutrition_plan_id, day_number)
);

CREATE INDEX idx_day_meal_plans_nutrition ON day_meal_plans(nutrition_plan_id);

-- ============================================
-- MEALS TABLE
-- ============================================

CREATE TABLE meals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_meal_plan_id UUID NOT NULL REFERENCES day_meal_plans(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    
    type VARCHAR(50) NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack'
    time TIME NOT NULL,
    
    calories INTEGER NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbs DECIMAL(6,2) NOT NULL,
    fats DECIMAL(6,2) NOT NULL,
    
    instructions TEXT,
    instructions_ar TEXT,
    instructions_en TEXT,
    
    image_url TEXT,
    order_index INTEGER NOT NULL,
    
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_meals_day ON meals(day_meal_plan_id);
CREATE INDEX idx_meals_type ON meals(type);

-- ============================================
-- FOOD ITEMS TABLE
-- ============================================

CREATE TABLE food_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    
    quantity DECIMAL(8,2) NOT NULL,
    unit VARCHAR(50) NOT NULL, -- 'g', 'ml', 'pieces', 'cups', etc.
    
    calories INTEGER NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbs DECIMAL(6,2) NOT NULL,
    fats DECIMAL(6,2) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_food_items_meal ON food_items(meal_id);

-- ============================================
-- CONVERSATIONS TABLE
-- ============================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    
    last_message_content TEXT,
    last_message_at TIMESTAMP,
    
    user_unread_count INTEGER DEFAULT 0,
    coach_unread_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, coach_id)
);

CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_coach ON conversations(coach_id);

-- ============================================
-- MESSAGES TABLE
-- ============================================

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    
    content TEXT NOT NULL,
    type message_type DEFAULT 'text',
    
    attachment_url TEXT,
    attachment_type VARCHAR(100),
    attachment_size INTEGER,
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- ============================================
-- VIDEO CALL BOOKINGS TABLE
-- ============================================

CREATE TABLE video_call_bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id),
    
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    
    status booking_status DEFAULT 'pending',
    
    meeting_url TEXT,
    meeting_id VARCHAR(255),
    
    notes TEXT,
    
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP,
    
    completed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bookings_user ON video_call_bookings(user_id);
CREATE INDEX idx_bookings_coach ON video_call_bookings(coach_id);
CREATE INDEX idx_bookings_date ON video_call_bookings(scheduled_date);
CREATE INDEX idx_bookings_status ON video_call_bookings(status);

-- ============================================
-- RATINGS TABLE
-- ============================================

CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id),
    
    -- Rating Context
    context VARCHAR(50) NOT NULL, -- 'message', 'video_call', 'workout', 'nutrition'
    reference_id UUID, -- ID of the related entity
    
    -- Rating
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ratings_user ON ratings(user_id);
CREATE INDEX idx_ratings_coach ON ratings(coach_id);
CREATE INDEX idx_ratings_context ON ratings(context);

-- ============================================
-- PRODUCTS TABLE
-- ============================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    
    description TEXT,
    description_ar TEXT,
    description_en TEXT,
    
    category VARCHAR(100) NOT NULL, -- 'supplements', 'equipment', 'apparel', etc.
    
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'SAR',
    
    stock_quantity INTEGER DEFAULT 0,
    
    images TEXT[], -- Array of image URLs
    
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);

-- ============================================
-- ORDERS TABLE
-- ============================================

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0.00,
    shipping DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL,
    
    currency VARCHAR(3) DEFAULT 'SAR',
    
    status order_status DEFAULT 'pending',
    payment_status payment_status DEFAULT 'pending',
    
    -- Shipping Address
    shipping_address_line1 TEXT,
    shipping_address_line2 TEXT,
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100) DEFAULT 'Saudi Arabia',
    
    -- Payment
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(255),
    
    notes TEXT,
    
    placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);

-- ============================================
-- ORDER ITEMS TABLE
-- ============================================

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================
-- PROGRESS TRACKING TABLE
-- ============================================

CREATE TABLE progress_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    
    weight DECIMAL(5,2),
    body_fat_percentage DECIMAL(4,2),
    
    -- Body Measurements (cm)
    chest DECIMAL(5,2),
    waist DECIMAL(5,2),
    hips DECIMAL(5,2),
    biceps_left DECIMAL(5,2),
    biceps_right DECIMAL(5,2),
    thigh_left DECIMAL(5,2),
    thigh_right DECIMAL(5,2),
    
    -- Photos
    front_photo_url TEXT,
    side_photo_url TEXT,
    back_photo_url TEXT,
    
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, date)
);

CREATE INDEX idx_progress_user ON progress_entries(user_id);
CREATE INDEX idx_progress_date ON progress_entries(date DESC);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255),
    title_en VARCHAR(255),
    
    message TEXT NOT NULL,
    message_ar TEXT,
    message_en TEXT,
    
    type VARCHAR(50) NOT NULL, -- 'message', 'booking', 'workout', 'nutrition', 'system'
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    action_url TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================
-- AUDIT LOGS TABLE
-- ============================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    
    action VARCHAR(100) NOT NULL, -- 'user_created', 'login', 'workout_completed', etc.
    entity_type VARCHAR(50), -- 'user', 'workout', 'message', etc.
    entity_id UUID,
    
    old_values JSONB,
    new_values JSONB,
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_coaches_updated_at BEFORE UPDATE ON coaches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exercises_updated_at BEFORE UPDATE ON exercises
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_plans_updated_at BEFORE UPDATE ON workout_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_days_updated_at BEFORE UPDATE ON workout_days
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_exercises_updated_at BEFORE UPDATE ON workout_exercises
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nutrition_plans_updated_at BEFORE UPDATE ON nutrition_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_day_meal_plans_updated_at BEFORE UPDATE ON day_meal_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meals_updated_at BEFORE UPDATE ON meals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_items_updated_at BEFORE UPDATE ON food_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_video_call_bookings_updated_at BEFORE UPDATE ON video_call_bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_updated_at BEFORE UPDATE ON ratings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_progress_entries_updated_at BEFORE UPDATE ON progress_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- User with Coach Info
CREATE VIEW user_profiles AS
SELECT 
    u.id,
    u.phone_number,
    u.email,
    u.full_name,
    u.full_name_ar,
    u.role,
    u.subscription_tier,
    u.profile_photo_url,
    c.id as coach_id,
    c.bio,
    c.average_rating as coach_rating,
    c.is_available as coach_available
FROM users u
LEFT JOIN coaches c ON u.assigned_coach_id = c.user_id;

-- Active Workout Plans with Progress
CREATE VIEW active_workout_plans_with_progress AS
SELECT 
    wp.id,
    wp.user_id,
    wp.name,
    wp.start_date,
    wp.end_date,
    COUNT(DISTINCT wd.id) as total_days,
    COUNT(DISTINCT we.id) as total_exercises,
    COUNT(DISTINCT CASE WHEN we.is_completed = TRUE THEN we.id END) as completed_exercises,
    ROUND(
        (COUNT(DISTINCT CASE WHEN we.is_completed = TRUE THEN we.id END)::DECIMAL / 
        NULLIF(COUNT(DISTINCT we.id), 0)) * 100, 
        2
    ) as completion_percentage
FROM workout_plans wp
LEFT JOIN workout_days wd ON wp.id = wd.workout_plan_id
LEFT JOIN workout_exercises we ON wd.id = we.workout_day_id
WHERE wp.is_active = TRUE
GROUP BY wp.id;

-- User Quota Status
CREATE VIEW user_quota_status AS
SELECT 
    u.id as user_id,
    u.subscription_tier,
    u.messages_sent_this_month,
    u.video_calls_this_month,
    u.quota_reset_date,
    CASE u.subscription_tier
        WHEN 'freemium' THEN 20
        WHEN 'premium' THEN 200
        WHEN 'smart_premium' THEN -1
    END as message_quota,
    CASE u.subscription_tier
        WHEN 'freemium' THEN 1
        WHEN 'premium' THEN 2
        WHEN 'smart_premium' THEN 4
    END as call_quota,
    u.nutrition_trial_start_date,
    u.nutrition_trial_active,
    CASE 
        WHEN u.subscription_tier = 'freemium' AND u.nutrition_trial_active = TRUE
        THEN 14 - EXTRACT(DAY FROM (CURRENT_TIMESTAMP - u.nutrition_trial_start_date))
        ELSE NULL
    END as trial_days_remaining
FROM users u;
