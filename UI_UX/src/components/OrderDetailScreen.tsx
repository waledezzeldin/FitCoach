import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Separator } from './ui/separator';
import { ScrollArea } from './ui/scroll-area';
import { ArrowLeft, Package, Truck, CheckCircle, MapPin, Phone, Mail } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface OrderItem {
  product: {
    id: string;
    name: string;
    brand: string;
    price: number;
    image: string;
  };
  quantity: number;
}

interface OrderDetailScreenProps {
  orderId: string;
  orderDate: Date;
  status: 'processing' | 'shipped' | 'delivered' | 'cancelled';
  items: OrderItem[];
  subtotal: number;
  shipping: number;
  tax: number;
  total: number;
  shippingAddress: {
    fullName: string;
    address: string;
    city: string;
    state: string;
    zipCode: string;
    phone: string;
  };
  trackingNumber?: string;
  estimatedDelivery?: Date;
  onBack: () => void;
  onTrackShipment?: () => void;
  onCancelOrder?: () => void;
}

export function OrderDetailScreen({
  orderId,
  orderDate,
  status,
  items,
  subtotal,
  shipping,
  tax,
  total,
  shippingAddress,
  trackingNumber,
  estimatedDelivery,
  onBack,
  onTrackShipment,
  onCancelOrder
}: OrderDetailScreenProps) {
  const { t } = useLanguage();

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'processing': return 'bg-blue-100 text-blue-800';
      case 'shipped': return 'bg-purple-100 text-purple-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'processing': return <Package className="w-5 h-5" />;
      case 'shipped': return <Truck className="w-5 h-5" />;
      case 'delivered': return <CheckCircle className="w-5 h-5" />;
      default: return <Package className="w-5 h-5" />;
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
            <h1 className="text-xl">{t('orders.orderDetails')}</h1>
            <p className="text-sm text-white/80">{orderId}</p>
          </div>
        </div>
      </div>

      <ScrollArea className="h-[calc(100vh-80px)]">
        <div className="p-4 space-y-4">
          {/* Order Status */}
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <p className="text-sm text-muted-foreground">{t('orders.orderDate')}</p>
                  <p className="font-medium">{orderDate.toLocaleDateString()}</p>
                </div>
                <Badge className={getStatusColor(status)}>
                  {getStatusIcon(status)}
                  <span className="ml-2">{t(`orders.status.${status}`)}</span>
                </Badge>
              </div>

              {/* Timeline */}
              <div className="space-y-4">
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    status !== 'cancelled' ? 'bg-green-100' : 'bg-gray-100'
                  }`}>
                    <CheckCircle className={`w-5 h-5 ${status !== 'cancelled' ? 'text-green-600' : 'text-gray-400'}`} />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{t('orders.orderPlaced')}</p>
                    <p className="text-sm text-muted-foreground">{orderDate.toLocaleString()}</p>
                  </div>
                </div>

                <div className="ml-5 w-0.5 h-8 bg-gray-200" />

                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    status === 'shipped' || status === 'delivered' ? 'bg-green-100' : 'bg-gray-100'
                  }`}>
                    <Truck className={`w-5 h-5 ${status === 'shipped' || status === 'delivered' ? 'text-green-600' : 'text-gray-400'}`} />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{t('orders.shipped')}</p>
                    {trackingNumber && (
                      <p className="text-sm text-muted-foreground">
                        {t('orders.tracking')}: {trackingNumber}
                      </p>
                    )}
                  </div>
                </div>

                {status !== 'cancelled' && (
                  <>
                    <div className="ml-5 w-0.5 h-8 bg-gray-200" />

                    <div className="flex items-start gap-4">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                        status === 'delivered' ? 'bg-green-100' : 'bg-gray-100'
                      }`}>
                        <CheckCircle className={`w-5 h-5 ${status === 'delivered' ? 'text-green-600' : 'text-gray-400'}`} />
                      </div>
                      <div className="flex-1">
                        <p className="font-medium">{t('orders.delivered')}</p>
                        {estimatedDelivery && (
                          <p className="text-sm text-muted-foreground">
                            {status === 'delivered' ? t('orders.deliveredOn') : t('orders.estimatedDelivery')}: {estimatedDelivery.toLocaleDateString()}
                          </p>
                        )}
                      </div>
                    </div>
                  </>
                )}
              </div>

              {/* Actions */}
              {status !== 'cancelled' && status !== 'delivered' && (
                <div className="flex gap-2 mt-6">
                  {trackingNumber && onTrackShipment && (
                    <Button variant="outline" onClick={onTrackShipment}>
                      <Truck className="w-4 h-4 mr-2" />
                      {t('orders.trackShipment')}
                    </Button>
                  )}
                  {status === 'processing' && onCancelOrder && (
                    <Button variant="outline" onClick={onCancelOrder}>
                      {t('orders.cancelOrder')}
                    </Button>
                  )}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Order Items */}
          <Card>
            <CardHeader>
              <CardTitle>{t('orders.items')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {items.map((item, index) => (
                <div key={index} className="flex gap-4 pb-3 border-b last:border-0 last:pb-0">
                  <img
                    src={item.product.image}
                    alt={item.product.name}
                    className="w-20 h-20 object-contain rounded"
                  />
                  <div className="flex-1">
                    <h4 className="font-medium">{item.product.name}</h4>
                    <p className="text-sm text-muted-foreground">{item.product.brand}</p>
                    <p className="text-sm mt-1">
                      {t('orders.quantity')}: {item.quantity}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium">${(item.product.price * item.quantity).toFixed(2)}</p>
                    <p className="text-sm text-muted-foreground">
                      ${item.product.price.toFixed(2)} {t('orders.each')}
                    </p>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Order Summary */}
          <Card>
            <CardHeader>
              <CardTitle>{t('orders.summary')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>{t('checkout.subtotal')}</span>
                <span>${subtotal.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>{t('checkout.shipping')}</span>
                <span>{shipping === 0 ? t('checkout.free') : `$${shipping.toFixed(2)}`}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>{t('checkout.tax')}</span>
                <span>${tax.toFixed(2)}</span>
              </div>
              <Separator />
              <div className="flex justify-between font-bold text-lg">
                <span>{t('checkout.total')}</span>
                <span className="text-primary">${total.toFixed(2)}</span>
              </div>
            </CardContent>
          </Card>

          {/* Shipping Address */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="w-5 h-5" />
                {t('checkout.shippingAddress')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <p className="font-medium">{shippingAddress.fullName}</p>
              <p className="text-sm text-muted-foreground">{shippingAddress.address}</p>
              <p className="text-sm text-muted-foreground">
                {shippingAddress.city}, {shippingAddress.state} {shippingAddress.zipCode}
              </p>
              <div className="flex items-center gap-2 text-sm text-muted-foreground pt-2">
                <Phone className="w-4 h-4" />
                <span>{shippingAddress.phone}</span>
              </div>
            </CardContent>
          </Card>
        </div>
      </ScrollArea>
    </div>
  );
}
