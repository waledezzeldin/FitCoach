# Generate Custom Plan Fix

## Problems Identified

### Problem 1: Profile Data Being Overwritten

When a user who already had a profile completed the second intake, their entire profile was being overwritten with default values, losing their:

- Real phone number (replaced with `+966501234567`)
- Authentication data
- Subscription tier (reset to `Freemium`)
- InBody history
- Coach assignment
- Other existing profile data

### Problem 2: Wrong Return Screen

After completing the second intake from WorkoutScreen, users were redirected to the home screen instead of returning to the workout screen where they came from.

### Problem 3: Dialog Not Closing

When users returned to WorkoutScreen after completing the second intake, the "Complete Your Profile" dialog would show again because the component didn't reactively update when `hasCompletedSecondIntake` changed.

## Root Causes

### Cause 1: Profile Overwrite
The `handleSecondIntakeComplete` function in `/App.tsx` always created a **brand new profile** instead of checking if the user already had an existing profile and updating it.

### Cause 2: Hardcoded Return Screen
The function always set `currentScreen: 'home'` regardless of where the user came from.

### Cause 3: State Not Reactive
The `showIntakePrompt` state in WorkoutScreen was initialized once but never updated when the profile changed.

```typescript
// ❌ BEFORE: Always created new profile
const handleSecondIntakeComplete = (data: SecondIntakeData) => {
  const firstIntake = appState.firstIntakeData!;
  
  const profile: UserProfile = {
    id: `user_${Date.now()}`,
    name: 'User',
    phoneNumber: '+966501234567', // ❌ Hardcoded!
    // ... rest of fields created from scratch
  };
  
  setAppState(prev => ({
    ...prev,
    userProfile: profile, // ❌ Overwrites existing profile!
  }));
};
```

## Solutions Implemented

### Solution 1: Smart Profile Update

Modified `handleSecondIntakeComplete` to check if a profile already exists:

1. **If profile exists** → UPDATE existing profile with second intake data
2. **If no profile** → CREATE new profile (original onboarding flow)

### Solution 2: Track Previous Screen

Added `previousScreen` field to `AppState` to track where the user was before navigating to second intake, then return them to that screen after completion.

### Solution 3: Reactive Dialog State

Added `useEffect` in WorkoutScreen to monitor `userProfile.hasCompletedSecondIntake` and automatically close the dialog when the value changes to `true`.

```typescript
// ✅ AFTER: Checks and updates existing profile
const handleSecondIntakeComplete = (data: SecondIntakeData) => {
  const calculateInitialScore = (experience: string) => {
    switch(experience) {
      case 'beginner': return 45;
      case 'intermediate': return 65;
      case 'advanced': return 80;
      default: return 50;
    }
  };
  
  // ✅ Check if user already has a profile
  if (appState.userProfile) {
    // UPDATE existing profile
    const updatedProfile: UserProfile = {
      ...appState.userProfile, // ✅ Preserve all existing data
      age: data.age,
      weight: data.weight,
      height: data.height,
      experienceLevel: data.experienceLevel,
      workoutFrequency: data.workoutFrequency,
      injuries: data.injuries,
      hasCompletedSecondIntake: true,
      // Only update fitness score if it was auto-generated
      ...(appState.userProfile.fitnessScoreUpdatedBy === 'auto' ? {
        fitnessScore: calculateInitialScore(data.experienceLevel),
        fitnessScoreLastUpdated: new Date(),
      } : {}),
    };

    setAppState(prev => ({
      ...prev,
      userProfile: updatedProfile,
      currentScreen: 'home',
    }));
  } else {
    // CREATE new profile (original onboarding flow)
    // ... create from scratch
  }
};
```

## Additional Fixes

### Fixed UserProfile Property Reference

The NutritionScreen was using `userProfile.phone` but the actual property name is `phoneNumber`.

**Changed in `/components/NutritionScreen.tsx`:**

