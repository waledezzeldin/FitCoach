# ✅ WORKOUT TEMPLATES - TWO-TIER INTAKE SYSTEM

## 🎉 Overview

Complete two-tier workout template system implemented supporting:
- **Starter** templates (3-question intake)
- **Advanced** templates (full intake questionnaire)

---

## 📦 What Was Created/Updated

### 1. **Services (2 files - Updated)**
```
✅ workoutTemplateService.js
   - Supports starter/advanced types
   - Search by type, goal, location, days
   - Smart template matching
   - findBestMatch() for auto-recommendations

✅ workoutGenerationService.js
   - Generates plans from both template types
   - Stores template metadata (blocks, fitness scores, routing)
   - Creates weeks, days, exercises, conditioning
   - Supports both intake levels
```

### 2. **Database Schema (New Migration)**
```
✅ 002_workout_templates_schema.sql
   - Added template fields to workout_plans
   - Created workout_weeks table
   - Created workout_day_exercises table (replaces workout_exercises)
   - Created workout_day_conditioning table
   - Created workout_plan_metadata table
   - Added intake_completed_stage to users
   - Updated views for progress tracking
```

### 3. **Directory Structure**
```
✅ src/data/workout-templates/
   ├── README.md                        - Complete format docs
   ├── starter/                         - Starter templates (3 questions)
   │   └── fat-loss-gym-3days.json     - Example starter template
   └── advanced/                        - Advanced templates (full intake)
       └── (ready for your files)
```

### 4. **Documentation (4 files)**
```
✅ WORKOUT_TEMPLATES_QUICK_START.md          - Quick reference
✅ WORKOUT_TEMPLATES_GUIDE.md                - Complete usage guide  
✅ WORKOUT_TEMPLATES_TWO_TIER_SYSTEM.md      - This file
✅ src/data/workout-templates/README.md      - Template format spec
```

### 5. **Example Template**
```
✅ starter/fat-loss-gym-3days.json
   - Complete 12-week program
   - 3 sessions per week
   - Periodization blocks
   - Conditioning work
   - Fitness score projections
   - Full bilingual support
```

---

## 🎯 Two-Tier System Explained

### Tier 1: Starter Templates

**Based on 3 basic intake questions:**
1. What's your goal? (fat_loss, muscle_gain, etc.)
2. Where do you train? (gym, home, outdoors)
3. How many days per week? (1-7)

**Characteristics:**
- ✅ Quick onboarding (< 1 minute)
- ✅ Generalized programs
- ✅ Proven progressions
- ✅ Beginner-friendly
- ✅ No injury considerations
- ✅ Standard equipment

**Use Cases:**
- New users who want to start quickly
- Users unsure about their needs
- Users testing the app
- Simple, straightforward goals

**File Location:** `/backend/src/data/workout-templates/starter/`

---

### Tier 2: Advanced Templates

**Based on full intake questionnaire:**
1. Detailed goal analysis
2. Training location & equipment available
3. Training frequency & schedule
4. Experience level & fitness background
5. **Injury history & limitations**
6. **Exercise preferences**
7. **Recovery capacity**
8. **Lifestyle factors**
9. And more...

**Characteristics:**
- ✅ Highly personalized
- ✅ Accounts for injuries
- ✅ Equipment-specific
- ✅ Experience-level appropriate
- ✅ Advanced techniques
- ✅ Specific periodization

**Use Cases:**
- Users who complete full intake
- Users with injuries/limitations
- Experienced athletes
- Specific performance goals
- Users wanting maximum personalization

**File Location:** `/backend/src/data/workout-templates/advanced/`

---

## 📝 Template Format

### New Format vs Old Format

**Old Format (v1):**
```json
{
  "id": "beginner-fat-loss",
  "level": "beginner",
  "goal": "fat_loss",
  "weeks": [...]
}
```

**New Format (v2 - Current):**
```json
{
  "plan_id": "starter_fatloss_gym_3d_v1",
  "type": "starter",
  "goal": "fat_loss",
  "location": "gym",
  "training_days": 3,
  "weeks": 12,
  "blocks": [...],
  "sessions": [...],
  "fitness_score": {...},
  "routing": {...}
}
```

### Key Differences:
- ✅ `type` instead of `level` (starter/advanced vs beginner/intermediate/advanced)
- ✅ `location` field (gym/home/outdoors/hybrid)
- ✅ `training_days` instead of `daysPerWeek`
- ✅ `sessions` instead of `weeks.days` (sessions repeat across weeks)
- ✅ `blocks` for periodization
- ✅ `fitness_score` for progress projection
- ✅ `routing` for injury/equipment swaps
- ✅ Exercise format matches your specification

