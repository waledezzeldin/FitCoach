# 📋 Workout Templates - Format Comparison

## Quick Reference: Starter vs Advanced Formats

---

## 🎯 When to Use Which Format

### **Use STARTER Format When:**
- ✅ Simple, single-purpose program
- ✅ No injury considerations needed
- ✅ Fixed experience level
- ✅ One goal + one location + one experience
- ✅ Quick to create
- ✅ Example: "3-Day Gym Fat Loss for Beginners"

### **Use ADVANCED Format When:**
- ✅ Multiple variations in one file
- ✅ Injury substitutions required
- ✅ Experience-based auto-scaling
- ✅ Multi-goal support
- ✅ Multi-location support
- ✅ Example: "2-Day Adaptive Program" (18 variations in 1 file!)

---

## 📊 Side-by-Side Comparison

### **Root Structure**

| Field | Starter | Advanced | Notes |
|-------|---------|----------|-------|
| `plan_id` | ✅ Required | ✅ Required | Unique identifier |
| `type` | `"starter"` | `"advanced"` | Template type |
| `goal` | ✅ Required | ❌ Not used | In starter: top-level |
| `location` | ✅ Required | ❌ Not used | In starter: top-level |
| `training_days` | ✅ Required | ✅ Required | Same for both |
| `weeks` | ✅ Required | ✅ Required | Same for both |
| `sessions` | ✅ Required | ❌ Not used | In starter: direct array |
| `programs` | ❌ Not used | ✅ Required | In advanced: nested object |
| `injury_swaps` | ❌ Optional | ✅ Common | Advanced feature |
| `experience_adjustments` | ❌ Not used | ✅ Common | Advanced feature |
| `exercises` | ❌ Optional | ✅ Common | Exercise definitions |

---

## 🏗️ Starter Format

### **Full Example Structure**

```json
{
  "plan_id": "starter_fatloss_gym_3d_v1",
  "type": "starter",
  "goal": "fat_loss",
  "location": "gym",
  "training_days": 3,
  "weeks": 12,
  "name_en": "Starter Fat Loss - 3 Days",
  "name_ar": "حرق الدهون للمبتدئين - 3 أيام",
  "description_en": "12-week program",
  "description_ar": "برنامج 12 أسبوع",
  
  "blocks": [
    {
      "block": 1,
      "weeks": [1, 2],
      "focus": "technique",
      "focus_ar": "التقنية",
      "progression": "RPE 6→7"
    }
  ],
  
  "sessions": [
    {
      "day": 1,
      "name_en": "Full Body A",
      "name_ar": "الجسم الكامل أ",
      "work": [
        {
          "ex_id": "back_squat",
          "name_en": "Back Squat",
          "name_ar": "سكوات خلفي",
          "video_id": "vid_back_squat",
          "equip": ["barbell"],
          "muscles": ["quads", "glutes"],
          "sets": 3,
          "reps": "6–10",
          "rest_s": 120,
          "rpe": 6.5,
          "notes_en": "Focus on depth",
          "notes_ar": "ركز على العمق"
        }
      ],
      "conditioning": {
        "type": "intervals",
        "type_ar": "فواصل",
        "protocol": "30s ON / 30s OFF × 12",
        "protocol_ar": "30/30 × 12",
        "target_heart_rate": "75–85% max",
        "duration_min": 12
      }
    }
  ],
  
  "fitness_score": {
    "method": "weekly_projection",
    "components": {
      "adherence": 0.5,
      "strength": 0.3,
      "cardio": 0.2
    },
    "weekly_expected": [
      {"week": 1, "score": 69},
      {"week": 2, "score": 70}
    ]
  },
  
  "routing": {
    "injury_swaps": true,
    "equipment_swaps": true
  },
  
  "metadata": {
    "created_by": "system",
    "version": "1.0",
    "intake_level": "starter",
    "intake_questions_required": 3,
    "tags": ["fat_loss", "gym", "3_days"]
  }
}
```

### **Starter: Key Points**
- ✅ **Simple** - Direct sessions array
- ✅ **Single-purpose** - One goal, one location
- ✅ **Quick** - Fast to create
- ✅ **Clear** - Easy to understand
- ❌ **No variations** - One template = one program

---

## 🏗️ Advanced Format

### **Full Example Structure**

