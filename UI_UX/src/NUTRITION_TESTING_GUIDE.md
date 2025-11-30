# Nutrition Flow Testing Guide

## Overview
The nutrition feature has a complete onboarding flow that varies based on user subscription tier and completion status. This guide explains how to test different scenarios.

## User Data Persistence
All nutrition data is stored in localStorage with user-specific keys based on phone number:
- `nutrition_preferences_completed_{phoneNumber}` - Whether user completed intake
- `nutrition_preferences_{phoneNumber}` - User's nutrition preferences data
- `pending_nutrition_intake_{phoneNumber}` - Flag for users who just upgraded
- `was_freemium_{phoneNumber}` - Tracks if user was previously Freemium

## Testing Different Users

### Method 1: Log Out and Log In
1. Log out from the current user (Account → Logout)
2. Log in with a **different phone number** (e.g., +966501234567, +966507654321)
3. Each phone number maintains its own nutrition data
4. You can switch between users to see their individual states

### Method 2: Use Debug Panel
1. Navigate to Nutrition screen
2. Triple-click on "Nutrition" header text
3. Debug panel will open
4. Click "🔄 Reset for New User Testing" to clear current user's nutrition data
5. Navigate back to home, then to nutrition to see the flow again

## User Flow Scenarios

### Scenario 1: New Premium User (First Time)
**User:** Premium or Smart Premium tier, never visited Nutrition before
**Expected Flow:**
1. User navigates to Nutrition screen
2. **Welcome Screen** appears with:
   - Green header
   - Sparkles icon
   - Feature list
   - "Start Nutrition Setup" button
3. User clicks "Start Nutrition Setup"
4. **Nutrition Preferences Intake** form appears (multi-step)
5. User completes all steps
6. **Main Nutrition Tracking** screen appears with personalized data

### Scenario 2: Returning Premium User
**User:** Premium user who already completed intake
**Expected Flow:**
1. User navigates to Nutrition screen
2. **Main Nutrition Tracking** screen appears directly (no welcome/intake)
3. Shows personalized macros, meals, and progress

### Scenario 3: Freemium User
**User:** Freemium tier
**Expected Flow:**
1. User navigates to Nutrition screen
2. **Locked Screen** appears with:
   - Lock icon
   - Feature benefits
   - "Upgrade Now" button
3. User cannot access nutrition tracking

### Scenario 4: User Upgrades from Freemium to Premium
**Expected Flow:**
1. User starts as Freemium (sees locked screen)
2. User clicks "Upgrade Now" and selects Premium/Smart Premium
3. After upgrade, automatically returns to Nutrition screen
4. **Welcome Screen** appears
5. User clicks "Start Nutrition Setup"
6. **Nutrition Preferences Intake** appears
7. User completes intake
8. **Main Nutrition Tracking** screen appears

### Scenario 5: User Upgrades from Other Screens
**Expected Flow:**
1. User is Freemium, upgrades from HomeScreen or AccountScreen
2. Pending intake flag is set
3. User navigates to Nutrition screen
4. **Welcome Screen** appears (intake is pending)
5. Rest of flow continues as Scenario 4

## Debug Panel Features

Access: Triple-click "Nutrition" header text on Nutrition screen

### Information Displayed
- **User Info**: Phone number, subscription tier
- **LocalStorage Flags**: Current state of all nutrition flags
- **Expected Behavior**: What should happen based on current state

### Quick Actions
1. **Simulate Upgrade**: Sets pending intake flag (for Premium users)
2. **Mark as Completed**: Marks intake as done without doing it
3. **🔄 Reset for New User Testing**: Clears all nutrition data for current user
4. **Refresh**: Reloads current flag states

## Testing Checklist

### Test as New Premium User
- [ ] Welcome screen appears
- [ ] Welcome screen has green header with ChefHat icon
- [ ] Three features are listed
- [ ] "Start Nutrition Setup" button works
- [ ] Intake form appears with multiple steps
- [ ] Can complete all intake steps
- [ ] Main tracking screen appears after completion
- [ ] Data persists on revisit (no welcome/intake shown)

### Test as New Freemium User
- [ ] Locked screen appears
- [ ] Lock icon is visible
- [ ] "Upgrade Now" button is present
- [ ] Cannot access nutrition features

### Test Upgrade Flow
- [ ] Start as Freemium user
- [ ] Upgrade via Nutrition screen
- [ ] Welcome screen appears automatically
- [ ] Can complete intake
- [ ] Data is saved

### Test Different Users
- [ ] Log out
- [ ] Log in with User A (+966501111111)
- [ ] Complete intake as User A
- [ ] Log out
- [ ] Log in with User B (+966502222222)
- [ ] User B sees welcome/intake (not User A's data)
- [ ] Log back in as User A
- [ ] User A sees their tracking screen (completed state)

### Test Arabic/RTL Support
- [ ] Switch language to Arabic
- [ ] Welcome screen displays RTL correctly
- [ ] Intake form displays RTL correctly
- [ ] All text is in Arabic

## Console Logging

All nutrition flow logic logs to console with `[NutritionScreen]` prefix. Open DevTools (F12) to see:
- Component initialization
- State changes
- Flag checks
- User actions
- Screen transitions

## Common Issues

### Issue: Welcome screen doesn't show for new Premium user
**Solution:** 
- Open debug panel
- Check if `nutrition_preferences_completed` flag is set to 'true'
- Click "Reset for New User Testing"
- Reload nutrition screen

### Issue: Intake shows every time
**Solution:**
- Check console logs for state initialization
- Verify `nutrition_preferences_completed_{phoneNumber}` is being set on completion
- May need to check handlePreferencesComplete function

### Issue: Different user sees previous user's data
**Solution:**
- This should NOT happen - data is phone number specific
- Check console to verify correct phone number is being used
- May indicate a caching issue - try hard refresh (Ctrl+Shift+R)

## InBody Values Precision

All InBody numeric values are now rounded to **3 decimal places**:
- Weight: 70.500 kg (not 70.5)
- BMI: 22.500 (not 22.5)
- Body Fat %: 18.500% (not 18.5)
- All other measurements follow same pattern

Input fields accept 0.001 step precision for accurate data entry.

## Additional Notes

- Language preference persists across logout
- Nutrition data is user-specific (phone number based)
- Each user can have different subscription tiers
- Welcome screen → Intake → Tracking is one-time per user
- Upgrade flow automatically triggers welcome/intake sequence
- Triple-click header is for development/testing only
