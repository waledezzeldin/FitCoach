# Nutrition Flow - Quick Reference Card

## 🎯 Quick Actions

### Test as Different User
```
1. Logout (Account screen)
2. Login with different phone (e.g., +966501234567)
3. Navigate to Nutrition
4. See fresh welcome screen
```

### Reset Current User's Data
```
1. Go to Nutrition screen
2. Triple-click "Nutrition" header
3. Click "🔄 Reset for New User Testing"
4. Navigate back to home, then to Nutrition
5. See welcome screen again
```

### Check User's Nutrition State
```
1. Triple-click "Nutrition" header
2. View all localStorage flags
3. Check "Expected Behavior" section
```

## 🔑 localStorage Keys

All keys are user-specific (includes phone number):
```
nutrition_preferences_completed_{phoneNumber}  → 'true' | null
nutrition_preferences_{phoneNumber}            → JSON object | null
pending_nutrition_intake_{phoneNumber}         → 'true' | null
was_freemium_{phoneNumber}                     → 'true' | null
```

## 📱 User Flow States

| User Type | First Visit | After Completion |
|-----------|-------------|------------------|
| Freemium | 🔒 Locked Screen | 🔒 Locked Screen |
| New Premium | ✨ Welcome → 📝 Intake | 📊 Tracking |
| Returning Premium | 📊 Tracking | 📊 Tracking |
| Just Upgraded | ✨ Welcome → 📝 Intake | 📊 Tracking |

## 🎨 Screen Components

```
NutritionScreen (Main Container)
│
├─ NutritionWelcomeScreen      [Green header, Sparkles icon]
│  └─ onClick: Show Intake
│
├─ NutritionPreferencesIntake  [Multi-step form]
│  └─ onComplete: Save & Show Tracking
│
├─ Main Tracking UI            [Macros, Meals, Progress]
│
├─ Locked Screen               [For Freemium users]
│
└─ NutritionDebugPanel         [Triple-click to open]
```

## 🐛 Debug Features

### Console Logs
```javascript
// All logs prefixed with:
[NutritionScreen] ...

// Open DevTools (F12) → Console tab
```

### Debug Panel Access
```
Triple-click "Nutrition" header text
```

### Debug Panel Actions
- **Simulate Upgrade** - Set pending intake flag
- **Mark as Completed** - Skip intake, show tracking
- **🔄 Reset for New User Testing** - Clear all data
- **Refresh** - Reload flag states

## 🧪 Testing Scenarios

### ✅ Scenario 1: New Premium User
```
1. Premium tier, never visited Nutrition
2. Expected: Welcome → Intake → Tracking
3. Test: Complete full flow
```

### ✅ Scenario 2: Returning User
```
1. Already completed intake
2. Expected: Direct to Tracking
3. Test: Navigate away and back
```

### ✅ Scenario 3: Freemium User
```
1. Freemium tier
2. Expected: Locked screen with upgrade button
3. Test: Can't access features
```

### ✅ Scenario 4: Upgrade from Freemium
```
1. Start as Freemium
2. Click "Upgrade Now"
3. Select Premium/Smart Premium
4. Expected: Auto-show Welcome screen
5. Test: Complete intake
```

### ✅ Scenario 5: Different Users
```
1. Login as User A (+966501111111)
2. Complete intake
3. Logout
4. Login as User B (+966502222222)
5. Expected: User B sees Welcome (not User A's data)
6. Test: Each user has independent data
```

## 📊 InBody Precision

All numeric values: **3 decimal places**
```javascript
Weight:  70.500 kg  (not 70.5)
BMI:     22.500     (not 22.5)
Fat %:   18.500%    (not 18.5%)
```

Input step: `0.001` for precise entry

## 🌐 RTL Support

All screens support Arabic/RTL:
- Welcome screen
- Intake form
- Tracking dashboard
- Debug panel

## 💾 Data Persistence

### What Persists
- ✅ Nutrition preferences (phone-specific)
- ✅ Completion flags (phone-specific)
- ✅ Language selection (global)

### What Doesn't Persist
- ❌ Current screen state
- ❌ Temporary UI states
- ❌ Session data

## 🚨 Common Issues

### Issue: Welcome screen not showing
**Fix:** Open debug panel → Check `nutrition_preferences_completed` → Should be `null` or not `'true'`

### Issue: Shows intake every time
**Fix:** Check console logs → Verify `handlePreferencesComplete` is called → Check localStorage is saving

### Issue: Different user sees old data
**Fix:** Should NOT happen - each phone has separate keys → Check phone number is correct

### Issue: Can't test flow again
**Fix:** Use debug panel → Click "🔄 Reset for New User Testing"

## 🎯 Example Phone Numbers

For testing different users:
```
+966501234567
+966507654321
+966509876543
+966505555555
+1234567890
```

## 🔍 Where to Look

### Code Files
```
/components/NutritionWelcomeScreen.tsx    - Welcome UI
/components/NutritionScreen.tsx           - Main logic
/components/NutritionPreferencesIntake.tsx - Intake form
/components/NutritionDebugPanel.tsx       - Testing tools
/components/DemoUserSwitcher.tsx          - Multi-user widget
/components/InBodyInputScreen.tsx         - InBody precision
```

### Documentation
```
/NUTRITION_TESTING_GUIDE.md              - Comprehensive testing guide
/NUTRITION_FLOW_REFACTOR_SUMMARY.md      - Technical details
/NUTRITION_QUICK_REFERENCE.md            - This file
```

## 🎬 Quick Start Testing

### 1-Minute Test
```bash
1. Ensure you're in demo mode
2. See "Multi-User Testing" button (bottom-right)
3. Click it to see current phone number
4. Navigate to Nutrition
5. Triple-click header to open debug panel
6. Click "Reset for New User Testing"
7. Go back to home, then Nutrition
8. See welcome screen → intake flow
```

## 📞 Support

Questions? Check:
1. Console logs (F12)
2. Debug panel (triple-click header)
3. Testing guide (/NUTRITION_TESTING_GUIDE.md)
4. Refactor summary (/NUTRITION_FLOW_REFACTOR_SUMMARY.md)

---

**Last Updated:** Sunday, November 9, 2025
**Version:** 2.0
**Status:** ✅ Production Ready
