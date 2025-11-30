import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Dumbbell, Target, TrendingUp, Calendar, CheckCircle, ArrowRight } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface WorkoutIntroScreenProps {
  onGetStarted: () => void;
}

export function WorkoutIntroScreen({ onGetStarted }: WorkoutIntroScreenProps) {
  const { t, isRTL } = useLanguage();

  return (
    <div className="min-h-screen bg-background relative overflow-hidden">
      {/* Full Foreground Image with Overlay */}
      <div 
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ 
          backgroundImage: 'url(https://images.unsplash.com/photo-1717571209798-ac9312c2d3cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)',
        }}
      >
        <div className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/60 to-black/80" />
      </div>

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col p-6 text-white">
        {/* Logo/Icon */}
        <div className="flex justify-center mt-12 mb-8">
          <div className="w-20 h-20 bg-blue-600 rounded-full flex items-center justify-center shadow-2xl">
            <Dumbbell className="w-10 h-10" />
          </div>
        </div>

        {/* Title */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-3">{t('workouts.introTitle') || 'Workout Center'}</h1>
          <p className="text-xl text-white/90">
            {t('workouts.introSubtitle') || 'Your personalized fitness journey starts here'}
          </p>
        </div>

        {/* Features */}
        <div className="flex-1 flex items-center">
          <div className="w-full space-y-4">
            <Card className="bg-white/10 backdrop-blur-md border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 bg-blue-600/20 rounded-xl flex items-center justify-center flex-shrink-0">
                    <Target className="w-6 h-6 text-blue-400" />
                  </div>
                  <div className={isRTL ? 'text-right' : 'text-left'}>
                    <h3 className="font-semibold mb-1 text-white">
                      {t('workouts.introFeature1Title') || 'Personalized Plans'}
                    </h3>
                    <p className="text-sm text-white/80">
                      {t('workouts.introFeature1Desc') || 'Custom workout plans tailored to your fitness goals and experience level'}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-md border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 bg-green-600/20 rounded-xl flex items-center justify-center flex-shrink-0">
                    <CheckCircle className="w-6 h-6 text-green-400" />
                  </div>
                  <div className={isRTL ? 'text-right' : 'text-left'}>
                    <h3 className="font-semibold mb-1 text-white">
                      {t('workouts.introFeature2Title') || 'Exercise Library'}
                    </h3>
                    <p className="text-sm text-white/80">
                      {t('workouts.introFeature2Desc') || 'Access hundreds of exercises with video guides and detailed instructions'}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-md border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 bg-purple-600/20 rounded-xl flex items-center justify-center flex-shrink-0">
                    <TrendingUp className="w-6 h-6 text-purple-400" />
                  </div>
                  <div className={isRTL ? 'text-right' : 'text-left'}>
                    <h3 className="font-semibold mb-1 text-white">
                      {t('workouts.introFeature3Title') || 'Track Progress'}
                    </h3>
                    <p className="text-sm text-white/80">
                      {t('workouts.introFeature3Desc') || 'Log your workouts and monitor your strength gains over time'}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-md border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 bg-orange-600/20 rounded-xl flex items-center justify-center flex-shrink-0">
                    <Calendar className="w-6 h-6 text-orange-400" />
                  </div>
                  <div className={isRTL ? 'text-right' : 'text-left'}>
                    <h3 className="font-semibold mb-1 text-white">
                      {t('workouts.introFeature4Title') || 'Injury-Safe Alternatives'}
                    </h3>
                    <p className="text-sm text-white/80">
                      {t('workouts.introFeature4Desc') || 'Get safe exercise substitutions if you have any injuries or limitations'}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* CTA Button */}
        <div className="mt-8 pb-8">
          <Button 
            onClick={onGetStarted}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white h-14 text-lg shadow-2xl"
            size="lg"
          >
            {t('workouts.getStarted') || 'Get Started'}
            <ArrowRight className={`w-5 h-5 ${isRTL ? 'mr-2' : 'ml-2'}`} />
          </Button>
          <p className="text-center text-white/60 text-sm mt-3">
            {t('workouts.introNote') || 'You can always access help from the workout screen'}
          </p>
        </div>
      </div>
    </div>
  );
}
