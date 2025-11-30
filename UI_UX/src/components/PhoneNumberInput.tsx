import React, { useState } from 'react';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { COUNTRY_CODES, validatePhoneNumber, PhoneValidationResult } from '../utils/phoneValidation';
import { useLanguage } from './LanguageContext';

interface PhoneNumberInputProps {
  value: string;
  onChange: (e164Phone: string, isValid: boolean) => void;
  disabled?: boolean;
  defaultCountry?: string;
}

export function PhoneNumberInput({ 
  value, 
  onChange, 
  disabled = false,
  defaultCountry = 'SA' 
}: PhoneNumberInputProps) {
  const { t, isRTL } = useLanguage();
  const [countryCode, setCountryCode] = useState(
    COUNTRY_CODES.find(c => c.code === defaultCountry)?.dialCode || '+966'
  );
  const [phoneNumber, setPhoneNumber] = useState('');
  const [validation, setValidation] = useState<PhoneValidationResult>({ isValid: true });

  const handlePhoneChange = (phone: string) => {
    setPhoneNumber(phone);
    
    const result = validatePhoneNumber(phone, countryCode);
    setValidation(result);
    
    if (result.isValid && result.formatted) {
      onChange(result.formatted, true);
    } else {
      onChange('', false);
    }
  };

  const handleCountryChange = (newDialCode: string) => {
    setCountryCode(newDialCode);
    
    // Re-validate with new country code
    if (phoneNumber) {
      const result = validatePhoneNumber(phoneNumber, newDialCode);
      setValidation(result);
      
      if (result.isValid && result.formatted) {
        onChange(result.formatted, true);
      } else {
        onChange('', false);
      }
    }
  };

  return (
    <div className="space-y-2">
      <Label htmlFor="phone">{t('auth.phoneNumber')}</Label>
      
      <div className={`flex gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
        {/* Country Code Selector */}
        <Select value={countryCode} onValueChange={handleCountryChange} disabled={disabled}>
          <SelectTrigger className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {COUNTRY_CODES.map(country => (
              <SelectItem key={country.code} value={country.dialCode}>
                <span className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <span>{country.flag}</span>
                  <span>{country.dialCode}</span>
                </span>
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {/* Phone Number Input */}
        <Input
          id="phone"
          type="tel"
          placeholder="501234567"
          value={phoneNumber}
          onChange={e => handlePhoneChange(e.target.value)}
          disabled={disabled}
          className={`flex-1 ${!validation.isValid && phoneNumber ? 'border-red-500' : ''}`}
          dir="ltr" // Always LTR for phone numbers
        />
      </div>

      {/* Validation Error */}
      {!validation.isValid && phoneNumber && validation.error && (
        <p className="text-sm text-red-500">{validation.error}</p>
      )}

      {/* Helper Text */}
      {validation.isValid && phoneNumber && (
        <p className="text-sm text-muted-foreground">
          {t('auth.phoneWillReceiveOTP')}
        </p>
      )}
    </div>
  );
}
