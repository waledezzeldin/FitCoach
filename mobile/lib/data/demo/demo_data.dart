import '../models/admin_analytics.dart';
import '../models/admin_coach.dart';
import '../models/admin_user.dart';
import '../models/audit_log.dart';
import '../models/appointment.dart';
import '../models/coach_analytics.dart';
import '../models/coach_client.dart';
import '../models/coach_earnings.dart';
import '../models/message.dart';
import '../models/nutrition_plan.dart';
import '../models/revenue_analytics.dart';
import '../models/user_profile.dart';
import '../models/workout_plan.dart';

class DemoData {
  static UserProfile userProfile({required String role}) {
    switch (role) {
      case 'coach':
        return UserProfile(
          id: 'demo-coach',
          name: 'Coach Sam',
          phoneNumber: '+10000000002',
          email: 'coach.demo@fitcoach.app',
          subscriptionTier: 'Premium',
          hasCompletedFirstIntake: true,
          hasCompletedSecondIntake: true,
          role: 'coach',
        );
      case 'admin':
        return UserProfile(
          id: 'demo-admin',
          name: 'Admin Noor',
          phoneNumber: '+10000000003',
          email: 'admin.demo@fitcoach.app',
          subscriptionTier: 'Smart Premium',
          hasCompletedFirstIntake: true,
          hasCompletedSecondIntake: true,
          role: 'admin',
        );
      default:
        return UserProfile(
          id: 'demo-user',
          name: 'Mina Faris',
          phoneNumber: '+10000000001',
          email: 'user.demo@fitcoach.app',
          age: 28,
          weight: 64.5,
          height: 168,
          gender: 'female',
          workoutFrequency: 4,
          workoutLocation: 'gym',
          experienceLevel: 'intermediate',
          mainGoal: 'strength',
          injuries: const ['knee'],
          subscriptionTier: 'Smart Premium',
          coachId: 'demo-coach',
          hasCompletedFirstIntake: false,
          hasCompletedSecondIntake: false,
          fitnessScore: 82,
          role: 'user',
        );
    }
  }

  static WorkoutPlan workoutPlan({required String userId}) {
    final exercisesDay1 = [
      Exercise(
        id: 'ex-squat',
        name: 'Barbell Squat',
        nameAr: 'Barbell Squat',
        nameEn: 'Barbell Squat',
        sets: 4,
        reps: '8',
        restTime: '90s',
        tempo: '3-1-1',
        muscleGroup: 'legs',
        equipment: 'barbell',
      ),
      Exercise(
        id: 'ex-bench',
        name: 'Bench Press',
        nameAr: 'Bench Press',
        nameEn: 'Bench Press',
        sets: 4,
        reps: '10',
        restTime: '90s',
        tempo: '2-1-1',
        muscleGroup: 'chest',
        equipment: 'barbell',
      ),
    ];

    final exercisesDay2 = [
      Exercise(
        id: 'ex-rows',
        name: 'Seated Row',
        nameAr: 'Seated Row',
        nameEn: 'Seated Row',
        sets: 3,
        reps: '12',
        restTime: '60s',
        tempo: '2-0-2',
        muscleGroup: 'back',
        equipment: 'machine',
      ),
      Exercise(
        id: 'ex-press',
        name: 'Overhead Press',
        nameAr: 'Overhead Press',
        nameEn: 'Overhead Press',
        sets: 3,
        reps: '10',
        restTime: '75s',
        tempo: '2-1-1',
        muscleGroup: 'shoulders',
        equipment: 'dumbbell',
      ),
    ];

    return WorkoutPlan(
      id: 'demo-plan-1',
      userId: userId,
      name: 'Demo Strength Split',
      description: '4-day strength split',
      days: [
        WorkoutDay(
          id: 'day-1',
          dayName: 'Day 1 - Lower',
          dayNumber: 1,
          exercises: exercisesDay1,
        ),
        WorkoutDay(
          id: 'day-2',
          dayName: 'Day 2 - Upper',
          dayNumber: 2,
          exercises: exercisesDay2,
        ),
      ],
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );
  }

  static List<Exercise> exerciseLibrary() {
    return [
      Exercise(
        id: 'ex-pushup',
        name: 'Push Up',
        nameAr: 'Push Up',
        nameEn: 'Push Up',
        sets: 3,
        reps: '12',
        muscleGroup: 'chest',
        equipment: 'bodyweight',
      ),
      Exercise(
        id: 'ex-lunge',
        name: 'Walking Lunge',
        nameAr: 'Walking Lunge',
        nameEn: 'Walking Lunge',
        sets: 3,
        reps: '12',
        muscleGroup: 'legs',
        equipment: 'bodyweight',
      ),
    ];
  }

