# Architecture Migration Guide
## عاش (FitCoach+) v2.0 - System Architecture for Flutter + Node.js

## Document Information
- **Document**: Architecture Migration Guide
- **Version**: 1.0.0
- **Last Updated**: December 21, 2024
- **Purpose**: Complete system architecture for mobile migration
- **Audience**: Solution Architects, Senior Developers, DevOps Engineers

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Technology Stack](#2-technology-stack)
3. [System Components](#3-system-components)
4. [Data Flow Architecture](#4-data-flow-architecture)
5. [Security Architecture](#5-security-architecture)
6. [Infrastructure Architecture](#6-infrastructure-architecture)
7. [Migration Strategy](#7-migration-strategy)
8. [Deployment Architecture](#8-deployment-architecture)

---

## 1. Architecture Overview

### 1.1 High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────┐            │
│  │   iOS App        │         │   Android App    │            │
│  │   (Flutter)      │         │   (Flutter)      │            │
│  │                  │         │                  │            │
│  │  • Provider      │         │  • Provider      │            │
│  │  • Riverpod      │         │  • Riverpod      │            │
│  │  • GoRouter      │         │  • GoRouter      │            │
│  │  • Hive (local)  │         │  • Hive (local)  │            │
│  │  • Socket.IO     │         │  • Socket.IO     │            │
│  └────────┬─────────┘         └────────┬─────────┘            │
│           │                            │                       │
└───────────┼────────────────────────────┼───────────────────────┘
            │                            │
            │     HTTPS (REST APIs)      │
            │     WSS (WebSocket)        │
            │                            │
┌───────────┼────────────────────────────┼───────────────────────┐
│           │        API GATEWAY         │                       │
├───────────┴────────────────────────────┴───────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              Load Balancer (ALB/NLB)                    │  │
│  │              • SSL Termination                          │  │
│  │              • Rate Limiting                            │  │
│  │              • DDoS Protection (Cloudflare)             │  │
│  └────────────────────────┬────────────────────────────────┘  │
│                           │                                    │
└───────────────────────────┼────────────────────────────────────┘
                            │
┌───────────────────────────┼────────────────────────────────────┐
│                  APPLICATION LAYER                             │
├───────────────────────────┴────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────┐  ┌────────────────────┐               │
│  │  Node.js API       │  │  Socket.IO Server  │               │
│  │  Server (Express)  │  │  (Real-time)       │               │
│  │                    │  │                    │               │
│  │  • REST APIs       │  │  • Chat Messages   │               │
│  │  • Authentication  │  │  • Live Updates    │               │
│  │  • Business Logic  │  │  • Notifications   │               │
│  │  • Prisma ORM      │  │  • Presence        │               │
│  └──────┬─────────────┘  └─────────┬──────────┘               │
│         │                          │                           │
│         │         ┌────────────────┼──────────┐                │
│         │         │                │          │                │
│  ┌──────┴─────┐  ┌┴──────────┐  ┌─┴────────┐ │               │
│  │ Auth       │  │ Workout   │  │ Message  │ │               │
│  │ Service    │  │ Service   │  │ Service  │ │               │
│  └────────────┘  └───────────┘  └──────────┘ │               │
│                                               │               │
│  ┌────────────┐  ┌───────────┐  ┌──────────┐ │               │
│  │ Nutrition  │  │ Store     │  │ Quota    │ │               │
│  │ Service    │  │ Service   │  │ Service  │ │               │
│  └────────────┘  └───────────┘  └──────────┘ │               │
│                                               │               │
└───────────────────────────────────────────────┼───────────────┘
                                                │
┌───────────────────────────────────────────────┼───────────────┐
│                    DATA LAYER                 │               │
├───────────────────────────────────────────────┴───────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  PostgreSQL     │  │   Redis      │  │   AWS S3 /      │  │
│  │  (Primary DB)   │  │   (Cache)    │  │   Cloudinary    │  │
│  │                 │  │              │  │   (Storage)     │  │
│  │  • Users        │  │  • Sessions  │  │                 │  │
│  │  • Workouts     │  │  • Quotas    │  │  • Images       │  │
│  │  • Nutrition    │  │  • OTP Codes │  │  • Videos       │  │
│  │  • Messages     │  │  • Rate Limit│  │  • Attachments  │  │
│  │  • Subscriptions│  │  • Job Queue │  │  • Exports      │  │
│  └─────────────────┘  └──────────────┘  └─────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌─────────────┐ │
│  │  Twilio  │  │ Firebase │  │  SendGrid  │  │  Stripe /   │ │
│  │  (SMS)   │  │  (FCM)   │  │  (Email)   │  │  Payment    │ │
│  └──────────┘  └──────────┘  └────────────┘  └─────────────┘ │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐                   │
│  │  Sentry  │  │ DataDog  │  │  Google    │                   │
│  │  (Errors)│  │  (APM)   │  │  Analytics │                   │
│  └──────────┘  └──────────┘  └────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Architecture Principles

#### Scalability
- **Horizontal Scaling**: Multiple API server instances behind load balancer
- **Database Sharding**: User data can be sharded by region/tier
- **Caching Strategy**: Redis for session, quota, and frequently accessed data
- **CDN**: Static assets served via CloudFront/Cloudflare

#### Reliability
- **High Availability**: Multi-AZ deployment for database and API servers
- **Failover**: Automatic failover for database with read replicas
- **Circuit Breakers**: Prevent cascade failures in microservices
- **Health Checks**: Continuous monitoring with auto-recovery

#### Security
- **Defense in Depth**: Multiple security layers (WAF, rate limiting, encryption)
- **Zero Trust**: JWT-based authentication, no trust between services
- **Data Encryption**: At-rest (database) and in-transit (TLS 1.3)
- **Secrets Management**: AWS Secrets Manager / HashiCorp Vault

#### Maintainability
- **Microservices**: Loosely coupled services for independent deployment
- **API Versioning**: `/api/v1/` endpoints with backward compatibility
- **Documentation**: Auto-generated API docs (OpenAPI/Swagger)
- **Logging**: Structured logging with correlation IDs

---

## 2. Technology Stack

### 2.1 Frontend Stack (Flutter)

```yaml
Framework & Language:
  - Flutter: 3.16.5 (stable channel)
  - Dart: 3.2.3
  - Minimum iOS: 12.0
  - Minimum Android: API 21 (Android 5.0)

State Management:
  - provider: ^6.1.1           # Simple state management
  - flutter_riverpod: ^2.4.9   # Complex state with caching
  - flutter_bloc: ^8.1.3       # Alternative for coach/admin panels

Navigation:
  - go_router: ^13.0.0         # Declarative routing
  - flutter_deep_linking: ^2.0.0

Networking:
  - dio: ^5.4.0                # HTTP client with interceptors
  - retrofit: ^4.0.3           # Type-safe API client generation
  - socket_io_client: ^2.0.3   # Real-time messaging

Local Storage:
  - hive: ^2.2.3               # NoSQL local database
  - hive_flutter: ^1.1.0
  - flutter_secure_storage: ^9.0.0  # Secure credential storage
  - shared_preferences: ^2.2.2      # Simple key-value storage

UI Components:
  - flutter_svg: ^2.0.9        # SVG rendering
  - cached_network_image: ^3.3.0  # Image caching
  - shimmer: ^3.0.0            # Loading placeholders
  - lottie: ^2.7.0             # Animation (JSON)
  - flutter_animate: ^4.3.0    # Declarative animations

Forms & Validation:
  - flutter_form_builder: ^9.1.1
  - form_builder_validators: ^9.1.0

Internationalization:
  - flutter_localizations: SDK
  - intl: ^0.18.1
  - easy_localization: ^3.0.4  # Simplified i18n

Utilities:
  - url_launcher: ^6.2.2       # Open external URLs
  - permission_handler: ^11.1.0 # Runtime permissions
  - image_picker: ^1.0.5       # Camera/gallery access
  - file_picker: ^6.1.1        # File selection
  - path_provider: ^2.1.1      # File system paths

Firebase:
  - firebase_core: ^2.24.2
  - firebase_analytics: ^10.8.0
  - firebase_crashlytics: ^3.4.9
  - firebase_messaging: ^14.7.10  # Push notifications

Testing:
  - flutter_test: SDK
  - mockito: ^5.4.4
  - bloc_test: ^9.1.5
  - integration_test: SDK
```

### 2.2 Backend Stack (Node.js)

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "typescript": "^5.3.3",
    "prisma": "^5.7.1",
    "@prisma/client": "^5.7.1",
    
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1",
    "twilio": "^4.19.3",
    
    "socket.io": "^4.6.1",
    "redis": "^4.6.11",
    "bull": "^4.11.5",
    
    "helmet": "^7.1.0",
    "cors": "^2.8.5",
    "express-rate-limit": "^7.1.5",
    "express-validator": "^7.0.1",
    
    "winston": "^3.11.0",
    "morgan": "^1.10.0",
    
    "aws-sdk": "^2.1514.0",
    "cloudinary": "^1.41.1",
    "multer": "^1.4.5-lts.1",
    
    "node-cron": "^3.0.3",
    "dotenv": "^16.3.1",
    
    "@sentry/node": "^7.91.0",
    "prom-client": "^15.1.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.5",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1"
  }
}
```

### 2.3 Database Stack

```yaml
Primary Database:
  - PostgreSQL: 15.5
  - Extensions:
    - uuid-ossp: UUID generation
    - pg_trgm: Full-text search
    - postgis: Geographic data (future)

ORM:
  - Prisma: 5.7.1
  - Features:
    - Type-safe query builder
    - Migration management
    - Schema validation
    - Query optimization

Cache Layer:
  - Redis: 7.2
  - Use Cases:
    - Session storage (JWT blacklist)
    - OTP code storage (5-min TTL)
    - Quota tracking (real-time)
    - Rate limiting
    - Task queue (Bull)
    - Real-time presence

File Storage:
  - AWS S3 (Primary)
  - Cloudinary (Alternative)
  - Buckets:
    - fitcoach-profile-images
    - fitcoach-exercise-media
    - fitcoach-nutrition-images
    - fitcoach-chat-attachments
    - fitcoach-store-products
```

### 2.4 Infrastructure Stack

```yaml
Cloud Provider: AWS (Primary) / Google Cloud (Alternative)

Compute:
  - Elastic Beanstalk / ECS: API servers
  - Lambda: Serverless functions (image processing, scheduled tasks)
  - Auto Scaling: 2-10 instances based on CPU/memory

Database:
  - RDS PostgreSQL: Multi-AZ with read replicas
  - ElastiCache Redis: Cluster mode enabled

Load Balancing:
  - Application Load Balancer (ALB)
  - Network Load Balancer (NLB) for WebSocket

CDN & DNS:
  - CloudFront: Static assets
  - Route 53: DNS management
  - Cloudflare: DDoS protection

Monitoring:
  - CloudWatch: AWS resource monitoring
  - DataDog: Application Performance Monitoring
  - Sentry: Error tracking
  - Firebase Analytics: Mobile analytics

CI/CD:
  - GitHub Actions: Automated testing and deployment
  - Docker: Containerization
  - AWS ECR: Container registry

Security:
  - WAF: Web Application Firewall
  - Secrets Manager: API keys and credentials
  - Certificate Manager: SSL/TLS certificates
  - IAM: Identity and access management
```

---

## 3. System Components

### 3.1 Mobile Application (Flutter)

#### Directory Structure
```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget with providers
│
├── core/
│   ├── config/
│   │   ├── app_config.dart      # Environment config
│   │   ├── api_config.dart      # API endpoints
│   │   └── theme_config.dart    # Theme configuration
│   ├── constants/
│   │   ├── app_constants.dart   # App-wide constants
│   │   ├── api_constants.dart   # API paths
│   │   └── asset_constants.dart # Asset paths
│   ├── utils/
│   │   ├── validators.dart      # Input validation
│   │   ├── formatters.dart      # Data formatting
│   │   ├── extensions.dart      # Dart extensions
│   │   └── logger.dart          # Logging utility
│   ├── network/
│   │   ├── dio_client.dart      # HTTP client setup
│   │   ├── interceptors/        # Request/response interceptors
│   │   └── socket_client.dart   # Socket.IO client
│   └── errors/
│       ├── exceptions.dart      # Custom exceptions
│       └── error_handler.dart   # Global error handling
│
├── data/
│   ├── models/
│   │   ├── user/
│   │   │   ├── user_profile.dart
│   │   │   ├── subscription.dart
│   │   │   └── quota.dart
│   │   ├── workout/
│   │   │   ├── workout_plan.dart
│   │   │   ├── exercise.dart
│   │   │   └── workout_session.dart
│   │   ├── nutrition/
│   │   │   ├── nutrition_plan.dart
│   │   │   ├── meal.dart
│   │   │   └── food_item.dart
│   │   ├── messaging/
│   │   │   ├── message.dart
│   │   │   └── conversation.dart
│   │   └── store/
│   │       ├── product.dart
│   │       └── order.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── workout_repository.dart
│   │   ├── nutrition_repository.dart
│   │   ├── messaging_repository.dart
│   │   └── store_repository.dart
│   ├── local/
│   │   ├── hive_service.dart    # Local database
│   │   ├── secure_storage.dart  # Secure credentials
│   │   └── cache_service.dart   # Cache management
│   └── remote/
│       ├── api_service.dart     # API client interface
│       └── socket_service.dart  # Real-time service
│
├── domain/
│   ├── entities/                # Business entities
│   ├── usecases/                # Business use cases
│   └── repositories/            # Repository interfaces
│
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── language_selection_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── otp_auth_screen.dart
│   │   ├── intake/
│   │   │   ├── first_intake_screen.dart
│   │   │   └── second_intake_screen.dart
│   │   ├── home/
│   │   │   └── home_dashboard_screen.dart
│   │   ├── workout/
│   │   │   ├── workout_screen.dart
│   │   │   └── exercise_detail_screen.dart
│   │   ├── nutrition/
│   │   │   └── nutrition_screen.dart
│   │   ├── messaging/
│   │   │   └── coach_messaging_screen.dart
│   │   ├── store/
│   │   │   └── store_screen.dart
│   │   ├── account/
│   │   │   └── account_screen.dart
│   │   ├── coach/
│   │   │   ├── coach_dashboard.dart
│   │   │   ├── coach_calendar.dart
│   │   │   └── plan_builders/
│   │   └── admin/
│   │       └── admin_dashboard.dart
│   ├── widgets/
│   │   ├── common/              # Reusable widgets
│   │   ├── workout/             # Workout-specific widgets
│   │   ├── nutrition/           # Nutrition-specific widgets
│   │   └── charts/              # Chart components
│   └── providers/
│       ├── auth_provider.dart
│       ├── user_provider.dart
│       ├── workout_provider.dart
│       ├── nutrition_provider.dart
│       ├── messaging_provider.dart
│       ├── quota_provider.dart
│       └── theme_provider.dart
│
├── l10n/
│   ├── intl_en.arb              # English translations
│   ├── intl_ar.arb              # Arabic translations
│   └── app_localizations.dart   # Generated localization
│
└── generated/                   # Auto-generated files
    ├── assets.dart              # Asset constants
    └── l10n/                    # Localization files
```

#### Key Components

**State Management Strategy**
```dart
// Provider for simple state
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserProfile? _user;
  
  Future<void> login(String phone, String otp) async {
    // Login logic
    notifyListeners();
  }
}

// Riverpod for complex state with caching
final workoutPlanProvider = FutureProvider.autoDispose<WorkoutPlan>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getWorkoutPlan();
});

// BLoC for coach/admin complex flows
class WorkoutPlanBloc extends Bloc<WorkoutPlanEvent, WorkoutPlanState> {
  // Complex state management
}
```

**Navigation Setup**
```dart
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => OTPAuthScreen(),
    ),
    // ... all 28 screens
  ],
  redirect: (context, state) {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    final hasCompletedIntake = context.read<UserProvider>().hasCompletedIntake;
    
    // Navigation guards
    if (!isAuthenticated && state.location != '/auth') {
      return '/auth';
    }
    
    if (isAuthenticated && !hasCompletedIntake) {
      return '/intake/first';
    }
    
    return null;
  },
);
```

### 3.2 Backend API Server (Node.js + Express)

#### Directory Structure
```
src/
├── index.ts                     # Entry point
├── app.ts                       # Express app setup
├── server.ts                    # Server initialization
│
├── config/
│   ├── database.ts              # Prisma client
│   ├── redis.ts                 # Redis client
│   ├── aws.ts                   # AWS SDK config
│   ├── twilio.ts                # Twilio config
│   └── environment.ts           # Environment variables
│
├── middleware/
│   ├── authentication.ts        # JWT verification
│   ├── authorization.ts         # Role-based access
│   ├── validation.ts            # Request validation
│   ├── errorHandler.ts          # Global error handler
│   ├── rateLimiter.ts           # Rate limiting
│   ├── logger.ts                # Request logging
│   └── quota.ts                 # Quota enforcement
│
├── routes/
│   ├── auth.routes.ts           # /api/auth/*
│   ├── user.routes.ts           # /api/users/*
│   ├── workout.routes.ts        # /api/workouts/*
│   ├── nutrition.routes.ts      # /api/nutrition/*
│   ├── messaging.routes.ts      # /api/messages/*
│   ├── subscription.routes.ts   # /api/subscriptions/*
│   ├── coach.routes.ts          # /api/coaches/*
│   ├── admin.routes.ts          # /api/admin/*
│   └── store.routes.ts          # /api/store/*
│
├── controllers/
│   ├── auth.controller.ts
│   ├── user.controller.ts
│   ├── workout.controller.ts
│   ├── nutrition.controller.ts
│   ├── messaging.controller.ts
│   ├── subscription.controller.ts
│   ├── coach.controller.ts
│   ├── admin.controller.ts
│   └── store.controller.ts
│
├── services/
│   ├── auth/
│   │   ├── otp.service.ts       # OTP generation/verification
│   │   ├── jwt.service.ts       # JWT token management
│   │   └── phone.service.ts     # Phone validation
│   ├── user/
│   │   ├── user.service.ts
│   │   ├── profile.service.ts
│   │   └── quota.service.ts
│   ├── workout/
│   │   ├── workout.service.ts
│   │   ├── exercise.service.ts
│   │   └── substitution.service.ts  # Injury substitution
│   ├── nutrition/
│   │   ├── nutrition.service.ts
│   │   ├── meal.service.ts
│   │   └── access.service.ts    # Freemium time limit
│   ├── messaging/
│   │   ├── message.service.ts
│   │   ├── socket.service.ts
│   │   └── notification.service.ts
│   ├── subscription/
│   │   ├── subscription.service.ts
│   │   ├── payment.service.ts
│   │   └── upgrade.service.ts
│   ├── storage/
│   │   ├── s3.service.ts
│   │   └── cloudinary.service.ts
│   ├── notification/
│   │   ├── fcm.service.ts       # Firebase Cloud Messaging
│   │   ├── email.service.ts
│   │   └── sms.service.ts
│   └── analytics/
│       ├── tracking.service.ts
│       └── reporting.service.ts
│
├── models/                      # Prisma generated models
│
├── validators/
│   ├── auth.validator.ts
│   ├── user.validator.ts
│   ├── workout.validator.ts
│   └── message.validator.ts
│
├── utils/
│   ├── logger.ts                # Winston logger
│   ├── errors.ts                # Custom error classes
│   ├── response.ts              # Standard API responses
│   └── helpers.ts               # Utility functions
│
├── jobs/
│   ├── quota-reset.job.ts       # Monthly quota reset
│   ├── nutrition-expiry.job.ts  # Freemium nutrition expiry
│   ├── reminder.job.ts          # Workout reminders
│   └── analytics.job.ts         # Daily analytics
│
├── socket/
│   ├── index.ts                 # Socket.IO setup
│   ├── handlers/
│   │   ├── message.handler.ts
│   │   ├── presence.handler.ts
│   │   └── notification.handler.ts
│   └── middleware/
│       └── socket-auth.ts
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

