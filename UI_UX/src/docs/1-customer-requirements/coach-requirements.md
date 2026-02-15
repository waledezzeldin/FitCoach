# Coach Requirements - عاش (FitCoach+ v2.0)

## Document Information
- **User Type**: Fitness Coaches
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## 1. Coach Personas

### Primary Persona: Coach Sarah
- **Age**: 30-40
- **Certifications**: ACE Certified Personal Trainer, Nutrition Specialist
- **Experience**: 5+ years personal training
- **Client Load**: 10-15 active clients
- **Goals**: Grow client base, increase revenue, work efficiently
- **Pain Points**: Time-consuming admin work, scattered client data, manual plan creation
- **Tech Savviness**: Moderate (uses apps regularly)

### Secondary Persona: Coach Khaled
- **Age**: 25-35
- **Certifications**: NASM CPT
- **Experience**: 2-3 years coaching
- **Client Load**: 5-8 active clients
- **Goals**: Build reputation, learn from client interactions
- **Focus**: Younger demographic, athletic training

---

## 2. Coach Journey Map

### 2.1 Coach Onboarding Journey

```
Application → Admin Approval → Coach Intro → Setup Profile → 
First Client Assignment → Create First Plan → Start Coaching
```

### 2.2 Weekly Coaching Journey

```
Monday: Check Dashboard → Review Client Progress → Update Plans
Tuesday: Respond to Messages → Conduct Video Calls
Wednesday: Create New Workout Plans → Review Nutrition Requests
Thursday: Message Clients → Check Calendar
Friday: Conduct Video Calls → Review Earnings
```

---

## 3. Feature Requirements by Screen

### 3.1 Coach Dashboard

#### Purpose
Central hub for coaches to view all clients, recent activity, and quick access to coaching tools.

#### Requirements

**FR-COACH-DASH-01: Welcome Header**
- Display: "Welcome, Coach [Name]"
- Quick stats overview:
  - Total active clients
  - Messages pending response
  - Upcoming video calls today
  - Monthly earnings (current month)

**FR-COACH-DASH-02: Client List**
- Display all assigned clients in grid/list
- Each client card shows:
  - Client photo and name
  - Subscription tier badge
  - Last interaction date
  - Unread message count (if any)
  - Quick action buttons: Message, View Profile
- Sort options:
  - Recently active
  - Alphabetical
  - Tier (Premium+ first)
- Search/filter by name

**FR-COACH-DASH-03: Recent Activity Feed**
- Timeline of client activities:
  - Workout completed
  - Message received
  - Video call scheduled
  - Plan generated
  - Rating received
- Click activity to view details
- Real-time updates

**FR-COACH-DASH-04: Quick Actions**
- "Create Workout Plan" button
- "Create Nutrition Plan" button
- "View Calendar" button
- "View Earnings" button
- "Settings" button

**FR-COACH-DASH-05: Performance Metrics**
- Average rating (1-5 stars)
- Total clients coached (lifetime)
- Response time average
- Video calls completed this month
- Client satisfaction score

**FR-COACH-DASH-06: Client Requests**
- List of pending requests:
  - Custom workout plan requests
  - Nutrition plan requests
  - Video call booking requests
- Badge count on dashboard

#### User Scenarios

**Scenario 1: Morning Dashboard Check**
```
Coach Sarah logs in at 8 AM
→ Sees "Welcome, Coach Sarah"
→ Quick stats: 12 active clients, 5 unread messages, 2 calls today
→ Views activity feed:
   - "Ahmed completed Leg Day workout" (30 min ago)
   - "Fatimah sent a message" (1 hour ago)
   - "Khalid booked video call for 2 PM" (yesterday)
→ Clicks on Fatimah's message
→ Responds to question about form
→ Returns to dashboard
→ Checks calendar for today's calls
```

---

### 3.2 Coach Messaging Screen

#### Purpose
Communicate with assigned clients via real-time messaging with context about client's tier and quota.

#### Requirements

**FR-COACH-MSG-01: Client Selection**
- List of all clients on left sidebar (desktop) or top dropdown (mobile)
- Each client shows:
  - Photo, name, subscription tier
  - Unread message count
  - Last message timestamp
- Tap client to open conversation

**FR-COACH-MSG-02: Conversation Display**
- Chat interface showing:
  - Coach messages (left-aligned for LTR)
  - Client messages (right-aligned for LTR)
  - Timestamps
  - Read receipts
  - Message status

