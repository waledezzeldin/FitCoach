import React, { useState, useEffect } from 'react';
import { LanguageProvider, useLanguage } from './components/LanguageContext';
import { LanguageSelectionScreen } from './components/LanguageSelectionScreen';
import { AppIntroScreen } from './components/AppIntroScreen';
import { AuthScreen } from './components/AuthScreen';
import { FirstIntakeScreen } from './components/FirstIntakeScreen';
import { SecondIntakeScreen } from './components/SecondIntakeScreen';
import { HomeScreen } from './components/HomeScreen';
import { WorkoutScreen } from './components/WorkoutScreen';
import { NutritionScreen } from './components/NutritionScreen';
import { CoachScreen } from './components/CoachScreen';
import { CoachDashboard } from './components/CoachDashboard';
import { AdminDashboard } from './components/AdminDashboard';
import { StoreScreen } from './components/StoreScreen';
import { AccountScreen } from './components/AccountScreen';
import { CoachProfileScreen } from './components/CoachProfileScreen';
import { PublicCoachProfileScreen, getMockCoachData } from './components/PublicCoachProfileScreen';
import { DemoModeIndicator } from './components/DemoModeIndicator';
import { DemoUserSwitcher } from './components/DemoUserSwitcher';
import { FirstIntakeData, SecondIntakeData } from './types/IntakeTypes';
import { InBodyHistory } from './types/InBodyTypes';
import { Toaster } from './components/ui/sonner';

// FitCoach+ v2.0 - Complete bilingual fitness application
type Screen = 'intro' | 'auth' | 'firstIntake' | 'secondIntake' | 'home' | 'workout' | 'nutrition' | 'coach' | 'store' | 'account' | 'coachProfile' | 'publicCoachProfile';
type UserType = 'user' | 'coach' | 'admin';
type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';
type MainGoal = 'fat_loss' | 'muscle_gain' | 'general_fitness';
type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';

export interface UserProfile {
  id: string;
  name: string;
  phoneNumber: string;
  email?: string;
  age: number;
  weight: number;
  height: number;
  gender: 'male' | 'female' | 'other';
  workoutFrequency: number;
  workoutLocation: 'home' | 'gym';
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
  mainGoal: MainGoal;
  injuries: InjuryArea[];
  subscriptionTier: SubscriptionTier;
  coachId?: string;
  hasCompletedSecondIntake?: boolean;
  fitnessScore?: number;
  fitnessScoreUpdatedBy?: 'auto' | 'coach';
  fitnessScoreLastUpdated?: Date;
  inBodyHistory?: InBodyHistory;
}

export interface AppState {
  isAuthenticated: boolean;
  isDemoMode: boolean;
  userType: UserType;
  userProfile: UserProfile | null;
  currentScreen: Screen;
  hasCompletedOnboarding: boolean;
  hasSeenIntro: boolean;
  firstIntakeData: FirstIntakeData | null;
  previousScreen?: Screen; // v2.0: Track where user came from before secondIntake
}

