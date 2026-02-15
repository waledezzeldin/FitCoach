# FitCoach+ v2.0 - Quick Start Guide

## 🚀 Get Started in 5 Minutes

This guide helps you quickly understand the FitCoach+ application and navigate the documentation.

---

## What is FitCoach+?

**FitCoach+** is a comprehensive bilingual (English/Arabic) fitness coaching platform that connects users with certified fitness coaches. Think of it as:

- **For Users**: A personalized fitness companion with workout plans, nutrition tracking, progress monitoring, and direct coach communication
- **For Coaches**: A client management platform with plan builders, scheduling, earnings tracking
- **For Admins**: A complete business management dashboard with analytics, user/coach management, and system controls

---

## Key Features (v2.0)

### 🔐 Authentication
- **Phone OTP**: No passwords! SMS-based authentication with 6-digit codes
- **Saudi Focus**: Optimized for +966 phone numbers

### 📝 Two-Stage Intake
- **First Intake** (3 questions): Gender, Goal, Workout Location - Required for all users
- **Second Intake** (6 questions): Age, Weight, Height, Experience, Frequency, Injuries - Premium+ exclusive

### ⚖️ Tier-Based Subscriptions
- **Freemium** ($0): 20 messages/month, 1 video call, 7-day nutrition trial
- **Premium** ($19.99): 200 messages/month, 2 video calls, unlimited nutrition
- **Smart Premium** ($49.99): Unlimited messages, 4 video calls, all features + chat attachments

### 🍎 Time-Limited Nutrition (v2.0)
- Freemium users get 7-day nutrition trial
- Expiry warnings at 3, 2, 1 days before expiry
- Locked screen on expiration with upgrade prompt

### 🏋️ Injury-Aware Workouts (v2.0)
- 5 injury areas supported: Shoulder, Knee, Lower Back, Neck, Ankle
- Automatic exercise contraindication detection
- Modal with 3-5 safe alternative exercises
- One-click substitution with reasoning

### ⭐ Post-Interaction Ratings (v2.0)
- Rate coaches after video calls
- Rate workout plan quality every 10 messages
- Powers coach recommendations and quality analytics

---

## Application Structure

### 28 Total Screens

#### User Journey (12 screens)
1. **Language Selection** → Choose English or Arabic
2. **App Intro** → 3-slide feature walkthrough
3. **Phone OTP Auth** → Verify phone number
4. **First Intake** → 3 quick questions
5. **Second Intake** → 6 detailed questions (Premium+ only)
6. **Home Dashboard** → Main hub with stats and quick actions
7. **Workout Screen** → Exercise plans with timer and substitutions
8. **Nutrition Screen** → Meal plans with macro tracking
9. **Coach Messaging** → Chat with quota enforcement
10. **Store Screen** → E-commerce for fitness products
11. **Account Settings** → Profile and preferences
12. **Progress Detail** → Weight tracking, InBody scans, adherence

#### Coach Tools (6 screens)
13. **Coach Dashboard** → Client overview and stats
14. **Coach Calendar** → Schedule management
15. **Coach Messaging** → Client communication
16. **Workout Plan Builder** → Create custom workout plans
17. **Nutrition Plan Builder** → Create meal plans
18. **Coach Earnings** → Revenue tracking and payouts

#### Admin Dashboard (8 screens)
19. **Admin Main Dashboard** → Platform overview
20. **User Management** → CRUD operations on users
21. **Coach Management** → Approve/suspend coaches
22. **Content Management** → Exercise/food database
23. **Store Management** → Product inventory
24. **Subscription Management** → Override subscriptions
25. **System Settings** → Feature flags and configs
26. **Analytics Dashboard** → Business metrics

---

## Documentation Map

### 📘 For Non-Technical Stakeholders

**Start Here**:
1. [executive-summary.md](../3-software-architecture/executive-summary.md) (20 min read)
   - Product vision and business model
   - Target users and value propositions
   - All v2.0 features explained
   - Success metrics and roadmap

**Then Read**:
2. [screen-specifications.md](../3-software-architecture/screen-specifications.md) (1 hour browse)
   - Visual understanding of all 28 screens
   - User flows and interactions
   - Perfect for understanding user experience

---

### 💻 For Frontend Developers