  static NutritionPlan nutritionPlan({required String userId}) {
    final meals = [
      Meal(
        id: 'meal-1',
        name: 'Breakfast',
        nameAr: 'Breakfast',
        nameEn: 'Breakfast',
        type: 'breakfast',
        time: '08:00',
        foods: [
          FoodItem(
            id: 'food-oats',
            name: 'Oats',
            nameAr: 'Oats',
            nameEn: 'Oats',
            quantity: 80,
            unit: 'g',
            macros: MacroTargets(protein: 10, carbs: 54, fats: 6),
            calories: 320,
          ),
          FoodItem(
            id: 'food-eggs',
            name: 'Eggs',
            nameAr: 'Eggs',
            nameEn: 'Eggs',
            quantity: 2,
            unit: 'pcs',
            macros: MacroTargets(protein: 12, carbs: 1, fats: 10),
            calories: 140,
          ),
        ],
        macros: MacroTargets(protein: 22, carbs: 55, fats: 16),
        calories: 460,
      ),
      Meal(
        id: 'meal-2',
        name: 'Lunch',
        nameAr: 'Lunch',
        nameEn: 'Lunch',
        type: 'lunch',
        time: '13:00',
        foods: [
          FoodItem(
            id: 'food-chicken',
            name: 'Chicken Breast',
            nameAr: 'Chicken Breast',
            nameEn: 'Chicken Breast',
            quantity: 180,
            unit: 'g',
            macros: MacroTargets(protein: 40, carbs: 0, fats: 6),
            calories: 220,
          ),
          FoodItem(
            id: 'food-rice',
            name: 'Rice',
            nameAr: 'Rice',
            nameEn: 'Rice',
            quantity: 150,
            unit: 'g',
            macros: MacroTargets(protein: 4, carbs: 45, fats: 1),
            calories: 210,
          ),
        ],
        macros: MacroTargets(protein: 44, carbs: 45, fats: 7),
        calories: 430,
      ),
      Meal(
        id: 'meal-3',
        name: 'Dinner',
        nameAr: 'Dinner',
        nameEn: 'Dinner',
        type: 'dinner',
        time: '19:30',
        foods: [
          FoodItem(
            id: 'food-salmon',
            name: 'Salmon',
            nameAr: 'Salmon',
            nameEn: 'Salmon',
            quantity: 160,
            unit: 'g',
            macros: MacroTargets(protein: 34, carbs: 0, fats: 12),
            calories: 260,
          ),
          FoodItem(
            id: 'food-potato',
            name: 'Sweet Potato',
            nameAr: 'Sweet Potato',
            nameEn: 'Sweet Potato',
            quantity: 200,
            unit: 'g',
            macros: MacroTargets(protein: 4, carbs: 41, fats: 0),
            calories: 180,
          ),
        ],
        macros: MacroTargets(protein: 38, carbs: 41, fats: 12),
        calories: 440,
      ),
    ];

    return NutritionPlan(
      id: 'demo-nutrition-1',
      userId: userId,
      name: 'Demo Nutrition Plan',
      description: 'Balanced macros for training days',
      days: [
        DayMealPlan(
          id: 'day-1',
          dayName: 'Day 1',
          dayNumber: 1,
          meals: meals,
        ),
      ],
      macros: const {
        'protein': 150.0,
        'carbs': 260.0,
        'fats': 70.0,
      },
      dailyCalories: 2400,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      macroTargets: const {
        'calories': 2400,
        'protein': 150,
        'carbs': 260,
        'fat': 70,
      },
    );
  }

  static CoachAnalytics coachAnalytics() {
    return CoachAnalytics(
      activeClients: 18,
      upcomingAppointments: 3,
      todayEarnings: 180,
      monthEarnings: 2450,
      unreadMessages: 6,
    );
  }

