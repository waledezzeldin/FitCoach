# Admin Requirements - عاش (FitCoach+ v2.0)

## Document Information
- **User Type**: Platform Administrators
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## 1. Admin Persona

### Primary Persona: Platform Administrator
- **Role**: Operations Manager
- **Responsibilities**: User management, coach approval, system configuration, analytics monitoring
- **Goals**: Maintain platform health, ensure quality, drive growth
- **Tech Savviness**: High (familiar with admin dashboards, data analysis)

---

## 2. Admin Dashboard Screens (8 Screens)

### 2.1 Main Dashboard

#### Purpose
High-level overview of platform health with key metrics and quick access to all admin functions.

#### Requirements

**FR-ADMIN-MAIN-01: Key Metrics Cards**
- Total Users (with growth % vs last month)
- Active Coaches count
- Monthly Recurring Revenue (MRR)
- Active Subscriptions by tier breakdown
- Today's registrations
- Support tickets pending

**FR-ADMIN-MAIN-02: Revenue Chart**
- Line chart showing MRR over last 12 months
- Breakdown by subscription tier
- Revenue growth trend
- Annotations for major events

**FR-ADMIN-MAIN-03: User Growth Chart**
- New registrations per day (last 30 days)
- Tier distribution over time
- Conversion funnel metrics

**FR-ADMIN-MAIN-04: Recent Activity Feed**
- Latest user registrations
- New coach applications
- Subscription changes
- Support tickets created
- Real-time updates

**FR-ADMIN-MAIN-05: Quick Actions**
- "Review Pending Coaches" button (with badge count)
- "View Support Tickets" button
- "System Settings" button
- "Generate Report" button

---

### 2.2 User Management Screen

#### Purpose
Manage all end users (fitness enthusiasts) with CRUD operations, search, and filtering.

#### Requirements

**FR-ADMIN-USER-01: User Table**
- Paginated table showing all users
- Columns:
  - User ID
  - Name
  - Phone Number
  - Subscription Tier (badge)
  - Registration Date
  - Last Active
  - Status (Active/Suspended)
  - Actions (View/Edit/Suspend)
- Sort by any column
- Items per page: 25/50/100

**FR-ADMIN-USER-02: Search & Filter**
- Search by:
  - Name (fuzzy search)
  - Phone number
  - User ID
- Filter by:
  - Subscription tier (Freemium/Premium/Smart Premium)
  - Status (Active/Suspended)
  - Registration date range
  - Last active date range
- Advanced filter combinations

**FR-ADMIN-USER-03: User Detail View**
- Click user to open detailed modal/page:
  - Full profile information
  - First & second intake responses
  - Assigned coach details
  - Subscription history
  - Quota usage (messages, calls)
  - Workout completion stats
  - Message history count
  - Video call history
- Edit button for each section

**FR-ADMIN-USER-04: Edit User**
- Modify user details:
  - Name
  - Gender
  - Main goal
  - Workout location
  - Age, weight, height (if Premium+)
  - Injuries
  - Fitness score (with reason for change)
- Save changes with audit log

**FR-ADMIN-USER-05: Subscription Override**
- Change user's subscription tier
- Options:
  - Upgrade user (Freemium → Premium → Smart Premium)
  - Downgrade user
  - Grant free Premium (promotional)
  - Set custom expiry date
- Reason field (required for audit)
- Immediate effect or scheduled change

**FR-ADMIN-USER-06: Coach Reassignment**
- Change assigned coach for user
- Select from active coaches dropdown
- Reason for reassignment
- Notify user and new coach
- Transfer conversation history

**FR-ADMIN-USER-07: Account Suspension**
- Suspend user account (violations, fraud)
- Reason required (dropdown: Abuse, Payment Fraud, Terms Violation, Other)
- Suspension period (temporary or permanent)
- Notify user via SMS/email
- Option to reactivate suspended accounts

**FR-ADMIN-USER-08: Bulk Actions**
- Select multiple users (checkboxes)
- Bulk operations:
  - Export to CSV
  - Send notification
  - Change subscription tier (mass upgrade for promotion)
  - Assign to coach

