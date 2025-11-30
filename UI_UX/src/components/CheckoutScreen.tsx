import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { RadioGroup, RadioGroupItem } from './ui/radio-group';
import { Separator } from './ui/separator';
import { ScrollArea } from './ui/scroll-area';
import { 
  ArrowLeft, 
  CreditCard, 
  Truck, 
  MapPin, 
  Phone,
  Mail,
  CheckCircle,
  Trash2,
  Shield
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface CartItem {
  product: {
    id: string;
    name: string;
    brand: string;
    price: number;
    image: string;
  };
  quantity: number;
}

interface CheckoutScreenProps {
  cartItems: CartItem[];
  onBack: () => void;
  onOrderComplete: (orderId: string) => void;
}

export function CheckoutScreen({ cartItems, onBack, onOrderComplete }: CheckoutScreenProps) {
  const { t, isRTL } = useLanguage();
  const [step, setStep] = useState<'shipping' | 'payment' | 'review'>('shipping');
  
  // Shipping information
  const [shippingInfo, setShippingInfo] = useState({
    fullName: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    state: '',
    zipCode: '',
    country: 'Saudi Arabia'
  });
  
  // Payment method
  const [paymentMethod, setPaymentMethod] = useState<'card' | 'cod'>('card');
  const [cardInfo, setCardInfo] = useState({
    cardNumber: '',
    cardName: '',
    expiryDate: '',
    cvv: ''
  });

  const subtotal = cartItems?.reduce((sum, item) => sum + item.product.price * item.quantity, 0) || 0;
  const shipping = subtotal > 100 ? 0 : 15;
  const tax = subtotal * 0.15; // 15% VAT
  const total = subtotal + shipping + tax;

  const handlePlaceOrder = () => {
    if (step === 'shipping') {
      if (!shippingInfo.fullName || !shippingInfo.email || !shippingInfo.phone || !shippingInfo.address) {
        toast.error(t('checkout.fillAllFields'));
        return;
      }
      setStep('payment');
    } else if (step === 'payment') {
      if (paymentMethod === 'card' && (!cardInfo.cardNumber || !cardInfo.cardName)) {
        toast.error(t('checkout.fillPaymentDetails'));
        return;
      }
      setStep('review');
    } else {
      // Process order
      const orderId = `ORD-${Date.now()}`;
      toast.success(t('checkout.orderPlaced'));
      onOrderComplete(orderId);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white p-4">
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
            <h1 className="text-xl">{t('checkout.title')}</h1>
            <p className="text-sm text-white/80">{t('checkout.subtitle')}</p>
          </div>
        </div>
      </div>

      {/* Progress Steps */}
      <div className="p-6 bg-muted/30">
        <div className="max-w-3xl mx-auto">
          <div className="flex items-center justify-between">
            {/* Step 1: Shipping */}
            <div className="flex flex-col items-center gap-2 flex-1">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-all ${
                step === 'shipping' ? 'border-primary bg-primary text-white shadow-lg scale-110' : 
                step === 'payment' || step === 'review' ? 'border-green-500 bg-green-500 text-white' : 'border-muted-foreground bg-background'
              }`}>
                {step === 'payment' || step === 'review' ? <CheckCircle className="w-5 h-5" /> : '1'}
              </div>
              <span className={`text-sm font-medium ${
                step === 'shipping' ? 'text-primary' : 
                step === 'payment' || step === 'review' ? 'text-green-600' : 'text-muted-foreground'
              }`}>
                {t('checkout.shipping')}
              </span>
            </div>
            
            {/* Connector Line 1 */}
            <div className={`h-0.5 flex-1 mx-2 transition-colors ${
              step === 'payment' || step === 'review' ? 'bg-green-500' : 'bg-muted-foreground/30'
            }`} />
            
            {/* Step 2: Payment */}
            <div className="flex flex-col items-center gap-2 flex-1">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-all ${
                step === 'payment' ? 'border-primary bg-primary text-white shadow-lg scale-110' : 
                step === 'review' ? 'border-green-500 bg-green-500 text-white' : 'border-muted-foreground/30 bg-background'
              }`}>
                {step === 'review' ? <CheckCircle className="w-5 h-5" /> : '2'}
              </div>
              <span className={`text-sm font-medium ${
                step === 'payment' ? 'text-primary' : 
                step === 'review' ? 'text-green-600' : 'text-muted-foreground'
              }`}>
                {t('checkout.payment')}
              </span>
            </div>
            
            {/* Connector Line 2 */}
            <div className={`h-0.5 flex-1 mx-2 transition-colors ${
              step === 'review' ? 'bg-green-500' : 'bg-muted-foreground/30'
            }`} />
            
            {/* Step 3: Review */}
            <div className="flex flex-col items-center gap-2 flex-1">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-all ${
                step === 'review' ? 'border-primary bg-primary text-white shadow-lg scale-110' : 'border-muted-foreground/30 bg-background'
              }`}>
                3
              </div>
              <span className={`text-sm font-medium ${
                step === 'review' ? 'text-primary' : 'text-muted-foreground'
              }`}>
                {t('checkout.review')}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="p-4 lg:p-6 max-w-7xl mx-auto">
        <div className={`grid lg:grid-cols-3 gap-6 ${isRTL ? 'lg:flex lg:flex-row-reverse' : ''}`}>
          {/* Main Content */}
          <div className={`space-y-6 ${isRTL ? 'lg:flex-[2]' : 'lg:col-span-2'}`}>
          {/* Shipping Information */}
          {step === 'shipping' && (
            <Card>
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                    <Truck className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <div>{t('checkout.shippingInformation')}</div>
                    <p className="text-sm text-muted-foreground font-normal">
                      {t('checkout.subtitle')}
                    </p>
                  </div>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-5">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                  <div className="space-y-2">
                    <Label htmlFor="fullName">{t('checkout.fullName')} *</Label>
                    <Input
                      id="fullName"
                      value={shippingInfo.fullName}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, fullName: e.target.value })}
                      placeholder="John Doe"
                      className="h-11"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">{t('checkout.email')} *</Label>
                    <Input
                      id="email"
                      type="email"
                      value={shippingInfo.email}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, email: e.target.value })}
                      placeholder="john@example.com"
                      className="h-11"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="phone">{t('checkout.phone')} *</Label>
                  <Input
                    id="phone"
                    value={shippingInfo.phone}
                    onChange={(e) => setShippingInfo({ ...shippingInfo, phone: e.target.value })}
                    placeholder="+966 50 123 4567"
                    className="h-11"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="address">{t('checkout.address')} *</Label>
                  <Input
                    id="address"
                    value={shippingInfo.address}
                    onChange={(e) => setShippingInfo({ ...shippingInfo, address: e.target.value })}
                    placeholder="123 Main St"
                    className="h-11"
                  />
                </div>

                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="city">{t('checkout.city')}</Label>
                    <Input
                      id="city"
                      value={shippingInfo.city}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, city: e.target.value })}
                      placeholder="Riyadh"
                      className="h-11"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="state">{t('checkout.state')}</Label>
                    <Input
                      id="state"
                      value={shippingInfo.state}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, state: e.target.value })}
                      placeholder="Riyadh"
                      className="h-11"
                    />
                  </div>
                  <div className="space-y-2 col-span-2 md:col-span-1">
                    <Label htmlFor="zipCode">{t('checkout.zipCode')}</Label>
                    <Input
                      id="zipCode"
                      value={shippingInfo.zipCode}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, zipCode: e.target.value })}
                      placeholder="12345"
                      className="h-11"
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Payment Information */}
          {step === 'payment' && (
            <Card>
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                    <CreditCard className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <div>{t('checkout.paymentMethod')}</div>
                    <p className="text-sm text-muted-foreground font-normal">
                      Select your preferred payment method
                    </p>
                  </div>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-5">
                <RadioGroup value={paymentMethod} onValueChange={(val) => setPaymentMethod(val as 'card' | 'cod')}>
                  <div className={`flex items-center space-x-3 border-2 rounded-xl p-4 cursor-pointer transition-all hover:border-primary/50 ${
                    paymentMethod === 'card' ? 'border-primary bg-primary/5' : ''
                  }`}>
                    <RadioGroupItem value="card" id="card" />
                    <Label htmlFor="card" className="flex-1 cursor-pointer">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                          <CreditCard className="w-5 h-5 text-blue-600" />
                        </div>
                        <div>
                          <div className="font-medium">{t('checkout.creditCard')}</div>
                          <p className="text-xs text-muted-foreground">Pay securely with your card</p>
                        </div>
                      </div>
                    </Label>
                  </div>
                  <div className={`flex items-center space-x-3 border-2 rounded-xl p-4 cursor-pointer transition-all hover:border-primary/50 ${
                    paymentMethod === 'cod' ? 'border-primary bg-primary/5' : ''
                  }`}>
                    <RadioGroupItem value="cod" id="cod" />
                    <Label htmlFor="cod" className="flex-1 cursor-pointer">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center">
                          <Truck className="w-5 h-5 text-green-600" />
                        </div>
                        <div>
                          <div className="font-medium">{t('checkout.cashOnDelivery')}</div>
                          <p className="text-xs text-muted-foreground">Pay when you receive</p>
                        </div>
                      </div>
                    </Label>
                  </div>
                </RadioGroup>

                {paymentMethod === 'card' && (
                  <div className="space-y-5 pt-4 border-t">
                    <div className="space-y-2">
                      <Label htmlFor="cardNumber">{t('checkout.cardNumber')} *</Label>
                      <Input
                        id="cardNumber"
                        value={cardInfo.cardNumber}
                        onChange={(e) => setCardInfo({ ...cardInfo, cardNumber: e.target.value })}
                        placeholder="1234 5678 9012 3456"
                        maxLength={19}
                        className="h-11"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="cardName">{t('checkout.cardholderName')} *</Label>
                      <Input
                        id="cardName"
                        value={cardInfo.cardName}
                        onChange={(e) => setCardInfo({ ...cardInfo, cardName: e.target.value })}
                        placeholder="John Doe"
                        className="h-11"
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="expiryDate">{t('checkout.expiryDate')} *</Label>
                        <Input
                          id="expiryDate"
                          value={cardInfo.expiryDate}
                          onChange={(e) => setCardInfo({ ...cardInfo, expiryDate: e.target.value })}
                          placeholder="MM/YY"
                          maxLength={5}
                          className="h-11"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="cvv">{t('checkout.cvv')} *</Label>
                        <Input
                          id="cvv"
                          value={cardInfo.cvv}
                          onChange={(e) => setCardInfo({ ...cardInfo, cvv: e.target.value })}
                          placeholder="123"
                          maxLength={4}
                          type="password"
                          className="h-11"
                        />
                      </div>
                    </div>
                    <div className="flex items-start gap-2 p-3 bg-muted/50 rounded-lg">
                      <Shield className="w-5 h-5 text-green-600 mt-0.5" />
                      <p className="text-xs text-muted-foreground">
                        Your payment information is encrypted and secure. We never store your card details.
                      </p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          {/* Order Review */}
          {step === 'review' && (
            <div className="space-y-6">
              <Card>
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                      <Truck className="w-5 h-5 text-primary" />
                    </div>
                    {t('checkout.shippingAddress')}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2 p-4 bg-muted/30 rounded-lg">
                    <p className="font-semibold text-lg">{shippingInfo.fullName}</p>
                    <div className="text-sm space-y-1 text-muted-foreground">
                      <p>{shippingInfo.address}</p>
                      <p>{shippingInfo.city}, {shippingInfo.state} {shippingInfo.zipCode}</p>
                      <p>{shippingInfo.country}</p>
                    </div>
                    <Separator className="my-3" />
                    <div className="text-sm space-y-1">
                      <p className="flex items-center gap-2">
                        <span className="text-muted-foreground">Phone:</span>
                        <span className="font-medium">{shippingInfo.phone}</span>
                      </p>
                      <p className="flex items-center gap-2">
                        <span className="text-muted-foreground">Email:</span>
                        <span className="font-medium">{shippingInfo.email}</span>
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                      <CreditCard className="w-5 h-5 text-primary" />
                    </div>
                    {t('checkout.paymentMethod')}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="p-4 bg-muted/30 rounded-lg">
                    {paymentMethod === 'card' ? (
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center">
                          <CreditCard className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                          <p className="font-medium">{t('checkout.creditCard')}</p>
                          <p className="text-sm text-muted-foreground">
                            •••• •••• •••• {cardInfo.cardNumber.slice(-4)}
                          </p>
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center">
                          <Truck className="w-6 h-6 text-green-600" />
                        </div>
                        <div>
                          <p className="font-medium">{t('checkout.cashOnDelivery')}</p>
                          <p className="text-sm text-muted-foreground">
                            Pay when you receive your order
                          </p>
                        </div>
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>

              <div className="p-4 bg-blue-50 dark:bg-blue-950/20 border border-blue-200 dark:border-blue-900 rounded-lg">
                <div className="flex gap-3">
                  <Shield className="w-5 h-5 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
                  <div className="text-sm">
                    <p className="font-medium text-blue-900 dark:text-blue-100 mb-1">
                      Ready to place your order?
                    </p>
                    <p className="text-blue-700 dark:text-blue-300">
                      Review your information above and click the button to complete your purchase.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Order Summary - Sidebar */}
        <div className={`lg:sticky lg:top-4 h-fit ${isRTL ? 'lg:flex-1' : ''}`}>
          <Card className="shadow-lg">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                  <Shield className="w-4 h-4 text-primary" />
                </div>
                {t('checkout.orderSummary')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Cart Items */}
              <ScrollArea className="max-h-72 pr-3">
                <div className="space-y-4">
                  {cartItems?.map((item, index) => (
                    <div key={index} className="flex gap-4 pb-3 border-b last:border-0">
                      <div className="relative">
                        <img
                          src={item.product.image}
                          alt={item.product.name}
                          className="w-20 h-20 object-contain rounded-lg border bg-muted/20"
                        />
                        <div className="absolute -top-2 -right-2 w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center">
                          {item.quantity}
                        </div>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium line-clamp-2 mb-1">{item.product.name}</p>
                        <p className="text-xs text-muted-foreground mb-2">{item.product.brand}</p>
                        <p className="font-medium text-primary">
                          ${(item.product.price * item.quantity).toFixed(2)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </ScrollArea>

              {/* Price Breakdown */}
              <div className="space-y-3 pt-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">{t('checkout.subtotal')}</span>
                  <span className="font-medium">${subtotal.toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">{t('checkout.shipping')}</span>
                  <span className="font-medium">
                    {shipping === 0 ? (
                      <span className="text-green-600">{t('checkout.free')}</span>
                    ) : (
                      `$${shipping.toFixed(2)}`
                    )}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">{t('checkout.tax')} (VAT 15%)</span>
                  <span className="font-medium">${tax.toFixed(2)}</span>
                </div>
                
                <Separator className="my-3" />
                
                <div className="flex justify-between items-center">
                  <span className="font-semibold">{t('checkout.total')}</span>
                  <span className="text-2xl font-bold text-primary">${total.toFixed(2)}</span>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="space-y-3 pt-2">
                <Button className="w-full h-12" size="lg" onClick={handlePlaceOrder}>
                  <Shield className="w-4 h-4 mr-2" />
                  {step === 'review' ? t('checkout.placeOrder') : t('common.continue')}
                </Button>

                {step !== 'shipping' && (
                  <Button 
                    variant="outline" 
                    className="w-full"
                    onClick={() => setStep(step === 'review' ? 'payment' : 'shipping')}
                  >
                    <ArrowLeft className="w-4 h-4 mr-2" />
                    {t('common.back')}
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
      </div>
    </div>
  );
}