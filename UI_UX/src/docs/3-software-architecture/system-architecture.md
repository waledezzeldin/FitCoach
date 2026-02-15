# System Architecture - عاش (FitCoach+ v2.0)

## Document Information
- **Document Type**: System Architecture Specification
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [System Context](#2-system-context)
3. [Container Architecture](#3-container-architecture)
4. [Deployment Architecture](#4-deployment-architecture)
5. [Data Flow](#5-data-flow)
6. [Security Architecture](#6-security-architecture)
7. [Scalability Architecture](#7-scalability-architecture)
8. [Integration Architecture](#8-integration-architecture)

---

## 1. Architecture Overview

### 1.1 Architectural Style

**Type**: Single Page Application (SPA) with REST API Backend

**Pattern**: Client-Server Architecture with Layered Frontend

```
┌─────────────────────────────────────────────────┐
│         Client Layer (React SPA)                │
│  ┌──────────────────────────────────────────┐  │
│  │  Presentation Layer                      │  │
│  │  (Components, Screens, UI)               │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │  Business Logic Layer                    │  │
│  │  (State Management, Utilities)           │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │  Data Access Layer                       │  │
│  │  (API calls, LocalStorage)               │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                       ↕ HTTPS
┌─────────────────────────────────────────────────┐
│         Server Layer (Node.js/Express)          │
│  ┌──────────────────────────────────────────┐  │
│  │  API Layer (REST endpoints)              │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │  Service Layer (Business logic)          │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │  Data Layer (Database access)            │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                       ↕
┌─────────────────────────────────────────────────┐
│         Data Layer (PostgreSQL)                 │
└─────────────────────────────────────────────────┘
```

### 1.2 Key Architectural Decisions

**ADR-001: React vs Angular vs Vue**
- **Decision**: React 18
- **Rationale**: Largest ecosystem, best TypeScript support, team expertise, component reusability
- **Consequences**: Need custom state management, more configuration than Angular

**ADR-002: SPA vs SSR**
- **Decision**: Single Page Application
- **Rationale**: Better user experience, offline capabilities, lower server costs
- **Consequences**: Initial load time higher, SEO requires additional work

**ADR-003: REST vs GraphQL**
- **Decision**: REST API
- **Rationale**: Simpler implementation, better caching, easier to migrate
- **Consequences**: Multiple requests for related data, overfetching

**ADR-004: PostgreSQL vs MongoDB**
- **Decision**: PostgreSQL
- **Rationale**: ACID compliance, relational data, mature tooling, SQL familiarity
- **Consequences**: More rigid schema, requires migrations

**ADR-005: Monolith vs Microservices**
- **Decision**: Modular Monolith (v2.0), Microservices (v3.0+)
- **Rationale**: Faster initial development, easier debugging, lower operational complexity
- **Migration Path**: Separate services for video, messaging, payments in future

---

## 2. System Context

### 2.1 System Context Diagram

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                    عاش Platform                            │
│                 (FitCoach+ v2.0)                           │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   Web App    │  │   Mobile Web │  │  Admin Panel │   │
│  │  (React SPA) │  │  (Responsive)│  │   (Desktop)  │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
           ↓                    ↓                    ↓
    ┌───────────┐        ┌───────────┐        ┌───────────┐
    │ End Users │        │  Coaches  │        │   Admins  │
    │(Fitness   │        │(Trainers) │        │(Platform  │
    │Enthusiasts)        └───────────┘        │ Managers) │
    └───────────┘                              └───────────┘

External Systems:
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│   Twilio/   │   │   Stripe/   │   │  Agora/     │   │  Firebase/  │
│   AWS SNS   │   │   Paddle    │   │  Twilio     │   │  OneSignal  │
│  (OTP SMS)  │   │  (Payments) │   │ (Video)     │   │  (Push)     │
└─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
```

### 2.2 User Types and Access

| User Type | Primary Device | Key Features | Access Level |
|-----------|---------------|--------------|--------------|
| End User | Mobile | Workouts, Nutrition, Messaging, Store | Tier-based (F/P/SP) |
| Coach | Mobile/Tablet | Client Management, Plan Creation, Calendar | Full access |
| Administrator | Desktop | User Management, Analytics, Settings | Full system access |

---

## 3. Container Architecture

### 3.1 Application Containers

```
                         Internet
                            ↓
                    ┌──────────────┐
                    │   Cloudflare │
                    │      CDN     │
                    └──────────────┘
                            ↓
          ┌─────────────────┴─────────────────┐
          ↓                                   ↓
┌────────────────────┐            ┌────────────────────┐
│   Static Assets    │            │   API Gateway      │
│   (Vercel/Netlify) │            │   (Load Balancer)  │
│                    │            └────────────────────┘
│  - HTML/JS/CSS     │                      ↓
│  - Images          │            ┌────────────────────┐
│  - Fonts           │            │   Application      │
└────────────────────┘            │   Servers (x3)     │
                                  │   (Node.js/Express)│
                                  └────────────────────┘
                                            ↓
                 ┌──────────────────────────┼──────────────────────────┐
                 ↓                          ↓                          ↓
      ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
      │   PostgreSQL     │      │      Redis       │      │    S3/MinIO      │
      │   (Primary DB)   │      │   (Cache/Queue)  │      │  (File Storage)  │
      │                  │      │                  │      │                  │
      │  - User data     │      │  - Sessions      │      │  - Images        │
      │  - Workouts      │      │  - Quotas        │      │  - Attachments   │
      │  - Messages      │      │  - Temp data     │      │  - Backups       │
      └──────────────────┘      └──────────────────┘      └──────────────────┘
              ↓
      ┌──────────────────┐
      │   PostgreSQL     │
      │  (Read Replica)  │
      │   for Analytics  │
      └──────────────────┘
```

### 3.2 Frontend Container (React SPA)

**Technology Stack**:
- React 18.2
- TypeScript 5.0
- Tailwind CSS v4.0
- Vite 5 (build tool)

**Key Responsibilities**:
- UI rendering and user interactions
- Client-side routing
- State management (React Context)
- API communication
- Offline support (Service Worker)

**Build Artifacts**:
```
dist/
├── index.html
├── assets/
│   ├── index.[hash].js        # Main bundle
│   ├── vendor.[hash].js       # Third-party libs
│   ├── translations.[hash].js # i18n data (code split)
│   └── *.css                  # Styles
└── images/
```

**Bundle Optimization**:
```javascript
// vite.config.ts
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          translations: ['./src/translations/translations-data.ts'],
          admin: ['./src/components/admin/**']
        }
      }
    }
  }
};
```

---

### 3.3 Backend Container (API Server)

**Technology Stack**:
- Node.js 18 LTS
- Express 4.18
- TypeScript
- Prisma ORM (or TypeORM)

**API Structure**:
```
/api
├── /auth
│   ├── POST /send-otp
│   ├── POST /verify-otp
│   └── POST /logout
├── /users
│   ├── GET    /me
│   ├── PUT    /me
│   ├── POST   /intake/first
│   └── POST   /intake/second
├── /workouts
│   ├── GET    /plans
│   ├── POST   /logs
│   └── GET    /exercises
├── /nutrition
│   ├── POST   /generate
│   ├── GET    /plans
│   └── GET    /access-status
├── /messages
│   ├── GET    /conversations
│   ├── POST   /conversations/:id/messages
│   └── POST   /conversations/:id/attachments
├── /quota
│   ├── GET    /usage
│   └── POST   /reset
├── /subscriptions
│   ├── GET    /current
│   ├── POST   /upgrade
│   └── GET    /invoices
├── /store
│   ├── GET    /products
│   ├── POST   /orders
│   └── GET    /orders/:id
└── /admin
    ├── GET    /users
    ├── PUT    /users/:id
    ├── GET    /analytics
    └── GET    /audit-logs
```

**Middleware Stack**:
```typescript
app.use(helmet());                    // Security headers
app.use(cors(corsOptions));           // CORS configuration
app.use(express.json());              // JSON body parser
app.use(morgan('combined'));          // Request logging
app.use(rateLimiter);                 // Rate limiting
app.use(authenticate);                // JWT validation
app.use(errorHandler);                // Centralized error handling
```

---

### 3.4 Database Container (PostgreSQL)

**Configuration**:
- PostgreSQL 14
- Primary + 1 Read Replica
- Connection pooling (max 20 connections)
- Automated backups (daily, 30-day retention)

**Database Schema** (24 tables):
```
users
coaches
otp_sessions
quota_usage
exercises
workout_plans
workouts
workout_exercises
nutrition_plans
meals
food_items
conversations
messages
video_calls
coach_ratings
products
orders
order_items
weight_entries
inbody_scans
audit_logs
system_settings
subscriptions
payment_transactions
```

**Indexes** (Performance Optimization):
```sql
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_tier ON users(subscription_tier);
CREATE INDEX idx_messages_conversation_date ON messages(conversation_id, sent_at DESC);
CREATE INDEX idx_workout_logs_user_date ON workout_logs(user_id, completed_at DESC);
CREATE INDEX idx_quota_user_reset ON quota_usage(user_id, reset_date);
```

---

### 3.5 Cache Container (Redis)

**Use Cases**:
- Session storage (JWT tokens)
- Quota counters (fast reads/writes)
- API response caching
- Rate limiting counters
- Temporary OTP storage

**Data Structures**:
```redis
# Session
SET session:{userId} {sessionData} EX 2592000  # 30 days

# Quota counters
INCR quota:messages:{userId}
EXPIRE quota:messages:{userId} 2592000         # Auto-reset monthly

# OTP attempts
INCR otp:attempts:{phoneNumber}
EXPIRE otp:attempts:{phoneNumber} 3600         # 1 hour

# Rate limiting
INCR ratelimit:{ip}:{endpoint}
EXPIRE ratelimit:{ip}:{endpoint} 60            # 1 minute window
```

---

### 3.6 File Storage Container (S3/MinIO)

**Stored Files**:
- User profile photos
- Exercise photos/videos
- Meal photos
- Chat attachments (Smart Premium)
- Product images
- InBody scan documents

**Bucket Structure**:
```
fitcoach-storage/
├── users/
│   └── {userId}/
│       ├── profile.jpg
│       └── documents/
├── exercises/
│   ├── photos/
│   └── videos/
├── meals/
│   └── photos/
├── attachments/
│   └── {conversationId}/
│       └── {messageId}/
└── products/
    └── {productId}/
```

**Security**:
- Pre-signed URLs (expiry: 1 hour)
- Server-side encryption (AES-256)
- Bucket policies (private by default)

---

## 4. Deployment Architecture

### 4.1 Production Environment

```
                    ┌──────────────────┐
                    │   Cloudflare     │
                    │   (DNS + CDN)    │
                    └──────────────────┘
                            ↓
                    ┌──────────────────┐
                    │   AWS Route 53   │
                    │  (Load Balancer) │
                    └──────────────────┘
                            ↓
          ┌─────────────────┴─────────────────┐
          ↓                                   ↓
┌──────────────────┐              ┌──────────────────┐
│  Vercel/Netlify  │              │   AWS ECS/EKS    │
│  (Frontend SPA)  │              │  (Backend API)   │
│                  │              │                  │
│  - Auto-deploy   │              │  - 3 containers  │
│  - Global CDN    │              │  - Auto-scaling  │
│  - SSL cert      │              │  - Health checks │
└──────────────────┘              └──────────────────┘
                                            ↓
                                  ┌──────────────────┐
                                  │   AWS RDS        │
                                  │  (PostgreSQL)    │
                                  │  Multi-AZ        │
                                  └──────────────────┘
```

### 4.2 Infrastructure as Code (Terraform)

```hcl
# Example: AWS ECS Task Definition
resource "aws_ecs_task_definition" "fitcoach_api" {
  family                   = "fitcoach-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "api"
    image     = "fitcoach/api:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "DATABASE_URL", value = var.database_url }
    ]
  }])
}

