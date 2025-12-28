# عاش (FitCoach+ v2.0) 🏋️‍♂️

A comprehensive bilingual fitness application with phone OTP authentication, multi-tier subscriptions, and advanced features for users, coaches, and admins.

---

## 👋 **NEW HERE? → [START HERE](./START_HERE.md)**

**Quick Links:**
- 📖 **[START HERE](./START_HERE.md)** - New developer onboarding
- 📚 **[Documentation Index](./DOCUMENTATION_INDEX.md)** - All documentation
- 📱 **[Mobile Docs](./mobile/docs/README.md)** - Flutter guide
- 🔧 **[Backend Docs](./backend/docs/README.md)** - Backend guide
- ⚛️ **[Web Docs](./docs/README.md)** - React guide

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Open browser to http://localhost:5173
```

**Important**: The app now runs on port **5173** (Vite default) instead of 3000.

**First time here?** See [QUICKSTART.md](./QUICKSTART.md) for detailed setup instructions.

## ✅ WebAssembly Error - FIXED

The WebAssembly compilation error has been **completely resolved** by:

1. **Disabling Hot Module Replacement (HMR)** - No more auto-refresh, but stable compilation
2. **Disabling build minification** - Prevents WebAssembly triggers
3. **Removing React.StrictMode** - Reduces double-rendering overhead
4. **Force dependency rebuild** - `npm run dev` now includes `--force` flag

See [QUICKSTART.md](./QUICKSTART.md) for detailed setup instructions.

## 📱 Application Features

### v2.0 Major Upgrade Features

- ✅ **Phone OTP Authentication** - Saudi phone numbers with 6-digit OTP
- ✅ **Two-Stage Intake System** - First intake + detailed second intake
- ✅ **Quota Enforcement** - Messages and video calls limited by tier
- ✅ **Time-Limited Nutrition** - Freemium users get 7-day trial
- ✅ **Gated Chat Attachments** - Premium+ exclusive feature
- ✅ **Post-Interaction Ratings** - Rate coaches and trainer quality
- ✅ **Injury Substitution Engine** - Automatic exercise alternatives

### Core Features

- 🌍 **Bilingual Support** - English & Arabic with full RTL support
- 👤 **Multi-Role System** - User, Coach, Admin dashboards
- 💪 **Workout Management** - Custom plans, timers, exercise library
- 🥗 **Nutrition Tracking** - Meal plans, macros, food logging
- 💬 **Coach Messaging** - Direct communication with quota tracking
- 🎥 **Video Booking** - Schedule virtual training sessions
- 🏪 **E-Commerce Store** - Fitness products and supplements
- 📊 **Progress Tracking** - Weight, InBody measurements, fitness score
- 💳 **Subscription Management** - Freemium/Premium/Smart Premium tiers

## 📊 Application Structure

### Screens (28 Total)

#### User Flow (12 screens)
1. Language Selection
2. App Intro
3. Phone OTP Auth
4. First Intake
5. Second Intake  
6. Home Dashboard
7. Workout
8. Nutrition
9. Coach Messaging
10. Store
11. Account Settings
12. Progress Tracking

#### Coach Tools (6 screens)
1. Coach Dashboard
2. Coach Calendar
3. Coach Messaging
4. Workout Plan Builder
5. Nutrition Plan Builder
6. Coach Earnings

#### Admin Tools (8 screens)
1. Admin Dashboard
2. User Management
3. Coach Management
4. Content Management
5. Order Management
6. Earnings Management
7. Subscription Management
8. System Analytics

#### Additional (2 screens)
1. Exercise Detail
2. Product Detail

## 🏗️ Technical Stack

- **Frontend**: React 18 + TypeScript
- **Styling**: Tailwind CSS v4
- **Icons**: Lucide React
- **Charts**: Recharts
- **Forms**: React Hook Form
- **Notifications**: Sonner
- **Build Tool**: Vite 5

## 📁 Project Structure

```
fitcoach-app/
├── components/           # All React components
│   ├── admin/           # Admin-specific screens
│   ├── ui/              # Reusable UI components
│   ├── LanguageContext.tsx  # i18n (2988 lines!)
│   └── ...              # 50+ component files
├── types/               # TypeScript type definitions
├── styles/              # Global CSS and Tailwind config
├── public/              # Static assets
└── App.tsx              # Main application component
```

## 🎨 Subscription Tiers

### Freemium (Free)
- 5 messages/month
- 0 video calls/month
- 7-day nutrition trial
- Basic workout plans
- No chat attachments

### Premium ($19.99/month)
- 20 messages/month
- 2 video calls/month
- Full nutrition access
- Advanced workouts
- No chat attachments

### Smart Premium ($49.99/month)
- Unlimited messages
- 8 video calls/month
- Full nutrition access
- Personalized plans
- ✅ Chat attachments enabled

## 🌍 Internationalization

Complete bilingual support for:
- English (LTR)
- Arabic (RTL with proper text direction)

2,904 translation keys covering all UI elements.

## 🔧 Development Notes

### No Hot Module Replacement
Due to the large LanguageContext.tsx file (2,988 lines), HMR has been disabled to prevent WebAssembly compilation errors. To see changes:

```bash
# Make your code changes, then:
# Press F5 or Ctrl+R in the browser to refresh
```

### Build for Production

```bash
npm run build
npm run preview
```

### Clean Install

If you encounter any issues:

```bash
npm run clean  # Deletes node_modules, dist, .vite and reinstalls
```

## 📝 Configuration Files

- `vite.config.ts` - HMR disabled, minify disabled, 50MB chunk limit
- `tsconfig.json` - Strict mode disabled for faster compilation
- `package.json` - Dev script includes `--force` flag
- `tailwind.config` - Embedded in `styles/globals.css` (v4)

## 🐛 Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

## 🎯 Demo Mode

The app includes a demo mode for testing without authentication:
- Access via "Try Demo Mode" on auth screen
- Switch between User/Coach/Admin roles
- Test with multiple phone numbers
- All data stored in localStorage

## 📚 Complete Documentation

**Documentation Package**: 130,000+ words across all SDLC phases, ready for development team handoff.

This project includes comprehensive documentation organized by Software Development Life Cycle (SDLC) phases:

### Quick Navigation
- 📖 **[Documentation Index](./docs/INDEX.md)** - Complete documentation overview
- 🚀 **[Quick Start Guide](./docs/00-QUICK-START.md)** - Get oriented in 5 minutes
- 📋 **[Executive Summary](./docs/01-EXECUTIVE-SUMMARY.md)** - Business overview and product vision

### Documentation by Phase

#### Phase 1: Customer Requirements (33,000+ words)
- [End User Requirements](./docs/1-customer-requirements/end-user-requirements.md) - User needs and features
- [Coach Requirements](./docs/1-customer-requirements/coach-requirements.md) - Coaching tools
- [Admin Requirements](./docs/1-customer-requirements/admin-requirements.md) - Platform management

#### Phase 2: Software Requirements (37,000+ words)
- [Functional Requirements](./docs/2-software-requirements/functional-requirements.md) - System behaviors
- [Non-Functional Requirements](./docs/2-software-requirements/non-functional-requirements.md) - Performance, security
- [Data Models](./docs/02-DATA-MODELS.md) - Complete database schema (24 tables)
- [Feature Specifications](./docs/04-FEATURE-SPECIFICATIONS.md) - Deep dive into v2.0 features
- [Business Logic](./docs/05-BUSINESS-LOGIC.md) - Algorithms and calculations
- [API Specifications](./docs/06-API-SPECIFICATIONS.md) - 60+ REST endpoints

#### Phase 3: Software Architecture (15,000+ words)
- [System Architecture](./docs/3-software-architecture/system-architecture.md) - Technical design
- [Screen Specifications](./docs/03-SCREEN-SPECIFICATIONS.md) - All 28 screens documented

#### Phase 4: Code Documentation (53,000+ words)
- [Component Reference](./docs/4-code-documentation/component-reference.md) - All 28 screens + components
- [Utilities Reference](./docs/4-code-documentation/utilities-reference.md) - Helper functions
- [Development Guide](./docs/4-code-documentation/development-guide.md) - Implementation patterns

#### Reference Materials
- [Navigation Map](./docs/reference/navigation-map.md) - Visual flow of all user journeys
- [Image Assets Catalog](./docs/image-assets-catalog.md) - Visual asset reference

### Documentation Highlights
- ✅ **Platform-Agnostic**: Migrate to any language or framework
- ✅ **Complete Data Models**: SQL schemas for all 24 tables
- ✅ **API Documentation**: Every endpoint with request/response examples
- ✅ **Business Logic**: Fitness score, macro calculation, injury substitution algorithms
- ✅ **Screen Specifications**: Pixel-perfect UI requirements for all 28 screens
- ✅ **Code Documentation**: Complete implementation guide with 53,000+ words
- ✅ **Migration Guide**: Step-by-step checklist for reimplementation

**[👉 Start Here: Documentation Index](./docs/INDEX.md)**

---

## 📄 License

MIT License - FitCoach Team

## 🙏 Acknowledgments

Built with Figma Make - AI-powered web application builder.

---

**Version**: 2.0.0  
**Status**: ✅ Production Ready  
**Documentation**: ✅ Complete SRS Package  
**Last Updated**: December 8, 2024