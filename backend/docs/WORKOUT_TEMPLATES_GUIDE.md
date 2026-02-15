# 🏋️ Workout Templates System - Complete Guide

## Overview

The workout templates system allows you to generate personalized workout plans from predefined JSON template files. This guide explains how to add your own templates and use the system.

---

## 📁 Directory Structure

```
backend/src/data/workout-templates/
├── README.md              # Template format documentation
├── beginner/
│   ├── fat-loss.json      # Example template (replace with yours)
│   ├── muscle-gain.json   # Add your templates here
│   ├── general-fitness.json
│   └── endurance.json
├── intermediate/
│   ├── fat-loss.json
│   ├── muscle-gain.json
│   ├── general-fitness.json
│   └── endurance.json
└── advanced/
    ├── fat-loss.json
    ├── muscle-gain.json
    ├── general-fitness.json
    └── endurance.json
```

---

## 🚀 Quick Start

### Step 1: Add Your JSON Files

1. Place your workout template JSON files in the appropriate level directory:
   - `beginner/` - For beginner programs
   - `intermediate/` - For intermediate programs
   - `advanced/` - For advanced programs

2. Name your files based on the goal:
   - `fat-loss.json`
   - `muscle-gain.json`
   - `general-fitness.json`
   - `endurance.json`

### Step 2: JSON File Format

Each JSON file should follow this structure:

```json
{
  "id": "unique-template-id",
  "name": "Template Name",
  "nameAr": "اسم القالب",
  "description": "Description in English",
  "descriptionAr": "الوصف بالعربية",
  "goal": "fat_loss",
  "level": "beginner",
  "durationWeeks": 8,
  "daysPerWeek": 4,
  "equipment": ["bodyweight", "dumbbells"],
  "weeks": [
    {
      "weekNumber": 1,
      "days": [
        {
          "dayNumber": 1,
          "dayName": "Monday",
          "dayNameAr": "الإثنين",
          "focus": "Full Body",
          "focusAr": "الجسم الكامل",
          "exercises": [
            {
              "exerciseId": null,
              "exerciseName": "Push-ups",
              "exerciseNameAr": "تمرين الضغط",
              "sets": 3,
              "reps": "10-12",
              "restSeconds": 60,
              "notes": "Keep form strict",
              "notesAr": "حافظ على الشكل الصحيح",
              "order": 1
            }
          ]
        }
      ]
    }
  ],
  "metadata": {
    "createdBy": "system",
    "version": "1.0",
    "tags": ["fat_loss", "beginner"],
    "estimatedCaloriesBurn": 300,
    "difficulty": "easy"
  }
}
```

### Step 3: Restart Server

After adding your JSON files, restart the server:

```bash
npm run dev
```

The server will automatically load all templates on startup.

---

## 📝 Field Requirements

### Required Fields

```
✅ id                    - Unique identifier
✅ name                  - English name
✅ nameAr                - Arabic name
✅ goal                  - One of: fat_loss, muscle_gain, general_fitness, endurance
✅ level                 - One of: beginner, intermediate, advanced
✅ durationWeeks         - 1-52 weeks
✅ daysPerWeek           - 1-7 days
✅ weeks                 - Array of week objects
```

### Week Requirements

```
✅ weekNumber            - Week number (1-N)
✅ days                  - Array of day objects
```

### Day Requirements

```
✅ dayNumber             - Day number (1-7)
✅ dayName               - Day name in English
✅ dayNameAr             - Day name in Arabic
✅ exercises             - Array of exercise objects
```

### Exercise Requirements

```
✅ exerciseName          - Exercise name in English
✅ exerciseNameAr        - Exercise name in Arabic
✅ sets                  - Number of sets
✅ reps                  - Reps (can be "10-12", "AMRAP", "30s")
✅ order                 - Exercise order (1-N)

Optional:
⭕ exerciseId           - Link to exercise database
⭕ restSeconds          - Rest time between sets
⭕ notes                - Exercise notes in English
⭕ notesAr              - Exercise notes in Arabic
```

---

## 🔌 API Endpoints

### 1. Get All Templates

```http
GET /v2/workouts/templates
```

