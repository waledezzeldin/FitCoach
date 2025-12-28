const { v4: uuidv4 } = require('uuid');
const db = require('../database');
const logger = require('../utils/logger');

/**
 * Nutrition Generation Service
 * Generates personalized nutrition plans based on user intake data
 */

class NutritionGenerationService {
  
  /**
   * Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
   */
  calculateBMR(weight, height, age, gender) {
    // Weight in kg, height in cm, age in years
    if (gender === 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  /**
   * Get activity multiplier based on workout frequency
   */
  getActivityMultiplier(workoutFrequency) {
    const multipliers = {
      'sedentary': 1.2,        // 0 days
      'lightly_active': 1.375, // 1-2 days
      'moderately_active': 1.55, // 3-4 days
      'very_active': 1.725,    // 5-6 days
      'extremely_active': 1.9  // 7 days
    };

    // Map workout days per week to activity level
    if (workoutFrequency <= 0) return multipliers.sedentary;
    if (workoutFrequency <= 2) return multipliers.lightly_active;
    if (workoutFrequency <= 4) return multipliers.moderately_active;
    if (workoutFrequency <= 6) return multipliers.very_active;
    return multipliers.extremely_active;
  }

  /**
   * Calculate TDEE (Total Daily Energy Expenditure)
   */
  calculateTDEE(bmr, activityLevel) {
    return Math.round(bmr * activityLevel);
  }

  /**
   * Calculate calorie target based on goal
   */
  calculateCalorieTarget(tdee, goal) {
    const adjustments = {
      'weight_loss': -500,      // 500 cal deficit
      'fat_loss': -500,
      'muscle_gain': 300,       // 300 cal surplus
      'maintenance': 0,
      'general_fitness': 0,
      'endurance': 200,
      'strength': 300
    };

    const adjustment = adjustments[goal] || 0;
    return Math.round(tdee + adjustment);
  }

  /**
   * Calculate macro distribution based on goal
   */
  calculateMacros(calorieTarget, goal, weight) {
    let proteinPerKg, carbPercentage, fatPercentage;

    // Protein targets (grams per kg body weight)
    const proteinTargets = {
      'weight_loss': 2.2,
      'fat_loss': 2.2,
      'muscle_gain': 2.0,
      'maintenance': 1.6,
      'general_fitness': 1.6,
      'endurance': 1.4,
      'strength': 2.0
    };

    proteinPerKg = proteinTargets[goal] || 1.6;
    const proteinGrams = Math.round(weight * proteinPerKg);
    const proteinCalories = proteinGrams * 4;

    // Remaining calories for carbs and fat
    const remainingCalories = calorieTarget - proteinCalories;

    // Carb/fat split based on goal
    if (goal === 'fat_loss' || goal === 'weight_loss') {
      carbPercentage = 0.30; // Lower carb for fat loss
      fatPercentage = 0.30;
    } else if (goal === 'muscle_gain' || goal === 'strength') {
      carbPercentage = 0.45; // Higher carb for muscle gain
      fatPercentage = 0.25;
    } else if (goal === 'endurance') {
      carbPercentage = 0.50; // High carb for endurance
      fatPercentage = 0.20;
    } else {
      carbPercentage = 0.40; // Balanced
      fatPercentage = 0.25;
    }

    const carbCalories = remainingCalories * carbPercentage;
    const fatCalories = remainingCalories * fatPercentage;

    return {
      calories: calorieTarget,
      protein: proteinGrams,
      carbs: Math.round(carbCalories / 4),
      fat: Math.round(fatCalories / 9)
    };
  }

  /**
   * Get meal template database based on dietary preferences
   */
  getMealTemplates(dietaryPreferences = [], goal) {
    // Base meal templates (you can expand this significantly)
    const mealDatabase = {
      breakfast: [
        {
          name: 'Oatmeal with Berries',
          name_ar: 'شوفان مع التوت',
          calories: 350,
          protein: 12,
          carbs: 55,
          fat: 8,
          ingredients: ['Oats', 'Blueberries', 'Almond milk', 'Honey'],
          tags: ['vegetarian', 'vegan']
        },
        {
          name: 'Egg White Omelette',
          name_ar: 'عجة بياض البيض',
          calories: 280,
          protein: 30,
          carbs: 15,
          fat: 12,
          ingredients: ['Egg whites', 'Spinach', 'Mushrooms', 'Whole wheat toast'],
          tags: ['high_protein', 'vegetarian']
        },
        {
          name: 'Greek Yogurt Bowl',
          name_ar: 'زبادي يوناني',
          calories: 300,
          protein: 20,
          carbs: 35,
          fat: 8,
          ingredients: ['Greek yogurt', 'Granola', 'Honey', 'Mixed berries'],
          tags: ['vegetarian', 'high_protein']
        },
        {
          name: 'Protein Pancakes',
          name_ar: 'فطائر البروتين',
          calories: 400,
          protein: 35,
          carbs: 45,
          fat: 10,
          ingredients: ['Protein powder', 'Banana', 'Eggs', 'Oats'],
          tags: ['high_protein']
        }
      ],
      lunch: [
        {
          name: 'Grilled Chicken Salad',
          name_ar: 'سلطة دجاج مشوي',
          calories: 450,
          protein: 45,
          carbs: 30,
          fat: 15,
          ingredients: ['Chicken breast', 'Mixed greens', 'Quinoa', 'Olive oil'],
          tags: ['high_protein', 'gluten_free']
        },
        {
          name: 'Salmon with Rice',
          name_ar: 'سلمون مع أرز',
          calories: 500,
          protein: 40,
          carbs: 50,
          fat: 18,
          ingredients: ['Salmon fillet', 'Brown rice', 'Broccoli', 'Lemon'],
          tags: ['high_protein', 'omega3']
        },
        {
          name: 'Turkey Wrap',
          name_ar: 'لفة الديك الرومي',
          calories: 420,
          protein: 38,
          carbs: 40,
          fat: 12,
          ingredients: ['Turkey breast', 'Whole wheat wrap', 'Lettuce', 'Avocado'],
          tags: ['high_protein']
        },
        {
          name: 'Vegetarian Buddha Bowl',
          name_ar: 'بوذا بول نباتي',
          calories: 480,
          protein: 18,
          carbs: 65,
          fat: 16,
          ingredients: ['Chickpeas', 'Sweet potato', 'Kale', 'Tahini'],
          tags: ['vegetarian', 'vegan']
        }
      ],
      dinner: [
        {
          name: 'Grilled Steak with Vegetables',
          name_ar: 'ستيك مشوي مع خضار',
          calories: 550,
          protein: 50,
          carbs: 35,
          fat: 22,
          ingredients: ['Lean beef', 'Asparagus', 'Sweet potato', 'Olive oil'],
          tags: ['high_protein', 'gluten_free']
        },
        {
          name: 'Baked Chicken with Quinoa',
          name_ar: 'دجاج مخبوز مع كينوا',
          calories: 480,
          protein: 45,
          carbs: 42,
          fat: 15,
          ingredients: ['Chicken thighs', 'Quinoa', 'Green beans', 'Garlic'],
          tags: ['high_protein', 'gluten_free']
        },
        {
          name: 'Shrimp Stir Fry',
          name_ar: 'قلي الروبيان',
          calories: 420,
          protein: 40,
          carbs: 38,
          fat: 12,
          ingredients: ['Shrimp', 'Mixed vegetables', 'Brown rice', 'Soy sauce'],
          tags: ['high_protein', 'low_fat']
        },
        {
          name: 'Lentil Curry',
          name_ar: 'كاري العدس',
          calories: 450,
          protein: 20,
          carbs: 60,
          fat: 14,
          ingredients: ['Red lentils', 'Coconut milk', 'Spinach', 'Basmati rice'],
          tags: ['vegetarian', 'vegan']
        }
      ],
      snacks: [
        {
          name: 'Protein Shake',
          name_ar: 'مخفوق البروتين',
          calories: 200,
          protein: 30,
          carbs: 15,
          fat: 4,
          ingredients: ['Whey protein', 'Banana', 'Almond milk'],
          tags: ['high_protein', 'quick']
        },
        {
          name: 'Mixed Nuts',
          name_ar: 'مكسرات مشكلة',
          calories: 180,
          protein: 6,
          carbs: 8,
          fat: 15,
          ingredients: ['Almonds', 'Cashews', 'Walnuts'],
          tags: ['vegetarian', 'vegan']
        },
        {
          name: 'Apple with Peanut Butter',
          name_ar: 'تفاح مع زبدة الفول السوداني',
          calories: 200,
          protein: 8,
          carbs: 25,
          fat: 10,
          ingredients: ['Apple', 'Natural peanut butter'],
          tags: ['vegetarian', 'vegan']
        }
      ]
    };

    return mealDatabase;
  }

  /**
   * Filter meals based on dietary restrictions
   */
  filterMealsByDietaryPreferences(meals, preferences = []) {
    if (preferences.length === 0) return meals;

    return meals.filter(meal => {
      return preferences.every(pref => meal.tags && meal.tags.includes(pref));
    });
  }

  /**
   * Select meals to match target macros
   */
  selectMealsForDay(mealDatabase, targetMacros, dietaryPreferences) {
    const selectedMeals = {
      breakfast: null,
      lunch: null,
      dinner: null,
      snacks: []
    };

    // Filter meals by dietary preferences
    const breakfastOptions = this.filterMealsByDietaryPreferences(
      mealDatabase.breakfast,
      dietaryPreferences
    );
    const lunchOptions = this.filterMealsByDietaryPreferences(
      mealDatabase.lunch,
      dietaryPreferences
    );
    const dinnerOptions = this.filterMealsByDietaryPreferences(
      mealDatabase.dinner,
      dietaryPreferences
    );
    const snackOptions = this.filterMealsByDietaryPreferences(
      mealDatabase.snacks,
      dietaryPreferences
    );

    // Select random meals from each category
    selectedMeals.breakfast = breakfastOptions[
      Math.floor(Math.random() * breakfastOptions.length)
    ] || mealDatabase.breakfast[0];

    selectedMeals.lunch = lunchOptions[
      Math.floor(Math.random() * lunchOptions.length)
    ] || mealDatabase.lunch[0];

    selectedMeals.dinner = dinnerOptions[
      Math.floor(Math.random() * dinnerOptions.length)
    ] || mealDatabase.dinner[0];

    // Calculate remaining calories needed
    const mainMealsCals = selectedMeals.breakfast.calories +
                           selectedMeals.lunch.calories +
                           selectedMeals.dinner.calories;
    
    const remainingCalories = targetMacros.calories - mainMealsCals;

    // Add snacks if needed
    if (remainingCalories > 100) {
      const numSnacks = Math.floor(remainingCalories / 200);
      for (let i = 0; i < Math.min(numSnacks, 2); i++) {
        const snack = snackOptions[
          Math.floor(Math.random() * snackOptions.length)
        ] || mealDatabase.snacks[0];
        selectedMeals.snacks.push(snack);
      }
    }

    return selectedMeals;
  }

  /**
   * Generate complete nutrition plan
   */
  async generatePlan(userId, customizations = {}) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Get user data and intake
      const userResult = await client.query(
        `SELECT u.*, ui.*, up.*
         FROM users u
         LEFT JOIN user_intake ui ON u.id = ui.user_id
         LEFT JOIN user_profiles up ON u.id = up.user_id
         WHERE u.id = $1`,
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];

      // Extract user data
      const weight = customizations.weight || user.weight || user.current_weight || 70;
      const height = customizations.height || user.height || 170;
      const age = customizations.age || user.age || 30;
      const gender = customizations.gender || user.gender || 'male';
      const goal = customizations.goal || user.primary_goal || user.goal || 'general_fitness';
      const workoutFrequency = user.workout_frequency || user.training_days_per_week || 3;
      const dietaryPreferences = customizations.dietary_preferences ||
                                 (user.dietary_preferences ? JSON.parse(user.dietary_preferences) : []);

      // Calculate nutrition targets
      const bmr = this.calculateBMR(weight, height, age, gender);
      const activityMultiplier = this.getActivityMultiplier(workoutFrequency);
      const tdee = this.calculateTDEE(bmr, activityMultiplier);
      const calorieTarget = this.calculateCalorieTarget(tdee, goal);
      const macros = this.calculateMacros(calorieTarget, goal, weight);

      // Get meal database
      const mealDatabase = this.getMealTemplates(dietaryPreferences, goal);

      // Create nutrition plan
      const planResult = await client.query(
        `INSERT INTO nutrition_plans (
          id, user_id, coach_id, name, name_ar, description, description_ar,
          goal, daily_calories, daily_protein, daily_carbs, daily_fat,
          start_date, duration_days, is_active, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, true, NOW(), NOW())
        RETURNING *`,
        [
          uuidv4(),
          userId,
          customizations.coachId || null,
          `Nutrition Plan - ${goal.replace('_', ' ').toUpperCase()}`,
          `خطة التغذية - ${goal.replace('_', ' ').toUpperCase()}`,
          `Personalized nutrition plan for ${goal.replace('_', ' ')}`,
          `خطة تغذية مخصصة لـ ${goal.replace('_', ' ')}`,
          goal,
          macros.calories,
          macros.protein,
          macros.carbs,
          macros.fat,
          customizations.startDate || new Date(),
          customizations.duration || 28,
        ]
      );

      const nutritionPlan = planResult.rows[0];

      // Generate 7 days of meal plans (week template)
      for (let day = 1; day <= 7; day++) {
        const dailyMeals = this.selectMealsForDay(
          mealDatabase,
          macros,
          dietaryPreferences
        );

        // Create day meal plan
        const dayPlanResult = await client.query(
          `INSERT INTO day_meal_plans (
            id, nutrition_plan_id, day_number, target_calories,
            target_protein, target_carbs, target_fat, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
          RETURNING *`,
          [
            uuidv4(),
            nutritionPlan.id,
            day,
            macros.calories,
            macros.protein,
            macros.carbs,
            macros.fat
          ]
        );

        const dayPlan = dayPlanResult.rows[0];

        // Insert breakfast
        await client.query(
          `INSERT INTO meals (
            id, day_meal_plan_id, meal_type, name, name_ar, calories,
            protein, carbs, fat, ingredients, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
          [
            uuidv4(),
            dayPlan.id,
            'breakfast',
            dailyMeals.breakfast.name,
            dailyMeals.breakfast.name_ar,
            dailyMeals.breakfast.calories,
            dailyMeals.breakfast.protein,
            dailyMeals.breakfast.carbs,
            dailyMeals.breakfast.fat,
            JSON.stringify(dailyMeals.breakfast.ingredients)
          ]
        );

        // Insert lunch
        await client.query(
          `INSERT INTO meals (
            id, day_meal_plan_id, meal_type, name, name_ar, calories,
            protein, carbs, fat, ingredients, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
          [
            uuidv4(),
            dayPlan.id,
            'lunch',
            dailyMeals.lunch.name,
            dailyMeals.lunch.name_ar,
            dailyMeals.lunch.calories,
            dailyMeals.lunch.protein,
            dailyMeals.lunch.carbs,
            dailyMeals.lunch.fat,
            JSON.stringify(dailyMeals.lunch.ingredients)
          ]
        );

        // Insert dinner
        await client.query(
          `INSERT INTO meals (
            id, day_meal_plan_id, meal_type, name, name_ar, calories,
            protein, carbs, fat, ingredients, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
          [
            uuidv4(),
            dayPlan.id,
            'dinner',
            dailyMeals.dinner.name,
            dailyMeals.dinner.name_ar,
            dailyMeals.dinner.calories,
            dailyMeals.dinner.protein,
            dailyMeals.dinner.carbs,
            dailyMeals.dinner.fat,
            JSON.stringify(dailyMeals.dinner.ingredients)
          ]
        );

        // Insert snacks
        for (const snack of dailyMeals.snacks) {
          await client.query(
            `INSERT INTO meals (
              id, day_meal_plan_id, meal_type, name, name_ar, calories,
              protein, carbs, fat, ingredients, created_at, updated_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
            [
              uuidv4(),
              dayPlan.id,
              'snack',
              snack.name,
              snack.name_ar,
              snack.calories,
              snack.protein,
              snack.carbs,
              snack.fat,
              JSON.stringify(snack.ingredients)
            ]
          );
        }
      }

      // Set expiry for Freemium users
      if (user.subscription_tier === 'freemium') {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 7);

        await client.query(
          `UPDATE nutrition_plans
           SET expiry_date = $1
           WHERE id = $2`,
          [expiryDate, nutritionPlan.id]
        );

        nutritionPlan.expiry_date = expiryDate;
      }

      await client.query('COMMIT');
      client.release();

      logger.info(`Nutrition plan generated for user ${userId}`);

      return {
        plan: nutritionPlan,
        targets: macros,
        calculations: {
          bmr,
          tdee,
          activityMultiplier
        }
      };

    } catch (error) {
      await client.query('ROLLBACK');
      client.release();
      logger.error('Generate nutrition plan error:', error);
      throw error;
    }
  }
}

module.exports = new NutritionGenerationService();
