# FitCoach+ v2.0 - Phase 1 Implementation Plan
## Critical User Features (Week 1-2)

This document provides detailed specifications for the 5 highest-priority screens to be implemented in Phase 1.

---

## 🎯 PHASE 1 OBJECTIVES

Implement the most critical missing features that directly impact user experience and fulfill v2.0 requirements:

1. ✅ **Enhanced CoachScreen** - Complete quota/rating/attachment integration
2. ✅ **Injury Substitution UI** - Safe exercise replacement system
3. ✅ **Meal Details & Food Logging** - Complete nutrition tracking
4. ✅ **Client Detail Screen** - Coach's comprehensive client view
5. ✅ **Coach Messaging Interface** - Individual client communication

---

## 1️⃣ ENHANCED COACHSCREEN

### File: `/components/CoachScreen.tsx` (MODIFY EXISTING)

### Requirements Met:
- v2.0: Quota enforcement for messages and calls per subscription tier
- v2.0: Post-interaction rating system
- v2.0: Gated chat attachments for Premium+ users

### Features to Add:

#### A. QuotaDisplay Integration
```typescript
// Add at the top of the screen (after header)
<QuotaDisplay 
  quota={quotaUsage}
  compact={false}
  showUpgradePrompt={userProfile.subscriptionTier === 'Freemium'}
  onUpgrade={() => setShowSubscriptionManager(true)}
/>
```

**Implementation Details:**
- Display current message and call usage
- Show warning when 80%+ quota used
- Block sending messages when quota exhausted
- Show upgrade prompt for Freemium users
- Reset monthly display

#### B. RatingModal Integration
```typescript
// Trigger after completing a video call
const [showRatingModal, setShowRatingModal] = useState(false);
const [lastCallId, setLastCallId] = useState<string | null>(null);

// After call ends
useEffect(() => {
  // Check if a call just ended
  if (hasCallJustEnded) {
    setShowRatingModal(true);
  }
}, [sessions]);

<RatingModal
  open={showRatingModal}
  onOpenChange={setShowRatingModal}
  interactionType="call"
  coachName={coach.name}
  onSubmit={handleRatingSubmit}
  onSkip={() => setShowRatingModal(false)}
/>
```

**Implementation Details:**
- Trigger automatically after video call completion
- Allow optional skip
- Save ratings to user profile
- Display confirmation toast

#### C. File Attachment Feature (Premium+ Only)
```typescript
// In messages tab
{userProfile.subscriptionTier === 'Smart Premium' ? (
  <Button 
    variant="ghost" 
    size="icon"
    onClick={handleAttachFile}
  >
    <Paperclip className="w-5 h-5" />
  </Button>
) : (
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" disabled>
        <Lock className="w-4 h-4" />
      </Button>
    </TooltipTrigger>
    <TooltipContent>
      {t('coach.attachmentRequiresPremiumPlus')}
    </TooltipContent>
  </Tooltip>
)}
```

**Implementation Details:**
- Show lock icon for Premium and Freemium users
- Allow image/PDF attachments for Smart Premium
- Max file size: 10MB
- Display attached files in message bubbles
- Preview images inline

