# ✅ Workout System Complete Guide

## Overview

Your fitness app now has a **fully automated, production-ready workout generation system** with:

1. ✅ **Automatic template selection** based on user intake answers
2. ✅ **Coach customization per user** without affecting other users
3. ✅ **96 unique workout programs** (11 template files)
4. ✅ **Tier-based access control** (Freemium vs. Premium)
5. ✅ **Injury-aware substitutions**
6. ✅ **Bilingual support** (AR/EN)

---

## 🎯 How It Works

### **1. User Completes Intake**

#### **Freemium Users (3 Questions):**
- Primary Goal (fat_loss, muscle_gain, general_fitness)
- Workout Location (gym, home)
- Training Days: **Always 3 days** (fixed for freemium)

#### **Premium Users (Full Intake):**
- All above questions +
- Experience Level (beginner, intermediate, advanced)
- Training Days: **2-6 days** (user chooses)
- Injuries (if any)

---

### **2. System Automatically Selects Template**

The `workoutRecommendationService` automatically:

#### **For Freemium Users:**
```javascript
// Template Type: starter
// Training Days: 3 (always)
// Result: starter_fatloss_gym_3d_v1.json
```

#### **For Premium Users:**
```javascript
// Template Type: advanced
// Training Days: 2-6 (based on user preference)
// Experience: beginner/intermediate/advanced
// Result: premium_4d_v1.json → extracts gym.fat_loss.intermediate
```

---

### **3. Workout Plan Generated**

**API Call:**
```bash
POST /v2/workouts/generate-from-template
{
  "templateId": "premium_4d_v1", # Auto-selected by system
  "customizations": {
    "startDate": "2025-01-01",
    "injuries": ["knee_pain"]  # Optional
  }
}
```

**What Happens:**
1. System gets user's intake data
2. Selects correct template (starter vs. premium)
3. Extracts appropriate program variation
4. Applies injury substitutions if needed
5. Creates personalized 12-week plan in database
6. User receives fully customized workout

---

## 👨‍⚕️ Coach Customization

### **Coaches Can:**

#### **1. Clone a Workout Plan for Specific User**
```bash
POST /v2/workouts/:planId/clone
{
  "customizationNotes": "Modified for knee injury recovery"
}
```

**Result:** Creates a coach-owned copy that can be modified without affecting:
- The original template
- Other users' plans
- Future plan generations

---

#### **2. Update Exercise Parameters for One User**
```bash
PUT /v2/workouts/:planId/exercises/:exerciseId
{
  "sets": 4,        # Changed from 3
  "reps": "8-10",   # Changed from 10-12
  "rest_seconds": 120,
  "rpe": 7.5,
  "notes": "Focus on eccentric control"
}
```

**Result:** Only affects THIS user's plan

---

#### **3. Add Custom Notes to Workout Days**
```bash
POST /v2/workouts/:planId/days/:dayId/note
{
  "note": "Take extra rest if shoulder feels tight. Focus on form over weight."
}
```

**Result:** Personalized coaching notes visible to only this user

---

#### **4. View Customization History**
```bash
GET /v2/workouts/customization-history/:userId?limit=50
```

**Response:**
```json
{
  "success": true,
  "history": [
    {
      "id": "uuid",
      "coach_id": "coach-uuid",
      "user_id": "user-uuid",
      "customization_type": "exercise_update",
      "changes": {
        "sets": 4,
        "reps": "8-10"
      },
      "workout_plan_name": "Premium 4-Day Program (Custom)",
      "exercise_name": "Back Squat",
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

##Human: continue