**FR-ADMIN-USER-09: Data Export**
- Export user data to CSV/Excel
- Columns customization
- Filtered export (only users matching current filters)
- Full export (all users)

#### User Scenarios

**Scenario 1: Handling User Complaint**
```
Admin receives support ticket: "User can't access nutrition plan"
→ Opens User Management screen
→ Searches phone number: +966512345678
→ Finds user: Ahmed
→ Views details:
   - Tier: Freemium
   - Nutrition access: Expired (7-day trial ended 3 days ago)
→ Understands issue: trial expired
→ Options:
   A) Tell user to upgrade (correct business logic)
   B) Grant 7-day extension (customer service gesture)
→ Admin chooses B
→ Clicks "Edit User"
→ Extends nutrition access by 7 days
→ Adds note: "Customer service extension due to support ticket #1234"
→ Saves changes
→ User can now access nutrition
→ Admin responds to ticket: "Access extended for 7 days as courtesy"
```

**Scenario 2: Promotional Upgrade**
```
Admin wants to reward top 10 active users with free Premium for 1 month
→ Opens User Management
→ Filters: Tier = Freemium, Last Active = Last 7 days
→ Sorts by: Workout Completion Rate (descending)
→ Selects top 10 users (checkboxes)
→ Bulk Action: "Upgrade Subscription"
→ Sets: Tier = Premium, Duration = 1 month, Reason = "Top User Reward"
→ Confirms action
→ 10 users upgraded
→ System sends congratulatory messages
→ Users receive Premium features immediately
```

---

### 2.3 Coach Management Screen

#### Purpose
Manage fitness coaches including approval process, performance monitoring, and assignment management.

#### Requirements

**FR-ADMIN-COACH-01: Coach Application Queue**
- Separate tab for "Pending Approval" coaches
- Shows:
  - Applicant name
  - Certifications submitted
  - Years of experience
  - Application date
  - Application materials (resume, certificates)
- Actions: Approve, Reject, Request More Info

**FR-ADMIN-COACH-02: Active Coaches Table**
- Table of all approved coaches
- Columns:
  - Coach ID
  - Name
  - Certifications
  - Assigned Clients count
  - Average Rating (stars)
  - Active Since date
  - Status (Active/On Leave/Suspended)
  - Actions (View/Edit/Suspend)

**FR-ADMIN-COACH-03: Coach Detail View**
- Full coach profile:
  - Personal information
  - Certifications and credentials
  - Specializations
  - Bio and coaching philosophy
  - Assigned clients list
  - Performance metrics:
    - Average rating
    - Response time
    - Client retention rate
    - Revenue generated
  - Message/call activity stats
  - Ratings and feedback from clients

**FR-ADMIN-COACH-04: Approve Coach Application**
- Review application materials
- Verify certifications (manual or API)
- Set coach tier/level (Junior/Senior/Master)
- Assign initial client load limit
- Send approval email
- Coach gains access to coach dashboard

**FR-ADMIN-COACH-05: Client Assignment**
- Assign new user to coach
- Criteria for auto-assignment:
  - Coach with lowest client load
  - Coach specialization matching user goal
  - Coach availability
  - Language preference
- Manual assignment override
- Reassignment capability

**FR-ADMIN-COACH-06: Coach Performance Monitoring**
- Flag coaches with:
  - Low ratings (< 3.5 stars)
  - Slow response time (> 8 hours average)
  - High client churn (> 20% monthly)
  - Inactive (no activity in 7 days)
- Review and take action:
  - Send warning
  - Provide training
  - Suspend account
  - Terminate contract

**FR-ADMIN-COACH-07: Coach Suspension**
- Suspend for violations, quality issues, or inactivity
- Reason required
- Reassign all clients to other coaches
- Notify coach
- Option to reactivate

#### User Scenarios

