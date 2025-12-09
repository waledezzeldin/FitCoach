# FitCoach+ v2.0 - Software Requirements Specification

## 📋 Documentation Overview

This directory contains comprehensive software requirements documentation for **FitCoach+**, a bilingual (English/Arabic) fitness coaching platform. The documentation is designed to be **platform-agnostic** and suitable for migration to any programming language or framework.

---

## 📚 Document Structure

### 1. [Executive Summary](./01-EXECUTIVE-SUMMARY.md)
**Purpose**: High-level overview of the entire project  
**Audience**: Stakeholders, Product Managers, Technical Leads  
**Contains**:
- Project vision and business model
- Target audience and value propositions
- Major v2.0 upgrade features
- Technical architecture overview
- 28-screen inventory
- Success metrics and roadmap
- Migration considerations
- Glossary of terms

**Read this first** to understand the project scope and business context.

---

### 2. [Data Models & Schema](./02-DATA-MODELS.md)
**Purpose**: Complete database design and type definitions  
**Audience**: Backend Developers, Database Administrators, System Architects  
**Contains**:
- All TypeScript interface definitions
- SQL database schemas (PostgreSQL-compatible)
- 17 core data models:
  - User & Authentication
  - Coach Profiles
  - Intake System (First & Second)
  - Quota Management
  - Workout & Exercise Models
  - Nutrition & Meal Models
  - Messaging & Video Calls
  - Ratings & Reviews
  - E-Commerce (Products, Orders)
  - Progress Tracking
  - Admin & System Models
  - Injury Substitution Models
- Database indexes and optimization
- Data relationships diagram
- Migration checklist

**Use this** to implement the database layer in any backend technology.

---

### 3. [Screen Specifications](./03-SCREEN-SPECIFICATIONS.md)
**Purpose**: Detailed UI/UX requirements for all 28 screens  
**Audience**: Frontend Developers, UI/UX Designers, QA Engineers  
**Contains**:
- Screen-by-screen breakdown with:
  - Purpose and entry points
  - Complete UI component specifications
  - User interaction flows
  - Data requirements (API endpoints)
  - Validation rules
  - Navigation flows
  - RTL (Right-to-Left) considerations for Arabic
  - Accessibility requirements
  - Error states and edge cases
  - Demo mode behavior

**Screens Covered**:
- **User Journey** (12): Language Selection, App Intro, Phone OTP Auth, First/Second Intake, Home Dashboard, Workout, Nutrition, Coach Messaging, Store, Account, Progress
- **Coach Tools** (6): Coach Dashboard, Calendar, Messaging, Workout/Nutrition Plan Builders, Earnings
- **Admin Dashboard** (8): Main Dashboard, User/Coach/Content Management, Store Management, Subscriptions, System Settings, Analytics
- **Supporting** (2): Exercise Library, Video Booking

**Use this** to build pixel-perfect UI screens in any frontend framework.

---

### 4. [Feature Specifications](./04-FEATURE-SPECIFICATIONS.md)
**Purpose**: Deep dive into major v2.0 features with implementation details  
**Audience**: Full-Stack Developers, Product Managers  
**Contains**:
- **Phone OTP Authentication System**
  - Phone validation (Saudi Arabia format)
  - OTP generation and verification
  - Rate limiting and security
  - Error handling strategies
  
- **Two-Stage Intake System**
  - First Intake (3 questions, all users)
  - Second Intake (6 questions, Premium+ only)
  - Upgrade prompts and gating
  - Fitness score auto-calculation
  
- **Quota Management System**
  - Tier-based usage limits (messages, video calls)
  - Real-time quota tracking
  - Monthly reset logic
  - Upgrade prompts on limit reached
  
- **Time-Limited Nutrition Access**
  - 7-day trial for Freemium users
  - Expiry banners and locked screen
  - Upgrade flow and re-activation
  
- **Chat Attachments Gating**
  - Premium+ exclusive feature
  - File type validation
  - Upload and storage logic
  - Security considerations
  
- **Additional Features**:
  - Post-Interaction Rating System
  - Injury Substitution Engine
  - Subscription Management
  - Coach Assignment System
  - Progress Tracking System

**Use this** to implement complex business features with provided algorithms.

---

