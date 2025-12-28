# عاش (FitCoach+ v2.0) - Complete Documentation Index

## Overview
This is the comprehensive documentation package for the عاش (FitCoach+ v2.0) fitness coaching platform. The documentation is organized by Software Development Life Cycle (SDLC) phases, providing complete coverage from customer requirements through code implementation.

**Total Documentation**: 130,000+ words across all documents  
**Version**: 2.0.0  
**Last Updated**: December 2024  
**Status**: Production Ready

---

## Documentation Structure

```
/docs/
├── 1-customer-requirements/     ← WHAT users need
├── 2-software-requirements/     ← WHAT system must do
├── 3-software-architecture/     ← HOW system is structured
├── 4-code-documentation/        ← HOW it's implemented
├── reference/                   ← Quick reference materials
├── archive/                     ← Historical development notes
└── [legacy comprehensive docs]  ← 50,000+ words of detailed specs
```

---

## Phase 1: Customer Requirements

**Purpose**: Define user needs, experiences, and business value propositions

### Documents

📄 **[1-customer-requirements/README.md](./1-customer-requirements/README.md)**  
Overview of customer requirements organization

📄 **[1-customer-requirements/end-user-requirements.md](./1-customer-requirements/end-user-requirements.md)** *(~15,000 words)*  
Complete requirements for fitness enthusiasts including:
- User personas (Ahmed, Fatimah, Khalid)
- Screen-by-screen requirements (12 screens)
- Feature requirements by subscription tier
- User journeys and scenarios
- Acceptance criteria
- Success metrics

📄 **[1-customer-requirements/coach-requirements.md](./1-customer-requirements/coach-requirements.md)** *(~8,000 words)*  
Requirements for fitness coaches including:
- Coach personas
- Coaching tool requirements (6 screens)
- Client management features
- Plan creation workflows
- Performance metrics

📄 **[1-customer-requirements/admin-requirements.md](./1-customer-requirements/admin-requirements.md)** *(~10,000 words)*  
Platform administrator requirements including:
- Admin dashboard (8 screens)
- User and coach management
- System configuration
- Analytics and reporting
- Audit and compliance

**Quick Start**: Begin with `end-user-requirements.md` to understand primary user needs.

---

## Phase 2: Software Requirements

**Purpose**: Translate customer needs into technical specifications

### Documents

📄 **[2-software-requirements/README.md](./2-software-requirements/README.md)**  
Overview of software requirements organization

📄 **[2-software-requirements/functional-requirements.md](./2-software-requirements/functional-requirements.md)**  
Functional requirements document

📄 **[2-software-requirements/non-functional-requirements.md](./2-software-requirements/non-functional-requirements.md)**  
Non-functional requirements document

### Comprehensive Existing Documentation (50,000+ words)

📄 **[2-software-requirements/data-models.md](./2-software-requirements/data-models.md)** *(~8,000 words)*  
Complete database schema and type definitions:
- User profiles and authentication
- Subscription and quota models
- Workout and exercise structures
- Nutrition and meal planning data
- Coach and admin data models
- Audit and analytics schemas

📄 **[2-software-requirements/feature-specifications.md](./2-software-requirements/feature-specifications.md)** *(~12,000 words)*  
Deep dive into v2.0 features:
- Phone OTP authentication system
- Two-stage intake system
- Quota management (messages/calls)
- Time-limited nutrition access
- Chat attachment gating
- Post-interaction rating system
- Injury substitution engine

📄 **[2-software-requirements/business-logic.md](./2-software-requirements/business-logic.md)** *(~10,000 words)*  
Core algorithms and business rules:
- Fitness score calculation
- Injury detection and substitution logic
- Quota enforcement algorithms
- Nutrition expiry management
- Subscription tier logic
- Coach assignment rules

📄 **[2-software-requirements/api-specifications.md](./2-software-requirements/api-specifications.md)** *(~7,000 words)*  
API endpoints and contracts:
- Authentication endpoints (OTP)
- User management APIs
- Workout and nutrition APIs
- Messaging and video call APIs
- Admin management APIs
- Webhook specifications