#### Key Components

**Express App Setup**
```typescript
// app.ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';

const app = express();

// Security
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}));

// Parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(morgan('combined'));

// Rate limiting
app.use(rateLimiter);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', authenticate, userRoutes);
app.use('/api/workouts', authenticate, workoutRoutes);
// ... all routes

// Error handling
app.use(errorHandler);

export default app;
```

**Authentication Middleware**
```typescript
// middleware/authentication.ts
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    role: 'user' | 'coach' | 'admin';
    subscriptionTier: string;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      throw new Error('No token provided');
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    req.user = decoded;
    
    next();
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' });
  }
};
```

**Quota Enforcement Middleware**
```typescript
// middleware/quota.ts
import { redisClient } from '../config/redis';
import { prisma } from '../config/database';

export const enforceMessageQuota = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const userId = req.user!.id;
  const tier = req.user!.subscriptionTier;
  
  // Smart Premium has unlimited messages
  if (tier === 'Smart Premium') {
    return next();
  }
  
  // Get quota limits
  const limits = {
    'Freemium': 20,
    'Premium': 200,
    'Smart Premium': Infinity
  };
  
  const limit = limits[tier];
  
  // Check current usage from Redis
  const key = `quota:messages:${userId}:${getCurrentMonth()}`;
  const current = await redisClient.get(key);
  const usage = parseInt(current || '0');
  
  if (usage >= limit) {
    return res.status(429).json({
      error: 'Message quota exceeded',
      quota: {
        limit,
        used: usage,
        remaining: 0
      },
      upgradePrompt: tier === 'Freemium' ? 'Premium' : 'Smart Premium'
    });
  }
  
  next();
};
```

