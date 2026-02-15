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
  Activity,
  ChevronDown,
  ChevronUp
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
import { PageTransition } from './PageTransition';
import { AnimatedCard } from './AnimatedCard';
import { AnimatedButton } from './AnimatedButton';
import { motion } from 'motion/react';

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
  const [logoClickCount, setLogoClickCount] = useState(0);
  const [showDebugPanel, setShowDebugPanel] = useState(false);
  
  // Debug: Triple-click logo to show debug options
  const handleLogoClick = () => {
    const newCount = logoClickCount + 1;
    setLogoClickCount(newCount);
    
    if (newCount === 3) {
      setShowDebugPanel(true);
      setLogoClickCount(0);
    }
    
    // Reset counter after 2 seconds
    setTimeout(() => setLogoClickCount(0), 2000);
  };
  
  const resetAllIntroScreens = () => {
    localStorage.removeItem('workout_intro_seen');
    localStorage.removeItem('nutrition_intro_seen');
    localStorage.removeItem('coach_intro_seen');
    localStorage.removeItem('store_intro_seen');
    toast.success(isRTL ? 'تم إعادة تعيين جميع الشاشات الترحيبية' : 'All intro screens reset!');
    setShowDebugPanel(false);
  };
  
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
          toast.success(isRTL ? '🎉 مبروك الترقة!' : '🎉 Upgrade Successful!', {
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
      {/* Debug Panel Dialog */}
      {showDebugPanel && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <Card className="max-w-sm w-full">
            <CardHeader>
              <CardTitle className="text-lg">Debug Options</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <p className="text-sm text-muted-foreground">
                Reset all intro/welcome screens to see them again on next visit
              </p>
              <Button 
                onClick={resetAllIntroScreens}
                className="w-full"
              >
                Reset All Intro Screens
              </Button>
              <Button 
                variant="outline"
                onClick={() => setShowDebugPanel(false)}
                className="w-full"
              >
                Cancel
              </Button>
            </CardContent>
          </Card>
        </div>
      )}
    
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1671970922029-0430d2ae122c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjBpbnRlcmlvciUyMGVxdWlwbWVudHxlbnwxfHx8fDE3NjUxOTkxNTJ8MA&ixlib=rb-4.1.0&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
        {/* Header */}
        <div className="bg-gradient-to-r from-slate-700 to-slate-900 text-white p-4 rounded-b-3xl">
          <div className={`flex items-center justify-between mb-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <div 
              className={`${isRTL ? 'text-right' : 'text-left'} cursor-pointer`}
              onClick={handleLogoClick}
            >
              <h1>{t('home.hello')}, {userProfile.name.split(' ')[0]}! 👋</h1>
              <p className="opacity-90 text-sm">{t('home.ready')}</p>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="bg-white/20 text-white text-xs">
                {userProfile.subscriptionTier}
              </Badge>
              <Button 
                variant="ghost" 
                size="icon"
                onClick={() => onNavigate('account')}
                className="text-white hover:bg-white/20 h-8 w-8"
              >
                <User className="w-4 h-4" />
              </Button>
            </div>
          </div>

          {/* Fitness Score - Compact Display */}
          <div className="bg-white/10 rounded-xl p-3 mb-3">
            <div className={`flex items-center justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <div className={isRTL ? 'text-right' : 'text-left'}>
                <div className="text-xs opacity-90">{t('home.fitnessScore')}</div>
                <div className="text-xs opacity-75">
                  {userProfile.fitnessScoreUpdatedBy === 'coach' 
                    ? t('home.updateByCoach') 
                    : t('home.autoUpdated')}
                </div>
              </div>
              <div className="text-center">
                <div className="text-3xl">
                  {userProfile.fitnessScore || (isDemoMode ? 72 : 0)}
                </div>
                <div className="text-xs opacity-75">/100</div>
              </div>
            </div>
            <Progress 
              value={userProfile.fitnessScore || (isDemoMode ? 72 : 0)} 
              className="bg-white/20 h-1.5" 
            />
          </div>

          {/* Compact Stats Grid */}
          <div className="grid grid-cols-3 gap-2 mb-3">
            {/* Calories Burned */}
            <div className="bg-white/10 rounded-xl p-2 text-center">
              <Flame className="w-4 h-4 mx-auto mb-1" />
              <div className="text-sm">{currentStats.caloriesBurned}</div>
              <div className="text-xs opacity-90">{t('home.caloriesBurned').split(' ')[0]}</div>
            </div>

            {/* Calories Consumed */}
            <div className="bg-white/10 rounded-xl p-2 text-center">
              <Apple className="w-4 h-4 mx-auto mb-1" />
              <div className="text-sm">{currentStats.caloriesConsumed}</div>
              <div className="text-xs opacity-90">{t('home.caloriesConsumed').split(' ')[0]}</div>
            </div>

            {/* Plan Adherence */}
            <div className="bg-white/10 rounded-xl p-2 text-center">
              <Target className="w-4 h-4 mx-auto mb-1" />
              <div className="text-sm">{currentStats.planAdherence}%</div>
              <div className="text-xs opacity-90">{t('home.adherence')}</div>
            </div>
          </div>

          {/* Compact Weekly Progress */}
          <div className="bg-white/10 rounded-xl p-2.5">
            <div className={`flex items-center justify-between mb-1.5 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <span className="text-xs">{t('home.weeklyProgress')}</span>
              <span className="text-xs">{currentStats.weeklyProgress}%</span>
            </div>
            <Progress value={currentStats.weeklyProgress} className="bg-white/20 h-1.5" />
            <div className="flex justify-between text-xs opacity-75 mt-1">
              <span>{currentStats.workoutsCompleted}/{currentStats.totalWorkouts}</span>
              <span>{t('home.thisWeek')}</span>
            </div>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* v2.0 Quota Display */}
          {userProfile.subscriptionTier !== 'Smart Premium' && (
            <QuotaDisplay 
              quota={quotaUsage}
              showUpgradePrompt={true}
              onUpgrade={() => setShowSubscriptionManager(true)}
            />
          )}

          {/* Today's Workout - Compact */}
          {todayWorkout && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.1 }}
            >
              <Card className="border shadow-sm bg-purple-50">
                <CardHeader className="pb-2 pt-3 px-4">
                  <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <CardTitle className="text-base">{t('home.todaysWorkout')}</CardTitle>
                    <Badge variant="outline" className="text-xs">
                      <Calendar className={`w-3 h-3 ${isRTL ? 'ml-1' : 'mr-1'}`} />
                      {t('home.today')}
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-3 px-4 pb-3">
                  <div>
                    <h3 className="text-sm">{todayWorkout.name}</h3>
                    <div className="flex items-center gap-3 text-xs text-muted-foreground">
                      <span>{todayWorkout.duration}</span>
                      <span>•</span>
                      <span>{todayWorkout.exercises} {t('home.exercises')}</span>
                    </div>
                  </div>
                  <motion.div
                    whileTap={{ scale: 0.95 }}
                    whileHover={{ scale: 1.02 }}
                    transition={{ type: "spring", stiffness: 400, damping: 17 }}
                  >
                    <Button 
                      onClick={() => onNavigate('workout')}
                      className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 h-9 text-sm"
                    >
                      <Dumbbell className="w-4 h-4 mr-2" />
                      {t('home.startWorkout')}
                    </Button>
                  </motion.div>
                </CardContent>
              </Card>
            </motion.div>
          )}

          {/* Navigation Grid - Compact */}
          <div className="grid grid-cols-2 gap-3">
            {navigationItems.map((item, index) => (
              <motion.div
                key={item.id}
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                transition={{ 
                  duration: 0.3,
                  delay: index * 0.1,
                  ease: "easeOut"
                }}
                whileHover={{ 
                  scale: 1.05,
                  transition: { type: "spring", stiffness: 400, damping: 17 }
                }}
                whileTap={{ 
                  scale: 0.95,
                  transition: { type: "spring", stiffness: 400, damping: 17 }
                }}
              >
                <Card 
                  className={`cursor-pointer transition-all hover:shadow-lg border ${ 
                    item.locked ? 'border-2 border-orange-200 bg-orange-50' : 
                    item.id === 'workout' ? 'bg-blue-50' :
                    item.id === 'nutrition' ? 'bg-green-50' :
                    item.id === 'coach' ? 'bg-amber-50' :
                    'bg-cyan-50'
                  }`}
                  onClick={() => {
                    if (item.available) {
                      onNavigate(item.id as any);
                    } else if (item.locked && item.id === 'nutrition') {
                      setShowSubscriptionManager(true);
                    }
                  }}
                >
                  <CardContent className="p-4 text-center space-y-2">
                    <div className="relative inline-block">
                      <div className={`w-12 h-12 ${item.color} rounded-2xl flex items-center justify-center`}>
                        <item.icon className="w-6 h-6 text-white" />
                      </div>
                      {item.badge && (
                        <Badge 
                          variant="destructive" 
                          className="absolute -top-1 -right-1 w-5 h-5 p-0 flex items-center justify-center text-xs"
                        >
                          {item.badge}
                        </Badge>
                      )}
                      {item.locked && (
                        <div className="absolute inset-0 bg-gradient-to-br from-orange-500 to-pink-600 rounded-2xl flex items-center justify-center">
                          <Crown className="w-5 h-5 text-white" />
                        </div>
                      )}
                    </div>
                    <div>
                      <h3 className="text-sm">{item.title}</h3>
                      <p className="text-xs text-muted-foreground">{item.description}</p>
                      {item.locked && (
                        <Badge variant="secondary" className="mt-1.5 text-xs">
                          {isRTL ? '👆 اضغط للترقية' : '👆 Tap to Upgrade'}
                        </Badge>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>

          {/* Expandable Quick Access Menu */}
          <ExpandableQuickAccess
            isRTL={isRTL}
            t={t}
            onBookVideo={() => setShowVideoBooking(true)}
            onViewProgress={() => setShowProgressDetail(true)}
            onExerciseLibrary={() => setShowExerciseLibrary(true)}
            onInBodyInput={() => setShowInBodyInput(true)}
            onNavigateStore={() => onNavigate('store')}
          />

          {/* Compact Recent Activity */}
          {isDemoMode && (
            <Card className="border shadow-sm">
              <CardHeader className="pb-2 pt-3 px-4">
                <CardTitle className={`text-sm flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <TrendingUp className="w-4 h-4" />
                  {t('home.recentActivity')}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 px-4 pb-3">
                <div className="flex items-center justify-between py-1.5">
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-green-500 rounded-full"></div>
                    <div>
                      <div className="text-xs">{t('home.completedPushDay')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.hoursAgo')}</div>
                    </div>
                  </div>
                  <Badge variant="secondary" className="text-xs">+250 cal</Badge>
                </div>
                <div className="flex items-center justify-between py-1.5">
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-500 rounded-full"></div>
                    <div>
                      <div className="text-xs">{t('home.messageFromCoach')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.dayAgo')}</div>
                    </div>
                  </div>
                  <Badge variant="outline" className="text-xs">{t('home.new')}</Badge>
                </div>
                <div className="flex items-center justify-between py-1.5">
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-purple-500 rounded-full"></div>
                    <div>
                      <div className="text-xs">{t('home.weeklyProgressUpdated')}</div>
                      <div className="text-xs text-muted-foreground">{t('home.daysAgo')}</div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Compact Upgrade CTA for Freemium users */}
          {userProfile.subscriptionTier === 'Freemium' && (
            <Card className="bg-gradient-to-r from-purple-50 to-blue-50 border-purple-200 shadow-sm">
              <CardContent className="p-4 text-center space-y-3">
                <div className="flex items-center justify-center">
                  <Crown className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <h3 className="text-sm text-purple-900">{t('home.unlockPremium')}</h3>
                  <p className="text-xs text-purple-700">
                    {t('home.premiumDesc')}
                  </p>
                </div>
                <div className="space-y-1.5">
                  <div className="text-xs text-purple-600 space-y-0.5">
                    <div>✨ {t('nutritionPrefs.title')}</div>
                    <div>💬 {t('subscription.unlimited')} {t('coach.messages')}</div>
                    <div>📊 {t('subscription.advancedAnalytics')}</div>
                  </div>
                  <Button 
                    className="bg-purple-600 hover:bg-purple-700 w-full h-9 text-sm"
                    onClick={() => setShowSubscriptionManager(true)}
                  >
                    <Crown className="w-3 h-3 mr-1.5" />
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

// Expandable Quick Access Component
function ExpandableQuickAccess({ 
  isRTL, 
  t, 
  onBookVideo, 
  onViewProgress, 
  onExerciseLibrary, 
  onInBodyInput,
  onNavigateStore 
}: {
  isRTL: boolean;
  t: (key: string) => string;
  onBookVideo: () => void;
  onViewProgress: () => void;
  onExerciseLibrary: () => void;
  onInBodyInput: () => void;
  onNavigateStore: () => void;
}) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <Card className="border shadow-sm">
      <CardHeader 
        className="pb-2 pt-3 px-4 cursor-pointer hover:bg-muted/50 transition-colors"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
          <CardTitle className="text-sm flex items-center gap-2">
            <Dumbbell className="w-4 h-4" />
            {t('home.quickAccess')}
          </CardTitle>
          {isExpanded ? (
            <ChevronUp className="w-4 h-4 text-muted-foreground" />
          ) : (
            <ChevronDown className="w-4 h-4 text-muted-foreground" />
          )}
        </div>
      </CardHeader>
      {isExpanded && (
        <CardContent className="space-y-1.5 px-4 pb-3">
          <Button 
            variant="outline" 
            size="sm"
            className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} bg-purple-50 hover:bg-purple-100 border-purple-200 h-8 text-xs`}
            onClick={onBookVideo}
          >
            <Video className={`w-3.5 h-3.5 ${isRTL ? 'ml-2' : 'mr-2'} text-purple-600`} />
            <span className="text-purple-900">{t('home.bookVideoSession')}</span>
          </Button>
          <Button 
            variant="outline" 
            size="sm"
            className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} h-8 text-xs`}
            onClick={onViewProgress}
          >
            <TrendingUp className={`w-3.5 h-3.5 ${isRTL ? 'ml-2' : 'mr-2'}`} />
            {t('home.viewProgress')}
          </Button>
          <Button 
            variant="outline" 
            size="sm"
            className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} h-8 text-xs`}
            onClick={onExerciseLibrary}
          >
            <Dumbbell className={`w-3.5 h-3.5 ${isRTL ? 'ml-2' : 'mr-2'}`} />
            {t('home.exerciseLibrary')}
          </Button>
          <Button 
            variant="outline" 
            size="sm"
            className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} bg-blue-50 hover:bg-blue-100 border-blue-200 h-8 text-xs`}
            onClick={onInBodyInput}
          >
            <Activity className={`w-3.5 h-3.5 ${isRTL ? 'ml-2' : 'mr-2'} text-blue-600`} />
            <span className="text-blue-900">{t('inbody.title')}</span>
          </Button>
          <Button 
            variant="outline" 
            size="sm"
            className={`w-full ${isRTL ? 'justify-end' : 'justify-start'} h-8 text-xs`}
            onClick={onNavigateStore}
          >
            <ShoppingBag className={`w-3.5 h-3.5 ${isRTL ? 'ml-2' : 'mr-2'}`} />
            {t('home.supplements')}
          </Button>
        </CardContent>
      )}
    </Card>
  );
}