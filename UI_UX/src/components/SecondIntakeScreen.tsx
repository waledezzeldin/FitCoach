import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Checkbox } from './ui/checkbox';
import { Progress } from './ui/progress';
import { ArrowLeft, ArrowRight, Calendar, Scale, Ruler, Dumbbell, AlertTriangle, Sparkles, CheckCircle } from 'lucide-react';
import { SecondIntakeData, InjuryArea, ExperienceLevel, validateSecondIntake } from '../types/IntakeTypes';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface SecondIntakeScreenProps {
  onComplete: (data: SecondIntakeData) => void;
  onBack?: () => void;
  isDemoMode: boolean;
}

export function SecondIntakeScreen({ onComplete, onBack, isDemoMode }: SecondIntakeScreenProps) {
  const { t, isRTL } = useLanguage();
  const [currentStep, setCurrentStep] = useState(0);
  const [data, setData] = useState<Partial<SecondIntakeData>>({
    age: isDemoMode ? 28 : undefined,
    weight: isDemoMode ? 78 : undefined,
    height: isDemoMode ? 178 : undefined,
    experienceLevel: isDemoMode ? 'intermediate' : undefined,
    workoutFrequency: isDemoMode ? 4 : undefined,
    injuries: isDemoMode ? ['lower_back'] : [],
  });

  const totalSteps = 5;
  const progress = ((currentStep + 1) / totalSteps) * 100;

  const updateData = <K extends keyof SecondIntakeData>(field: K, value: SecondIntakeData[K]) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

  const toggleInjury = (injury: InjuryArea) => {
    setData(prev => ({
      ...prev,
      injuries: prev.injuries?.includes(injury)
        ? prev.injuries.filter(i => i !== injury)
        : [...(prev.injuries || []), injury]
    }));
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
    const validation = validateSecondIntake(data);
    
    if (!validation.isValid) {
      // Show validation errors
      validation.errors.forEach(error => {
        toast.error(error);
      });
      return;
    }
    
    if (data.age && data.weight && data.height && data.experienceLevel && data.workoutFrequency) {
      const completeData: SecondIntakeData = {
        age: data.age,
        weight: data.weight,
        height: data.height,
        experienceLevel: data.experienceLevel,
        workoutFrequency: data.workoutFrequency,
        injuries: data.injuries || [],
        completedAt: new Date()
      };
      
      console.log('Second Intake Complete:', completeData);
      onComplete(completeData);
    } else {
      toast.error(t('intake.second.incomplete') || 'Please complete all required fields');
    }
  };

  const isStepValid = () => {
    switch (currentStep) {
      case 0: return !!data.age && data.age >= 13 && data.age <= 120;
      case 1: return !!data.weight && data.weight > 0 && !!data.height && data.height > 0;
      case 2: return !!data.experienceLevel;
      case 3: return !!data.workoutFrequency && data.workoutFrequency >= 2 && data.workoutFrequency <= 6;
      case 4: return true; // Injuries optional
      default: return false;
    }
  };

  const renderStep = () => {
    switch (currentStep) {
      case 0:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Calendar className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.age.title')}</h2>
              <p className="text-muted-foreground">{t('intake.second.ageDesc')}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="age">{t('onboarding.age.label')}</Label>
              <Input
                id="age"
                type="number"
                placeholder="28"
                value={data.age || ''}
                onChange={(e) => updateData('age', parseInt(e.target.value))}
                min="13"
                max="120"
              />
            </div>
          </div>
        );

      case 1:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Scale className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('intake.second.bodyMetrics')}</h2>
              <p className="text-muted-foreground">{t('intake.second.metricsDesc')}</p>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="weight">{t('onboarding.weight.label')}</Label>
                <Input
                  id="weight"
                  type="number"
                  placeholder="78"
                  value={data.weight || ''}
                  onChange={(e) => updateData('weight', parseFloat(e.target.value))}
                  min="30"
                  max="300"
                  step="0.1"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="height">{t('onboarding.height.label')}</Label>
                <Input
                  id="height"
                  type="number"
                  placeholder="178"
                  value={data.height || ''}
                  onChange={(e) => updateData('height', parseFloat(e.target.value))}
                  min="100"
                  max="250"
                />
              </div>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Dumbbell className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('onboarding.experience.title')}</h2>
              <p className="text-muted-foreground">{t('intake.second.experienceDesc')}</p>
            </div>
            <div className="space-y-3">
              <RadioGroup 
                value={data.experienceLevel} 
                onValueChange={(value) => updateData('experienceLevel', value as ExperienceLevel)}
              >
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.experienceLevel === 'beginner' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="beginner" id="beginner" />
                  <Label htmlFor="beginner" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.experience.beginner')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.second.beginnerDesc')}</div>
                    </div>
                  </Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.experienceLevel === 'intermediate' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="intermediate" id="intermediate" />
                  <Label htmlFor="intermediate" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.experience.intermediate')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.second.intermediateDesc')}</div>
                    </div>
                  </Label>
                </div>
                <div className={`flex items-center space-x-2 p-4 rounded-lg border cursor-pointer hover:bg-muted/50 ${data.experienceLevel === 'advanced' ? 'border-primary bg-primary/5' : ''} ${isRTL ? 'flex-row-reverse space-x-reverse' : ''}`}>
                  <RadioGroupItem value="advanced" id="advanced" />
                  <Label htmlFor="advanced" className="flex-1 cursor-pointer">
                    <div>
                      <div>{t('onboarding.experience.advanced')}</div>
                      <div className="text-xs text-muted-foreground">{t('intake.second.advancedDesc')}</div>
                    </div>
                  </Label>
                </div>
              </RadioGroup>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <Calendar className="w-16 h-16 mx-auto text-primary" />
              <h2>{t('intake.second.frequency')}</h2>
              <p className="text-muted-foreground">{t('intake.second.frequencyDesc')}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="frequency">{t('onboarding.workout.frequency')}</Label>
              <Select 
                value={data.workoutFrequency?.toString()} 
                onValueChange={(value) => updateData('workoutFrequency', parseInt(value))}
              >
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
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div className="text-center space-y-2">
              <AlertTriangle className="w-16 h-16 mx-auto text-orange-500" />
              <h2>{t('onboarding.injuries.title')}</h2>
              <p className="text-muted-foreground">{t('intake.second.injuriesDesc')}</p>
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
                      checked={data.injuries?.includes(injury.key)}
                      onCheckedChange={() => toggleInjury(injury.key)}
                    />
                    <Label htmlFor={injury.key} className="cursor-pointer">{injury.label}</Label>
                  </div>
                ))}
              </div>
              {(!data.injuries || data.injuries.length === 0) && (
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
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-100 p-4 flex items-center justify-center relative">
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
              <Sparkles className="w-5 h-5 text-purple-600" />
              {t('intake.second.title')}
            </CardTitle>
            <span className="text-sm text-muted-foreground">
              {currentStep + 1}/{totalSteps}
            </span>
          </div>
          <CardDescription>{t('intake.second.subtitle')}</CardDescription>
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
              className="flex-1 bg-purple-600 hover:bg-purple-700"
            >
              {currentStep === totalSteps - 1 ? (
                <>
                  {t('intake.second.complete')}
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