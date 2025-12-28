import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Globe, ChevronRight } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import logoImage from 'figma:asset/a18300719941655fc0e724274fe3c0687ac10328.png';
import { motion } from 'motion/react';

interface LanguageSelectionScreenProps {
  onLanguageSelect: (language: 'en' | 'ar') => void;
}

export function LanguageSelectionScreen({ onLanguageSelect }: LanguageSelectionScreenProps) {
  const { t } = useLanguage();
  
  const languages = [
    {
      code: 'en' as const,
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸'
    },
    {
      code: 'ar' as const,
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦'
    }
  ];

  return (
    <div className="min-h-screen relative overflow-hidden flex items-center justify-center p-4">
      {/* Fitness Background Image */}
      <div 
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ 
          backgroundImage: 'url(https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)',
        }}
      >
        <div className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/60 to-black/80" />
      </div>
      
      <div className="w-full max-w-md relative z-10">
        {/* Header */}
        <motion.div 
          className="text-center mb-12"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          {/* Logo */}
          <div className="mb-6">
            <motion.div 
              className="w-32 h-32 flex items-center justify-center mx-auto mb-6"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{
                type: "spring",
                stiffness: 200,
                damping: 15,
                duration: 0.8,
              }}
            >
              <img src={logoImage} alt="Fitness App Logo" className="w-full h-full object-contain drop-shadow-2xl" />
            </motion.div>
          </div>
          <h1 className="text-white text-3xl font-bold mb-3 tracking-tight drop-shadow-lg">
            Choose Your Language
          </h1>
          <p className="text-white/90 text-lg drop-shadow-md">
            اختر لغتك
          </p>
        </motion.div>

        {/* Language Options - Smaller and Centered */}
        <motion.div 
          className="space-y-3 max-w-xs mx-auto"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
        >
          {languages.map((language, index) => (
            <motion.div
              key={language.code}
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.4 + index * 0.1, duration: 0.5 }}
            >
              <Button
                variant="outline"
                className="w-full h-auto py-4 px-6 justify-between bg-white/95 backdrop-blur-sm hover:bg-white hover:shadow-xl hover:shadow-blue-500/20 transition-all duration-300 hover:scale-105 border-white/30"
                onClick={() => onLanguageSelect(language.code)}
              >
                <div className="flex items-center space-x-3 rtl:space-x-reverse">
                  <span className="text-2xl">{language.flag}</span>
                  <div className="text-left rtl:text-right">
                    <p className="font-semibold text-slate-900">{language.nativeName}</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-blue-600 rtl:rotate-180" />
              </Button>
            </motion.div>
          ))}
        </motion.div>

        {/* Footer */}
        <motion.div 
          className="text-center mt-10"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.5 }}
        >
          <p className="text-white/80 text-sm drop-shadow-md">
            You can change this later in settings
          </p>
          <p className="text-white/80 text-sm drop-shadow-md">
            يمكنك تغيير هذا لاحقاً في الإعدادات
          </p>
        </motion.div>
      </div>
    </div>
  );
}