import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { 
  ArrowLeft, 
  Check, 
  X, 
  Crown, 
  Star,
  Zap,
  Sparkles
} from 'lucide-react';
import { UserProfile, SubscriptionTier } from '../App';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface SubscriptionManagerProps {
  userProfile: UserProfile;
  onBack: () => void;
  onUpgrade: (newTier: SubscriptionTier) => void;
}

interface PlanFeature {
  id: string;
  category: string;
  freemium: boolean | string;
  premium: boolean | string;
  smartPremium: boolean | string;
}

export function SubscriptionManager({ userProfile, onBack, onUpgrade }: SubscriptionManagerProps) {
  const { t, isRTL } = useLanguage();
  const [selectedPlan, setSelectedPlan] = useState<SubscriptionTier>(userProfile.subscriptionTier);
  const [isUpgrading, setIsUpgrading] = useState(false);

  const planFeatures: PlanFeature[] = [
    {
      id: 'workouts_access',
      category: t('subscription.workouts'),
      freemium: t('subscription.included'),
      premium: t('subscription.included'),
      smartPremium: t('subscription.included')
    },
    {
      id: 'workout_plans',
      category: t('subscription.workoutPlans'),
      freemium: `2-${t('subscription.weekCycle')}`,
      premium: `4-${t('subscription.weekCycle')}`,
      smartPremium: t('subscription.adaptiveAI')
    },
    {
      id: 'nutrition_access',
      category: t('subscription.nutrition'),
      freemium: false,
      premium: t('subscription.included'),
      smartPremium: t('subscription.included')
    },
    {
      id: 'nutrition_personalization',
      category: t('subscription.mealPersonalization'),
      freemium: false,
      premium: t('subscription.basicPreferences'),
      smartPremium: t('subscription.aiPowered')
    },
    {
      id: 'coach_messages',
      category: t('subscription.coachMessages'),
      freemium: `3 ${t('subscription.perMonth')}`,
      premium: `15 ${t('subscription.perMonth')}`,
      smartPremium: t('subscription.unlimited')
    },
    {
      id: 'coach_sessions',
      category: t('subscription.videoSessions'),
      freemium: `1 ${t('subscription.perMonth')}`,
      premium: `4 ${t('subscription.perMonth')}`,
      smartPremium: `8 ${t('subscription.perMonth')}`
    },
    {
      id: 'store_access',
      category: t('subscription.store'),
      freemium: t('subscription.included'),
      premium: t('subscription.included'),
      smartPremium: t('subscription.included')
    },
    {
      id: 'store_discounts',
      category: t('subscription.storeDiscounts'),
      freemium: false,
      premium: `10% ${t('subscription.off')}`,
      smartPremium: `20% ${t('subscription.off')}`
    },
    {
      id: 'progress_analytics',
      category: t('subscription.advancedAnalytics'),
      freemium: false,
      premium: t('subscription.basicReports'),
      smartPremium: t('subscription.detailedInsights')
    }
  ];

  const planDetails = {
    Freemium: {
      name: t('subscription.freemium'),
      price: 'Free',
      priceAr: 'مجاني',
      icon: Star,
      color: 'border-gray-200 bg-gray-50',
      headerColor: 'bg-gray-100',
      buttonColor: 'bg-gray-500 hover:bg-gray-600'
    },
    Premium: {
      name: t('subscription.premium'),
      price: '$19.99/month',
      priceAr: '19.99$ شهرياً',
      icon: Crown,
      color: 'border-blue-200 bg-blue-50',
      headerColor: 'bg-blue-100',
      buttonColor: 'bg-blue-600 hover:bg-blue-700'
    },
    'Smart Premium': {
      name: t('subscription.smartPremium'),
      price: '$39.99/month',
      priceAr: '39.99$ شهرياً',
      icon: Zap,
      color: 'border-purple-200 bg-purple-50',
      headerColor: 'bg-purple-100',
      buttonColor: 'bg-purple-600 hover:bg-purple-700'
    }
  };

  const handleUpgrade = async (tier: SubscriptionTier) => {
    setIsUpgrading(true);
    
    // Simulate upgrade process
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    onUpgrade(tier);
    toast.success(t('subscription.upgradeSuccess'), {
      description: `${t('subscription.currentPlan')}: ${planDetails[tier].name}`,
      duration: 3000,
    });
    
    setIsUpgrading(false);
    onBack();
  };

  const FeatureIcon = ({ included }: { included: boolean | string }) => {
    if (included === false) {
      return <X className="w-4 h-4 text-red-500" />;
    }
    return <Check className="w-4 h-4 text-green-600" />;
  };

  const renderFeatureValue = (value: boolean | string) => {
    if (value === false) {
      return <span className="text-red-500 text-sm">{t('subscription.notIncluded')}</span>;
    }
    if (value === true) {
      return <span className="text-green-600 text-sm">{t('subscription.included')}</span>;
    }
    return <span className="text-sm font-medium">{value}</span>;
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4">
        <div className={`flex items-center gap-3 mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('subscription.title')}</h1>
            <p className="text-white/80">{t('subscription.compare')}</p>
          </div>
          <Sparkles className="w-6 h-6" />
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Current Plan Indicator */}
        <Card className="bg-gradient-to-r from-green-50 to-blue-50 border-green-200">
          <CardContent className="p-4">
            <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
              <div className={isRTL ? 'text-right' : 'text-left'}>
                <h3 className="font-medium text-green-900">{t('subscription.current')}</h3>
                <p className="text-sm text-green-700">{planDetails[userProfile.subscriptionTier].name}</p>
              </div>
              <Badge variant="secondary" className="bg-green-100 text-green-800">
                {planDetails[userProfile.subscriptionTier].name}
              </Badge>
            </div>
          </CardContent>
        </Card>

        {/* Plan Comparison */}
        <div className="space-y-4">
          <h2 className="text-center">{t('subscription.compare')}</h2>
          
          {/* Plan Headers */}
          <div className="grid grid-cols-3 gap-2">
            {(Object.keys(planDetails) as SubscriptionTier[]).map((tier) => {
              const plan = planDetails[tier];
              const PlanIcon = plan.icon;
              const isCurrentPlan = tier === userProfile.subscriptionTier;
              
              return (
                <Card 
                  key={tier} 
                  className={`${plan.color} ${isCurrentPlan ? 'ring-2 ring-green-500' : ''} transition-all`}
                >
                  <CardHeader className={`${plan.headerColor} p-3 text-center`}>
                    <div className="flex flex-col items-center gap-2">
                      <PlanIcon className="w-6 h-6" />
                      <div>
                        <CardTitle className="text-sm">{plan.name}</CardTitle>
                        <p className="text-xs font-medium">
                          {isRTL ? plan.priceAr : plan.price}
                        </p>
                      </div>
                      {isCurrentPlan && (
                        <Badge variant="secondary" className="text-xs bg-green-100 text-green-800">
                          {t('subscription.currentPlan')}
                        </Badge>
                      )}
                    </div>
                  </CardHeader>
                </Card>
              );
            })}
          </div>

          {/* Features Comparison */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">{t('subscription.features')}</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {planFeatures.map((feature, index) => (
                <div 
                  key={feature.id} 
                  className={`grid grid-cols-4 gap-2 p-3 ${index % 2 === 0 ? 'bg-muted/30' : ''}`}
                >
                  <div className="font-medium text-sm">
                    {feature.category}
                  </div>
                  <div className="flex items-center gap-2">
                    <FeatureIcon included={feature.freemium} />
                    {renderFeatureValue(feature.freemium)}
                  </div>
                  <div className="flex items-center gap-2">
                    <FeatureIcon included={feature.premium} />
                    {renderFeatureValue(feature.premium)}
                  </div>
                  <div className="flex items-center gap-2">
                    <FeatureIcon included={feature.smartPremium} />
                    {renderFeatureValue(feature.smartPremium)}
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Upgrade Buttons */}
          <div className="grid grid-cols-1 gap-4">
            {(Object.keys(planDetails) as SubscriptionTier[]).map((tier) => {
              const plan = planDetails[tier];
              const isCurrentPlan = tier === userProfile.subscriptionTier;
              const isUpgrade = tier !== 'Freemium' && tier !== userProfile.subscriptionTier;
              
              if (isCurrentPlan) return null;
              
              return (
                <Button
                  key={tier}
                  className={`${plan.buttonColor} w-full`}
                  disabled={isUpgrading || !isUpgrade}
                  onClick={() => handleUpgrade(tier)}
                >
                  {isUpgrading ? (
                    <div className="flex items-center gap-2">
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      {t('subscription.upgrading')}
                    </div>
                  ) : (
                    <>
                      {t('subscription.upgradeButton')} {plan.name}
                      <span className="ml-2 text-sm opacity-80">
                        {isRTL ? plan.priceAr : plan.price}
                      </span>
                    </>
                  )}
                </Button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}