#### D. Complete Booking Flow
```typescript
// Add booking dialog
const [showBookingDialog, setShowBookingDialog] = useState(false);

<Dialog open={showBookingDialog} onOpenChange={setShowBookingDialog}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>{t('coach.bookSession')}</DialogTitle>
    </DialogHeader>
    <Calendar
      mode="single"
      selected={selectedDate}
      onSelect={setSelectedDate}
      disabled={(date) => date < new Date()}
    />
    <Select value={selectedTime} onValueChange={setSelectedTime}>
      {availableTimes.map(time => (
        <SelectItem key={time} value={time}>{time}</SelectItem>
      ))}
    </Select>
    <DialogFooter>
      <Button onClick={handleConfirmBooking}>
        {t('coach.confirmBooking')}
      </Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

**Implementation Details:**
- Calendar view for date selection
- Time slot selection (30/60 min sessions)
- Check quota before allowing booking
- Confirmation with toast
- Add to sessions list as 'pending'

### New Translation Keys:
```typescript
'coach.quotaWarning': 'You have used {percent}% of your monthly quota',
'coach.quotaExhausted': 'Message quota reached. Upgrade to continue.',
'coach.attachmentRequiresPremiumPlus': 'File attachments are only available for Smart Premium subscribers',
'coach.rateYourSession': 'How was your session with {coach}?',
'coach.bookSession': 'Book a Session',
'coach.confirmBooking': 'Confirm Booking',
'coach.selectDate': 'Select Date',
'coach.selectTime': 'Select Time',
'coach.bookingConfirmed': 'Session booked successfully!',
// Arabic translations
'coach.quotaWarning': 'لقد استخدمت {percent}٪ من حصتك الشهرية',
'coach.quotaExhausted': 'تم الوصول إلى حد الرسائل. قم بالترقية للمتابعة.',
// ... etc
```

---

## 2️⃣ INJURY SUBSTITUTION INTERFACE

### File: `/components/WorkoutScreen.tsx` (MODIFY EXISTING)

### Requirements Met:
- v2.0: Injury substitution engine for safe exercise replacements

### Features to Add:

#### A. Report Injury Button
```typescript
// Add during exercise execution
{currentExercise.muscleGroup && (
  <Button
    variant="outline"
    size="sm"
    onClick={() => setShowInjuryDialog(true)}
  >
    <AlertTriangle className="w-4 h-4 mr-2" />
    {t('workouts.reportInjury')}
  </Button>
)}
```

#### B. Injury Reporting Dialog
```typescript
<Dialog open={showInjuryDialog} onOpenChange={setShowInjuryDialog}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>{t('workouts.injuryDialog.title')}</DialogTitle>
      <DialogDescription>
        {t('workouts.injuryDialog.description')}
      </DialogDescription>
    </DialogHeader>
    
    <div className="space-y-4">
      <Label>{t('workouts.injuryDialog.selectArea')}</Label>
      <div className="grid grid-cols-2 gap-2">
        {injuryAreas.map(area => (
          <Button
            key={area}
            variant={selectedInjury === area ? 'default' : 'outline'}
            onClick={() => setSelectedInjury(area)}
          >
            {t(`injuries.${area}`)}
          </Button>
        ))}
      </div>
      
      <Alert>
        <Info className="w-4 h-4" />
        <AlertDescription>
          {t('workouts.injuryDialog.impactNotice')}
        </AlertDescription>
      </Alert>
    </div>
    
    <DialogFooter>
      <Button variant="ghost" onClick={() => setShowInjuryDialog(false)}>
        {t('common.cancel')}
      </Button>
      <Button onClick={handleReportInjury}>
        {t('workouts.findAlternative')}
      </Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

#### C. Alternative Exercise Selection
```typescript
const handleReportInjury = () => {
  const currentEx = getCurrentExercise();
  const alternatives = findSafeAlternatives(
    currentEx.exerciseId,
    selectedInjury,
    currentEx.muscleGroup
  );
  
  setAlternativeExercises(alternatives);
  setShowAlternativesDialog(true);
  setShowInjuryDialog(false);
};

<Dialog open={showAlternativesDialog} onOpenChange={setShowAlternativesDialog}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>{t('workouts.alternatives.title')}</DialogTitle>
      <DialogDescription>
        {t('workouts.alternatives.description', { 
          injury: t(`injuries.${selectedInjury}`) 
        })}
      </DialogDescription>
    </DialogHeader>
    
    <ScrollArea className="max-h-96">
      {alternativeExercises.map(alt => (
        <Card key={alt.id} className="mb-3">
          <CardContent className="p-4">
            <div className="flex items-start justify-between">
              <div>
                <h4>{alt.name}</h4>
                <p className="text-sm text-muted-foreground">
                  {alt.muscleGroup}
                </p>
                <Badge variant="outline" className="mt-2">
                  {t('workouts.safeFor')} {t(`injuries.${selectedInjury}`)}
                </Badge>
              </div>
              <Button
                size="sm"
                onClick={() => handleSwapExercise(alt.id)}
              >
                {t('workouts.useThis')}
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </ScrollArea>
  </DialogContent>
</Dialog>
```

#### D. Visual Indicator for Swapped Exercises
```typescript
// In exercise card display
{exercise.isSwapped && (
  <Badge variant="secondary" className="flex items-center gap-1">
    <RefreshCw className="w-3 h-3" />
    {t('workouts.swapped')}
  </Badge>
)}

// Show original exercise info
{exercise.originalExerciseId && (
  <div className="text-xs text-muted-foreground mt-1">
    {t('workouts.originalExercise')}: {getExerciseById(exercise.originalExerciseId)?.name}
  </div>
)}
```

