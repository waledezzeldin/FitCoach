import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { ArrowLeft, CreditCard, Plus, Trash2, Check } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface PaymentMethod {
  id: string;
  type: 'card' | 'paypal';
  last4?: string;
  brand?: string;
  expiryMonth?: number;
  expiryYear?: number;
  isDefault: boolean;
}

interface PaymentManagementScreenProps {
  onBack: () => void;
}

export function PaymentManagementScreen({ onBack }: PaymentManagementScreenProps) {
  const { t } = useLanguage();
  const [showAddCard, setShowAddCard] = useState(false);
  const [paymentMethods, setPaymentMethods] = useState<PaymentMethod[]>([
    {
      id: '1',
      type: 'card',
      last4: '4242',
      brand: 'Visa',
      expiryMonth: 12,
      expiryYear: 2025,
      isDefault: true
    },
    {
      id: '2',
      type: 'card',
      last4: '5555',
      brand: 'Mastercard',
      expiryMonth: 10,
      expiryYear: 2026,
      isDefault: false
    }
  ]);

  const [newCard, setNewCard] = useState({
    number: '',
    name: '',
    expiry: '',
    cvv: ''
  });

  const handleAddCard = () => {
    // Validate and add new card
    if (!newCard.number || !newCard.name || !newCard.expiry || !newCard.cvv) {
      toast.error(t('payment.fillAllFields'));
      return;
    }

    const mockCard: PaymentMethod = {
      id: Date.now().toString(),
      type: 'card',
      last4: newCard.number.slice(-4),
      brand: 'Visa',
      expiryMonth: parseInt(newCard.expiry.split('/')[0]),
      expiryYear: parseInt('20' + newCard.expiry.split('/')[1]),
      isDefault: false
    };

    setPaymentMethods([...paymentMethods, mockCard]);
    setShowAddCard(false);
    setNewCard({ number: '', name: '', expiry: '', cvv: '' });
    toast.success(t('payment.cardAdded'));
  };

  const handleSetDefault = (id: string) => {
    setPaymentMethods(methods => methods.map(m => ({
      ...m,
      isDefault: m.id === id
    })));
    toast.success(t('payment.defaultUpdated'));
  };

  const handleRemoveCard = (id: string) => {
    setPaymentMethods(methods => methods.filter(m => m.id !== id));
    toast.success(t('payment.cardRemoved'));
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('payment.title')}</h1>
            <p className="text-sm text-white/80">{t('payment.subtitle')}</p>
          </div>
          <Button
            variant="secondary"
            size="sm"
            onClick={() => setShowAddCard(true)}
          >
            <Plus className="w-4 h-4 mr-2" />
            {t('payment.addCard')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-3">
        {paymentMethods.map(method => (
          <Card key={method.id} className={method.isDefault ? 'border-primary' : ''}>
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded flex items-center justify-center text-white font-bold text-xs">
                    {method.brand}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-medium">•••• •••• •••• {method.last4}</span>
                      {method.isDefault && (
                        <Badge variant="secondary">
                          <Check className="w-3 h-3 mr-1" />
                          {t('payment.default')}
                        </Badge>
                      )}
                    </div>
                    <p className="text-sm text-muted-foreground">
                      {t('payment.expires')} {method.expiryMonth}/{method.expiryYear}
                    </p>
                  </div>
                </div>

                <div className="flex gap-2">
                  {!method.isDefault && (
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleSetDefault(method.id)}
                    >
                      {t('payment.setDefault')}
                    </Button>
                  )}
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleRemoveCard(method.id)}
                    disabled={method.isDefault}
                  >
                    <Trash2 className="w-4 h-4 text-destructive" />
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}

        {paymentMethods.length === 0 && (
          <Card>
            <CardContent className="p-12 text-center">
              <CreditCard className="w-12 h-12 mx-auto mb-4 text-muted-foreground opacity-50" />
              <p className="text-muted-foreground mb-4">{t('payment.noCards')}</p>
              <Button onClick={() => setShowAddCard(true)}>
                <Plus className="w-4 h-4 mr-2" />
                {t('payment.addFirstCard')}
              </Button>
            </CardContent>
          </Card>
        )}
      </div>

      {/* Add Card Dialog */}
      <Dialog open={showAddCard} onOpenChange={setShowAddCard}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('payment.addNewCard')}</DialogTitle>
            <DialogDescription>{t('payment.addCardDesc')}</DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label>{t('payment.cardNumber')}</Label>
              <Input
                placeholder="1234 5678 9012 3456"
                value={newCard.number}
                onChange={(e) => setNewCard({ ...newCard, number: e.target.value })}
                maxLength={16}
              />
            </div>

            <div className="space-y-2">
              <Label>{t('payment.cardholderName')}</Label>
              <Input
                placeholder="John Doe"
                value={newCard.name}
                onChange={(e) => setNewCard({ ...newCard, name: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('payment.expiry')}</Label>
                <Input
                  placeholder="MM/YY"
                  value={newCard.expiry}
                  onChange={(e) => setNewCard({ ...newCard, expiry: e.target.value })}
                  maxLength={5}
                />
              </div>
              <div className="space-y-2">
                <Label>{t('payment.cvv')}</Label>
                <Input
                  placeholder="123"
                  type="password"
                  value={newCard.cvv}
                  onChange={(e) => setNewCard({ ...newCard, cvv: e.target.value })}
                  maxLength={4}
                />
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAddCard(false)}>
              {t('common.cancel')}
            </Button>
            <Button onClick={handleAddCard}>
              {t('payment.addCard')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}