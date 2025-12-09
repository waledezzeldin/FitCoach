# FitCoach+ v2.0 - API Specifications

## Document Information
- **Document**: REST API Endpoint Specifications
- **Version**: 2.0.0
- **Last Updated**: December 8, 2024
- **Purpose**: Complete API documentation for backend implementation

---

## Table of Contents

1. API Overview
2. Authentication Endpoints
3. User Management Endpoints
4. Intake Endpoints
5. Quota Management Endpoints
6. Workout Endpoints
7. Nutrition Endpoints
8. Messaging Endpoints
9. Video Call Endpoints
10. Rating Endpoints
11. E-Commerce Endpoints
12. Progress Tracking Endpoints
13. Coach Endpoints
14. Admin Endpoints
15. File Upload Endpoints

---

## 1. API Overview

### Base URL
```
Production: https://api.fitcoachplus.com/v2
Staging: https://api-staging.fitcoachplus.com/v2
Development: http://localhost:3000/api/v2
```

### Authentication
- **Method**: Bearer token (JWT)
- **Header**: `Authorization: Bearer {token}`
- **Token Expiry**: 30 days
- **Refresh**: Automatic on valid request

### Common Response Format

**Success Response**:
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully"
}
```

**Error Response**:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { ... }
  }
}
```

### HTTP Status Codes
- `200` - OK (Success)
- `201` - Created
- `400` - Bad Request (Validation error)
- `401` - Unauthorized (Missing/invalid token)
- `403` - Forbidden (Insufficient permissions)
- `404` - Not Found
- `429` - Too Many Requests (Rate limit exceeded)
- `500` - Internal Server Error

### Rate Limiting
- **General**: 100 requests per minute per user
- **OTP Send**: 3 requests per hour per phone number
- **File Upload**: 10 uploads per minute per user

---

## 2. Authentication Endpoints

### 2.1 Send OTP

**Endpoint**: `POST /auth/send-otp`

**Description**: Generate and send 6-digit OTP to user's phone via SMS.

**Request Body**:
```json
{
  "phoneNumber": "+966512345678"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "otpSent": true,
    "expiresIn": 300,
    "message": "OTP sent successfully"
  }
}
```

**Errors**:
- `400` - Invalid phone number format
- `429` - Rate limit exceeded (3 per hour)
- `500` - SMS delivery failed

**Rate Limit**: 3 requests per hour per phone number

---

### 2.2 Verify OTP

**Endpoint**: `POST /auth/verify-otp`

**Description**: Verify OTP code and authenticate user.

**Request Body**:
```json
{
  "phoneNumber": "+966512345678",
  "otpCode": "123456"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "phoneNumber": "+966512345678",
      "name": "Ahmed",
      "subscriptionTier": "Freemium",
      "isNewUser": false
    }
  }
}
```

**Errors**:
- `400` - Invalid OTP code
- `401` - OTP expired
- `429` - Too many attempts (3 max)

---

### 2.3 Logout

**Endpoint**: `POST /auth/logout`

**Description**: Invalidate current JWT token.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 3. User Management Endpoints

### 3.1 Get Current User

**Endpoint**: `GET /users/me`

**Description**: Get authenticated user's profile.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "phoneNumber": "+966512345678",
    "name": "Ahmed",
    "email": "ahmed@example.com",
    "age": 28,
    "weight": 75.5,
    "height": 175,
    "gender": "male",
    "workoutFrequency": 4,
    "workoutLocation": "gym",
    "experienceLevel": "intermediate",
    "mainGoal": "muscle_gain",
    "injuries": ["knee"],
    "subscriptionTier": "Premium",
    "subscriptionStartDate": "2024-01-15T00:00:00Z",
    "coachId": "uuid",
    "hasCompletedSecondIntake": true,
    "fitnessScore": 65,
    "fitnessScoreUpdatedBy": "auto",
    "fitnessScoreLastUpdated": "2024-01-15T10:30:00Z",
    "createdAt": "2024-01-15T00:00:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

---

### 3.2 Update User Profile

**Endpoint**: `PUT /users/me`