**Priority Reading Order**:
1. [screen-specifications.md](../3-software-architecture/screen-specifications.md) - Build UI screens
2. [data-models.md](../2-software-requirements/data-models.md) - Understand data structures
3. [feature-specifications.md](../2-software-requirements/feature-specifications.md) - Implement features
4. [api-specifications.md](../2-software-requirements/api-specifications.md) - Call backend APIs

**Key Info**:
- All 28 screens documented with pixel-perfect specifications
- Component breakdowns for each screen
- Validation rules for forms
- RTL layout requirements for Arabic
- Demo mode behavior

---

### ⚙️ For Backend Developers

**Priority Reading Order**:
1. [data-models.md](../2-software-requirements/data-models.md) - Database schema
2. [api-specifications.md](../2-software-requirements/api-specifications.md) - API endpoints
3. [business-logic.md](../2-software-requirements/business-logic.md) - Algorithms
4. [feature-specifications.md](../2-software-requirements/feature-specifications.md) - Feature requirements

**Key Info**:
- 24 database tables with SQL schemas
- 60+ REST API endpoints documented
- 10 core algorithms (fitness score, macros, etc.)
- Security considerations and rate limiting

---

### 🎨 For UI/UX Designers

**Priority Reading Order**:
1. [screen-specifications.md](../3-software-architecture/screen-specifications.md) - Screen layouts
2. [executive-summary.md](../3-software-architecture/executive-summary.md) - User personas
3. [feature-specifications.md](../2-software-requirements/feature-specifications.md) - Feature flows

**Key Info**:
- Detailed component specifications
- User interaction patterns
- RTL design requirements for Arabic
- Accessibility guidelines
- Color-coded quota indicators
- Expiry banners (3-color system)

---

### 🧪 For QA/Test Engineers

**Priority Reading Order**:
1. [screen-specifications.md](../3-software-architecture/screen-specifications.md) - Test scenarios
2. [feature-specifications.md](../2-software-requirements/feature-specifications.md) - Edge cases
3. [business-logic.md](../2-software-requirements/business-logic.md) - Validation rules

**Key Info**:
- Validation rules for every input
- Edge cases documented per feature
- Error states and messages
- Demo mode for testing
- Testing strategies per feature

---

## Core Concepts to Understand

### 1. Subscription Tiers & Quota System

**How It Works**:
```
User sends message
    ↓
Check quota: messagesUsed < messagesTotal?
    ↓
   ┌─────┴─────┐
   ↓           ↓
  Yes          No
   ↓           ↓
Allow      Show Upgrade Prompt
   ↓
Increment quota
   ↓
Monthly reset (1st of month)
```

**Tier Limits**:
| Feature | Freemium | Premium | Smart Premium |
|---------|----------|---------|---------------|
| Messages | 20/month | 200/month | Unlimited |
| Video Calls | 1/month | 2/month | 4/month |
| Call Duration | 15 min | 25 min | 25 min |
| Nutrition | 7-day trial | Unlimited | Unlimited |
| Chat Attachments | ❌ | ❌ | ✅ |
| Second Intake | ❌ | ✅ | ✅ |

---

### 2. Nutrition Expiry (Freemium Only)

**Timeline**:
```
Day 1: Generate plan → Trial starts
Days 2-4: Full access (no warnings)
Day 5: Blue banner "2 days left"
Day 6: Orange banner "1 day left"
Day 7: Red banner "Last day!"
Day 8+: Locked screen → Upgrade required
```

**Implementation**:
- `generatedAt` timestamp stored on plan creation
- `expiresAt` = generatedAt + 7 days
- Check on every nutrition screen load
- Premium+ users: `expiresAt` = null (unlimited)

---

### 3. Injury Substitution Engine

**How It Works**:
```
User opens workout
    ↓
Load exercises
    ↓
For each exercise:
  Check against user injuries
    ↓
  Contraindication found?
   ┌─────┴─────┐
   ↓           ↓
  Yes          No
   ↓           ↓
Show warning  Continue
   ↓
Auto-open alternatives modal
   ↓
User selects safe alternative
   ↓
Exercise substituted
```

**Example**:
- User has **knee injury**
- Workout includes "Barbell Squat"
- System detects "squat" keyword
- Shows alternatives: Leg Extension, Wall Sit, Hip Thrust
- User selects "Leg Extension"
- Squat replaced, reason logged

---

### 4. Two-Stage Intake System

