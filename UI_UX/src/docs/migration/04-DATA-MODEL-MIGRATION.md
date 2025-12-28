# Data Model Migration Guide
## عاش (FitCoach+) v2.0 - Complete Data Structure Migration

## Document Information
- **Document**: Data Model Migration Guide
- **Version**: 1.0.0
- **Last Updated**: December 21, 2024
- **Purpose**: Complete data structure mapping from React to Flutter + PostgreSQL
- **Audience**: Database Architects, Backend Developers

---

## Migration Overview

### Source (React Web App)
- **Storage**: Browser localStorage
- **Format**: JSON objects
- **Language**: TypeScript interfaces
- **Persistence**: Client-side only

### Target (Flutter Mobile App)
- **Storage**: PostgreSQL (server) + Hive (mobile local)
- **Format**: Prisma models (server) + Dart classes (mobile)
- **Language**: TypeScript (server) + Dart (mobile)
- **Persistence**: Server-authoritative with client caching

---

## Complete Data Model Mapping

### 1. User Profile Model

**React (TypeScript)**
```typescript
interface UserProfile {
  id: string;
  name: string;
  phoneNumber: string;
  email?: string;
  age: number;
  weight: number;
  height: number;
  gender: 'male' | 'female' | 'other';
  workoutFrequency: number;
  workoutLocation: 'home' | 'gym';
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
  mainGoal: 'fat_loss' | 'muscle_gain' | 'general_fitness';
  injuries: InjuryArea[];
  subscriptionTier: SubscriptionTier;
  coachId?: string;
  hasCompletedSecondIntake?: boolean;
  fitnessScore?: number;
  fitnessScoreUpdatedBy?: 'auto' | 'coach';
  fitnessScoreLastUpdated?: Date;
  inBodyHistory?: InBodyHistory;
}
```

**Flutter (Dart)**
```dart
@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phoneNumber;
  
  @HiveField(3)
  final String? email;
  
  @HiveField(4)
  final int age;
  
  @HiveField(5)
  final double weight;
  
  @HiveField(6)
  final int height;
  
  @HiveField(7)
  final Gender gender;
  
  @HiveField(8)
  final int workoutFrequency;
  
  @HiveField(9)
  final WorkoutLocation workoutLocation;
  
  @HiveField(10)
  final ExperienceLevel experienceLevel;
  
  @HiveField(11)
  final MainGoal mainGoal;
  
  @HiveField(12)
  final List<InjuryArea> injuries;
  
  @HiveField(13)
  final SubscriptionTier subscriptionTier;
  
  @HiveField(14)
  final String? coachId;
  
  @HiveField(15)
  final bool hasCompletedSecondIntake;
  
  @HiveField(16)
  final int? fitnessScore;
  
  @HiveField(17)
  final String? fitnessScoreUpdatedBy;
  
  @HiveField(18)
  final DateTime? fitnessScoreLastUpdated;
  
  @HiveField(19)
  final InBodyHistory? inBodyHistory;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.workoutFrequency,
    required this.workoutLocation,
    required this.experienceLevel,
    required this.mainGoal,
    required this.injuries,
    required this.subscriptionTier,
    this.coachId,
    this.hasCompletedSecondIntake = false,
    this.fitnessScore,
    this.fitnessScoreUpdatedBy,
    this.fitnessScoreLastUpdated,
    this.inBodyHistory,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
    age: json['age'],
    weight: (json['weight'] as num).toDouble(),
    height: json['height'],
    gender: Gender.values.byName(json['gender']),
    workoutFrequency: json['workoutFrequency'],
    workoutLocation: WorkoutLocation.values.byName(json['workoutLocation']),
    experienceLevel: ExperienceLevel.values.byName(json['experienceLevel']),
    mainGoal: MainGoal.values.byName(json['mainGoal']),
    injuries: (json['injuries'] as List)
        .map((e) => InjuryArea.values.byName(e))
        .toList(),
    subscriptionTier: SubscriptionTier.values.byName(json['subscriptionTier']),
    coachId: json['coachId'],
    hasCompletedSecondIntake: json['hasCompletedSecondIntake'] ?? false,
    fitnessScore: json['fitnessScore'],
    fitnessScoreUpdatedBy: json['fitnessScoreUpdatedBy'],
    fitnessScoreLastUpdated: json['fitnessScoreLastUpdated'] != null
        ? DateTime.parse(json['fitnessScoreLastUpdated'])
        : null,
    inBodyHistory: json['inBodyHistory'] != null
        ? InBodyHistory.fromJson(json['inBodyHistory'])
        : null,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender.name,
    'workoutFrequency': workoutFrequency,
    'workoutLocation': workoutLocation.name,
    'experienceLevel': experienceLevel.name,
    'mainGoal': mainGoal.name,
    'injuries': injuries.map((e) => e.name).toList(),
    'subscriptionTier': subscriptionTier.name,
    'coachId': coachId,
    'hasCompletedSecondIntake': hasCompletedSecondIntake,
    'fitnessScore': fitnessScore,
    'fitnessScoreUpdatedBy': fitnessScoreUpdatedBy,
    'fitnessScoreLastUpdated': fitnessScoreLastUpdated?.toIso8601String(),
    'inBodyHistory': inBodyHistory?.toJson(),
  };
  
  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    double? weight,
    int? height,
    Gender? gender,
    int? workoutFrequency,
    WorkoutLocation? workoutLocation,
    ExperienceLevel? experienceLevel,
    MainGoal? mainGoal,
    List<InjuryArea>? injuries,
    SubscriptionTier? subscriptionTier,
    String? coachId,
    bool? hasCompletedSecondIntake,
    int? fitnessScore,
    String? fitnessScoreUpdatedBy,
    DateTime? fitnessScoreLastUpdated,
    InBodyHistory? inBodyHistory,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      phoneNumber: this.phoneNumber,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      mainGoal: mainGoal ?? this.mainGoal,
      injuries: injuries ?? this.injuries,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      coachId: coachId ?? this.coachId,
      hasCompletedSecondIntake: hasCompletedSecondIntake ?? this.hasCompletedSecondIntake,
      fitnessScore: fitnessScore ?? this.fitnessScore,
      fitnessScoreUpdatedBy: fitnessScoreUpdatedBy ?? this.fitnessScoreUpdatedBy,
      fitnessScoreLastUpdated: fitnessScoreLastUpdated ?? this.fitnessScoreLastUpdated,
      inBodyHistory: inBodyHistory ?? this.inBodyHistory,
    );
  }
}
```