**Description**: Update user profile fields.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "name": "Ahmed Ali",
  "email": "ahmed.ali@example.com",
  "weight": 74.5,
  "workoutFrequency": 5
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Ahmed Ali",
    "email": "ahmed.ali@example.com",
    "weight": 74.5,
    "workoutFrequency": 5,
    "updatedAt": "2024-01-21T10:00:00Z"
  }
}
```

---

### 3.3 Delete User Account

**Endpoint**: `DELETE /users/me`

**Description**: Permanently delete user account and all associated data.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```

---

## 4. Intake Endpoints

### 4.1 Submit First Intake

**Endpoint**: `POST /users/me/intake/first`

**Description**: Submit initial 3-question intake (all users).

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "gender": "male",
  "mainGoal": "muscle_gain",
  "workoutLocation": "gym"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "completed": true,
    "nextStep": "secondIntake"
  }
}
```

**Validation**:
- `gender`: Required, enum ['male', 'female', 'other']
- `mainGoal`: Required, enum ['fat_loss', 'muscle_gain', 'general_fitness']
- `workoutLocation`: Required, enum ['home', 'gym']

---

### 4.2 Submit Second Intake (Premium+ Only)

**Endpoint**: `POST /users/me/intake/second`

**Description**: Submit detailed 6-question intake (Premium/Smart Premium only).

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "age": 28,
  "weight": 75.5,
  "height": 175,
  "experienceLevel": "intermediate",
  "workoutFrequency": 4,
  "injuries": ["knee"]
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "completed": true,
    "fitnessScore": 65,
    "fitnessScoreLevel": "Advanced",
    "nextStep": "home"
  }
}
```

**Errors**:
- `403` - Freemium users not allowed (must upgrade)

**Validation**:
- `age`: Required, number, 13-120
- `weight`: Required, number, 30-300 kg
- `height`: Required, number, 100-250 cm
- `experienceLevel`: Required, enum ['beginner', 'intermediate', 'advanced']
- `workoutFrequency`: Required, number, 2-6
- `injuries`: Optional, array of enum ['shoulder', 'knee', 'lower_back', 'neck', 'ankle']

---

## 5. Quota Management Endpoints

### 5.1 Get Quota Usage

**Endpoint**: `GET /users/me/quota`

**Description**: Get current quota usage for authenticated user.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "tier": "Freemium",
    "messages": {
      "used": 8,
      "total": 20,
      "remaining": 12,
      "percentage": 40
    },
    "calls": {
      "used": 1,
      "total": 1,
      "remaining": 0,
      "percentage": 100
    },
    "resetDate": "2024-02-01T00:00:00Z",
    "lastResetAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### 5.2 Check Quota (Before Action)

**Endpoint**: `POST /users/me/quota/check`

**Description**: Check if action is allowed within quota limits.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "action": "message"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "allowed": true,
    "remaining": 12,
    "showWarning": false
  }
}
```

**Or if quota exceeded**:
```json
{
  "success": false,
  "data": {
    "allowed": false,
    "remaining": 0,
    "reason": "Message quota exceeded",
    "showUpgradePrompt": true
  }
}
```

**Request Parameters**:
- `action`: enum ['message', 'call', 'attachment']

---

## 6. Workout Endpoints

### 6.1 Get Current Workout Plan

**Endpoint**: `GET /users/me/workouts/current`

**Description**: Get user's active workout plan.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "8-Week Muscle Building Program",
    "durationWeeks": 8,
    "workoutsPerWeek": 4,
    "currentWeek": 2,
    "currentDay": 3,
    "todayWorkout": {
      "id": "uuid",
      "name": "Lower Body Strength",
      "dayNumber": 3,
      "weekNumber": 2,
      "estimatedDuration": 45,
      "exercises": [
        {
          "id": "uuid",
          "exerciseId": "uuid",
          "exerciseName": "Barbell Squat",
          "muscleGroup": "legs",
          "sets": 4,
          "reps": "8-10",
          "restTime": 120,
          "isSubstituted": false,
          "completedSets": 0,
          "isCompleted": false
        }
      ]
    }
  }
}
```

---

### 6.2 Get Workout by ID

**Endpoint**: `GET /workouts/{workoutId}`