### 5. [Business Logic & Algorithms](./05-BUSINESS-LOGIC.md)
**Purpose**: Core calculations and business rules  
**Audience**: Backend Developers, Data Scientists  
**Contains**:
- **Fitness Score Calculation**
  - Input parameters
  - Scoring algorithm
  - Interpretation levels
  - Coach override logic
  
- **Injury Substitution Engine**
  - Injury rules database
  - Exercise contraindication checking
  - Safe alternative suggestions
  - Real-time substitution flow
  
- **Nutrition Macro Calculation**
  - BMR and TDEE formulas
  - Goal-based calorie adjustment
  - Protein/carb/fat distribution
  - Activity multipliers
  
- **Calorie Burn Estimation**
  - MET (Metabolic Equivalent) values
  - Duration and intensity factors
  - Workout-specific calculations
  
- **Workout Plan Generation**
  - Training split selection
  - Exercise pool filtering
  - Progressive overload application
  
- **Coach Matching Algorithm**
  - Specialty matching
  - Rating and experience weighting
  - Availability scoring
  
- **Progress Tracking Calculations**
  - Weight trend analysis
  - Workout adherence percentage
  - Streak calculations
  
- **Subscription Pricing Logic**
  - Tier pricing
  - Annual discount calculation
  - Proration on upgrades
  
- **Rating Aggregation**
  - Average calculation with recency weighting
  
- **Notification Triggers**
  - Business rules for reminders
  - Daily notification processing

**Use this** to implement accurate calculations matching the original app.

---

## 🎯 Document Usage by Role

### Product Manager / Business Analyst
**Start with**:
1. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - Complete business context
2. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Feature requirements

**Use for**:
- Understanding product vision and goals
- Defining user stories and acceptance criteria
- Planning roadmap and releases

---

### Frontend Developer
**Start with**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - All UI details
2. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - User flow overview

**Use for**:
- Building React/Angular/Vue/Swift/Kotlin UI components
- Implementing navigation and user interactions
- Handling form validations
- Supporting RTL for Arabic language
- Implementing responsive design

**Key Sections**:
- Screen UI components
- User interaction flows
- Navigation flows
- RTL considerations
- Accessibility requirements

---

### Backend Developer
**Start with**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Database schema
2. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Algorithms
3. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - API requirements

**Use for**:
- Setting up PostgreSQL/MySQL/MongoDB database
- Creating REST/GraphQL APIs
- Implementing authentication (OTP flow)
- Building quota management system
- Implementing business logic calculations

**Key Sections**:
- Database schemas and indexes
- API endpoint specifications
- Validation rules
- Security considerations
- Business algorithms

---

### Mobile Developer (iOS/Android)
**Start with**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - Native screen designs
2. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Data structures
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Local calculations

**Use for**:
- Building native iOS (Swift/SwiftUI) or Android (Kotlin/Jetpack Compose) apps
- Implementing offline-first architecture
- Creating local database with Core Data / Room
- Implementing push notifications

---

### QA Engineer / Tester
**Start with**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - Test scenarios
2. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Edge cases

**Use for**:
- Writing test cases
- Creating automated tests (Selenium, Cypress, etc.)
- Validating business logic
- Testing edge cases and error states

**Key Sections**:
- Validation rules
- Edge cases
- Error handling
- Testing strategies

---

### UI/UX Designer
**Start with**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - Screen layouts
2. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - User personas

**Use for**:
- Creating high-fidelity mockups
- Designing user flows
- Ensuring accessibility compliance
- Designing RTL layouts for Arabic

---

### DevOps / System Administrator
**Start with**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Infrastructure needs
2. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - Technical stack

**Use for**:
- Setting up cloud infrastructure (AWS/Azure/GCP)
- Configuring databases (PostgreSQL + replicas)
- Setting up CI/CD pipelines
- Implementing monitoring and logging
- Scaling for 10,000+ concurrent users

---

## 🚀 Quick Start Guides

### For Complete Reimplementation

**Step 1**: Read Executive Summary
```bash
# Understand the business context, features, and technical architecture
cat 01-EXECUTIVE-SUMMARY.md
```

**Step 2**: Set Up Database
```bash
# Use schema definitions from Data Models document
# Create PostgreSQL database
# Run schema migrations from 02-DATA-MODELS.md
```

