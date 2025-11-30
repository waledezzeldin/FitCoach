import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Globe, ChevronRight } from 'lucide-react';
import { useLanguage } from './LanguageContext';

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
    <div className="min-h-screen bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="mb-4">
            <div className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4">
              <Globe className="w-8 h-8 text-white" />
            </div>
          </div>
          <h1 className="text-white text-2xl font-bold mb-2">
            {t('language.choose')}
          </h1>
          <p className="text-white/80 text-base">
            {t('language.chooseSubtitle')}
          </p>
        </div>

        {/* Language Options */}
        <div className="space-y-3">
          {languages.map((language) => (
            <Card key={language.code} className="overflow-hidden">
              <CardContent className="p-0">
                <Button
                  variant="ghost"
                  className="w-full h-auto p-4 justify-between hover:bg-muted/50 transition-colors"
                  onClick={() => onLanguageSelect(language.code)}
                >
                  <div className="flex items-center space-x-3 rtl:space-x-reverse">
                    <span className="text-2xl">{language.flag}</span>
                    <div className="text-left rtl:text-right">
                      <p className="font-medium">{language.name}</p>
                      <p className="text-sm text-muted-foreground">{language.nativeName}</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-muted-foreground rtl:rotate-180" />
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Footer */}
        <div className="text-center mt-8">
          <p className="text-white/60 text-sm">
            {t('language.changeLater')}
          </p>
          <p className="text-white/60 text-sm">
            {t('language.changeLaterAr')}
          </p>
        </div>
      </div>
    </div>
  );
}