**Query Parameters:**
- `goal` - Filter by goal (fat_loss, muscle_gain, etc.)
- `level` - Filter by level (beginner, intermediate, advanced)
- `durationWeeks` - Filter by duration
- `daysPerWeek` - Filter by days per week
- `equipment` - Filter by required equipment

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:3000/v2/workouts/templates?goal=fat_loss&level=beginner"
```

**Response:**
```json
{
  "success": true,
  "templates": [
    {
      "id": "beginner-fat-loss-8weeks",
      "name": "Beginner Fat Loss - 8 Weeks",
      "nameAr": "حرق الدهون للمبتدئين - 8 أسابيع",
      "goal": "fat_loss",
      "level": "beginner",
      "durationWeeks": 8,
      "daysPerWeek": 4
    }
  ],
  "count": 1
}
```

### 2. Get Template by ID

```http
GET /v2/workouts/templates/:id
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:3000/v2/workouts/templates/beginner-fat-loss-8weeks"
```

**Response:**
```json
{
  "success": true,
  "template": {
    "id": "beginner-fat-loss-8weeks",
    "name": "Beginner Fat Loss - 8 Weeks",
    "weeks": [ /* Full week data */ ]
  }
}
```

### 3. Generate Workout from Template

```http
POST /v2/workouts/generate-from-template
```

**Body:**
```json
{
  "templateId": "beginner-fat-loss-8weeks",
  "userId": "user-id-here",
  "customizations": {
    "name": "My Custom Plan Name",
    "startDate": "2024-12-22",
    "includeUserName": true
  }
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "beginner-fat-loss-8weeks",
    "customizations": {
      "startDate": "2024-12-22"
    }
  }' \
  "http://localhost:3000/v2/workouts/generate-from-template"
```

**Response:**
```json
{
  "success": true,
  "message": "Workout plan generated successfully",
  "plan": {
    "id": "generated-plan-id",
    "name": "Beginner Fat Loss - 8 Weeks",
    "startDate": "2024-12-22",
    "endDate": "2025-02-16"
  },
  "templateUsed": "beginner-fat-loss-8weeks"
}
```

### 4. Get Recommended Template

```http
GET /v2/workouts/recommend-template/:userId?
```

**Example:**
```bash
# For current user
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:3000/v2/workouts/recommend-template"

# For specific user (coach/admin)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:3000/v2/workouts/recommend-template/user-id-here"
```

**Response:**
```json
{
  "success": true,
  "template": {
    "id": "beginner-fat-loss-8weeks",
    "name": "Beginner Fat Loss - 8 Weeks",
    "nameAr": "حرق الدهون للمبتدئين - 8 أسابيع",
    "description": "Recommended based on your profile"
  }
}
```

---

## 💡 Usage Examples

### Example 1: User Selects Template

```javascript
// Frontend: User browses templates
const response = await fetch('/v2/workouts/templates?goal=fat_loss', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { templates } = await response.json();

// User selects a template
const selectedTemplateId = templates[0].id;

// Generate workout plan
await fetch('/v2/workouts/generate-from-template', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    templateId: selectedTemplateId,
    customizations: {
      startDate: new Date().toISOString()
    }
  })
});
```

### Example 2: Automatic Recommendation

```javascript
// Frontend: Get recommendation based on user profile
const response = await fetch('/v2/workouts/recommend-template', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { template } = await response.json();

// Show recommendation to user
console.log(`Recommended: ${template.name}`);

// User accepts recommendation
await fetch('/v2/workouts/generate-from-template', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    templateId: template.id
  })
});
```

### Example 3: Coach Assigns Template

```javascript
// Frontend: Coach selects template for client
const clientId = 'client-user-id';
const templateId = 'intermediate-muscle-gain';