**Flow**:
```
New user verifies phone
    ↓
First Intake (3 questions)
   - Gender
   - Goal  
   - Location
    ↓
Check subscription tier
   ┌─────┴─────┐
   ↓           ↓
Freemium   Premium+
   ↓           ↓
  Home    Second Intake (6 questions)
               - Age
               - Weight
               - Height
               - Experience
               - Frequency
               - Injuries
                ↓
          Calculate Fitness Score
                ↓
               Home
```

**Why Two Stages?**
- First intake: Quick onboarding (all users)
- Second intake: Detailed profiling (Premium+ incentive)
- Drives conversion: Freemium → Premium

---

## Data Model at a Glance

### Core Tables (Top 10)

1. **users** - User accounts and profiles
2. **coaches** - Coach profiles and stats
3. **quota_usage** - Monthly message/call tracking
4. **workout_plans** → **workouts** → **workout_exercises** - Exercise hierarchy
5. **nutrition_plans** → **meals** → **food_items** - Meal hierarchy
6. **conversations** → **messages** - Chat system
7. **video_calls** - Scheduled/completed calls
8. **coach_ratings** - Post-interaction ratings
9. **orders** → **order_items** - E-commerce
10. **weight_entries** - Progress tracking

**Total**: 24 tables

---

## Key Algorithms

### 1. Fitness Score Calculation
```typescript
Base score: 50
+ Experience: 0 (beginner), 15 (intermediate), 30 (advanced)
+ Frequency: (workoutDays - 2) × 3
- Age factor: -5 if < 20, -1 per 5 years if > 45
- Injuries: -5 per injury (max -20)
- BMI factor: -10 if underweight/obese
= Final score (0-100)
```

### 2. Macro Calculation
```typescript
1. BMR (Mifflin-St Jeor)
2. TDEE = BMR × activity multiplier
3. Adjust for goal:
   - Fat loss: TDEE × 0.80
   - Muscle gain: TDEE × 1.10
   - Maintenance: TDEE × 1.00
4. Protein: 1.8-2.2 g/kg
5. Fats: 27% of calories
6. Carbs: Remaining calories
```

### 3. Injury Substitution
```typescript
1. Check exercise name against avoid keywords
2. If match found → flag exercise
3. Look up injury rule
4. Filter alternatives by muscle group
5. Return 3-5 safe alternatives with reasoning
6. User selects → update workout plan
```

---

## Typical User Journeys

### New User (Freemium)
```
1. Open app → Language selection (English/Arabic)
2. View intro slides (3 slides)
3. Enter phone number → Receive OTP → Verify
4. Complete First Intake (3 questions)
5. Arrive at Home Dashboard
6. Tap "Nutrition" → Generate plan (7-day trial starts)
7. View meal plan, log meals
8. Day 5: See expiry warning banner
9. Day 8: Nutrition locked → Upgrade prompt
10. Tap "Upgrade" → Checkout → Premium!
```

### Existing User (Premium)
```
1. Open app → Auto-login (token valid)
2. Home Dashboard loads
3. See "Today's Workout: Upper Body Strength"
4. Tap "Start Workout"
5. Exercise 1: "Overhead Press" → ⚠️ Injury alert (shoulder injury)
6. Alternatives modal opens
7. Select "Landmine Press" (safe alternative)
8. Complete workout with timer
9. Rate workout plan (4 stars)
10. Check progress → Weight down 0.5kg this week!
```

### Coach User
```
1. Login → Coach Dashboard
2. See 12 active clients
3. Client "Ahmed" sent message → Respond
4. Check calendar → 2 video calls today
5. Build workout plan for new client
6. Review client progress reports
7. Check earnings: $1,250 this month
```

---

## Technical Highlights

### Frontend
- **React 18** with TypeScript
- **Tailwind CSS v4** (embedded config)
- **Vite 5** (build tool, HMR disabled due to large translations)
- **Code Splitting**: Translations exported separately
- **RTL Support**: Full right-to-left layout for Arabic
- **Responsive**: Mobile-first design

### Backend (Recommended)
- **Node.js + Express** or **Django** or **Spring Boot**
- **PostgreSQL** (primary database with indexes)
- **Redis** (caching, session management)
- **AWS S3** (file storage for attachments)
- **Twilio/AWS SNS** (SMS OTP delivery)