  static List<CoachClient> coachClients() {
    final now = DateTime.now();
    return [
      CoachClient(
        id: 'client-1',
        fullName: 'Mina Faris',
        email: 'user.demo@fitcoach.app',
        phoneNumber: '+10000000001',
        subscriptionTier: 'Smart Premium',
        goal: 'Strength',
        isActive: true,
        assignedDate: now.subtract(const Duration(days: 40)),
        lastActivity: now.subtract(const Duration(days: 1)),
        fitnessScore: 82,
        workoutPlanId: 'demo-plan-1',
        workoutPlanName: 'Demo Strength Split',
        nutritionPlanId: 'demo-nutrition-1',
        nutritionPlanName: 'Demo Nutrition Plan',
        messageCount: 2,
      ),
      CoachClient(
        id: 'client-2',
        fullName: 'Omar Reed',
        email: 'omar.demo@fitcoach.app',
        phoneNumber: '+10000000004',
        subscriptionTier: 'Premium',
        goal: 'Fat loss',
        isActive: true,
        assignedDate: now.subtract(const Duration(days: 12)),
        lastActivity: now.subtract(const Duration(days: 3)),
        fitnessScore: 76,
        workoutPlanId: 'demo-plan-2',
        workoutPlanName: 'Fat Loss Starter',
        nutritionPlanId: 'demo-nutrition-2',
        nutritionPlanName: 'Cutting Plan',
        messageCount: 1,
      ),
    ];
  }

  static List<Appointment> coachAppointments({
    required String coachId,
    required String userId,
  }) {
    final today = DateTime.now();
    final later = today.add(const Duration(hours: 3));
    final tomorrow = today.add(const Duration(days: 1, hours: 2));
    return [
      Appointment(
        id: 'appt-1',
        coachId: coachId,
        userId: userId,
        scheduledAt: today.toIso8601String(),
        durationMinutes: 45,
        status: 'confirmed',
        type: 'video',
        notes: 'Weekly check-in',
        coachName: 'Coach Sam',
        userName: 'Mina Faris',
      ),
      Appointment(
        id: 'appt-2',
        coachId: coachId,
        userId: 'client-2',
        scheduledAt: later.toIso8601String(),
        durationMinutes: 30,
        status: 'pending',
        type: 'chat',
        notes: 'Macro review',
        coachName: 'Coach Sam',
        userName: 'Omar Reed',
      ),
      Appointment(
        id: 'appt-3',
        coachId: coachId,
        userId: 'client-3',
        scheduledAt: tomorrow.toIso8601String(),
        durationMinutes: 60,
        status: 'confirmed',
        type: 'assessment',
        notes: 'Initial assessment',
        coachName: 'Coach Sam',
        userName: 'Lina Park',
      ),
    ];
  }

