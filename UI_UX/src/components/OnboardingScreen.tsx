import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Checkbox } from './ui/checkbox';
import { Progress } from './ui/progress';
import { ArrowLeft, ArrowRight, User, Scale, Ruler, Calendar, MapPin, Target, Dumbbell, AlertTriangle, CheckCircle } from 'lucide-react';
import { UserProfile, MainGoal, InjuryArea } from '../App';
import { useLanguage } from './LanguageContext';

interface OnboardingScreenProps {
  onComplete: (profile: UserProfile) => void;
  onBack?: () => void;
  isDemoMode: boolean;
}

interface OnboardingData {
  name: string;
  age: string;
  weight: string;
  height: string;
  gender: 'male' | 'female' | 'other';
  mainGoal: MainGoal;
  workoutFrequency: string;
  workoutLocation: 'home' | 'gym';
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
  injuries: InjuryArea[];
}

export function OnboardingScreen({ onComplete, onBack, isDemoMode }: OnboardingScreenProps) {
  const { t, isRTL } = useLanguage();
  const [currentStep, setCurrentStep] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [data, setData] = useState<OnboardingData>({
    name: isDemoMode ? 'Mina H.' : '',
    age: isDemoMode ? '28' : '',
    weight: isDemoMode ? '78' : '',
    height: isDemoMode ? '178' : '',
    gender: isDemoMode ? 'male' : 'male',
    mainGoal: isDemoMode ? 'muscle_gain' : 'general_fitness',
    workoutFrequency: isDemoMode ? '4' : '',
    workoutLocation: isDemoMode ? 'gym' : 'home',
    experienceLevel: isDemoMode ? 'intermediate' : 'beginner',
    injuries: isDemoMode ? ['lower_back'] : [],
  });

  const totalSteps = 8;
  const progress = ((currentStep + 1) / totalSteps) * 100;

  const handleNext = () => {
    if (currentStep < totalSteps - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      handleComplete();
    }
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    } else if (onBack) {
      // Allow going back to previous screen (auth) from first step
      onBack();
    }
  };

  const handleComplete = async () => {
    setIsLoading(true);
    
    // Simulate API call for plan generation
    await new Promise(resolve => setTimeout(resolve, 3000));

    const profile: UserProfile = {
      id: isDemoMode ? 'demo_user_1' : `user_${Date.now()}`,
      name: data.name,
      email: isDemoMode ? 'mina.h@demo.com' : 'user@example.com',
      age: parseInt(data.age),
      weight: parseFloat(data.weight),
      height: parseFloat(data.height),
      gender: data.gender,
      mainGoal: data.mainGoal,
      workoutFrequency: parseInt(data.workoutFrequency),
      workoutLocation: data.workoutLocation,
      experienceLevel: data.experienceLevel,
      injuries: data.injuries,
      subscriptionTier: isDemoMode ? 'Smart Premium' : 'Freemium',
      coachId: isDemoMode ? 'coach_sara' : undefined,
    };

    onComplete(profile);
    setIsLoading(false);
  };

  const updateData = (field: keyof OnboardingData, value: string) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

  const toggleInjury = (injury: InjuryArea) => {
    setData(prev => ({
      ...prev,
      injuries: prev.injuries.includes(injury)
        ? prev.injuries.filter(i => i !== injury)
        : [...prev.injuries, injury]
    }));
  };

  const isStepValid = () => {
    switch (currentStep) {
      case 0: return data.name.trim().length > 0;
      case 1: return data.age && parseInt(data.age) > 0 && parseInt(data.age) < 120;
      case 2: return data.weight && parseFloat(data.weight) > 0;
      case 3: return data.height && parseFloat(data.height) > 0;
      case 4: return true; // Main goal always has a default
      case 5: return data.workoutFrequency && parseInt(data.workoutFrequency) >= 2 && parseInt(data.workoutFrequency) <= 6;
      case 6: return true; // Experience level always has a default
      case 7: return true; // Injuries is optional
      default: return false;
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardContent className="p-8 text-center space-y-6">
            <div className="w-16 h-16 mx-auto bg-primary rounded-full flex items-center justify-center">
              <Dumbbell className="w-8 h-8 text-primary-foreground animate-pulse" />
            </div>
            <div className="space-y-2">
              <h3>{t('onboarding.creating')}</h3>
              <p className="text-muted-foreground">
                {t('onboarding.analyzing')}
              </p>
            </div>
            <Progress value={75} className="w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  const renderStep = () => {
    switch (currentStep) {
      case 0:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <User className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.name.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.name.subtitle')}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="name">{t('auth.fullName')}</Label>
              <Input
                id="name"
                placeholder={t('auth.fullName')}
                value={data.name}
                onChange={(e) => updateData('name', e.target.value)}
                dir={isRTL ? 'rtl' : 'ltr'}
              />
            </div>
          </div>
        );

      case 1:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Calendar className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.age.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.age.subtitle')}</p>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="age">{t('onboarding.age.label')}</Label>
                <Input
                  id="age"
                  type="number"
                  placeholder={t('onboarding.age.label')}
                  value={data.age}
                  onChange={(e) => updateData('age', e.target.value)}
                  min="13"
                  max="120"
                />
              </div>
              <div className="space-y-2">
                <Label>{t('onboarding.gender.label')}</Label>
                <RadioGroup 
                  value={data.gender} 
                  onValueChange={(value) => updateData('gender', value)}
                >
                  <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <RadioGroupItem value="male" id="male" />
                    <Label htmlFor="male">{t('onboarding.gender.male')}</Label>
                  </div>
                  <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <RadioGroupItem value="female" id="female" />
                    <Label htmlFor="female">{t('onboarding.gender.female')}</Label>
                  </div>
                  <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <RadioGroupItem value="other" id="other" />
                    <Label htmlFor="other">{t('onboarding.gender.other')}</Label>
                  </div>
                </RadioGroup>
              </div>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Scale className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.weight.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.weight.subtitle')}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="weight">{t('onboarding.weight.label')}</Label>
              <Input
                id="weight"
                type="number"
                placeholder={t('onboarding.weight.label')}
                value={data.weight}
                onChange={(e) => updateData('weight', e.target.value)}
                min="30"
                max="300"
                step="0.1"
              />
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Ruler className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.height.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.height.subtitle')}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="height">{t('onboarding.height.label')}</Label>
              <Input
                id="height"
                type="number"
                placeholder={t('onboarding.height.label')}
                value={data.height}
                onChange={(e) => updateData('height', e.target.value)}
                min="100"
                max="250"
              />
            </div>
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Target className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.goals.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.goals.subtitle')}</p>
            </div>
            <div className="space-y-2">
              <RadioGroup 
                value={data.mainGoal} 
                onValueChange={(value) => updateData('mainGoal', value as MainGoal)}
              >
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="fat_loss" id="fat_loss" />
                  <Label htmlFor="fat_loss">{t('onboarding.goals.fatLoss')}</Label>
                </div>
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="muscle_gain" id="muscle_gain" />
                  <Label htmlFor="muscle_gain">{t('onboarding.goals.muscleGain')}</Label>
                </div>
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="general_fitness" id="general_fitness" />
                  <Label htmlFor="general_fitness">{t('onboarding.goals.generalFitness')}</Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      case 5:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <MapPin className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.workout.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.workout.subtitle')}</p>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="frequency">{t('onboarding.workout.frequency')}</Label>
                <Select value={data.workoutFrequency} onValueChange={(value) => updateData('workoutFrequency', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder={t('onboarding.workout.frequency')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="2">{t('onboarding.workout.2days')}</SelectItem>
                    <SelectItem value="3">{t('onboarding.workout.3days')}</SelectItem>
                    <SelectItem value="4">{t('onboarding.workout.4days')}</SelectItem>
                    <SelectItem value="5">{t('onboarding.workout.5days')}</SelectItem>
                    <SelectItem value="6">{t('onboarding.workout.6days')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t('onboarding.workout.location')}</Label>
                <RadioGroup 
                  value={data.workoutLocation} 
                  onValueChange={(value) => updateData('workoutLocation', value as 'home' | 'gym')}
                >
                  <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <RadioGroupItem value="home" id="home" />
                    <Label htmlFor="home">{t('onboarding.workout.home')}</Label>
                  </div>
                  <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <RadioGroupItem value="gym" id="gym" />
                    <Label htmlFor="gym">{t('onboarding.workout.gym')}</Label>
                  </div>
                </RadioGroup>
              </div>
            </div>
          </div>
        );

      case 6:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Dumbbell className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.experience.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.experience.subtitle')}</p>
            </div>
            <div className="space-y-2">
              <Label>{t('onboarding.experience.label')}</Label>
              <RadioGroup 
                value={data.experienceLevel} 
                onValueChange={(value) => updateData('experienceLevel', value as 'beginner' | 'intermediate' | 'advanced')}
              >
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="beginner" id="beginner" />
                  <Label htmlFor="beginner">{t('onboarding.experience.beginner')}</Label>
                </div>
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="intermediate" id="intermediate" />
                  <Label htmlFor="intermediate">{t('onboarding.experience.intermediate')}</Label>
                </div>
                <div className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="advanced" id="advanced" />
                  <Label htmlFor="advanced">{t('onboarding.experience.advanced')}</Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      case 7:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <AlertTriangle className="w-16 h-16 mx-auto text-orange-500" />
              <h2>{t('onboarding.injuries.title')}</h2>
              <p className="text-muted-foreground">{t('onboarding.injuries.subtitle')}</p>
            </div>
            <div className="space-y-4">
              <Label>{t('onboarding.injuries.label')}</Label>
              <div className="space-y-3">
                {[
                  { key: 'shoulder' as InjuryArea, label: t('onboarding.injuries.shoulder') },
                  { key: 'knee' as InjuryArea, label: t('onboarding.injuries.knee') },
                  { key: 'lower_back' as InjuryArea, label: t('onboarding.injuries.lowerBack') },
                  { key: 'neck' as InjuryArea, label: t('onboarding.injuries.neck') },
                  { key: 'ankle' as InjuryArea, label: t('onboarding.injuries.ankle') },
                ].map((injury) => (
                  <div key={injury.key} className={`flex items-center space-x-2 ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                    <Checkbox
                      id={injury.key}
                      checked={data.injuries.includes(injury.key)}
                      onCheckedChange={() => toggleInjury(injury.key)}
                    />
                    <Label htmlFor={injury.key}>{injury.label}</Label>
                  </div>
                ))}
              </div>
              {data.injuries.length === 0 && (
                <div className={`flex items-center space-x-2 p-3 bg-green-50 border border-green-200 rounded-lg ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <CheckCircle className="w-4 h-4 text-green-600" />
                  <span className="text-sm text-green-700">{t('onboarding.injuries.none')}</span>
                </div>  
              )}
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
            <CardTitle>{t('onboarding.gettingStarted')}</CardTitle>
            <span className="text-sm text-muted-foreground">
              {currentStep + 1} {t('onboarding.step')} {totalSteps}
            </span>
          </div>
          <Progress value={progress} className="w-full" />
        </CardHeader>
        <CardContent className="space-y-6">
          {renderStep()}
          
          <div className={`flex gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
            {(currentStep > 0 || onBack) && (
              <Button 
                variant="outline" 
                onClick={handleBack}
                className="flex-1"
                title={currentStep === 0 && onBack ? 'Return to login' : ''}
              >
                {isRTL ? <ArrowRight className="w-4 h-4 mr-2" /> : <ArrowLeft className="w-4 h-4 mr-2" />}
                {t('onboarding.back')}
              </Button>
            )}
            <Button 
              onClick={handleNext}
              disabled={!isStepValid()}
              className="flex-1"
            >
              {currentStep === totalSteps - 1 ? t('onboarding.completeSetup') : t('onboarding.continue')}
              {currentStep < totalSteps - 1 && (isRTL ? <ArrowLeft className="w-4 h-4 ml-2" /> : <ArrowRight className="w-4 h-4 ml-2" />)}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}