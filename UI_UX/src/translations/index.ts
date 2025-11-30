// FitCoach+ v2.0 - Modular Translation System
// This file aggregates all translation modules for lazy loading

export type Language = 'en' | 'ar';

// Import all translation modules
import { commonTranslations } from './common';

// Lazy-loaded translation modules (will be code-split automatically)
const translationModules = [
  () => import('./auth'),
  () => import('./onboarding'),
  () => import('./workouts'),
  () => import('./nutrition'),
  () => import('./coach'),
  () => import('./admin'),
  () => import('./store'),
  () => import('./user'),
];

let cachedTranslations: Record<Language, Record<string, string>> | null = null;
let loadingPromise: Promise<Record<Language, Record<string, string>>> | null = null;

/**
 * Loads and merges all translation modules
 * This function is called once on app startup
 */
export async function loadTranslations(): Promise<Record<Language, Record<string, string>>> {
  // Return cached translations if already loaded
  if (cachedTranslations) {
    return cachedTranslations;
  }

  // Return existing promise if already loading
  if (loadingPromise) {
    return loadingPromise;
  }

  // Start loading all modules
  loadingPromise = (async () => {
    // Load all translation modules in parallel
    const modules = await Promise.all(
      translationModules.map(loader => loader())
    );

    // Initialize with common translations
    const merged: Record<Language, Record<string, string>> = {
      en: { ...commonTranslations.en },
      ar: { ...commonTranslations.ar },
    };

    // Merge all module translations
    modules.forEach(module => {
      const translations = module.default || module;
      Object.keys(translations).forEach(lang => {
        Object.assign(merged[lang as Language], translations[lang as Language]);
      });
    });

    cachedTranslations = merged;
    return merged;
  })();

  return loadingPromise;
}

/**
 * Gets translations synchronously (must be loaded first)
 */
export function getTranslationsSync(): Record<Language, Record<string, string>> {
  if (!cachedTranslations) {
    // Fallback: return common translations only
    // The app should call loadTranslations() during initialization
    console.warn('Translations not fully loaded. Using common translations only.');
    return {
      en: { ...commonTranslations.en },
      ar: { ...commonTranslations.ar },
    };
  }
  return cachedTranslations;
}

/**
 * Preload translations during app initialization
 */
export function preloadTranslations() {
  loadTranslations().catch(error => {
    console.error('Failed to preload translations:', error);
  });
}