  static CoachEarnings coachEarnings() {
    final now = DateTime.now();
    return CoachEarnings(
      summary: EarningsSummary(
        totalEarnings: 12450,
        totalCommission: 1860,
        totalTransactions: 42,
      ),
      periodBreakdown: [
        PeriodEarnings(
          period: DateTime(now.year, now.month - 2, 1),
          earnings: 3500,
          transactions: 12,
        ),
        PeriodEarnings(
          period: DateTime(now.year, now.month - 1, 1),
          earnings: 4100,
          transactions: 14,
        ),
        PeriodEarnings(
          period: DateTime(now.year, now.month, 1),
          earnings: 4850,
          transactions: 16,
        ),
      ],
      recentTransactions: [
        Transaction(
          id: 'txn-1',
          clientName: 'Mina Faris',
          amount: 120,
          coachCommission: 18,
          type: 'subscription',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: 'txn-2',
          clientName: 'Omar Reed',
          amount: 80,
          coachCommission: 12,
          type: 'session',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ],
    );
  }

  static AdminAnalytics adminAnalytics() {
    return AdminAnalytics(
      users: UserStats(total: 1240, active: 812),
      coaches: CoachStats(total: 68, active: 41),
      subscriptions: [
        SubscriptionDistribution(subscriptionTier: 'Freemium', count: 520),
        SubscriptionDistribution(subscriptionTier: 'Premium', count: 460),
        SubscriptionDistribution(subscriptionTier: 'Smart Premium', count: 260),
      ],
      revenue: RevenueStats(last30Days: 45200),
      growth: GrowthStats(newUsersLast7Days: 84),
      sessions: SessionStats(today: 214),
    );
  }

  static List<AdminUser> adminUsers() {
    final now = DateTime.now();
    return [
      AdminUser(
        id: 'user-1',
        fullName: 'Mina Faris',
        email: 'user.demo@fitcoach.app',
        phoneNumber: '+10000000001',
        subscriptionTier: 'Smart Premium',
        isActive: true,
        coachId: 'coach-1',
        coachName: 'Coach Sam',
        createdAt: now.subtract(const Duration(days: 200)),
        lastLogin: now.subtract(const Duration(hours: 3)),
      ),
      AdminUser(
        id: 'user-2',
        fullName: 'Omar Reed',
        email: 'omar.demo@fitcoach.app',
        phoneNumber: '+10000000004',
        subscriptionTier: 'Premium',
        isActive: true,
        coachId: 'coach-2',
        coachName: 'Coach Dana',
        createdAt: now.subtract(const Duration(days: 120)),
        lastLogin: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<AdminCoach> adminCoaches() {
    final now = DateTime.now();
    return [
      AdminCoach(
        id: 'coach-1',
        userId: 'demo-coach',
        fullName: 'Coach Sam',
        email: 'coach.demo@fitcoach.app',
        phoneNumber: '+10000000002',
        specializations: const ['Strength', 'Mobility'],
        clientCount: 18,
        totalEarnings: 12450,
        averageRating: 4.8,
        isApproved: true,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 400)),
        approvedAt: now.subtract(const Duration(days: 380)),
      ),
      AdminCoach(
        id: 'coach-2',
        userId: 'coach-user-2',
        fullName: 'Coach Dana',
        email: 'dana.demo@fitcoach.app',
        phoneNumber: '+10000000005',
        specializations: const ['Nutrition', 'Endurance'],
        clientCount: 12,
        totalEarnings: 8400,
        averageRating: 4.6,
        isApproved: true,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 250)),
        approvedAt: now.subtract(const Duration(days: 230)),
      ),
      AdminCoach(
        id: 'coach-3',
        userId: 'coach-user-3',
        fullName: 'Coach Lina',
        email: 'lina.demo@fitcoach.app',
        phoneNumber: '+10000000006',
        specializations: const ['Rehab', 'Mobility'],
        clientCount: 0,
        totalEarnings: 0,
        averageRating: 0,
        isApproved: false,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 15)),
        approvedAt: null,
      ),
    ];
  }

  static RevenueAnalytics revenueAnalytics() {
    final now = DateTime.now();
    return RevenueAnalytics(
      total: 154200,
      transactionCount: 920,
      byPeriod: [
        RevenuePeriod(
          period: DateTime(now.year, now.month - 2, 1),
          revenue: 45200,
          transactions: 280,
        ),
        RevenuePeriod(
          period: DateTime(now.year, now.month - 1, 1),
          revenue: 51200,
          transactions: 310,
        ),
        RevenuePeriod(
          period: DateTime(now.year, now.month, 1),
          revenue: 57800,
          transactions: 330,
        ),
      ],
      byTier: [
        RevenueTier(subscriptionTier: 'Freemium', revenue: 12000, count: 520),
        RevenueTier(subscriptionTier: 'Premium', revenue: 62000, count: 460),
        RevenueTier(subscriptionTier: 'Smart Premium', revenue: 80200, count: 260),
      ],
    );
  }

  static List<AuditLog> auditLogs() {
    final now = DateTime.now();
    return [
      AuditLog(
        id: 'audit-1',
        userId: 'user-1',
        userName: 'Mina Faris',
        action: 'login_success',
        ipAddress: '192.168.1.10',
        userAgent: 'Chrome',
        metadata: const {'method': 'otp'},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AuditLog(
        id: 'audit-2',
        userId: 'coach-1',
        userName: 'Coach Sam',
        action: 'plan_updated',
        ipAddress: '192.168.1.12',
        userAgent: 'Chrome',
        metadata: const {'plan': 'demo-plan-1'},
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  static Conversation demoConversation({
    required String userId,
    required String coachId,
  }) {
    final now = DateTime.now();
    return Conversation(
      id: '${userId}_$coachId',
      userId: userId,
      coachId: coachId,
      lastMessageContent: 'Your plan is ready for review.',
      lastMessageAt: now.subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(minutes: 15)),
    );
  }

  static List<Message> chatMessages({
    required String conversationId,
  }) {
    final now = DateTime.now();
    return [
      Message(
        id: 'msg-1',
        conversationId: conversationId,
        senderId: 'demo-coach',
        receiverId: 'demo-user',
        content: 'Welcome! Ready for today\'s session?',
        type: MessageType.text,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        readAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Message(
        id: 'msg-2',
        conversationId: conversationId,
        senderId: 'demo-user',
        receiverId: 'demo-coach',
        content: 'Yes, feeling good. Can we review my form cues?',
        type: MessageType.text,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        readAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      Message(
        id: 'msg-3',
        conversationId: conversationId,
        senderId: 'demo-coach',
        receiverId: 'demo-user',
        content: 'Absolutely. I added notes in your plan.',
        type: MessageType.text,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
    ];
  }
}
