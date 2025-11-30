// FitCoach+ v2.0 - Optimized Language Context with Lazy Loading
// This version extracts translations to reduce initial bundle size

import React, { createContext, useContext, useState, useEffect } from 'react';

export type Language = 'en' | 'ar';

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string, params?: Record<string, any>) => string;
  isRTL: boolean;
  hasSelectedLanguage: boolean;
  selectInitialLanguage: (lang: Language) => void;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

// Inline minimal translations for critical UI during loading
const minimalTranslations = {
  en: {
    'common.loading': 'Loading...',
    'language.choose': 'Choose Your Language',
    'language.changeLater': 'You can change this later in settings',
  },
  ar: {
    'common.loading': 'جاري التحميل...',
    'language.choose': 'اختر لغتك',
    'language.changeLater': 'يمكنك تغيير هذا لاحقاً في الإعدادات',
  }
} as const;

// Cache for loaded translations
let translationsCache: Record<Language, Record<string, string>> | null = null;
let translationsPromise: Promise<Record<Language, Record<string, string>>> | null = null;

/**
 * Lazy load translations from a separate chunk
 * This keeps the initial bundle small
 */
async function loadTranslations() {
  if (translationsCache) {
    return translationsCache;
  }

  if (translationsPromise) {
    return translationsPromise;
  }

  translationsPromise = (async () => {
    try {
      // Dynamically import the translation data
      // This creates a separate chunk that's only loaded when needed
      const module = await import('./translations-data');
      translationsCache = module.translations;
      return translationsCache;
    } catch (error) {
      console.error('Failed to load translations:', error);
      // Fallback to minimal translations
      return minimalTranslations as Record<Language, Record<string, string>>;
    }
  })();

  return translationsPromise;
}

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [hasSelectedLanguage, setHasSelectedLanguage] = useState(false);
  const [language, setLanguage] = useState<Language>('en');
  const [translations, setTranslations] = useState<Record<Language, Record<string, string>>>(
    minimalTranslations as Record<Language, Record<string, string>>
  );
  const [isLoadingTranslations, setIsLoadingTranslations] = useState(true);

  // Load translations on mount
  useEffect(() => {
    loadTranslations()
      .then(trans => {
        setTranslations(trans);
        setIsLoadingTranslations(false);
      })
      .catch(error => {
        console.error('Failed to load translations:', error);
        setIsLoadingTranslations(false);
      });
  }, []);

  // Restore language preference from localStorage
  useEffect(() => {
    const savedLanguage = localStorage.getItem('fitcoach_language') as Language;
    if (savedLanguage) {
      setLanguage(savedLanguage);
      setHasSelectedLanguage(true);
      document.documentElement.dir = savedLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = savedLanguage;
    } else {
      setIsLoadingTranslations(false);
    }
  }, []);

  const selectInitialLanguage = (lang: Language) => {
    setLanguage(lang);
    setHasSelectedLanguage(true);
    localStorage.setItem('fitcoach_language', lang);
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = lang;
  };

  const changeLanguage = (lang: Language) => {
    setLanguage(lang);
    localStorage.setItem('fitcoach_language', lang);
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = lang;
  };

  const t = (key: string, params?: Record<string, any>): string => {
    let translation = translations[language]?.[key] || key;
    
    // Handle parameter substitution (e.g., {{name}}, {{injury}})
    if (params && typeof translation === 'string') {
      Object.keys(params).forEach(paramKey => {
        translation = translation.replace(new RegExp(`\\{\\{${paramKey}\\}\\}`, 'g'), params[paramKey]);
      });
    }
    
    return translation;
  };

  const isRTL = language === 'ar';

  // Show minimal loading screen while translations are loading and language is not selected
  if (isLoadingTranslations && !hasSelectedLanguage) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-background">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">{minimalTranslations[language]['common.loading']}</p>
        </div>
      </div>
    );
  }

  return (
    <LanguageContext.Provider 
      value={{ 
        language, 
        setLanguage: changeLanguage, 
        t, 
        isRTL, 
        hasSelectedLanguage,
        selectInitialLanguage 
      }}
    >
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