---

## 4. Data Flow Architecture

### 4.1 Authentication Flow

```
┌──────────┐                                           ┌──────────┐
│  Mobile  │                                           │  Twilio  │
│   App    │                                           │   SMS    │
└────┬─────┘                                           └────▲─────┘
     │                                                      │
     │ 1. Request OTP                                      │
     │    POST /api/auth/request-otp                       │
     │    { phone: "+966512345678" }                       │
     │                                                      │
     ▼                                                      │
┌─────────────────────────────────────────────┐           │
│           Node.js API Server                │           │
│  ┌─────────────────────────────────────┐    │           │
│  │ 1. Validate Saudi phone format      │    │           │
│  │ 2. Generate 6-digit OTP             │    │           │
│  │ 3. Store in Redis (5-min TTL)       │    │           │
│  │ 4. Send SMS via Twilio  ────────────┼────┼───────────┘
│  │ 5. Return success response          │    │
│  └─────────────────────────────────────┘    │
└─────────────────────┬───────────────────────┘
                      │
                      │ 2. Response: { success: true }
                      │
                      ▼
┌─────────────────────────────────────────────┐
│              Mobile App                     │
│  ┌─────────────────────────────────────┐    │
│  │ User enters 6-digit OTP             │    │
│  └─────────────────────────────────────┘    │
└─────────────────────┬───────────────────────┘
                      │
                      │ 3. Verify OTP
                      │    POST /api/auth/verify-otp
                      │    { phone: "+966512345678", otp: "123456" }
                      │
                      ▼
┌─────────────────────────────────────────────┐
│           Node.js API Server                │
│  ┌─────────────────────────────────────┐    │
│  │ 1. Validate OTP from Redis          │    │
│  │ 2. Check user exists in DB          │    │
│  │    - If new: Create user account    │    │
│  │    - If exists: Load profile        │    │
│  │ 3. Generate JWT token               │    │
│  │ 4. Store session in Redis           │    │
│  │ 5. Return token + user profile      │    │
│  └─────────────────────────────────────┘    │
└─────────────────────┬───────────────────────┘
                      │
                      │ 4. Response: { token, user }
                      │
                      ▼
┌─────────────────────────────────────────────┐
│              Mobile App                     │
│  ┌─────────────────────────────────────┐    │
│  │ 1. Store JWT in secure storage      │    │
│  │ 2. Store user profile in Hive       │    │
│  │ 3. Navigate to Home/Intake          │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

### 4.2 Workout Plan Flow

```
┌──────────┐                                    ┌──────────┐
│  Mobile  │                                    │   Coach  │
│   App    │                                    │  Portal  │
└────┬─────┘                                    └────┬─────┘
     │                                               │
     │ 1. Request workout plan                      │
     │    GET /api/workouts/plan                    │
     │    Headers: { Authorization: Bearer JWT }    │
     │                                               │
     ▼                                               │
