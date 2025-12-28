import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { ShoppingBag, Package, Truck, Sparkles } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { motion } from 'motion/react';

interface StoreIntroScreenProps {
  onGetStarted: () => void;
}

export function StoreIntroScreen({ onGetStarted }: StoreIntroScreenProps) {
  const { t, isRTL } = useLanguage();

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.3, // Increased delay between items
        delayChildren: 0.3
      }
    }
  };

  // Directional animation based on language
  const itemVariants = {
    hidden: { 
      opacity: 0, 
      x: isRTL ? 100 : -100  // Right to left for RTL, left to right for LTR
    },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut"
      }
    }
  };

  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Full background image */}
      <div 
        className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1736236560164-bc741c70bca5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Gradient overlay */}
      <div className="absolute inset-0 z-1 bg-gradient-to-b from-black/60 via-black/50 to-black/70" />
      
      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col justify-end p-6 pb-8">
        <div className="space-y-6">
          {/* Title */}
          <div className="text-white space-y-2">
            <h1 className="text-4xl font-bold">{t('store.intro.title')}</h1>
            <p className="text-xl text-white/90">
              {t('store.intro.subtitle')}
            </p>
          </div>

          {/* Features */}
          <motion.div className="space-y-3" variants={containerVariants} initial="hidden" animate="visible">
            <motion.div variants={itemVariants}>
              <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                <CardContent className="p-4">
                  <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <div className="w-12 h-12 rounded-full bg-orange-500/20 flex items-center justify-center">
                      <ShoppingBag className="w-6 h-6 text-orange-300" />
                    </div>
                    <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                      <h3 className="font-semibold text-white">{t('store.intro.feature1Title')}</h3>
                      <p className="text-sm text-white/80">{t('store.intro.feature1Desc')}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants}>
              <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                <CardContent className="p-4">
                  <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center">
                      <Sparkles className="w-6 h-6 text-blue-300" />
                    </div>
                    <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                      <h3 className="font-semibold text-white">{t('store.intro.feature2Title')}</h3>
                      <p className="text-sm text-white/80">{t('store.intro.feature2Desc')}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants}>
              <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                <CardContent className="p-4">
                  <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center">
                      <Truck className="w-6 h-6 text-green-300" />
                    </div>
                    <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                      <h3 className="font-semibold text-white">{t('store.intro.feature3Title')}</h3>
                      <p className="text-sm text-white/80">{t('store.intro.feature3Desc')}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants}>
              <Card className="bg-white/10 backdrop-blur-sm border-white/20">
                <CardContent className="p-4">
                  <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <div className="w-12 h-12 rounded-full bg-purple-500/20 flex items-center justify-center">
                      <Package className="w-6 h-6 text-purple-300" />
                    </div>
                    <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                      <h3 className="font-semibold text-white">{t('store.intro.feature4Title')}</h3>
                      <p className="text-sm text-white/80">{t('store.intro.feature4Desc')}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>

          {/* CTA Button */}
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button 
              className="w-full bg-orange-600 hover:bg-orange-700 text-white h-14 text-lg"
              onClick={onGetStarted}
            >
              {t('store.intro.startShopping')}
            </Button>
          </motion.div>
        </div>
      </div>
    </div>
  );
}