**Quick Start**: Read `feature-specifications.md` for v2.0 upgrade features.

---

## Phase 3: Software Architecture

**Purpose**: Define system structure, design patterns, and technology choices

### Documents

📄 **[3-software-architecture/README.md](./3-software-architecture/README.md)**  
Overview of architectural documentation including:
- System context diagrams
- Component architecture
- Technology stack (React, TypeScript, Tailwind, Supabase)
- Design patterns (Composition, Context, Type Safety)
- Architectural decision records (ADRs)
- Scalability considerations

📄 **[3-software-architecture/system-architecture.md](./3-software-architecture/system-architecture.md)**  
System architecture documentation

### Comprehensive Existing Documentation

📄 **[3-software-architecture/executive-summary.md](./3-software-architecture/executive-summary.md)** *(~5,000 words)*  
High-level project overview:
- Project vision and goals
- Business model and revenue streams
- Core value propositions
- Technical architecture overview
- 28 screen inventory
- Non-functional requirements
- Development roadmap

📄 **[3-software-architecture/screen-specifications.md](./3-software-architecture/screen-specifications.md)** *(~15,000 words)*  
Detailed UI/UX specifications:
- All 28 screens documented
- UI components and layouts
- User interactions and flows
- Validation and error handling
- RTL considerations
- Accessibility requirements

**Quick Start**: Read `executive-summary.md` for complete project overview.

---

## Phase 4: Code Documentation

**Purpose**: Explain implementation details and guide developers

### Documents

📄 **[4-code-documentation/README.md](./4-code-documentation/README.md)**  
Overview of code documentation including:
- Codebase structure
- Component organization (28 screens)
- Utility functions documentation
- Type definitions
- Development guidelines
- Code patterns and best practices

📄 **[4-code-documentation/component-reference.md](./4-code-documentation/component-reference.md)** *(~20,000 words)*  
Complete component documentation:
- All 28 screens with implementation details
- Reusable UI components
- Props, state, and context usage
- Component dependencies and relationships

📄 **[4-code-documentation/utilities-reference.md](./4-code-documentation/utilities-reference.md)** *(~18,000 words)*  
Utility functions and business logic:
- Injury substitution engine (`injuryRules.ts`)
- Quota enforcement system (`quotaEnforcement.ts`)
- Nutrition expiry logic (`nutritionExpiry.ts`)
- Phone validation (`phoneValidation.ts`)
- Type definitions (IntakeTypes, QuotaTypes, InBodyTypes)

📄 **[4-code-documentation/development-guide.md](./4-code-documentation/development-guide.md)** *(~15,000 words)*  
Development workflows and best practices:
- Project setup and configuration
- Development patterns and conventions
- Testing strategies
- Deployment procedures
- Troubleshooting guide

**Quick Start**: Read `4-code-documentation/README.md` for implementation overview.

---

## Reference Materials

**Purpose**: Quick reference guides and supplementary documentation

### Documents

📄 **[reference/README.md](./reference/README.md)**  
Overview of reference materials

📄 **[reference/navigation-map.md](./reference/navigation-map.md)**  
Complete visual navigation flow reference:
- User navigation flows (onboarding → main app)
- Coach navigation flows
- Admin navigation flows
- Cross-cutting flows (upgrade, rating, second intake)
- State transitions
- Screen inventory (35 total screens)
- Deep linking patterns
- Navigation guard rules

📄 **[image-assets-catalog.md](./image-assets-catalog.md)** *(~8,000 words)*  
Complete catalog of all visual assets including:
- 150+ image assets with download links
- Branding and logo files
- Splash and onboarding images
- Welcome screen hero images
- Workout exercise demonstrations (50+ exercises)
- Nutrition meal photos (30+ meals)
- Store product images (40+ products)
- Coach profile images
- UI icons and illustrations
- Empty states and badges
- Image optimization guidelines
- Bulk download links (Unsplash, Pexels, Shutterstock)

