import React from 'react';
import { Alert, AlertDescription } from './ui/alert';
import { Button } from './ui/button';
import { Clock, Lock, Crown, RefreshCw } from 'lucide-react';
import { NutritionExpiryStatus } from '../utils/nutritionExpiry';
import { useLanguage } from './LanguageContext';

interface NutritionExpiryBannerProps {
  status: NutritionExpiryStatus;
  onUpgrade?: () => void;
  onRegenerate?: () => void;
  tier: 'Freemium' | 'Premium' | 'Smart Premium';
}

export function NutritionExpiryBanner({
  status,
  onUpgrade,
  onRegenerate,
  tier
}: NutritionExpiryBannerProps) {
  const { t, isRTL } = useLanguage();

  // Premium+ users don't see expiry banner
  if (tier !== 'Freemium') {
    return null;
  }

  // Plan is locked (expired)
  if (status.isLocked || status.isExpired) {
    return (
      <Alert className="bg-red-50 border-red-200">
        <Lock className="w-4 h-4 text-red-600" />
        <AlertDescription className="space-y-2">
          <div>
            <p className="font-medium text-red-900">{t('nutrition.expired')}</p>
            <p className="text-sm text-red-700">{t('nutrition.upgradeToKeep')}</p>
          </div>
          <div className={`flex gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
            {onUpgrade && (
              <Button 
                size="sm" 
                onClick={onUpgrade}
                className="bg-purple-600 hover:bg-purple-700"
              >
                <Crown className="w-3 h-3 mr-1" />
                {t('subscription.upgradeButton')} Premium
              </Button>
            )}
            {onRegenerate && (
              <Button 
                size="sm" 
                variant="outline"
                onClick={onRegenerate}
              >
                <RefreshCw className="w-3 h-3 mr-1" />
                {t('nutrition.regenerate')}
              </Button>
            )}
          </div>
        </AlertDescription>
      </Alert>
    );
  }

  // Plan is active but expiring soon
  const isExpiringSoon = status.daysRemaining !== null && status.daysRemaining <= 2;

  return (
    <Alert className={isExpiringSoon ? 'bg-orange-50 border-orange-200' : 'bg-blue-50 border-blue-200'}>
      <Clock className={`w-4 h-4 ${isExpiringSoon ? 'text-orange-600' : 'text-blue-600'}`} />
      <AlertDescription className="space-y-2">
        <div>
          <p className={`font-medium ${isExpiringSoon ? 'text-orange-900' : 'text-blue-900'}`}>
            {t('nutrition.expiresIn')}: {' '}
            {status.daysRemaining !== null && status.daysRemaining > 0 && (
              <span>
                {status.daysRemaining} {t('nutrition.days')}
              </span>
            )}
            {status.daysRemaining === 0 && status.hoursRemaining !== null && (
              <span>
                {status.hoursRemaining} {t('nutrition.hours')}
              </span>
            )}
          </p>
          <p className={`text-sm ${isExpiringSoon ? 'text-orange-700' : 'text-blue-700'}`}>
            {t('nutrition.freemiumAccess')}
          </p>
        </div>
        {onUpgrade && (
          <Button 
            size="sm" 
            variant="outline"
            onClick={onUpgrade}
            className={isExpiringSoon ? 'border-orange-300 text-orange-900 hover:bg-orange-100' : ''}
          >
            <Crown className="w-3 h-3 mr-1" />
            {t('nutrition.unlockUnlimited')}
          </Button>
        )}
      </AlertDescription>
    </Alert>
  );
}