# Auto-scaling
resource "aws_appautoscaling_target" "api" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/fitcoach-cluster/fitcoach-api"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

---

## 5. Data Flow

### 5.1 User Authentication Flow

```
┌──────────┐                   ┌──────────┐                  ┌──────────┐
│  Client  │                   │   API    │                  │  Twilio  │
└──────────┘                   └──────────┘                  └──────────┘
     │                              │                              │
     │  1. POST /auth/send-otp      │                              │
     │  { phoneNumber }             │                              │
     │─────────────────────────────>│                              │
     │                              │  2. Generate OTP             │
     │                              │     Hash & Store             │
     │                              │                              │
     │                              │  3. Send SMS                 │
     │                              │─────────────────────────────>│
     │                              │                              │
     │  4. OTP sent (200 OK)        │                              │
     │<─────────────────────────────│                              │
     │                              │                              │
     │                              │                              │
     │  5. POST /auth/verify-otp    │                              │
     │  { phoneNumber, code }       │                              │
     │─────────────────────────────>│                              │
     │                              │  6. Validate OTP             │
     │                              │     Find/Create User         │
     │                              │     Generate JWT             │
     │                              │                              │
     │  7. { token, user }          │                              │
     │<─────────────────────────────│                              │
     │                              │                              │
     │  8. Store token              │                              │
     │     Navigate to Home         │                              │
     │                              │                              │
```