### New Translation Keys:
```typescript
'workouts.reportInjury': 'Report Injury',
'workouts.injuryDialog.title': 'Report an Injury',
'workouts.injuryDialog.description': 'Select the injured area to find safe alternatives',
'workouts.injuryDialog.selectArea': 'Injured Area',
'workouts.injuryDialog.impactNotice': 'We\'ll automatically replace exercises that affect this area',
'workouts.findAlternative': 'Find Alternatives',
'workouts.alternatives.title': 'Safe Alternatives',
'workouts.alternatives.description': 'These exercises are safe for your {injury} injury',
'workouts.safeFor': 'Safe for',
'workouts.useThis': 'Use This',
'workouts.swapped': 'Swapped',
'workouts.originalExercise': 'Original',
'injuries.shoulder': 'Shoulder',
'injuries.knee': 'Knee',
'injuries.lower_back': 'Lower Back',
'injuries.neck': 'Neck',
'injuries.ankle': 'Ankle',
// Arabic...
```

---

## 3️⃣ MEAL DETAILS & FOOD LOGGING

### Files to Create:
- `/components/MealDetailScreen.tsx` (NEW)
- `/components/FoodLoggingDialog.tsx` (NEW)

### File to Modify:
- `/components/NutritionScreen.tsx`

### A. MealDetailScreen Component

```typescript
// /components/MealDetailScreen.tsx
import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { ScrollArea } from './ui/scroll-area';
import { 
  ArrowLeft, 
  Clock, 
  Flame, 
  Plus, 
  Minus,
  Edit,
  Trash2,
  ChefHat 
} from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface MealDetailScreenProps {
  meal: Meal;
  onBack: () => void;
  onAddFood: () => void;
  onEditFood: (foodId: string) => void;
  onRemoveFood: (foodId: string) => void;
  onViewRecipe?: (recipeId: string) => void;
}

export function MealDetailScreen({
  meal,
  onBack,
  onAddFood,
  onEditFood,
  onRemoveFood,
  onViewRecipe
}: MealDetailScreenProps) {
  const { t, isRTL } = useLanguage();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-600 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-bold">{meal.name}</h1>
            <p className="text-sm text-white/90 flex items-center gap-2">
              <Clock className="w-4 h-4" />
              {meal.time}
            </p>
          </div>
        </div>

        {/* Meal Summary */}
        <div className="grid grid-cols-4 gap-2 bg-white/10 rounded-lg p-3">
          <div className="text-center">
            <div className="text-2xl font-bold">{meal.totalCalories}</div>
            <div className="text-xs">{t('nutrition.calories')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{meal.totalProtein}g</div>
            <div className="text-xs">{t('nutrition.protein')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{meal.totalCarbs}g</div>
            <div className="text-xs">{t('nutrition.carbs')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{meal.totalFats}g</div>
            <div className="text-xs">{t('nutrition.fats')}</div>
          </div>
        </div>
      </div>

      {/* Food Items List */}
      <div className="p-4 space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="font-semibold">{t('nutrition.foodItems')}</h2>
          <Button size="sm" onClick={onAddFood}>
            <Plus className="w-4 h-4 mr-2" />
            {t('nutrition.addFood')}
          </Button>
        </div>

        <ScrollArea className="h-[calc(100vh-300px)]">
          {meal.foods.map(food => (
            <Card key={food.id} className="mb-3">
              <CardContent className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex-1">
                    <h3 className="font-medium">{food.name}</h3>
                    <p className="text-sm text-muted-foreground">
                      {food.serving}
                    </p>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => onEditFood(food.id)}
                    >
                      <Edit className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => onRemoveFood(food.id)}
                    >
                      <Trash2 className="w-4 h-4 text-destructive" />
                    </Button>
                  </div>
                </div>

                <div className="grid grid-cols-4 gap-2 text-center text-sm">
                  <div>
                    <div className="font-semibold">{food.calories}</div>
                    <div className="text-xs text-muted-foreground">cal</div>
                  </div>
                  <div>
                    <div className="font-semibold">{food.protein}g</div>
                    <div className="text-xs text-muted-foreground">protein</div>
                  </div>
                  <div>
                    <div className="font-semibold">{food.carbs}g</div>
                    <div className="text-xs text-muted-foreground">carbs</div>
                  </div>
                  <div>
                    <div className="font-semibold">{food.fats}g</div>
                    <div className="text-xs text-muted-foreground">fats</div>
                  </div>
                </div>

                {food.recipeId && (
                  <Button
                    variant="outline"
                    size="sm"
                    className="w-full mt-2"
                    onClick={() => onViewRecipe?.(food.recipeId!)}
                  >
                    <ChefHat className="w-4 h-4 mr-2" />
                    {t('nutrition.viewRecipe')}
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </ScrollArea>
      </div>
    </div>
  );
}
```

