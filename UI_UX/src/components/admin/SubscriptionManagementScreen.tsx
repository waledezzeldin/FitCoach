import React from 'react';
import { Button } from '../ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { ArrowLeft, Save } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

export function SubscriptionManagementScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();

  const tiers = [
    { id: 'freemium', name: 'Freemium', price: 0, features: ['Basic workout plans', '50 coach messages/month', '1 video call/month'] },
    { id: 'premium', name: 'Premium', price: 29.99, features: ['Custom plans', '200 messages/month', '4 video calls/month', 'Nutrition access'] },
    { id: 'smart_premium', name: 'Smart Premium', price: 49.99, features: ['All Premium features', 'Unlimited messaging', '8 video calls/month', 'File attachments'] },
  ];

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-purple-600 to-pink-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('admin.subscriptionManagement')}</h1>
            <p className="text-sm text-white/80">{t('admin.managePlans')}</p>
          </div>
          <Button variant="secondary" onClick={() => toast.success(t('admin.saved'))}>
            <Save className="w-4 h-4 mr-2" />
            {t('common.save')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {tiers.map(tier => (
          <Card key={tier.id}>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                <span>{tier.name}</span>
                <span className="text-2xl text-primary">${tier.price}/mo</span>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>{t('admin.price')}</Label>
                  <Input type="number" defaultValue={tier.price} />
                </div>
                <div className="space-y-2">
                  <Label>{t('admin.billingCycle')}</Label>
                  <Input defaultValue="monthly" disabled />
                </div>
              </div>

              <div className="space-y-2">
                <Label>{t('admin.features')}</Label>
                <div className="space-y-2">
                  {tier.features.map((feature, idx) => (
                    <div key={idx} className="flex items-center gap-2 p-2 bg-muted/50 rounded">
                      <span className="text-sm">{feature}</span>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}