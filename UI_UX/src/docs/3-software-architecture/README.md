# Software Architecture Documentation

## Overview
This folder contains architectural documentation for the عاش (FitCoach+ v2.0) fitness application. These documents describe the high-level structure, design decisions, and technical patterns used in the system.

## Purpose
- Define system architecture and structure
- Document design patterns and principles
- Specify technology stack and tools
- Describe component interactions
- Guide development decisions
- Enable system understanding for new developers

## Document Organization

### 1. **system-architecture.md**
High-level system design including:
- Architectural style (SPA, Client-Server)
- System context diagram
- Container diagram (applications, data stores)
- Deployment architecture
- Infrastructure requirements
- Scalability strategy

### 2. **component-architecture.md**
Frontend component structure:
- Component hierarchy and organization
- Screen components (28 screens)
- Reusable UI components
- Business logic components
- State management architecture
- Component communication patterns

### 3. **data-architecture.md**
Data layer design:
- Data flow diagrams
- State management (React Context, localStorage)
- Caching strategy
- Data synchronization
- Offline-first considerations
- Migration from demo to production

### 4. **technology-stack.md**
Technology choices and justifications:
- Frontend: React 18 + TypeScript
- Styling: Tailwind CSS v4.0
- Build Tool: Vite 5
- UI Library: Radix UI primitives
- State Management: React Hooks
- Internationalization: Custom Context
- Future: Backend (Supabase) and mobile (React Native)

## Key Architectural Principles

### 1. Component-Based Architecture
- **Modularity**: Each screen is a self-contained component
- **Reusability**: Common UI components in `/components/ui/`
- **Composition**: Complex UIs built from simple components
- **Separation of Concerns**: Presentation vs. business logic

### 2. Single Responsibility
- Each component has one clear purpose
- Business logic separated into `/utils/` files
- Type definitions in `/types/` files
- Translations in dedicated files

### 3. Type Safety
- TypeScript for compile-time type checking
- Comprehensive interfaces for all data structures
- Type-safe API calls and state management
- Reduces runtime errors

### 4. Internationalization-First
- All text through translation system
- RTL support built-in from start
- 2,904 translation keys for Arabic/English
- No hardcoded strings in components

### 5. Mobile-First Responsive
- Design starts with mobile viewport
- Progressive enhancement for larger screens
- Touch-friendly interactions (44px+ targets)
- Optimized for 4G connections

### 6. Progressive Enhancement
- Core features work without JavaScript (where possible)
- Graceful degradation on older browsers
- Offline capabilities for critical features (workout timer)

## Architecture Diagrams

### System Context (High-Level)

```
┌─────────────────────────────────────────────────────────┐
│                      عاش Platform                        │
│                  (FitCoach+ v2.0)                        │
└─────────────────────────────────────────────────────────┘
         ↓                    ↓                    ↓
    End Users            Coaches             Administrators
    (Mobile Web)      (Mobile Web)           (Desktop Web)
         ↓                    ↓                    ↓
┌─────────────────────────────────────────────────────────┐
│               React SPA (TypeScript)                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  User    │  │  Coach   │  │  Admin   │              │
│  │ Screens  │  │ Screens  │  │ Screens  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
│                                                          │
│  ┌─────────────────────────────────────────────┐       │
│  │  Business Logic Layer                       │       │
│  │  (Quota, Injury Rules, Validation, etc.)    │       │
│  └─────────────────────────────────────────────┘       │
│                                                          │
│  ┌─────────────────────────────────────────────┐       │
│  │  Data Layer (LocalStorage / Supabase API)   │       │
│  └─────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
         ↓                    ↓                    ↓
   ┌──────────┐      ┌─────────────┐      ┌──────────────┐
   │ Supabase │      │  Twilio/AWS │      │  Stripe/     │
   │ Database │      │  (OTP SMS)  │      │  Paddle      │
   └──────────┘      └─────────────┘      └──────────────┘
```

### Component Architecture (Frontend)

```
/App.tsx (Main Entry Point)
    │
    ├─ LanguageContext (Translation Provider)
    │
    ├─ Authentication Flow
    │   ├─ LanguageSelectionScreen
    │   ├─ AppIntroScreen (Onboarding Carousel)
    │   ├─ AuthScreen (Phone OTP)
    │   └─ IntakeScreens (First + Second)
    │
    ├─ End User Screens (12)
    │   ├─ HomeScreen
    │   ├─ WorkoutScreen
    │   ├─ NutritionScreen
    │   ├─ CoachMessagingScreen
    │   ├─ StoreScreen
    │   ├─ ProgressDetailScreen
    │   └─ AccountScreen
    │
    ├─ Coach Screens (6)
    │   ├─ CoachDashboard
    │   ├─ CoachMessagingScreen
    │   ├─ WorkoutPlanBuilder
    │   ├─ NutritionPlanBuilder
    │   ├─ CoachCalendarScreen
    │   └─ CoachEarningsScreen
    │
    ├─ Admin Screens (8)
    │   ├─ AdminDashboard (Main)
    │   ├─ UserManagementScreen
    │   ├─ CoachManagementScreen
    │   ├─ ContentManagementScreen
    │   ├─ StoreManagementScreen
    │   ├─ SubscriptionManagementScreen
    │   ├─ SystemSettingsScreen
    │   ├─ AnalyticsDashboard
    │   └─ AuditLogsScreen
    │
    ├─ Shared Components
    │   ├─ /components/ui/ (40+ Radix-based components)
    │   ├─ DemoModeIndicator
    │   ├─ QuotaDisplay
    │   ├─ NutritionExpiryBanner
    │   └─ RatingModal
    │
    └─ Utility Modules
        ├─ /utils/injuryRules.ts
        ├─ /utils/nutritionExpiry.ts
        ├─ /utils/phoneValidation.ts
        ├─ /types/*.ts (Type definitions)
        └─ /translations/*.ts (i18n data)
```