### Quick Reference Guides

📄 **[reference/quick-start.md](./reference/quick-start.md)**  
Fast 5-minute orientation guide for new team members

📄 **[QUICKSTART.md](../QUICKSTART.md)**  
Alternative quick start (root level)

---

## Documentation By Use Case

### I'm a Product Manager
**Start here**:
1. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - Project overview
2. [end-user-requirements.md](./1-customer-requirements/end-user-requirements.md) - User needs
3. [coach-requirements.md](./1-customer-requirements/coach-requirements.md) - Coach needs
4. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Feature details

### I'm a UX Designer
**Start here**:
1. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - All 28 screens
2. [end-user-requirements.md](./1-customer-requirements/end-user-requirements.md) - User journeys
3. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - Design principles

### I'm a Backend Developer
**Start here**:
1. [02-DATA-MODELS.md](./02-DATA-MODELS.md) - Database schema
2. [06-API-SPECIFICATIONS.md](./06-API-SPECIFICATIONS.md) - API contracts
3. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Business rules
4. [3-software-architecture/README.md](./3-software-architecture/README.md) - Architecture

### I'm a Frontend Developer
**Start here**:
1. [4-code-documentation/README.md](./4-code-documentation/README.md) - Code guide
2. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - UI specs
3. [00-QUICK-START.md](./00-QUICK-START.md) - Setup instructions
4. [3-software-architecture/README.md](./3-software-architecture/README.md) - Component architecture

### I'm a QA Engineer
**Start here**:
1. [end-user-requirements.md](./1-customer-requirements/end-user-requirements.md) - Acceptance criteria
2. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Feature specs
3. [03-SCREEN-SPECIFICATIONS.md](./03-SCREEN-SPECIFICATIONS.md) - UI requirements
4. [05-BUSINESS-LOGIC.md](./05-BUSINESS-LOGIC.md) - Business rules to test

### I'm a DevOps Engineer
**Start here**:
1. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - System requirements
2. [3-software-architecture/README.md](./3-software-architecture/README.md) - Infrastructure needs
3. [06-API-SPECIFICATIONS.md](./06-API-SPECIFICATIONS.md) - External integrations

### I'm a Business Analyst
**Start here**:
1. [01-EXECUTIVE-SUMMARY.md](./01-EXECUTIVE-SUMMARY.md) - Business model
2. [admin-requirements.md](./1-customer-requirements/admin-requirements.md) - Analytics needs
3. [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md) - Feature ROI

---

## Key Features Documented

### v2.0 Major Upgrades

✅ **Phone OTP Authentication**
- Saudi phone number verification (+966 5X XXX XXXX)
- 6-digit SMS codes with expiry
- Passwordless security
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#1-phone-otp-authentication-system)

✅ **Two-Stage Intake System**
- First Intake: 3 questions (all users)
- Second Intake: 6 questions (Premium+ only)
- Progressive onboarding with gating
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#2-two-stage-intake-system)

✅ **Quota Management**
- Tier-based message limits (Freemium: 20, Premium: 200, Smart: Unlimited)
- Video call quotas (1, 2, 4 calls/month)
- Visual progress bars and warnings
- Hard enforcement with upgrade prompts
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#3-quota-management-system)

✅ **Time-Limited Nutrition Access**
- Freemium: 7-day trial from first generation
- Premium+: Unlimited persistent access
- Countdown banners (3 days, 2 days, 1 day, expired)
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#4-time-limited-nutrition-access)

✅ **Chat Attachment Gating**
- Smart Premium exclusive feature
- Freemium/Premium: Disabled with tooltip
- Smart Premium: Images and PDFs
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#5-chat-attachments-gating)

✅ **Post-Interaction Rating System**
- Appears after video calls
- Every 10 messages
- 1-5 star rating + optional feedback
- Coach performance analytics
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#6-post-interaction-rating-system)