**Step 3**: Implement Backend APIs
```bash
# Follow API specifications in:
# - 04-FEATURE-SPECIFICATIONS.md (authentication, quota, etc.)
# - 02-DATA-MODELS.md (CRUD endpoints)
# - 05-BUSINESS-LOGIC.md (calculations)
```

**Step 4**: Build Frontend Screens
```bash
# Use screen specifications from:
# 03-SCREEN-SPECIFICATIONS.md
# Implement all 28 screens following exact specifications
```

**Step 5**: Implement Business Logic
```bash
# Copy algorithms from:
# 05-BUSINESS-LOGIC.md
# Implement in your chosen language
```

**Step 6**: Test & Deploy
```bash
# Use edge cases and validation rules from all documents
# Set up staging environment
# Deploy to production
```

---

### For Migration to Specific Platforms

#### **Migrating to React Native (Mobile)**

**Reference Documents**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - Adapt web screens to native components
2. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Use AsyncStorage or Realm for local data
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Port calculations to JavaScript/TypeScript

**Key Considerations**:
- Replace web components with React Native equivalents (View, Text, TouchableOpacity)
- Implement navigation with React Navigation
- Use react-native-otp-input for OTP screen
- Implement push notifications with Firebase Cloud Messaging
- Handle offline mode with Redux Persist

---

#### **Migrating to Flutter**

**Reference Documents**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Convert TypeScript interfaces to Dart classes
2. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - Build with Flutter widgets
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Port to Dart language

**Key Considerations**:
- Use Provider or Riverpod for state management
- Implement sqflite for local database
- Use flutter_sms_autofill for OTP auto-fill
- Handle RTL with Directionality widget
- Use GetX or GoRouter for navigation

---

#### **Migrating to Django (Backend)**

**Reference Documents**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Create Django models from schema
2. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Build Django REST Framework APIs
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Implement in Python

**Key Considerations**:
- Use Django ORM to create models
- Build REST APIs with Django REST Framework
- Implement phone OTP with Twilio SDK
- Use Celery for scheduled tasks (quota resets)
- Use Django Channels for real-time messaging

---

#### **Migrating to Spring Boot (Java)**

**Reference Documents**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Create JPA entities
2. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Build REST controllers
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Implement in Java

**Key Considerations**:
- Use Spring Data JPA for database
- Build REST APIs with Spring MVC
- Implement authentication with Spring Security
- Use Spring Scheduler for cron jobs
- Use WebSocket for real-time features

---

## 📊 Data Model Summary

**Total Tables**: 20+

**Core Entities**:
- users (1)
- coaches (1)
- otp_sessions (1)
- quota_usage (1)
- exercises (1)
- workout_plans (1)
- workouts (1)
- workout_exercises (1)
- nutrition_plans (1)
- meals (1)
- food_items (1)
- meal_food_items (junction, 1)
- conversations (1)
- messages (1)
- video_calls (1)
- coach_ratings (1)
- trainer_ratings (1)
- products (1)
- orders (1)
- order_items (1)
- weight_entries (1)
- inbody_scans (1)
- audit_logs (1)
- system_settings (1)

**Total**: 24 tables

---

## 🌍 Internationalization (i18n)

**Languages Supported**:
- English (en) - LTR (Left-to-Right)
- Arabic (ar) - RTL (Right-to-Left)

**Translation Keys**: 2,904 keys covering all UI elements

**Implementation**:
- Context-based translation system (LanguageContext in React)
- Separate translation files for code-splitting
- Dynamic text direction switching
- Locale-specific date/number formatting
- Cultural considerations (Saudi phone format, etc.)

**Migration Note**: Export translation JSON from `/components/translations-data.ts` and import into your i18n solution (i18next, vue-i18n, etc.)

---

## 🔐 Security Considerations

**Authentication**:
- Phone OTP (no passwords)
- JWT tokens for session management
- OTP hashed before storage (bcrypt)
- Rate limiting (3 OTP per hour per phone)

**Data Protection**:
- Minimal PII collection
- No medical data storage
- File uploads scanned for malware
- Signed URLs for file access
- HTTPS only in production

**Access Control**:
- Role-based access (User, Coach, Admin)
- Tier-based feature gating
- Database row-level security (planned)