```json
{
  "plan_id": "advanced_2d_multigoal_v1",
  "type": "advanced",
  "training_days": 2,
  "weeks": 12,
  "name_en": "Advanced 2-Day Multi-Goal",
  "name_ar": "برنامج متعدد الأهداف",
  "description_en": "Adaptive program",
  "description_ar": "برنامج تكيفي",
  
  "supports_locations": ["home", "gym"],
  "supports_goals": ["fat_loss", "muscle_gain", "general_fitness"],
  "supports_experience_levels": ["beginner", "intermediate", "advanced"],
  
  "blocks": [
    {
      "block": 1,
      "weeks": [1, 2],
      "focus": "base technique",
      "focus_ar": "تقنية الأساس",
      "progression": "RPE 6→7"
    }
  ],
  
  "experience_adjustments": {
    "beginner": {
      "set_multiplier": 1.00,
      "intensity_bias": -0.25
    },
    "intermediate": {
      "set_multiplier": 1.10,
      "intensity_bias": 0.00
    },
    "advanced": {
      "set_multiplier": 1.20,
      "intensity_bias": 0.15
    }
  },
  
  "injury_swaps": {
    "knee_pain": {
      "patterns_blocked": ["deep_knee_flexion"],
      "swap_map": {
        "back_squat": ["goblet_squat", "leg_press_partial"],
        "walking_lunge": ["reverse_lunge"]
      }
    },
    "lower_back_pain": {
      "swap_map": {
        "deadlift": ["hip_thrust", "trap_bar_deadlift_light"],
        "back_squat": ["goblet_squat", "leg_press"]
      }
    }
  },
  
  "exercises": [
    {
      "ex_id": "back_squat",
      "name_en": "Back Squat",
      "name_ar": "سكوات خلفي",
      "video_id": "vid_back_squat",
      "equip": ["barbell"],
      "muscles": ["quads", "glutes", "core"]
    }
  ],
  
  "programs": {
    "home": {
      "fat_loss": {
        "beginner": [
          {
            "day": 1,
            "name_en": "FB Strength",
            "name_ar": "قوة الجسم الكامل",
            "work": [
              {
                "ex_id": "goblet_squat",
                "sets": 3,
                "reps": "8–12",
                "rpe": 7,
                "rest_s": 90
              }
            ],
            "conditioning": {
              "type": "intervals",
              "protocol": "30/30 × 10"
            }
          }
        ],
        "intermediate": [/* ... */],
        "advanced": [/* ... */]
      },
      "muscle_gain": {/* ... */},
      "general_fitness": {/* ... */}
    },
    "gym": {
      "fat_loss": {/* ... */},
      "muscle_gain": {/* ... */},
      "general_fitness": {/* ... */}
    }
  },
  
  "fitness_score": {
    "method": "weekly_projection",
    "weights": {
      "adherence": 0.5,
      "strength": 0.3,
      "cardio": 0.2
    },
    "by_experience": {
      "beginner": [
        {"week": 1, "score": 66},
        {"week": 2, "score": 67}
      ],
      "intermediate": [
        {"week": 1, "score": 68},
        {"week": 2, "score": 69}
      ],
      "advanced": [
        {"week": 1, "score": 69},
        {"week": 2, "score": 70}
      ]
    }
  },
  
  "routing": {
    "injury_swaps": true,
    "equipment_swaps": true
  },
  
  "metadata": {
    "created_by": "system",
    "version": "1.0",
    "intake_level": "advanced",
    "intake_questions_required": "full",
    "tags": ["2_days", "multi_goal", "adaptive"]
  }
}
```

### **Advanced: Key Points**
- ✅ **Complex** - Nested programs structure
- ✅ **Multi-purpose** - Many variations in one file
- ✅ **Adaptive** - Auto-adjusts for experience/injuries
- ✅ **Powerful** - One file = many programs
- ⚠️ **Complex** - Takes longer to create

---

## 🔄 Session Extraction

### **Starter: Direct Access**
```javascript
// Sessions are directly in template
const sessions = template.sessions;
// Done!
```

### **Advanced: Criteria-Based Extraction**
```javascript
// Sessions extracted based on criteria
const sessions = extractSessionsFromAdvancedTemplate(template, {
  location: 'home',
  goal: 'fat_loss',
  experience_level: 'intermediate',
  injuries: ['knee_pain']
});

// System:
// 1. Gets: programs.home.fat_loss.intermediate
// 2. Applies injury swaps
// 3. Applies experience adjustments
// Returns personalized sessions!
```

---

## 📈 Scaling Comparison

### **Starter Templates**
```
1 Template = 1 Program

Example:
- starter_fatloss_gym_3d_v1.json
  → Fat Loss, Gym, 3 Days

To cover variations:
- starter_fatloss_gym_3d_v1.json (beginner)
- starter_fatloss_gym_4d_v1.json (beginner)
- starter_musclegain_gym_3d_v1.json (beginner)
- starter_musclegain_gym_4d_v1.json (beginner)
= 4 files for 4 variations
```

