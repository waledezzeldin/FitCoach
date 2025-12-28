# Workout Plan Templates

## Overview

This directory contains predefined workout plan templates in JSON format. Templates are divided into two intake levels:

- **Starter** - Based on 3 basic intake questions (goal, location, training days)
- **Advanced** - Based on full intake questionnaire (includes injuries, experience, preferences, etc.)

---

## Directory Structure

```
workout-templates/
├── README.md                    # This file
├── starter/
│   ├── fat-loss-gym-3days.json
│   ├── fat-loss-gym-4days.json
│   ├── fat-loss-home-3days.json
│   ├── muscle-gain-gym-4days.json
│   └── ... (more starter templates)
└── advanced/
    ├── fat-loss-gym-5days-intermediate.json
    ├── muscle-gain-gym-6days-advanced.json
    ├── endurance-outdoors-4days.json
    └── ... (more advanced templates)
```

---

## JSON Template Format

### Complete Template Structure

```json
{
  "plan_id": "starter_fatloss_gym_3d_v1",
  "type": "starter",
  "goal": "fat_loss",
  "location": "gym",
  "training_days": 3,
  "weeks": 12,
  "name_en": "Starter Fat Loss - 3 Days (Gym)",
  "name_ar": "حرق الدهون للمبتدئين - 3 أيام",
  "description_en": "12-week progressive fat loss program",
  "description_ar": "برنامج حرق الدهون لمدة 12 أسبوعًا",
  "blocks": [
    {
      "block": 1,
      "weeks": [1,2],
      "focus": "technique + base",
      "focus_ar": "التقنية والأساس",
      "progression": "RPE 6 → 7"
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
          "muscles": ["quads","glutes","core"],
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
        "machine_options": ["rower","bike"],
        "protocol": "30s ON / 30s OFF × 12",
        "protocol_ar": "30 ثانية تشغيل / 30 ثانية راحة × 12",
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

---

## Field Descriptions

### Root Level

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `plan_id` | String | ✅ | Unique identifier (e.g., `starter_fatloss_gym_3d_v1`) |
| `type` | String | ✅ | `starter` or `advanced` |
| `goal` | String | ✅ | `fat_loss`, `muscle_gain`, `general_fitness`, `endurance`, `strength`, `hypertrophy` |
| `location` | String | ✅ | `gym`, `home`, `outdoors`, `hybrid` |
| `training_days` | Integer | ✅ | Number of training days per week (1-7) |
| `weeks` | Integer | ✅ | Total program duration in weeks (1-52) |
| `name_en` | String | ✅ | English name |
| `name_ar` | String | ✅ | Arabic name |
| `description_en` | String | ⭕ | English description |
| `description_ar` | String | ⭕ | Arabic description |
| `blocks` | Array | ⭕ | Periodization blocks |
| `sessions` | Array | ✅ | Training sessions/days |
| `fitness_score` | Object | ⭕ | Expected fitness score progression |
| `routing` | Object | ⭕ | Configuration for swaps/substitutions |
| `metadata` | Object | ⭕ | Additional metadata |

### Block Structure

```json
{
  "block": 1,
  "weeks": [1, 2],
  "focus": "technique + base",
  "focus_ar": "التقنية والأساس",
  "progression": "RPE 6 → 7"
}
```

| Field | Description |
|-------|-------------|
| `block` | Block number |
| `weeks` | Array of week numbers in this block |
| `focus` | Training focus in English |
| `focus_ar` | Training focus in Arabic |
| `progression` | Progression strategy |

### Session Structure

```json
{
  "day": 1,
  "name_en": "Full Body A",
  "name_ar": "الجسم الكامل أ",
  "work": [ /* exercises */ ],
  "conditioning": { /* optional conditioning */ }
}
```

| Field | Description |
|-------|-------------|
| `day` | Day number (1-7) |
| `name_en` | Session name in English |
| `name_ar` | Session name in Arabic |
| `work` | Array of exercises |
| `conditioning` | Optional conditioning/cardio work |

### Exercise Structure

```json
{
  "ex_id": "back_squat",
  "name_en": "Back Squat",
  "name_ar": "سكوات خلفي",
  "video_id": "vid_back_squat",
  "equip": ["barbell"],
  "muscles": ["quads", "glutes", "core"],
  "sets": 3,
  "reps": "6–10",
  "rest_s": 120,
  "rpe": 6.5,
  "notes_en": "Focus on depth",
  "notes_ar": "ركز على العمق"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ex_id` | String | ✅ | Exercise identifier |
| `name_en` | String | ✅ | Exercise name in English |
| `name_ar` | String | ✅ | Exercise name in Arabic |
| `video_id` | String | ⭕ | Reference to video tutorial |
| `equip` | Array | ⭕ | Equipment needed |
| `muscles` | Array | ⭕ | Muscles worked |
| `sets` | Integer | ✅ | Number of sets |
| `reps` | String | ✅ | Reps (e.g., "6-10", "AMRAP", "30s") |
| `rest_s` | Integer | ⭕ | Rest time in seconds |
| `rpe` | Decimal | ⭕ | Rate of Perceived Exertion (1-10) |
| `notes_en` | String | ⭕ | Exercise notes in English |
| `notes_ar` | String | ⭕ | Exercise notes in Arabic |

### Conditioning Structure

```json
{
  "type": "intervals",
  "type_ar": "فواصل",
  "machine_options": ["rower", "bike", "treadmill"],
  "protocol": "30s ON / 30s OFF × 12",
  "protocol_ar": "30 ثانية تشغيل / 30 ثانية راحة × 12",
  "intensity": "Zone 2",
  "target_heart_rate": "75–85% max",
  "duration_min": 12
}
```

---

## Valid Values

### Types
- `starter` - Based on 3 basic questions
- `advanced` - Based on full intake

### Goals
- `fat_loss` - Fat loss/weight loss
- `muscle_gain` - Muscle building/hypertrophy
- `general_fitness` - Overall fitness
- `endurance` - Cardiovascular endurance
- `strength` - Maximal strength
- `hypertrophy` - Muscle size focus

### Locations
- `gym` - Gym with equipment
- `home` - Home workouts
- `outdoors` - Outdoor training
- `hybrid` - Mix of locations

### Equipment
- `barbell`
- `dumbbell`
- `machine`
- `cable`
- `bodyweight`
- `kettlebell`
- `resistance_bands`
- `rower`
- `bike`
- `treadmill`

### Muscle Groups
- `quads`, `hamstrings`, `glutes`, `calves`
- `chest`, `back`, `lats`, `mid_back`
- `front_delts`, `side_delts`, `rear_delts`
- `biceps`, `triceps`, `forearms`
- `core`, `abs`, `obliques`

---

## Naming Conventions

### File Names
```
[goal]-[location]-[days]days.json
```

Examples:
- `fat-loss-gym-3days.json`
- `muscle-gain-home-4days.json`
- `endurance-outdoors-5days.json`

### Plan IDs
```
[type]_[goal]_[location]_[days]d_v[version]
```

Examples:
- `starter_fatloss_gym_3d_v1`
- `advanced_musclegain_home_4d_v1`
- `starter_endurance_outdoors_5d_v1`

---

## Starter vs Advanced Templates

### Starter Templates
- **Based on:** 3 basic intake questions
  1. What's your goal?
  2. Where do you train?
  3. How many days per week?
- **Target:** Users who want quick onboarding
- **Characteristics:**
  - Generalized programs
  - Fewer customization options
  - Proven, safe progressions
  - Beginner-friendly

### Advanced Templates
- **Based on:** Full intake questionnaire
  - Detailed experience level
  - Injury history
  - Equipment preferences
  - Training schedule
  - Recovery capacity
  - And more...
- **Target:** Users who completed full intake
- **Characteristics:**
  - Highly personalized
  - Accounts for injuries
  - More specific progressions
  - Advanced techniques

---

## How to Add Templates

### Step 1: Choose Template Type
Decide if template is for `starter` or `advanced` intake level.

### Step 2: Create JSON File
Follow the format above, ensuring all required fields are present.

### Step 3: Save to Correct Directory
- Starter templates → `/starter/`
- Advanced templates → `/advanced/`

### Step 4: Validate
Use a JSON validator to ensure syntax is correct.

### Step 5: Test
Restart server and test template loading:
```bash
npm run dev
# Check logs for "Loaded template: [plan_id]"
```

---

## Validation Rules

Templates are validated for:
- ✅ Required fields present
- ✅ Valid type (`starter` or `advanced`)
- ✅ Valid goal
- ✅ Valid location
- ✅ Valid numeric ranges
- ✅ Proper array structures
- ✅ Session structure
- ✅ Exercise structure

---

## Examples

See example templates:
- **Starter:** `/starter/fat-loss-gym-3days.json`
- **Advanced:** (Add your advanced templates here)

---

## Best Practices

1. **Always provide Arabic translations** for all user-facing text
2. **Include video IDs** for exercise demonstrations
3. **Use proper RPE values** (6-10 scale)
4. **Specify equipment** for each exercise
5. **Add helpful notes** for form cues
6. **Include conditioning** when appropriate
7. **Progressive overload** via blocks
8. **Test templates** before production use

---

## Questions?

Review the example templates or check the main documentation:
- **WORKOUT_TEMPLATES_GUIDE.md** - Complete usage guide
- **WORKOUT_TEMPLATES_QUICK_START.md** - Quick reference

---

**Happy Template Building!** 🏋️‍♀️
