import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  ArrowLeft, 
  Lock, 
  Target, 
  Apple, 
  Beef, 
  Wheat, 
  Droplets,
  Plus,
  TrendingUp,
  Settings,
  ChefHat,
  Sparkles
} from 'lucide-react';
import { UserProfile } from '../App';
import { NutritionPreferencesIntake, NutritionPreferences } from './NutritionPreferencesIntake';
import { NutritionWelcomeScreen } from './NutritionWelcomeScreen';
import { SubscriptionManager } from './SubscriptionManager';
import { useLanguage } from './LanguageContext';
import { NutritionExpiryBanner } from './NutritionExpiryBanner';
import { checkNutritionExpiry, NutritionExpiryStatus } from '../utils/nutritionExpiry';
import { MealDetailScreen } from './MealDetailScreen';
import { NutritionDebugPanel } from './NutritionDebugPanel';
import { NutritionIntroScreen } from './NutritionIntroScreen';

interface NutritionScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'workout' | 'coach' | 'store' | 'account') => void;
  onUpdateProfile: (updatedProfile: UserProfile) => void;
  onLogout?: () => void;
  isDemoMode: boolean;
}

interface MacroTarget {
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  water: number;
}

interface FoodItem {
  id: string;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  serving: string;
}

interface Meal {
  id: string;
  name: string;
  time: string;
  foods: FoodItem[];
  totalCalories: number;
}