### **Advanced Templates**
```
1 Template = Many Programs

Example:
- advanced_2d_multigoal_v1.json
  → 2 locations × 3 goals × 3 experience levels
  = 18 variations in 1 file!

Plus:
- Auto injury swaps
- Auto experience scaling
- Fitness projections per experience

= Massive reduction in template files needed
```

---

## 💾 File Size Comparison

### **Starter Template**
```
File: fat-loss-gym-3days.json
Size: ~8 KB
Contains: 1 program
Sessions: 3
Exercises: ~15
```

### **Advanced Template**
```
File: 2day-multigoal-v1.json
Size: ~35 KB
Contains: 18 programs
Sessions: 36 (2 × 18)
Exercises: ~17 definitions
Plus: Injury swaps, experience adjustments
```

---

## 🎯 Use Case Examples

### **Starter Template Examples**

```
starter_fatloss_gym_3d_v1.json
starter_fatloss_gym_4d_v1.json
starter_fatloss_home_3d_v1.json
starter_musclegain_gym_4d_v1.json
starter_musclegain_gym_5d_v1.json
starter_generalfitness_home_3d_v1.json
```

### **Advanced Template Examples**

```
advanced_2d_multigoal_v1.json
  → Covers: home/gym × 3 goals × 3 experience = 18 programs

advanced_3d_multigoal_v1.json
  → Covers: home/gym × 3 goals × 3 experience = 18 programs

advanced_4d_multigoal_v1.json
  → Covers: home/gym × 3 goals × 3 experience = 18 programs

= 3 files for 54 program variations!
```

---

## ⚖️ Pros & Cons

### **Starter Format**

**Pros:**
- ✅ Simple to create
- ✅ Easy to understand
- ✅ Clear structure
- ✅ Fast to validate
- ✅ Good for specific programs

**Cons:**
- ❌ One template per variation
- ❌ No auto-adaptation
- ❌ No injury support
- ❌ Requires many files

### **Advanced Format**

**Pros:**
- ✅ One file = many programs
- ✅ Auto-adapts to user
- ✅ Injury swap support
- ✅ Experience scaling
- ✅ Fewer files needed
- ✅ Highly flexible

**Cons:**
- ❌ Complex to create
- ❌ Harder to understand
- ❌ More to validate
- ❌ Overkill for simple cases

---

## 🎨 Format Decision Tree

```
Need to create a workout template?
│
├─ Single, specific program?
│  (e.g., "3-Day Gym Fat Loss for Beginners")
│  └─► Use STARTER format
│
└─ Multiple variations?
   (e.g., "2-Day program for any goal/location/experience")
   └─► Use ADVANCED format
```

---

## 🚀 Quick Start

### **Create Starter Template**
1. Copy `/starter/fat-loss-gym-3days.json`
2. Modify goal, location, sessions
3. Save as new file
4. Done!

### **Create Advanced Template**
1. Copy `/advanced/2day-multigoal-v1.json`
2. Add/modify programs by location/goal/experience
3. Define injury swaps
4. Set experience adjustments
5. Define exercise library
6. Save as new file
7. Done!

---

## 📋 Validation Checklist

### **Starter Template**
- [ ] `plan_id` unique
- [ ] `type` = "starter"
- [ ] `goal` valid (fat_loss, muscle_gain, etc.)
- [ ] `location` valid (gym, home, outdoors, hybrid)
- [ ] `training_days` 1-7
- [ ] `weeks` 1-52
- [ ] `sessions` array with valid structure
- [ ] Each exercise has: ex_id, name_en, sets, reps

### **Advanced Template**
- [ ] `plan_id` unique
- [ ] `type` = "advanced"
- [ ] `training_days` 1-7
- [ ] `weeks` 1-52
- [ ] `programs` object exists
- [ ] Programs nested: location → goal → experience
- [ ] Each session has: day, name_en, work array
- [ ] `injury_swaps` valid (if present)
- [ ] `experience_adjustments` valid (if present)
- [ ] `exercises` array defined (recommended)

---

## 🎊 Summary

| Aspect | Starter | Advanced |
|--------|---------|----------|
| **Complexity** | Simple | Complex |
| **Variations** | 1 per file | Many per file |
| **Adaptability** | None | High |
| **Creation Time** | Fast | Slow |
| **File Count** | Many | Few |
| **Injury Support** | No | Yes |
| **Experience Scaling** | No | Yes |
| **Best For** | Specific programs | Adaptive programs |
| **Example File** | fat-loss-gym-3days.json | 2day-multigoal-v1.json |

**Both formats are fully supported and production-ready!** ✅

Choose based on your needs. Mix and match as needed. 🎯
