import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Checkbox } from './ui/checkbox';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { 
  ArrowLeft, 
  ArrowRight,
  CheckCircle,
  ChefHat,
  Clock,
  Flame,
  Heart,
  Utensils
} from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface NutritionPreferencesIntakeProps {
  onComplete: (preferences: NutritionPreferences) => void;
  onBack: () => void;
  onLogout?: () => void;
}

export interface NutritionPreferences {
  proteinSources: string[];
  proteinAllergies: string[];
  dinnerPreferences: {
    portionSize: 'light' | 'moderate' | 'filling';
    prepSpeed: 'quick' | 'normal' | 'prep_ahead';
    carbLevel: 'no_carb' | 'low_carb' | 'includes_carbs';
    temperature: 'hot' | 'cold' | 'both';
    cuisines: string[];
    avoid: string[];
  };
  additionalNotes: string;
}

export function NutritionPreferencesIntake({ onComplete, onBack, onLogout }: NutritionPreferencesIntakeProps) {
  const { t, isRTL } = useLanguage();
  const [currentStep, setCurrentStep] = useState(1);
  const totalSteps = 3;

  const [preferences, setPreferences] = useState<NutritionPreferences>({
    proteinSources: [],
    proteinAllergies: [],
    dinnerPreferences: {
      portionSize: 'moderate',
      prepSpeed: 'normal',
      carbLevel: 'includes_carbs',
      temperature: 'both',
      cuisines: [],
      avoid: []
    },
    additionalNotes: ''
  });

  const proteinOptions = [
    { id: 'chicken', name: t('foods.chicken'), icon: '🐔' },
    { id: 'red_meat', name: t('foods.beef'), icon: '🥩' },
    { id: 'tuna', name: t('foods.tuna'), icon: '🐟' },
    { id: 'shrimp', name: t('foods.shrimp'), icon: '🦐' },
    { id: 'salmon', name: t('foods.salmon'), icon: '🐟' },
    { id: 'eggs', name: t('foods.eggs'), icon: '🥚' },
    { id: 'beans', name: t('foods.beans'), icon: '🫘' },
    { id: 'tofu', name: t('foods.tofu'), icon: '🥜' },
  ];

  const cuisineOptions = [
    { id: 'egyptian', name: t('cuisines.egyptian'), icon: '🇪🇬' },
    { id: 'arabic', name: t('cuisines.middle_eastern'), icon: '🥙' },
    { id: 'mediterranean', name: t('cuisines.mediterranean'), icon: '🫒' },
    { id: 'asian', name: t('cuisines.asian'), icon: '🍜' },
    { id: 'western', name: t('cuisines.american'), icon: '🍽️' },
    { id: 'indian', name: t('cuisines.indian'), icon: '🍛' },
  ];

  const avoidOptions = [
    { id: 'spicy', name: t('foods.spicy'), icon: '🌶️' },
    { id: 'fried', name: t('foods.fried'), icon: '🍟' },
    { id: 'dairy', name: t('foods.dairy'), icon: '🥛' },
    { id: 'gluten', name: t('foods.gluten'), icon: '🌾' },
    { id: 'seafood', name: t('foods.seafood'), icon: '🐟' },
    { id: 'nuts', name: t('foods.nuts'), icon: '🥜' },
    { id: 'shellfish', name: t('foods.shellfish'), icon: '🦐' },
  ];

  const handleProteinToggle = (proteinId: string, isAllergy: boolean = false) => {
    const key = isAllergy ? 'proteinAllergies' : 'proteinSources';
    const current = preferences[key];
    
    setPreferences(prev => ({
      ...prev,
      [key]: current.includes(proteinId)
        ? current.filter(id => id !== proteinId)
        : [...current, proteinId]
    }));
  };

  const handleDinnerPreferenceChange = (key: string, value: any) => {
    setPreferences(prev => ({
      ...prev,
      dinnerPreferences: {
        ...prev.dinnerPreferences,
        [key]: value
      }
    }));
  };

  const handleArrayToggle = (key: 'cuisines' | 'avoid', value: string) => {
    const current = preferences.dinnerPreferences[key];
    handleDinnerPreferenceChange(key, 
      current.includes(value)
        ? current.filter(item => item !== value)
        : [...current, value]
    );
  };

  const nextStep = () => {
    if (currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
    } else {
      onComplete(preferences);
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    } else {
      onBack();
    }
  };

  const canProceed = () => {
    switch (currentStep) {
      case 1:
        return preferences.proteinSources.length > 0;
      case 2:
        return preferences.dinnerPreferences.cuisines.length > 0;
      case 3:
        return true;
      default:
        return false;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-green-600 text-white p-4">
        <div className={`flex items-center gap-3 mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={prevStep}
            onDoubleClick={onLogout}
            className="text-white hover:bg-white/20"
            title={currentStep === 1 ? 'Double-tap to logout' : 'Back'}
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('nutritionPrefs.title')}</h1>
            <p className="text-white/80">{t('nutritionPrefs.step')} {currentStep} {t('onboarding.step')} {totalSteps}</p>
          </div>
          <ChefHat className="w-6 h-6" />
        </div>
        
        {/* Progress Bar */}
        <div className="w-full bg-white/20 rounded-full h-2">
          <div 
            className="bg-white h-2 rounded-full transition-all duration-300"
            style={{ width: `${(currentStep / totalSteps) * 100}%` }}
          />
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Step 1: Protein Preferences */}
        {currentStep === 1 && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Heart className="w-5 h-5 text-red-500" />
                  {t('nutritionPrefs.protein.title')}
                </CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.protein.subtitle')}
                </p>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-3">
                  {proteinOptions.map((protein) => (
                    <div
                      key={protein.id}
                      className={`p-3 border rounded-lg cursor-pointer transition-all ${
                        preferences.proteinSources.includes(protein.id)
                          ? 'border-green-500 bg-green-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => handleProteinToggle(protein.id)}
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{protein.icon}</span>
                        <span className="text-sm">{protein.name}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Badge variant="destructive" className="w-fit">!</Badge>
                  {t('nutritionPrefs.allergies.title')}
                </CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.allergies.subtitle')}
                </p>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-3">
                  {proteinOptions.map((protein) => (
                    <div
                      key={protein.id}
                      className={`p-3 border rounded-lg cursor-pointer transition-all ${
                        preferences.proteinAllergies.includes(protein.id)
                          ? 'border-red-500 bg-red-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => handleProteinToggle(protein.id, true)}
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{protein.icon}</span>
                        <span className="text-sm">{protein.name}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Step 2: Dinner Preferences */}
        {currentStep === 2 && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Utensils className="w-5 h-5 text-orange-500" />
                  {t('nutritionPrefs.dinner.title')}
                </CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.dinner.subtitle')}
                </p>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Portion Size */}
                <div>
                  <Label className="text-sm font-medium">{t('nutritionPrefs.portionSize')}</Label>
                  <RadioGroup 
                    value={preferences.dinnerPreferences.portionSize}
                    onValueChange={(value) => handleDinnerPreferenceChange('portionSize', value)}
                    className="mt-2"
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="light" id="light" />
                      <Label htmlFor="light">{t('nutritionPrefs.portionSize.light')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="moderate" id="moderate" />
                      <Label htmlFor="moderate">{t('nutritionPrefs.portionSize.moderate')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="filling" id="filling" />
                      <Label htmlFor="filling">{t('nutritionPrefs.portionSize.filling')}</Label>
                    </div>
                  </RadioGroup>
                </div>

                {/* Prep Speed */}
                <div>
                  <Label className="text-sm font-medium flex items-center gap-2">
                    <Clock className="w-4 h-4" />
                    {t('nutritionPrefs.prepTime')}
                  </Label>
                  <RadioGroup 
                    value={preferences.dinnerPreferences.prepSpeed}
                    onValueChange={(value) => handleDinnerPreferenceChange('prepSpeed', value)}
                    className="mt-2"
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="quick" id="quick" />
                      <Label htmlFor="quick">{t('nutritionPrefs.prepTime.quick')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="normal" id="normal" />
                      <Label htmlFor="normal">{t('nutritionPrefs.prepTime.normal')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="prep_ahead" id="prep_ahead" />
                      <Label htmlFor="prep_ahead">{t('nutritionPrefs.prepTime.prepAhead')}</Label>
                    </div>
                  </RadioGroup>
                </div>

                {/* Carb Level */}
                <div>
                  <Label className="text-sm font-medium">{t('nutritionPrefs.carbs')}</Label>
                  <RadioGroup 
                    value={preferences.dinnerPreferences.carbLevel}
                    onValueChange={(value) => handleDinnerPreferenceChange('carbLevel', value)}
                    className="mt-2"
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="no_carb" id="no_carb" />
                      <Label htmlFor="no_carb">{t('nutritionPrefs.carbs.noCarb')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="low_carb" id="low_carb" />
                      <Label htmlFor="low_carb">{t('nutritionPrefs.carbs.lowCarb')}</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="includes_carbs" id="includes_carbs" />
                      <Label htmlFor="includes_carbs">{t('nutritionPrefs.carbs.includesCarbs')}</Label>
                    </div>
                  </RadioGroup>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('nutritionPrefs.cuisines')}</CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.cuisines.subtitle')}
                </p>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-3">
                  {cuisineOptions.map((cuisine) => (
                    <div
                      key={cuisine.id}
                      className={`p-3 border rounded-lg cursor-pointer transition-all ${
                        preferences.dinnerPreferences.cuisines.includes(cuisine.id)
                          ? 'border-blue-500 bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => handleArrayToggle('cuisines', cuisine.id)}
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{cuisine.icon}</span>
                        <span className="text-sm">{cuisine.name}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Step 3: Restrictions & Notes */}
        {currentStep === 3 && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Badge variant="secondary">⚠️</Badge>
                  {t('nutritionPrefs.avoid.title')}
                </CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.avoid.subtitle')}
                </p>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-3">
                  {avoidOptions.map((item) => (
                    <div
                      key={item.id}
                      className={`p-3 border rounded-lg cursor-pointer transition-all ${
                        preferences.dinnerPreferences.avoid.includes(item.id)
                          ? 'border-red-500 bg-red-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => handleArrayToggle('avoid', item.id)}
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{item.icon}</span>
                        <span className="text-sm">{item.name}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('nutritionPrefs.notes.title')}</CardTitle>
                <p className="text-sm text-muted-foreground">
                  {t('nutritionPrefs.notes.subtitle')}
                </p>
              </CardHeader>
              <CardContent>
                <Textarea
                  placeholder={t('nutritionPrefs.notes.placeholder')}
                  value={preferences.additionalNotes}
                  onChange={(e) => setPreferences(prev => ({
                    ...prev,
                    additionalNotes: e.target.value
                  }))}
                  className="min-h-[100px]"
                />
              </CardContent>
            </Card>

            <Card className="bg-green-50 border-green-200">
              <CardContent className="p-4">
                <div className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-600 mt-0.5" />
                  <div>
                    <h4 className="text-green-900 font-medium">{t('nutritionPrefs.complete')}</h4>
                    <p className="text-sm text-green-700 mt-1">
                      {t('nutritionPrefs.completeDesc')}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Navigation Buttons */}
        <div className="flex gap-3 pt-4 border-t">
          <Button variant="outline" onClick={prevStep} className="flex-1">
            <ArrowLeft className="w-4 h-4 mr-2" />
            {currentStep === 1 ? t('common.back') : t('nutritionPrefs.previous')}
          </Button>
          <Button 
            onClick={nextStep} 
            className="flex-1"
            disabled={!canProceed()}
          >
            {currentStep === totalSteps ? t('nutritionPrefs.completeSetup') : t('common.next')}
            <ArrowRight className="w-4 h-4 ml-2" />
          </Button>
        </div>
      </div>
    </div>
  );
}