**FR-COACH-MSG-03: Client Context Panel**
- Shows client information:
  - Current subscription tier
  - Message quota remaining (e.g., "5/20 messages left")
  - Video call quota remaining
  - Days until quota reset
- Warning if client is near quota limit
- Info: "Client is Freemium - limited to 20 messages/month"

**FR-COACH-MSG-04: Send Messages**
- Text input field (unlimited characters)
- Send button
- Coaches have unlimited message sending (not limited by quota)
- Can send even if client has exceeded quota (but client can't reply)

**FR-COACH-MSG-05: Attachments**
- Coaches can send attachments regardless of client tier
- Attach images (workout form corrections)
- Attach PDFs (meal plans, guides)
- Note: Client can receive but may not be able to send (tier-dependent)

**FR-COACH-MSG-06: Quick Actions**
- "Create Workout Plan" button in message header
- "Create Nutrition Plan" button
- "View Client Profile" button
- "Schedule Video Call" button

**FR-COACH-MSG-07: Message Templates**
- Pre-written response templates:
  - Form correction advice
  - Motivation messages
  - Nutrition tips
  - Exercise alternatives
- Customizable templates
- Insert with one click

**FR-COACH-MSG-08: Client Progress Context**
- Sidebar shows recent client activity:
  - Last workout completed
  - Last nutrition log
  - Weight trend
  - Fitness score
- Helps coach give informed responses

#### User Scenarios

**Scenario 1: Responding to Form Question**
```
Coach sees notification: "Ahmed sent a message"
→ Opens messaging screen
→ Selects Ahmed from client list
→ Sees context: Premium tier, 45/200 messages used
→ Reads message: "I feel pain in my shoulder during overhead press"
→ Attaches image showing correct form
→ Types response: "Try this corrected form. Keep elbows slightly forward..."
→ Also suggests: "Let's substitute with landmine press for now"
→ Sends message
→ Updates Ahmed's injury profile: Add "shoulder" injury
```

**Scenario 2: Helping Freemium Client Near Quota**
```
Coach sees Fatimah has 2/20 messages remaining
→ Context panel shows warning: "Client near message quota"
→ Coach writes comprehensive response to answer multiple questions at once
→ Includes detailed guidance to reduce need for follow-ups
→ Adds note: "If you have more questions, consider upgrading to Premium for 200 messages/month"
→ Sends message
```

---

### 3.3 Workout Plan Builder

#### Purpose
Create customized workout plans for clients based on their profile, goals, and injuries.

#### Requirements

**FR-WO-BUILDER-01: Client Selection**
- Dropdown to select client
- Loads client profile:
  - Goal (fat loss/muscle gain/general fitness)
  - Experience level
  - Workout location (home/gym)
  - Injuries
  - Workout frequency (days/week)

**FR-WO-BUILDER-02: Plan Template**
- Option to start from template or blank
- Templates categorized by:
  - Goal (fat loss, muscle gain, general)
  - Experience (beginner, intermediate, advanced)
  - Location (home, gym)
- Templates include pre-populated exercises

**FR-WO-BUILDER-03: Week Structure**
- Define number of training days (2-6 days/week)
- Name each day (e.g., "Upper Body", "Leg Day", "Full Body")
- Set rest days

**FR-WO-BUILDER-04: Exercise Selection**
- Browse exercise library (150+ exercises)
- Search by:
  - Name
  - Muscle group
  - Equipment required
  - Difficulty level
- Filter out contraindicated exercises based on client's injuries
- Each exercise shows:
  - Name, photo, target muscles
  - Injury warnings (if applicable)

**FR-WO-BUILDER-05: Exercise Configuration**
- Drag and drop exercises to reorder
- Set for each exercise:
  - Sets (1-10)
  - Reps (1-50) or Duration (seconds)
  - Rest time (seconds)
  - Notes/instructions
- Duplicate exercises easily

**FR-WO-BUILDER-06: Injury-Aware Recommendations**
- When selecting exercise, system shows warning if contraindicated
- Example: Selecting "Barbell Squat" for client with knee injury
  - Warning: "⚠️ This exercise may worsen knee injury"
  - Suggested alternatives automatically shown
- Coach can override if appropriate

**FR-WO-BUILDER-07: Plan Preview**
- Preview how plan will look to client
- Mobile and desktop views
- Test workout flow
- See estimated duration

**FR-WO-BUILDER-08: Save & Assign**
- Save as draft (not visible to client)
- Assign to client (immediately visible)
- Option to notify client via message
- Option to replace existing plan or add as new

**FR-WO-BUILDER-09: Plan Templates Management**
- Save custom plans as reusable templates
- Edit saved templates
- Delete templates
- Use template for multiple clients (with adjustments)

#### User Scenarios

**Scenario 1: Creating Beginner Home Workout**
```
Coach Sarah creates plan for new client
→ Selects client: "Ahmed" (Beginner, Home, Fat Loss Goal)
→ Chooses template: "Beginner Fat Loss - Home"
→ Template loads with 4 days:
   - Day 1: Full Body A
   - Day 2: Rest
   - Day 3: Full Body B
   - Day 4: Rest
   - Day 5: Full Body C
   - Day 6: Rest
   - Day 7: Rest
→ Reviews exercises for Day 1:
   1. Bodyweight Squats (3 x 15)
   2. Push-ups (3 x 10)
   3. Lunges (3 x 12 each leg)
   4. Plank (3 x 30 seconds)
→ Adjusts: Changes push-ups to knee push-ups (easier for beginner)
→ Adds notes: "Focus on form over speed"
→ Previews plan in mobile view
→ Assigns to Ahmed
→ Sends message: "Your personalized workout plan is ready!"
```

**Scenario 2: Injury-Aware Plan Modification**
```
Coach Khaled creates plan for client with knee injury
→ Selects client: "Sara" (Intermediate, Gym, Knee Injury)
→ Starts from blank
→ Creates Day 1: Leg Day
→ Attempts to add "Barbell Back Squat"
→ System shows warning: "⚠️ High knee compression - may worsen knee injury"
→ System suggests alternatives:
   - Leg Press (lower knee stress)
   - Bulgarian Split Squat (unilateral, controlled)
   - Box Squats (limited depth)
→ Coach selects "Leg Press" (4 x 12)
→ Continues building leg workout with safe exercises:
   - Hamstring Curls (4 x 15)
   - Romanian Deadlifts (4 x 10)
   - Calf Raises (4 x 20)
→ No injury warnings for these
→ Assigns plan
→ Client receives safe, effective leg workout
```

---

### 3.4 Nutrition Plan Builder

#### Purpose
Create personalized meal plans for clients based on their goals, preferences, and dietary restrictions.

#### Requirements

**FR-NUTR-BUILDER-01: Client Selection**
- Select client from dropdown
- Load client data:
  - Goal (fat loss/muscle gain/maintenance)
  - Age, weight, height
  - Activity level
  - Dietary preferences (if provided)

**FR-NUTR-BUILDER-02: Calorie Calculation**
- Auto-calculate TDEE based on client data
- Formula: TDEE = BMR x Activity Multiplier
- Adjust for goal:
  - Fat loss: TDEE - 500 cal (1 lb/week)
  - Muscle gain: TDEE + 300 cal
  - Maintenance: TDEE
- Override option for manual calorie setting

**FR-NUTR-BUILDER-03: Macro Distribution**
- Set macro percentages:
  - Protein (grams and %)
  - Carbs (grams and %)
  - Fats (grams and %)
- Default distributions by goal:
  - Fat Loss: 40% protein, 30% carbs, 30% fats
  - Muscle Gain: 30% protein, 45% carbs, 25% fats
  - Maintenance: 30% protein, 40% carbs, 30% fats
- Adjust sliders to customize

**FR-NUTR-BUILDER-04: Meal Planning**
- Define number of meals (3-6 per day)
- For each meal slot:
  - Select from meal database
  - View: Name, calories, macros, photo
  - Add custom meals
- Meal database categorized:
  - Breakfast
  - Lunch
  - Dinner
  - Snacks
- Filter by:
  - Cuisine (Arabic, Western, Asian)
  - Dietary preference (Vegetarian, High-protein, Low-carb)

**FR-NUTR-BUILDER-05: Daily Nutrition Summary**
- Shows total for day:
  - Total calories
  - Protein grams
  - Carb grams
  - Fat grams
- Visual indicator if totals match targets (green = on target)
- Adjust meals if over/under target

**FR-NUTR-BUILDER-06: Weekly Plan**
- Option to create 7-day meal plan
- Duplicate days easily
- Vary meals for dietary variety
- Swap meals between days

**FR-NUTR-BUILDER-07: Recipe Details**
- Each meal includes:
  - Ingredients list with quantities
  - Cooking instructions
  - Prep time and cook time
  - Serving size
  - Substitution options

**FR-NUTR-BUILDER-08: Save & Assign**
- Save as draft
- Assign to client
- Notify client via message
- Option to PDF export for client download

#### User Scenarios

**Scenario 1: Fat Loss Meal Plan**
```
Coach creates nutrition plan for client wanting to lose weight
→ Selects client: "Ahmed" (85 kg, Fat Loss Goal)
→ System calculates TDEE: 2500 cal
→ Adjusts for fat loss: 2000 cal/day
→ Sets macros: 200g protein, 150g carbs, 67g fats
→ Creates 5 meals:
   Breakfast: Omelette with veggies (350 cal, 30g protein)
   Snack: Greek yogurt with berries (150 cal, 15g protein)
   Lunch: Grilled chicken with rice (550 cal, 50g protein)
   Snack: Protein shake (200 cal, 25g protein)
   Dinner: Salmon with vegetables (750 cal, 60g protein)
→ Total: 2000 cal, 180g protein, 160g carbs, 70g fats
→ Slightly adjusts dinner to hit protein target exactly
→ Assigns plan to Ahmed
→ Ahmed's nutrition trial starts (7 days for Freemium, unlimited for Premium+)
```

---

### 3.5 Coach Calendar Screen

#### Purpose
View and manage scheduled video calls with clients.

#### Requirements

**FR-COACH-CAL-01: Calendar View**
- Month view showing all scheduled calls
- Week view (more detail)
- Day view (hourly slots)
- Highlighted dates with scheduled calls
- Color-coded by client (optional)

**FR-COACH-CAL-02: Upcoming Calls List**
- List of upcoming video calls (next 7 days)
- Each call shows:
  - Client name and photo
  - Date and time
  - Duration (15 or 25 min based on tier)
  - Meeting link
  - "Join Call" button (active 5 min before start)
  - "Reschedule" or "Cancel" options

**FR-COACH-CAL-03: Call Details**
- Tap call to view details:
  - Client profile info
  - Call purpose/notes (if client provided)
  - Client's recent activity
  - Preparation checklist

**FR-COACH-CAL-04: Availability Management**
- Set available time slots
- Block out unavailable times
- Set recurring availability (e.g., "Every Monday 10 AM - 2 PM")
- Clients can only book during available slots

**FR-COACH-CAL-05: Video Call Interface**
- "Join Call" button launches video interface
- Video/audio controls
- Chat sidebar for notes
- Screen sharing option
- Call timer showing time remaining
- "End Call" button

**FR-COACH-CAL-06: Post-Call Actions**
- After call ends, prompt to:
  - Add call notes (private, for coach reference)
  - Update client's workout/nutrition plan
  - Send follow-up message
- System automatically requests client rating

#### User Scenarios

**Scenario 1: Conducting Video Call**
```
Coach Sarah has call scheduled for 2 PM
→ At 1:55 PM, "Join Call" button becomes active
→ Coach clicks "Join Call" at 1:58 PM
→ Video interface loads
→ Ahmed joins at 2:00 PM
→ Coach reviews Ahmed's progress:
   - Completed 8/10 workouts this month
   - Lost 2 kg in 4 weeks
   - Question about plateau
→ Coach discusses:
   - Form improvement for compound lifts
   - Nutrition adjustments (increase protein)
   - New workout variation to break plateau
→ Call duration: 25 minutes (Premium tier)
→ Call ends at 2:25 PM
→ Coach adds notes: "Client motivated, adjust workout intensity next week"
→ Sends follow-up message with adjusted plan
→ Client receives rating prompt
```

---

### 3.6 Coach Earnings Screen

#### Purpose
Track coaching revenue, client subscriptions, and payment history.

#### Requirements

**FR-COACH-EARN-01: Current Month Summary**
- Display for current month:
  - Total earnings
  - Number of active paying clients
  - Earnings per tier (Premium, Smart Premium)
  - Projected earnings (based on current subscriptions)
- Comparison with last month (% change)

**FR-COACH-EARN-02: Revenue Breakdown**
- Pie chart showing revenue by subscription tier
- List of paying clients with individual contributions
- Average revenue per client

**FR-COACH-EARN-03: Earnings History**
- Table showing past months:
  - Month/Year
  - Total earnings
  - Active clients count
  - Download PDF statement
- Filter by date range

**FR-COACH-EARN-04: Payment Schedule**
- Next payout date
- Payout amount
- Payment method on file
- Payout frequency (monthly, bi-weekly)

**FR-COACH-EARN-05: Client Subscription Status**
- List all assigned clients with:
  - Name
  - Subscription tier
  - Monthly contribution to coach earnings
  - Subscription status (active/canceled)
  - Next billing date
- Filter by tier or status

**FR-COACH-EARN-06: Performance Insights**
- Client acquisition trend (new clients per month)
- Client retention rate
- Average client lifetime value
- Revenue growth trend chart

#### User Scenarios

**Scenario 1: Monthly Earnings Review**
```
End of month, Coach Sarah reviews earnings
→ Opens Earnings screen
→ Current Month: December 2024
   - Total: $1,250
   - Active Clients: 12 (8 Premium @ $19.99, 4 Smart Premium @ $49.99)
   - Coach's share: 70% = $875
   - Platform fee: 30% = $375
→ Sees comparison: +15% vs November
→ Reviews client list:
   - 8 Premium clients contributing $15.99 each = $127.92
   - 4 Smart Premium contributing $34.99 each = $139.96
→ Total: $267.88 coach earnings this month
→ Next payout: January 5th
→ Payment method: Bank transfer
```

---

## 4. Coach Performance Metrics

### Key Performance Indicators (KPIs)

**Client Satisfaction**
- Target: 4.5+ stars average rating
- Measured from post-call and post-message ratings
- Visible on coach profile

**Response Time**
- Target: < 4 hours average response to client messages
- Measured from message received to coach reply
- Faster response = better client experience

**Client Retention**
- Target: 85% month-over-month retention
- Measured by clients who remain subscribed
- High retention = quality coaching

**Activity Rate**
- Target: Clients complete 70%+ of assigned workouts
- Indicates plan quality and client engagement
- Coaches with higher completion rates ranked better

**Revenue Growth**
- Target: 10% month-over-month growth
- Measured by total earnings increase
- Incentivizes client acquisition and retention

---

## 5. Coach Tools & Resources

### Training Materials
- Onboarding video tutorials
- Best practices for messaging
- How to create effective workout plans
- Nutrition planning guidelines
- Client motivation techniques

### Support
- Dedicated coach support team
- Community forum for coaches
- Monthly coach webinars
- Feedback submission system

### Profile Visibility
- Public coach profile for new client matching
- Showcase certifications and specializations
- Display ratings and testimonials
- Bio and coaching philosophy

---

## 6. Coach Acceptance Criteria

**AC-COACH-01: Client Assignment**
- GIVEN admin approves new coach
- WHEN coach logs in for first time
- THEN coach sees coach intro screen
- AND has 0 clients initially
- AND waits for admin to assign first clients

**AC-COACH-02: Plan Creation**
- GIVEN coach creates workout plan for client
- WHEN plan is assigned
- THEN client sees plan immediately in workout screen
- AND client receives notification (if enabled)
- AND plan respects client's injury contraindications

**AC-COACH-03: Messaging with Quota Context**
- GIVEN coach views client conversation
- WHEN client is near quota limit (80%+)
- THEN coach sees warning in context panel
- AND can still send messages unlimited
- AND is aware client may not reply if quota exceeded

**AC-COACH-04: Video Call Quota**
- GIVEN client has 0 video calls remaining
- WHEN client attempts to book call
- THEN booking is blocked
- AND coach sees "Client has exceeded call quota" in calendar
- AND client must upgrade to book more calls

**AC-COACH-05: Earnings Calculation**
- GIVEN coach has 10 active paying clients
- WHEN calculating monthly earnings
- THEN coach receives 70% of subscription fees
- AND platform takes 30%
- AND earnings update in real-time as clients subscribe/cancel

---

## 7. Future Coach Features (Roadmap)

### Planned for v2.1
- Advanced analytics dashboard (client progress trends)
- Automated workout progression (AI-assisted)
- Group coaching capabilities
- Video content library for coaches
- Performance benchmarking vs other coaches

### Under Consideration
- Coach-to-coach mentoring system
- Continuing education credit tracking
- Client testimonial collection tool
- Social media integration for marketing
- White-label coaching programs

---

**End of Coach Requirements Document**