┌─────────────────────────────────────────────┐     │
│           Node.js API Server                │     │
│  ┌─────────────────────────────────────┐    │     │
│  │ 1. Authenticate JWT                 │    │     │
│  │ 2. Get user ID and profile          │    │     │
│  │ 3. Check if plan exists             │    │     │
│  │    - No plan: Return empty state    │    │     │
│  │    - Has plan: Fetch from DB        │    │     │
│  └─────────────────────────────────────┘    │     │
└─────────────────────┬───────────────────────┘     │
                      │                             │
                      │ 2. Response: { plan }       │
                      │                             │
                      ▼                             │
┌─────────────────────────────────────────────┐     │
│              Mobile App                     │     │
│  ┌─────────────────────────────────────┐    │     │
│  │ 1. Display plan (or empty state)    │    │     │
│  │ 2. User clicks "Get Plan from Coach"│    │     │
│  │ 3. Navigate to Coach screen         │    │     │
│  └─────────────────────────────────────┘    │     │
└─────────────────────┬───────────────────────┘     │
                      │                             │
                      │ 3. Send message to coach    │
                      │    POST /api/messages/send  │
                      │                             │
                      ▼                             ▼
┌───────────────────────────────────────────────────────┐
│              Socket.IO Real-time                      │
│  ┌───────────────────────────────────────────────┐    │
│  │ 1. Message queued and sent via Socket        │    │
│  │ 2. Coach receives notification                │    │
│  │ 3. Coach opens plan builder                   │    │
│  └───────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────┘
                      │                             ▲
                      │                             │
                      │                             │ 4. Coach creates plan
                      │                             │    POST /api/workouts/generate
                      │                             │    { userId, exercises[], ... }
                      │                             │
                      ▼                             │
