# 🏥 Injury Mapping System

## Overview

Keyword-based intelligent injury substitution system that automatically replaces exercises based on user injuries.

---

## 🎯 How It Works

### **1. Keyword Matching**
```javascript
// Exercise: "back_squat"
// User has: ["knee_pain"]

// System checks: knee_pain avoid_keywords
// avoid_keywords: ["squat", "lunge", "step_up", "leg_press", "leg_extension"]

// "back_squat" contains "squat" → ⚠️ AVOID
// System finds substitute: "hip_thrust" ✅
```

### **2. Automatic Substitution**
```javascript
// Original exercise:
{
  ex_id: "back_squat",
  sets: 3,
  reps: "8-12",
  rpe: 7.5
}

// After injury swap:
{
  ex_id: "hip_thrust",
  sets: 3,              // ✅ Preserved
  reps: "8-12",         // ✅ Preserved
  rpe: 7.5,             // ✅ Preserved
  was_substituted: true,
  original_ex_id: "back_squat",
  substitution_reason: "Exercise contains 'squat' which is not recommended for Knee Pain"
}
```

---

## 📁 File Structure

```
backend/
└── src/
    ├── data/
    │   └── injury-swaps.json          ✅ Injury mapping definitions
    ├── services/
    │   └── injuryMappingService.js    ✅ Service logic
    └── server.js                       ✅ Auto-loads on startup
```

---

## 🗂️ injury-swaps.json Format

```json
{
  "injury_type": {
    "description_en": "English name",
    "description_ar": "Arabic name",
    "avoid_keywords": [
      "keyword1",
      "keyword2"
    ],
    "substitute_exercises": [
      "safe_exercise_1",
      "safe_exercise_2"
    ]
  }
}
```

### **Example:**
```json
{
  "knee_pain": {
    "description_en": "Knee Pain",
    "description_ar": "ألم الركبة",
    "avoid_keywords": [
      "squat",
      "lunge",
      "step_up",
      "leg_press",
      "leg_extension"
    ],
    "substitute_exercises": [
      "glute_bridge",
      "hip_thrust",
      "romanian_deadlift",
      "hamstring_curl",
      "superman"
    ]
  }
}
```

---

## 🎨 Supported Injury Types

### **Currently Supported:**

1. **shoulder_pain** - Shoulder Pain (ألم الكتف)
2. **knee_pain** - Knee Pain (ألم الركبة)
3. **lower_back_pain** - Lower Back Pain (ألم أسفل الظهر)
4. **neck_pain** - Neck Pain (ألم الرقبة)
5. **ankle_pain** - Ankle Pain (ألم الكاحل)
6. **wrist_pain** - Wrist Pain (ألم المعصم)
7. **elbow_pain** - Elbow Pain (ألم الكوع)
8. **hip_pain** - Hip Pain (ألم الورك)

---

## 🔄 Service Methods

### **Load Mappings**
```javascript
await injuryMappingService.loadMappings();
```

### **Check If Exercise Should Be Avoided**
```javascript
const check = await injuryMappingService.shouldAvoidExercise(
  'back_squat',
  'Back Squat',
  ['knee_pain']
);

// Returns:
{
  shouldAvoid: true,
  reason: "Exercise contains 'squat' which is not recommended for Knee Pain",
  reason_ar: "التمرين يحتوي على 'squat' وهو غير موصى به لـ ألم الركبة",
  injury: "knee_pain",
  injuryDescription: "Knee Pain",
  injuryDescription_ar: "ألم الركبة"
}
```

### **Find Substitute Exercise**
```javascript
const substitute = await injuryMappingService.findSubstituteExercise(
  'back_squat',
  ['knee_pain'],
  availableExercises
);

// Returns: "hip_thrust"
```

### **Apply Swaps to Session**
```javascript
const modifiedSession = await injuryMappingService.applyInjurySwapsToSession(
  session,
  ['knee_pain', 'lower_back_pain'],
  exerciseLibrary
);
```

### **Apply Swaps to All Sessions**
```javascript
const modifiedSessions = await injuryMappingService.applyInjurySwapsToSessions(
  sessions,
  injuries,
  exerciseLibrary
);
```

---

## 🎯 Usage in Workout Generation

### **Automatic Integration:**

```javascript
// In workoutGenerationService.js
const userCriteria = {
  location: 'gym',
  goal: 'fat_loss',
  experience_level: 'intermediate',
  injuries: ['knee_pain', 'lower_back_pain']  // ← User injuries
};

// Get sessions (automatically applies swaps)
const sessions = workoutTemplateService.getSessionsFromTemplate(
  template,
  userCriteria
);

// Exercises are already swapped! ✅
```

---

## 🧪 Matching Logic

### **Keyword Normalization:**
```javascript
// Exercise ID: "back_squat"
// Exercise Name: "Back Squat"
// Combined: "back_squat_Back Squat"
// Normalized: "back_squat_back_squat"

// Avoid keyword: "squat"
// Normalized: "squat"

// Match: "back_squat_back_squat".includes("squat") → ✅ TRUE
```

### **Examples:**

