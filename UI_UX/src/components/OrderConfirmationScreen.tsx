import React from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Separator } from './ui/separator';
import { CheckCircle, Package, Truck, Home } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface OrderConfirmationScreenProps {
  orderId: string;
  orderTotal: number;
  estimatedDelivery: Date;
  onViewOrder: () => void;
  onContinueShopping: () => void;
  onGoHome: () => void;
}

export function OrderConfirmationScreen({
  orderId,
  orderTotal,
  estimatedDelivery,
  onViewOrder,
  onContinueShopping,
  onGoHome
}: OrderConfirmationScreenProps) {
  const { t } = useLanguage();

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <Card className="max-w-md w-full">
        <CardContent className="p-8 text-center space-y-6">
          {/* Success Icon */}
          <div className="flex justify-center">
            <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center">
              <CheckCircle className="w-12 h-12 text-green-600" />
            </div>
          </div>

          {/* Success Message */}
          <div>
            <h1 className="text-2xl font-bold mb-2">{t('checkout.orderSuccess')}</h1>
            <p className="text-muted-foreground">{t('checkout.orderSuccessMessage')}</p>
          </div>

          {/* Order Details */}
          <div className="bg-muted/30 rounded-lg p-4 space-y-3">
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">{t('checkout.orderNumber')}</span>
              <span className="font-mono font-medium">{orderId}</span>
            </div>
            <Separator />
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">{t('checkout.total')}</span>
              <span className="font-bold text-lg text-primary">${orderTotal.toFixed(2)}</span>
            </div>
          </div>

          {/* Delivery Timeline */}
          <div className="space-y-3">
            <h3 className="font-medium text-left">{t('checkout.nextSteps')}</h3>
            <div className="space-y-2">
              <div className="flex items-start gap-3 text-left">
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <Package className="w-4 h-4 text-primary" />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-sm">{t('checkout.orderProcessing')}</p>
                  <p className="text-xs text-muted-foreground">{t('checkout.within24Hours')}</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3 text-left">
                <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center flex-shrink-0">
                  <Truck className="w-4 h-4 text-muted-foreground" />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-sm">{t('checkout.shipping')}</p>
                  <p className="text-xs text-muted-foreground">
                    {t('checkout.estimatedDelivery')}: {estimatedDelivery.toLocaleDateString()}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Confirmation Email */}
          <div className="bg-blue-50 dark:bg-blue-950 border border-blue-200 dark:border-blue-800 rounded-lg p-3">
            <p className="text-sm text-blue-800 dark:text-blue-200">
              {t('checkout.confirmationEmailSent')}
            </p>
          </div>

          {/* Action Buttons */}
          <div className="space-y-2 pt-4">
            <Button className="w-full" onClick={onViewOrder}>
              {t('checkout.viewOrderDetails')}
            </Button>
            <Button variant="outline" className="w-full" onClick={onContinueShopping}>
              {t('checkout.continueShopping')}
            </Button>
            <Button variant="ghost" className="w-full" onClick={onGoHome}>
              <Home className="w-4 h-4 mr-2" />
              {t('checkout.backToHome')}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