┌─────────────────────────────────────────────┐     │
│           Node.js API Server                │─────┘
│  ┌─────────────────────────────────────┐    │
│  │ 1. Validate coach authorization     │    │
│  │ 2. Apply injury substitution logic  │    │
│  │ 3. Save plan to database            │    │
│  │ 4. Notify user via Socket.IO        │    │
│  │ 5. Send push notification           │    │
│  └─────────────────────────────────────┘    │
└─────────────────────┬───────────────────────┘
                      │
                      │ 5. Push notification
                      │    "Your workout plan is ready!"
                      │
                      ▼
┌─────────────────────────────────────────────┐
│              Mobile App                     │
│  ┌─────────────────────────────────────┐    │
│  │ 1. Receive push notification        │    │
│  │ 2. Fetch new plan                   │    │
│  │ 3. Cache in Hive                    │    │
│  │ 4. Display to user                  │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

### 4.3 Message Quota Flow

```
┌──────────┐
│  Mobile  │
│   App    │
└────┬─────┘
     │
     │ User types message and hits send
     │ POST /api/messages/send
     │ Headers: { Authorization: Bearer JWT }
     │ Body: { coachId, text, attachment? }
     │
     ▼
┌─────────────────────────────────────────────────────┐
│           Quota Enforcement Middleware              │
│  ┌─────────────────────────────────────────────┐    │
│  │ 1. Extract user ID and subscription tier   │    │
│  │ 2. Check tier limits:                      │    │
│  │    - Freemium: 20/month                    │    │
│  │    - Premium: 200/month                    │    │
│  │    - Smart Premium: Unlimited              │    │
│  │ 3. Query Redis:                            │    │
│  │    Key: "quota:messages:userId:2024-12"    │    │
│  │    Value: current count                    │    │
│  │ 4. If usage >= limit:                      │    │
│  │    - Return 429 (Quota Exceeded)           │    │
│  │    - Suggest upgrade                       │    │
│  │ 5. If within limit: Continue               │    │
│  └─────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────┘
                         │
                         │ Quota OK → Continue
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│           Message Controller                        │
│  ┌─────────────────────────────────────────────┐    │
│  │ 1. Validate message content                │    │
│  │ 2. Check attachment (Premium+ only)        │    │
│  │ 3. Save message to database                │    │
│  │ 4. Increment quota counter in Redis        │    │
│  │ 5. Emit via Socket.IO to coach             │    │
│  │ 6. Send push notification to coach         │    │
│  │ 7. Return success with new quota count     │    │
│  └─────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────┘
                         │
                         │ Response: {
                         │   success: true,
                         │   message,
                         │   quota: {
                         │     used: 5,
                         │     limit: 20,
                         │     remaining: 15,
                         │     resetDate: "2025-01-01"
                         │   }
                         │ }
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              Mobile App                             │
│  ┌─────────────────────────────────────────────┐    │
│  │ 1. Display message in chat                 │    │
│  │ 2. Update quota indicator:                 │    │
│  │    "5/20 messages used this month"         │    │
│  │ 3. Show warning if usage > 80%:            │    │
│  │    "16/20 messages used - Consider upgrade"│    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

## 5. Security Architecture

### 5.1 Security Layers

```
┌─────────────────────────────────────────────────────┐
│              Layer 1: Network Security              │
├─────────────────────────────────────────────────────┤
│ • Cloudflare DDoS Protection                        │
│ • WAF (Web Application Firewall)                    │
│ • Rate limiting at CDN level                        │
│ • TLS 1.3 encryption (in-transit)                   │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────┐
│          Layer 2: Application Security              │
├─────────────────────────────────────────────────────┤
│ • Helmet.js security headers                        │
│ • CORS policy enforcement                           │
│ • Input validation (express-validator)              │
│ • XSS protection                                    │
│ • SQL injection prevention (Prisma ORM)             │
│ • Rate limiting (express-rate-limit)                │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────┐
│          Layer 3: Authentication Security           │
├─────────────────────────────────────────────────────┤
│ • JWT tokens (HS256 algorithm)                      │
│ • Token expiry (15 minutes access, 7 days refresh)  │
│ • Secure token storage (flutter_secure_storage)     │
│ • OTP rate limiting (3 requests/hour/phone)         │
│ • Phone number verification (Twilio)                │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────┐
│          Layer 4: Data Security                     │
├─────────────────────────────────────────────────────┤
│ • Database encryption at rest (AWS RDS)             │
│ • Field-level encryption (sensitive data)           │
│ • Secrets management (AWS Secrets Manager)          │
│ • Regular backups (daily automated)                 │
│ • GDPR compliance (data retention policies)         │
└─────────────────────────────────────────────────────┘
```

### 5.2 JWT Token Structure

```typescript
// Access Token (15-minute expiry)
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-uuid-here",           // User ID
    "role": "user",                    // user | coach | admin
    "tier": "Premium",                 // Subscription tier
    "iat": 1703174400,                 // Issued at
    "exp": 1703175300,                 // Expires at (15 min)
    "jti": "token-uuid"                // JWT ID (for revocation)
  },
  "signature": "..."
}

