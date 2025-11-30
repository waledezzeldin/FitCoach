import React, { useState } from 'react';
import { Button } from './ui/button';
import { Label } from './ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Progress } from './ui/progress';
import { ArrowLeft, ArrowRight, Target, MapPin, Users, Sparkles } from 'lucide-react';
import { FirstIntakeData, MainGoal, WorkoutLocation, Gender, validateFirstIntake } from '../types/IntakeTypes';
import { useLanguage } from './LanguageContext';

interface FirstIntakeScreenProps {
  onComplete: (data: FirstIntakeData) => void;
  onBack?: () => void;
  isDemoMode: boolean;
}

export function FirstIntakeScreen({ onComplete, onBack, isDemoMode }: FirstIntakeScreenProps) {
  const { t, isRTL } = useLanguage();
  const [currentStep, setCurrentStep] = useState(0);
  const [data, setData] = useState<Partial<FirstIntakeData>>({
    gender: isDemoMode ? 'male' : undefined,
    mainGoal: isDemoMode ? 'muscle_gain' : undefined,
    workoutLocation: isDemoMode ? 'gym' : undefined,
  });

  const totalSteps = 3;
  const progress = ((currentStep + 1) / totalSteps) * 100;

  const updateData = <K extends keyof FirstIntakeData>(field: K, value: FirstIntakeData[K]) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

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
      onBack();
    }
  };

  const handleComplete = () => {
    const validation = validateFirstIntake(data);
    
    if (validation.isValid && data.gender && data.mainGoal && data.workoutLocation) {
      const completeData: FirstIntakeData = {
        gender: data.gender,
        mainGoal: data.mainGoal,
        workoutLocation: data.workoutLocation,
        completedAt: new Date()
      };
      onComplete(completeData);
    }
  };

  const isStepValid = () => {
    switch (currentStep) {
      case 0: return !!data.gender;
      case 1: return !!data.mainGoal;
      case 2: return !!data.workoutLocation;
      default: return false;
    }
  };

  const renderStep = () => {
    switch (currentStep) {
      case 0:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Users className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.gender.title')}</h2>
              <p className="text-muted-foreground">{t('intake.first.genderDesc')}</p>
            </div>
            <div className="space-y-3">
              <RadioGroup 
                value={data.gender} 
                onValueChange={(value) => updateData('gender', value as Gender)}
              >
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.gender === 'male' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="male" id="male" />
                  <Label htmlFor="male" className="flex-1 cursor-pointer">{t('onboarding.gender.male')}</Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.gender === 'female' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="female" id="female" />
                  <Label htmlFor="female" className="flex-1 cursor-pointer">{t('onboarding.gender.female')}</Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.gender === 'other' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="other" id="other" />
                  <Label htmlFor="other" className="flex-1 cursor-pointer">{t('onboarding.gender.other')}</Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      case 1:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Target className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.goals.title')}</h2>
              <p className="text-muted-foreground">{t('intake.first.goalDesc')}</p>
            </div>
            <div className="space-y-3">
              <RadioGroup 
                value={data.mainGoal} 
                onValueChange={(value) => updateData('mainGoal', value as MainGoal)}
              >
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.mainGoal === 'fat_loss' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="fat_loss" id="fat_loss" />
                  <Label htmlFor="fat_loss" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.goals.fatLoss')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.first.fatLossDesc')}</div>
                    </div>
                  </Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.mainGoal === 'muscle_gain' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="muscle_gain" id="muscle_gain" />
                  <Label htmlFor="muscle_gain" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.goals.muscleGain')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.first.muscleGainDesc')}</div>
                    </div>
                  </Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.mainGoal === 'general_fitness' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="general_fitness" id="general_fitness" />
                  <Label htmlFor="general_fitness" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.goals.generalFitness')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.first.fitnessDesc')}</div>
                    </div>
                  </Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <MapPin className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.workout.location')}</h2>
              <p className="text-muted-foreground">{t('intake.first.locationDesc')}</p>
            </div>
            <div className="space-y-3">
              <RadioGroup 
                value={data.workoutLocation} 
                onValueChange={(value) => updateData('workoutLocation', value as WorkoutLocation)}
              >
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.workoutLocation === 'gym' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="gym" id="gym" />
                  <Label htmlFor="gym" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.workout.gym')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.first.gymDesc')}</div>
                    </div>
                  </Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.workoutLocation === 'home' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="home" id="home" />
                  <Label htmlFor="home" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.workout.home')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.first.homeDesc')}</div>
                    </div>
                  </Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1647213053074-a00c7b885ebf?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.4
        }}
      />
      
      <Card className="w-full max-w-md relative z-10">
        <CardHeader className="space-y-1">
          <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
            <CardTitle className="flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-primary" />
              {t('intake.first.title')}
            </CardTitle>
            <span className="text-sm text-muted-foreground">
              {currentStep + 1}/{totalSteps}
            </span>
          </div>
          <CardDescription>{t('intake.first.subtitle')}</CardDescription>
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
              {currentStep === totalSteps - 1 ? (
                <>
                  {t('intake.first.complete')}
                  <Sparkles className="w-4 h-4 ml-2" />
                </>
              ) : (
                <>
                  {t('onboarding.continue')}
                  {isRTL ? <ArrowLeft className="w-4 h-4 ml-2" /> : <ArrowRight className="w-4 h-4 ml-2" />}
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}