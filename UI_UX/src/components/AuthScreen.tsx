import React, { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Separator } from './ui/separator';
import { Dumbbell, Mail, Phone } from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { PhoneNumberInput } from './PhoneNumberInput';
import { OTPInput } from './OTPInput';

interface AuthScreenProps {
  onAuthenticate: (userType: 'user' | 'coach' | 'admin', profile?: UserProfile) => void;
  onActivateDemo: (phoneNumber?: string) => void;
}

type AuthStep = 'choose' | 'phone' | 'otp' | 'email' | 'emailSignup';

export function AuthScreen({ onAuthenticate, onActivateDemo }: AuthScreenProps) {
  const { t, isRTL } = useLanguage();
  const [authStep, setAuthStep] = useState<AuthStep>('choose');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [name, setName] = useState('');
  const [isPhoneValid, setIsPhoneValid] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [otpAttempts, setOtpAttempts] = useState(3);
  const [logoPressStart, setLogoPresStart] = useState<number | null>(null);

  const handlePhoneChange = (e164Phone: string, isValid: boolean) => {
    setPhoneNumber(e164Phone);
    setIsPhoneValid(isValid);
  };

  const handlePhoneSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isPhoneValid) return;

    setIsLoading(true);

    // Simulate sending OTP
    await new Promise(resolve => setTimeout(resolve, 1000));

    setAuthStep('otp');
    setIsLoading(false);
  };

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;

    setIsLoading(true);

    // Simulate email authentication
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Demo authentication logic based on email
    if (email === 'coach@fitcoach.com') {
      onAuthenticate('coach');
    } else if (email === 'admin@fitcoach.com') {
      onAuthenticate('admin');
    } else {
      // Regular user authentication
      onAuthenticate('user');
    }

    setIsLoading(false);
  };

  const handleEmailSignupSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password || !confirmPassword || !name) return;

    if (password !== confirmPassword) {
      alert(t('auth.passwordMismatch') || 'Passwords do not match');
      return;
    }

    setIsLoading(true);

    // Simulate account creation
    await new Promise(resolve => setTimeout(resolve, 1500));

    // After successful signup, authenticate the user
    onAuthenticate('user');

    setIsLoading(false);
  };

  const handleOTPComplete = async (otp: string) => {
    setIsLoading(true);

    // Simulate OTP verification
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Demo authentication logic based on phone number
    if (phoneNumber === '+966507654321') {
      onAuthenticate('coach');
    } else if (phoneNumber === '+966509876543') {
      onAuthenticate('admin');
    } else {
      // Regular user authentication
      onAuthenticate('user');
    }

    setIsLoading(false);
  };

  const handleSocialLogin = async (provider: 'google' | 'facebook' | 'apple') => {
    setIsLoading(true);

    // Simulate social login
    await new Promise(resolve => setTimeout(resolve, 1500));

    // For demo purposes, authenticate as regular user
    onAuthenticate('user');

    setIsLoading(false);
  };

  const handleResendOTP = async () => {
    setIsLoading(true);
    // Simulate resending OTP
    await new Promise(resolve => setTimeout(resolve, 1000));
    setIsLoading(false);
  };

  const handleLogoPress = () => {
    setLogoPresStart(Date.now());
  };

  const handleLogoRelease = () => {
    if (logoPressStart && Date.now() - logoPressStart > 2000) {
      onActivateDemo();
    }
    setLogoPresStart(null);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-20"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1595079835020-30a7ac7c0b02?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10 w-full max-w-md p-6">
        {/* Logo */}
        <div 
          className="text-center mb-8"
          onMouseDown={handleLogoPress}
          onMouseUp={handleLogoRelease}
          onTouchStart={handleLogoPress}
          onTouchEnd={handleLogoRelease}
        >
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-2xl mb-4">
            <Dumbbell className="w-8 h-8 text-primary-foreground" />
          </div>
          <h1 className="text-3xl font-bold text-primary">FitCoach+</h1>
          <p className="text-muted-foreground">{t('auth.tagline')}</p>
        </div>

        <Card>
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">
              {authStep === 'otp' 
                ? t('auth.enterOTP') 
                : authStep === 'emailSignup'
                ? (t('auth.createAccount') || 'Create Account')
                : t('auth.welcome')
              }
            </CardTitle>
            <CardDescription className="text-center">
              {authStep === 'otp' 
                ? `${t('auth.otpSent')} ${phoneNumber}`
                : authStep === 'choose'
                ? t('auth.welcomeSubtitle')
                : authStep === 'phone'
                ? t('auth.phoneWillReceiveOTP')
                : authStep === 'emailSignup'
                ? (t('auth.createAccountSubtitle') || 'Join FitCoach+ and start your fitness journey')
                : t('auth.welcomeSubtitle')
              }
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {authStep === 'choose' && (
              <div className="space-y-3">
                {/* Email/Password Button */}
                <Button 
                  variant="outline" 
                  className="w-full h-12 justify-start"
                  onClick={() => setAuthStep('email')}
                  disabled={isLoading}
                >
                  <Mail className={`w-5 h-5 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                  {t('auth.continueWithEmail')}
                </Button>

                {/* Phone Button */}
                <Button 
                  variant="outline" 
                  className="w-full h-12 justify-start"
                  onClick={() => setAuthStep('phone')}
                  disabled={isLoading}
                >
                  <Phone className={`w-5 h-5 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                  {t('auth.continueWithPhone')}
                </Button>

                <div className="relative my-4">
                  <Separator />
                  <span className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-background px-2 text-xs text-muted-foreground">
                    {t('auth.orDivider')}
                  </span>
                </div>

                {/* Social Login Icons - Icons Only */}
                <div className="flex gap-3 justify-center">
                  <Button 
                    variant="outline" 
                    size="icon"
                    className="h-12 w-12 rounded-full"
                    onClick={() => handleSocialLogin('google')}
                    disabled={isLoading}
                    title={t('auth.continueWithGoogle')}
                  >
                    <svg className="w-5 h-5" viewBox="0 0 24 24">
                      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                    </svg>
                  </Button>

                  <Button 
                    variant="outline" 
                    size="icon"
                    className="h-12 w-12 rounded-full"
                    onClick={() => handleSocialLogin('facebook')}
                    disabled={isLoading}
                    title={t('auth.continueWithFacebook')}
                  >
                    <svg className="w-5 h-5" viewBox="0 0 24 24" fill="#1877F2">
                      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                    </svg>
                  </Button>

                  <Button 
                    variant="outline" 
                    size="icon"
                    className="h-12 w-12 rounded-full"
                    onClick={() => handleSocialLogin('apple')}
                    disabled={isLoading}
                    title={t('auth.continueWithApple')}
                  >
                    <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
                    </svg>
                  </Button>
                </div>
              </div>
            )}

            {authStep === 'email' && (
              <form onSubmit={handleEmailSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email">{t('auth.email')}</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder={t('auth.emailPlaceholder')}
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    disabled={isLoading}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password">{t('auth.password')}</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder={t('auth.passwordPlaceholder')}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    disabled={isLoading}
                    required
                  />
                </div>

                <Button 
                  type="submit" 
                  className="w-full" 
                  disabled={isLoading || !email || !password}
                >
                  {isLoading ? t('common.loading') : t('auth.signIn')}
                </Button>

                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => setAuthStep('choose')}
                  disabled={isLoading}
                >
                  {t('common.back')}
                </Button>

                <div className="text-center pt-2">
                  <p className="text-sm text-muted-foreground">
                    {t('auth.noAccount') || "Don't have an account?"}{' '}
                    <Button
                      type="button"
                      variant="link"
                      className="p-0 h-auto text-primary"
                      onClick={() => setAuthStep('emailSignup')}
                      disabled={isLoading}
                    >
                      {t('auth.signUp') || 'Sign Up'}
                    </Button>
                  </p>
                </div>
              </form>
            )}

            {authStep === 'emailSignup' && (
              <form onSubmit={handleEmailSignupSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="signup-name">{t('auth.fullName')}</Label>
                  <Input
                    id="signup-name"
                    type="text"
                    placeholder={t('auth.fullName')}
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    disabled={isLoading}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="signup-email">{t('auth.email')}</Label>
                  <Input
                    id="signup-email"
                    type="email"
                    placeholder={t('auth.emailPlaceholder')}
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    disabled={isLoading}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="signup-password">{t('auth.password')}</Label>
                  <Input
                    id="signup-password"
                    type="password"
                    placeholder={t('auth.passwordPlaceholder')}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    disabled={isLoading}
                    required
                    minLength={6}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="confirm-password">{t('auth.confirmPassword') || 'Confirm Password'}</Label>
                  <Input
                    id="confirm-password"
                    type="password"
                    placeholder={t('auth.confirmPasswordPlaceholder') || 'Re-enter your password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    disabled={isLoading}
                    required
                    minLength={6}
                  />
                </div>

                <Button 
                  type="submit" 
                  className="w-full" 
                  disabled={isLoading || !email || !password || !confirmPassword || !name}
                >
                  {isLoading ? t('common.loading') : t('auth.createAccount') || 'Create Account'}
                </Button>

                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => setAuthStep('email')}
                  disabled={isLoading}
                >
                  {t('common.back')}
                </Button>

                <div className="text-center pt-2">
                  <p className="text-sm text-muted-foreground">
                    {t('auth.haveAccount') || 'Already have an account?'}{' '}
                    <Button
                      type="button"
                      variant="link"
                      className="p-0 h-auto text-primary"
                      onClick={() => setAuthStep('email')}
                      disabled={isLoading}
                    >
                      {t('auth.signIn')}
                    </Button>
                  </p>
                </div>
              </form>
            )}

            {authStep === 'phone' && (
              <form onSubmit={handlePhoneSubmit} className="space-y-4">
                <PhoneNumberInput
                  value={phoneNumber}
                  onChange={handlePhoneChange}
                  disabled={isLoading}
                  defaultCountry="SA"
                />

                <Button 
                  type="submit" 
                  className="w-full" 
                  disabled={isLoading || !isPhoneValid}
                >
                  {isLoading ? t('common.loading') : t('auth.signIn')}
                </Button>

                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => setAuthStep('choose')}
                  disabled={isLoading}
                >
                  {t('common.back')}
                </Button>
              </form>
            )}

            {authStep === 'otp' && (
              <div className="space-y-4">
                <OTPInput
                  length={6}
                  onComplete={handleOTPComplete}
                  onResend={handleResendOTP}
                  disabled={isLoading}
                  resendCooldown={60}
                />

                {otpAttempts < 3 && (
                  <p className="text-sm text-center text-muted-foreground">
                    {otpAttempts} {t('auth.attemptsRemaining')}
                  </p>
                )}

                <Button
                  variant="outline"
                  className="w-full"
                  onClick={() => setAuthStep('phone')}
                  disabled={isLoading}
                >
                  {t('common.back')}
                </Button>
              </div>
            )}

            {authStep === 'choose' && (
              <div className="text-center pt-4">
                <Button 
                  variant="outline" 
                  onClick={() => onActivateDemo(phoneNumber)}
                  className="text-sm"
                  disabled={isLoading}
                >
                  {t('auth.tryDemo')}
                </Button>
              </div>
            )}
          </CardContent>
        </Card>

        <div className="text-center mt-6 text-xs text-muted-foreground">
          <p>{t('auth.demoCredentials')}</p>
          <p>{t('auth.demoUser')}</p>
          <p>Email: user@fitcoach.com / Password: demo123</p>
          <p>{t('auth.demoCoach')}</p>
          <p>Email: coach@fitcoach.com</p>
          <p>{t('auth.demoAdmin')}</p>
          <p>Email: admin@fitcoach.com</p>
        </div>
      </div>
    </div>
  );
}