// Refresh Token (7-day expiry)
{
  "sub": "user-uuid-here",
  "type": "refresh",
  "iat": 1703174400,
  "exp": 1703779200                   // 7 days
}
```

### 5.3 API Security Checklist

```typescript
// Rate Limiting Configuration
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,  // 1 hour
  max: 3,                     // 3 OTP requests
  message: 'Too many OTP requests, please try again later'
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,   // 15 minutes
  max: 100,                   // 100 requests
  standardHeaders: true,
  legacyHeaders: false
});

// Input Validation
const messageValidation = [
  body('text')
    .trim()
    .isLength({ min: 1, max: 2000 })
    .escape()
    .withMessage('Message must be 1-2000 characters'),
  body('coachId')
    .isUUID()
    .withMessage('Invalid coach ID'),
  body('attachment')
    .optional()
    .isURL()
    .withMessage('Invalid attachment URL')
];

// SQL Injection Prevention (Prisma)
// ✅ Safe (parameterized)
const user = await prisma.user.findUnique({
  where: { id: userId }
});

// ❌ Unsafe (raw SQL) - AVOID
const users = await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`;
```

---

## 6. Infrastructure Architecture

### 6.1 AWS Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Route 53 (DNS)                       │
│                   fitcoachapp.com                       │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────┐
│                  CloudFront (CDN)                       │
│                  SSL Certificate                        │
└────────────────────────┬────────────────────────────────┘
                         │
           ┌─────────────┴─────────────┐
           │                           │
           ▼                           ▼