**Scenario 1: Approving New Coach**
```
Admin reviews pending coach applications
→ Opens Coach Management screen
→ Tabs: "Pending Approval" (2 applications)
→ Clicks on "Sarah Ahmed"
→ Views application:
   - ACE Certified Personal Trainer (certificate attached)
   - 5 years experience
   - Specialization: Weight Loss, Nutrition
   - Resume shows credible gyms
→ Clicks "Verify Certificate" → Checks with ACE database → Valid
→ Clicks "Approve"
→ Modal:
   - Set Coach Level: Senior
   - Max Client Load: 15
   - Specializations: [Weight Loss] [Nutrition] [Women's Fitness]
→ Confirms approval
→ Sarah receives email: "Welcome! Your coach account is active"
→ Sarah logs in to coach dashboard
```

---

### 2.4 Content Management Screen

#### Purpose
Manage exercise database, meal database, and store products with CRUD operations.

#### Requirements

**FR-ADMIN-CONTENT-01: Exercise Library Management**
- Table of all exercises (150+)
- Columns:
  - Exercise Name (EN/AR)
  - Category (Strength, Cardio, Flexibility)
  - Target Muscle Group
  - Equipment Required
  - Difficulty Level
  - Injury Contraindications
  - Status (Active/Draft/Archived)
- Add new exercise form
- Edit existing exercise
- Upload exercise photos/videos
- Set injury warnings

**FR-ADMIN-CONTENT-02: Meal Database Management**
- Table of all meals
- Columns:
  - Meal Name (EN/AR)
  - Meal Type (Breakfast, Lunch, Dinner, Snack)
  - Calories
  - Protein/Carbs/Fats
  - Cuisine Type
  - Photo
- Add new meal
- Edit recipe, macros, instructions
- Upload meal photos
- Set dietary tags (Vegetarian, High-Protein, etc.)

**FR-ADMIN-CONTENT-03: Store Product Management**
- Table of products
- Columns:
  - Product Name
  - Category (Equipment, Supplements, Apparel)
  - Price (SAR)
  - Stock Count
  - Sales Count
  - Rating
  - Status (Active/Out of Stock/Discontinued)
- Add new product
- Edit details, pricing, stock
- Upload product photos (multiple)
- Manage reviews (moderate, delete inappropriate)

#### User Scenarios

**Scenario 1: Adding New Exercise**
```
Admin wants to add "Kettlebell Swing" exercise
→ Opens Content Management → Exercise Tab
→ Clicks "Add New Exercise"
→ Fills form:
   - Name (EN): Kettlebell Swing
   - Name (AR): أرجحة الكيتلبل
   - Category: Strength
   - Muscle Groups: [Glutes] [Hamstrings] [Core]
   - Equipment: Kettlebell
   - Difficulty: Intermediate
   - Instructions (EN): Step-by-step guide
   - Instructions (AR): دليل خطوة بخطوة
   - Injury Warnings: [Lower Back] (if improper form)
   - Safe for: Shoulder, Knee, Neck, Ankle injuries
→ Uploads demo video
→ Uploads thumbnail photo
→ Status: Active
→ Saves exercise
→ Exercise now available in library for coaches
```

---

### 2.5 Subscription Management Screen

#### Purpose
Monitor subscriptions, process refunds, and manage tier configurations.

#### Requirements

**FR-ADMIN-SUB-01: Active Subscriptions**
- Table of all active subscriptions
- Columns:
  - User Name
  - Phone Number
  - Tier (Freemium/Premium/Smart Premium)
  - Start Date
  - Next Billing Date
  - MRR Contribution
  - Payment Method
  - Status (Active/Past Due/Canceled)
- Filter by tier, status, date range

**FR-ADMIN-SUB-02: Subscription Details**
- View individual subscription:
  - User profile
  - Payment history
  - Upgrade/downgrade history
  - Usage stats (messages, calls, nutrition access)
  - Invoice history

**FR-ADMIN-SUB-03: Cancellation Management**
- View canceled subscriptions
- Reason for cancellation (if provided)
- Cancellation date
- Option to re-activate (win-back)
- Export churn data for analysis

