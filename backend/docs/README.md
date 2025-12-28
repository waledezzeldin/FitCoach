# 🔧 عاش Fitness - Backend API Documentation

**Complete documentation for the Node.js/Express backend server**

---

## 📋 **QUICK START**

- **[Quick Start Guide](./QUICK_START.md)** - Get the backend running in 5 minutes
- **[README](../README.md)** - Main backend README

---

## 📚 **DOCUMENTATION INDEX**

### **1. Getting Started**

| Document | Description |
|----------|-------------|
| [Quick Start](./QUICK_START.md) | Setup backend in 5 minutes |
| [Production Readiness](./PRODUCTION_READINESS_CHECKLIST.md) | Deployment checklist |
| [Testing Guide](./TESTING.md) | How to run tests |

---

### **2. API Documentation**

| Document | Description |
|----------|-------------|
| [API Overview](./API_OVERVIEW.md) | All 61 API endpoints |
| [Authentication](./AUTH_API.md) | Auth endpoints & OTP flow |
| [User APIs](./USER_API.md) | User management endpoints |
| [Workout APIs](./WORKOUT_API.md) | Workout plan endpoints |
| [Nutrition APIs](./NUTRITION_API.md) | Nutrition plan endpoints |
| [Coach APIs](./COACH_API.md) | Coach feature endpoints |
| [Admin APIs](./ADMIN_API.md) | Admin panel endpoints |
| [Store APIs](./STORE_API.md) | E-commerce endpoints |

---

### **3. System Guides**

| Document | Description |
|----------|-------------|
| [Complete System Overview](./COMPLETE_SYSTEM_OVERVIEW.md) | Full system architecture |
| [Workout System Guide](./WORKOUT_SYSTEM_GUIDE.md) | Workout generation system |
| [Workout Templates](./WORKOUT_TEMPLATES_GUIDE.md) | Template library guide |
| [Injury Mapping](./INJURY_MAPPING_GUIDE.md) | Injury substitution engine |

---

### **4. Implementation Reports**

| Document | Description |
|----------|-------------|
| [Backend Complete Summary](./BACKEND_COMPLETE_SUMMARY.md) | Implementation summary |
| [Features Complete](./FEATURES_COMPLETE.md) | Feature checklist |
| [Backend Audit](./BACKEND_AUDIT_COMPLETE.md) | Code audit results |
| [Testing Complete](./TESTING_COMPLETE.md) | Test coverage report |

---

## 🏗️ **ARCHITECTURE**

```
backend/
├── src/
│   ├── controllers/           # Request handlers (18 controllers)
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── workoutController.js
│   │   ├── nutritionController.js
│   │   ├── coachController.js
│   │   ├── adminController.js
│   │   └── ...
│   │
│   ├── services/              # Business logic (15 services)
│   │   ├── workoutGenerationService.js
│   │   ├── nutritionGenerationService.js
│   │   ├── injuryMappingService.js
│   │   ├── quotaService.js
│   │   └── ...
│   │
│   ├── routes/                # API routes (17 route files)
│   ├── middleware/            # Auth, validation, etc.
│   ├── database/              # DB connection & migrations
│   ├── sockets/               # WebSocket handlers
│   └── utils/                 # Helper functions
│
├── __tests__/                 # Test files
├── migrations/                # Database migrations
├── docs/                      # Documentation (this folder)
└── package.json
```

---

## 📊 **API ENDPOINTS SUMMARY**

### **Total: 61 APIs**

| Category | Endpoints | Status |
|----------|-----------|--------|
| **Authentication** | 7 | ✅ Complete |
| **User Management** | 8 | ✅ Complete |
| **Workout System** | 9 | ✅ Complete |
| **Nutrition System** | 7 | ✅ Complete |
| **Coach Features** | 12 | ✅ Complete |
| **Admin Features** | 8 | ✅ Complete |
| **Video Calls** | 4 | ✅ Complete |
| **Messaging** | 3 | ✅ Complete |
| **E-commerce** | 3 | ✅ Complete |

---

## 🔐 **AUTHENTICATION**

### **OTP Flow:**
```
1. POST /api/auth/request-otp       # Request OTP via SMS
2. POST /api/auth/verify-otp        # Verify OTP code
3. Receive JWT token                # Use for all requests
```

### **Protected Routes:**
```javascript
// Add JWT token to headers
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN'
}
```

---

## 🗄️ **DATABASE**

### **PostgreSQL Tables:**
- `users` - User accounts
- `user_profiles` - User details
- `workout_plans` - Workout plans
- `nutrition_plans` - Nutrition plans
- `coaches` - Coach profiles
- `messages` - Chat messages
- `video_call_sessions` - Video calls
- `products` - Store products
- `orders` - E-commerce orders
- **+ 15 more tables**

### **Migrations:**
```bash
# Run migrations
npm run migrate

# Reset database
npm run db:reset
```

---

## 🚀 **GETTING STARTED**

### **1. Prerequisites**
```bash
# Install Node.js 18+
# Install PostgreSQL 14+
# Install Redis (optional, for caching)
```

### **2. Setup**
```bash
cd backend

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your credentials

# Create database
createdb ash_fitness

# Run migrations
npm run migrate

# Seed data (optional)
npm run seed
```

### **3. Run**
```bash
# Development
npm run dev

# Production
npm start

# Run tests
npm test
```

---

## 🔗 **ENVIRONMENT VARIABLES**

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/ash_fitness

# JWT
JWT_SECRET=your-secret-key

# Twilio (OTP)
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
TWILIO_PHONE_NUMBER=+1234567890

# Stripe (Payments)
STRIPE_SECRET_KEY=sk_test_...

# Agora (Video)
AGORA_APP_ID=your-app-id
AGORA_APP_CERTIFICATE=your-certificate

# AWS S3 (File Storage)
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_S3_BUCKET=your-bucket

# OpenAI (AI Generation)
OPENAI_API_KEY=sk-...
```

---

## 📊 **TESTING**

### **Test Coverage:**
- ✅ Controller tests
- ✅ Service tests
- ✅ Middleware tests
- ✅ Integration tests
- ✅ Repository tests

### **Run Tests:**
```bash
# All tests
npm test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage
```

---

## 🔗 **RELATED DOCUMENTATION**

- **Mobile Documentation:** `/mobile/docs/README.md`
- **React Documentation:** `/docs/README.md`
- **Main Project README:** `/README.md`

---

## 📞 **SUPPORT**

For questions or issues:
1. Check [Quick Start Guide](./QUICK_START.md)
2. Review [Complete System Overview](./COMPLETE_SYSTEM_OVERVIEW.md)
3. See [API Documentation](#2-api-documentation)

---

*Last Updated: December 2024*  
*Node.js Version: 18+*  
*Status: Production Ready* ✅

