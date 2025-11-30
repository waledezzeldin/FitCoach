// Phone Number Validation Utilities

export interface PhoneValidationResult {
  isValid: boolean;
  formatted?: string;
  error?: string;
}

export interface CountryCode {
  code: string;
  name: string;
  flag: string;
  dialCode: string;
}

export const COUNTRY_CODES: CountryCode[] = [
  { code: 'SA', name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966' },
  { code: 'EG', name: 'Egypt', flag: '🇪🇬', dialCode: '+20' },
  { code: 'TR', name: 'Turkey', flag: '🇹🇷', dialCode: '+90' },
  { code: 'AE', name: 'UAE', flag: '🇦🇪', dialCode: '+971' },
  { code: 'US', name: 'United States', flag: '🇺🇸', dialCode: '+1' },
  { code: 'GB', name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44' },
];

export const validatePhoneNumber = (phone: string, countryCode: string): PhoneValidationResult => {
  // Remove all non-digit characters
  const digitsOnly = phone.replace(/\D/g, '');
  
  // Basic validation
  if (digitsOnly.length < 7 || digitsOnly.length > 15) {
    return {
      isValid: false,
      error: 'Phone number must be 7-15 digits'
    };
  }
  
  // Format as E.164
  const formatted = `${countryCode}${digitsOnly}`;
  
  return {
    isValid: true,
    formatted
  };
};

export const formatPhoneForDisplay = (e164Phone: string): string => {
  // Extract country code and number
  const country = COUNTRY_CODES.find(c => e164Phone.startsWith(c.dialCode));
  
  if (!country) return e164Phone;
  
  const number = e164Phone.substring(country.dialCode.length);
  
  // Format based on country (simple formatting)
  if (country.code === 'SA') {
    // Saudi: +966 50 123 4567
    return `${country.dialCode} ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}`;
  } else if (country.code === 'EG') {
    // Egypt: +20 100 123 4567
    return `${country.dialCode} ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}`;
  } else if (country.code === 'US') {
    // US: +1 (555) 123-4567
    return `${country.dialCode} (${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}`;
  }
  
  // Default formatting
  return `${country.dialCode} ${number}`;
};

export const maskPhone = (e164Phone: string): string => {
  // Show only last 4 digits: +966 ** *** **67
  const country = COUNTRY_CODES.find(c => e164Phone.startsWith(c.dialCode));
  
  if (!country) return '****';
  
  const number = e164Phone.substring(country.dialCode.length);
  const lastFour = number.substring(number.length - 4);
  
  return `${country.dialCode} ** *** **${lastFour}`;
};