**Description**: Get specific workout details.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Upper Body Strength",
    "dayNumber": 1,
    "weekNumber": 2,
    "estimatedDuration": 50,
    "exercises": [ ... ]
  }
}
```

---

### 6.3 Complete Workout

**Endpoint**: `POST /workouts/{workoutId}/complete`

**Description**: Mark workout as completed and log details.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "completedAt": "2024-01-21T10:30:00Z",
  "actualDuration": 48,
  "exercises": [
    {
      "exerciseId": "uuid",
      "completedSets": 4,
      "weight": 80,
      "notes": "Felt strong today"
    }
  ]
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "workoutId": "uuid",
    "completed": true,
    "caloriesBurned": 340,
    "newPersonalRecords": []
  }
}
```

---

### 6.4 Substitute Exercise (Injury-Based)

**Endpoint**: `POST /workouts/{workoutId}/exercises/{exerciseId}/substitute`

**Description**: Replace exercise with safe alternative due to injury.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "newExerciseId": "uuid",
  "reason": "Knee injury - reduced loading while maintaining quad stimulus"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "substituted": true,
    "originalExercise": "Barbell Squat",
    "newExercise": "Leg Extension",
    "reason": "Knee injury - reduced loading while maintaining quad stimulus"
  }
}
```

---

### 6.5 Get Exercise Alternatives

**Endpoint**: `GET /exercises/{exerciseId}/alternatives`

**Description**: Get safe alternative exercises based on user injuries.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
- `injuryArea`: enum ['shoulder', 'knee', 'lower_back', 'neck', 'ankle']
- `targetMuscleGroup`: string (optional)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "originalExercise": {
      "id": "uuid",
      "name": "Barbell Squat"
    },
    "alternatives": [
      {
        "id": "uuid",
        "name": "Leg Extension",
        "muscleGroup": "quadriceps",
        "reason": "Reduced knee loading while maintaining quad stimulus",
        "defaultSets": 3,
        "defaultReps": "10-12",
        "defaultRestTime": 60
      }
    ]
  }
}
```

---

## 7. Nutrition Endpoints

### 7.1 Get Nutrition Plan

**Endpoint**: `GET /users/me/nutrition/plan`

**Description**: Get user's active nutrition plan.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Muscle Building Nutrition Plan",
    "dailyCalories": 2800,
    "proteinGrams": 150,
    "carbGrams": 350,
    "fatGrams": 78,
    "mealsPerDay": 5,
    "generatedAt": "2024-01-15T00:00:00Z",
    "expiresAt": "2024-01-22T00:00:00Z",
    "isExpired": false,
    "daysLeft": 3,
    "meals": [ ... ]
  }
}
```

---

### 7.2 Generate Nutrition Plan

**Endpoint**: `POST /users/me/nutrition/generate`

**Description**: Generate new personalized nutrition plan.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "preferences": {
    "dietType": "standard",
    "allergies": ["nuts", "dairy"],
    "mealsPerDay": 5,
    "includeSnacks": true
  }
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Custom Nutrition Plan",
    "dailyCalories": 2800,
    "expiresAt": "2024-01-29T00:00:00Z",
    "trialDays": 7
  }
}
```

**Note**: Freemium users get 7-day trial from generation date.

---

### 7.3 Check Nutrition Access (v2.0)

**Endpoint**: `GET /users/me/nutrition/access`

**Description**: Check if user has nutrition access (for Freemium expiry).

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "hasAccess": true,
    "isExpired": false,
    "daysLeft": 3,
    "expiresAt": "2024-01-24T00:00:00Z",
    "tier": "Freemium"
  }
}
```

**Or if expired**:
```json
{
  "success": true,
  "data": {
    "hasAccess": false,
    "isExpired": true,
    "daysLeft": 0,
    "reason": "Trial period ended. Upgrade to continue.",
    "tier": "Freemium"
  }
}
```

---

### 7.4 Log Meal

**Endpoint**: `POST /meals/{mealId}/log`

**Description**: Mark meal as consumed.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "loggedAt": "2024-01-21T12:30:00Z"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "mealId": "uuid",
    "logged": true,
    "loggedAt": "2024-01-21T12:30:00Z"
  }
}
```

