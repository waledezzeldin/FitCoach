# 🚀 Workout Templates - Quick Start Guide

## ⚡ Two Template Types

### 1. **Starter Templates** (3-Question Intake)
- Based on: Goal, Location, Training Days
- For: Quick onboarding, new users
- Directory: `/backend/src/data/workout-templates/starter/`

### 2. **Advanced Templates** (Full Intake)
- Based on: Complete questionnaire (injuries, experience, etc.)
- For: Personalized programs, experienced users
- Directory: `/backend/src/data/workout-templates/advanced/`

---

## 📝 Quick Template Format

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
          "sets": 3,
          "reps": "6–10",
          "rest_s": 120,
          "equip": ["barbell"],
          "muscles": ["quads","glutes"]
        }
      ]
    }
  ]
}
```

---

## 🎯 Required Fields

### Minimum Required:
```
✅ plan_id             - Unique ID
✅ type                - "starter" or "advanced"
✅ goal                - fat_loss, muscle_gain, etc.
✅ location            - gym, home, outdoors, hybrid
✅ training_days       - 1-7
✅ weeks               - 1-52
✅ name_en / name_ar   - Names in both languages
✅ sessions            - Array of workout sessions
    ✅ day             - Day number
    ✅ name_en/name_ar - Session names
    ✅ work            - Array of exercises
        ✅ ex_id       - Exercise ID
        ✅ name_en/ar  - Exercise names
        ✅ sets        - Number
        ✅ reps        - String ("6-10", "AMRAP", etc.)
```

---

## 📂 How to Add Your Files

### Step 1: Place Files
```bash
# Starter templates
/backend/src/data/workout-templates/starter/
├── fat-loss-gym-3days.json       ← Your file
├── muscle-gain-gym-4days.json    ← Your file
└── ...

# Advanced templates
/backend/src/data/workout-templates/advanced/
├── fat-loss-gym-5days.json       ← Your file
└── ...
```

### Step 2: Restart Server
```bash
cd backend
npm run dev
```

### Step 3: Check Logs
Look for:
```
Loaded template: starter_fatloss_gym_3d_v1 (Starter Fat Loss - 3 Days)
Loaded 10 workout templates
```

---

## ✅ Valid Values

### Type
- `starter` or `advanced`

### Goal
- `fat_loss`
- `muscle_gain`
- `general_fitness`
- `endurance`
- `strength`
- `hypertrophy`

### Location
- `gym`
- `home`
- `outdoors`
- `hybrid`

### File Names
- `fat-loss-gym-3days.json`
- `muscle-gain-home-4days.json`
- `endurance-outdoors-5days.json`

---

## 🔌 API Endpoints

### Get Templates
```bash
GET /v2/workouts/templates?type=starter&goal=fat_loss
```

### Generate Workout
```bash
POST /v2/workouts/generate-from-template
{
  "templateId": "starter_fatloss_gym_3d_v1",
  "customizations": {
    "startDate": "2024-12-22"
  }
}
```

### Get Recommendation
```bash
GET /v2/workouts/recommend-template
```

---

## 💡 Starter vs Advanced

### Use **Starter** when:
- ✅ User completes basic intake (3 questions)
- ✅ Quick onboarding needed
- ✅ General program is fine

### Use **Advanced** when:
- ✅ User completes full intake
- ✅ Has injuries to work around
- ✅ Needs specific customization
- ✅ More experienced

---

## 📊 Example Usage

### User completes basic intake:
```javascript
// User answers:
// 1. Goal: Fat Loss
// 2. Location: Gym
// 3. Days: 3

// Backend finds matching starter template
const template = await workoutTemplateService.searchTemplates({
  type: 'starter',
  goal: 'fat_loss',
  location: 'gym',
  training_days: 3
});

// Generate plan
await workoutGenerationService.generateFromTemplate(
  userId,
  template.plan_id
);
```

---

## 🎨 Template Structure

```
Template
├── plan_id, type, goal, location
├── training_days, weeks
├── name_en, name_ar
├── blocks (optional periodization)
└── sessions
    ├── day, name_en, name_ar
    ├── work (exercises)
    │   ├── ex_id, name_en, name_ar
    │   ├── sets, reps, rest_s
    │   ├── equip, muscles
    │   └── notes_en, notes_ar
    └── conditioning (optional)
        ├── type, protocol
        └── intensity, duration
```

---

## 🗂️ File Organization

### Recommended:
```
starter/
├── fat-loss-gym-3days.json
├── fat-loss-gym-4days.json
├── fat-loss-home-3days.json
├── muscle-gain-gym-4days.json
└── ...

advanced/
├── fat-loss-gym-5days-intermediate.json
├── muscle-gain-gym-6days-advanced.json
└── ...
```

---

## 🏃 Quick Checklist

- [ ] Choose type: `starter` or `advanced`
- [ ] Create JSON file with all required fields
- [ ] Add Arabic translations
- [ ] Save to correct directory
- [ ] Restart server
- [ ] Check logs for successful load
- [ ] Test via API

---

## 📖 Full Documentation

- **README.md** - Complete format specification
- **WORKOUT_TEMPLATES_GUIDE.md** - Detailed usage guide
- **Example** - `/starter/fat-loss-gym-3days.json`

---

## 🎊 That's It!

1. Create JSON files
2. Place in `/starter/` or `/advanced/`
3. Restart server
4. Done! ✅

**Your templates are ready to generate workouts!** 💪
