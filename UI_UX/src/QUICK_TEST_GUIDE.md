# Quick Test Guide - Coach Profile Features

## How to Test as Client 👤

1. **Login as Regular User**
   - Use demo mode OR
   - Login with regular user account

2. **Navigate to Coach Tab**
   - Tap "Coach" in bottom navigation
   - You should see your assigned coach card

3. **View Coach Profile**
   - Look for "View Coach Profile" button under coach specialties
   - Tap the button
   - PublicCoachProfileScreen opens

4. **Explore Coach Credentials**
   - See coach's professional header (name, rating, experience)
   - View quick stats (clients, sessions, success rate)
   - Tap through tabs:
     - **Overview**: Bio and contact info
     - **Certificates**: Professional certifications
     - **Experience**: Work history
     - **Achievements**: Awards and medals

5. **Test Contact Actions**
   - Tap "Send Message" → Should go to Coach messaging
   - Tap "Book Call" → Should go to Coach sessions

6. **Return to Coach Tab**
   - Tap back arrow in header
   - Should return to Coach screen

## How to Test as Coach 👨‍🏫

1. **Login as Coach**
   - Use demo mode with coach account OR
   - Login with coach credentials

2. **Access Your Profile**
   - On Coach Dashboard
   - Look for User icon (👤) in header (next to Settings)
   - Tap User icon
   - CoachProfileScreen opens

3. **Edit Your Bio**
   - Go to Overview tab
   - Tap "Edit" button on Bio section
   - Change the bio text
   - Tap checkmark (✓) to save
   - Should see toast: "Bio updated successfully"
   - Tap X to cancel without saving

4. **Edit Contact Info**
   - Tap "Edit" on Contact Information section
   - Change email or phone
   - Tap save (✓)
   - Should see toast: "Profile updated successfully"

5. **View Your Credentials**
   - **Certificates Tab**: See all your certifications
     - View issue/expiry dates
     - See issuing organizations
   - **Experience Tab**: Review work history
     - Current positions marked with green "Current" badge
     - See timeline of all positions
   - **Achievements Tab**: View awards and medals
     - Color-coded icons (gold, purple, blue)
     - Categories: medal, award, recognition

6. **Check Your Stats**
   - View quick stats at top:
     - Total Clients
     - Completed Sessions  
     - Success Rate
     - Monthly Revenue (only visible to you)

7. **Return to Dashboard**
   - Tap back arrow
   - Should return to Coach Dashboard

## Visual Indicators to Look For

### Client View (PublicCoachProfileScreen)
```
✅ Purple/Indigo gradient header
✅ "Your Coach" title
✅ Verified badge (✓ Verified Coach)
✅ Star rating (⭐ 4.8)
✅ Active clients count
✅ Years of experience
✅ Specialization badges
✅ "Send Message" and "Book Call" buttons
✅ 3 stat cards (no revenue shown)
✅ Certificates with blue icons (🏆)
✅ Experience with purple icons (📚)
✅ Achievements with colored icons (🥇🏆⭐)
✅ Empty states if no data
```

### Coach View (CoachProfileScreen)
```
✅ Purple/Indigo gradient header
✅ "My Profile" title
✅ Settings icon in header
✅ Verified badge
✅ Star rating with review count
✅ 4 stat cards (including revenue)
✅ Edit buttons on bio and contact sections
✅ Save/Cancel buttons when editing
✅ "Add Certificate" button
✅ "Add Experience" button
✅ "Add Achievement" button
✅ Current position indicator (green badge)
✅ Achievement type badges (outline style)
```

## Expected Behaviors

### Buttons Should Work
| Button | Expected Result |
|--------|----------------|
| View Coach Profile | Open PublicCoachProfileScreen |
| Send Message | Navigate to Coach messaging tab |
| Book Call | Navigate to Coach sessions tab |
| Back Arrow | Return to previous screen |
| Edit (Bio) | Show textarea with save/cancel |
| Save (✓) | Save changes + show toast |
| Cancel (X) | Discard changes + hide editor |
| Add Certificate | Open add certificate dialog (future) |
| Add Experience | Open add experience dialog (future) |
| Add Achievement | Open add achievement dialog (future) |