---

## 8. Messaging Endpoints

### 8.1 Get Conversations

**Endpoint**: `GET /users/me/conversations`

**Description**: Get all conversations for authenticated user.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "coachId": "uuid",
      "coachName": "Coach Ahmed",
      "coachAvatar": "https://...",
      "lastMessageAt": "2024-01-21T10:00:00Z",
      "lastMessagePreview": "Sounds good! Let's schedule...",
      "unreadCount": 2,
      "isActive": true
    }
  ]
}
```

---

### 8.2 Get Messages

**Endpoint**: `GET /conversations/{conversationId}/messages`

**Description**: Get messages in a conversation.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
- `limit`: number (default: 50)
- `before`: timestamp (for pagination)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "conversationId": "uuid",
    "messages": [
      {
        "id": "uuid",
        "senderId": "uuid",
        "senderType": "user",
        "type": "text",
        "content": "Hi coach, can we schedule a call?",
        "isRead": true,
        "readAt": "2024-01-21T10:05:00Z",
        "createdAt": "2024-01-21T10:00:00Z"
      }
    ],
    "hasMore": false
  }
}
```

---

### 8.3 Send Message

**Endpoint**: `POST /conversations/{conversationId}/messages`

**Description**: Send a text or file message.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "type": "text",
  "content": "Hi coach, can we schedule a call?",
  "attachments": []
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "senderId": "uuid",
    "senderType": "user",
    "type": "text",
    "content": "Hi coach, can we schedule a call?",
    "createdAt": "2024-01-21T10:00:00Z"
  }
}
```

**Errors**:
- `403` - Message quota exceeded
- `403` - Attachments not allowed (Freemium/Premium)

**Note**: Quota check happens automatically before sending.

---

### 8.4 Mark Messages as Read

**Endpoint**: `POST /conversations/{conversationId}/messages/read`

**Description**: Mark all messages in conversation as read.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "conversationId": "uuid",
    "markedRead": 5
  }
}
```

---

## 9. Video Call Endpoints

### 9.1 Schedule Video Call

**Endpoint**: `POST /video-calls`

**Description**: Schedule a video call with coach.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "coachId": "uuid",
  "scheduledAt": "2024-01-25T14:00:00Z",
  "duration": 25,
  "notes": "Want to review workout form"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "coachId": "uuid",
    "scheduledAt": "2024-01-25T14:00:00Z",
    "duration": 25,
    "status": "scheduled",
    "meetingUrl": "https://video.fitcoachplus.com/room/xyz123"
  }
}
```

**Errors**:
- `403` - Video call quota exceeded

---

### 9.2 Get Scheduled Calls

**Endpoint**: `GET /users/me/video-calls`

**Description**: Get all video calls (past and upcoming).

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
- `status`: enum ['scheduled', 'completed', 'cancelled'] (optional)

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "coachId": "uuid",
      "coachName": "Coach Ahmed",
      "scheduledAt": "2024-01-25T14:00:00Z",
      "duration": 25,
      "status": "scheduled",
      "meetingUrl": "https://video.fitcoachplus.com/room/xyz123"
    }
  ]
}
```

---

### 9.3 Complete Video Call

**Endpoint**: `POST /video-calls/{callId}/complete`

**Description**: Mark video call as completed (auto-called by system).

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "actualDuration": 23,
  "endedAt": "2024-01-25T14:23:00Z"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "callId": "uuid",
    "status": "completed",
    "shouldPromptRating": true
  }
}
```

---

## 10. Rating Endpoints

### 10.1 Rate Coach (Post-Interaction)

**Endpoint**: `POST /coaches/{coachId}/ratings`

**Description**: Submit rating for coach after video call or messaging.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "rating": 5,
  "comment": "Very helpful and knowledgeable!",
  "interactionType": "video_call",
  "relatedVideoCallId": "uuid"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "rating": 5,
    "comment": "Very helpful and knowledgeable!",
    "createdAt": "2024-01-25T14:30:00Z"
  }
}
```

**Validation**:
- `rating`: Required, number, 1-5
- `comment`: Optional, string, max 500 chars
- `interactionType`: Required, enum ['video_call', 'messaging']