┌──────────────────┐        ┌──────────────────┐
│   S3 Bucket      │        │   ALB (Load      │
│   (Static        │        │   Balancer)      │
│   Assets)        │        │                  │
└──────────────────┘        └────────┬─────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
          ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
          │   ECS Task  │  │   ECS Task  │  │   ECS Task  │
          │   (API 1)   │  │   (API 2)   │  │   (API 3)   │
          └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
                 │                │                │
                 └────────────────┼────────────────┘
                                  │
                 ┌────────────────┴────────────────┐
                 │                                 │
                 ▼                                 ▼
       ┌─────────────────┐              ┌─────────────────┐
       │   RDS (Primary) │──────────────│ RDS (Replica)   │
       │   PostgreSQL    │  Replication │  Read-only      │
       │   Multi-AZ      │              │                 │
       └─────────────────┘              └─────────────────┘

       ┌─────────────────┐
       │  ElastiCache    │
       │  (Redis)        │
       │  Cluster Mode   │
       └─────────────────┘

       ┌─────────────────┐
       │  S3 Bucket      │
       │  (User Uploads) │
       │  • Images       │
       │  • Attachments  │
       └─────────────────┘
```

### 6.2 Environment Configuration

```typescript
// config/environment.ts
export const config = {
  // Server
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  
  // Database
  DATABASE_URL: process.env.DATABASE_URL,
  DATABASE_POOL_MIN: 2,
  DATABASE_POOL_MAX: 10,
  
  // Redis
  REDIS_URL: process.env.REDIS_URL,
  REDIS_TTL: 3600, // 1 hour
  
  // JWT
  JWT_SECRET: process.env.JWT_SECRET,
  JWT_ACCESS_EXPIRY: '15m',
  JWT_REFRESH_EXPIRY: '7d',
  
  // Twilio
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN,
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE_NUMBER,
  
  // AWS
  AWS_REGION: process.env.AWS_REGION || 'us-east-1',
  AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID,
  AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY,
  AWS_S3_BUCKET: process.env.AWS_S3_BUCKET,
  
  // Firebase
  FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID,
  FIREBASE_PRIVATE_KEY: process.env.FIREBASE_PRIVATE_KEY,
  FIREBASE_CLIENT_EMAIL: process.env.FIREBASE_CLIENT_EMAIL,
  
  // SendGrid
  SENDGRID_API_KEY: process.env.SENDGRID_API_KEY,
  
  // Sentry
  SENTRY_DSN: process.env.SENTRY_DSN,
  
  // Feature Flags
  ENABLE_PUSH_NOTIFICATIONS: process.env.ENABLE_PUSH_NOTIFICATIONS === 'true',
  ENABLE_EMAIL_NOTIFICATIONS: process.env.ENABLE_EMAIL_NOTIFICATIONS === 'true',
  ENABLE_ANALYTICS: process.env.ENABLE_ANALYTICS === 'true'
};
```

### 6.3 Scaling Strategy

```yaml
Auto-Scaling Configuration:

API Servers (ECS):
  Minimum Instances: 2
  Maximum Instances: 10
  Scale Up Trigger:
    - CPU > 70% for 2 minutes
    - Memory > 80% for 2 minutes
    - Request count > 1000/min
  Scale Down Trigger:
    - CPU < 30% for 5 minutes
    - Memory < 50% for 5 minutes

Database (RDS):
  Primary: db.t3.medium (2 vCPU, 4 GB RAM)
  Read Replicas: 2 (auto-failover enabled)
  Storage: 100 GB (auto-scaling up to 1 TB)
  Backups: Daily automated (7-day retention)

Cache (ElastiCache):
  Node Type: cache.t3.medium
  Cluster: 3 nodes (master + 2 replicas)
  Eviction Policy: allkeys-lru
  Max Memory: 4 GB per node

Load Balancer:
  Health Check: /api/health (every 30s)
  Timeout: 60 seconds
  Unhealthy Threshold: 3 consecutive failures
  Healthy Threshold: 2 consecutive successes
