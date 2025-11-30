import React, { useState, useRef, useEffect } from 'react';
import { Input } from './ui/input';

interface OTPInputProps {
  length?: number;
  onComplete: (otp: string) => void;
  onResend?: () => void;
  resendCooldown?: number; // seconds
  disabled?: boolean;
}

export function OTPInput({ 
  length = 6, 
  onComplete, 
  onResend,
  resendCooldown = 60,
  disabled = false
}: OTPInputProps) {
  const [otp, setOtp] = useState<string[]>(Array(length).fill(''));
  const [resendTimer, setResendTimer] = useState(0);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    // Auto-focus first input
    if (inputRefs.current[0] && !disabled) {
      inputRefs.current[0].focus();
    }
  }, [disabled]);

  useEffect(() => {
    // Resend timer countdown
    if (resendTimer > 0) {
      const timer = setTimeout(() => setResendTimer(resendTimer - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [resendTimer]);

  const handleChange = (index: number, value: string) => {
    if (disabled) return;

    // Only allow digits
    const digit = value.replace(/\D/g, '').slice(-1);
    
    const newOtp = [...otp];
    newOtp[index] = digit;
    setOtp(newOtp);

    // Auto-focus next input
    if (digit && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }

    // Check if complete
    if (newOtp.every(d => d !== '') && newOtp.join('').length === length) {
      onComplete(newOtp.join(''));
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (disabled) return;

    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      // Move to previous input on backspace if current is empty
      inputRefs.current[index - 1]?.focus();
    } else if (e.key === 'ArrowLeft' && index > 0) {
      inputRefs.current[index - 1]?.focus();
    } else if (e.key === 'ArrowRight' && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    if (disabled) return;

    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, length);
    
    const newOtp = [...otp];
    pastedData.split('').forEach((digit, i) => {
      if (i < length) {
        newOtp[i] = digit;
      }
    });
    
    setOtp(newOtp);

    // Focus last filled input or next empty
    const nextIndex = Math.min(pastedData.length, length - 1);
    inputRefs.current[nextIndex]?.focus();

    // Check if complete
    if (newOtp.every(d => d !== '') && newOtp.join('').length === length) {
      onComplete(newOtp.join(''));
    }
  };

  const handleResend = () => {
    if (resendTimer > 0 || !onResend) return;
    
    onResend();
    setResendTimer(resendCooldown);
    setOtp(Array(length).fill(''));
    inputRefs.current[0]?.focus();
  };

  return (
    <div className="space-y-4">
      <div className="flex gap-2 justify-center" onPaste={handlePaste}>
        {otp.map((digit, index) => (
          <Input
            key={index}
            ref={el => inputRefs.current[index] = el}
            type="text"
            inputMode="numeric"
            maxLength={1}
            value={digit}
            onChange={e => handleChange(index, e.target.value)}
            onKeyDown={e => handleKeyDown(index, e)}
            disabled={disabled}
            className="w-12 h-12 text-center text-lg font-semibold"
            autoComplete="off"
          />
        ))}
      </div>

      {onResend && (
        <div className="text-center">
          <button
            type="button"
            onClick={handleResend}
            disabled={resendTimer > 0}
            className={`text-sm ${
              resendTimer > 0 
                ? 'text-muted-foreground cursor-not-allowed' 
                : 'text-primary hover:underline'
            }`}
          >
            {resendTimer > 0 
              ? `Resend code in ${resendTimer}s` 
              : 'Resend code'}
          </button>
        </div>
      )}
    </div>
  );
}