---

### 10.2 Rate Trainer (Workout Plan Quality)

**Endpoint**: `POST /ratings/trainer`

**Description**: Rate the quality of generated workout/nutrition plans.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "rating": 4,
  "comment": "Good plan but a bit repetitive",
  "planType": "workout",
  "relatedPlanId": "uuid"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "rating": 4,
    "planType": "workout",
    "createdAt": "2024-01-21T15:00:00Z"
  }
}
```

---

## 11. E-Commerce Endpoints

### 11.1 Get Products

**Endpoint**: `GET /products`

**Description**: Get all products in store.

**Query Parameters**:
- `category`: string (optional)
- `search`: string (optional)
- `limit`: number (default: 20)
- `offset`: number (default: 0)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "uuid",
        "name": "Whey Protein Isolate",
        "nameArabic": "بروتين واي معزول",
        "description": "High-quality whey protein...",
        "price": 199.99,
        "compareAtPrice": 249.99,
        "imageUrl": "https://...",
        "category": "supplement",
        "averageRating": 4.7,
        "totalRatings": 128,
        "isInStock": true
      }
    ],
    "total": 45,
    "limit": 20,
    "offset": 0
  }
}
```

---

### 11.2 Get Product by ID

**Endpoint**: `GET /products/{productId}`

**Description**: Get detailed product information.

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Whey Protein Isolate",
    "description": "High-quality whey protein isolate with 25g protein per serving...",
    "price": 199.99,
    "stockQuantity": 50,
    "additionalImages": ["https://...", "https://..."],
    "ratings": [ ... ]
  }
}
```

---

### 11.3 Create Order

**Endpoint**: `POST /orders`

**Description**: Create new order (checkout).

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "items": [
    {
      "productId": "uuid",
      "quantity": 2
    }
  ],
  "shippingAddress": {
    "fullName": "Ahmed Ali",
    "phoneNumber": "+966512345678",
    "addressLine1": "123 King Fahd Road",
    "city": "Riyadh",
    "postalCode": "12345",
    "country": "Saudi Arabia"
  },
  "paymentMethod": "credit_card"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "orderNumber": "ORD-2024-00123",
    "subtotal": 399.98,
    "tax": 59.99,
    "shippingFee": 20.00,
    "total": 479.97,
    "status": "processing",
    "paymentUrl": "https://pay.fitcoachplus.com/checkout/xyz123"
  }
}
```

---

### 11.4 Get Orders

**Endpoint**: `GET /users/me/orders`

**Description**: Get user's order history.

**Headers**:
```
Authorization: Bearer {token}
```

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "orderNumber": "ORD-2024-00123",
      "total": 479.97,
      "status": "delivered",
      "createdAt": "2024-01-15T00:00:00Z",
      "deliveredAt": "2024-01-18T14:30:00Z"
    }
  ]
}
```

---

## 12. Progress Tracking Endpoints

### 12.1 Log Weight Entry

**Endpoint**: `POST /users/me/progress/weight`

**Description**: Log daily weight measurement.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "weight": 74.5,
  "date": "2024-01-21",
  "notes": "Feeling lighter today"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "weight": 74.5,
    "date": "2024-01-21",
    "createdAt": "2024-01-21T08:00:00Z"
  }
}
```

---

### 12.2 Get Weight History

**Endpoint**: `GET /users/me/progress/weight`

**Description**: Get weight tracking history.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
- `startDate`: ISO date (optional)
- `endDate`: ISO date (optional)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "entries": [
      {
        "id": "uuid",
        "weight": 75.0,
        "date": "2024-01-15"
      },
      {
        "id": "uuid",
        "weight": 74.5,
        "date": "2024-01-21"
      }
    ],
    "stats": {
      "currentWeight": 74.5,
      "startingWeight": 76.0,
      "totalChange": -1.5,
      "weeklyAverage": -0.25,
      "trend": "improving"
    }
  }
}
```

---

### 12.3 Log InBody Scan (Premium+ Only)

**Endpoint**: `POST /users/me/progress/inbody`

**Description**: Log professional body composition scan.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "scanDate": "2024-01-21",
  "totalWeight": 74.5,
  "bodyFatMass": 12.3,
  "leanBodyMass": 62.2,
  "skeletalMuscleMass": 35.8,
  "bodyFatPercentage": 16.5,
  "basalMetabolicRate": 1650,
  "visceralFatLevel": 5
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "scanDate": "2024-01-21",
    "createdAt": "2024-01-21T10:00:00Z"
  }
}
```