**FR-ADMIN-SUB-04: Refund Processing**
- Issue refunds for specific billing periods
- Refund reasons dropdown
- Partial or full refund
- Automatic tier adjustment
- Notify user of refund

**FR-ADMIN-SUB-05: Tier Configuration**
- Modify tier pricing (requires approval)
- Update quota limits:
  - Messages per month
  - Video calls per month
  - Call duration
  - Feature access flags
- Changes take effect next billing cycle
- Log all changes for audit

#### User Scenarios

**Scenario 1: Processing Refund Request**
```
User requests refund for Premium subscription (not satisfied)
→ Admin opens Subscription Management
→ Searches user: Ahmed
→ Views subscription:
   - Premium tier, started 10 days ago
   - Billed $19.99 on Dec 1st
→ Admin reviews support ticket: "Didn't use much, want refund"
→ Admin decides: Partial refund (pro-rated for unused days)
→ Clicks "Issue Refund"
→ Selects: Refund Amount = $13.33 (20 days unused)
→ Reason: "Customer request - unused period"
→ Confirms refund
→ System processes refund via Stripe
→ User's tier changes to Freemium immediately
→ User notified: "Refund processed, $13.33 will appear in 5-7 days"
```

---

### 2.6 System Settings Screen

#### Purpose
Configure platform-wide settings, feature flags, and quota limits.

#### Requirements

**FR-ADMIN-SETTINGS-01: Tier Quota Configuration**
- Edit quota limits for each tier:
  - Freemium: Messages, Calls, Nutrition Trial Days
  - Premium: Messages, Calls
  - Smart Premium: Calls (messages unlimited)
- Change takes effect for new users immediately
- Existing users unaffected until next reset

**FR-ADMIN-SETTINGS-02: Feature Flags**
- Toggle features on/off globally:
  - Chat attachments
  - Video calls
  - Store
  - InBody tracking
  - Injury substitution engine
  - Coach ratings
- Emergency kill switches for problematic features

**FR-ADMIN-SETTINGS-03: System Announcements**
- Create platform-wide announcements
- Display in all user types (users, coaches, admins)
- Types: Info, Warning, Critical
- Schedule announcement:
  - Start date/time
  - End date/time
  - Auto-dismiss option
- Example: "Scheduled maintenance on Dec 20th, 2 AM - 4 AM"

**FR-ADMIN-SETTINGS-04: Coach Assignment Rules**
- Configure auto-assignment algorithm:
  - Max clients per coach
  - Load balancing strategy (round-robin, lowest load, specialization match)
  - Prioritize coach tier
- Test assignment algorithm

**FR-ADMIN-SETTINGS-05: Email/SMS Templates**
- Edit notification templates:
  - Welcome email
  - OTP SMS
  - Subscription confirmation
  - Payment failed
  - Coach assignment
- Support variables ({{userName}}, {{otpCode}}, etc.)
- Preview templates

---

### 2.7 Analytics Dashboard

#### Purpose
Business intelligence with charts, trends, and insights for decision-making.

#### Requirements

**FR-ADMIN-ANALYTICS-01: User Metrics**
- Total Users (all time)
- Active Users (last 30 days)
- New Registrations (daily, weekly, monthly trend)
- Tier Distribution pie chart
- User Growth chart (12 months)

**FR-ADMIN-ANALYTICS-02: Revenue Metrics**
- MRR (current month)
- MRR Growth trend (12 months)
- Revenue by Tier breakdown
- Average Revenue Per User (ARPU)
- Customer Lifetime Value (LTV) estimate
- Churn rate

**FR-ADMIN-ANALYTICS-03: Engagement Metrics**
- Daily/Weekly Active Users (DAU/WAU)
- Workout Completion Rate
- Average Workouts per User per Week
- Message Activity (messages sent per day)
- Video Calls Conducted (per day/week)

**FR-ADMIN-ANALYTICS-04: Conversion Metrics**
- Freemium to Premium conversion rate
- Premium to Smart Premium conversion rate
- Time to conversion (days from registration to upgrade)
- Conversion funnel visualization