await fetch('/v2/workouts/generate-from-template', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${coachToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    userId: clientId,
    templateId: templateId,
    customizations: {
      name: 'John\'s Custom Muscle Gain Program',
      includeUserName: true
    }
  })
});
```

---

## 🎯 Template Customization Options

When generating a workout from a template, you can customize:

```json
{
  "name": "Custom plan name",
  "nameAr": "اسم مخصص للخطة",
  "description": "Custom description",
  "descriptionAr": "وصف مخصص",
  "startDate": "2024-12-22",
  "includeUserName": true
}
```

- **name**: Override template name
- **nameAr**: Override Arabic name
- **description**: Override description
- **descriptionAr**: Override Arabic description
- **startDate**: Set custom start date (defaults to today)
- **includeUserName**: Add user's name to plan title

---

## 🔍 Template Recommendation Logic

The system recommends templates based on:

1. **User's Fitness Level**
   - From user intake: `fitness_level`
   - Maps to: beginner, intermediate, advanced

2. **User's Primary Goal**
   - From user intake: `primary_goal`
   - Maps to: fat_loss, muscle_gain, endurance, general_fitness

3. **User's Injuries**
   - Considers contraindications
   - Filters out incompatible exercises

Example mapping:
```
User Goal          →  Template Goal
"lose_weight"      →  "fat_loss"
"build_muscle"     →  "muscle_gain"
"improve_endurance" → "endurance"
```

---

## ✅ Validation

Templates are validated on load for:

- ✅ Required fields present
- ✅ Valid goal values
- ✅ Valid level values
- ✅ Valid numeric ranges
- ✅ Proper array structures
- ✅ Week and day sequences

If a template fails validation, it's skipped and an error is logged.

---

## 🐛 Troubleshooting

### Templates Not Loading

**Issue:** Server starts but no templates loaded

**Solution:**
1. Check file location: `/backend/src/data/workout-templates/[level]/[goal].json`
2. Check JSON syntax: Use a JSON validator
3. Check file permissions: Ensure files are readable
4. Check logs: Look for validation errors

### Template Not Found

**Issue:** `GET /templates/:id` returns 404

**Solution:**
1. Verify template ID matches the `id` field in JSON
2. Check if template loaded successfully on startup
3. Restart server to reload templates

### Generation Fails

**Issue:** `POST /generate-from-template` returns 500

**Solution:**
1. Check database connection
2. Verify user exists
3. Check template structure
4. Review server logs for specific error

---

## 📊 Template Statistics

Get statistics about loaded templates:

```javascript
// In backend code
const workoutTemplateService = require('./services/workoutTemplateService');
const stats = workoutTemplateService.getStatistics();
console.log(stats);

/* Output:
{
  total: 12,
  byGoal: {
    fat_loss: 4,
    muscle_gain: 4,
    general_fitness: 2,
    endurance: 2
  },
  byLevel: {
    beginner: 4,
    intermediate: 4,
    advanced: 4
  },
  byGoalLevel: {
    beginner_fat_loss: 1,
    beginner_muscle_gain: 1,
    ...
  }
}
*/
```

---

## 🔄 Reload Templates

To reload templates without restarting server (development only):

```javascript
// Add this endpoint in development mode
app.get('/v2/admin/reload-templates', async (req, res) => {
  try {
    const count = await workoutTemplateService.reloadTemplates();
    res.json({ success: true, count });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

---

## 📚 Complete Example Template

See `/backend/src/data/workout-templates/beginner/fat-loss.json` for a complete example template with all fields properly filled out.

---

## ✨ Best Practices

1. **Unique IDs**: Use descriptive IDs like `level-goal-duration`
2. **Complete Weeks**: Include all weeks, not just Week 1
3. **Progressive Overload**: Increase difficulty across weeks
4. **Arabic Support**: Always provide Arabic translations
5. **Clear Instructions**: Add notes for proper form
6. **Test Templates**: Generate and test each template
7. **Version Control**: Keep templates in version control
8. **Documentation**: Document any special requirements

---

## 🎊 Summary

You now have a complete template-based workout generation system!

**What you can do:**
1. ✅ Add unlimited JSON template files
2. ✅ Filter and search templates
3. ✅ Generate personalized workout plans
4. ✅ Get automatic recommendations
5. ✅ Customize generated plans
6. ✅ Support multiple levels and goals

**To add your templates:**
1. Create JSON files following the format
2. Place them in the appropriate directory
3. Restart the server
4. Start generating workouts!

---

**Questions?** Check the README.md in the templates directory or review the example template provided.

**Happy Fitness Coaching!** 🏋️‍♀️💪