### 5.2 Send Message Flow (with Quota Check)

```
┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│  Client  │         │   API    │         │  Redis   │         │PostgreSQL│
└──────────┘         └──────────┘         └──────────┘         └──────────┘
     │                    │                    │                    │
     │  1. POST /messages │                    │                    │
     │  { content }       │                    │                    │
     │───────────────────>│                    │                    │
     │                    │  2. Check quota    │                    │
     │                    │───────────────────>│                    │
     │                    │  GET quota count   │                    │
     │                    │                    │                    │
     │                    │  3. Count: 15/20   │                    │
     │                    │<───────────────────│                    │
     │                    │                    │                    │
     │                    │  4. Allowed ✓      │                    │
     │                    │                    │                    │
     │                    │  5. Save message            │
     │                    │────────────────────────────>│
     │                    │                    │                    │
     │                    │  6. INCR quota     │                    │
     │                    │───────────────────>│                    │
     │                    │                    │                    │
     │  7. { message }    │                    │                    │
     │<───────────────────│                    │                    │
     │                    │                    │                    │
     │  8. Display message│                    │                    │
     │     Show "5 left"  │                    │                    │
     │                    │                    │                    │
```

### 5.3 Generate Workout Plan Flow (Coach → Client)

```
┌───────────┐       ┌──────────┐       ┌──────────┐       ┌──────────┐
│   Coach   │       │   API    │       │PostgreSQL│       │  Client  │
│  (Web)    │       │          │       │          │       │  (Push)  │
└───────────┘       └──────────┘       └──────────┘       └──────────┘
     │                   │                   │                   │
     │  1. POST /workouts/plans              │                   │
     │  { clientId, exercises[] }            │                   │
     │──────────────────>│                   │                   │
     │                   │  2. Verify        │                   │
     │                   │     coach-client  │                   │
     │                   │────────────────> │                   │
     │                   │                   │                   │
     │                   │  3. Check injuries│                   │
     │                   │  (auto-substitute)│                   │
     │                   │                   │                   │
     │                   │  4. Save plan     │                   │
     │                   │────────────────> │                   │
     │                   │                   │                   │
     │                   │  5. Deactivate old│                   │
     │                   │────────────────> │                   │
     │                   │                   │                   │
     │                   │  6. Notify client │                   │
     │                   │────────────────────────────────────> │
     │                   │                   │                   │
     │  7. Plan created  │                   │                   │
     │<──────────────────│                   │                   │
     │                   │                   │                   │
```