**PostgreSQL (Prisma)**
```prisma
model User {
  id                        String    @id @default(uuid())
  phoneNumber               String    @unique @map("phone_number")
  name                      String
  email                     String?   @unique
  
  age                       Int?
  weight                    Float?
  height                    Int?
  gender                    Gender?
  
  workoutFrequency          Int?      @map("workout_frequency")
  workoutLocation           String?   @map("workout_location")
  experienceLevel           String?   @map("experience_level")
  mainGoal                  String?   @map("main_goal")
  injuries                  String[]  @default([])
  
  subscriptionTier          String    @default("Freemium") @map("subscription_tier")
  subscriptionStartDate     DateTime? @map("subscription_start_date")
  subscriptionEndDate       DateTime? @map("subscription_end_date")
  
  coachId                   String?   @map("coach_id")
  coach                     User?     @relation("CoachClients", fields: [coachId], references: [id])
  clients                   User[]    @relation("CoachClients")
  
  hasCompletedFirstIntake   Boolean   @default(false) @map("has_completed_first_intake")
  hasCompletedSecondIntake  Boolean   @default(false) @map("has_completed_second_intake")
  
  fitnessScore              Int?      @map("fitness_score")
  fitnessScoreUpdatedBy     String?   @map("fitness_score_updated_by")
  fitnessScoreLastUpdated   DateTime? @map("fitness_score_last_updated")
  
  role                      UserRole  @default(USER)
  
  createdAt                 DateTime  @default(now()) @map("created_at")
  updatedAt                 DateTime  @updatedAt @map("updated_at")
  lastLoginAt               DateTime? @map("last_login_at")
  
  workoutPlans              WorkoutPlan[]
  nutritionPlans            NutritionPlan[]
  messages                  Message[]
  videoCalls                VideoCall[]
  orders                    Order[]
  quotaUsage                QuotaUsage?
  inBodyRecords             InBodyRecord[]
  ratings                   Rating[]
  
  @@map("users")
}
```

---

### 2. Workout Plan Model