**Errors**:
- `403` - Freemium users not allowed

---

## 13. Coach Endpoints

### 13.1 Get Public Coach Profile

**Endpoint**: `GET /coaches/{coachId}/public`

**Description**: Get public-facing coach profile (for browsing).

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Ahmed Al-Khalifa",
    "bio": "Certified personal trainer with 10 years experience...",
    "specialties": ["Weight Loss", "Strength Training"],
    "certifications": ["NASM-CPT", "Precision Nutrition L1"],
    "yearsExperience": 10,
    "profileImageUrl": "https://...",
    "averageRating": 4.8,
    "totalRatings": 156,
    "isAcceptingClients": true
  }
}
```

---

### 13.2 Assign Coach

**Endpoint**: `POST /users/me/coach`

**Description**: Assign a coach to current user.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "coachId": "uuid"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "coachId": "uuid",
    "coachName": "Ahmed Al-Khalifa",
    "assignedAt": "2024-01-21T10:00:00Z"
  }
}
```

---

## 14. Admin Endpoints

### 14.1 Get All Users (Admin Only)

**Endpoint**: `GET /admin/users`

**Description**: Get paginated list of all users.

**Headers**:
```
Authorization: Bearer {admin_token}
```

**Query Parameters**:
- `tier`: enum ['Freemium', 'Premium', 'Smart Premium'] (optional)
- `search`: string (optional)
- `limit`: number (default: 50)
- `offset`: number (default: 0)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "users": [ ... ],
    "total": 1248,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 14.2 Update User Subscription (Admin Override)

**Endpoint**: `PUT /admin/users/{userId}/subscription`

**Description**: Manually change user's subscription tier.

**Headers**:
```
Authorization: Bearer {admin_token}
```

**Request Body**:
```json
{
  "newTier": "Premium",
  "reason": "Promotional upgrade"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "previousTier": "Freemium",
    "newTier": "Premium",
    "updatedAt": "2024-01-21T10:00:00Z"
  }
}
```

---

## 15. File Upload Endpoints

### 15.1 Upload File (Premium+ Only for Chat Attachments)

**Endpoint**: `POST /files/upload`

**Description**: Upload file to cloud storage.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data**:
- `file`: File (required)
- `conversationId`: string (optional, for chat attachments)

**Response** (201):
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.fitcoachplus.com/files/user123/conv456/msg789_1234567890_image.jpg",
    "filename": "image.jpg",
    "size": 2048576,
    "contentType": "image/jpeg"
  }
}
```

**Errors**:
- `403` - Attachments not allowed (Freemium/Premium)
- `400` - Invalid file type
- `413` - File too large (>10MB for images, >5MB for PDFs)

**Allowed File Types**:
- Images: image/jpeg, image/png, image/heic
- Documents: application/pdf

---

## Error Codes Reference

| Code | Description |
|------|-------------|
| `AUTH_INVALID_PHONE` | Phone number format invalid |
| `AUTH_OTP_EXPIRED` | OTP code has expired |
| `AUTH_OTP_INVALID` | OTP code is incorrect |
| `AUTH_RATE_LIMIT` | Too many OTP requests |
| `QUOTA_EXCEEDED` | User quota limit reached |
| `TIER_INSUFFICIENT` | Feature requires higher tier |
| `NUTRITION_EXPIRED` | Freemium nutrition trial ended |
| `VALIDATION_ERROR` | Request validation failed |
| `NOT_FOUND` | Resource not found |
| `UNAUTHORIZED` | Missing or invalid auth token |
| `FORBIDDEN` | Insufficient permissions |
| `SERVER_ERROR` | Internal server error |

---

**End of API Specifications**

This document provides complete API specifications for implementing the FitCoach+ backend. All endpoints follow RESTful conventions and return consistent JSON responses.
