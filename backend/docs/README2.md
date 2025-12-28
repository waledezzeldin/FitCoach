# 🚀 FitCoach+ Backend API v2.0 - عاش

Comprehensive Node.js + PostgreSQL backend for the FitCoach+ fitness coaching platform.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Database Setup](#database-setup)
- [API Documentation](#api-documentation)
- [Environment Variables](#environment-variables)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Deployment](#deployment)

---

## ✨ Features

### 🔐 Authentication & Authorization
- ✅ Phone OTP authentication (+966 Saudi format)
- ✅ JWT token-based auth with refresh tokens
- ✅ Role-based access control (User, Coach, Admin)
- ✅ Subscription tier-based permissions

### 👥 User Management
- ✅ Two-stage intake system (5Q + 6Q)
- ✅ Profile management with bilingual support (AR/EN)
- ✅ Injury tracking for exercise substitution
- ✅ Three subscription tiers (Freemium, Premium, Smart Premium)

### 📊 Quota System
- ✅ Monthly message quotas by tier
- ✅ Video call quotas by tier
- ✅ 14-day nutrition trial for Freemium users
- ✅ Automatic monthly reset
- ✅ Real-time quota enforcement

### 💪 Workout Management
- ✅ Workout plan creation and assignment
- ✅ 400+ exercise database
- ✅ Automatic injury detection
- ✅ Smart exercise substitution engine
- ✅ Progress tracking

### 🥗 Nutrition Management
- ✅ Custom meal plans
- ✅ Macro tracking (Protein, Carbs, Fats)
- ✅ Time-limited trial for Freemium
- ✅ Meal completion tracking

### 💬 Real-Time Messaging
- ✅ Socket.IO for instant messaging
- ✅ Message quota enforcement
- ✅ Attachment gating (Premium+ only)
- ✅ Typing indicators
- ✅ Read receipts
- ✅ Push notifications

### 📹 Video Call Booking
- ✅ Calendar-based scheduling
- ✅ Quota enforcement
- ✅ Booking management
- ✅ Meeting URL generation ready

### ⭐ Rating System
- ✅ Post-interaction ratings (5-star)
- ✅ Text feedback
- ✅ Coach rating aggregation
- ✅ Rating for messages, calls, workouts, nutrition

### 🛒 E-Commerce
- ✅ Product management
- ✅ Shopping cart
- ✅ Order processing
- ✅ Coach commission tracking

### 📈 Progress Tracking
- ✅ Body measurements
- ✅ Weight and body fat tracking
- ✅ Progress photos
- ✅ Achievement system

### 👨‍💼 Coach & Admin Tools
- ✅ Coach dashboard
- ✅ Client management
- ✅ Plan creation tools
- ✅ Admin analytics
- ✅ User management
- ✅ Audit logging

---

## 🛠 Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL 14+
- **Real-time:** Socket.IO
- **Authentication:** JWT
- **SMS:** Twilio
- **Storage:** AWS S3
- **Logging:** Winston
- **Testing:** Jest
- **Validation:** Express Validator

---

## 🚀 Quick Start

### Prerequisites

```bash
# Node.js 18+
node --version

# PostgreSQL 14+
postgres --version

# npm or yarn
npm --version
```

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd backend

# 2. Install dependencies
npm install

# 3. Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# 4. Create database
createdb fitcoach_db

# 5. Run database migrations
npm run migrate

# 6. (Optional) Seed database with sample data
npm run seed

# 7. Start development server
npm run dev
```

The API will be available at `http://localhost:5000`

---

## 🗄 Database Setup

### Create Database

```bash
# Using psql
createdb fitcoach_db

# Or manually
psql -U postgres
CREATE DATABASE fitcoach_db;
\q
```

### Run Schema

```bash
# Run the schema SQL file
psql -U postgres -d fitcoach_db -f src/database/schema.sql
```

### Database Schema Overview

```
📊 Database Tables (20+):
├─ users                    # User accounts
├─ otp_verifications        # OTP codes
├─ coaches                  # Coach profiles
├─ exercises                # Exercise library (400+)
├─ workout_plans            # User workout plans
├─ workout_days             # Daily workouts
├─ workout_exercises        # Exercise assignments
├─ nutrition_plans          # Nutrition plans
├─ day_meal_plans           # Daily meal plans
├─ meals                    # Individual meals
├─ food_items               # Food ingredients
├─ conversations            # Chat conversations
├─ messages                 # Chat messages
├─ video_call_bookings      # Video sessions
├─ ratings                  # User ratings
├─ products                 # Store products
├─ orders                   # Purchase orders
├─ order_items              # Order line items
├─ progress_entries         # Progress tracking
├─ notifications            # Push notifications
└─ audit_logs               # System audit trail
```

---

## 📚 API Documentation

### Base URL

```
Development: http://localhost:5000/v2
Production: https://api.fitcoachplus.com/v2
```

### Authentication

All protected endpoints require JWT token in header:

```
Authorization: Bearer <access_token>
```

### Endpoints

#### 🔐 Authentication

```
POST   /v2/auth/send-otp          # Send OTP to phone
POST   /v2/auth/verify-otp        # Verify OTP and login
POST   /v2/auth/refresh-token     # Refresh access token
POST   /v2/auth/logout            # Logout user
GET    /v2/auth/me                # Get current user
```

#### 👤 Users

```
GET    /v2/users/:id              # Get user profile
PUT    /v2/users/:id              # Update user profile
POST   /v2/users/first-intake    # Complete first intake
POST   /v2/users/second-intake   # Complete second intake
GET    /v2/users/:id/quota        # Get quota status
POST   /v2/users/start-trial     # Start nutrition trial
```

#### 💪 Workouts

```
GET    /v2/workouts               # Get user's workout plans
GET    /v2/workouts/:id           # Get workout plan details
POST   /v2/workouts               # Create workout plan (Coach)
PUT    /v2/workouts/:id           # Update workout plan
DELETE /v2/workouts/:id           # Delete workout plan
POST   /v2/workouts/:id/complete  # Mark exercise complete
GET    /v2/workouts/:id/progress  # Get workout progress
```

#### 🥗 Nutrition

```
GET    /v2/nutrition              # Get nutrition plans
GET    /v2/nutrition/:id          # Get nutrition plan details
POST   /v2/nutrition              # Create nutrition plan (Coach)
PUT    /v2/nutrition/:id          # Update nutrition plan
POST   /v2/nutrition/:id/complete # Mark meal complete
GET    /v2/nutrition/trial-status # Get trial status
```

#### 💬 Messages

```
GET    /v2/messages/conversations        # Get all conversations
GET    /v2/messages/conversations/:id    # Get conversation messages
POST   /v2/messages                      # Send message
PUT    /v2/messages/:id/read             # Mark as read
POST   /v2/messages/upload               # Upload attachment (Premium+)
```

#### 📹 Bookings

```
GET    /v2/bookings                      # Get user bookings
POST   /v2/bookings                      # Create booking
PUT    /v2/bookings/:id                  # Update booking
DELETE /v2/bookings/:id                  # Cancel booking
GET    /v2/bookings/available-slots     # Get available slots
```

#### 🏋️ Exercises

```
GET    /v2/exercises                     # Get all exercises
GET    /v2/exercises/:id                 # Get exercise details
GET    /v2/exercises/search              # Search exercises
GET    /v2/exercises/alternatives/:id    # Get alternatives
POST   /v2/exercises                     # Create exercise (Admin)
PUT    /v2/exercises/:id                 # Update exercise
```

#### 🛒 Products & Orders

```
GET    /v2/products                      # Get all products
GET    /v2/products/:id                  # Get product details
POST   /v2/orders                        # Create order
GET    /v2/orders                        # Get user orders
GET    /v2/orders/:id                    # Get order details
```

#### ⭐ Ratings

```
POST   /v2/ratings                       # Submit rating
GET    /v2/ratings/coach/:id             # Get coach ratings
GET    /v2/ratings/user/:id              # Get user's ratings
```

#### 👨‍💼 Coach & Admin

```
GET    /v2/coaches                       # Get all coaches
GET    /v2/coaches/:id                   # Get coach profile
GET    /v2/coaches/:id/clients           # Get coach clients
POST   /v2/admin/users/:id/suspend       # Suspend user
GET    /v2/admin/analytics               # Get analytics
```

### Response Format

#### Success Response

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

#### Error Response

```json
{
  "success": false,
  "message": "Error message",
  "errors": [ ... ]
}
```

---

## 🔧 Environment Variables

See `.env.example` for full list. Critical variables:

```env
# Database
DB_HOST=localhost
DB_NAME=fitcoach_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_secret_key

# Twilio (for OTP)
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_PHONE_NUMBER=+966xxxxxxxxx

# AWS S3 (for uploads)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_S3_BUCKET=fitcoach-uploads
```

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── controllers/       # Request handlers
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── workoutController.js
│   │   └── ...
│   ├── routes/            # API routes
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── workouts.js
│   │   └── ...
│   ├── middleware/        # Custom middleware
│   │   ├── auth.js
│   │   ├── rateLimiter.js
│   │   └── validation.js
│   ├── services/          # Business logic
│   │   ├── twilioService.js
│   │   ├── quotaService.js
│   │   └── ...
│   ├── sockets/           # Socket.IO handlers
│   │   └── index.js
│   ├── database/          # Database files
│   │   ├── index.js
│   │   ├── schema.sql
│   │   ├── migrate.js
│   │   └── seed.js
│   ├── utils/             # Utilities
│   │   ├── logger.js
│   │   └── helpers.js
│   └── server.js          # Entry point
├── tests/                 # Test files
├── logs/                  # Log files
├── .env.example           # Environment template
├── package.json
└── README.md
```

---

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run specific test file
npm test -- tests/auth.test.js

# Watch mode
npm test -- --watch
```

---

## 📊 Key Features Implementation

### 1. Phone OTP Authentication

```javascript
// Send OTP
POST /v2/auth/send-otp
{
  "phoneNumber": "+966501234567"
}

// Verify OTP
POST /v2/auth/verify-otp
{
  "phoneNumber": "+966501234567",
  "otpCode": "1234"
}
```

### 2. Quota Enforcement

Middleware automatically checks quotas:

```javascript
// Middleware checks quota before allowing message
router.post('/messages', 
  authMiddleware, 
  checkMessageQuota,  // ✅ Automatic quota check
  messageController.send
);
```

### 3. Injury Substitution

```javascript
// Automatic injury detection
const userInjuries = ['shoulder_injury', 'knee_pain'];
const exercise = await Exercise.findById(id);

if (hasInjuryConflict(userInjuries, exercise.contraindications)) {
  // Substitute with safe alternative
  const alternatives = await Exercise.getAlternatives(exercise.id);
  // Return safe options
}
```

### 4. Real-Time Messaging

```javascript
// Client connects
socket.on('connect', () => {
  socket.emit('join_conversation', { conversationId });
});

// Send message
socket.emit('send_message', {
  conversationId,
  content: 'Hello!',
  type: 'text'
});

// Receive messages
socket.on('new_message', (data) => {
  console.log(data.message);
});
```

### 5. Nutrition Trial

```javascript
// Middleware checks nutrition access
router.get('/nutrition/:id',
  authMiddleware,
  checkNutritionAccess,  // ✅ Checks trial or subscription
  nutritionController.get
);
```

---

## 🚀 Deployment

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET`
- [ ] Configure database backup
- [ ] Setup SSL/TLS
- [ ] Configure rate limiting
- [ ] Setup monitoring (PM2, New Relic, etc.)
- [ ] Configure log rotation
- [ ] Setup CDN for static assets
- [ ] Enable database connection pooling
- [ ] Configure CORS properly

### Docker Deployment

```bash
# Build image
docker build -t fitcoach-backend .

# Run container
docker run -p 5000:5000 --env-file .env fitcoach-backend
```

### PM2 Deployment

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start src/server.js --name fitcoach-api

# Save process list
pm2 save

# Setup startup script
pm2 startup
```

---

## 📈 Performance

### Optimizations

- ✅ Database connection pooling
- ✅ Query optimization with indexes
- ✅ Response compression
- ✅ Rate limiting
- ✅ Caching with Redis (optional)
- ✅ Efficient pagination
- ✅ Lazy loading

### Monitoring

- Winston logging
- Morgan HTTP logging
- Error tracking
- Performance metrics
- Database query logging

---

## 🔒 Security

- ✅ JWT authentication
- ✅ Password hashing (bcrypt)
- ✅ SQL injection protection (parameterized queries)
- ✅ XSS protection (Helmet)
- ✅ CORS configuration
- ✅ Rate limiting
- ✅ Input validation
- ✅ Audit logging

---

## 📝 API Rate Limits

```
General API: 100 requests / 15 minutes
Auth (OTP):  5 requests / 15 minutes
Uploads:     10 requests / hour
```

---

## 🐛 Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL is running
pg_isready

# Test connection
psql -U postgres -d fitcoach_db -c "SELECT 1"
```

### Port Already in Use

```bash
# Find process using port 5000
lsof -i :5000

# Kill process
kill -9 <PID>
```

---

## 📞 Support

- Documentation: `/docs`
- Issues: GitHub Issues
- Email: support@fitcoachplus.com

---

## 📄 License

MIT License - Copyright (c) 2024 FitCoach+

---

## 🎉 Ready to Launch!

```bash
npm run dev
```

API will be running at: **http://localhost:5000/v2**

Health check: **http://localhost:5000/health**

---

**Built with ❤️ by FitCoach+ Team**