```

---

## 7. Migration Strategy

### 7.1 Migration Phases

**Phase 1: Infrastructure Setup (Week 1)**
- [ ] Provision AWS resources (RDS, ElastiCache, S3, ECS)
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Configure domain and SSL certificates
- [ ] Set up monitoring (CloudWatch, Sentry, DataDog)
- [ ] Create staging environment

**Phase 2: Backend Development (Week 2-4)**
- [ ] Initialize Node.js project with TypeScript
- [ ] Set up Prisma ORM and migrations
- [ ] Implement authentication system (OTP, JWT)
- [ ] Build core API endpoints (users, workouts, nutrition)
- [ ] Implement quota management system
- [ ] Set up Socket.IO for real-time messaging
- [ ] Integrate Twilio (SMS), Firebase (FCM), SendGrid (email)

**Phase 3: Frontend Development (Week 5-8)**
- [ ] Initialize Flutter project
- [ ] Set up state management (Provider, Riverpod)
- [ ] Implement authentication flow
- [ ] Build 28 screens (User, Coach, Admin)
- [ ] Integrate API with Dio
- [ ] Implement real-time messaging
- [ ] Add offline support with Hive
- [ ] Localization (Arabic/English)

**Phase 4: Integration & Testing (Week 9-10)**
- [ ] End-to-end testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] Accessibility compliance
- [ ] User acceptance testing (UAT)

**Phase 5: Deployment (Week 11-12)**
- [ ] Beta deployment to staging
- [ ] App Store submission (iOS)
- [ ] Play Store submission (Android)
- [ ] Production deployment
- [ ] Monitor and iterate

### 7.2 Data Migration Script

```typescript
// scripts/migrate-data.ts
import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';

const prisma = new PrismaClient();

async function migrateUserData() {
  // 1. Export from localStorage (web app)
  const webData = JSON.parse(fs.readFileSync('./export/users.json', 'utf8'));
  
  // 2. Transform and import to PostgreSQL
  for (const user of webData) {
    await prisma.user.create({
      data: {
        phoneNumber: user.phoneNumber,
        name: user.name,
        email: user.email,
        age: user.age,
        weight: user.weight,
        height: user.height,
        gender: user.gender,
        workoutFrequency: user.workoutFrequency,
        workoutLocation: user.workoutLocation,
        experienceLevel: user.experienceLevel,
        mainGoal: user.mainGoal,
        injuries: user.injuries,
        subscriptionTier: user.subscriptionTier,
        coachId: user.coachId,
        hasCompletedSecondIntake: user.hasCompletedSecondIntake,
        fitnessScore: user.fitnessScore
      }
    });
  }
  
  console.log(`Migrated ${webData.length} users`);
}

async function migrateWorkoutPlans() {
  // Similar migration for workout plans
}

async function main() {
  await migrateUserData();
  await migrateWorkoutPlans();
  // ... migrate all entities
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

---

## 8. Deployment Architecture

### 8.1 Deployment Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
      - name: Run linting
        run: npm run lint

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker image
        run: docker build -t fitcoach-api:latest .
      - name: Push to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin
          docker push fitcoach-api:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster fitcoach-cluster \
            --service fitcoach-api \
            --force-new-deployment

  notify:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - name: Notify Slack
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -d '{"text": "Deployment successful!"}'
```

### 8.2 Monitoring & Alerting

```typescript
// Sentry Error Tracking
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1
});

// DataDog APM
import tracer from 'dd-trace';
tracer.init({
  service: 'fitcoach-api',
  env: process.env.NODE_ENV
});

// CloudWatch Metrics
import { CloudWatch } from 'aws-sdk';
const cloudwatch = new CloudWatch();

async function publishMetric(name: string, value: number) {
  await cloudwatch.putMetricData({
    Namespace: 'FitCoach',
    MetricData: [{
      MetricName: name,
      Value: value,
      Unit: 'Count',
      Timestamp: new Date()
    }]
  }).promise();
}

// Custom Alerts
const alerts = {
  errorRate: {
    threshold: 1, // 1% error rate
    action: 'Send PagerDuty alert'
  },
  responseTime: {
    threshold: 1000, // 1 second P95
    action: 'Scale up servers'
  },
  databaseConnections: {
    threshold: 80, // 80% of pool
    action: 'Increase pool size'
  }
};
```

---

## Appendix

### Technology Version Matrix

| Component | Version | Release Date | EOL Date |
|-----------|---------|--------------|----------|
| Flutter | 3.16.5 | Dec 2023 | Dec 2025 |
| Dart | 3.2.3 | Dec 2023 | - |
| Node.js | 20.10.0 LTS | Nov 2023 | Apr 2026 |
| TypeScript | 5.3.3 | Nov 2023 | - |
| PostgreSQL | 15.5 | Nov 2023 | Nov 2027 |
| Redis | 7.2 | Aug 2023 | - |
| Prisma | 5.7.1 | Dec 2023 | - |

### Resource Estimates

**Infrastructure Costs (Monthly)**
- RDS PostgreSQL (db.t3.medium): $60
- ElastiCache Redis (cache.t3.medium × 3): $120
- ECS Fargate (2-10 tasks): $50-250
- Application Load Balancer: $20
- S3 Storage (100 GB): $3
- CloudFront (1 TB transfer): $85
- **Total: $338-518/month** (scales with users)

**Third-Party Services (Monthly)**
- Twilio SMS (10,000 messages): $75
- Firebase (Analytics + FCM): Free-$25
- SendGrid (Email): Free-$15
- Sentry: $26
- **Total: $101-141/month**

**Grand Total: $439-659/month** for infrastructure + services

---

**Document Version**: 1.0.0  
**Last Updated**: December 21, 2024  
**Next Review**: March 2025
