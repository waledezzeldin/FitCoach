import React from 'react';
import { Button } from './ui/button';
import { ArrowLeft, LogOut } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { motion } from 'motion/react';

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
      <motion.div
        whileTap={{ scale: 0.9 }}
        whileHover={{ scale: 1.1 }}
        transition={{ type: "spring", stiffness: 400, damping: 17 }}
      >
        <Button 
          variant="ghost" 
          size="icon"
          onClick={onLogout}
          className={`text-primary-foreground hover:bg-primary-foreground/20 ${className}`}
          title={t('common.back')}
        >
          <LogOut className="w-5 h-5" />
        </Button>
      </motion.div>
    );
  }

  return (
    <motion.div
      whileTap={{ scale: 0.9 }}
      whileHover={{ scale: 1.1 }}
      transition={{ type: "spring", stiffness: 400, damping: 17 }}
    >
      <Button 
        variant="ghost" 
        size="icon"
        onClick={onBack}
        className={`text-primary-foreground hover:bg-primary-foreground/20 ${className}`}
        title={t('common.back')}
      >
        <ArrowLeft className={`w-5 h-5 ${isRTL ? 'rotate-180' : ''}`} />
      </Button>
    </motion.div>
  );
}