export function NutritionScreen({ userProfile, onNavigate, onUpdateProfile, onLogout, isDemoMode }: NutritionScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('today');
  
  // Show intro screen on first usage
  const [showIntro, setShowIntro] = React.useState(() => {
    const hasSeenIntro = localStorage.getItem('nutrition_intro_seen');
    return !hasSeenIntro;
  });
  
  // v2.0: Check if user has completed nutrition preferences (persisted)
  const [hasCompletedPreferences, setHasCompletedPreferences] = useState(() => {
    console.log('====== [NutritionScreen] INITIALIZATION START ======');
    console.log('[NutritionScreen] Component mounting at:', new Date().toISOString());
    console.log('[NutritionScreen] UserProfile:', {
      phoneNumber: userProfile.phoneNumber,
      tier: userProfile.subscriptionTier,
      isDemoMode
    });
    
    // If user doesn't have nutrition access, they can't have completed preferences
    if (userProfile.subscriptionTier === 'Freemium') {
      console.log('[NutritionScreen] User is Freemium, no access → returning FALSE');
      return false;
    }
    
    // Check if there's a pending nutrition intake (user just upgraded)
    const pendingIntakeKey = `pending_nutrition_intake_${userProfile.phoneNumber}`;
    const pendingIntake = localStorage.getItem(pendingIntakeKey);
    console.log('[NutritionScreen] Checking pending intake:', {
      key: pendingIntakeKey,
      value: pendingIntake,
      type: typeof pendingIntake,
      equalsTrueString: pendingIntake === 'true'
    });
    
    if (pendingIntake === 'true') {
      console.log('[NutritionScreen] ✓ Pending intake found, forcing intake to show → returning FALSE');
      return false; // Force intake to show
    }
    
    // Check localStorage for completed preferences flag
    const completedKey = `nutrition_preferences_completed_${userProfile.phoneNumber}`;
    const storedFlag = localStorage.getItem(completedKey);
    console.log('[NutritionScreen] Checking completed flag:', {
      key: completedKey,
      value: storedFlag,
      type: typeof storedFlag
    });
    
    if (storedFlag === 'true') {
      console.log('[NutritionScreen] User already completed preferences → returning TRUE');
      return true;
    }
    
    // New paid users should go through the intake flow (no auto-complete)
    // This ensures each user sees the welcome screen and intake on first access
    console.log('[NutritionScreen] No completed flag found - user needs to complete intake → returning FALSE');
    console.log('====== [NutritionScreen] INITIALIZATION END ======');
    return false;
  });
  
  // v2.0: Track welcome and intake screens separately for better flow control
  const [showWelcomeScreen, setShowWelcomeScreen] = useState(() => {
    const pendingIntakeKey = `pending_nutrition_intake_${userProfile.phoneNumber}`;
    const pendingIntake = localStorage.getItem(pendingIntakeKey);
    // Show welcome screen if user just upgraded (has pending intake)
    const shouldShowWelcome = pendingIntake === 'true' && userProfile.subscriptionTier !== 'Freemium';
    console.log('[NutritionScreen] showWelcomeScreen initial state:', {
      pendingIntake,
      tier: userProfile.subscriptionTier,
      shouldShowWelcome
    });
    return shouldShowWelcome;
  });
  
  const [showPreferencesIntake, setShowPreferencesIntake] = useState(false);
  const [showSubscriptionManager, setShowSubscriptionManager] = useState(false);
  const [showDebugPanel, setShowDebugPanel] = useState(false);
  const [clickCount, setClickCount] = useState(0);
  
  // v2.0 Nutrition expiry tracking (for Freemium users)
  const [nutritionAccessDate] = useState(
    isDemoMode && userProfile.subscriptionTier === 'Freemium' 
      ? new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) // 5 days ago (2 days remaining)
      : new Date()
  );
  
  // Create a nutrition plan object from the access date
  const nutritionPlan = {
    id: 'nutrition_plan_1',
    generatedAt: nutritionAccessDate,
    expiresAt: userProfile.subscriptionTier === 'Freemium' 
      ? new Date(nutritionAccessDate.getTime() + 7 * 24 * 60 * 60 * 1000) // 7 days from generation
      : null,
    isLocked: false
  };
  
  const nutritionExpiryStatus = checkNutritionExpiry(nutritionPlan, userProfile.subscriptionTier);

  const handleRegenerate = () => {
    // Simulate regenerating the nutrition plan
    // In real app, this would call API and reset the access date
    alert(t('nutrition.regenerateWarning'));
  };
  
  // v2.0: Load nutrition preferences from localStorage if available
  const [nutritionPreferences, setNutritionPreferences] = useState<NutritionPreferences | null>(() => {
    // Try to load from localStorage first
    const storedPrefs = localStorage.getItem(`nutrition_preferences_${userProfile.phoneNumber}`);
    if (storedPrefs) {
      try {
        return JSON.parse(storedPrefs);
      } catch (e) {
        console.error('Failed to parse stored preferences', e);
      }
    }
    
    // Demo data for premium users
    if (isDemoMode && userProfile.subscriptionTier !== 'Freemium') {
      return {
        proteinSources: ['chicken', 'tuna', 'eggs'],
        proteinAllergies: [],
        dinnerPreferences: {
          portionSize: 'moderate',
          prepSpeed: 'normal',
          carbLevel: 'includes_carbs',
          temperature: 'hot',
          cuisines: ['mediterranean', 'arabic'],
          avoid: ['spicy', 'fried']
        },
        additionalNotes: 'Prefer lighter dinners during weekdays'
      };
    }
    
    return null;
  });

  const isLocked = userProfile.subscriptionTier === 'Freemium';

  // Demo nutrition data
  const macroTargets: MacroTarget = {
    calories: 2400,
    protein: 150,
    carbs: 300,
    fats: 80,
    water: 3000,
  };

  const currentIntake = isDemoMode ? {
    calories: 1840,
    protein: 120,
    carbs: 180,
    fats: 65,
    water: 2200,
  } : {
    calories: 0,
    protein: 0,
    carbs: 0,
    fats: 0,
    water: 0,
  };

  // Dynamic meal suggestions based on preferences
  const generateMealSuggestions = (): Meal[] => {
    if (!nutritionPreferences || !hasCompletedPreferences) {
      return [
        {
          id: 'breakfast',
          name: 'Breakfast',
          time: '8:00 AM',
          foods: [
            { id: '1', name: 'Oatmeal with Berries', calories: 320, protein: 12, carbs: 55, fats: 8, serving: '1 bowl' },
            { id: '2', name: 'Greek Yogurt', calories: 150, protein: 20, carbs: 8, fats: 0, serving: '200g' },
          ],
          totalCalories: 470,
        },
        {
          id: 'lunch',
          name: 'Lunch',
          time: '1:00 PM',
          foods: [
            { id: '3', name: 'Grilled Chicken Breast', calories: 280, protein: 54, carbs: 0, fats: 6, serving: '200g' },
            { id: '4', name: 'Brown Rice', calories: 220, protein: 5, carbs: 45, fats: 2, serving: '1 cup' },
            { id: '5', name: 'Mixed Vegetables', calories: 80, protein: 3, carbs: 15, fats: 1, serving: '1 cup' },
          ],
          totalCalories: 580,
        },
        {
          id: 'dinner',
          name: 'Dinner',
          time: '7:00 PM',
          foods: [
            { id: '6', name: 'Salmon Fillet', calories: 410, protein: 40, carbs: 0, fats: 28, serving: '180g' },
            { id: '7', name: 'Sweet Potato', calories: 180, protein: 4, carbs: 42, fats: 0, serving: '1 medium' },
            { id: '8', name: 'Green Salad', calories: 50, protein: 2, carbs: 8, fats: 2, serving: '1 bowl' },
          ],
          totalCalories: 640,
        },
      ];
    }

    // Personalized meals based on preferences
    const preferredProteins = nutritionPreferences.proteinSources;
    const preferredCuisines = nutritionPreferences.dinnerPreferences.cuisines;
    const carbLevel = nutritionPreferences.dinnerPreferences.carbLevel;
    const avoidFoods = nutritionPreferences.dinnerPreferences.avoid;

    // Generate dinner based on preferences
    let dinnerProtein = 'Grilled Chicken Breast';
    let dinnerCalories = 280;
    
    if (preferredProteins.includes('salmon')) {
      dinnerProtein = 'Grilled Salmon';
      dinnerCalories = 350;
    } else if (preferredProteins.includes('tuna')) {
      dinnerProtein = 'Seared Tuna Steak';
      dinnerCalories = 320;
    }

    let dinnerCarb = null;
    let dinnerCarbCalories = 0;
    
    if (carbLevel === 'includes_carbs') {
      if (preferredCuisines.includes('mediterranean')) {
        dinnerCarb = 'Quinoa Pilaf';
        dinnerCarbCalories = 200;
      } else if (preferredCuisines.includes('arabic')) {
        dinnerCarb = 'Bulgur Rice';
        dinnerCarbCalories = 180;
      } else {
        dinnerCarb = 'Sweet Potato';
        dinnerCarbCalories = 180;
      }
    }

    const dinnerFoods = [
      { id: '6', name: dinnerProtein, calories: dinnerCalories, protein: 40, carbs: 0, fats: 15, serving: '180g' },
      ...(dinnerCarb ? [{ id: '7', name: dinnerCarb, calories: dinnerCarbCalories, protein: 4, carbs: carbLevel === 'low_carb' ? 20 : 42, fats: 2, serving: '1 cup' }] : []),
      { id: '8', name: preferredCuisines.includes('mediterranean') ? 'Greek Salad' : 'Mixed Greens', calories: 80, protein: 3, carbs: 8, fats: 5, serving: '1 bowl' },
    ];

    return [
      {
        id: 'breakfast',
        name: 'Breakfast',
        time: '8:00 AM',
        foods: [
          { id: '1', name: preferredProteins.includes('eggs') ? 'Scrambled Eggs with Spinach' : 'Protein Smoothie', calories: 320, protein: 25, carbs: 15, fats: 18, serving: '1 serving' },
          { id: '2', name: 'Greek Yogurt with Berries', calories: 150, protein: 20, carbs: 12, fats: 2, serving: '200g' },
        ],
        totalCalories: 470,
      },
      {
        id: 'lunch',
        name: 'Lunch',
        time: '1:00 PM',
        foods: [
          { id: '3', name: preferredProteins.includes('chicken') ? 'Mediterranean Chicken Bowl' : 'Tuna Salad', calories: 350, protein: 35, carbs: 25, fats: 12, serving: '1 bowl' },
          { id: '4', name: 'Whole Grain Pita', calories: 120, protein: 4, carbs: 24, fats: 1, serving: '1 piece' },
          { id: '5', name: 'Hummus & Vegetables', calories: 110, protein: 4, carbs: 12, fats: 6, serving: '1 serving' },
        ],
        totalCalories: 580,
      },
      {
        id: 'dinner',
        name: 'Dinner',
        time: '7:00 PM',
        foods: dinnerFoods,
        totalCalories: dinnerFoods.reduce((sum, food) => sum + food.calories, 0),
      },
    ];
  };

  const sampleMeals = generateMealSuggestions();
  
  // Debug panel triple-click handler
  const handleTitleClick = () => {
    const newCount = clickCount + 1;
    setClickCount(newCount);
    
    if (newCount >= 3) {
      setShowDebugPanel(true);
      setClickCount(0);
    }
    
    // Reset click count after 1 second
    setTimeout(() => setClickCount(0), 1000);
  };

  const calculateProgress = (current: number, target: number) => {
    return Math.min((current / target) * 100, 100);
  };

  const handlePreferencesComplete = (preferences: NutritionPreferences) => {
    console.log('[NutritionScreen] Preferences completed, updating state');
    setNutritionPreferences(preferences);
    setHasCompletedPreferences(true);
    setShowPreferencesIntake(false);
    setShowWelcomeScreen(false);
    
    // v2.0: Store preferences and completion flag in localStorage (persisted)
    localStorage.setItem(`nutrition_preferences_${userProfile.phoneNumber}`, JSON.stringify(preferences));
    localStorage.setItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`, 'true');
    
    // Clear pending nutrition intake flag since user has now completed it
    localStorage.removeItem(`pending_nutrition_intake_${userProfile.phoneNumber}`);
    console.log('[NutritionScreen] Cleared pending intake flag, showing main nutrition screen');
  };

  const handleSubscriptionUpgrade = (newTier: SubscriptionTier) => {
    console.log('[NutritionScreen] User upgraded from', userProfile.subscriptionTier, 'to', newTier);
    const updatedProfile: UserProfile = {
      ...userProfile,
      subscriptionTier: newTier
    };
    onUpdateProfile(updatedProfile);
    
    // v2.0: After upgrade from Freemium, show welcome screen then intake
    if (userProfile.subscriptionTier === 'Freemium' && newTier !== 'Freemium') {
      console.log('[NutritionScreen] Upgrade detected - showing welcome screen');
      setHasCompletedPreferences(false);
      setShowSubscriptionManager(false);
      setShowWelcomeScreen(true);
      // The welcome screen will then lead to the intake form
    }
  };
  
  // v2.0: Monitor subscription changes - if user was Freemium and now has access
  useEffect(() => {
    console.log('====== [NutritionScreen] useEffect START ======');
    console.log('[NutritionScreen] useEffect triggered at:', new Date().toISOString());
    console.log('[NutritionScreen] Current tier:', userProfile.subscriptionTier);
    console.log('[NutritionScreen] Current hasCompletedPreferences state:', hasCompletedPreferences);
    
    const wasFreemium = localStorage.getItem(`was_freemium_${userProfile.phoneNumber}`);
    const isNowPaid = userProfile.subscriptionTier !== 'Freemium';
    const hasCompletedFlag = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`) === 'true';
    const pendingNutritionIntake = localStorage.getItem(`pending_nutrition_intake_${userProfile.phoneNumber}`) === 'true';
    
    console.log('[NutritionScreen] useEffect state check:', { 
      wasFreemium, 
      isNowPaid, 
      hasCompletedFlag, 
      pendingNutritionIntake,
      phoneNumber: userProfile.phoneNumber
    });
    
    if (wasFreemium === 'true' && isNowPaid && !hasCompletedFlag) {
      // User just upgraded from Freemium to paid plan and hasn't completed nutrition intake
      // Mark that nutrition intake is pending and show welcome screen
      console.log('[NutritionScreen] ✓ Branch 1: User just upgraded, showing welcome screen');
      localStorage.setItem(`pending_nutrition_intake_${userProfile.phoneNumber}`, 'true');
      localStorage.removeItem(`was_freemium_${userProfile.phoneNumber}`);
      setHasCompletedPreferences(false);
      setShowWelcomeScreen(true); // Show welcome screen first
      setShowPreferencesIntake(false);
      console.log('[NutritionScreen] Set showWelcomeScreen to TRUE');
    } else if (pendingNutritionIntake && isNowPaid && !hasCompletedFlag) {
      // User upgraded earlier and nutrition intake is pending - show welcome screen
      console.log('[NutritionScreen] ✓ Branch 2: Pending intake detected, showing welcome screen');
      setHasCompletedPreferences(false);
      setShowWelcomeScreen(true); // Show welcome screen first
      setShowPreferencesIntake(false);
      console.log('[NutritionScreen] Set showWelcomeScreen to TRUE');
    } else if (userProfile.subscriptionTier === 'Freemium') {
      // Track that user is/was freemium
      console.log('[NutritionScreen] ✓ Branch 3: User is Freemium, tracking status');
      localStorage.setItem(`was_freemium_${userProfile.phoneNumber}`, 'true');
      setHasCompletedPreferences(false); // Ensure no access to nutrition tracking
      setShowWelcomeScreen(false);
      setShowPreferencesIntake(false);
      console.log('[NutritionScreen] Set hasCompletedPreferences to FALSE');
    } else {
      console.log('[NutritionScreen] No branch matched, no state change');
    }
    console.log('====== [NutritionScreen] useEffect END ======');
  }, [userProfile.subscriptionTier, userProfile.phoneNumber]);

  // Show Welcome Screen first (for new premium users or after upgrade)
  if (showWelcomeScreen) {
    console.log('[NutritionScreen] Rendering NutritionWelcomeScreen');
    return (
      <NutritionWelcomeScreen
        onStart={() => {
          console.log('[NutritionScreen] User clicked Start - showing intake form');
          setShowWelcomeScreen(false);
          setShowPreferencesIntake(true);
        }}
        onBack={() => onNavigate('home')}
      />
    );
  }
  
  // Show intro screen on first visit (for non-locked users)
  if (showIntro && !isLocked) {
    return (
      <NutritionIntroScreen
        onGetStarted={() => {
          setShowIntro(false);
          localStorage.setItem('nutrition_intro_seen', 'true');
        }}
      />
    );
  }

  // First-time nutrition access for paid users (legacy path - no pending upgrade)
  if (!isLocked && !hasCompletedPreferences && !showPreferencesIntake && !showWelcomeScreen) {
    console.log('[NutritionScreen] Showing welcome screen (legacy path) - isLocked:', isLocked, 'hasCompleted:', hasCompletedPreferences);
    return (
      <NutritionWelcomeScreen
        onStart={() => {
          console.log('[NutritionScreen] User clicked Start - showing intake form');
          setShowPreferencesIntake(true);
        }}
        onBack={() => onNavigate('home')}
      />
    );
  }

  // Show subscription manager if requested
  if (showSubscriptionManager) {
    return (
      <SubscriptionManager
        userProfile={userProfile}
        onBack={() => setShowSubscriptionManager(false)}
        onUpgrade={handleSubscriptionUpgrade}
      />
    );
  }

  // Show preferences intake
  if (showPreferencesIntake) {
    return (
      <NutritionPreferencesIntake
        onComplete={handlePreferencesComplete}
        onBack={() => setShowPreferencesIntake(false)}
        onLogout={onLogout}
      />
    );
  }

  if (isLocked) {
    return (
      <div className="min-h-screen bg-background">
        {/* Header */}
        <div className="bg-primary text-primary-foreground p-4">
          <div className="flex items-center gap-3">
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => onNavigate('home')}
              className="text-primary-foreground hover:bg-primary-foreground/20"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div className="flex-1">
              <h1 className="text-xl">Nutrition</h1>
              <p className="text-primary-foreground/80">Meal plans & tracking</p>
            </div>
          </div>
        </div>

        {/* Locked Content */}
        <div className="p-4 flex items-center justify-center min-h-[60vh]">
          <Card className="w-full max-w-md text-center">
            <CardContent className="p-8 space-y-6">
              <div className="w-20 h-20 mx-auto bg-orange-100 rounded-full flex items-center justify-center">
                <Lock className="w-10 h-10 text-orange-600" />
              </div>
              <div className="space-y-2">
                <h2>{t('subscription.premium')} Feature</h2>
                <p className="text-muted-foreground">
                  {t('home.premiumDesc')}
                </p>
              </div>
              <div className="space-y-3">
                <div className={`space-y-2 ${isRTL ? 'text-right' : 'text-left'}`}>
                  <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <Target className="w-4 h-4 text-green-600" />
                    <span className="text-sm">{t('nutrition.feature1')}</span>
                  </div>
                  <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <Apple className="w-4 h-4 text-green-600" />
                    <span className="text-sm">{t('nutrition.feature2')}</span>
                  </div>
                  <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <TrendingUp className="w-4 h-4 text-green-600" />
                    <span className="text-sm">{t('nutrition.feature3')}</span>
                  </div>
                </div>
                <Button 
                  className="w-full bg-orange-600 hover:bg-orange-700"
                  onClick={() => setShowSubscriptionManager(true)}
                >
                  {t('subscription.upgradeButton')}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-40"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1749280446532-60869b4b9863?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
        {/* Header */}
        <div className="bg-green-600 text-white p-4">
          <div className={`flex items-center gap-3 mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => onNavigate('home')}
              className="text-white hover:bg-white/20"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div className="flex-1">
              <h1 
                className="text-xl cursor-pointer select-none" 
                onClick={handleTitleClick}
                title="Triple-click to open debug panel"
              >
                {t('nutrition.title')}
              </h1>
              <p className="text-white/80">{t('nutrition.tracking')}</p>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setShowPreferencesIntake(true)}
              className="text-white hover:bg-white/20"
              title={t('nutrition.editPreferences')}
            >
              <Settings className="w-5 h-5" />
            </Button>
          </div>
          
          {/* Daily Overview */}
          <div className="bg-white/10 rounded-2xl p-4 space-y-4">
            <div className="flex items-center justify-between">
              <h3>{t('nutrition.todaysProgress')}</h3>
              <Badge variant="secondary" className="bg-white/20 text-white">
                {Math.round((currentIntake.calories / macroTargets.calories) * 100)}%
              </Badge>
            </div>
            
            <div className="space-y-3">
              <div>
                <div className="flex items-center justify-between text-sm mb-1">
                  <span>{t('nutrition.calories')}</span>
                  <span>{currentIntake.calories} / {macroTargets.calories}</span>
                </div>
                <Progress 
                  value={calculateProgress(currentIntake.calories, macroTargets.calories)} 
                  className="bg-white/20"
                />
              </div>
            </div>
          </div>
        </div>

        <div className="p-4">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="today">{t('common.today')}</TabsTrigger>
              <TabsTrigger value="meals">{t('nutrition.mealPlans')}</TabsTrigger>
              <TabsTrigger value="tracking">Tracking</TabsTrigger>
            </TabsList>

            <TabsContent value="today" className="space-y-4 mt-4">
              {/* Macro Breakdown */}
              <div className="grid grid-cols-2 gap-4">
                <Card>
                  <CardContent className="p-4 text-center">
                    <Beef className="w-6 h-6 mx-auto mb-2 text-red-500" />
                    <div className="text-lg font-semibold">{currentIntake.protein}g</div>
                    <div className="text-sm text-muted-foreground">{t('nutrition.protein')}</div>
                    <Progress 
                      value={calculateProgress(currentIntake.protein, macroTargets.protein)} 
                      className="mt-2 h-1"
                    />
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="p-4 text-center">
                    <Wheat className="w-6 h-6 mx-auto mb-2 text-yellow-500" />
                    <div className="text-lg font-semibold">{currentIntake.carbs}g</div>
                    <div className="text-sm text-muted-foreground">{t('nutrition.carbs')}</div>
                    <Progress 
                      value={calculateProgress(currentIntake.carbs, macroTargets.carbs)} 
                      className="mt-2 h-1"
                    />
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="p-4 text-center">
                    <Droplets className="w-6 h-6 mx-auto mb-2 text-blue-500" />
                    <div className="text-lg font-semibold">{currentIntake.fats}g</div>
                    <div className="text-sm text-muted-foreground">{t('nutrition.fats')}</div>
                    <Progress 
                      value={calculateProgress(currentIntake.fats, macroTargets.fats)} 
                      className="mt-2 h-1"
                    />
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="p-4 text-center">
                    <Droplets className="w-6 h-6 mx-auto mb-2 text-cyan-500" />
                    <div className="text-lg font-semibold">{currentIntake.water}ml</div>
                    <div className="text-sm text-muted-foreground">{t('nutrition.water')}</div>
                    <Progress 
                      value={calculateProgress(currentIntake.water, macroTargets.water)} 
                      className="mt-2 h-1"
                    />
                  </CardContent>
                </Card>
              </div>

              {/* Quick Actions */}
              <div className="flex gap-2">
                <Button className="flex-1" variant="outline">
                  <Plus className="w-4 h-4 mr-2" />
                  {t('nutrition.logFood')}
                </Button>
                <Button className="flex-1" variant="outline">
                  <Droplets className="w-4 h-4 mr-2" />
                  {t('nutrition.addWater')}
                </Button>
              </div>
            </TabsContent>

            <TabsContent value="meals" className="space-y-4 mt-4">
              {/* Preferences Summary for Demo */}
              {isDemoMode && nutritionPreferences && (
                <Card className="bg-blue-50 border-blue-200">
                  <CardHeader className="pb-3">
                    <CardTitle className="text-sm flex items-center gap-2">
                      <ChefHat className="w-4 h-4 text-blue-600" />
                      {t('nutritionPrefs.title')}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex flex-wrap gap-1">
                      <Badge variant="outline" className="text-xs">
                        {nutritionPreferences.dinnerPreferences.portionSize} portions
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        {nutritionPreferences.dinnerPreferences.prepSpeed.replace('_', ' ')} prep
                      </Badge>
                      {nutritionPreferences.dinnerPreferences.cuisines.slice(0, 2).map(cuisine => (
                        <Badge key={cuisine} variant="outline" className="text-xs capitalize">
                          {cuisine}
                        </Badge>
                      ))}
                    </div>
                    <p className="text-xs text-blue-700">
                      Meals personalized based on your preferences • 
                      <Button 
                        variant="link" 
                        size="sm" 
                        className="h-auto p-0 text-xs text-blue-600"
                        onClick={() => setShowPreferencesIntake(true)}
                      >
                        Update preferences
                      </Button>
                    </p>
                  </CardContent>
                </Card>
              )}
              
              {sampleMeals.map((meal) => (
                <Card key={meal.id}>
                  <CardHeader className="pb-3">
                    <div className="flex items-center justify-between">
                      <div>
                        <CardTitle className="text-lg">{meal.name}</CardTitle>
                        <p className="text-sm text-muted-foreground">{meal.time}</p>
                      </div>
                      <Badge variant="outline">{meal.totalCalories} cal</Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {meal.foods.map((food) => (
                      <div key={food.id} className="flex items-center justify-between p-3 bg-muted rounded-lg">
                        <div>
                          <div className="font-medium">{food.name}</div>
                          <div className="text-sm text-muted-foreground">{food.serving}</div>
                        </div>
                        <div className="text-right text-sm">
                          <div>{food.calories} cal</div>
                          <div className="text-muted-foreground">
                            P: {food.protein}g | C: {food.carbs}g | F: {food.fats}g
                          </div>
                        </div>
                      </div>
                    ))}
                    <Button variant="outline" className="w-full">
                      <Plus className="w-4 h-4 mr-2" />
                      {t('nutrition.addTo')} {meal.name}
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </TabsContent>

            <TabsContent value="tracking" className="space-y-4 mt-4">
              <Card>
                <CardHeader>
                  <CardTitle>{t('nutrition.weeklyProgress')}</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="aspect-[2/1] bg-muted rounded-lg flex items-center justify-center">
                      <p className="text-muted-foreground">Nutrition progress chart</p>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-center">
                      <div>
                        <div className="text-2xl font-bold text-green-600">6</div>
                        <div className="text-sm text-muted-foreground">{t('nutrition.daysOnTrack')}</div>
                      </div>
                      <div>
                        <div className="text-2xl font-bold text-blue-600">92%</div>
                        <div className="text-sm text-muted-foreground">{t('nutrition.avgAdherence')}</div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>{t('nutrition.recommendations')}</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <div className="flex items-center gap-2 mb-1">
                      <Target className="w-4 h-4 text-blue-600" />
                      <span className="font-medium text-blue-900">{t('nutrition.proteinGoal')}</span>
                    </div>
                    <p className="text-sm text-blue-700">
                      {t('nutrition.proteinShort')}
                    </p>
                  </div>
                  <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
                    <div className="flex items-center gap-2 mb-1">
                      <Droplets className="w-4 h-4 text-green-600" />
                      <span className="font-medium text-green-900">{t('nutrition.hydration')}</span>
                    </div>
                    <p className="text-sm text-green-700">
                      {t('nutrition.hydrationGood')}
                    </p>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
        
        {/* Debug Panel */}
        {showDebugPanel && (
          <NutritionDebugPanel 
            userProfile={userProfile} 
            onClose={() => setShowDebugPanel(false)} 
          />
        )}
      </div>
    </div>
  );
}