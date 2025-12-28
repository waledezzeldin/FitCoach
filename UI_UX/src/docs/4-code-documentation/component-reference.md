# Component Reference Guide

## Document Information
- **Purpose**: Complete reference for all React components in عاش app
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Total Components**: 28 screens + 40+ UI components

---

## Table of Contents

1. [User Screen Components (12)](#user-screen-components)
2. [Coach Screen Components (6)](#coach-screen-components)
3. [Admin Screen Components (8)](#admin-screen-components)
4. [Shared Components](#shared-components)
5. [UI Components (Radix-based)](#ui-components)
6. [Component Patterns](#component-patterns)

---

## User Screen Components

### 1. LanguageSelectionScreen

**File**: `/components/LanguageSelectionScreen.tsx`

**Purpose**: First screen users see, allows language selection (Arabic/English).

**Props**:
```typescript
interface LanguageSelectionScreenProps {
  onLanguageSelected: (language: 'ar' | 'en') => void;
}
```

**State**:
```typescript
const [selectedLanguage, setSelectedLanguage] = useState<'ar' | 'en' | null>(null);
```

**Key Features**:
- Two large language buttons (Arabic flag + text, English flag + text)
- Persists selection to localStorage
- Sets RTL direction for Arabic
- Triggers onLanguageSelected callback

**Usage**:
```typescript
<LanguageSelectionScreen 
  onLanguageSelected={(lang) => {
    setLanguage(lang);
    navigate('/intro');
  }} 
/>
```

**Styling Notes**:
- Full screen centered layout
- Large touch targets for mobile
- Flag icons from `/imports` or Unsplash

---

### 2. AppIntroScreen

**File**: `/components/AppIntroScreen.tsx`

**Purpose**: 3-slide carousel introducing app features.

**Props**:
```typescript
interface AppIntroScreenProps {
  onComplete: () => void;
  onSkip: () => void;
}
```

**State**:
```typescript
const [currentSlide, setCurrentSlide] = useState<number>(0);
```

**Key Features**:
- 3 slides with hero images + titles + descriptions
- Swipeable carousel (react-slick or native)
- "Next" and "Skip" buttons
- Progress dots indicator
- Final slide has "Get Started" button

**Slide Content**:
1. **Slide 1**: Personalized Workouts
2. **Slide 2**: Nutrition Tracking
3. **Slide 3**: Track Progress

**Usage**:
```typescript
<AppIntroScreen 
  onComplete={() => navigate('/auth')}
  onSkip={() => navigate('/auth')}
/>
```

---

### 3. PhoneOTPAuthScreen

**File**: `/components/PhoneOTPAuthScreen.tsx`

**Purpose**: Phone number input and OTP verification for authentication.

**Props**:
```typescript
interface PhoneOTPAuthScreenProps {
  onAuthSuccess: (userId: string, isNewUser: boolean) => void;
}
```

**State**:
```typescript
const [step, setStep] = useState<'phone' | 'otp'>('phone');
const [phoneNumber, setPhoneNumber] = useState<string>('');
const [otp, setOtp] = useState<string>('');
const [countdown, setCountdown] = useState<number>(60);
const [error, setError] = useState<string>('');
const [loading, setLoading] = useState<boolean>(false);
```

**Key Features**:
- **Step 1**: Phone number input with Saudi format (+966 5X XXX XXXX)
- Real-time validation using `phoneValidation.ts`
- **Step 2**: 6-digit OTP input
- 60-second countdown timer
- Resend OTP after countdown
- Error handling and display
- Auto-focus on OTP input

**Validation Logic**:
```typescript
import { validateSaudiPhone } from '../utils/phoneValidation';

const handleSendOTP = async () => {
  const validation = validateSaudiPhone(phoneNumber);
  
  if (!validation.isValid) {
    setError(validation.error);
    return;
  }
  
  setLoading(true);
  try {
    // Mock: In production, call OTP service (Twilio/AWS SNS)
    await mockSendOTP(validation.formatted);
    setStep('otp');
    setCountdown(60);
  } catch (err) {
    setError(t('auth.otpSendFailed'));
  } finally {
    setLoading(false);
  }
};
```

**Usage**:
```typescript
<PhoneOTPAuthScreen 
  onAuthSuccess={(userId, isNewUser) => {
    if (isNewUser) {
      navigate('/first-intake');
    } else {
      navigate('/home');
    }
  }}
/>
```

---

### 4. FirstIntakeScreen

**File**: `/components/FirstIntakeScreen.tsx`

**Purpose**: Quick 3-question onboarding for all new users.

**Props**:
```typescript
interface FirstIntakeScreenProps {
  userId: string;
  onComplete: (data: FirstIntakeData) => void;
}
```

**State**:
```typescript
const [step, setStep] = useState<number>(1);
const [gender, setGender] = useState<'male' | 'female' | 'other' | null>(null);
const [goal, setGoal] = useState<'fat_loss' | 'muscle_gain' | 'general_fitness' | null>(null);
const [location, setLocation] = useState<'home' | 'gym' | null>(null);
```

**Questions**:
1. **Gender**: Male / Female / Other (with icons)
2. **Goal**: Fat Loss / Muscle Gain / General Fitness (with icons)
3. **Location**: Home / Gym (with icons)

**Validation**:
```typescript
const canProceed = () => {
  if (step === 1) return gender !== null;
  if (step === 2) return goal !== null;
  if (step === 3) return location !== null;
  return false;
};
```

**Usage**:
```typescript
<FirstIntakeScreen 
  userId={userId}
  onComplete={(data) => {
    saveFirstIntake(userId, data);
    navigate('/home');
  }}
/>
```

**Visual Design**:
- Large selectable cards for each option
- Progress bar at top (1/3, 2/3, 3/3)
- "Back" and "Next" buttons
- Illustrations for each option

---

### 5. HomeScreen

**File**: `/components/HomeScreen.tsx`

**Purpose**: Central dashboard showing workout plan, nutrition summary, quota usage, and quick actions.

**Props**:
```typescript
interface HomeScreenProps {
  userId: string;
  userProfile: UserProfile;
}
```

**State**:
```typescript
const [workoutSummary, setWorkoutSummary] = useState<WorkoutSummary | null>(null);
const [nutritionSummary, setNutritionSummary] = useState<NutritionSummary | null>(null);
const [quotaStatus, setQuotaStatus] = useState<QuotaStatus | null>(null);
const [loading, setLoading] = useState<boolean>(true);
```

**Key Sections**:
1. **Header**: Greeting, profile picture, notifications icon
2. **Workout Card**: Today's workout preview, "Start Workout" button
3. **Nutrition Card**: Today's meal plan summary, calories progress
4. **Progress Card**: Fitness score, current streak
5. **Quota Display**: Messages and calls remaining (tier-based)
6. **Quick Actions**: Chat with coach, view store, track progress
7. **Subscription Banner**: Upgrade prompt for Freemium users

**Usage**:
```typescript
<HomeScreen 
  userId={userId}
  userProfile={userProfile}
/>
```

**Data Fetching**:
```typescript
useEffect(() => {
  async function loadDashboardData() {
    try {
      setLoading(true);
      const [workout, nutrition, quota] = await Promise.all([
        fetchTodayWorkout(userId),
        fetchTodayNutrition(userId),
        fetchQuotaStatus(userId)
      ]);
      setWorkoutSummary(workout);
      setNutritionSummary(nutrition);
      setQuotaStatus(quota);
    } catch (error) {
      console.error('Failed to load dashboard:', error);
    } finally {
      setLoading(false);
    }
  }
  
  loadDashboardData();
}, [userId]);
```

---

### 6. SecondIntakePromptModal

**File**: `/components/SecondIntakePromptModal.tsx`

**Purpose**: Modal that appears when user first accesses workout, offering 3 options.

**Props**:
```typescript
interface SecondIntakePromptModalProps {
  isOpen: boolean;
  onCompleteProfile: () => void;
  onScheduleCall: () => void;
  onTryLater: () => void;
  videoCallsRemaining: number;
  userTier: SubscriptionTier;
}
```

**State**:
```typescript
const [selectedOption, setSelectedOption] = useState<'profile' | 'call' | 'later' | null>(null);
```

**Key Features**:
- Semi-transparent backdrop
- Three clear options with icons and descriptions:
  1. **Complete Profile Now** (Primary button)
  2. **Talk to My Coach** (Secondary button, shows quota)
  3. **Try Later** (Tertiary link)
- Quota check for video call option
- Blocks interaction with background
- Cannot dismiss by clicking outside (force choice)

**Usage**:
```typescript
<SecondIntakePromptModal 
  isOpen={showSecondIntakePrompt}
  onCompleteProfile={() => {
    setShowSecondIntakePrompt(false);
    navigate('/second-intake');
  }}
  onScheduleCall={() => {
    if (videoCallsRemaining > 0) {
      setShowSecondIntakePrompt(false);
      navigate('/video-booking');
    } else {
      showUpgradePrompt();
    }
  }}
  onTryLater={() => {
    setShowSecondIntakePrompt(false);
    incrementDeferralCount(userId);
    navigate('/workout');
  }}
  videoCallsRemaining={quotaStatus.videoCallsRemaining}
  userTier={userProfile.subscriptionTier}
/>
```

**Persistence Logic**:
```typescript
// In parent component
const [showSecondIntakePrompt, setShowSecondIntakePrompt] = useState(() => {
  const status = getSecondIntakePromptStatus(userId);
  return !status.hasCompletedSecondIntake && 
         !status.permanentlyDismissed &&
         status.timesDeferred < 3;
});
```

---

### 7. SecondIntakeScreen

**File**: `/components/SecondIntakeScreen.tsx`

**Purpose**: Detailed 6-question profile for ALL users (Freemium, Premium, Smart Premium).

**Props**:
```typescript
interface SecondIntakeScreenProps {
  userId: string;
  onComplete: (data: SecondIntakeData) => void;
}
```

**State**:
```typescript
const [step, setStep] = useState<number>(1);
const [age, setAge] = useState<number | null>(null);
const [weight, setWeight] = useState<number | null>(null);
const [height, setHeight] = useState<number | null>(null);
const [experience, setExperience] = useState<ExperienceLevel | null>(null);
const [frequency, setFrequency] = useState<number | null>(null);
const [injuries, setInjuries] = useState<InjuryArea[]>([]);
```

**Questions**:
1. **Age**: Number input (13-120)
2. **Weight**: Number input (30-300 kg) with kg/lbs toggle
3. **Height**: Number input (100-250 cm) with cm/ft toggle
4. **Experience**: Beginner / Intermediate / Advanced (cards)
5. **Workout Frequency**: 2-6 days/week (slider or buttons)
6. **Injuries**: Multi-select checkboxes (shoulder, knee, lower back, neck, ankle, none)

**Validation**:
```typescript
const validateStep = (stepNum: number): boolean => {
  switch (stepNum) {
    case 1: return age !== null && age >= 13 && age <= 120;
    case 2: return weight !== null && weight >= 30 && weight <= 300;
    case 3: return height !== null && height >= 100 && height <= 250;
    case 4: return experience !== null;
    case 5: return frequency !== null && frequency >= 2 && frequency <= 6;
    case 6: return true; // Injuries optional
    default: return false;
  }
};
```

**Fitness Score Calculation**:
```typescript
import { calculateFitnessScore } from '../utils/fitnessScore';

const handleComplete = () => {
  const intakeData: SecondIntakeData = {
    age,
    weight,
    height,
    experience,
    frequency,
    injuries
  };
  
  const score = calculateFitnessScore(intakeData);
  
  onComplete({
    ...intakeData,
    fitnessScore: score
  });
};
```

**Usage**:
```typescript
<SecondIntakeScreen 
  userId={userId}
  onComplete={(data) => {
    saveSecondIntake(userId, data);
    toast.success(t('intake.profileCompleted'));
    navigate('/workout');
  }}
/>
```

---

### 8. WorkoutScreen

**File**: `/components/WorkoutScreen.tsx`

**Purpose**: Display workout plan with injury substitution and progress tracking.

**Props**:
```typescript
interface WorkoutScreenProps {
  userId: string;
  userProfile: UserProfile;
  workoutPlan: WorkoutPlan;
}
```

**State**:
```typescript
const [currentExerciseIndex, setCurrentExerciseIndex] = useState<number>(0);
const [completedSets, setCompletedSets] = useState<Record<string, number>>({});
const [showSubstitution, setShowSubstitution] = useState<boolean>(false);
const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
const [timerActive, setTimerActive] = useState<boolean>(false);
const [restTime, setRestTime] = useState<number>(60);
```

**Key Features**:
- Exercise list with descriptions and images
- Injury warnings for contraindicated exercises
- "Show Alternative" button for unsafe exercises
- Set/rep tracking with checkboxes
- Rest timer between sets
- Exercise completion tracking
- Video demonstrations (if available)
- Notes section for each exercise

**Injury Detection**:
```typescript
import { isExerciseSafe, getSafeAlternatives } from '../utils/injuryRules';

const renderExercise = (exercise: Exercise) => {
  const userInjuries = userProfile.secondIntake?.injuries || [];
  const isSafe = isExerciseSafe(exercise, userInjuries);
  
  if (!isSafe) {
    const alternatives = getSafeAlternatives(exercise, userInjuries[0]);
    
    return (
      <ExerciseCard
        exercise={exercise}
        warning="⚠️ Not recommended due to your knee injury"
        onShowAlternative={() => {
          setSelectedExercise(exercise);
          setShowSubstitution(true);
        }}
        alternatives={alternatives}
      />
    );
  }
  
  return <ExerciseCard exercise={exercise} />;
};
```

**Usage**:
```typescript
<WorkoutScreen 
  userId={userId}
  userProfile={userProfile}
  workoutPlan={currentWorkout}
/>
```

---

### 9. NutritionScreen

**File**: `/components/NutritionScreen.tsx`

**Purpose**: Display daily meal plan with macro tracking and expiry management.

**Props**:
```typescript
interface NutritionScreenProps {
  userId: string;
  userProfile: UserProfile;
}
```

**State**:
```typescript
const [mealPlan, setMealPlan] = useState<MealPlan | null>(null);
const [selectedMeal, setSelectedMeal] = useState<Meal | null>(null);
const [showSubstitution, setShowSubstitution] = useState<boolean>(false);
const [nutritionAccess, setNutritionAccess] = useState<NutritionAccessStatus | null>(null);
```

**Key Features**:
- **Expiry Banner** (Freemium users only)
- Meal cards (Breakfast, Lunch, Dinner, Snacks)
- Macro breakdown (Protein, Carbs, Fats, Calories)
- Meal substitution system
- Progress bars for macro targets
- Meal logging with checkmarks
- Shopping list generation

**Expiry Check**:
```typescript
import { getNutritionAccessStatus } from '../utils/nutritionExpiry';

useEffect(() => {
  async function checkAccess() {
    const access = await getNutritionAccessStatus(userId);
    setNutritionAccess(access);
    
    if (access.isExpired && userProfile.subscriptionTier === 'Freemium') {
      navigate('/upgrade', { reason: 'nutrition_expired' });
    }
  }
  
  checkAccess();
}, [userId]);
```

**Expiry Banner**:
```typescript
{nutritionAccess && !nutritionAccess.isExpired && nutritionAccess.daysLeft <= 3 && (
  <NutritionExpiryBanner 
    daysLeft={nutritionAccess.daysLeft}
    onUpgrade={() => navigate('/upgrade')}
  />
)}
```

**Usage**:
```typescript
<NutritionScreen 
  userId={userId}
  userProfile={userProfile}
/>
```

---

### 10. MessagingScreen

**File**: `/components/MessagingScreen.tsx`

**Purpose**: Chat interface with coach, quota enforcement, and attachment gating.

**Props**:
```typescript
interface MessagingScreenProps {
  userId: string;
  coachId: string;
  userProfile: UserProfile;
}
```

**State**:
```typescript
const [messages, setMessages] = useState<Message[]>([]);
const [inputMessage, setInputMessage] = useState<string>('');
const [quotaStatus, setQuotaStatus] = useState<QuotaStatus | null>(null);
const [showRating, setShowRating] = useState<boolean>(false);
const [messageCount, setMessageCount] = useState<number>(0);
```

**Key Features**:
- Real-time message list (coach + user messages)
- Quota display at top (messages remaining)
- Text input with send button
- Attachment button (Smart Premium only - gated)
- Quota check before sending
- Rating modal every 10 messages
- Message timestamps
- Read receipts

**Quota Enforcement**:
```typescript
import { checkQuota, incrementQuota } from '../utils/quotaEnforcement';

const handleSendMessage = async () => {
  // Check quota
  const quotaCheck = await checkQuota(userId, 'message');
  
  if (!quotaCheck.allowed) {
    toast.error(t('quota.messageExceeded'));
    setShowUpgradePrompt(true);
    return;
  }
  
  // Send message
  try {
    const newMessage = await sendMessage({
      content: inputMessage,
      senderId: userId,
      receiverId: coachId,
      timestamp: new Date()
    });
    
    setMessages([...messages, newMessage]);
    setInputMessage('');
    
    // Increment quota
    await incrementQuota(userId, 'message');
    setQuotaStatus(await fetchQuotaStatus(userId));
    
    // Check for rating trigger
    const newCount = messageCount + 1;
    setMessageCount(newCount);
    if (newCount % 10 === 0) {
      setShowRating(true);
    }
  } catch (error) {
    toast.error(t('errors.sendMessageFailed'));
  }
};
```

**Attachment Gating**:
```typescript
const renderAttachmentButton = () => {
  const isSmartPremium = userProfile.subscriptionTier === 'Smart Premium';
  
  return (
    <button 
      onClick={isSmartPremium ? handleAttachment : undefined}
      disabled={!isSmartPremium}
      className={`attachment-btn ${!isSmartPremium ? 'opacity-50 cursor-not-allowed' : ''}`}
      title={!isSmartPremium ? t('quota.attachmentGated') : t('messages.addAttachment')}
    >
      <PaperclipIcon />
    </button>
  );
};
```

**Usage**:
```typescript
<MessagingScreen 
  userId={userId}
  coachId={userProfile.assignedCoach}
  userProfile={userProfile}
/>
```

---

### 11. StoreScreen

**File**: `/components/StoreScreen.tsx`

**Purpose**: E-commerce store for fitness products.

**Props**:
```typescript
interface StoreScreenProps {
  userId: string;
}
```

**State**:
```typescript
const [products, setProducts] = useState<Product[]>([]);
const [category, setCategory] = useState<ProductCategory>('all');
const [cart, setCart] = useState<CartItem[]>([]);
const [searchQuery, setSearchQuery] = useState<string>('');
```

**Key Features**:
- Product grid with images
- Category filters (Equipment, Supplements, Apparel, Accessories)
- Search functionality
- Product details modal
- Add to cart
- Cart preview
- Checkout flow
- Reviews and ratings

**Usage**:
```typescript
<StoreScreen userId={userId} />
```

---

### 12. ProgressScreen

**File**: `/components/ProgressScreen.tsx`

**Purpose**: Track and visualize fitness progress over time.

**Props**:
```typescript
interface ProgressScreenProps {
  userId: string;
  userProfile: UserProfile;
}
```

**State**:
```typescript
const [weightData, setWeightData] = useState<WeightEntry[]>([]);
const [workoutStats, setWorkoutStats] = useState<WorkoutStats | null>(null);
const [fitnessScore, setFitnessScore] = useState<number>(0);
const [achievements, setAchievements] = useState<Achievement[]>([]);
const [timeRange, setTimeRange] = useState<'week' | 'month' | '3months' | 'all'>('month');
```

**Key Features**:
- Weight tracking chart (line chart)
- InBody scan tracking (Premium+ only)
- Workout statistics (total, streak, time)
- Nutrition statistics
- Fitness score gauge
- Achievements/badges
- Before/after photos

**InBody Gating**:
```typescript
const renderInBodySection = () => {
  const hasAccess = ['Premium', 'Smart Premium'].includes(userProfile.subscriptionTier);
  
  if (!hasAccess) {
    return (
      <UpgradePrompt 
        feature="InBody Tracking"
        requiredTier="Premium"
        onUpgrade={() => navigate('/upgrade')}
      />
    );
  }
  
  return <InBodyList scans={inBodyScans} onAddScan={handleAddScan} />;
};
```

**Usage**:
```typescript
<ProgressScreen 
  userId={userId}
  userProfile={userProfile}
/>
```

---

## Coach Screen Components

### 13. CoachDashboardScreen

**File**: `/components/coach/CoachDashboardScreen.tsx`

**Purpose**: Coach's main dashboard showing client overview and actions.

**Props**:
```typescript
interface CoachDashboardScreenProps {
  coachId: string;
  coachProfile: CoachProfile;
}
```

**State**:
```typescript
const [clients, setClients] = useState<ClientSummary[]>([]);
const [pendingMessages, setPendingMessages] = useState<number>(0);
const [upcomingCalls, setUpcomingCalls] = useState<VideoCall[]>([]);
const [stats, setStats] = useState<CoachStats | null>(null);
```

**Key Features**:
- Active clients count
- Pending messages count
- Upcoming video calls
- Quick actions (create plan, view calendar, message client)
- Performance metrics (avg rating, total clients)

**Usage**:
```typescript
<CoachDashboardScreen 
  coachId={coachId}
  coachProfile={coachProfile}
/>
```

---

### 14. CoachClientListScreen

**File**: `/components/coach/CoachClientListScreen.tsx`

**Purpose**: List of all clients assigned to coach.

**Props**:
```typescript
interface CoachClientListScreenProps {
  coachId: string;
}
```

**State**:
```typescript
const [clients, setClients] = useState<Client[]>([]);
const [filter, setFilter] = useState<'all' | 'active' | 'inactive'>('all');
const [searchQuery, setSearchQuery] = useState<string>('');
```

**Key Features**:
- Client cards with profile pictures
- Filter by status (all/active/inactive)
- Search by name
- Quick view of client tier
- Navigate to client details

**Usage**:
```typescript
<CoachClientListScreen coachId={coachId} />
```

---

### 15. CoachWorkoutBuilderScreen

**File**: `/components/coach/CoachWorkoutBuilderScreen.tsx`

**Purpose**: Create custom workout plans for clients.

**Props**:
```typescript
interface CoachWorkoutBuilderScreenProps {
  coachId: string;
  clientId: string;
  clientProfile: UserProfile;
}
```

**State**:
```typescript
const [planName, setPlanName] = useState<string>('');
const [days, setDays] = useState<WorkoutDay[]>([]);
const [selectedExercises, setSelectedExercises] = useState<Exercise[]>([]);
const [exerciseLibrary, setExerciseLibrary] = useState<Exercise[]>([]);
```

**Key Features**:
- Plan name input
- Day selector (Mon-Sun)
- Exercise library search
- Drag-and-drop exercise ordering
- Set/rep configuration per exercise
- Injury-aware warnings
- Save as template
- Assign to client

**Usage**:
```typescript
<CoachWorkoutBuilderScreen 
  coachId={coachId}
  clientId={selectedClientId}
  clientProfile={selectedClient}
/>
```

---

### 16. CoachNutritionBuilderScreen

**File**: `/components/coach/CoachNutritionBuilderScreen.tsx`

**Purpose**: Create custom meal plans for clients.

**Props**:
```typescript
interface CoachNutritionBuilderScreenProps {
  coachId: string;
  clientId: string;
  clientProfile: UserProfile;
}
```

**State**:
```typescript
const [planName, setPlanName] = useState<string>('');
const [dailyCalories, setDailyCalories] = useState<number>(2000);
const [macroSplit, setMacroSplit] = useState<MacroSplit>({ protein: 30, carbs: 40, fats: 30 });
const [meals, setMeals] = useState<Meal[]>([]);
```

**Key Features**:
- Plan name and duration
- Calorie target input
- Macro split calculator
- Meal database search
- Meal substitutions setup
- Save as template
- Assign to client

**Usage**:
```typescript
<CoachNutritionBuilderScreen 
  coachId={coachId}
  clientId={selectedClientId}
  clientProfile={selectedClient}
/>
```

---

### 17. CoachCalendarScreen

**File**: `/components/coach/CoachCalendarScreen.tsx`

**Purpose**: Manage video call appointments and availability.

**Props**:
```typescript
interface CoachCalendarScreenProps {
  coachId: string;
}
```

**State**:
```typescript
const [appointments, setAppointments] = useState<VideoCall[]>([]);
const [selectedDate, setSelectedDate] = useState<Date>(new Date());
const [availability, setAvailability] = useState<AvailabilitySlot[]>([]);
```

**Key Features**:
- Month/week/day calendar views
- Appointment details
- Set availability blocks
- Accept/decline booking requests
- Reschedule appointments
- Video call notes

**Usage**:
```typescript
<CoachCalendarScreen coachId={coachId} />
```

---

### 18. CoachPerformanceScreen

**File**: `/components/coach/CoachPerformanceScreen.tsx`

**Purpose**: View coach performance metrics and client ratings.

**Props**:
```typescript
interface CoachPerformanceScreenProps {
  coachId: string;
}
```

**State**:
```typescript
const [avgRating, setAvgRating] = useState<number>(0);
const [totalRatings, setTotalRatings] = useState<number>(0);
const [ratingBreakdown, setRatingBreakdown] = useState<Record<number, number>>({});
const [recentFeedback, setRecentFeedback] = useState<Rating[]>([]);
```

**Key Features**:
- Average rating display
- Rating distribution (1-5 stars)
- Recent feedback with comments
- Performance trends over time
- Client retention rate
- Response time metrics

**Usage**:
```typescript
<CoachPerformanceScreen coachId={coachId} />
```

---

## Admin Screen Components

### 19. AdminDashboardScreen

**File**: `/components/admin/AdminDashboardScreen.tsx`

**Purpose**: Platform overview with key metrics.

**Props**:
```typescript
interface AdminDashboardScreenProps {
  adminId: string;
}
```

**State**:
```typescript
const [metrics, setMetrics] = useState<PlatformMetrics | null>(null);
const [recentActivity, setRecentActivity] = useState<Activity[]>([]);
```

**Key Features**:
- Total users, coaches, revenue
- Active subscriptions breakdown
- Daily/weekly/monthly trends
- Quick actions (manage users, coaches, content)
- Recent system activity log

**Usage**:
```typescript
<AdminDashboardScreen adminId={adminId} />
```

---

### 20. AdminUserManagementScreen

**File**: `/components/admin/AdminUserManagementScreen.tsx`

**Purpose**: Manage all platform users.

**Props**:
```typescript
interface AdminUserManagementScreenProps {
  adminId: string;
}
```

**State**:
```typescript
const [users, setUsers] = useState<User[]>([]);
const [filters, setFilters] = useState<UserFilters>({ tier: 'all', status: 'all' });
const [searchQuery, setSearchQuery] = useState<string>('');
const [selectedUser, setSelectedUser] = useState<User | null>(null);
```

**Key Features**:
- User table with pagination
- Filter by tier, status, date
- Search by name, phone, email
- View user details
- Edit subscription tier
- Suspend/activate users
- View user activity log

**Usage**:
```typescript
<AdminUserManagementScreen adminId={adminId} />
```

---

### 21. AdminCoachManagementScreen

**File**: `/components/admin/AdminCoachManagementScreen.tsx`

**Purpose**: Manage all coaches on platform.

**Props**:
```typescript
interface AdminCoachManagementScreenProps {
  adminId: string;
}
```

**State**:
```typescript
const [coaches, setCoaches] = useState<Coach[]>([]);
const [selectedCoach, setSelectedCoach] = useState<Coach | null>(null);
```

**Key Features**:
- Coach table with performance metrics
- Add new coach
- Edit coach profile
- View assigned clients
- View ratings and feedback
- Deactivate coach

**Usage**:
```typescript
<AdminCoachManagementScreen adminId={adminId} />
```

---

### 22. AdminContentManagementScreen

**File**: `/components/admin/AdminContentManagementScreen.tsx`

**Purpose**: Manage exercises and meals library.

**Props**:
```typescript
interface AdminContentManagementScreenProps {
  adminId: string;
}
```

**State**:
```typescript
const [contentType, setContentType] = useState<'exercises' | 'meals'>('exercises');
const [exercises, setExercises] = useState<Exercise[]>([]);
const [meals, setMeals] = useState<Meal[]>([]);
```

**Key Features**:
- Exercise library management
- Meal library management
- Add/edit/delete content
- Upload media (images, videos)
- Tag exercises (muscle groups, equipment, difficulty)
- Mark injury contraindications

**Usage**:
```typescript
<AdminContentManagementScreen adminId={adminId} />
```

---

### 23-26. Other Admin Screens

- **AdminSubscriptionManagementScreen**: Manage subscription plans and pricing
- **AdminAnalyticsScreen**: Detailed analytics and reports
- **AdminSystemConfigScreen**: System settings and feature flags
- **AdminAuditLogScreen**: System audit trail

---

## Shared Components

### QuotaDisplay

**File**: `/components/QuotaDisplay.tsx`

**Purpose**: Shows quota usage for messages and video calls.

**Props**:
```typescript
interface QuotaDisplayProps {
  quotaStatus: QuotaStatus;
  userTier: SubscriptionTier;
  onUpgrade?: () => void;
}
```

**Usage**:
```typescript
<QuotaDisplay 
  quotaStatus={quotaStatus}
  userTier={userProfile.subscriptionTier}
  onUpgrade={() => navigate('/upgrade')}
/>
```

---

### NutritionExpiryBanner

**File**: `/components/NutritionExpiryBanner.tsx`

**Purpose**: Shows countdown for Freemium nutrition trial.

**Props**:
```typescript
interface NutritionExpiryBannerProps {
  daysLeft: number;
  onUpgrade: () => void;
}
```

**Usage**:
```typescript
<NutritionExpiryBanner 
  daysLeft={3}
  onUpgrade={() => navigate('/upgrade')}
/>
```

---

### UpgradePrompt

**File**: `/components/UpgradePrompt.tsx`

**Purpose**: Reusable upgrade prompt for gated features.

**Props**:
```typescript
interface UpgradePromptProps {
  feature: string;
  requiredTier: SubscriptionTier;
  currentTier: SubscriptionTier;
  onUpgrade: () => void;
  onDismiss?: () => void;
}
```

**Usage**:
```typescript
<UpgradePrompt 
  feature="InBody Tracking"
  requiredTier="Premium"
  currentTier={userProfile.subscriptionTier}
  onUpgrade={() => navigate('/upgrade')}
/>
```

---

### DemoModeIndicator

**File**: `/components/DemoModeIndicator.tsx`

**Purpose**: Shows banner when app is in demo mode (no backend).

**Props**: None

**Usage**:
```typescript
{isDemoMode && <DemoModeIndicator />}
```

---

## UI Components (Radix-based)

All UI components are located in `/components/ui/` and are built on Radix UI primitives.

### Button

**File**: `/components/ui/button.tsx`

**Variants**: `default`, `destructive`, `outline`, `ghost`, `link`

**Sizes**: `sm`, `default`, `lg`

**Usage**:
```typescript
import { Button } from './ui/button';

<Button variant="default" size="lg" onClick={handleClick}>
  {t('common.save')}
</Button>
```

---

### Dialog

**File**: `/components/ui/dialog.tsx`

**Components**: `Dialog`, `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`

**Usage**:
```typescript
import { Dialog, DialogTrigger, DialogContent } from './ui/dialog';

<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>
      <DialogDescription>Description</DialogDescription>
    </DialogHeader>
    {/* Content */}
  </DialogContent>
</Dialog>
```

---

### Card

**File**: `/components/ui/card.tsx`

**Components**: `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`

**Usage**:
```typescript
import { Card, CardHeader, CardTitle, CardContent } from './ui/card';

<Card>
  <CardHeader>
    <CardTitle>Workout Plan</CardTitle>
  </CardHeader>
  <CardContent>
    {/* Content */}
  </CardContent>
</Card>
```

---

### Other UI Components

- **Input**: Text inputs with validation
- **Textarea**: Multi-line text input
- **Select**: Dropdown select
- **Checkbox**: Checkbox input
- **RadioGroup**: Radio button group
- **Switch**: Toggle switch
- **Slider**: Range slider
- **Progress**: Progress bar
- **Toast**: Notification toasts (Sonner)
- **Skeleton**: Loading placeholders
- **Tabs**: Tabbed interface
- **Accordion**: Collapsible sections
- **Avatar**: User profile pictures
- **Badge**: Status badges
- **Tooltip**: Hover tooltips

---

## Component Patterns

### Pattern 1: Screen Wrapper

All screen components follow this structure:

```typescript
export function ScreenName({ ...props }: ScreenNameProps) {
  const { t, language } = useLanguage();
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    loadData();
  }, []);
  
  if (loading) return <ScreenSkeleton />;
  if (error) return <ErrorScreen error={error} />;
  
  return (
    <div className="screen-container">
      <Header />
      <main>
        {/* Screen content */}
      </main>
      <Footer />
    </div>
  );
}
```

---

### Pattern 2: Form Handling

```typescript
const [formData, setFormData] = useState<FormData>(initialData);
const [errors, setErrors] = useState<Record<string, string>>({});

const validate = (): boolean => {
  const newErrors: Record<string, string> = {};
  
  if (!formData.name) newErrors.name = t('errors.required');
  if (formData.age < 13) newErrors.age = t('errors.minAge');
  
  setErrors(newErrors);
  return Object.keys(newErrors).length === 0;
};

const handleSubmit = async () => {
  if (!validate()) return;
  
  try {
    await submitForm(formData);
    toast.success(t('success.saved'));
  } catch (error) {
    toast.error(t('errors.saveFailed'));
  }
};
```

---

### Pattern 3: Conditional Rendering

```typescript
const renderContent = () => {
  if (userTier === 'Freemium' && feature.requiresPremium) {
    return <UpgradePrompt feature={feature.name} />;
  }
  
  if (!hasSecondIntake && feature.requiresProfile) {
    return <CompleteProfilePrompt />;
  }
  
  return <FeatureContent />;
};
```

---

**Total Components Documented**: 28 screens + 15 shared + 20+ UI = 60+ components

**End of Component Reference Guide**