| Exercise ID | Exercise Name | Keyword | Match? |
|------------|---------------|---------|--------|
| `back_squat` | "Back Squat" | `squat` | ✅ Yes |
| `leg_press` | "Leg Press" | `squat` | ❌ No |
| `overhead_press` | "Overhead Press" | `overhead` | ✅ Yes |
| `bench_press` | "Bench Press" | `overhead` | ❌ No |
| `lat_pulldown` | "Lat Pulldown" | `squat` | ❌ No |

---

## 🔧 Adding New Injury Types

### **Step 1: Edit injury-swaps.json**
```json
{
  "new_injury_type": {
    "description_en": "New Injury Name",
    "description_ar": "اسم الإصابة الجديدة",
    "avoid_keywords": [
      "keyword1",
      "keyword2",
      "keyword3"
    ],
    "substitute_exercises": [
      "safe_exercise_1",
      "safe_exercise_2",
      "safe_exercise_3"
    ]
  }
}
```

### **Step 2: Restart Server**
```bash
npm run dev
# Logs: "Loaded 9 injury mapping types" ✅
```

### **Step 3: Test**
```bash
# User creates intake with new injury type
POST /v2/intake/full
{
  "injuries": ["new_injury_type"]
}

# Generate workout - swaps applied automatically!
POST /v2/workouts/generate-from-template
{
  "templateId": "advanced_2d_multigoal_v1"
}
```

---

## 🎨 Template Integration

### **Two Approaches:**

#### **1. Global Injury Mapping (Recommended) ✅**
```json
// Uses injury-swaps.json
// Automatically applied to ALL templates
// No template-specific configuration needed
```

#### **2. Template-Specific Mapping (Optional)**
```json
// In template JSON:
{
  "injury_swaps": {
    "knee_pain": {
      "swap_map": {
        "back_squat": ["goblet_squat", "leg_press"],
        "lunge": ["split_squat"]
      }
    }
  }
}
```

**Both work together:**
- Template-specific swaps take priority
- Falls back to global injury-swaps.json
- Best of both worlds! 🎯

---

## 📊 Statistics

### **Get Injury Stats:**
```javascript
const stats = await injuryMappingService.getStatistics();

// Returns:
{
  total_injuries: 8,
  by_injury: {
    knee_pain: {
      description: "Knee Pain",
      avoid_keywords_count: 5,
      substitute_exercises_count: 5
    },
    shoulder_pain: {
      description: "Shoulder Pain",
      avoid_keywords_count: 4,
      substitute_exercises_count: 5
    }
    // ...
  }
}
```

---

## ✅ Validation

### **Validate Substitutes:**
```javascript
const issues = await injuryMappingService.validateSubstitutes();

// Checks for conflicts:
// - Substitute exercises that contain avoid keywords
// - Example: "squat" in avoid_keywords but "goblet_squat" in substitutes

// Returns array of issues (if any)
```

---

## 🚀 API Endpoints

### **Get Injury Types**
```bash
GET /v2/workouts/injury-types

# Returns:
{
  "success": true,
  "injury_types": [
    {
      "type": "knee_pain",
      "description_en": "Knee Pain",
      "description_ar": "ألم الركبة"
    }
    // ...
  ]
}
```

### **Check Exercise Compatibility**
```bash
POST /v2/workouts/check-exercise-compatibility
{
  "exerciseId": "back_squat",
  "exerciseName": "Back Squat",
  "injuries": ["knee_pain"]
}

# Returns:
{
  "success": true,
  "compatible": false,
  "reason": "Exercise contains 'squat' which is not recommended for Knee Pain",
  "suggested_alternatives": ["hip_thrust", "glute_bridge"]
}
```

---

## 💡 Best Practices

### **1. Comprehensive Keywords**
```json
// Good ✅
"avoid_keywords": ["squat", "lunge", "step_up", "leg_press"]

// Bad ❌
"avoid_keywords": ["squat"]
```

### **2. Safe Substitutes**
```json
// Ensure substitutes don't conflict with the injury
"substitute_exercises": [
  "glute_bridge",   // ✅ Safe for knee pain
  "hip_thrust",     // ✅ Safe for knee pain
  "leg_press"       // ⚠️ May still stress knees
]
```

### **3. Multiple Injuries**
```javascript
// System finds substitutes safe for ALL injuries
const substitute = await injuryMappingService.findSubstituteExercise(
  'back_squat',
  ['knee_pain', 'lower_back_pain'],  // Both considered!
  exerciseLibrary
);
```

---

## 🎊 Summary

**Features:**
- ✅ Keyword-based matching (flexible, powerful)
- ✅ Automatic substitution (preserves sets, reps, RPE)
- ✅ Multi-injury support (finds safe for all)
- ✅ Bilingual descriptions (English + Arabic)
- ✅ Template integration (works with both formats)
- ✅ Global + template-specific (best of both)
- ✅ 8 injury types pre-configured
- ✅ Easy to extend (just edit JSON)
- ✅ Auto-loads on server start
- ✅ Complete API support

**Usage:**
```javascript
// User has injuries
injuries: ['knee_pain', 'lower_back_pain']

// System automatically:
1. Checks each exercise against avoid_keywords
2. Finds safe substitutes
3. Swaps exercises while preserving training parameters
4. Logs substitutions with reasons
5. Done! ✅
```

**Your injury mapping system is production-ready!** 🏥💪