### Deployment
- **Frontend**: Vercel, Netlify, or AWS Amplify
- **Backend**: AWS ECS, DigitalOcean, or Heroku
- **Database**: AWS RDS, DigitalOcean Managed DB
- **CDN**: CloudFront for file delivery

---

## Common Questions

### Q: Can I migrate this to React Native?
**A**: Yes! All specifications are platform-agnostic. Use:
- Document 3 for screen layouts → React Native components
- Document 2 for data models → AsyncStorage or Realm
- Document 5 for algorithms → Port to JavaScript

### Q: Can I use a different database (MongoDB, MySQL)?
**A**: Yes! SQL schemas provided convert easily:
- PostgreSQL → MySQL: Minimal changes
- PostgreSQL → MongoDB: Convert tables to collections, adjust relationships

### Q: Is the translation data included?
**A**: Translation keys are referenced throughout, but the full 2,904-key translation file should be extracted from `/components/translations-data.ts` in the original React app.

### Q: How long to implement from scratch?
**A**: Estimated **14 weeks** with 2-3 full-time developers:
- Weeks 1-2: Database + Auth
- Weeks 3-6: Core features (Intake, Workout, Nutrition)
- Weeks 7-10: Advanced features (Injury engine, Ratings)
- Weeks 11-12: Coach/Admin tools
- Weeks 13-14: Polish + Testing

### Q: Can I add new features not in the spec?
**A**: Absolutely! The architecture is designed to be extensible:
- Add new injury areas to substitution engine
- Add new subscription tiers
- Integrate wearables (Apple Health, Google Fit)
- Add social features (friend challenges, etc.)

---

## Next Steps

### For Your First Hour:
1. ✅ Read this Quick Start (10 min)
2. ✅ Skim [executive-summary.md](../3-software-architecture/executive-summary.md) (20 min)
3. ✅ Browse [screen-specifications.md](../3-software-architecture/screen-specifications.md) (30 min)
4. ✅ You now understand 80% of the app!

### For Your First Day:
1. ✅ Read your role-specific documents (see "Documentation Map" above)
2. ✅ Review [data-models.md](../2-software-requirements/data-models.md) for data structures
3. ✅ Check [api-specifications.md](../2-software-requirements/api-specifications.md) for API contracts
4. ✅ Plan your implementation approach

### For Your First Week:
1. ✅ Set up development environment
2. ✅ Create database schema from Document 2
3. ✅ Implement authentication (OTP flow)
4. ✅ Build 3-5 core screens (Language, Auth, Home, Workout, Nutrition)
5. ✅ Test critical user flows

---

## Support & Resources

**Documentation Files**:
- [quick-start.md](./quick-start.md) ← You are here
- [executive-summary.md](../3-software-architecture/executive-summary.md) - Business overview
- [data-models.md](../2-software-requirements/data-models.md) - Database schema
- [screen-specifications.md](../3-software-architecture/screen-specifications.md) - UI requirements
- [feature-specifications.md](../2-software-requirements/feature-specifications.md) - Feature details
- [business-logic.md](../2-software-requirements/business-logic.md) - Algorithms
- [api-specifications.md](../2-software-requirements/api-specifications.md) - API endpoints

**Original Source**:
- React app source code: `/components/*.tsx`
- Type definitions: `/types/*.ts`
- Business logic: `/utils/*.ts`

**Need Help?**
- Refer to specific document sections
- Check edge cases in Feature Specifications
- Review validation rules in Screen Specifications
- Look up algorithms in Business Logic document

---

## License

All documentation is proprietary to FitCoach+.

---

**Version**: 2.0.0  
**Last Updated**: December 18, 2024  
**Status**: ✅ Production Ready

---

## 🎉 Ready to Build?

**Choose your starting point**:
- 👨‍💼 **Business/Product**: Start with [executive-summary.md](../3-software-architecture/executive-summary.md)
- 💻 **Frontend Dev**: Start with [screen-specifications.md](../3-software-architecture/screen-specifications.md)
- ⚙️ **Backend Dev**: Start with [data-models.md](../2-software-requirements/data-models.md)
- 🎨 **Designer**: Start with [screen-specifications.md](../3-software-architecture/screen-specifications.md)
- 🧪 **QA Engineer**: Start with [feature-specifications.md](../2-software-requirements/feature-specifications.md)

**Let's build something amazing! 🚀**