---

## 🏗️ Template Structure Breakdown

### Root Level
```json
{
  "plan_id": "starter_fatloss_gym_3d_v1",
  "type": "starter",                    // or "advanced"
  "goal": "fat_loss",                   // fat_loss, muscle_gain, etc.
  "location": "gym",                    // gym, home, outdoors, hybrid
  "training_days": 3,                   // 1-7
  "weeks": 12,                          // 1-52
  "name_en": "Starter Fat Loss",
  "name_ar": "حرق الدهون للمبتدئين"
}
```

### Blocks (Periodization)
```json
"blocks": [
  {
    "block": 1,
    "weeks": [1, 2],
    "focus": "technique + base",
    "focus_ar": "التقنية والأساس",
    "progression": "RPE 6 → 7"
  }
]
```

### Sessions (Training Days)
```json
"sessions": [
  {
    "day": 1,                           // Day of week
    "name_en": "Full Body A",
    "name_ar": "الجسم الكامل أ",
    "work": [ /* exercises */ ],
    "conditioning": { /* optional */ }
  }
]
```

### Exercises
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

### Conditioning
```json
{
  "type": "intervals",
  "type_ar": "فواصل",
  "machine_options": ["rower", "bike"],
  "protocol": "30s ON / 30s OFF × 12",
  "protocol_ar": "30 ثانية / 30 ثانية × 12",
  "target_heart_rate": "75–85% max",
  "duration_min": 12
}
```

### Fitness Score Projection
```json
{
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
}
```

### Routing Config
```json
{
  "injury_swaps": true,
  "equipment_swaps": true
}
```

---

## 🗄️ Database Schema

### New Tables Created:

1. **workout_weeks**
   - Organizes workouts by week
   - Supports multi-week programs

2. **workout_day_exercises**
   - Individual exercises with full detail
   - Replaces `workout_exercises`
   - Stores: rpe, equipment, muscles, video_id

3. **workout_day_conditioning**
   - Conditioning/cardio sessions
   - Stores: type, protocol, intensity, machines

4. **workout_plan_metadata**
   - Template-specific data
   - Stores: location, blocks, fitness_score, routing

### Updated Tables:

1. **workout_plans**
   - Added: name_ar, description_ar
   - Added: goal, duration_weeks, days_per_week
   - Added: template_id, template_type

2. **users**
   - Added: intake_completed_stage ('basic' or 'full')

3. **user_intake**
   - Added: workout_location
   - Added: available_days
   - Added: training_days_per_week

---

## 🔌 API Flow

### Starter Flow

```
User completes basic intake (3 questions)
    ↓
POST /v2/intake/basic
{
  "primary_goal": "lose_weight",
  "workout_location": "gym",
  "available_days": 3
}
    ↓
User set to intake_completed_stage = 'basic'
    ↓
GET /v2/workouts/recommend-template
    ↓
Returns starter template matching criteria
    ↓
POST /v2/workouts/generate-from-template
{
  "templateId": "starter_fatloss_gym_3d_v1"
}
    ↓
Workout plan created with 12 weeks, 3 sessions/week
```

### Advanced Flow

```
User completes full intake questionnaire
    ↓
POST /v2/intake/full
{
  /* All intake data including injuries, etc. */
}
    ↓
User set to intake_completed_stage = 'full'
    ↓
GET /v2/workouts/recommend-template
    ↓
Returns advanced template considering injuries, equipment, etc.
    ↓
POST /v2/workouts/generate-from-template
{
  "templateId": "advanced_fatloss_gym_5d_v1"
}
    ↓
Personalized workout plan created
```

---

## 🎯 Recommendation Logic

### findBestMatch() Algorithm

```javascript
1. Determine intake level (starter or advanced)
2. Get templates for that level
3. Filter by goal (map user goal to template goal)
4. Filter by location (map user location to template location)
5. Filter by available days (≤ user's available days)
6. Sort by closest training_days match
7. Return best match
```

### Goal Mapping
```
User Goal          →  Template Goal
"lose_weight"      →  "fat_loss"
"build_muscle"     →  "muscle_gain"
"improve_endurance"→  "endurance"
"get_stronger"     →  "strength"
```

### Location Mapping
```
User Location      →  Template Location
"at_gym"           →  "gym"
"at_home"          →  "home"
"outdoors"         →  "outdoors"
"both"             →  "hybrid"
```

---

## 📂 File Organization

