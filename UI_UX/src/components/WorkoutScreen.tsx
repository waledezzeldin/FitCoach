import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Input } from './ui/input';
import { ArrowLeft, Play, Pause, RotateCcw, CheckCircle, Clock, Target, Plus, Minus, Eye, Calendar, AlertTriangle, Info, Clipboard, Video, RefreshCw } from 'lucide-react';
import { UserProfile } from '../App';
import { ExerciseDetailScreen } from './ExerciseDetailScreen';
import { exerciseDatabase, getExerciseById, translateExercise } from './EnhancedExerciseDatabase';
import { useLanguage } from './LanguageContext';
import { findSafeAlternatives } from '../utils/injuryRules';
import { Alert, AlertDescription } from './ui/alert';
import { ScrollArea } from './ui/scroll-area';
import { toast } from 'sonner@2.0.3';
import { WorkoutIntroScreen } from './WorkoutIntroScreen';

interface WorkoutScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'nutrition' | 'coach' | 'store' | 'account', options?: { coachTab?: 'messages' | 'sessions' }) => void;
  onNavigateToSecondIntake?: () => void;
  onLogout?: () => void;
  isDemoMode: boolean;
}

interface Exercise {
  id: string;
  name: string;
  exerciseId: string; // Reference to exercise database
  sets: number;
  reps: string;
  restTime: number;
  muscleGroup: string;
  videoUrl?: string;
  completed: boolean;
  loggedSets: { reps: number; weight?: number; time?: number }[];
  isSwapped?: boolean;
  originalExerciseId?: string;
}

interface WorkoutPlan {
  id: string;
  name: string;
  week: number;
  day: number;
  duration: string;
  difficulty: string;
  exercises: Exercise[];
}

