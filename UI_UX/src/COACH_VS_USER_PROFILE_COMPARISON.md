# Coach Profile vs User Profile - Visual Comparison

## Side-by-Side Comparison

### USER PROFILE (AccountScreen)
**Purpose:** Personal fitness tracking and subscription management

```
┌─────────────────────────────────────┐
│ ← Account                           │
│   Manage your profile               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│     JD    John Doe                  │
│           john@example.com          │
│           [Freemium]                │
└─────────────────────────────────────┘

[Profile] [Subscription] [Notifications]

━━━ PROFILE TAB ━━━
┌─────────────────────────────────────┐
│ Personal Information                │
│ Name:     John Doe                  │
│ Email:    john@example.com          │
│ Age:      25                        │
│ Weight:   75 kg                     │
│ Height:   175 cm                    │
│ Gender:   Male                      │
│ [Edit Profile]                      │
└─────────────────────────────────────┘

━━━ SUBSCRIPTION TAB ━━━
┌─────────────────────────────────────┐
│ Current Plan: Freemium              │
│ [Upgrade to Premium]                │
│                                     │
│ Features:                           │
│ ✓ Basic workout plans               │
│ ✓ 1 coach session/month             │
│ ✓ Store access                      │
│ ✗ Nutrition plans                   │
└─────────────────────────────────────┘
```

---

### COACH PROFILE (CoachProfileScreen) ⭐
**Purpose:** Professional credentials and coaching portfolio

```
┌─────────────────────────────────────┐
│ ← My Profile              [⚙️]      │
│   Professional coaching profile     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  AR  Ahmad Al-Rashid  [✓ Verified]  │
│      ahmad@coach.com                │
│      ⭐ 4.8 (87 reviews)             │
│      👥 45 clients • 📅 8 years exp  │
│                                     │
│  [Strength] [Nutrition] [Weight]    │
└─────────────────────────────────────┘

┌─────┬─────┬─────┬─────┐
│ 👥  │ 🎥  │ 📈  │ 💰  │
│ 87  │1240 │ 92% │$5.6K│
│Clnts│Sess │Succ │Rev  │
└─────┴─────┴─────┴─────┘

[Overview][Certificates][Experience][Achievements]

━━━ OVERVIEW TAB ━━━
┌─────────────────────────────────────┐
│ 👤 Professional Bio         [Edit]  │
│ Certified fitness coach with 8+     │
│ years of experience specializing... │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ Contact Information         [Edit]  │
│ Email: ahmad@coach.com              │
│ Phone: +966 50 123 4567             │
└─────────────────────────────────────┘

━━━ CERTIFICATES TAB 🎓 ━━━
┌─────────────────────────────────────┐
│ [🏆] CPT - NASM                     │
│      Issued: Jun 2017               │
│      Expires: Jun 2027              │
│      [View Certificate →]           │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [🏆] Nutrition Specialist - ISSA    │
│      Issued: Sep 2018               │
│      [View Certificate →]           │
└─────────────────────────────────────┘

━━━ EXPERIENCE TAB 💼 ━━━
┌─────────────────────────────────────┐
│ [📚] Senior Fitness Coach [Current] │
│      Elite Fitness Center           │
│      Jan 2020 - Present             │
│      Lead trainer managing 30+...   │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [📚] Personal Trainer               │
│      Gold's Gym                     │
│      Jun 2017 - Dec 2019            │
│      Provided one-on-one training...│
└─────────────────────────────────────┘

━━━ ACHIEVEMENTS TAB 🏆 ━━━
┌─────────────────────────────────────┐
│ [🏆] Top Trainer 2023      [Award]  │
│      Exceptional client results...  │
│      Dec 2023                       │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [🥇] National Championship [Medal]  │
│      1st Place - Men's Physique     │
│      Jul 2021                       │
└─────────────────────────────────────┘
```

## Feature Comparison Table

