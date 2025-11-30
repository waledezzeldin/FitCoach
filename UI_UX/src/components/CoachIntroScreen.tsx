import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { MessageSquare, Video, Calendar, Star } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface CoachIntroScreenProps {
  onGetStarted: () => void;
}

export function CoachIntroScreen({ onGetStarted }: CoachIntroScreenProps) {
  const { t, isRTL } = useLanguage();

  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Full background image */}
      <div 
        className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Gradient overlay */}
      <div className="absolute inset-0 z-1 bg-gradient-to-b from-black/60 via-black/50 to-black/70" />
      
      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col justify-end p-6 pb-8">
        <div className="space-y-6">
          {/* Title */}
          <div className="text-white space-y-2">
            <h1 className="text-4xl font-bold">{t('coach.introTitle') || 'Expert Coaches'}</h1>
            <p className="text-xl text-white/90">
              {t('coach.introSubtitle') || 'Get personalized guidance from certified fitness experts'}
            </p>
          </div>

          {/* Features */}
          <div className="space-y-3">
            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-purple-500/20 flex items-center justify-center">
                    <MessageSquare className="w-6 h-6 text-purple-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">{t('coach.introFeature1Title') || 'Direct Messaging'}</h3>
                    <p className="text-sm text-white/80">{t('coach.introFeature1Desc') || 'Chat with certified coaches for instant support and advice'}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center">
                    <Video className="w-6 h-6 text-blue-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">{t('coach.introFeature2Title') || 'Video Consultations'}</h3>
                    <p className="text-sm text-white/80">{t('coach.introFeature2Desc') || 'Book personalized video sessions for form checks and guidance'}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center">
                    <Calendar className="w-6 h-6 text-green-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">{t('coach.introFeature3Title') || 'Custom Plans'}</h3>
                    <p className="text-sm text-white/80">{t('coach.introFeature3Desc') || 'Receive personalized workout and nutrition plans from experts'}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-yellow-500/20 flex items-center justify-center">
                    <Star className="w-6 h-6 text-yellow-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">{t('coach.introFeature4Title') || 'Expert Guidance'}</h3>
                    <p className="text-sm text-white/80">{t('coach.introFeature4Desc') || 'Get professional advice tailored to your fitness goals'}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* CTA Button */}
          <Button 
            className="w-full bg-purple-600 hover:bg-purple-700 text-white h-14 text-lg"
            onClick={onGetStarted}
          >
            {t('coach.getStarted') || 'Get Started'}
          </Button>
        </div>
      </div>
    </div>
  );
}