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

// Lazy-loaded translations
let translationsCache: Record<Language, Record<string, string>> | null = null;
let translationsPromise: Promise<any> | null = null;

async function loadTranslations() {
  if (translationsCache) {
    return translationsCache;
  }

  if (translationsPromise) {
    return translationsPromise;
  }

  translationsPromise = (async () => {
    // Import the old LanguageContext to extract translations
    const oldContext = await import('./LanguageContext');
    // Access the translations object if exported, otherwise we'll use a fallback
    // For now, we'll import chunk by chunk
    const { loadTranslations: load } = await import('../translations/index');
    translationsCache = await load();
    return translationsCache;
  })();

  return translationsPromise;
}

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [hasSelectedLanguage, setHasSelectedLanguage] = useState(false);
  const [language, setLanguage] = useState<Language>('en');
  const [translations, setTranslations] = useState<Record<Language, Record<string, string>> | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load translations on mount
  useEffect(() => {
    loadTranslations().then(trans => {
      setTranslations(trans);
      setIsLoading(false);
    }).catch(error => {
      console.error('Failed to load translations:', error);
      setIsLoading(false);
    });
  }, []);

  useEffect(() => {
    const savedLanguage = localStorage.getItem('fitcoach_language') as Language;
    if (savedLanguage) {
      setLanguage(savedLanguage);
      setHasSelectedLanguage(true);
      document.documentElement.dir = savedLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = savedLanguage;
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
    if (!translations) {
      return key; // Return key if translations not loaded yet
    }

    let translation = translations[language][key] || key;
    
    // Handle parameter substitution
    if (params && typeof translation === 'string') {
      Object.keys(params).forEach(paramKey => {
        translation = translation.replace(new RegExp(`{{${paramKey}}}`, 'g'), params[paramKey]);
      });
    }
    
    return translation;
  };

  const isRTL = language === 'ar';

  // Show loading indicator while translations are loading
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-background">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading...</p>
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