**React (TypeScript)**
```typescript
interface WorkoutPlan {
  id: string;
  userId: string;
  name: string;
  daysPerWeek: number;
  weekNumber: number;
  days: WorkoutDay[];
  createdBy?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface WorkoutDay {
  id: string;
  dayNumber: number;
  dayName: string;
  isRestDay: boolean;
  exercises: WorkoutExercise[];
}

interface WorkoutExercise {
  id: string;
  exerciseId: string;
  exercise: Exercise;
  sets: number;
  repsMin?: number;
  repsMax?: number;
  duration?: number;
  restTime: number;
  notes?: string;
  isCompleted: boolean;
}
```

**Flutter (Dart)**
```dart
@HiveType(typeId: 1)
class WorkoutPlan {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final int daysPerWeek;
  
  @HiveField(4)
  final int weekNumber;
  
  @HiveField(5)
  final List<WorkoutDay> days;
  
  @HiveField(6)
  final String? createdBy;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;
  
  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.daysPerWeek,
    this.weekNumber = 1,
    required this.days,
    this.createdBy,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    daysPerWeek: json['daysPerWeek'],
    weekNumber: json['weekNumber'] ?? 1,
    days: (json['days'] as List)
        .map((e) => WorkoutDay.fromJson(e))
        .toList(),
    createdBy: json['createdBy'],
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'daysPerWeek': daysPerWeek,
    'weekNumber': weekNumber,
    'days': days.map((e) => e.toJson()).toList(),
    'createdBy': createdBy,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

@HiveType(typeId: 2)
class WorkoutDay {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int dayNumber;
  
  @HiveField(2)
  final String dayName;
  
  @HiveField(3)
  final bool isRestDay;
  
  @HiveField(4)
  final List<WorkoutExercise> exercises;
  
  WorkoutDay({
    required this.id,
    required this.dayNumber,
    required this.dayName,
    this.isRestDay = false,
    required this.exercises,
  });
  
  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
    id: json['id'],
    dayNumber: json['dayNumber'],
    dayName: json['dayName'],
    isRestDay: json['isRestDay'] ?? false,
    exercises: (json['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e))
        .toList(),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'dayNumber': dayNumber,
    'dayName': dayName,
    'isRestDay': isRestDay,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

@HiveType(typeId: 3)
class WorkoutExercise {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String exerciseId;
  
  @HiveField(2)
  final Exercise exercise;
  
  @HiveField(3)
  final int sets;
  
  @HiveField(4)
  final int? repsMin;
  
  @HiveField(5)
  final int? repsMax;
  
  @HiveField(6)
  final int? duration;
  
  @HiveField(7)
  final int restTime;
  
  @HiveField(8)
  final String? notes;
  
  @HiveField(9)
  final bool isCompleted;
  
  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exercise,
    required this.sets,
    this.repsMin,
    this.repsMax,
    this.duration,
    this.restTime = 60,
    this.notes,
    this.isCompleted = false,
  });
  
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    id: json['id'],
    exerciseId: json['exerciseId'],
    exercise: Exercise.fromJson(json['exercise']),
    sets: json['sets'],
    repsMin: json['repsMin'],
    repsMax: json['repsMax'],
    duration: json['duration'],
    restTime: json['restTime'] ?? 60,
    notes: json['notes'],
    isCompleted: json['isCompleted'] ?? false,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'exercise': exercise.toJson(),
    'sets': sets,
    'repsMin': repsMin,
    'repsMax': repsMax,
    'duration': duration,
    'restTime': restTime,
    'notes': notes,
    'isCompleted': isCompleted,
  };
  
  WorkoutExercise copyWith({
    bool? isCompleted,
    String? notes,
  }) {
    return WorkoutExercise(
      id: this.id,
      exerciseId: this.exerciseId,
      exercise: this.exercise,
      sets: this.sets,
      repsMin: this.repsMin,
      repsMax: this.repsMax,
      duration: this.duration,
      restTime: this.restTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

---

### 3. Nutrition Plan Model

**Flutter (Dart)**
```dart
@HiveType(typeId: 10)
class NutritionPlan {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String? description;
  
  @HiveField(4)
  final int caloriesTarget;
  
  @HiveField(5)
  final int proteinTarget;
  
  @HiveField(6)
  final int carbsTarget;
  
  @HiveField(7)
  final int fatsTarget;
  
  @HiveField(8)
  final int mealsPerDay;
  