---

## 📈 Performance Requirements

**Response Times**:
- Initial load: < 3 seconds (4G)
- Screen transitions: < 300ms
- API responses: < 1 second (95th percentile)

**Scalability**:
- Support 10,000+ concurrent users
- Handle 1M+ exercises logged per month
- Process 100,000+ messages per day

**Reliability**:
- 99.5% uptime target
- Graceful degradation on API failures
- Offline-first for workout timer

---

## 🧪 Testing Requirements

**Unit Tests**:
- All business logic functions
- Data validation functions
- Calculation algorithms

**Integration Tests**:
- Complete user flows (onboarding, workout, nutrition)
- Payment processing
- Quota enforcement
- Rating system

**E2E Tests**:
- Critical user journeys
- Cross-browser compatibility
- Mobile responsiveness

**Load Tests**:
- Concurrent user simulation
- Database query performance
- API endpoint stress testing

---

## 📦 Technology Stack (Original Implementation)

**Frontend**:
- React 18 + TypeScript
- Tailwind CSS v4
- Vite 5 (build tool)
- Lucide React (icons)
- Recharts (charts)
- Sonner (toasts)

**Backend** (Production Ready):
- Node.js + Express (recommended)
- PostgreSQL (primary database)
- Redis (caching, sessions)
- AWS S3 (file storage)
- Twilio (SMS OTP)

**DevOps**:
- Docker containers
- Kubernetes orchestration
- GitHub Actions (CI/CD)
- Sentry (error tracking)
- Mixpanel (analytics)

---

## 🔄 Migration Checklist

When migrating to a new platform, follow this checklist:

### Phase 1: Foundation (Week 1-2)
- [ ] Set up project structure
- [ ] Configure database (PostgreSQL/MySQL/MongoDB)
- [ ] Implement data models from Document 2
- [ ] Set up authentication (OTP flow)
- [ ] Create basic REST/GraphQL APIs

### Phase 2: Core Features (Week 3-6)
- [ ] Implement intake system (first + second)
- [ ] Build quota management system
- [ ] Create workout module (plans, exercises, timer)
- [ ] Build nutrition module (plans, meals, macros)
- [ ] Implement messaging system

### Phase 3: Advanced Features (Week 7-10)
- [ ] Injury substitution engine
- [ ] Time-limited nutrition access
- [ ] Chat attachments gating
- [ ] Rating system (coach + trainer)
- [ ] Progress tracking (weight, InBody, adherence)

### Phase 4: Business Tools (Week 11-12)
- [ ] Coach dashboard and tools
- [ ] Admin dashboard (8 screens)
- [ ] E-commerce module (products, orders)
- [ ] Payment integration (Stripe/Paddle)
- [ ] Earnings and payout system

### Phase 5: Polish & Launch (Week 13-14)
- [ ] Implement all 2,904 translation keys
- [ ] Test RTL layout for Arabic
- [ ] Performance optimization
- [ ] Security audit
- [ ] Load testing
- [ ] Beta testing with real users
- [ ] Production deployment

**Estimated Timeline**: 14 weeks (3.5 months) with 2-3 full-time developers

---

## 📞 Support & Maintenance

**Known Issues**:
- None currently (WebAssembly error resolved in v2.0)

**Future Enhancements**:
- Push notifications
- Social features (friend challenges, leaderboards)
- Wearable device integration (Apple Health, Google Fit)
- AI-powered workout generation
- Voice-guided workout sessions

---

## 📄 License

All documentation is proprietary to FitCoach+. For licensing inquiries, contact the FitCoach Team.

---

## 🙏 Acknowledgments

- Built with Figma Make - AI-powered web application builder
- Special thanks to the development team for implementing v2.0 features
- Community feedback incorporated throughout the design process

---

**Last Updated**: December 8, 2024  
**Document Version**: 2.0.0  
**Status**: ✅ Complete & Production Ready

---

## 📧 Contact

For questions about this documentation:
- Technical Lead: [Your Email]
- Product Owner: [Your Email]

For implementation support:
- Create an issue in the project repository
- Refer to specific document sections
- Include relevant code snippets

---

**End of Documentation Index**

*Begin your migration journey with [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md)*