✅ **Injury Substitution Engine**
- 5 injury areas: Shoulder, Knee, Lower Back, Neck, Ankle
- Automatic contraindication detection
- Safe alternative suggestions
- One-click exercise replacement
- Documented in: [04-FEATURE-SPECIFICATIONS.md](./04-FEATURE-SPECIFICATIONS.md#7-injury-substitution-engine)

---

## Application Statistics

- **Total Screens**: 28
  - User Screens: 12
  - Coach Screens: 6
  - Admin Screens: 8
  - Supporting Screens: 2
- **Translation Keys**: 2,904 (Arabic/English)
- **UI Components**: 40+ (Radix UI based)
- **Exercise Database**: 150+ exercises
- **Subscription Tiers**: 3 (Freemium, Premium, Smart Premium)
- **User Types**: 3 (End User, Coach, Administrator)

---

## Technology Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **Styling**: Tailwind CSS v4.0
- **Build Tool**: Vite 5
- **UI Library**: Radix UI primitives
- **Icons**: Lucide React
- **Charts**: Recharts
- **Forms**: React Hook Form v7.55.0
- **Notifications**: Sonner
- **Animations**: Motion/React

### Backend (Future Production)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Twilio/AWS SNS (OTP)
- **Payments**: Stripe or Paddle
- **Video**: Agora or Twilio Video
- **Analytics**: Mixpanel or Amplitude

### Infrastructure
- **Hosting**: Vercel or Netlify (frontend)
- **Database**: Supabase (managed PostgreSQL)
- **CDN**: Cloudflare
- **Monitoring**: Sentry

---

## Document Maintenance

### Ownership by Phase

| Phase | Owner | Review Frequency |
|-------|-------|------------------|
| Customer Requirements | Product Manager | Monthly |
| Software Requirements | Technical Lead | Bi-weekly |
| Software Architecture | Solutions Architect | Quarterly |
| Code Documentation | Dev Team Lead | Weekly |

### Version History

| Version | Date | Major Changes |
|---------|------|---------------|
| 2.0.0 | Dec 2024 | Complete SDLC documentation structure, v2.0 features documented |
| 1.5.0 | Dec 2024 | Added admin screens, comprehensive SRS |
| 1.0.0 | Initial | Initial project documentation |

### Contributing to Documentation

1. **Identify gap or update needed**
2. **Determine correct phase** (1-4 folders)
3. **Create or update markdown file**
4. **Follow existing formatting conventions**
5. **Update this index if adding new docs**
6. **Submit for review by phase owner**

---

## Document Navigation

### Linear Reading Path (Recommended)
```
1. Executive Summary (01-EXECUTIVE-SUMMARY.md)
2. End User Requirements (1-customer-requirements/end-user-requirements.md)
3. Screen Specifications (03-SCREEN-SPECIFICATIONS.md)
4. Feature Specifications (04-FEATURE-SPECIFICATIONS.md)
5. Data Models (02-DATA-MODELS.md)
6. Business Logic (05-BUSINESS-LOGIC.md)
7. API Specifications (06-API-SPECIFICATIONS.md)
8. Architecture Overview (3-software-architecture/README.md)
9. Code Documentation (4-code-documentation/README.md)
```

### Jump to Specific Topics

**Authentication & Onboarding**
- [Phone OTP System](./04-FEATURE-SPECIFICATIONS.md#1-phone-otp-authentication-system)
- [Two-Stage Intake](./04-FEATURE-SPECIFICATIONS.md#2-two-stage-intake-system)
- [Auth Screen Spec](./03-SCREEN-SPECIFICATIONS.md#3-phone-otp-authentication-screen)

**Subscription & Quotas**
- [Quota Management](./04-FEATURE-SPECIFICATIONS.md#3-quota-management-system)
- [Subscription Tiers](./01-EXECUTIVE-SUMMARY.md#14-business-model)
- [Tier Feature Matrix](./1-customer-requirements/end-user-requirements.md#4-subscription-tier-feature-matrix)

**Workout & Nutrition**
- [Injury Engine](./04-FEATURE-SPECIFICATIONS.md#7-injury-substitution-engine)
- [Nutrition Expiry](./04-FEATURE-SPECIFICATIONS.md#4-time-limited-nutrition-access)
- [Workout Screen](./03-SCREEN-SPECIFICATIONS.md#7-workout-screen)
- [Nutrition Screen](./03-SCREEN-SPECIFICATIONS.md#8-nutrition-screen)

**Coaching Features**
- [Coach Requirements](./1-customer-requirements/coach-requirements.md)
- [Messaging System](./04-FEATURE-SPECIFICATIONS.md#chat-messaging)
- [Video Calls](./04-FEATURE-SPECIFICATIONS.md#video-calls)
- [Rating System](./04-FEATURE-SPECIFICATIONS.md#6-post-interaction-rating-system)

**Admin Tools**
- [Admin Requirements](./1-customer-requirements/admin-requirements.md)
- [8 Admin Screens](./03-SCREEN-SPECIFICATIONS.md#admin-dashboard-screens)
- [User Management](./1-customer-requirements/admin-requirements.md#22-user-management-screen)

**Technical Implementation**
- [Data Models](./02-DATA-MODELS.md)
- [Business Logic](./05-BUSINESS-LOGIC.md)
- [API Specs](./06-API-SPECIFICATIONS.md)
- [Code Guide](./4-code-documentation/README.md)

---

## Glossary

### Key Terms

**OTP** - One-Time Password (6-digit SMS code)  
**RTL** - Right-to-Left (Arabic text direction)  
**LTR** - Left-to-Right (English text direction)  
**Freemium** - Free subscription tier with limited features  
**Premium** - Paid tier at $19.99/month  
**Smart Premium** - Top tier at $49.99/month  
**Intake** - Onboarding questionnaire (First = 3Q, Second = 6Q)  
**Quota** - Usage limit (messages, calls) per subscription tier  
**InBody** - Professional body composition analysis  
**MRR** - Monthly Recurring Revenue  
**ARPU** - Average Revenue Per User  
**Churn** - Rate of subscription cancellations

### Injury Areas
- **Shoulder** - Rotator cuff, deltoid issues
- **Knee** - Patella, ligament problems
- **Lower Back** - Lumbar spine issues
- **Neck** - Cervical spine problems
- **Ankle** - Joint and tendon issues

### Subscription Tier Abbreviations
- **F** - Freemium
- **P** - Premium
- **SP** - Smart Premium

---

## Contact & Support

### Documentation Issues
- **Typos/Errors**: Create issue in repository
- **Missing Information**: Contact phase owner
- **Clarifications**: Check existing comprehensive docs first

### Phase Owners (Example)
- **Customer Requirements**: product@fitcoachplus.com
- **Software Requirements**: tech-lead@fitcoachplus.com
- **Architecture**: architect@fitcoachplus.com
- **Code Documentation**: dev-lead@fitcoachplus.com

---

## Quick Links

- 📚 [Customer Requirements Overview](./1-customer-requirements/README.md)
- 🔧 [Software Requirements Overview](./2-software-requirements/README.md)
- 🏗️ [Software Architecture Overview](./3-software-architecture/README.md)
- 💻 [Code Documentation Overview](./4-code-documentation/README.md)
- 📄 [Executive Summary](./01-EXECUTIVE-SUMMARY.md)
- 🚀 [Quick Start Guide](./00-QUICK-START.md)

---

**Document Status**: ✅ Complete and Production Ready  
**Total Pages**: 130,000+ words across all documents  
**Last Updated**: December 2024  
**Version**: 2.0.0

---

*This documentation represents a complete Software Development Life Cycle (SDLC) documentation package for a production-ready fitness coaching platform serving users in Saudi Arabia and Arabic-speaking regions.*