export function WorkoutScreen({ userProfile, onNavigate, onNavigateToSecondIntake, onLogout, isDemoMode }: WorkoutScreenProps) {
  const { t, isRTL } = useLanguage();
  
  // Show intro screen on first usage
  const [showIntro, setShowIntro] = React.useState(() => {
    const hasSeenIntro = localStorage.getItem('workout_intro_seen');
    return !hasSeenIntro;
  });
  
  const [currentView, setCurrentView] = React.useState<'overview' | 'exercise' | 'exercise-detail'>('overview');
  const [currentExerciseIndex, setCurrentExerciseIndex] = React.useState(0);
  const [isTimerRunning, setIsTimerRunning] = React.useState(false);
  const [timerSeconds, setTimerSeconds] = React.useState(60);
  const [currentSet, setCurrentSet] = React.useState(0);
  const [showFirstTimeOverlay, setShowFirstTimeOverlay] = React.useState(false);
  const [showIntakePrompt, setShowIntakePrompt] = React.useState(!userProfile.hasCompletedSecondIntake);
  const [workoutStartTime, setWorkoutStartTime] = React.useState<Date | null>(null);
  const [totalCaloriesBurned, setTotalCaloriesBurned] = React.useState(0);
  
  // v2.0: Injury substitution state
  const [showInjuryDialog, setShowInjuryDialog] = React.useState(false);
  const [showAlternativesDialog, setShowAlternativesDialog] = React.useState(false);
  const [selectedInjury, setSelectedInjury] = React.useState<string>('');
  const [alternativeExercises, setAlternativeExercises] = React.useState<any[]>([]);
  
  // v2.0: Monitor hasCompletedSecondIntake changes to close dialog when user returns
  React.useEffect(() => {
    if (userProfile.hasCompletedSecondIntake) {
      setShowIntakePrompt(false);
    }
  }, [userProfile.hasCompletedSecondIntake]);
  
  const injuryAreas = ['shoulder', 'knee', 'lower_back', 'neck', 'elbow', 'wrist', 'ankle', 'hip'];

  // Enhanced demo workout data with exercise database references
  const demoWorkout: WorkoutPlan = {
    id: 'workout_1',
    name: t('workouts.upperBodyStrength'),
    week: 1,
    day: 3,
    duration: '45 min',
    difficulty: t('workouts.intermediate'),
    exercises: [
      {
        id: 'ex1',
        exerciseId: 'bench_press',
        name: t('exercises.benchPress'),
        sets: 4,
        reps: '8-10',
        restTime: 90,
        muscleGroup: t('workouts.chest'),
        completed: true,
        loggedSets: [
          { reps: 8, weight: 80, time: Date.now() - 3600000 },
          { reps: 8, weight: 80, time: Date.now() - 3400000 },
          { reps: 7, weight: 80, time: Date.now() - 3200000 },
          { reps: 6, weight: 80, time: Date.now() - 3000000 }
        ]
      },
      {
        id: 'ex2',
        exerciseId: 'pull_ups',
        name: t('exercises.pullUps'),
        sets: 3,
        reps: '6-8',
        restTime: 120,
        muscleGroup: t('workouts.back'),
        completed: false,
        loggedSets: [
          { reps: 8, time: Date.now() - 1800000 },
          { reps: 7, time: Date.now() - 1600000 }
        ]
      },
      {
        id: 'ex3',
        exerciseId: 'overhead_press',
        name: t('exercises.shoulderPress'),
        sets: 3,
        reps: '8-10',
        restTime: 90,
        muscleGroup: t('workouts.shoulders'),
        completed: false,
        loggedSets: []
      },
      {
        id: 'ex4',
        exerciseId: 'barbell_rows',
        name: t('exercises.barbellRows'),
        sets: 3,
        reps: '8-10',
        restTime: 90,
        muscleGroup: t('workouts.back'),
        completed: false,
        loggedSets: []
      },
    ]
  };

  const [workout, setWorkout] = React.useState<WorkoutPlan>(demoWorkout);
  const currentExercise = workout.exercises[currentExerciseIndex];
  const completedExercises = workout.exercises.filter(ex => ex.completed).length;
  const progress = (completedExercises / workout.exercises.length) * 100;

  const startExercise = (index: number) => {
    setCurrentExerciseIndex(index);
    setCurrentView('exercise');
    setCurrentSet(workout.exercises[index].loggedSets.length);
    setTimerSeconds(workout.exercises[index].restTime);
    
    // Start workout timer if not already started
    if (!workoutStartTime) {
      setWorkoutStartTime(new Date());
    }
    
    // Check if this is user's first time with this exercise (simulate)
    const hasSeenExerciseBefore = localStorage.getItem(`exercise_seen_${workout.exercises[index].exerciseId}`);
    if (!hasSeenExerciseBefore && isDemoMode) {
      setShowFirstTimeOverlay(true);
    }
  };

  const viewExerciseDetails = (index: number) => {
    setCurrentExerciseIndex(index);
    setCurrentView('exercise-detail');
  };

  // v2.0: Handle injury reporting
  const handleReportInjury = () => {
    if (!selectedInjury) {
      toast.error(t('workouts.selectInjuryArea'));
      return;
    }
    
    const currentEx = workout.exercises[currentExerciseIndex];
    const alternatives = findSafeAlternatives(
      currentEx.exerciseId,
      selectedInjury,
      currentEx.muscleGroup
    );
    
    setAlternativeExercises(alternatives);
    setShowAlternativesDialog(true);
    setShowInjuryDialog(false);
  };
  
  // v2.0: Handle exercise swap from injury alternatives
  const handleSwapExercise = (newExerciseId: string) => {
    const newExerciseData = getExerciseById(newExerciseId);
    if (!newExerciseData) return;

    // Translate the new exercise data
    const translatedExercise = translateExercise(newExerciseData, t);

    const updatedWorkout = { ...workout };
    const currentExercise = updatedWorkout.exercises[currentExerciseIndex];
    
    // Update exercise with new data
    updatedWorkout.exercises[currentExerciseIndex] = {
      ...currentExercise,
      exerciseId: newExerciseId,
      name: translatedExercise.name,
      sets: newExerciseData.defaultSets,
      reps: newExerciseData.defaultReps,
      restTime: newExerciseData.defaultRestTime,
      muscleGroup: newExerciseData.muscleGroup,
      isSwapped: true,
      originalExerciseId: currentExercise.originalExerciseId || currentExercise.exerciseId,
      loggedSets: [] // Reset logged sets for new exercise
    };
    
    setWorkout(updatedWorkout);
    setShowAlternativesDialog(false);
    toast.success(t('workouts.exerciseSwapped'));
    setCurrentView('overview');
  };

  const dismissFirstTimeOverlay = () => {
    setShowFirstTimeOverlay(false);
    const currentExercise = workout.exercises[currentExerciseIndex];
    localStorage.setItem(`exercise_seen_${currentExercise.exerciseId}`, 'true');
  };

  const logSet = (reps: number, weight?: number) => {
    const updatedWorkout = { ...workout };
    const exercise = updatedWorkout.exercises[currentExerciseIndex];
    
    if (currentSet < exercise.sets) {
      exercise.loggedSets.push({ 
        reps, 
        weight, 
        time: Date.now()
      });
      
      if (exercise.loggedSets.length === exercise.sets) {
        exercise.completed = true;
        // Estimate calories burned for this exercise (mock calculation)
        const exerciseCalories = Math.floor(reps * (weight || 0) * 0.1) + 15;
        setTotalCaloriesBurned(prev => prev + exerciseCalories);
      }
    }
    
    setWorkout(updatedWorkout);
    setCurrentSet(exercise.loggedSets.length);
    
    // Start rest timer if not the last set
    if (exercise.loggedSets.length < exercise.sets) {
      setTimerSeconds(exercise.restTime);
      setIsTimerRunning(true);
    }
  };

  const nextExercise = () => {
    if (currentExerciseIndex < workout.exercises.length - 1) {
      startExercise(currentExerciseIndex + 1);
    } else {
      setCurrentView('overview');
    }
  };

  React.useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isTimerRunning && timerSeconds > 0) {
      interval = setInterval(() => {
        setTimerSeconds(prev => prev - 1);
      }, 1000);
    } else if (timerSeconds === 0) {
      setIsTimerRunning(false);
    }
    return () => clearInterval(interval);
  }, [isTimerRunning, timerSeconds]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const getWorkoutDuration = () => {
    if (!workoutStartTime) return '0:00';
    const now = new Date();
    const diffMs = now.getTime() - workoutStartTime.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffSecs = Math.floor((diffMs % 60000) / 1000);
    return `${diffMins}:${diffSecs.toString().padStart(2, '0')}`;
  };

  // Exercise Detail Screen View
  if (currentView === 'exercise-detail') {
    const currentExercise = workout.exercises[currentExerciseIndex];
    return (
      <ExerciseDetailScreen
        exerciseId={currentExercise.exerciseId}
        onBack={() => setCurrentView('overview')}
        onStartExercise={() => {
          setCurrentView('exercise');
          setCurrentSet(currentExercise.loggedSets.length);
          setTimerSeconds(currentExercise.restTime);
          if (!workoutStartTime) {
            setWorkoutStartTime(new Date());
          }
        }}
        onSwapExercise={handleSwapExercise}
        showFirstTimeOverlay={showFirstTimeOverlay}
        onDismissOverlay={dismissFirstTimeOverlay}
      />
    );
  }
  
  // Show intro screen on first visit
  if (showIntro) {
    return (
      <WorkoutIntroScreen
        onGetStarted={() => {
          setShowIntro(false);
          localStorage.setItem('workout_intro_seen', 'true');
        }}
      />
    );
  }

  if (currentView === 'exercise' && currentExercise) {
    return (
      <div className="min-h-screen bg-background relative">
        {/* Background Image */}
        <div 
          className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
          style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1759300642647-cfe1e9bf7225?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
        />
        
        {/* Content */}
        <div className="relative z-10">
        {/* Header */}
        <div className="bg-primary text-primary-foreground p-4">
          <div className="flex items-center gap-3 mb-4">
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => setCurrentView('overview')}
              className="text-primary-foreground hover:bg-primary-foreground/20"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div className="flex-1">
              <h1 className="text-lg">{currentExercise.name}</h1>
              <p className="text-primary-foreground/80 text-sm">
                {currentExercise.muscleGroup} • Set {currentSet + 1} of {currentExercise.sets}
              </p>
            </div>
          </div>
          <Progress value={(currentSet / currentExercise.sets) * 100} className="bg-primary-foreground/20" />
        </div>

        <div className="p-4 space-y-6">
          {/* Exercise Details */}
          <Card>
            <CardContent className="p-6">
              <div className="grid grid-cols-2 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold">{currentExercise.sets}</div>
                  <div className="text-sm text-muted-foreground">{t('workouts.sets')}</div>
                </div>
                <div>
                  <div className="text-2xl font-bold">{currentExercise.reps}</div>
                  <div className="text-sm text-muted-foreground">{t('workouts.reps')}</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Video Placeholder */}
          <Card>
            <CardContent className="p-0">
              <div className="aspect-video bg-muted rounded-lg flex items-center justify-center">
                <div className="text-center">
                  <Play className="w-12 h-12 mx-auto mb-2 text-muted-foreground" />
                  <p className="text-muted-foreground">{t('workouts.exerciseDemo')}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Rest Timer */}
          {isTimerRunning && (
            <Card className="bg-blue-50 border-blue-200">
              <CardContent className="p-6 text-center">
                <Clock className="w-8 h-8 mx-auto mb-2 text-blue-600" />
                <div className="text-3xl font-bold text-blue-600 mb-2">
                  {formatTime(timerSeconds)}
                </div>
                <p className="text-blue-700 mb-4">{t('workouts.restTime')}</p>
                <div className="flex gap-2 justify-center">
                  <Button 
                    variant="outline"
                    onClick={() => setIsTimerRunning(!isTimerRunning)}
                  >
                    {isTimerRunning ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
                  </Button>
                  <Button 
                    variant="outline"
                    onClick={() => {
                      setTimerSeconds(currentExercise.restTime);
                      setIsTimerRunning(false);
                    }}
                  >
                    <RotateCcw className="w-4 h-4" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* v2.0: Report Injury Button */}
          <Button
            variant="outline"
            className="w-full"
            onClick={() => setShowInjuryDialog(true)}
          >
            <AlertTriangle className="w-4 h-4 mr-2" />
            {t('workouts.reportInjury')}
          </Button>

          {/* Log Set */}
          {currentSet < currentExercise.sets && (
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('workouts.logSet')} {currentSet + 1}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium">{t('workouts.reps')}</label>
                    <div className="flex items-center gap-2 mt-1">
                      <Button variant="outline" size="icon">
                        <Minus className="w-4 h-4" />
                      </Button>
                      <Input 
                        type="number" 
                        defaultValue="8" 
                        className="text-center"
                        id="reps-input"
                      />
                      <Button variant="outline" size="icon">
                        <Plus className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium">{t('workouts.weight')} ({t('workouts.kg')})</label>
                    <div className="flex items-center gap-2 mt-1">
                      <Button variant="outline" size="icon">
                        <Minus className="w-4 h-4" />
                      </Button>
                      <Input 
                        type="number" 
                        defaultValue="80" 
                        className="text-center"
                        id="weight-input"
                      />
                      <Button variant="outline" size="icon">
                        <Plus className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </div>
                <Button 
                  className="w-full"
                  onClick={() => {
                    const repsInput = document.getElementById('reps-input') as HTMLInputElement;
                    const weightInput = document.getElementById('weight-input') as HTMLInputElement;
                    logSet(parseInt(repsInput.value), parseFloat(weightInput.value));
                  }}
                >
                  {t('workouts.logSet')}
                </Button>
              </CardContent>
            </Card>
          )}

          {/* Logged Sets */}
          {currentExercise.loggedSets.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('workouts.completedSets')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {currentExercise.loggedSets.map((set, index) => (
                    <div key={index} className="flex items-center justify-between p-3 bg-muted rounded-lg">
                      <span>Set {index + 1}</span>
                      <div className="flex items-center gap-4">
                        <span>{set.reps} {t('workouts.reps')}</span>
                        {set.weight && <span>{set.weight} {t('workouts.kg')}</span>}
                        <CheckCircle className="w-4 h-4 text-green-600" />
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Next Exercise Button */}
          {currentExercise.completed && (
            <Button 
              className="w-full"
              onClick={nextExercise}
            >
              {currentExerciseIndex < workout.exercises.length - 1 ? t('workouts.nextExercise') : t('workouts.finishWorkout')}
            </Button>
          )}
        </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1717571209798-ac9312c2d3cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Second Intake Prompt Dialog */}
      <Dialog open={showIntakePrompt} onOpenChange={setShowIntakePrompt}>
        <DialogContent className={isRTL ? 'rtl' : ''}>
          <DialogHeader>
            <DialogTitle className={isRTL ? 'text-right' : ''}>
              {t('intake.prompt.title')}
            </DialogTitle>
            <DialogDescription className={isRTL ? 'text-right' : ''}>
              {t('intake.prompt.description')}
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-3 py-4">
            <div className={`bg-blue-50 border border-blue-200 rounded-lg p-4 ${isRTL ? 'text-right' : ''}`}>
              <div className={`flex items-start gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                <Clipboard className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <h4 className="font-medium text-blue-900 mb-1">{t('intake.prompt.option1Title')}</h4>
                  <p className="text-sm text-blue-700">{t('intake.prompt.option1Desc')}</p>
                </div>
              </div>
            </div>
            
            <div className={`bg-purple-50 border border-purple-200 rounded-lg p-4 ${isRTL ? 'text-right' : ''}`}>
              <div className={`flex items-start gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                <Video className="w-5 h-5 text-purple-600 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <h4 className="font-medium text-purple-900 mb-1">{t('intake.prompt.option2Title')}</h4>
                  <p className="text-sm text-purple-700">{t('intake.prompt.option2Desc')}</p>
                  {userProfile.subscriptionTier === 'Freemium' && (
                    <Badge variant="secondary" className="mt-2 bg-green-100 text-green-800">
                      {t('intake.prompt.freeCall')}
                    </Badge>
                  )}
                </div>
              </div>
            </div>
          </div>

          <DialogFooter className={`gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <Button
              variant="outline"
              onClick={() => setShowIntakePrompt(false)}
            >
              {t('common.later')}
            </Button>
            <Button
              variant="outline"
              onClick={() => {
                setShowIntakePrompt(false);
                onNavigate('coach', { coachTab: 'sessions' });
              }}
              className="gap-2"
            >
              <Video className="w-4 h-4" />
              {t('intake.prompt.bookCall')}
            </Button>
            <Button
              onClick={() => {
                setShowIntakePrompt(false);
                onNavigateToSecondIntake?.();
              }}
              className="gap-2"
            >
              <Clipboard className="w-4 h-4" />
              {t('intake.prompt.completeIntake')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Header */}
      <div className="bg-gradient-to-r from-blue-700 to-indigo-800 text-primary-foreground p-4">
        <div className={`flex items-center gap-3 mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={() => onNavigate('home')}
            className="text-primary-foreground hover:bg-primary-foreground/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('workouts.title')}</h1>
            <p className="text-primary-foreground/80">
              {t('workouts.week')} {workout.week}, {t('workouts.day')} {workout.day}
              {workoutStartTime && (
                <span className="ml-2">• {getWorkoutDuration()}</span>
              )}
            </p>
          </div>
          <div className="flex items-center gap-2">
            {totalCaloriesBurned > 0 && (
              <Badge variant="secondary" className="bg-orange-100 text-orange-800">
                🔥 {totalCaloriesBurned} cal
              </Badge>
            )}
            <Badge variant="secondary" className="bg-primary-foreground/20 text-primary-foreground">
              <Calendar className="w-3 h-3 mr-1" />
              {t('common.today')}
            </Badge>
          </div>
        </div>
        <Progress value={progress} className="bg-primary-foreground/20" />
        <p className="text-sm text-primary-foreground/80 mt-2">
          {completedExercises} {t('onboarding.step')} {workout.exercises.length} {t('workouts.exercises')} {t('workouts.complete')}
        </p>
      </div>

      <div className="p-4 space-y-4">
        {/* Second Intake Progress Banner */}
        {!userProfile.hasCompletedSecondIntake && (
          <Card className="border-blue-200 bg-gradient-to-r from-blue-50 to-purple-50">
            <CardContent className="p-4">
              <div className={`space-y-3 ${isRTL ? 'text-right' : ''}`}>
                <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="flex-1">
                    <h3 className="font-semibold text-blue-900 mb-1">
                      {t('intake.banner.title')}
                    </h3>
                    <p className="text-sm text-blue-700">
                      {t('intake.banner.description')}
                    </p>
                  </div>
                  <Info className="w-5 h-5 text-blue-600 flex-shrink-0 ml-3" />
                </div>
                
                {/* Progress Indicator */}
                <div className="space-y-2">
                  <div className={`flex items-center justify-between text-xs text-blue-700 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <span>{t('intake.banner.profileProgress')}</span>
                    <span>30%</span>
                  </div>
                  <Progress value={30} className="h-2 bg-blue-200" />
                  <p className="text-xs text-blue-600">
                    {t('intake.banner.benefitsText')}
                  </p>
                </div>

                {/* Action Buttons */}
                <div className={`flex gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <Button
                    size="sm"
                    onClick={() => onNavigateToSecondIntake?.()}
                    className="flex-1 bg-blue-600 hover:bg-blue-700 gap-2"
                  >
                    <Clipboard className="w-4 h-4" />
                    {t('intake.banner.completeNow')}
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => onNavigate('coach')}
                    className="flex-1 border-purple-300 text-purple-700 hover:bg-purple-50 gap-2"
                  >
                    <Video className="w-4 h-4" />
                    {t('intake.banner.bookCall')}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Workout Overview */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>{workout.name}</CardTitle>
              <Badge variant="outline">{workout.difficulty}</Badge>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <Target className="w-5 h-5 mx-auto mb-1 text-muted-foreground" />
                <div className="text-sm font-medium">{workout.exercises.length}</div>
                <div className="text-xs text-muted-foreground">{t('workouts.exercises')}</div>
              </div>
              <div>
                <Clock className="w-5 h-5 mx-auto mb-1 text-muted-foreground" />
                <div className="text-sm font-medium">{workout.duration}</div>
                <div className="text-xs text-muted-foreground">{t('workouts.duration')}</div>
              </div>
              <div>
                <CheckCircle className="w-5 h-5 mx-auto mb-1 text-muted-foreground" />
                <div className="text-sm font-medium">{Math.round(progress)}%</div>
                <div className="text-xs text-muted-foreground">{t('workouts.complete')}</div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Exercise List */}
        <div className="space-y-3">
          {workout.exercises.map((exercise, index) => (
            <Card 
              key={exercise.id}
              className={`transition-all cursor-pointer hover:shadow-md ${
                exercise.completed ? 'bg-green-50 border-green-200' : ''
              }`}
              onClick={() => viewExerciseDetails(index)}
            >
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-medium">{exercise.name}</h3>
                      {exercise.isSwapped && (
                        <Badge variant="outline" className="text-xs">
                          <RefreshCw className="w-3 h-3 mr-1" />
                          {t('workouts.swapped')}
                        </Badge>
                      )}
                      {exercise.completed && (
                        <CheckCircle className="w-4 h-4 text-green-600" />
                      )}
                    </div>
                    <div className="flex items-center gap-4 text-sm text-muted-foreground">
                      <span>{exercise.sets} {t('workouts.sets')}</span>
                      <span>•</span>
                      <span>{exercise.reps} {t('workouts.reps')}</span>
                      <span>•</span>
                      <span>{exercise.muscleGroup}</span>
                    </div>
                    {exercise.loggedSets.length > 0 && (
                      <div className="text-xs text-muted-foreground mt-1">
                        {exercise.loggedSets.length} {t('onboarding.step')} {exercise.sets} {t('workouts.sets')} {t('workouts.logged')}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={(e) => {
                        e.stopPropagation();
                        viewExerciseDetails(index);
                      }}
                      className="h-8 w-8"
                    >
                      <Eye className="w-4 h-4" />
                    </Button>
                    <Button
                      variant={exercise.completed ? 'default' : 'secondary'}
                      size="sm"
                      onClick={(e) => {
                        e.stopPropagation();
                        startExercise(index);
                      }}
                    >
                      {exercise.completed ? t('workouts.review') : t('workouts.start')}
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3 pt-4">
          <Button variant="outline" className="flex-1">
            {t('workouts.previousWorkout')}
          </Button>
          <Button 
            className="flex-1"
            disabled={progress === 100}
          >
            {progress === 100 ? t('workouts.completed') : t('workouts.continueWorkout')}
          </Button>
        </div>
      </div>

      {/* v2.0: Injury Report Dialog */}
      <Dialog open={showInjuryDialog} onOpenChange={setShowInjuryDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('workouts.injuryDialog.title')}</DialogTitle>
            <DialogDescription>
              {t('workouts.injuryDialog.description')}
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium mb-2 block">{t('workouts.injuryDialog.selectArea')}</label>
              <div className="grid grid-cols-2 gap-2">
                {injuryAreas.map(area => (
                  <Button
                    key={area}
                    variant={selectedInjury === area ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setSelectedInjury(area)}
                  >
                    {t(`injuries.${area}`)}
                  </Button>
                ))}
              </div>
            </div>
            
            <Alert>
              <Info className="w-4 h-4" />
              <AlertDescription>
                {t('workouts.injuryDialog.impactNotice')}
              </AlertDescription>
            </Alert>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowInjuryDialog(false)}>
              {t('common.cancel')}
            </Button>
            <Button onClick={handleReportInjury} disabled={!selectedInjury}>
              {t('workouts.findAlternative')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* v2.0: Alternative Exercises Dialog */}
      <Dialog open={showAlternativesDialog} onOpenChange={setShowAlternativesDialog}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{t('workouts.alternatives.title')}</DialogTitle>
            <DialogDescription>
              {t('workouts.alternatives.description', { injury: selectedInjury ? t(`injuries.${selectedInjury}`) : '' })}
            </DialogDescription>
          </DialogHeader>
          
          <ScrollArea className="max-h-96">
            <div className="space-y-3">
              {alternativeExercises.map(alt => (
                <Card key={alt.id}>
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="font-medium mb-1">{alt.name}</h4>
                        <p className="text-sm text-muted-foreground mb-2">
                          {alt.muscleGroup}
                        </p>
                        <div className="flex flex-wrap gap-2">
                          <Badge variant="outline">
                            {alt.defaultSets} sets × {alt.defaultReps} reps
                          </Badge>
                          <Badge variant="secondary" className="bg-green-100 text-green-800">
                            {t('workouts.safeFor')} {selectedInjury && t(`injuries.${selectedInjury}`)}
                          </Badge>
                        </div>
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
              
              {alternativeExercises.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  <AlertTriangle className="w-12 h-12 mx-auto mb-2 opacity-50" />
                  <p>{t('workouts.noAlternativesFound')}</p>
                </div>
              )}
            </div>
          </ScrollArea>
        </DialogContent>
      </Dialog>
      </div>
    </div>
  );
}