### B. FoodLoggingDialog Component

```typescript
// /components/FoodLoggingDialog.tsx
import React, { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ScrollArea } from './ui/scroll-area';
import { Search } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface FoodLoggingDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAddFood: (food: FoodItem) => void;
}

export function FoodLoggingDialog({
  open,
  onOpenChange,
  onAddFood
}: FoodLoggingDialogProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('search');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Custom food form
  const [customFood, setCustomFood] = useState({
    name: '',
    serving: '',
    calories: '',
    protein: '',
    carbs: '',
    fats: ''
  });

  const handleAddCustomFood = () => {
    const food: FoodItem = {
      id: `custom_${Date.now()}`,
      name: customFood.name,
      serving: customFood.serving,
      calories: parseFloat(customFood.calories),
      protein: parseFloat(customFood.protein),
      carbs: parseFloat(customFood.carbs),
      fats: parseFloat(customFood.fats),
    };
    onAddFood(food);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>{t('nutrition.addFood')}</DialogTitle>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="search">{t('nutrition.searchFood')}</TabsTrigger>
            <TabsTrigger value="custom">{t('nutrition.customFood')}</TabsTrigger>
          </TabsList>

          <TabsContent value="search" className="space-y-3">
            <div className="relative">
              <Search className="absolute left-3 top-3 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder={t('nutrition.searchPlaceholder')}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>

            <ScrollArea className="h-64">
              {/* Food database results */}
              <div className="space-y-2">
                {/* Example food items */}
                <Button
                  variant="outline"
                  className="w-full justify-start"
                  onClick={() => {/* Add food */}}
                >
                  <div className="text-left">
                    <div className="font-medium">Chicken Breast</div>
                    <div className="text-xs text-muted-foreground">
                      100g • 165 cal • 31g protein
                    </div>
                  </div>
                </Button>
              </div>
            </ScrollArea>
          </TabsContent>

          <TabsContent value="custom" className="space-y-3">
            <div className="space-y-2">
              <Label>{t('nutrition.foodName')}</Label>
              <Input
                value={customFood.name}
                onChange={(e) => setCustomFood({...customFood, name: e.target.value})}
                placeholder="e.g., Grilled Chicken"
              />
            </div>

            <div className="space-y-2">
              <Label>{t('nutrition.servingSize')}</Label>
              <Input
                value={customFood.serving}
                onChange={(e) => setCustomFood({...customFood, serving: e.target.value})}
                placeholder="e.g., 100g"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label>{t('nutrition.calories')}</Label>
                <Input
                  type="number"
                  value={customFood.calories}
                  onChange={(e) => setCustomFood({...customFood, calories: e.target.value})}
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.protein')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.protein}
                  onChange={(e) => setCustomFood({...customFood, protein: e.target.value})}
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.carbs')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.carbs}
                  onChange={(e) => setCustomFood({...customFood, carbs: e.target.value})}
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.fats')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.fats}
                  onChange={(e) => setCustomFood({...customFood, fats: e.target.value})}
                />
              </div>
            </div>

            <Button
              className="w-full"
              onClick={handleAddCustomFood}
              disabled={!customFood.name || !customFood.calories}
            >
              {t('nutrition.addToMeal')}
            </Button>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
```

### New Translation Keys:
```typescript
'nutrition.foodItems': 'Food Items',
'nutrition.addFood': 'Add Food',
'nutrition.searchFood': 'Search Database',
'nutrition.customFood': 'Custom Food',
'nutrition.searchPlaceholder': 'Search for foods...',
'nutrition.foodName': 'Food Name',
'nutrition.servingSize': 'Serving Size',
'nutrition.addToMeal': 'Add to Meal',
'nutrition.viewRecipe': 'View Recipe',
// Arabic...
```

---

## 4️⃣ CLIENT DETAIL SCREEN (Coach)

### File to Create: `/components/ClientDetailScreen.tsx`

