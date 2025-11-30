import React from 'react';
import { Button } from './ui/button';
import { ArrowLeft, LogOut } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface BackButtonProps {
  onBack?: () => void;
  onLogout?: () => void;
  showLogout?: boolean;
  className?: string;
}

export function BackButton({ onBack, onLogout, showLogout = false, className = "" }: BackButtonProps) {
  const { t, isRTL } = useLanguage();

  if (showLogout && onLogout) {
    return (
      <Button 
        variant="ghost" 
        size="icon"
        onClick={onLogout}
        className={`text-primary-foreground hover:bg-primary-foreground/20 ${className}`}
        title={t('common.back')}
      >
        <LogOut className="w-5 h-5" />
      </Button>
    );
  }

  return (
    <Button 
      variant="ghost" 
      size="icon"
      onClick={onBack}
      className={`text-primary-foreground hover:bg-primary-foreground/20 ${className}`}
      title={t('common.back')}
    >
      <ArrowLeft className={`w-5 h-5 ${isRTL ? 'rotate-180' : ''}`} />
    </Button>
  );
}