import React from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { ShoppingBag, Package, Truck, Sparkles } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface StoreIntroScreenProps {
  onGetStarted: () => void;
}

export function StoreIntroScreen({ onGetStarted }: StoreIntroScreenProps) {
  const { t, isRTL } = useLanguage();

  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Full background image */}
      <div 
        className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1736236560164-bc741c70bca5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Gradient overlay */}
      <div className="absolute inset-0 z-1 bg-gradient-to-b from-black/60 via-black/50 to-black/70" />
      
      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col justify-end p-6 pb-8">
        <div className="space-y-6">
          {/* Title */}
          <div className="text-white space-y-2">
            <h1 className="text-4xl font-bold">FitCoach Store</h1>
            <p className="text-xl text-white/90">
              Premium fitness gear and supplements
            </p>
          </div>

          {/* Features */}
          <div className="space-y-3">
            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-orange-500/20 flex items-center justify-center">
                    <ShoppingBag className="w-6 h-6 text-orange-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">Curated Products</h3>
                    <p className="text-sm text-white/80">Handpicked fitness equipment & supplements</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center">
                    <Sparkles className="w-6 h-6 text-blue-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">Member Discounts</h3>
                    <p className="text-sm text-white/80">Exclusive deals for premium members</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardContent className="p-4">
                <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center">
                    <Truck className="w-6 h-6 text-green-300" />
                  </div>
                  <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                    <h3 className="font-semibold text-white">Fast Delivery</h3>
                    <p className="text-sm text-white/80">Quick shipping on all orders</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* CTA Button */}
          <Button 
            className="w-full bg-orange-600 hover:bg-orange-700 text-white h-14 text-lg"
            onClick={onGetStarted}
          >
            Start Shopping
          </Button>
        </div>
      </div>
    </div>
  );
}