function AppContent() {
  const { hasSelectedLanguage, selectInitialLanguage, t } = useLanguage();
  
  const [appState, setAppState] = useState<AppState>({
    isAuthenticated: false,
    isDemoMode: false,
    userType: 'user',
    userProfile: null,
    currentScreen: 'intro',
    hasCompletedOnboarding: false,
    hasSeenIntro: false,
    firstIntakeData: null,
    previousScreen: undefined,
  });

  // Demo mode activation (long press on logo)
  const [logoPressDuration, setLogoPressDuration] = useState(0);

  useEffect(() => {
    // Only check for demo mode and intro completion if language has been selected
    if (hasSelectedLanguage) {
      const demoMode = localStorage.getItem('fitcoach_demo_mode') === 'true';
      const hasSeenIntro = localStorage.getItem('fitcoach_intro_seen') === 'true';
      
      if (demoMode) {
        activateDemoMode();
      } else if (hasSeenIntro) {
        setAppState(prev => ({
          ...prev,
          hasSeenIntro: true,
          currentScreen: 'auth'
        }));
      }
    }
  }, [hasSelectedLanguage]);

  const activateDemoMode = (phoneNumber?: string) => {
    // Determine user type based on phone number, default to user
    let demoType: UserType = 'user';
    if (phoneNumber === '+966507654321') {
      demoType = 'coach';
    } else if (phoneNumber === '+966509876543') {
      demoType = 'admin';
    }
    
    let demoUser: UserProfile;
    
    if (demoType === 'coach') {
      demoUser = {
        id: 'coach_1',
        name: 'Sarah Johnson',
        phoneNumber: '+966507654321',
        age: 32,
        weight: 65,
        height: 168,
        gender: 'female',
        workoutFrequency: 6,
        workoutLocation: 'gym',
        experienceLevel: 'advanced',
        mainGoal: 'general_fitness',
        injuries: [],
        subscriptionTier: 'Smart Premium',
        hasCompletedSecondIntake: true,
        fitnessScore: 88,
        fitnessScoreUpdatedBy: 'auto',
        fitnessScoreLastUpdated: new Date(),
      };
    } else if (demoType === 'admin') {
      demoUser = {
        id: 'admin_1',
        name: 'Admin User',
        phoneNumber: '+966509876543',
        age: 30,
        weight: 75,
        height: 175,
        gender: 'other',
        workoutFrequency: 5,
        workoutLocation: 'gym',
        experienceLevel: 'advanced',
        mainGoal: 'general_fitness',
        injuries: [],
        subscriptionTier: 'Smart Premium',
        hasCompletedSecondIntake: true,
        fitnessScore: 85,
        fitnessScoreUpdatedBy: 'auto',
        fitnessScoreLastUpdated: new Date(),
      };
    } else {
      demoUser = {
        id: 'demo_user_1',
        name: 'Mina H.',
        phoneNumber: phoneNumber || '+966501234567',
        age: 28,
        weight: 78,
        height: 178,
        gender: 'male',
        workoutFrequency: 4,
        workoutLocation: 'gym',
        experienceLevel: 'intermediate',
        mainGoal: 'muscle_gain',
        injuries: ['lower_back'],
        subscriptionTier: 'Freemium', // Start as Freemium to test upgrade flow
        coachId: 'coach_sara',
        hasCompletedSecondIntake: false, // To test second intake flow
        fitnessScore: 72,
        fitnessScoreUpdatedBy: 'coach',
        fitnessScoreLastUpdated: new Date(),
      };
    }

    setAppState({
      isAuthenticated: true,
      isDemoMode: true,
      userType: demoType,
      userProfile: demoUser,
      currentScreen: 'home',
      hasCompletedOnboarding: true,
      hasSeenIntro: true,
      firstIntakeData: null,
    });

    localStorage.setItem('fitcoach_demo_mode', 'true');
  };

  const handleIntroComplete = () => {
    localStorage.setItem('fitcoach_intro_seen', 'true');
    setAppState(prev => ({
      ...prev,
      hasSeenIntro: true,
      currentScreen: 'auth'
    }));
  };

  const handleAuthentication = (userType: UserType, profile?: UserProfile) => {
    let userProfile = profile;
    
    // Create default profiles for coaches and admins
    if (!profile && userType === 'coach') {
      userProfile = {
        id: 'coach_1',
        name: 'Sarah Johnson',
        phoneNumber: '+966507654321',
        age: 32,
        weight: 65,
        height: 168,
        gender: 'female',
        workoutFrequency: 6,
        workoutLocation: 'gym',
        experienceLevel: 'advanced',
        mainGoal: 'general_fitness',
        injuries: [],
        subscriptionTier: 'Smart Premium',
        hasCompletedSecondIntake: true,
        fitnessScore: 88,
        fitnessScoreUpdatedBy: 'auto',
        fitnessScoreLastUpdated: new Date(),
      };
    } else if (!profile && userType === 'admin') {
      userProfile = {
        id: 'admin_1',
        name: 'Admin User',
        phoneNumber: '+966509876543',
        age: 30,
        weight: 75,
        height: 175,
        gender: 'other',
        workoutFrequency: 5,
        workoutLocation: 'gym',
        experienceLevel: 'advanced',
        mainGoal: 'general_fitness',
        injuries: [],
        subscriptionTier: 'Smart Premium',
        hasCompletedSecondIntake: true,
        fitnessScore: 85,
        fitnessScoreUpdatedBy: 'auto',
        fitnessScoreLastUpdated: new Date(),
      };
    }

    setAppState(prev => ({
      ...prev,
      isAuthenticated: true,
      userType,
      userProfile: userProfile || null,
      currentScreen: userType === 'user' && !userProfile ? 'firstIntake' : 'home',
      hasCompletedOnboarding: !!userProfile,
    }));
  };

  const handleFirstIntakeComplete = (data: FirstIntakeData) => {
    // Create basic profile with first intake data and navigate to home
    const profile: UserProfile = {
      id: `user_${Date.now()}`,
      name: 'User',
      phoneNumber: '+966501234567',
      gender: data.gender,
      mainGoal: data.mainGoal,
      workoutLocation: data.workoutLocation,
      age: 25, // Default values
      weight: 70,
      height: 170,
      experienceLevel: 'beginner',
      workoutFrequency: 3,
      injuries: [],
      subscriptionTier: 'Freemium',
      hasCompletedSecondIntake: false,
      fitnessScore: 50, // Starting fitness score
      fitnessScoreUpdatedBy: 'auto',
      fitnessScoreLastUpdated: new Date(),
    };

    setAppState(prev => ({
      ...prev,
      firstIntakeData: data,
      userProfile: profile,
      currentScreen: 'home',
      hasCompletedOnboarding: true,
    }));
  };

  const handleSecondIntakeComplete = (data: SecondIntakeData) => {
    // Calculate initial fitness score based on experience level
    const calculateInitialScore = (experience: string) => {
      switch(experience) {
        case 'beginner': return 45;
        case 'intermediate': return 65;
        case 'advanced': return 80;
        default: return 50;
      }
    };
    
    // v2.0: Check if user already has a profile (completing second intake later)
    if (appState.userProfile) {
      // UPDATE existing profile with second intake data
      const updatedProfile: UserProfile = {
        ...appState.userProfile,
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

      // v2.0: Return to previous screen if available, otherwise go to home
      const returnScreen = appState.previousScreen || 'home';

      setAppState(prev => ({
        ...prev,
        userProfile: updatedProfile,
        currentScreen: returnScreen,
        previousScreen: undefined, // Clear previous screen
      }));
    } else {
      // CREATE new profile from first + second intake (original onboarding flow)
      const firstIntake = appState.firstIntakeData!;
      
      const profile: UserProfile = {
        id: `user_${Date.now()}`,
        name: 'User', // Default name, can be updated later
        phoneNumber: '+966501234567', // From auth
        gender: firstIntake.gender,
        mainGoal: firstIntake.mainGoal,
        workoutLocation: firstIntake.workoutLocation,
        age: data.age,
        weight: data.weight,
        height: data.height,
        experienceLevel: data.experienceLevel,
        workoutFrequency: data.workoutFrequency,
        injuries: data.injuries,
        subscriptionTier: 'Freemium', // Default subscription
        hasCompletedSecondIntake: true,
        fitnessScore: calculateInitialScore(data.experienceLevel),
        fitnessScoreUpdatedBy: 'auto',
        fitnessScoreLastUpdated: new Date(),
      };

      setAppState(prev => ({
        ...prev,
        userProfile: profile,
        currentScreen: 'home',
        hasCompletedOnboarding: true,
      }));
    }
  };

  const handleSkipSecondIntake = () => {
    // Create profile with only first intake data
    const firstIntake = appState.firstIntakeData!;
    
    const profile: UserProfile = {
      id: `user_${Date.now()}`,
      name: 'User',
      phoneNumber: '+966501234567',
      gender: firstIntake.gender,
      mainGoal: firstIntake.mainGoal,
      workoutLocation: firstIntake.workoutLocation,
      age: 25, // Default values
      weight: 70,
      height: 170,
      experienceLevel: 'beginner',
      workoutFrequency: 3,
      injuries: [],
      subscriptionTier: 'Freemium',
      hasCompletedSecondIntake: false,
      fitnessScore: 50,
      fitnessScoreUpdatedBy: 'auto',
      fitnessScoreLastUpdated: new Date(),
    };

    setAppState(prev => ({
      ...prev,
      userProfile: profile,
      currentScreen: 'home',
      hasCompletedOnboarding: true,
    }));
  };

  const navigateToScreen = (screen: Screen) => {
    setAppState(prev => {
      // v2.0: If navigating to secondIntake, save the current screen to return to later
      if (screen === 'secondIntake' && prev.currentScreen !== 'secondIntake') {
        return { ...prev, currentScreen: screen, previousScreen: prev.currentScreen };
      }
      return { ...prev, currentScreen: screen };
    });
  };

  const updateUserProfile = (updatedProfile: UserProfile) => {
    setAppState(prev => ({ 
      ...prev, 
      userProfile: updatedProfile 
    }));
  };

  const handleLogout = () => {
    setAppState({
      isAuthenticated: false,
      isDemoMode: false,
      userType: 'user',
      userProfile: null,
      currentScreen: 'auth',
      hasCompletedOnboarding: false,
      hasSeenIntro: true,
      firstIntakeData: null,
    });
    localStorage.removeItem('fitcoach_demo_mode');
    // Note: We keep the language selection on logout as users typically don't want to reselect language
  };

  const handleBackToAuth = () => {
    handleLogout();
  };

  const renderCurrentScreen = () => {
    // First, check if language has been selected
    if (!hasSelectedLanguage) {
      return <LanguageSelectionScreen onLanguageSelect={selectInitialLanguage} />;
    }

    if (!appState.hasSeenIntro) {
      return <AppIntroScreen onComplete={handleIntroComplete} />;
    }

    if (!appState.isAuthenticated) {
      return (
        <AuthScreen 
          onAuthenticate={handleAuthentication}
          onActivateDemo={activateDemoMode}
        />
      );
    }

    // v2.0 Two-stage intake flow
    if (appState.userType === 'user' && !appState.hasCompletedOnboarding) {
      if (appState.currentScreen === 'firstIntake') {
        return (
          <FirstIntakeScreen 
            onComplete={handleFirstIntakeComplete}
            onBack={handleBackToAuth}
            isDemoMode={appState.isDemoMode}
          />
        );
      }
      
      if (appState.currentScreen === 'secondIntake') {
        return (
          <SecondIntakeScreen 
            onComplete={handleSecondIntakeComplete}
            onBack={handleSkipSecondIntake}
            isDemoMode={appState.isDemoMode}
          />
        );
      }
    }

    // Safety check - if userProfile is still null at this point, something went wrong
    if (!appState.userProfile) {
      return (
        <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center">
          <div className="text-center">
            <p>{t('app.loadingProfile')}</p>
          </div>
        </div>
      );
    }

    switch (appState.currentScreen) {
      case 'home':
        // Show different home screens based on user type
        if (appState.userType === 'admin') {
          return (
            <AdminDashboard 
              userProfile={appState.userProfile}
              onNavigate={navigateToScreen}
              isDemoMode={appState.isDemoMode}
            />
          );
        }
        if (appState.userType === 'coach') {
          return (
            <CoachDashboard 
              userProfile={appState.userProfile}
              onNavigate={navigateToScreen}
              onEditProfile={() => navigateToScreen('coachProfile')}
              isDemoMode={appState.isDemoMode}
            />
          );
        }
        return (
          <HomeScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onUpdateProfile={updateUserProfile}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'workout':
        return (
          <WorkoutScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onNavigateToSecondIntake={() => navigateToScreen('secondIntake')}
            onLogout={handleBackToAuth}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'secondIntake':
        return (
          <SecondIntakeScreen 
            onComplete={handleSecondIntakeComplete}
            onBack={() => navigateToScreen('home')}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'nutrition':
        return (
          <NutritionScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onUpdateProfile={updateUserProfile}
            onLogout={handleBackToAuth}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'coach':
        return (
          <CoachScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onViewCoachProfile={() => navigateToScreen('publicCoachProfile')}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'store':
        return (
          <StoreScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'account':
        return (
          <AccountScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onLogout={handleLogout}
            onUpdateProfile={updateUserProfile}
            isDemoMode={appState.isDemoMode}
          />
        );
      case 'coachProfile':
        return (
          <CoachProfileScreen 
            userProfile={appState.userProfile}
            onBack={() => navigateToScreen('home')}
            onLogout={handleLogout}
            onUpdateProfile={updateUserProfile}
          />
        );
      case 'publicCoachProfile':
        return (
          <PublicCoachProfileScreen 
            coach={getMockCoachData()}
            onBack={() => navigateToScreen('coach')}
            onMessage={() => navigateToScreen('coach')}
            onBookCall={() => {
              navigateToScreen('coach');
              // Could show booking dialog here
            }}
          />
        );
      default:
        return (
          <HomeScreen 
            userProfile={appState.userProfile}
            onNavigate={navigateToScreen}
            onUpdateProfile={updateUserProfile}
            isDemoMode={appState.isDemoMode}
          />
        );
    }
  };

  return (
    <div className="w-full max-w-md mx-auto bg-background min-h-screen relative overflow-hidden">
      {appState.isDemoMode && <DemoModeIndicator />}
      {appState.isDemoMode && appState.userProfile && (
        <DemoUserSwitcher currentPhoneNumber={appState.userProfile.phoneNumber} />
      )}
      {renderCurrentScreen()}
      <Toaster />
    </div>
  );
}

export default function App() {
  return (
    <LanguageProvider>
      <AppContent />
    </LanguageProvider>
  );
}