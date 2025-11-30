// FitCoach+ v2.0 - Translations Data Module
// This file extracts the translations object from LanguageContext.tsx
// to enable code-splitting and reduce initial bundle size

// Re-export the translations from the original LanguageContext
// Vite will automatically create a separate chunk for this module
import { Language } from './LanguageContext';

// We need to access the original translations
// Since it's not exported, we'll need to import the entire module
// and then Vite will tree-shake and code-split appropriately

// Temporary solution: We'll dynamically import and extract
export async function getTranslations(): Promise<Record<Language, Record<string, string>>> {
  // This dynamic import creates a separate chunk
  const module = await import('./LanguageContext');
  // The translations are in the module but not exported
  // We'll need to extract them differently
  
  // For now, return a promise that the LanguageContext will handle
  throw new Error('Use LanguageContext directly - this file is a placeholder for future optimization');
}

export type { Language };
