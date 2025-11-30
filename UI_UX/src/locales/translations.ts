// FitCoach+ v2.0 - Optimized Translation Loading
// This file provides lazy-loaded translations to reduce initial bundle size

export type Language = 'en' | 'ar';

// Lazy load translations on demand
let cachedTranslations: Record<Language, Record<string, string>> | null = null;

export async function getTranslations(): Promise<Record<Language, Record<string, string>>> {
  if (cachedTranslations) {
    return cachedTranslations;
  }

  // Dynamic import - this creates a separate chunk
  const module = await import('./translations-data');
  cachedTranslations = module.translations;
  return cachedTranslations;
}

// Synchronous getter for contexts that can't use async
export function getTranslationsSync(): Record<Language, Record<string, string>> {
  if (!cachedTranslations) {
    // If not loaded yet, we need to load from LanguageContext
    // This is a fallback - the app should call getTranslations() first
    throw new Error('Translations not loaded yet. Call getTranslations() first.');
  }
  return cachedTranslations;
}