| Feature | User Profile | Coach Profile |
|---------|-------------|---------------|
| **Personal Info** | ✅ Name, Email, Age, Weight, Height, Gender | ✅ Name, Email, Phone, Professional Bio |
| **Avatar** | ✅ Basic avatar | ✅ Professional headshot |
| **Verification Badge** | ❌ No | ✅ "Verified Coach" badge |
| **Rating Display** | ❌ No | ✅ Star rating + review count |
| **Experience Years** | ❌ No | ✅ Years of coaching experience |
| **Specializations** | ❌ No | ✅ Multiple specialty badges |
| **Quick Stats** | ❌ No | ✅ 4-metric dashboard |
| **Subscription Management** | ✅ Upgrade/manage plan | ❌ Not applicable |
| **Certificates** | ❌ No | ✅ Full certificate management |
| **Work Experience** | ❌ No | ✅ Timeline with job history |
| **Achievements** | ❌ No | ✅ Awards, medals, recognition |
| **Revenue Tracking** | ❌ No | ✅ Monthly/total revenue |
| **Client Count** | ❌ No | ✅ Total and active clients |
| **Success Rate** | ❌ No | ✅ Goal achievement percentage |
| **Completed Sessions** | ❌ No | ✅ Total sessions delivered |
| **Notifications** | ✅ Workout, nutrition reminders | ❌ Separate coach settings |
| **InBody Data** | ✅ Track personal metrics | ❌ View client InBody data |
| **Progress Tracking** | ✅ Personal fitness progress | ❌ Track client progress |

## Data Structure Comparison

### User Profile Data
```typescript
interface UserProfile {
  id: string;
  name: string;
  email: string;
  age: number;
  weight: number;
  height: number;
  gender: 'male' | 'female';
  subscriptionTier: 'Freemium' | 'Premium' | 'Smart Premium';
  fitnessGoal: string;
  avatar?: string;
}
```

### Coach Profile Data
```typescript
interface CoachProfile extends UserProfile {
  // Basic Info
  phone: string;
  bio: string;
  yearsOfExperience: number;
  specializations: string[];
  isVerified: boolean;
  
  // Statistics
  totalClients: number;
  activeClients: number;
  completedSessions: number;
  avgRating: number;
  successRate: number;
  totalRevenue: number;
  monthlyRevenue: number;
  
  // Credentials
  certificates: Certificate[];
  experiences: Experience[];
  achievements: Achievement[];
}

interface Certificate {
  id: string;
  name: string;
  issuingOrganization: string;
  dateObtained: Date;
  expiryDate?: Date;
  certificateUrl?: string;
}

interface Experience {
  id: string;
  title: string;
  organization: string;
  startDate: Date;
  endDate?: Date;
  isCurrent: boolean;
  description: string;
}

interface Achievement {
  id: string;
  title: string;
  description: string;
  date: Date;
  type: 'medal' | 'award' | 'recognition';
}
```

## Navigation Flow

### User Profile Access
```
Home Screen
    ↓
[Account Tab] (Bottom Navigation)
    ↓
AccountScreen
    ├─ Profile Tab
    ├─ Subscription Tab
    ├─ Notifications Tab
    └─ Settings Tab
```

### Coach Profile Access
```
Coach Dashboard
    ↓
[My Profile Button] (Top Right)
    ↓
CoachProfileScreen
    ├─ Overview Tab
    ├─ Certificates Tab
    ├─ Experience Tab
    └─ Achievements Tab
```

## Use Cases

### User Profile (Client)
**"I want to..."**
- ✅ Update my personal fitness information
- ✅ Track my weight and progress
- ✅ Manage my subscription plan
- ✅ Set notification preferences
- ✅ View my InBody results
- ✅ Change my fitness goals

### Coach Profile (Professional)
**"I want to..."**
- ✅ Showcase my professional credentials
- ✅ Display my certifications to clients
- ✅ Highlight my work experience
- ✅ Show off my achievements and awards
- ✅ Track my coaching statistics
- ✅ Monitor my revenue and client base
- ✅ Build credibility and trust
- ✅ Attract new clients

## Client View Comparison

### What Clients See: User Profile
```
When viewing another user's profile:
❌ Very limited information
❌ Just name and basic details
❌ No credibility indicators
```

