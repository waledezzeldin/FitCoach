import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { 
  Dumbbell, 
  Apple, 
  MessageCircle, 
  CreditCard, 
  User, 
  ShoppingBag,
  TrendingUp,
  Target,
  Calendar,
  Flame,
  Crown,
  Video,
  Activity
} from 'lucide-react';
import { UserProfile, SubscriptionTier } from '../App';
import { useLanguage } from './LanguageContext';
import { SubscriptionManager } from './SubscriptionManager';
import { QuotaDisplay } from './QuotaDisplay';
import { toast } from 'sonner@2.0.3';
import { QuotaUsage, TIER_QUOTAS } from '../types/QuotaTypes';
import { ProgressDetailScreen } from './ProgressDetailScreen';
import { ExerciseLibraryScreen } from './ExerciseLibraryScreen';
import { VideoBookingScreen } from './VideoBookingScreen';
import { InBodyInputScreen } from './InBodyInputScreen';
import { InBodyData } from '../types/InBodyTypes';

interface HomeScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'workout' | 'nutrition' | 'coach' | 'store' | 'account') => void;
  onUpdateProfile: (updatedProfile: UserProfile) => void;
  isDemoMode: boolean;
}

export function HomeScreen({ userProfile, onNavigate, onUpdateProfile, isDemoMode }: HomeScreenProps) {
  const { t, isRTL } = useLanguage();
  const [showSubscriptionManager, setShowSubscriptionManager] = useState(false);
  const [showProgressDetail, setShowProgressDetail] = useState(false);
  const [showExerciseLibrary, setShowExerciseLibrary] = useState(false);
  const [showVideoBooking, setShowVideoBooking] = useState(false);
  const [showInBodyInput, setShowInBodyInput] = useState(false);
  
  // v2.0 Quota tracking
  const quotaLimits = TIER_QUOTAS[userProfile.subscriptionTier];
  const [quotaUsage, setQuotaUsage] = useState<QuotaUsage>({
    messagesUsed: isDemoMode ? 8 : 0,
    messagesTotal: quotaLimits.messages,
    callsUsed: isDemoMode ? 1 : 0,
    callsTotal: quotaLimits.calls,
    resetDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
  });

  // Enhanced demo/mock data with more detailed stats
  const [currentStats, setCurrentStats] = React.useState(() => {
    if (isDemoMode) {
      return {
        caloriesBurned: 2850,
        caloriesConsumed: 1950,
        dailyCalorieGoal: 2200,
        workoutsCompleted: 12,
        totalWorkouts: 14,
        planAdherence: 85,
        streakDays: 5,
        weeklyProgress: 78,
        lastWorkoutCalories: 340,
        macros: {
          protein: { consumed: 120, target: 140 },
          carbs: { consumed: 245, target: 275 },
          fats: { consumed: 65, target: 75 }
        }
      };
    }
    return {
      caloriesBurned: 0,
      caloriesConsumed: 0,
      dailyCalorieGoal: 2000,
      workoutsCompleted: 0,
      totalWorkouts: 0,
      planAdherence: 0,
      streakDays: 0,
      weeklyProgress: 0,
      lastWorkoutCalories: 0,
      macros: {
        protein: { consumed: 0, target: 120 },
        carbs: { consumed: 0, target: 250 },
        fats: { consumed: 0, target: 70 }
      }
    };
  });

  const todayWorkout = isDemoMode ? {
    name: "Upper Body Strength",
    duration: "45 min",
    exercises: 6,
    completed: false
  } : null;

  const handleSubscriptionUpgrade = (newTier: SubscriptionTier) => {
    const wasFreemium = userProfile.subscriptionTier === 'Freemium';
    
    // v2.0: If upgrading from Freemium to a paid plan with nutrition, mark nutrition intake as pending
    if (wasFreemium && newTier !== 'Freemium') {
      const hasCompletedNutrition = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`) === 'true';
      if (!hasCompletedNutrition) {
        localStorage.setItem(`pending_nutrition_intake_${userProfile.phoneNumber}`, 'true');
        console.log('[HomeScreen] Set pending nutrition intake for', userProfile.phoneNumber);
        
        // Show prompt to visit nutrition screen after a short delay
        setTimeout(() => {
          toast.success(isRTL ? '🎉 مبروك الترقية!' : '🎉 Upgrade Successful!', {
            description: isRTL 
              ? 'لنبدأ بإعداد خطة التغذية الخاصة بك. اضغط هنا للمتابعة.' 
              : 'Let\'s set up your nutrition plan. Tap here to continue.',
            duration: 8000,
            action: {
              label: isRTL ? 'ابدأ الآن' : 'Start Now',
              onClick: () => onNavigate('nutrition')
            }
          });
        }, 2000);
      }
      // Remove the freemium tracking flag since user is upgrading
      localStorage.removeItem(`was_freemium_${userProfile.phoneNumber}`);
    }
    
    const updatedProfile: UserProfile = {
      ...userProfile,
      subscriptionTier: newTier
    };
    onUpdateProfile(updatedProfile);
  };

  const handleInBodySave = (data: InBodyData) => {
    const updatedProfile: UserProfile = {
      ...userProfile,
      inBodyHistory: {
        scans: [
          ...(userProfile.inBodyHistory?.scans || []),
          data
        ],
        latestScan: data
      }
    };
    onUpdateProfile(updatedProfile);
    setShowInBodyInput(false);
  };

  const navigationItems = [
    {
      id: 'workout',
      title: t('home.workouts'),
      description: t('home.workouts.desc'),
      icon: Dumbbell,
      color: 'bg-blue-500',
      available: true,
    },
    {
      id: 'nutrition',
      title: t('home.nutrition'),
      description: t('home.nutrition.desc'),
      icon: Apple,
      color: 'bg-green-500',
      available: userProfile.subscriptionTier !== 'Freemium',
      locked: userProfile.subscriptionTier === 'Freemium',
    },
    {
      id: 'coach',
      title: t('home.coach'),
      description: t('home.coach.desc'),
      icon: MessageCircle,
      color: 'bg-purple-500',
      available: true,
      badge: isDemoMode ? '1' : undefined,
    },
    {
      id: 'store',
      title: t('home.store'),
      description: t('home.store.desc'),
      icon: ShoppingBag,
      color: 'bg-orange-500',
      available: true,
    },
  ];

  // Show Video Booking if requested
  if (showVideoBooking) {
    return (
      <VideoBookingScreen
        userProfile={userProfile}
        onBack={() => setShowVideoBooking(false)}
        isDemoMode={isDemoMode}
      />
    );
  }

  // Show Exercise Library if requested
  if (showExerciseLibrary) {
    return (
      <ExerciseLibraryScreen
        userProfile={userProfile}
        onBack={() => setShowExerciseLibrary(false)}
        onSelectExercise={(exercise) => {
          // Could navigate to exercise detail here
          setShowExerciseLibrary(false);
        }}
      />
    );
  }

  // Show Progress Detail if requested
  if (showProgressDetail) {
    return (
      <ProgressDetailScreen
        userProfile={userProfile}
        onBack={() => setShowProgressDetail(false)}
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

  // Show InBody input screen if requested
  if (showInBodyInput) {
    return (
      <InBodyInputScreen
        userProfile={userProfile}
        onBack={() => setShowInBodyInput(false)}
        onSave={handleInBodySave}
      />
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-40"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1544965819-473a800795fe?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-6 rounded-b-3xl">
          <div className={`flex items-center justify-between mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <div className={isRTL ? 'text-right' : 'text-left'}>
              <h1>{t('home.hello')}, {userProfile.name.split(' ')[0]}! 👋</h1>
              <p className="opacity-90">{t('home.ready')}</p>
            </div>
            <div className="flex items-center gap-3">
              <Badge variant="secondary" className="bg-white/20 text-white">
                {userProfile.subscriptionTier}
              </Badge>
              <Button 
                variant="ghost" 
                size="icon"
                onClick={() => onNavigate('account')}
                className="text-white hover:bg-white/20"
              >
                <User className="w-5 h-5" />
              </Button>
            </div>
          </div>

          {/* Fitness Score - Prominent Display */}
          <div className="bg-white/10 rounded-2xl p-4 mb-4">
            <div className={`flex items-center justify-between mb-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <div className={isRTL ? 'text-right' : 'text-left'}>
                <div className="text-sm opacity-90">{t('home.fitnessScore')}</div>
                <div className="text-xs opacity-75">
                  {userProfile.fitnessScoreUpdatedBy === 'coach' 
                    ? t('home.updateByCoach') 
                    : t('home.autoUpdated')}
                </div>
              </div>
              <div className="text-center">
                <div className="text-4xl font-bold">
                  {userProfile.fitnessScore || (isDemoMode ? 72 : 0)}
                </div>
                <div className="text-xs opacity-75">/100</div>
              </div>
            </div>
            <Progress 
              value={userProfile.fitnessScore || (isDemoMode ? 72 : 0)} 
              className="bg-white/20 h-2" 
            />
            <div className="text-xs opacity-75 mt-2 text-center">
              {t('home.fitnessScoreDesc')}
            </div>
          </div>

          {/* Enhanced Smart Cards */}
          <div className="grid grid-cols-3 gap-3 mb-4">
            {/* Calories Burned */}
            <div className="bg-white/10 rounded-2xl p-3 text-center">
              <Flame className="w-5 h-5 mx-auto mb-1" />
              <div className="text-lg">{currentStats.caloriesBurned}</div>
              <div className="text-xs opacity-90">{t('home.caloriesBurned')}</div>
              {isDemoMode && currentStats.lastWorkoutCalories > 0 && (
                <div className="text-xs text-green-300 mt-1">
                  +{currentStats.lastWorkoutCalories} {t('home.today')}
                </div>
              )}
            </div>

            {/* Calories Consumed */}
            <div className="bg-white/10 rounded-2xl p-3 text-center">
              <Apple className="w-5 h-5 mx-auto mb-1" />
              <div className="text-lg">{currentStats.caloriesConsumed}</div>
              <div className="text-xs opacity-90">{t('home.caloriesConsumed')}</div>
              <div className="text-xs opacity-75 mt-1">
                /{currentStats.dailyCalorieGoal}
              </div>
            </div>

            {/* Plan Adherence */}
            <div className="bg-white/10 rounded-2xl p-3 text-center">
              <Target className="w-5 h-5 mx-auto mb-1" />
              <div className="text-lg">{currentStats.planAdherence}%</div>
              <div className="text-xs opacity-90">{t('home.adherence')}</div>
              {currentStats.streakDays > 0 && (
                <div className="text-xs text-yellow-300 mt-1">
                  🔥 {currentStats.streakDays} days
                </div>
              )}
            </div>
          </div>

          {/* Weekly Progress */}
          <div className="bg-white/10 rounded-2xl p-4">
            <div className={`flex items-center justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <span className="text-sm">{t('home.weeklyProgress')}</span>
              <span className="text-sm">{currentStats.weeklyProgress}%</span>
            </div>
            <Progress value={currentStats.weeklyProgress} className="bg-white/20" />
            <div className="flex justify-between text-xs opacity-75 mt-2">
              <span>{currentStats.workoutsCompleted}/{currentStats.totalWorkouts} {t('home.workouts.completed')}</span>
              <span>{t('home.thisWeek')}</span>
            </div>
          </div>
        </div>

        <div className="p-6 space-y-6">
          {/* v2.0 Quota Display */}
          {userProfile.subscriptionTier !== 'Smart Premium' && (
            <QuotaDisplay 
              quota={quotaUsage}
              showUpgradePrompt={true}
              onUpgrade={() => setShowSubscriptionManager(true)}
            />
          )}

          {/* Today's Workout */}
          {todayWorkout && (
            <Card>
              <CardHeader className="pb-3">
                <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <CardTitle className="text-lg">{t('home.todaysWorkout')}</CardTitle>
                  <Badge variant="outline">
                    <Calendar className={`w-3 h-3 ${isRTL ? 'ml-1' : 'mr-1'}`} />
                    {t('home.today')}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <h3>{todayWorkout.name}</h3>
                  <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    <span>{todayWorkout.duration}</span>
                    <span>•</span>
                    <span>{todayWorkout.exercises} {t('home.exercises')}</span>
                  </div>
                </div>
                <Button 
                  onClick={() => onNavigate('workout')}
                  className="w-full"
                >
                  {t('home.startWorkout')}
                </Button>
              </CardContent>
            </Card>
          )}

          {/* Navigation Grid */}
          <div className="grid grid-cols-2 gap-4">
            {navigationItems.map((item) => (
              <Card 
                key={item.id}
                className={`cursor-pointer transition-all duration-200 hover:scale-105 ${
                  item.locked ? 'border-orange-200 hover:border-orange-400' : ''
                }`}
                onClick={() => {
                  if (item.available) {
                    onNavigate(item.id as any);
                  } else if (item.locked && item.id === 'nutrition') {
                    // Show upgrade screen for Freemium users clicking on nutrition
                    setShowSubscriptionManager(true);
                  }
                }}
              >
                <CardContent className="p-6 text-center space-y-3">
                  <div className="relative inline-block">
                    <div className={`w-12 h-12 ${item.color} rounded-2xl flex items-center justify-center`}>
                      <item.icon className="w-6 h-6 text-white" />
                    </div>
                    {item.badge && (
                      <Badge 
                        variant="destructive" 
                        className="absolute -top-2 -right-2 w-5 h-5 p-0 flex items-center justify-center text-xs"
                      >
                        {item.badge}
                      </Badge>
                    )}
                    {item.locked && (
                      <div className="absolute inset-0 bg-gradient-to-br from-orange-500/80 to-purple-600/80 rounded-2xl flex items-center justify-center">
                        <Crown className="w-5 h-5 text-white animate-pulse" />
                      </div>
                    )}
                  </div>
                  <div>
                    <h3 className="text-sm">{item.title}</h3>
                    <p className="text-xs text-muted-foreground">{item.description}</p>
                    {item.locked && (
                      <Badge variant="secondary" className="mt-1 text-xs bg-gradient-to-r from-orange-100 to-purple-100 text-orange-700 border-orange-200">
                        {isRTL ? '👆 اضغط للترقية' : '👆 Tap to Upgrade'}
                      </Badge>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Quick Access Buttons */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">{t('home.quickAccess')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <Button 
                variant="outline" 
                className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} bg-purple-50 hover:bg-purple-100 border-purple-200`}
                onClick={() => setShowVideoBooking(true)}
              >
                <Video className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'} text-purple-600`} />
                <span className="text-purple-900">{t('home.bookVideoSession')}</span>
              </Button>
              <Button 
                variant="outline" 
                className={`w-full ${isRTL ? 'justify-end' : 'justify-start'}`}
                onClick={() => setShowProgressDetail(true)}
              >
                <TrendingUp className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('home.viewProgress')}
              </Button>
              <Button 
                variant="outline" 
                className={`w-full ${isRTL ? 'justify-end' : 'justify-start'}`}
                onClick={() => setShowExerciseLibrary(true)}
              >
                <Dumbbell className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('home.exerciseLibrary')}
              </Button>
              <Button 
                variant="outline" 
                className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} bg-blue-50 hover:bg-blue-100 border-blue-200`}
                onClick={() => setShowInBodyInput(true)}
              >
                <Activity className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'} text-blue-600`} />
                <span className="text-blue-900">{t('inbody.title')}</span>
              </Button>
              <Button 
                variant="outline" 
                className={`w-full ${isRTL ? 'justify-end' : 'justify-start'}`}
                onClick={() => onNavigate('store')}
              >
                <ShoppingBag className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('home.supplements')}
              </Button>
            </CardContent>
          </Card>

          {/* Recent Activity */}
          {isDemoMode && (
            <Card>
              <CardHeader>
                <CardTitle className={`text-lg flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <TrendingUp className="w-5 h-5" />
                  {t('home.recentActivity')}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center justify-between py-2">
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <div>
                      <div className="text-sm">{t('home.completedPushDay')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.hoursAgo')}</div>
                    </div>
                  </div>
                  <Badge variant="secondary">+250 cal</Badge>
                </div>
                <div className="flex items-center justify-between py-2">
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <div>
                      <div className="text-sm">{t('home.messageFromCoach')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.dayAgo')}</div>
                    </div>
                  </div>
                  <Badge variant="outline">{t('home.new')}</Badge>
                </div>
                <div className="flex items-center justify-between py-2">
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                    <div>
                      <div className="text-sm">{t('home.weeklyProgressUpdated')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.daysAgo')}</div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Upgrade CTA for Freemium users */}
          {userProfile.subscriptionTier === 'Freemium' && (
            <Card className="bg-gradient-to-r from-purple-50 to-blue-50 border-purple-200">
              <CardContent className="p-6 text-center space-y-4">
                <div className="flex items-center justify-center mb-2">
                  <Crown className="w-8 h-8 text-purple-600" />
                </div>
                <div>
                  <h3 className="text-purple-900">{t('home.unlockPremium')}</h3>
                  <p className="text-sm text-purple-700">
                    {t('home.premiumDesc')}
                  </p>
                </div>
                <div className="space-y-2">
                  <div className="text-xs text-purple-600 space-y-1">
                    <div>✨ {t('nutritionPrefs.title')}</div>
                    <div>💬 {t('subscription.unlimited')} {t('coach.messages')}</div>
                    <div>📊 {t('subscription.advancedAnalytics')}</div>
                  </div>
                  <Button 
                    className="bg-purple-600 hover:bg-purple-700 w-full"
                    onClick={() => setShowSubscriptionManager(true)}
                  >
                    <Crown className="w-4 h-4 mr-2" />
                    {t('home.upgradeNow')}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}