### Tabs Should Display
| Tab | What You Should See |
|-----|---------------------|
| Overview | Bio section + Contact info |
| Certificates | List of 3 certifications OR empty state |
| Experience | Timeline of 2 jobs OR empty state |
| Achievements | List of 3 awards OR empty state |

### RTL (Arabic) Should Work
- All elements flip direction
- Text alignment changes
- Icons move to correct side
- Buttons maintain proper spacing
- Badges align correctly

## Common Issues & Solutions

### Issue: "View Coach Profile" button not showing
**Solution:** Check that `onViewCoachProfile` prop is passed to CoachScreen in App.tsx

### Issue: User icon not showing in coach dashboard
**Solution:** Verify `onEditProfile` prop is passed to CoachDashboard in App.tsx

### Issue: Tooltip warning in console
**Solution:** Already fixed with TooltipProvider wrapper

### Issue: Translations not showing
**Solution:** Check LanguageContext.tsx has all 58 coach profile translation keys

### Issue: Back button doesn't work
**Solution:** Verify navigation handlers in App.tsx are correct

### Issue: Stats not displaying
**Solution:** Check mock data is being loaded from getMockCoachData()

## Demo Data Included

### Mock Coach Profile
- **Name:** Ahmad Al-Rashid
- **Email:** ahmad.coach@fitcoach.com
- **Phone:** +966 50 123 4567
- **Rating:** 4.8 ⭐
- **Total Clients:** 87
- **Active Clients:** 45
- **Sessions:** 1,240
- **Success Rate:** 92%
- **Experience:** 8 years

### Certifications (3)
1. Certified Personal Trainer (CPT) - NASM
2. Nutrition Specialist - ISSA
3. Advanced Strength & Conditioning - NSCA

### Experience (2)
1. Senior Fitness Coach - Elite Fitness Center (Current)
2. Personal Trainer - Gold's Gym (2017-2019)

### Achievements (3)
1. Top Trainer of the Year 2023 (Award)
2. National Bodybuilding Championship - 1st Place (Medal)
3. Client Success Award (Recognition)

## Quick Verification Checklist

### For Clients
- [ ] Can see Coach tab in navigation
- [ ] Coach card displays with name and specialties
- [ ] "View Coach Profile" button is visible
- [ ] Clicking button opens coach profile
- [ ] All 4 tabs are accessible
- [ ] Can see certificates, experience, achievements
- [ ] "Send Message" button works
- [ ] "Book Call" button works
- [ ] Back button returns to Coach tab
- [ ] Profile displays in correct language
- [ ] RTL works in Arabic

### For Coaches
- [ ] Can see Coach Dashboard
- [ ] User icon (👤) visible in header
- [ ] Clicking icon opens profile editor
- [ ] Can edit bio section
- [ ] Can edit contact info
- [ ] Save shows success toast
- [ ] Cancel discards changes
- [ ] All tabs display correctly
- [ ] Stats show including revenue
- [ ] Back button returns to dashboard
- [ ] Profile displays in correct language
- [ ] RTL works in Arabic

## Performance Checks

### Should Load Fast
- ✅ Profile opens instantly (mock data)
- ✅ Tab switching is smooth
- ✅ Edit mode toggles quickly
- ✅ Navigation is immediate

### Should Be Responsive
- ✅ Works on mobile viewport (375px+)
- ✅ Adapts to tablet sizes
- ✅ Buttons are touch-friendly
- ✅ Text is readable

## Accessibility Checks

- [ ] Can tab through all interactive elements
- [ ] Buttons have proper labels
- [ ] Icons have semantic meaning
- [ ] Color contrast is sufficient
- [ ] Focus indicators are visible
- [ ] Screen reader compatible

## Browser Testing

Recommended browsers:
- ✅ Chrome/Edge (Chromium)
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers

## Summary

**Two distinct experiences:**

1. **Client View** (PublicCoachProfileScreen)
   - Read-only
   - Focused on trust and credibility
   - Contact actions prominent
   - No revenue shown

2. **Coach View** (CoachProfileScreen)
   - Fully editable
   - Professional management
   - Add credentials
   - Track statistics

**Both fully integrated and working!** ✅

---

**Quick Start:**
1. Run app
2. Login as client → Go to Coach tab → Tap "View Coach Profile"
3. Login as coach → Tap User icon in header → Edit your profile

That's it! 🎉