**FR-ADMIN-ANALYTICS-05: Coach Metrics**
- Total Active Coaches
- Average Clients per Coach
- Coach Rating Distribution
- Coach Utilization Rate (assigned clients vs capacity)

**FR-ADMIN-ANALYTICS-06: Export & Reports**
- Export any chart data to CSV
- Generate PDF reports
- Schedule automated reports (daily/weekly/monthly)
- Email reports to stakeholders

---

### 2.8 Audit Logs Screen

#### Purpose
Track all admin actions, system events, and changes for compliance and debugging.

#### Requirements

**FR-ADMIN-AUDIT-01: Activity Log Table**
- Table of all logged events
- Columns:
  - Timestamp
  - Admin User (who performed action)
  - Action Type (User Edit, Subscription Change, Coach Approval, etc.)
  - Target (User ID, Coach ID, Product ID)
  - Details (JSON of changes)
  - IP Address
- Sort by date (newest first)
- Paginated (50 per page)

**FR-ADMIN-AUDIT-02: Filter Logs**
- Filter by:
  - Date range
  - Admin user
  - Action type
  - Target entity type (User, Coach, Subscription)
- Search by User ID, Coach ID, or keywords

**FR-ADMIN-AUDIT-03: Log Details**
- Click log entry to view full details:
  - Before state (JSON)
  - After state (JSON)
  - Diff view (highlight changes)
  - Reason (if provided)
  - Related entities

**FR-ADMIN-AUDIT-04: Export Logs**
- Export filtered logs to CSV
- Full export (all logs) for compliance
- Retention policy: Logs kept for 2 years

---

## 3. Admin Acceptance Criteria

**AC-ADMIN-01: User Subscription Override**
- GIVEN admin views user in User Management
- WHEN admin changes subscription tier from Freemium to Premium
- THEN user's tier updates immediately
- AND user gains Premium features instantly
- AND quota limits update
- AND audit log records change with reason

**AC-ADMIN-02: Coach Approval**
- GIVEN pending coach application
- WHEN admin reviews and approves
- THEN coach receives approval email
- AND coach can log in to coach dashboard
- AND coach is available for client assignments
- AND audit log records approval

**AC-ADMIN-03: Content Addition**
- GIVEN admin adds new exercise to library
- WHEN exercise is saved as "Active"
- THEN exercise appears in exercise library for all coaches
- AND coaches can add to workout plans
- AND exercise is translatable (EN/AR)

**AC-ADMIN-04: System Settings Change**
- GIVEN admin changes Freemium message quota from 20 to 25
- WHEN change is saved
- THEN new Freemium users get 25 messages
- AND existing users keep current quota until next reset
- AND audit log records change

---

## 4. Admin Security Requirements

**SEC-ADMIN-01: Authentication**
- Admin accounts require strong password (min 12 chars, uppercase, lowercase, number, symbol)
- Two-factor authentication (2FA) mandatory for admin access
- Session timeout after 30 minutes inactivity

**SEC-ADMIN-02: Authorization**
- Role-based access control (RBAC):
  - Super Admin: All permissions
  - Operations Admin: User/Coach management, no System Settings
  - Content Admin: Content Management only
  - Support Admin: View-only access, can edit user details for support

**SEC-ADMIN-03: Audit Trail**
- All admin actions logged with timestamp, user, IP address
- Logs immutable (cannot be deleted or edited)
- Critical actions (subscription changes, coach suspensions) send email alerts to super admin

**SEC-ADMIN-04: Data Access**
- Admins cannot view user messages content (privacy)
- Admins can view metadata (message count, timestamps)
- Sensitive PII (phone numbers) partially masked in some views
- Full access requires explicit permission and logged

---

## 5. Future Admin Features (Roadmap)

### Planned for v2.1
- Advanced fraud detection alerts
- A/B testing framework for pricing
- Automated coach performance reviews
- Customer support ticketing system integration
- Real-time notification system

### Under Consideration
- Machine learning insights for churn prediction
- Automated refund policy enforcement
- Multi-tenant support (white-label partners)
- API key management for integrations

---

**End of Admin Requirements Document**
