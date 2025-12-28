import React, { useState } from 'react';
import { Button } from './ui/button';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { ImageWithFallback } from './figma/ImageWithFallback';
import logoImage from 'figma:asset/a18300719941655fc0e724274fe3c0687ac10328.png';
import coachImage from 'figma:asset/de6a2e681d364f07c56c6148e2f26443e94f9ee6.png';

interface OnboardingCarouselProps {
  onComplete: () => void;
}

export function OnboardingCarousel({ onComplete }: OnboardingCarouselProps) {
  const { t, isRTL } = useLanguage();
  const [currentSlide, setCurrentSlide] = useState(0);
  const [touchStart, setTouchStart] = useState<number | null>(null);
  const [touchEnd, setTouchEnd] = useState<number | null>(null);

  const slides = [
    {
      image: coachImage,
      title: t('onboarding.coaching.title'),
      description: t('onboarding.coaching.description'),
      gradient: 'from-purple-500/20 to-blue-500/20',
      accentColor: 'bg-purple-500',
    },
    {
      image: 'https://images.unsplash.com/photo-1638328740227-1c4b1627614d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoZWFsdGh5JTIwbnV0cml0aW9uJTIwZm9vZCUyMGNvbG9yZnVsfGVufDF8fHx8MTc2NTMxMTA0N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      title: t('onboarding.nutrition.title'),
      description: t('onboarding.nutrition.description'),
      gradient: 'from-orange-500/20 to-blue-500/20',
      accentColor: 'bg-orange-500',
    },
    {
      image: 'https://images.unsplash.com/photo-1734189605012-f03d97a4d98f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b3Jrb3V0JTIwZ3ltJTIwZXhlcmNpc2UlMjB0cmFpbmluZ3xlbnwxfHx8fDE3NjUzMTEwNDd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      title: t('onboarding.workouts.title'),
      description: t('onboarding.workouts.description'),
      gradient: 'from-blue-500/20 to-purple-500/20',
      accentColor: 'bg-blue-500',
    },
    {
      image: 'https://images.unsplash.com/photo-1693996045369-781799bbaea0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwc3VwcGxlbWVudHMlMjBwcm90ZWluJTIwcG93ZGVyfGVufDF8fHx8MTc2NTMxMDU5M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      title: t('onboarding.store.title'),
      description: t('onboarding.store.description'),
      gradient: 'from-orange-500/20 to-purple-500/20',
      accentColor: 'bg-orange-500',
    },
  ];

  const totalSlides = slides.length;

  // Minimum swipe distance (in px) to trigger a slide change
  const minSwipeDistance = 50;

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchEnd(null);
    setTouchStart(e.targetTouches[0].clientX);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd(e.targetTouches[0].clientX);
  };

  const handleTouchEnd = () => {
    if (!touchStart || !touchEnd) return;
    
    const distance = touchStart - touchEnd;
    const isLeftSwipe = distance > minSwipeDistance;
    const isRightSwipe = distance < -minSwipeDistance;

    if (isRTL) {
      // Reverse swipe direction for RTL
      if (isLeftSwipe && currentSlide > 0) {
        setCurrentSlide(currentSlide - 1);
      }
      if (isRightSwipe && currentSlide < totalSlides - 1) {
        setCurrentSlide(currentSlide + 1);
      }
    } else {
      if (isLeftSwipe && currentSlide < totalSlides - 1) {
        setCurrentSlide(currentSlide + 1);
      }
      if (isRightSwipe && currentSlide > 0) {
        setCurrentSlide(currentSlide - 1);
      }
    }
  };

  const handleNext = () => {
    if (currentSlide < totalSlides - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      onComplete();
    }
  };

  const handlePrev = () => {
    if (currentSlide > 0) {
      setCurrentSlide(currentSlide - 1);
    }
  };

  const handleSkip = () => {
    onComplete();
  };

  const currentSlideData = slides[currentSlide];

  return (
    <div 
      className={`min-h-screen bg-gradient-to-br ${currentSlideData.gradient} transition-all duration-500 relative overflow-hidden`}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Skip Button */}
      <div className="absolute top-6 right-6 z-10">
        <Button 
          variant="ghost" 
          onClick={handleSkip}
          className="text-sm hover:bg-white/20 transition-colors"
        >
          {t('onboarding.skip')}
        </Button>
      </div>

      {/* Main Content */}
      <div className="min-h-screen flex flex-col items-center justify-center p-6 pt-20 pb-32">
        {/* Image Container */}
        <div className="w-full max-w-sm mb-8 relative">
          <div className="aspect-square rounded-3xl overflow-hidden shadow-2xl bg-white/10 backdrop-blur-sm">
            <ImageWithFallback
              src={currentSlideData.image}
              alt={currentSlideData.title}
              className="w-full h-full object-cover"
            />
          </div>
          {/* Decorative elements */}
          <div className={`absolute -top-4 -right-4 w-24 h-24 ${currentSlideData.accentColor} rounded-full opacity-20 blur-2xl`}></div>
          <div className={`absolute -bottom-4 -left-4 w-32 h-32 ${currentSlideData.accentColor} rounded-full opacity-15 blur-3xl`}></div>
        </div>

        {/* Text Content */}
        <div className={`text-center max-w-md ${isRTL ? 'text-right' : 'text-left'}`}>
          <h1 className="text-3xl font-bold mb-4 text-gray-900">
            {currentSlideData.title}
          </h1>
          <p className="text-lg text-gray-700 leading-relaxed">
            {currentSlideData.description}
          </p>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="absolute bottom-0 left-0 right-0 bg-white/80 backdrop-blur-md border-t border-gray-200 p-6">
        <div className="max-w-md mx-auto">
          {/* Progress Dots */}
          <div className="flex items-center justify-center gap-2 mb-6">
            {slides.map((_, index) => (
              <button
                key={index}
                onClick={() => setCurrentSlide(index)}
                className={`transition-all duration-300 rounded-full ${
                  index === currentSlide
                    ? `${currentSlideData.accentColor} w-8 h-2`
                    : 'bg-gray-300 w-2 h-2 hover:bg-gray-400'
                }`}
                aria-label={`${t('onboarding.goToSlide')} ${index + 1}`}
              />
            ))}
          </div>

          {/* Navigation Buttons */}
          <div className={`flex items-center gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            {/* Previous Button */}
            <Button
              variant="outline"
              onClick={handlePrev}
              disabled={currentSlide === 0}
              className="flex-shrink-0 w-12 h-12 p-0"
            >
              {isRTL ? (
                <ChevronRight className="w-5 h-5" />
              ) : (
                <ChevronLeft className="w-5 h-5" />
              )}
            </Button>

            {/* Next/Get Started Button */}
            <Button
              onClick={handleNext}
              className={`flex-1 h-12 ${currentSlideData.accentColor} hover:opacity-90 transition-opacity text-white`}
            >
              {currentSlide === totalSlides - 1
                ? t('onboarding.getStarted')
                : t('onboarding.next')}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}