## Design Patterns Used

### 1. **Component Composition Pattern**
- Small, focused components combined to build complex UIs
- Example: `HomeScreen` composes `QuotaDisplay`, `WorkoutCard`, `NutritionSummary`

### 2. **Context API Pattern**
- `LanguageContext` provides translations to all components
- Avoids prop drilling for global state
- Clean, declarative access via `useLanguage()` hook

### 3. **Container/Presentation Pattern**
- Container components handle logic and state
- Presentation components receive props and render UI
- Example: `WorkoutScreen` (container) uses `WorkoutTimer` (presentation)

### 4. **Controlled Component Pattern**
- Form inputs managed by React state
- Single source of truth
- Enables validation and dynamic behavior

### 5. **Utility-First CSS (Tailwind)**
- No separate CSS files
- Styles co-located with components
- Responsive utilities (`sm:`, `md:`, `lg:`)
- Dark mode support (`dark:`)

### 6. **Type-Safe Data Layer**
- TypeScript interfaces for all data
- Compile-time checks prevent data shape errors
- Reduces runtime bugs

## Technology Stack

### Frontend Framework
- **React 18** - Component-based UI library
- **TypeScript 5** - Type-safe JavaScript
- **Vite 5** - Fast build tool with HMR

### Styling
- **Tailwind CSS v4.0** - Utility-first CSS framework
- **Radix UI** - Unstyled, accessible component primitives
- **Lucide React** - Icon library (1000+ icons)

### State Management
- **React Hooks** - useState, useEffect, useContext
- **Context API** - Global state (language, user profile)
- **LocalStorage** - Persistent state (demo mode)

### UI Libraries
- **Recharts** - Charts and data visualization
- **Sonner** - Toast notifications
- **React Hook Form** - Form validation
- **Motion/React** - Animations

### Backend (Future)
- **Supabase** - PostgreSQL database, auth, real-time
- **Twilio/AWS SNS** - SMS OTP delivery
- **Stripe/Paddle** - Payment processing
- **Agora/Twilio Video** - Video calls

### Mobile (Future)
- **React Native** - Cross-platform mobile apps
- **Expo** - React Native toolchain

## Scalability Considerations

### Current Scale (v2.0)
- Target: 10,000 concurrent users
- Single-region deployment
- CDN for static assets
- Database: Supabase (managed PostgreSQL)

### Future Scale (v3.0+)
- Multi-region deployment
- Microservices architecture
- Separate video streaming service
- Redis for caching and sessions
- Message queue for async processing
- Horizontal scaling with load balancers

## Security Architecture

### Authentication
- Phone OTP (no passwords)
- JWT tokens for session management
- Token expiry and refresh
- Role-based access control (User, Coach, Admin)

### Data Security
- HTTPS only (TLS 1.3)
- Data encrypted at rest (Supabase)
- Data encrypted in transit
- No PII in URLs or logs
- XSS protection
- CSRF tokens

### API Security
- Rate limiting per user/IP
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- API key management for external services

## Performance Optimization

### Current Optimizations
- **Code Splitting**: Translations in separate chunk
- **Lazy Loading**: Admin screens loaded on-demand
- **Image Optimization**: WebP format, lazy loading
- **Bundle Size**: Vite tree-shaking, minification
- **Caching**: LocalStorage for session data

### Future Optimizations
- Server-side rendering (SSR) for SEO
- Progressive Web App (PWA) with service workers
- Image CDN with automatic resizing
- Database query optimization with indexes
- Redis caching layer

## Migration Path

### Current State: Web SPA
- React web application
- LocalStorage for demo data
- Supabase for production data

### Phase 2: Native Mobile
- React Native apps (iOS/Android)
- Shared business logic with web
- Native features (push notifications, camera)

### Phase 3: Microservices
- Separate services:
  - User service
  - Coach service
  - Workout service
  - Nutrition service
  - Payment service
  - Video service
- API Gateway
- Service mesh

## Architectural Decision Records (ADRs)

### ADR-001: React vs Vue vs Angular
- **Decision**: React
- **Rationale**: Largest ecosystem, best TypeScript support, team expertise
- **Consequences**: Need to manage state (no built-in like Vue), more boilerplate than Angular

### ADR-002: Tailwind vs CSS Modules
- **Decision**: Tailwind CSS
- **Rationale**: Faster development, consistency, no CSS file management
- **Consequences**: Learning curve, verbose HTML, requires build step

### ADR-003: Supabase vs Firebase vs Custom Backend
- **Decision**: Supabase
- **Rationale**: PostgreSQL (relational), open-source, generous free tier, SQL familiarity
- **Consequences**: Less mature than Firebase, some advanced features limited

### ADR-004: Monorepo vs Separate Repos
- **Decision**: Single repository (monorepo)
- **Rationale**: Easier to manage, shared code, atomic commits, simpler CI/CD
- **Consequences**: Larger repo size, need discipline in organization

### ADR-005: Type System (TypeScript vs PropTypes)
- **Decision**: TypeScript
- **Rationale**: Compile-time checks, better IDE support, industry standard
- **Consequences**: Steeper learning curve, more verbose code, build step required

## Document Maintenance

- **Owner**: Solutions Architect
- **Review Frequency**: Quarterly or on major architectural changes
- **Last Updated**: December 2024 (v2.0)
- **Status**: Production Ready

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 2.0.0 | Dec 2024 | Full architecture documentation for v2.0 | Architecture Team |
| 1.0.0 | Initial | Initial architecture design | Architecture Team |

---

**Next**: Explore `system-architecture.md` for detailed system design, or `component-architecture.md` for frontend structure.