---

## 6. Security Architecture

### 6.1 Defense in Depth

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Network Security                             │
│  - Cloudflare DDoS protection                          │
│  - AWS WAF (Web Application Firewall)                  │
│  - Rate limiting (per IP, per user)                    │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  Layer 2: Application Security                         │
│  - HTTPS/TLS 1.3 only                                  │
│  - JWT authentication                                  │
│  - CORS configuration                                  │
│  - Security headers (Helmet.js)                        │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  Layer 3: API Security                                 │
│  - Input validation (Joi/Yup)                          │
│  - SQL injection prevention (parameterized queries)    │
│  - XSS prevention (sanitization)                       │
│  - CSRF tokens                                         │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  Layer 4: Data Security                                │
│  - Encryption at rest (AES-256)                        │
│  - Encrypted backups                                   │
│  - Sensitive data hashing (bcrypt)                     │
│  - Access control (RBAC)                               │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  Layer 5: Monitoring & Response                        │
│  - Intrusion detection (Fail2ban)                      │
│  - Audit logging                                       │
│  - Error tracking (Sentry)                             │
│  - Security alerts                                     │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Authentication & Authorization

**JWT Token Structure**:
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": "uuid",
    "phoneNumber": "+966512345678",
    "role": "user",
    "tier": "Premium",
    "iat": 1702857600,
    "exp": 1705449600
  }
}
```

**RBAC Matrix**:
| Resource | User | Coach | Admin |
|----------|------|-------|-------|
| Own Profile | Read/Write | Read/Write | Read/Write |
| Workout Plans | Read (assigned) | Read/Write (clients) | Read/Write (all) |
| Messages | Read/Write (own) | Read/Write (clients) | Read (all) |
| Quota Settings | Read | Read | Write |
| User Management | - | - | Full |

---

## 7. Scalability Architecture

### 7.1 Horizontal Scaling

**Application Servers**:
- Stateless design (JWT auth, no server sessions)
- Auto-scaling: Min 3, Max 10 instances
- Load balancer: Round-robin with health checks

**Database**:
- Primary for writes
- Read replicas for analytics and reports
- Connection pooling (max 20 per instance)

**Cache**:
- Redis cluster (3 nodes)
- Cache-aside pattern
- TTL-based expiration

### 7.2 Vertical Scaling Limits

| Component | Current | Max Scale |
|-----------|---------|-----------|
| App Server | 512MB/1 vCPU | 4GB/4 vCPU |
| Database | db.t3.medium | db.r5.xlarge |
| Redis | cache.t3.micro | cache.r5.large |

### 7.3 Performance Optimization

**Client-Side**:
```typescript
// Code splitting
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));