### Recommended Structure

```
starter/
├── fat-loss-gym-3days.json
├── fat-loss-gym-4days.json
├── fat-loss-home-3days.json
├── fat-loss-home-4days.json
├── muscle-gain-gym-3days.json
├── muscle-gain-gym-4days.json
├── muscle-gain-home-3days.json
├── general-fitness-gym-3days.json
├── endurance-outdoors-4days.json
└── ...

advanced/
├── fat-loss-gym-5days-intermediate.json
├── fat-loss-gym-6days-advanced.json
├── muscle-gain-gym-5days-powerlifting.json
├── muscle-gain-gym-6days-bodybuilding.json
├── endurance-outdoors-6days-marathon.json
└── ...
```

---

## 🚀 How to Use

### Step 1: Add Your JSON Files

Place your template files in the correct directory:
- `/backend/src/data/workout-templates/starter/` - For starter templates
- `/backend/src/data/workout-templates/advanced/` - For advanced templates

### Step 2: Follow the Format

Use the example template as reference:
- `/backend/src/data/workout-templates/starter/fat-loss-gym-3days.json`

Key points:
- ✅ Set `type` to "starter" or "advanced"
- ✅ Provide both English and Arabic text
- ✅ Include all required fields
- ✅ Use valid values for goal, location

### Step 3: Restart Server

```bash
cd backend
npm run dev
```

Check logs:
```
Loaded template: starter_fatloss_gym_3d_v1 (Starter Fat Loss - 3 Days (Gym))
Loaded 10 workout templates
```

### Step 4: Test

```bash
# Get starter templates
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:3000/v2/workouts/templates?type=starter"

# Get advanced templates
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:3000/v2/workouts/templates?type=advanced"

# Generate workout
curl -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"templateId":"starter_fatloss_gym_3d_v1"}' \
  "http://localhost:3000/v2/workouts/generate-from-template"
```

---

## 🎨 Frontend Integration

### Flutter Example

```dart
// User completes basic intake
await apiService.submitBasicIntake({
  'primary_goal': 'lose_weight',
  'workout_location': 'gym',
  'available_days': 3,
});

// Get recommended template
final recommendation = await apiService.getRecommendedTemplate();

// Show to user
showDialog(
  context: context,
  builder: (ctx) => TemplateRecommendationDialog(
    template: recommendation['template'],
  ),
);

// User accepts - generate workout
await apiService.generateFromTemplate(
  templateId: recommendation['template']['plan_id'],
);

// Navigate to workout plan
Navigator.push(context, WorkoutPlanScreen());
```

---

## ✅ Migration Checklist

To use the new system, run the migration:

```bash
# Run migration
psql -U postgres -d fitcoach -f backend/src/database/migrations/002_workout_templates_schema.sql

# Or use the migrate script
cd backend
npm run migrate
```

This creates:
- ✅ workout_weeks table
- ✅ workout_day_exercises table
- ✅ workout_day_conditioning table
- ✅ workout_plan_metadata table
- ✅ New columns in workout_plans
- ✅ New columns in users
- ✅ New columns in user_intake

---

## 📊 Benefits

### For Users
- ✅ Quick starter option (< 1 min to get program)
- ✅ Detailed advanced option (personalized)
- ✅ Clear progression path
- ✅ Professional program design

### For Coaches
- ✅ Less time creating basic programs
- ✅ Focus on advanced customization
- ✅ Consistent quality
- ✅ Easy template management

### For Business
- ✅ Faster onboarding
- ✅ Higher conversion
- ✅ Scalable solution
- ✅ Better user experience

---

## 🎊 Summary

You now have a complete two-tier template system!

**What works:**
- ✅ Starter templates (3-question intake)
- ✅ Advanced templates (full intake)
- ✅ Smart template matching
- ✅ Complete database schema
- ✅ API endpoints
- ✅ Bilingual support
- ✅ Example template provided
- ✅ Complete documentation

**What you need to do:**
1. Add your JSON template files
2. Run database migration
3. Restart server
4. Start generating workouts!

---

## 📚 Documentation

- **WORKOUT_TEMPLATES_QUICK_START.md** - Quick reference
- **WORKOUT_TEMPLATES_GUIDE.md** - Complete guide
- **src/data/workout-templates/README.md** - Format specification
- **This file** - Two-tier system overview

---

**Status:** ✅ **READY TO USE**

**Just add your JSON files and you're good to go!** 🎉💪

---

**Questions?** Review the documentation or check the example template.

**Happy Coaching!** 🏋️‍♀️