```typescript
// ❌ BEFORE
localStorage.getItem(`nutrition_preferences_completed_${userProfile.phone}`)

// ✅ AFTER
localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`)
```

**8 occurrences fixed:**
1. `hasCompletedPreferences` state initialization
2. `nutritionPreferences` state initialization
3. `handlePreferencesComplete` - preferences storage
4. `handlePreferencesComplete` - completion flag storage
5. `useEffect` - wasFreemium check
6. `useEffect` - removeItem call
7. `useEffect` - setItem call
8. `useEffect` - dependency array

## Implementation Details

### AppState Interface Update

```typescript
export interface AppState {
  isAuthenticated: boolean;
  isDemoMode: boolean;
  userType: UserType;
  userProfile: UserProfile | null;
  currentScreen: Screen;
  hasCompletedOnboarding: boolean;
  hasSeenIntro: boolean;
  firstIntakeData: FirstIntakeData | null;
  previousScreen?: Screen; // ✅ NEW: Track where user came from
}
```

### Smart Navigation Function

```typescript
const navigateToScreen = (screen: Screen) => {
  setAppState(prev => {
    // If navigating to secondIntake, save current screen
    if (screen === 'secondIntake' && prev.currentScreen !== 'secondIntake') {
      return { 
        ...prev, 
        currentScreen: screen, 
        previousScreen: prev.currentScreen // ✅ Save origin
      };
    }
    return { ...prev, currentScreen: screen };
  });
};
```

### Return to Previous Screen

```typescript
// In handleSecondIntakeComplete:
if (appState.userProfile) {
  const updatedProfile: UserProfile = {
    ...appState.userProfile,
    // ... update fields
  };

  // ✅ Return to previous screen if available
  const returnScreen = appState.previousScreen || 'home';

  setAppState(prev => ({
    ...prev,
    userProfile: updatedProfile,
    currentScreen: returnScreen, // ✅ Navigate back
    previousScreen: undefined, // ✅ Clear tracking
  }));
}
```

### Reactive Dialog in WorkoutScreen

```typescript
// ✅ Monitor hasCompletedSecondIntake changes
React.useEffect(() => {
  if (userProfile.hasCompletedSecondIntake) {
    setShowIntakePrompt(false);
  }
}, [userProfile.hasCompletedSecondIntake]);
```

## User Flow

### Scenario 1: New User (Onboarding)

1. ✅ User completes auth
2. ✅ User completes First Intake
3. ✅ User completes Second Intake → "Generate Custom Plan"
4. ✅ **NEW** profile created with all data
5. ✅ User sees home screen

### Scenario 2: Existing User Completing Second Intake Later

1. ✅ User has existing profile (may have skipped second intake initially)
2. ✅ User navigates to Workout or other screens that show second intake prompt
3. ✅ User clicks to complete second intake
4. ✅ User completes Second Intake → "Generate Custom Plan"
5. ✅ **EXISTING** profile updated with new data
6. ✅ All existing data preserved (phone, subscription, coach, etc.)
7. ✅ User sees home screen with updated profile

### Scenario 3: Coach-Assigned Fitness Score Preserved

1. ✅ User has profile with coach-assigned fitness score
2. ✅ User completes second intake
3. ✅ Fitness score **NOT** updated (preserves coach's assignment)
4. ✅ Only auto-generated scores are updated

## What Data Gets Preserved

When updating an existing profile, the following data is **preserved**:

- ✅ User ID
- ✅ Name
- ✅ Phone number
- ✅ Email
- ✅ Subscription tier
- ✅ Coach ID
- ✅ InBody history
- ✅ Gender
- ✅ Main goal
- ✅ Workout location
- ✅ Coach-assigned fitness score (if exists)

## What Data Gets Updated

When updating an existing profile, the following data is **updated**:

- ✅ Age
- ✅ Weight
- ✅ Height
- ✅ Experience level
- ✅ Workout frequency
- ✅ Injuries
- ✅ `hasCompletedSecondIntake` flag
- ✅ Fitness score (only if auto-generated, not coach-assigned)

## Testing Checklist

### Profile Updates
- [x] ✅ New user onboarding creates profile correctly
- [x] ✅ Existing user completing second intake preserves all data
- [x] ✅ Phone number preserved
- [x] ✅ Subscription tier preserved
- [x] ✅ Coach assignment preserved
- [x] ✅ InBody history preserved
- [x] ✅ Coach-assigned fitness score not overwritten
- [x] ✅ Auto-generated fitness score updated based on new experience level
- [x] ✅ NutritionScreen localStorage keys use correct property name

### Navigation Flow
- [x] ✅ User from WorkoutScreen returns to WorkoutScreen
- [x] ✅ User from NutritionScreen returns to NutritionScreen
- [x] ✅ User from HomeScreen returns to HomeScreen
- [x] ✅ User during onboarding goes to HomeScreen
- [x] ✅ Dialog closes automatically when user returns to WorkoutScreen
- [x] ✅ Dialog doesn't show again after completion

### Edge Cases
- [x] ✅ Navigating directly to secondIntake (no previous screen) → goes to home
- [x] ✅ Clicking "Later" on dialog keeps dialog dismissible
- [x] ✅ Profile updates persist across navigation
- [x] ✅ Multiple navigations don't break previousScreen tracking

## Related Files

### Modified Files
- `/App.tsx` - Main app logic
  - Updated `AppState` interface with `previousScreen` field
  - Modified `handleSecondIntakeComplete` to update existing profiles
  - Enhanced `navigateToScreen` to track previous screen
  - Smart return navigation after intake completion
  
- `/components/WorkoutScreen.tsx` - Workout screen UI
  - Added `useEffect` to reactively close dialog
  - Dialog now responds to profile changes
  
- `/components/NutritionScreen.tsx` - Nutrition screen UI
  - Fixed 8 occurrences of `userProfile.phone` → `userProfile.phoneNumber`
  - localStorage keys now use correct property name

### Unchanged Files (reference only)
- `/components/SecondIntakeScreen.tsx` - Second intake UI
- `/types/IntakeTypes.ts` - Type definitions

## Impact

### Before Fix:
- ❌ User data lost when completing second intake from WorkoutScreen
- ❌ User forced back to default subscription
- ❌ Coach assignment lost
- ❌ Phone number reset to dummy value
- ❌ InBody history wiped
- ❌ User redirected to home instead of returning to workout
- ❌ Dialog reappeared even after completion
- ❌ NutritionScreen localStorage failing due to wrong property name

### After Fix:
- ✅ All user data preserved perfectly
- ✅ Only second intake fields updated
- ✅ User returns to the screen they came from
- ✅ Dialog automatically closes when user returns
- ✅ Dialog never shows again after completion
- ✅ Seamless experience across all screens
- ✅ No data loss anywhere
- ✅ Correct property names used throughout
- ✅ Smart navigation tracking

## Future Enhancements

1. **Validation**: Add validation to ensure critical fields aren't overwritten
2. **Audit Trail**: Log profile updates for debugging
3. **Backend Sync**: Sync profile updates to backend database
4. **Rollback**: Allow users to revert changes if needed
5. **Confirmation**: Show preview of changes before applying

## Complete User Flow Example

### Scenario: User from WorkoutScreen

1. ✅ User on WorkoutScreen
2. ✅ Dialog appears: "Complete Your Profile"
3. ✅ User clicks "Complete Intake" button
4. ✅ `previousScreen` saved as `'workout'`
5. ✅ Navigation to SecondIntakeScreen
6. ✅ User fills in:
   - Age: 28
   - Weight: 75kg
   - Height: 180cm
   - Experience: Intermediate
   - Frequency: 4 days/week
   - Injuries: Lower back
7. ✅ User clicks "Generate Custom Plan"
8. ✅ Existing profile updated (all data preserved)
9. ✅ Navigation back to `'workout'` screen
10. ✅ `useEffect` detects `hasCompletedSecondIntake = true`
11. ✅ Dialog automatically closes
12. ✅ User continues workout with updated profile
13. ✅ Dialog never appears again

### Scenario: New User Onboarding

1. ✅ User completes authentication
2. ✅ User completes First Intake
3. ✅ Navigation to SecondIntakeScreen
4. ✅ `previousScreen` is `undefined` (onboarding flow)
5. ✅ User completes Second Intake
6. ✅ NEW profile created with all data
7. ✅ Navigation to `'home'` (default for onboarding)
8. ✅ User sees home screen
9. ✅ Full onboarding complete

---

**Status:** ✅ FULLY FIXED AND TESTED
**Date:** October 29, 2025
**Version:** v2.0
**Files Modified:** 
- `/App.tsx` - Added previousScreen tracking, smart navigation, profile update logic
- `/components/WorkoutScreen.tsx` - Added reactive dialog state management
- `/components/NutritionScreen.tsx` - Fixed property name references (8 occurrences)
