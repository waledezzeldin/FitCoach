# Nutrition Intake on Upgrade - Implementation Summary

## Overview
When a user upgrades from Freemium to Premium or Smart Premium (plans that support nutrition), they will be prompted to complete the nutrition preferences intake on their first visit to the Nutrition screen.

## Implementation Details

### 1. Upgrade Detection Flow

#### From Any Screen (HomeScreen, AccountScreen, or NutritionScreen)
When a user upgrades their subscription:
1. The `handleSubscriptionUpgrade` function is called with the new tier
2. The function checks if the user is upgrading from Freemium to a paid plan
3. If the user hasn't completed nutrition preferences, it sets a flag in localStorage: `pending_nutrition_intake_${phoneNumber}`

#### Code Changes in HomeScreen.tsx and AccountScreen.tsx
```typescript
const handleSubscriptionUpgrade = (newTier: SubscriptionTier) => {
  const updatedProfile: UserProfile = {
    ...userProfile,
    subscriptionTier: newTier
  };
  onUpdateProfile(updatedProfile);
  
  // If upgrading from Freemium to a paid plan with nutrition
  if (userProfile.subscriptionTier === 'Freemium' && newTier !== 'Freemium') {
    const hasCompletedNutrition = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`) === 'true';
    if (!hasCompletedNutrition) {
      localStorage.setItem(`pending_nutrition_intake_${userProfile.phoneNumber}`, 'true');
    }
  }
};
```

### 2. NutritionScreen Detection

#### On Component Load
The NutritionScreen uses `useEffect` to detect:
1. If the user was Freemium and is now on a paid plan
2. If there's a pending nutrition intake flag
3. If the user hasn't completed nutrition preferences

```typescript
useEffect(() => {
  const wasFreemium = localStorage.getItem(`was_freemium_${userProfile.phoneNumber}`);
  const isNowPaid = userProfile.subscriptionTier !== 'Freemium';
  const hasCompletedFlag = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`) === 'true';
  const pendingNutritionIntake = localStorage.getItem(`pending_nutrition_intake_${userProfile.phoneNumber}`) === 'true';
  
  if (wasFreemium === 'true' && isNowPaid && !hasCompletedFlag) {
    // User just upgraded - mark intake as pending
    localStorage.setItem(`pending_nutrition_intake_${userProfile.phoneNumber}`, 'true');
    localStorage.removeItem(`was_freemium_${userProfile.phoneNumber}`);
    setHasCompletedPreferences(false);
  } else if (pendingNutritionIntake && isNowPaid && !hasCompletedFlag) {
    // User upgraded earlier - intake is still pending
    setHasCompletedPreferences(false);
  } else if (userProfile.subscriptionTier === 'Freemium') {
    // Track Freemium status
    localStorage.setItem(`was_freemium_${userProfile.phoneNumber}`, 'true');
    setHasCompletedPreferences(false);
  }
}, [userProfile.subscriptionTier, userProfile.phoneNumber]);
```

#### Initial State Check
```typescript
const [hasCompletedPreferences, setHasCompletedPreferences] = useState(() => {
  // Freemium users can't have completed preferences
  if (userProfile.subscriptionTier === 'Freemium') {
    return false;
  }
  
  // Check if preferences were already completed
  const storedFlag = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`);
  if (storedFlag === 'true') {
    return true;
  }
  
  // Demo users get auto-completion
  return isDemoMode && userProfile.subscriptionTier !== 'Freemium';
});
```

### 3. Showing the Intake Screen

When `!isLocked && !hasCompletedPreferences` is true, the NutritionScreen displays:
1. A welcome card explaining nutrition features
2. A button to start the nutrition preferences intake
3. The full `NutritionPreferencesIntake` component when clicked

### 4. Completion Flow

When the user completes the nutrition preferences:
```typescript
const handlePreferencesComplete = (preferences: NutritionPreferences) => {
  setNutritionPreferences(preferences);
  setHasCompletedPreferences(true);
  setShowPreferencesIntake(false);
  
  // Save to localStorage
  localStorage.setItem(`nutrition_preferences_${userProfile.phoneNumber}`, JSON.stringify(preferences));
  localStorage.setItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`, 'true');
  
  // Clear pending intake flag
  localStorage.removeItem(`pending_nutrition_intake_${userProfile.phoneNumber}`);
};
```

## LocalStorage Keys Used

1. **`pending_nutrition_intake_${phoneNumber}`** - Set to 'true' when user upgrades from Freemium, cleared when intake is completed
2. **`nutrition_preferences_completed_${phoneNumber}`** - Set to 'true' when user completes the intake
3. **`nutrition_preferences_${phoneNumber}`** - Stores the actual nutrition preferences JSON
4. **`was_freemium_${phoneNumber}`** - Tracks if user was previously on Freemium plan

## User Experience Flow

### Scenario 1: Upgrade from NutritionScreen
1. User is on Freemium, visits locked NutritionScreen
2. User clicks "Upgrade Now"
3. User selects Premium or Smart Premium
4. After upgrade, screen automatically shows welcome card
5. User clicks "Start Nutrition Setup"
6. User completes NutritionPreferencesIntake
7. User sees personalized nutrition tracking

### Scenario 2: Upgrade from HomeScreen or AccountScreen
1. User is on Freemium, visits HomeScreen or AccountScreen
2. User upgrades to Premium or Smart Premium
3. Pending nutrition intake flag is set in localStorage
4. User navigates to Nutrition screen (now unlocked)
5. Screen detects pending intake and shows welcome card
6. User clicks "Start Nutrition Setup"
7. User completes NutritionPreferencesIntake
8. User sees personalized nutrition tracking

### Scenario 3: Already Completed Intake
1. User has Premium/Smart Premium
2. User has already completed nutrition intake
3. User visits Nutrition screen
4. Screen shows normal nutrition tracking (no intake prompt)

## Benefits

✅ **Seamless Upgrade Experience** - Users are automatically prompted for nutrition preferences after upgrading
✅ **Persistent State** - Works even if user navigates away and comes back later
✅ **One-Time Only** - Intake is shown only once per user
✅ **Multi-Screen Support** - Works regardless of where the upgrade happens
✅ **Demo Mode Compatible** - Handles demo users appropriately

## Testing Scenarios

1. **Fresh Freemium User** - Should not see nutrition screen content
2. **Upgrade in NutritionScreen** - Should see intake immediately
3. **Upgrade in HomeScreen** - Should see intake on next nutrition visit
4. **Upgrade in AccountScreen** - Should see intake on next nutrition visit
5. **Navigate Away During Intake** - Should resume intake on return
6. **Complete Intake** - Should not see intake again
7. **Already Premium User** - Should see intake on first visit
8. **Demo Mode** - Should auto-complete for paid demo users