// Image lazy loading
<img src="workout.jpg" loading="lazy" />

// Debounced search
const debouncedSearch = debounce(searchAPI, 300);
```

**Server-Side**:
```typescript
// Query optimization
const users = await prisma.user.findMany({
  select: { id: true, name: true }, // Only needed fields
  where: { subscriptionTier: 'Premium' },
  take: 50,                          // Limit results
  skip: page * 50                    // Pagination
});

// Caching
const cacheKey = `workout_plan_${userId}`;
let plan = await redis.get(cacheKey);
if (!plan) {
  plan = await db.workoutPlans.findOne({ userId });
  await redis.set(cacheKey, JSON.stringify(plan), 'EX', 3600); // 1 hour
}
```

---

## 8. Integration Architecture

### 8.1 External Service Integration

```
┌────────────────────────────────────────────────────┐
│              عاش Platform API                      │
└────────────────────────────────────────────────────┘
         ↓           ↓           ↓           ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   Twilio     │ │   Stripe     │ │    Agora     │ │  OneSignal   │
│   SMS API    │ │  Payment API │ │   Video API  │ │   Push API   │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

**Integration Patterns**:
- **Twilio SMS**: REST API, synchronous calls
- **Stripe Payments**: REST API + Webhooks for events
- **Agora Video**: SDK integration, token-based auth
- **OneSignal Push**: REST API, batched notifications

### 8.2 Webhook Handling

```typescript
// Stripe webhook handler
app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSuccess(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionCancellation(event.data.object);
        break;
    }
    
    res.json({ received: true });
  } catch (err) {
    res.status(400).send(`Webhook Error: ${err.message}`);
  }
});
```

---

## Summary

**Architecture Characteristics**:
- **Scalability**: Horizontal scaling to 10,000+ users
- **Reliability**: 99.5% uptime target
- **Performance**: < 1 second API responses (95th percentile)
- **Security**: Defense in depth, OWASP Top 10 compliance
- **Maintainability**: Modular design, comprehensive logging

**Technology Choices**:
- Frontend: React 18 + TypeScript + Tailwind CSS
- Backend: Node.js + Express + TypeScript
- Database: PostgreSQL 14 with read replicas
- Cache: Redis cluster
- File Storage: AWS S3 / MinIO
- Hosting: Vercel (frontend), AWS ECS (backend)

---

**Document Status**: ✅ Complete  
**Last Updated**: December 2024  
**Version**: 2.0.0

---

**End of System Architecture Specification**