```typescript
import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import {
  ArrowLeft,
  MessageCircle,
  Video,
  TrendingUp,
  TrendingDown,
  Calendar,
  Activity,
  Apple,
  Dumbbell,
  Award,
  Edit
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface ClientDetailScreenProps {
  client: Client;
  onBack: () => void;
  onMessage: () => void;
  onCall: () => void;
  onAssignPlan: () => void;
  onEditFitnessScore: () => void;
}

export function ClientDetailScreen({
  client,
  onBack,
  onMessage,
  onCall,
  onAssignPlan,
  onEditFitnessScore
}: ClientDetailScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');

  // Mock progress data
  const progressData = [
    { date: 'Week 1', weight: 85, fitnessScore: 55 },
    { date: 'Week 2', weight: 84.5, fitnessScore: 58 },
    { date: 'Week 3', weight: 84, fitnessScore: 62 },
    { date: 'Week 4', weight: 83.5, fitnessScore: 68 },
  ];

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-bold">{t('coach.clientDetails')}</h1>
          </div>
        </div>

        {/* Client Info Card */}
        <Card className="bg-white/10 border-white/20">
          <CardContent className="p-4">
            <div className="flex items-start gap-4">
              <Avatar className="w-16 h-16">
                <AvatarFallback className="bg-white/20 text-white text-xl">
                  {client.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              
              <div className="flex-1">
                <h2 className="text-xl font-bold text-white">{client.name}</h2>
                <p className="text-white/80 text-sm">{client.email}</p>
                
                <div className="flex gap-2 mt-2">
                  <Badge variant="secondary">
                    {client.subscriptionTier}
                  </Badge>
                  <Badge 
                    variant={
                      client.status === 'active' ? 'default' : 
                      client.status === 'new' ? 'secondary' : 'outline'
                    }
                  >
                    {client.status}
                  </Badge>
                </div>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-3 gap-2 mt-4">
              <Button
                variant="secondary"
                size="sm"
                onClick={onMessage}
              >
                <MessageCircle className="w-4 h-4 mr-2" />
                {t('coach.message')}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={onCall}
              >
                <Video className="w-4 h-4 mr-2" />
                {t('coach.call')}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={onAssignPlan}
              >
                <Dumbbell className="w-4 h-4 mr-2" />
                {t('coach.assignPlan')}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="p-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">{t('coach.overview')}</TabsTrigger>
          <TabsTrigger value="workouts">{t('coach.workouts')}</TabsTrigger>
          <TabsTrigger value="nutrition">{t('coach.nutrition')}</TabsTrigger>
          <TabsTrigger value="inbody">{t('coach.inbody')}</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-4">
          {/* Stats Grid */}
          <div className="grid grid-cols-2 gap-3">
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">{t('coach.fitnessScore')}</p>
                    <p className="text-2xl font-bold">{client.fitnessScore}</p>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={onEditFitnessScore}
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                </div>
                <Progress value={client.fitnessScore} className="mt-2" />
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.progress')}</p>
                <p className="text-2xl font-bold">{client.progress}%</p>
                <Progress value={client.progress} className="mt-2" />
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.goal')}</p>
                <p className="text-lg font-semibold">{client.goal}</p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.lastActive')}</p>
                <p className="text-sm font-medium">
                  {new Date(client.lastActivity).toLocaleDateString()}
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Progress Chart */}
          <Card>
            <CardHeader>
              <CardTitle>{t('coach.progressOverTime')}</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={progressData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Line 
                    type="monotone" 
                    dataKey="fitnessScore" 
                    stroke="#8b5cf6" 
                    strokeWidth={2}
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Other tabs... */}
      </Tabs>
    </div>
  );
}
```

---

## 5️⃣ COACH MESSAGING INTERFACE

### File to Create: `/components/CoachMessagingScreen.tsx`

*(Similar comprehensive implementation as above...)*

---

## 📝 IMPLEMENTATION CHECKLIST

### Week 1:
- [ ] Day 1-2: Enhanced CoachScreen (quota, rating, attachments)
- [ ] Day 3-4: Injury Substitution UI
- [ ] Day 5: Testing & refinements

### Week 2:
- [ ] Day 1-2: Meal Details & Food Logging
- [ ] Day 3-4: Client Detail Screen
- [ ] Day 4-5: Coach Messaging Interface
- [ ] Day 5: Testing & refinements

### Testing Requirements:
- [ ] All features work in demo mode
- [ ] Bilingual support (English/Arabic with RTL)
- [ ] Subscription tier access controls
- [ ] Mobile responsive
- [ ] Loading states
- [ ] Error handling
- [ ] Empty states

---

## 🚀 DEPLOYMENT NOTES

After Phase 1 completion:
1. All v2.0 critical features will be functional
2. User, Coach experiences significantly enhanced
3. Ready for Phase 2 (Store & Advanced Coach features)
4. Strong foundation for remaining phases

**Estimated Lines of Code: ~3,500 new lines**
**Estimated Components: 5 major features**
**Translation Keys: ~120 new keys**
