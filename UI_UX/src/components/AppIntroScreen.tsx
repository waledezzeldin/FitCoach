import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Badge } from './ui/badge';
import { Dumbbell, Apple, MessageCircle, CheckCircle } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface AppIntroScreenProps {
  onComplete: () => void;
}

export function AppIntroScreen({ onComplete }: AppIntroScreenProps) {
  const { t, isRTL } = useLanguage();

  const features = [
    {
      icon: Dumbbell,
      title: t('intro.feature1'),
      description: t('intro.feature1.desc'),
      color: 'bg-blue-500',
    },
    {
      icon: Apple,
      title: t('intro.feature2'),
      description: t('intro.feature2.desc'),
      color: 'bg-green-500',
    },
    {
      icon: MessageCircle,
      title: t('intro.feature3'),
      description: t('intro.feature3.desc'),
      color: 'bg-purple-500',
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-primary rounded-3xl mb-6 shadow-lg">
            <Dumbbell className="w-10 h-10 text-primary-foreground" />
          </div>
          <Badge variant="secondary" className="mb-4 px-4 py-1">
            <CheckCircle className="w-3 h-3 mr-1" />
            Version 1.0
          </Badge>
          <h1 className="text-3xl font-bold text-primary mb-2">
            {t('intro.welcome')}
          </h1>
          <p className="text-lg text-muted-foreground mb-4">
            {t('intro.subtitle')}
          </p>
          <p className="text-muted-foreground leading-relaxed">
            {t('intro.description')}
          </p>
        </div>

        {/* Features */}
        <div className="space-y-4 mb-8">
          {features.map((feature, index) => (
            <Card key={index} className="overflow-hidden">
              <CardContent className="p-4">
                <div className={`flex items-center gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className={`w-12 h-12 ${feature.color} rounded-2xl flex items-center justify-center flex-shrink-0`}>
                    <feature.icon className="w-6 h-6 text-white" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold mb-1">{feature.title}</h3>
                    <p className="text-sm text-muted-foreground">
                      {feature.description}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* CTA Button */}
        <Button 
          onClick={onComplete}
          className="w-full py-6 text-lg shadow-lg"
          size="lg"
        >
          {t('intro.getStarted')}
        </Button>

        {/* Footer */}
        <div className="text-center mt-6 text-xs text-muted-foreground">
          <p>{t('intro.footer')}</p>
        </div>
      </div>
    </div>
  );
}