  @HiveField(9)
  final List<Meal> meals;
  
  @HiveField(10)
  final String? createdBy;
  
  @HiveField(11)
  final bool isActive;
  
  @HiveField(12)
  final DateTime createdAt;
  
  @HiveField(13)
  final DateTime updatedAt;
  
  NutritionPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatsTarget,
    this.mealsPerDay = 3,
    required this.meals,
    this.createdBy,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory NutritionPlan.fromJson(Map<String, dynamic> json) => NutritionPlan(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    description: json['description'],
    caloriesTarget: json['caloriesTarget'],
    proteinTarget: json['proteinTarget'],
    carbsTarget: json['carbsTarget'],
    fatsTarget: json['fatsTarget'],
    mealsPerDay: json['mealsPerDay'] ?? 3,
    meals: (json['meals'] as List)
        .map((e) => Meal.fromJson(e))
        .toList(),
    createdBy: json['createdBy'],
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'caloriesTarget': caloriesTarget,
    'proteinTarget': proteinTarget,
    'carbsTarget': carbsTarget,
    'fatsTarget': fatsTarget,
    'mealsPerDay': mealsPerDay,
    'meals': meals.map((e) => e.toJson()).toList(),
    'createdBy': createdBy,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

---

### 4. Message Model

**Flutter (Dart)**
```dart
@HiveType(typeId: 20)
class Message {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String senderId;
  
  @HiveField(2)
  final String receiverId;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final MessageType messageType;
  
  @HiveField(5)
  final String? attachmentUrl;
  
  @HiveField(6)
  final String? attachmentType;
  
  @HiveField(7)
  final bool isRead;
  
  @HiveField(8)
  final DateTime? readAt;
  
  @HiveField(9)
  final DateTime createdAt;
  
  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.TEXT,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    content: json['content'],
    messageType: MessageType.values.byName(json['messageType'] ?? 'TEXT'),
    attachmentUrl: json['attachmentUrl'],
    attachmentType: json['attachmentType'],
    isRead: json['isRead'] ?? false,
    readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    createdAt: DateTime.parse(json['createdAt']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'messageType': messageType.name,
    'attachmentUrl': attachmentUrl,
    'attachmentType': attachmentType,
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
  
  Message copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return Message(
      id: this.id,
      senderId: this.senderId,
      receiverId: this.receiverId,
      content: this.content,
      messageType: this.messageType,
      attachmentUrl: this.attachmentUrl,
      attachmentType: this.attachmentType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: this.createdAt,
    );
  }
}

enum MessageType {
  TEXT,
  IMAGE,
  FILE
}
```

---

### 5. Quota Model

**Flutter (Dart)**
```dart
@HiveType(typeId: 30)
class Quota {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final int messagesUsed;
  
  @HiveField(2)
  final int messagesLimit;
  
  @HiveField(3)
  final int videoCallsUsed;
  
  @HiveField(4)
  final int videoCallsLimit;
  
  @HiveField(5)
  final DateTime? nutritionFirstAccess;
  
  @HiveField(6)
  final DateTime? nutritionExpiryDate;
  
  @HiveField(7)
  final String currentMonth;
  
  @HiveField(8)
  final DateTime lastResetDate;
  
  @HiveField(9)
  final String tier;
  
  Quota({
    required this.userId,
    required this.messagesUsed,
    required this.messagesLimit,
    required this.videoCallsUsed,
    required this.videoCallsLimit,
    this.nutritionFirstAccess,
    this.nutritionExpiryDate,
    required this.currentMonth,
    required this.lastResetDate,
    required this.tier,
  });
  
  factory Quota.empty() => Quota(
    userId: '',
    messagesUsed: 0,
    messagesLimit: 20,
    videoCallsUsed: 0,
    videoCallsLimit: 1,
    currentMonth: DateTime.now().toIso8601String().substring(0, 7),
    lastResetDate: DateTime.now(),
    tier: 'Freemium',
  );
  
  factory Quota.fromJson(Map<String, dynamic> json) => Quota(
    userId: json['userId'],
    messagesUsed: json['messagesUsed'],
    messagesLimit: json['messagesLimit'],
    videoCallsUsed: json['videoCallsUsed'],
    videoCallsLimit: json['videoCallsLimit'],
    nutritionFirstAccess: json['nutritionFirstAccess'] != null
        ? DateTime.parse(json['nutritionFirstAccess'])
        : null,
    nutritionExpiryDate: json['nutritionExpiryDate'] != null
        ? DateTime.parse(json['nutritionExpiryDate'])
        : null,
    currentMonth: json['currentMonth'],
    lastResetDate: DateTime.parse(json['lastResetDate']),
    tier: json['tier'],
  );
  
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'messagesUsed': messagesUsed,
    'messagesLimit': messagesLimit,
    'videoCallsUsed': videoCallsUsed,
    'videoCallsLimit': videoCallsLimit,
    'nutritionFirstAccess': nutritionFirstAccess?.toIso8601String(),
    'nutritionExpiryDate': nutritionExpiryDate?.toIso8601String(),
    'currentMonth': currentMonth,
    'lastResetDate': lastResetDate.toIso8601String(),
    'tier': tier,
  };
  
  // Helper methods
  int get messagesRemaining => messagesLimit - messagesUsed;
  int get videoCallsRemaining => videoCallsLimit - videoCallsUsed;
  
  bool get hasNutritionAccess {
    if (tier == 'Smart Premium' || tier == 'Premium') return true;
    if (nutritionExpiryDate == null) return false;
    return DateTime.now().isBefore(nutritionExpiryDate!);
  }
  
  int? get nutritionDaysRemaining {
    if (nutritionExpiryDate == null) return null;
    final remaining = nutritionExpiryDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
  
  bool get shouldShowMessageWarning {
    if (tier == 'Smart Premium') return false;
    final usagePercent = messagesUsed / messagesLimit;
    return usagePercent >= 0.8; // Warning at 80%
  }
  
  Quota copyWith({
    int? messagesUsed,
    int? videoCallsUsed,
    DateTime? nutritionFirstAccess,
    DateTime? nutritionExpiryDate,
  }) {
    return Quota(
      userId: this.userId,
      messagesUsed: messagesUsed ?? this.messagesUsed,
      messagesLimit: this.messagesLimit,
      videoCallsUsed: videoCallsUsed ?? this.videoCallsUsed,
      videoCallsLimit: this.videoCallsLimit,
      nutritionFirstAccess: nutritionFirstAccess ?? this.nutritionFirstAccess,
      nutritionExpiryDate: nutritionExpiryDate ?? this.nutritionExpiryDate,
      currentMonth: this.currentMonth,
      lastResetDate: this.lastResetDate,
      tier: this.tier,
    );
  }
}
```

---

## Migration Scripts

### Export from React localStorage

```javascript
// scripts/export-data.js
function exportUserData() {
  const userData = {
    user: JSON.parse(localStorage.getItem('fitcoach_user_data') || 'null'),
    workoutPlan: JSON.parse(localStorage.getItem('fitcoach_workout_plan') || 'null'),
    nutritionPlan: JSON.parse(localStorage.getItem('fitcoach_nutrition_plan') || 'null'),
    language: localStorage.getItem('fitcoach_language'),
    hasSeenIntro: localStorage.getItem('fitcoach_intro_seen') === 'true',
  };
  
  // Download as JSON
  const blob = new Blob([JSON.stringify(userData, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `fitcoach-export-${Date.now()}.json`;
  a.click();
}

exportUserData();
```

### Import to PostgreSQL

```typescript
// scripts/import-data.ts
import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';

const prisma = new PrismaClient();

async function importUserData(filePath: string) {
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  
  // Create or update user
  const user = await prisma.user.upsert({
    where: { phoneNumber: data.user.phoneNumber },
    update: {
      name: data.user.name,
      email: data.user.email,
      age: data.user.age,
      weight: data.user.weight,
      height: data.user.height,
      gender: data.user.gender.toUpperCase(),
      workoutFrequency: data.user.workoutFrequency,
      workoutLocation: data.user.workoutLocation,
      experienceLevel: data.user.experienceLevel,
      mainGoal: data.user.mainGoal,
      injuries: data.user.injuries,
      subscriptionTier: data.user.subscriptionTier,
      hasCompletedFirstIntake: true,
      hasCompletedSecondIntake: data.user.hasCompletedSecondIntake || false,
    },
    create: {
      phoneNumber: data.user.phoneNumber,
      name: data.user.name,
      email: data.user.email,
      age: data.user.age,
      weight: data.user.weight,
      height: data.user.height,
      gender: data.user.gender.toUpperCase(),
      workoutFrequency: data.user.workoutFrequency,
      workoutLocation: data.user.workoutLocation,
      experienceLevel: data.user.experienceLevel,
      mainGoal: data.user.mainGoal,
      injuries: data.user.injuries,
      subscriptionTier: data.user.subscriptionTier,
      role: 'USER',
      hasCompletedFirstIntake: true,
      hasCompletedSecondIntake: data.user.hasCompletedSecondIntake || false,
    },
  });
  
  console.log(`Imported user: ${user.id}`);
  
  // Import workout plan if exists
  if (data.workoutPlan) {
    await importWorkoutPlan(user.id, data.workoutPlan);
  }
  
  // Import nutrition plan if exists
  if (data.nutritionPlan) {
    await importNutritionPlan(user.id, data.nutritionPlan);
  }
}

async function importWorkoutPlan(userId: string, planData: any) {
  const plan = await prisma.workoutPlan.create({
    data: {
      userId,
      name: planData.name,
      daysPerWeek: planData.daysPerWeek,
      weekNumber: planData.weekNumber || 1,
      isActive: true,
      workoutDays: {
        create: planData.days.map((day: any) => ({
          dayNumber: day.dayNumber,
          dayName: day.dayName,
          isRestDay: day.isRestDay,
          exercises: {
            create: day.exercises.map((exercise: any, index: number) => ({
              exerciseId: exercise.exerciseId,
              orderIndex: index,
              sets: exercise.sets,
              repsMin: exercise.repsMin,
              repsMax: exercise.repsMax,
              duration: exercise.duration,
              restTime: exercise.restTime || 60,
              notes: exercise.notes,
            })),
          },
        })),
      },
    },
  });
  
  console.log(`Imported workout plan: ${plan.id}`);
}

async function importNutritionPlan(userId: string, planData: any) {
  const plan = await prisma.nutritionPlan.create({
    data: {
      userId,
      name: planData.name,
      description: planData.description,
      caloriesTarget: planData.caloriesTarget,
      proteinTarget: planData.proteinTarget,
      carbsTarget: planData.carbsTarget,
      fatsTarget: planData.fatsTarget,
      mealsPerDay: planData.mealsPerDay || 3,
      isActive: true,
      meals: {
        create: planData.meals.map((meal: any) => ({
          name: meal.name,
          nameAr: meal.nameAr,
          time: meal.time,
          calories: meal.calories,
          protein: meal.protein,
          carbs: meal.carbs,
          fats: meal.fats,
          foods: {
            create: meal.foods.map((food: any) => ({
              name: food.name,
              nameAr: food.nameAr,
              quantity: food.quantity,
              unit: food.unit,
              calories: food.calories,
              protein: food.protein,
              carbs: food.carbs,
              fats: food.fats,
              notes: food.notes,
            })),
          },
        })),
      },
    },
  });
  
  console.log(`Imported nutrition plan: ${plan.id}`);
}

// Run import
const filePath = process.argv[2];
if (!filePath) {
  console.error('Usage: ts-node import-data.ts <path-to-export-file>');
  process.exit(1);
}

importUserData(filePath)
  .catch((error) => {
    console.error('Import error:', error);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
```

---

## Data Validation Rules

### User Profile
- **phoneNumber**: Must match Saudi format `+966 5X XXX XXXX`
- **age**: 13-120 years
- **weight**: 30-300 kg
- **height**: 100-250 cm
- **workoutFrequency**: 2-6 days per week
- **subscriptionTier**: One of `Freemium`, `Premium`, `Smart Premium`

### Workout Plan
- **daysPerWeek**: 2-7 days
- **sets**: 1-10 per exercise
- **reps**: 1-100 per set
- **restTime**: 15-300 seconds

### Nutrition Plan
- **caloriesTarget**: 1000-5000 kcal
- **proteinTarget**: 50-300 grams
- **carbsTarget**: 50-500 grams
- **fatsTarget**: 20-200 grams
- **mealsPerDay**: 1-6 meals

### Quota Limits
- **Freemium**: 20 messages/month, 1 video call/month
- **Premium**: 200 messages/month, 2 video calls/month
- **Smart Premium**: Unlimited messages, 4 video calls/month

---

**Document Version**: 1.0.0  
**Last Updated**: December 21, 2024
