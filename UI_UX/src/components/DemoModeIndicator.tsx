import React from 'react';
import { Badge } from './ui/badge';
import { PlayCircle } from 'lucide-react';
import { useLanguage } from './LanguageContext';

export function DemoModeIndicator() {
  const { t, isRTL } = useLanguage();
  
  return (
    <div className="fixed top-4 left-1/2 transform -translate-x-1/2 z-50">
      <Badge 
        variant="secondary" 
        className="bg-orange-100 text-orange-800 border-orange-300 px-3 py-1 shadow-lg animate-pulse"
      >
        <PlayCircle className={`w-3 h-3 ${isRTL ? 'ml-1' : 'mr-1'}`} />
        {t('demo.mode')}
      </Badge>
    </div>
  );
}