### What Clients See: Coach Profile
```
When viewing a coach's profile:
✅ Full professional credentials
✅ Verified badge for trust
✅ Star rating and reviews
✅ Years of experience
✅ Certifications (proof of qualifications)
✅ Work history (track record)
✅ Achievements (excellence proof)
✅ Success rate (effectiveness indicator)
✅ Active client count (popularity)
```

## Color Scheme Differences

### User Profile
```css
Primary: Blue/Cyan gradients
- Standard user interface
- Clean and simple
- Focus on functionality

Header: bg-gradient-to-r from-blue-600 to-cyan-600
Cards:  White with subtle shadows
Stats:  Basic text displays
```

### Coach Profile
```css
Primary: Purple/Indigo gradients
- Professional appearance
- Rich with credentials
- Focus on credibility

Header:        bg-gradient-to-r from-purple-600 to-indigo-600
Cards:         White with enhanced shadows
Stats:         Icon-rich metric cards
Certificates:  Blue accent (🏆)
Experience:    Purple accent (📚)
Achievements:  Gold/Yellow accent (🏆🥇)
```

## Mobile Responsiveness

### User Profile (Mobile)
```
┌─────────────┐
│ ← Account   │
├─────────────┤
│   Avatar    │
│  John Doe   │
│  [Freemium] │
├─────────────┤
│ [Profile]   │
│ [Sub] [Not] │
├─────────────┤
│ Name: John  │
│ Email: ...  │
│ Age: 25     │
│             │
│ [Edit]      │
└─────────────┘
```

### Coach Profile (Mobile)
```
┌─────────────┐
│ ← Profile ⚙│
├─────────────┤
│   Avatar    │
│  Ahmad R.   │
│  ✓ Verified │
│  ⭐ 4.8     │
│  45 clients │
├─────────────┤
│  [Tags...]  │
├─────────────┤
│ ┌─┬─┬─┬─┐  │
│ │👥│🎥│📈│💰│ │
│ │87│1K│92│$5│ │
│ └─┴─┴─┴─┘  │
├─────────────┤
│[Ovr][Cert] │
│[Exp][Achv] │
├─────────────┤
│ Bio...      │
│             │
│ 🏆 Certs    │
│ 📚 Exp      │
│ 🏆 Awards   │
└─────────────┘
```

## When to Use Which

### Use AccountScreen (User Profile) When:
- ✅ User is a regular client
- ✅ Need to manage subscription
- ✅ Track personal fitness data
- ✅ Update personal information
- ✅ Manage notifications

### Use CoachProfileScreen When:
- ✅ User is a certified coach
- ✅ Need to showcase credentials
- ✅ Building professional portfolio
- ✅ Attracting new clients
- ✅ Demonstrating expertise
- ✅ Tracking coaching metrics

## Implementation Decision Tree

```
Is user a coach?
    │
    ├─ NO → Use AccountScreen
    │        - Personal info only
    │        - Subscription management
    │        - Basic settings
    │
    └─ YES → Use CoachProfileScreen
             - Professional credentials
             - Certificates
             - Experience history
             - Achievements
             - Coaching statistics
```

## Integration Example

```typescript
// In App.tsx or Navigation component

const renderProfileScreen = () => {
  if (userProfile.role === 'coach') {
    return (
      <CoachProfileScreen
        userProfile={userProfile}
        onBack={handleBack}
        onLogout={handleLogout}
        onUpdateProfile={handleUpdateProfile}
      />
    );
  } else {
    return (
      <AccountScreen
        userProfile={userProfile}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
        onUpdateProfile={handleUpdateProfile}
        isDemoMode={isDemoMode}
      />
    );
  }
};
```

## Summary

### User Profile = Personal Fitness Management
- Focused on individual health tracking
- Subscription and payment management
- Simple, clean interface
- Personal metrics only

### Coach Profile = Professional Portfolio
- Showcases coaching expertise
- Displays verifiable credentials
- Rich with professional information
- Built to establish trust and credibility
- Attracts and retains clients

**Key Takeaway:** The CoachProfileScreen is specifically designed to help coaches build their professional brand and credibility, while the AccountScreen is for clients to manage their personal fitness journey.

---

**Both screens are essential** but serve completely different purposes and user types within the FitCoach+ ecosystem.
