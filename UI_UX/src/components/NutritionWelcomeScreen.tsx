import React from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { ArrowLeft, ChefHat, Sparkles, Target, TrendingUp } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface NutritionWelcomeScreenProps {
  onStart: () => void;
  onBack: () => void;
}

export function NutritionWelcomeScreen({ onStart, onBack }: NutritionWelcomeScreenProps) {
  const { t, isRTL } = useLanguage();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-green-600 text-white p-4">
        <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className={`flex-1 ${isRTL ? 'text-right' : ''}`}>
            <h1 className="text-xl">{t('nutrition.title')}</h1>
            <p className="text-sm text-white/90">{t('nutrition.setup')}</p>
          </div>
          <ChefHat className="w-6 h-6" />
        </div>
      </div>

      {/* Welcome Content */}
      <div className="p-4 flex items-center justify-center min-h-[calc(100vh-80px)]">
        <Card className="w-full max-w-md">
          <CardContent className="p-8 space-y-6">
            {/* Icon */}
            <div className="w-20 h-20 mx-auto bg-green-100 rounded-full flex items-center justify-center">
              <Sparkles className="w-10 h-10 text-green-600" />
            </div>

            {/* Welcome Text */}
            <div className={`space-y-2 ${isRTL ? 'text-right' : 'text-center'}`}>
              <h2 className="text-2xl font-semibold">{t('nutrition.welcome')}</h2>
              <p className="text-muted-foreground">
                {t('nutrition.welcomeDesc')}
              </p>
            </div>

            {/* Features List */}
            <div className={`space-y-3 ${isRTL ? 'text-right' : 'text-left'}`}>
              <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
                  <Target className="w-4 h-4 text-green-600" />
                </div>
                <span className="text-sm">{t('nutrition.feature1')}</span>
              </div>
              <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
                  <ChefHat className="w-4 h-4 text-green-600" />
                </div>
                <span className="text-sm">{t('nutrition.feature2')}</span>
              </div>
              <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
                  <TrendingUp className="w-4 h-4 text-green-600" />
                </div>
                <span className="text-sm">{t('nutrition.feature3')}</span>
              </div>
            </div>

            {/* Start Button */}
            <Button 
              className="w-full bg-green-600 hover:bg-green-700"
              onClick={onStart}
            >
              {t('nutrition.startSetup')}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
