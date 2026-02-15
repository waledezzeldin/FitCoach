# 🚀 Backend Quick Start Guide

**Get the عاش Fitness backend running in 5 minutes**

---

## ⚡ **1. Prerequisites**

```bash
# Check Node.js version (18+ required)
node --version

# Check PostgreSQL (14+ required)
psql --version

# Install Git
git --version
```

---

## 📦 **2. Install Dependencies**

```bash
cd backend

# Install Node packages
npm install
```

---

## 🔧 **3. Setup Environment**

### **Create `.env` file:**

```bash
cp .env.example .env
```

### **Configure `.env`:**

```env
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/ash_fitness
PORT=3000

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this

# Twilio (OTP)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890

# Stripe (Payments)
STRIPE_SECRET_KEY=sk_test_your_stripe_key

# Agora (Video Calls)
AGORA_APP_ID=your-agora-app-id
AGORA_APP_CERTIFICATE=your-agora-certificate

# AWS S3 (File Storage)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_S3_BUCKET=ash-fitness-uploads
AWS_REGION=us-east-1

# OpenAI (AI Generation)
OPENAI_API_KEY=sk-your-openai-key
```

---

## 🗄️ **4. Setup Database**

### **Create Database:**

```bash
# Using psql
createdb ash_fitness

# Or using SQL
psql -U postgres
CREATE DATABASE ash_fitness;
\q
```

### **Run Migrations:**

```bash
npm run migrate
```

### **Seed Data (Optional):**

```bash
npm run seed
```

---

## ▶️ **5. Run Server**

### **Development Mode:**

```bash
npm run dev
```

### **Production Mode:**

```bash
npm start
```

---

## ✅ **6. Verify Installation**

### **Check Server:**

```bash
# Server should be running on:
http://localhost:3000
```

### **Test API:**

```bash
# Health check
curl http://localhost:3000/health

# Should return:
# {"status":"ok","timestamp":"..."}
```

### **Test Database:**

```bash
# Check tables
psql ash_fitness -c "\dt"

# Should show 25+ tables
```

---

## 🧪 **7. Run Tests (Optional)**

```bash
# Run all tests
npm test

# Run in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

---

## 📊 **8. Available Endpoints**

### **Authentication:**
```
POST   /api/auth/request-otp    # Request OTP
POST   /api/auth/verify-otp     # Verify OTP & get token
POST   /api/auth/refresh        # Refresh token
```

### **Users:**
```
GET    /api/users/profile       # Get user profile
PUT    /api/users/profile       # Update profile
```

### **Workouts:**
```
GET    /api/workouts/active     # Get active workout plan
POST   /api/workouts/generate   # Generate new plan
```

### **Nutrition:**
```
GET    /api/nutrition/active    # Get active nutrition plan
POST   /api/nutrition/generate  # Generate new plan
```

**[View All 61 APIs →](./API_OVERVIEW.md)**

---

## 🔑 **9. Get JWT Token for Testing**

### **Using cURL:**

```bash
# 1. Request OTP
curl -X POST http://localhost:3000/api/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890"}'

# 2. Verify OTP (use code from SMS or check console logs)
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890", "otp": "123456"}'

# Response will include JWT token
```

### **Use Token in Requests:**

```bash
curl http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 📁 **10. Project Structure**

```
backend/
├── src/
│   ├── controllers/        # Request handlers
│   ├── services/           # Business logic
│   ├── routes/             # API routes
│   ├── middleware/         # Auth, validation
│   ├── database/           # DB connection
│   ├── sockets/            # WebSocket handlers
│   └── utils/              # Helper functions
│
├── __tests__/              # Test files
├── migrations/             # Database migrations
├── .env                    # Environment variables
└── package.json
```

---

## 🐛 **Troubleshooting**

### **Database Connection Error:**

```bash
# Check PostgreSQL is running
sudo service postgresql status

# Check connection string
psql postgresql://postgres:password@localhost:5432/ash_fitness
```

### **Port Already in Use:**

```bash
# Change port in .env
PORT=3001

# Or kill process on port 3000
lsof -ti:3000 | xargs kill
```

### **Migration Errors:**

```bash
# Reset database (WARNING: deletes all data)
npm run db:reset

# Then run migrations again
npm run migrate
```

---

## 🔗 **Next Steps**

1. ✅ **[Read Complete System Overview](./COMPLETE_SYSTEM_OVERVIEW.md)**
2. ✅ **[View API Documentation](./API_OVERVIEW.md)**
3. ✅ **[Learn About Workout System](./WORKOUT_SYSTEM_GUIDE.md)**
4. ✅ **[Setup Production Deployment](./PRODUCTION_READINESS_CHECKLIST.md)**

---

## 📞 **Need Help?**

- Check [Complete System Overview](./COMPLETE_SYSTEM_OVERVIEW.md)
- Review [Testing Guide](./TESTING.md)
- See [Production Checklist](./PRODUCTION_READINESS_CHECKLIST.md)

---

**Status:** ✅ Backend should now be running!  
**Access:** http://localhost:3000  
**Ready for:** Flutter & React integration

---

*Quick Start Guide*  
*Last Updated: December 2024*

