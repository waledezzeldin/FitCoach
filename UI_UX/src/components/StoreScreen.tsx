import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  ArrowLeft, 
  Search, 
  ShoppingCart, 
  Plus, 
  Minus, 
  Star,
  Package,
  Truck,
  Clock
} from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { CheckoutScreen } from './CheckoutScreen';
import { ProductDetailScreen } from './ProductDetailScreen';
import { OrderDetailScreen } from './OrderDetailScreen';
import { OrderConfirmationScreen } from './OrderConfirmationScreen';
import { toast } from 'sonner@2.0.3';
import { StoreIntroScreen } from './StoreIntroScreen';

interface StoreScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'workout' | 'nutrition' | 'coach' | 'account') => void;
  isDemoMode: boolean;
}

interface Product {
  id: string;
  name: string;
  brand: string;
  price: number;
  originalPrice?: number;
  rating: number;
  reviewCount: number;
  image: string;
  category: string;
  description: string;
  inStock: boolean;
  isPopular?: boolean;
  discount?: number;
}

interface CartItem {
  product: Product;
  quantity: number;
}

interface Order {
  id: string;
  date: Date;
  status: 'processing' | 'shipped' | 'delivered';
  total: number;
  items: CartItem[];
}

export function StoreScreen({ userProfile, onNavigate, isDemoMode }: StoreScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('products');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedProduct, setSelectedProduct] = useState<string | null>(null);
  const [selectedOrder, setSelectedOrder] = useState<string | null>(null);
  const [showCheckout, setShowCheckout] = useState(false);
  const [orderConfirmationId, setOrderConfirmationId] = useState<string | null>(null);
  const [lastOrderTotal, setLastOrderTotal] = useState<number>(0);
  
  // Show intro screen on first usage
  const [showIntro, setShowIntro] = React.useState(() => {
    const hasSeenIntro = localStorage.getItem('store_intro_seen');
    return !hasSeenIntro;
  });
  
  const [cart, setCart] = useState<CartItem[]>(isDemoMode ? [
    {
      product: {
        id: '1',
        name: 'Whey Protein Isolate',
        brand: 'FitNutrition',
        price: 59.99,
        originalPrice: 69.99,
        rating: 4.8,
        reviewCount: 1247,
        image: '/api/placeholder/200/200',
        category: 'Protein',
        description: 'Premium whey protein isolate for muscle building and recovery.',
        inStock: true,
        isPopular: true,
        discount: 15
      },
      quantity: 1
    }
  ] : []);

  // Demo products
  const products: Product[] = [
    {
      id: '1',
      name: 'Whey Protein Isolate',
      brand: 'FitNutrition',
      price: 59.99,
      originalPrice: 69.99,
      rating: 4.8,
      reviewCount: 1247,
      image: '/api/placeholder/200/200',
      category: 'Protein',
      description: 'Premium whey protein isolate for muscle building and recovery.',
      inStock: true,
      isPopular: true,
      discount: 15
    },
    {
      id: '2',
      name: 'Creatine Monohydrate',
      brand: 'PowerSupps',
      price: 29.99,
      rating: 4.9,
      reviewCount: 892,
      image: '/api/placeholder/200/200',
      category: 'Pre-Workout',
      description: 'Pure creatine monohydrate for increased strength and power.',
      inStock: true,
    },
    {
      id: '3',
      name: 'BCAA Recovery',
      brand: 'RecoverMax',
      price: 39.99,
      rating: 4.6,
      reviewCount: 654,
      image: '/api/placeholder/200/200',
      category: 'Recovery',
      description: 'Branch-chain amino acids for faster muscle recovery.',
      inStock: true,
    },
    {
      id: '4',
      name: 'Pre-Workout Boost',
      brand: 'EnergyCore',
      price: 44.99,
      originalPrice: 49.99,
      rating: 4.7,
      reviewCount: 423,
      image: '/api/placeholder/200/200',
      category: 'Pre-Workout',
      description: 'High-energy formula to maximize your workout performance.',
      inStock: false,
      discount: 10
    },
    {
      id: '5',
      name: 'Multivitamin Complex',
      brand: 'VitalHealth',
      price: 24.99,
      rating: 4.5,
      reviewCount: 332,
      image: '/api/placeholder/200/200',
      category: 'Vitamins',
      description: 'Complete daily vitamin and mineral support.',
      inStock: true,
    },
    {
      id: '6',
      name: 'Fat Burner Pro',
      brand: 'LeanLife',
      price: 49.99,
      rating: 4.3,
      reviewCount: 267,
      image: '/api/placeholder/200/200',
      category: 'Fat Burners',
      description: 'Advanced thermogenic formula for weight management.',
      inStock: true,
    },
  ];

  // Demo orders
  const orders: Order[] = isDemoMode ? [
    {
      id: 'ORD-2024-001',
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      status: 'delivered',
      total: 89.98,
      items: [
        { product: products[0], quantity: 1 },
        { product: products[1], quantity: 1 },
      ]
    },
    {
      id: 'ORD-2024-002',
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      status: 'shipped',
      total: 39.99,
      items: [
        { product: products[2], quantity: 1 },
      ]
    },
  ] : [];

  const categories = ['all', 'Protein', 'Pre-Workout', 'Recovery', 'Vitamins', 'Fat Burners'];

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         product.brand.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || product.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const addToCart = (product: Product) => {
    setCart(prev => {
      const existingItem = prev.find(item => item.product.id === product.id);
      if (existingItem) {
        return prev.map(item =>
          item.product.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      }
      return [...prev, { product, quantity: 1 }];
    });
  };

  const updateQuantity = (productId: string, newQuantity: number) => {
    if (newQuantity === 0) {
      setCart(prev => prev.filter(item => item.product.id !== productId));
    } else {
      setCart(prev =>
        prev.map(item =>
          item.product.id === productId
            ? { ...item, quantity: newQuantity }
            : item
        )
      );
    }
  };

  const cartTotal = cart.reduce((total, item) => total + item.product.price * item.quantity, 0);
  const cartItemCount = cart.reduce((total, item) => total + item.quantity, 0);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'processing': return 'text-yellow-600';
      case 'shipped': return 'text-blue-600';
      case 'delivered': return 'text-green-600';
      default: return 'text-muted-foreground';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'processing': return <Clock className="w-4 h-4" />;
      case 'shipped': return <Truck className="w-4 h-4" />;
      case 'delivered': return <Package className="w-4 h-4" />;
      default: return <Clock className="w-4 h-4" />;
    }
  };

  // Show Order Confirmation
  if (orderConfirmationId) {
    const estimatedDelivery = new Date();
    estimatedDelivery.setDate(estimatedDelivery.getDate() + 7); // 7 days from now
    
    return (
      <OrderConfirmationScreen
        orderId={orderConfirmationId}
        orderTotal={lastOrderTotal}
        estimatedDelivery={estimatedDelivery}
        onViewOrder={() => {
          setOrderConfirmationId(null);
          setActiveTab('orders');
        }}
        onContinueShopping={() => {
          setOrderConfirmationId(null);
          setActiveTab('products');
        }}
        onGoHome={() => {
          setOrderConfirmationId(null);
          onNavigate('home');
        }}
      />
    );
  }

  // Show Checkout
  if (showCheckout) {
    return (
      <CheckoutScreen
        cartItems={cart}
        onBack={() => setShowCheckout(false)}
        onOrderComplete={(orderId) => {
          setShowCheckout(false);
          setLastOrderTotal(cartTotal);
          setOrderConfirmationId(orderId);
          setCart([]);
        }}
      />
    );
  }

  // Show Product Detail
  if (selectedProduct) {
    const product = products.find(p => p.id === selectedProduct);
    if (product) {
      return (
        <ProductDetailScreen
          product={{
            ...product,
            stockCount: 50,
            features: ['High Quality', 'Fast Shipping', 'Money Back Guarantee'],
            specifications: { Weight: '2 lbs', Servings: '30' }
          }}
          userProfile={userProfile}
          onBack={() => setSelectedProduct(null)}
          onAddToCart={(prod, qty) => {
            // Add to cart with quantity
            const existing = cart.find(item => item.product.id === prod.id);
            if (existing) {
              setCart(cart.map(item => 
                item.product.id === prod.id 
                  ? { ...item, quantity: item.quantity + qty }
                  : item
              ));
            } else {
              setCart([...cart, { product: prod, quantity: qty }]);
            }
            toast.success(`${prod.name} added to cart`);
            setSelectedProduct(null);
          }}
        />
      );
    }
  }

  // Show Order Detail
  if (selectedOrder) {
    const order = orders.find(o => o.id === selectedOrder);
    if (order) {
      return (
        <OrderDetailScreen
          order={{
            ...order,
            trackingNumber: order.status !== 'processing' ? `TRK-${order.id}` : undefined,
            shippingAddress: {
              street: '123 Main St',
              city: 'Riyadh',
              state: 'Riyadh Province',
              zipCode: '12345',
              country: 'Saudi Arabia'
            },
            paymentMethod: 'Credit Card ending in 4242'
          }}
          onBack={() => setSelectedOrder(null)}
          onTrackShipment={() => toast.info(`Tracking: TRK-${order.id}`)}
          onCancelOrder={order.status === 'processing' ? () => {
            toast.success('Order cancelled');
            setSelectedOrder(null);
          } : undefined}
        />
      );
    }
  }
  
  // Show intro screen on first visit
  if (showIntro) {
    return (
      <StoreIntroScreen
        onGetStarted={() => {
          setShowIntro(false);
          localStorage.setItem('store_intro_seen', 'true');
        }}
      />
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1736236560164-bc741c70bca5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-amber-600 to-orange-700 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={() => onNavigate('home')}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('store.title')}</h1>
            <p className="text-white/80">{t('store.subtitle')}</p>
          </div>
          <Button 
            variant="ghost" 
            size="icon"
            className="text-white hover:bg-white/20 relative"
          >
            <ShoppingCart className="w-5 h-5" />
            {cartItemCount > 0 && (
              <Badge 
                variant="destructive" 
                className="absolute -top-2 -right-2 w-5 h-5 p-0 flex items-center justify-center text-xs"
              >
                {cartItemCount}
              </Badge>
            )}
          </Button>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-white/60" />
          <Input
            placeholder={t('store.searchPlaceholder')}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 bg-white/10 border-white/20 text-white placeholder:text-white/60"
          />
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="products">{t('store.products')}</TabsTrigger>
            <TabsTrigger value="cart" className="relative">
              {t('store.cart')}
              {cartItemCount > 0 && (
                <Badge 
                  variant="destructive" 
                  className="absolute -top-2 -right-2 w-5 h-5 p-0 flex items-center justify-center text-xs"
                >
                  {cartItemCount}
                </Badge>
              )}
            </TabsTrigger>
            <TabsTrigger value="orders">{t('store.orders')}</TabsTrigger>
          </TabsList>

          <TabsContent value="products" className="mt-4 space-y-4">
            {/* Categories */}
            <div className="flex gap-2 overflow-x-auto pb-2">
              {categories.map((category) => (
                <Button
                  key={category}
                  variant={selectedCategory === category ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setSelectedCategory(category)}
                  className="whitespace-nowrap"
                >
                  {category === 'all' ? t('store.all') : category}
                </Button>
              ))}
            </div>

            {/* Products Grid */}
            <div className="grid grid-cols-2 gap-4">
              {filteredProducts.map((product) => (
                <Card 
                  key={product.id} 
                  className="overflow-hidden cursor-pointer hover:shadow-lg transition-shadow"
                  onClick={() => setSelectedProduct(product.id)}
                >
                  <CardContent className="p-0">
                    <div className="aspect-square bg-muted relative">
                      {product.discount && (
                        <Badge 
                          variant="destructive" 
                          className="absolute top-2 left-2 z-10"
                        >
                          -{product.discount}%
                        </Badge>
                      )}
                      {product.isPopular && (
                        <Badge 
                          variant="secondary" 
                          className="absolute top-2 right-2 z-10 bg-orange-100 text-orange-800"
                        >
                          {t('store.popular')}
                        </Badge>
                      )}
                      <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                        <Package className="w-12 h-12" />
                      </div>
                    </div>
                    <div className="p-3 space-y-2">
                      <div>
                        <p className="text-xs text-muted-foreground">{product.brand}</p>
                        <h3 className="text-sm font-medium line-clamp-2">{product.name}</h3>
                      </div>
                      
                      <div className="flex items-center gap-1 text-xs">
                        <Star className="w-3 h-3 fill-current text-yellow-500" />
                        <span>{product.rating}</span>
                        <span className="text-muted-foreground">({product.reviewCount})</span>
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-semibold">${product.price}</span>
                            {product.originalPrice && (
                              <span className="text-xs text-muted-foreground line-through">
                                ${product.originalPrice}
                              </span>
                            )}
                          </div>
                        </div>
                      </div>

                      <Button 
                        size="sm" 
                        className="w-full"
                        disabled={!product.inStock}
                        onClick={(e) => {
                          e.stopPropagation();
                          addToCart(product);
                        }}
                      >
                        {product.inStock ? (
                          <>
                            <Plus className="w-3 h-3 mr-1" />
                            {t('store.addToCart')}
                          </>
                        ) : (
                          t('store.outOfStock')
                        )}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>

            {filteredProducts.length === 0 && (
              <div className="text-center py-12">
                <Package className="w-12 h-12 mx-auto mb-4 text-muted-foreground opacity-50" />
                <p className="text-muted-foreground">{t('store.noProductsFound')}</p>
                <p className="text-sm text-muted-foreground">{t('store.adjustSearch')}</p>
              </div>
            )}
          </TabsContent>

          <TabsContent value="cart" className="mt-4 space-y-4">
            {cart.length === 0 ? (
              <div className="text-center py-12">
                <ShoppingCart className="w-12 h-12 mx-auto mb-4 text-muted-foreground opacity-50" />
                <p className="text-muted-foreground">{t('store.cartEmpty')}</p>
                <p className="text-sm text-muted-foreground">{t('store.addProducts')}</p>
                <Button 
                  className="mt-4"
                  onClick={() => setActiveTab('products')}
                >
                  {t('store.browseProducts')}
                </Button>
              </div>
            ) : (
              <>
                <div className="space-y-3">
                  {cart.map((item) => (
                    <Card key={item.product.id}>
                      <CardContent className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="w-16 h-16 bg-muted rounded-lg flex items-center justify-center">
                            <Package className="w-6 h-6 text-muted-foreground" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <h3 className="font-medium truncate">{item.product.name}</h3>
                            <p className="text-sm text-muted-foreground">{item.product.brand}</p>
                            <p className="font-semibold">${item.product.price}</p>
                          </div>
                          <div className="flex items-center gap-2">
                            <Button 
                              variant="outline" 
                              size="icon"
                              className="w-8 h-8"
                              onClick={() => updateQuantity(item.product.id, item.quantity - 1)}
                            >
                              <Minus className="w-3 h-3" />
                            </Button>
                            <span className="w-8 text-center text-sm">{item.quantity}</span>
                            <Button 
                              variant="outline" 
                              size="icon"
                              className="w-8 h-8"
                              onClick={() => updateQuantity(item.product.id, item.quantity + 1)}
                            >
                              <Plus className="w-3 h-3" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>

                <Card>
                  <CardContent className="p-4">
                    <div className="space-y-2">
                      <div className="flex justify-between">
                        <span>{t('store.subtotal')}</span>
                        <span>${cartTotal.toFixed(2)}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>{t('store.shipping')}</span>
                        <span>{t('store.free')}</span>
                      </div>
                      <div className="border-t pt-2">
                        <div className="flex justify-between font-semibold">
                          <span>{t('store.total')}</span>
                          <span>${cartTotal.toFixed(2)}</span>
                        </div>
                      </div>
                    </div>
                    <Button 
                      className="w-full mt-4"
                      onClick={() => {
                        if (isDemoMode) {
                          toast.success(t('store.demoCheckout') || 'Demo: Creating order...');
                          const orderId = `ORDER-${Date.now()}`;
                          setOrderConfirmationId(orderId);
                          setCart([]);
                        } else {
                          setShowCheckout(true);
                        }
                      }}
                    >
                      {t('store.checkout')}
                    </Button>
                  </CardContent>
                </Card>
              </>
            )}
          </TabsContent>

          <TabsContent value="orders" className="mt-4 space-y-4">
            {orders.length === 0 ? (
              <div className="text-center py-12">
                <Package className="w-12 h-12 mx-auto mb-4 text-muted-foreground opacity-50" />
                <p className="text-muted-foreground">{t('store.noOrders')}</p>
                <p className="text-sm text-muted-foreground">{t('store.orderHistory')}</p>
              </div>
            ) : (
              <div className="space-y-4">
                {orders.map((order) => (
                  <Card 
                    key={order.id}
                    className="cursor-pointer hover:shadow-lg transition-shadow"
                    onClick={() => setSelectedOrder(order.id)}
                  >
                    <CardHeader className="pb-3">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-lg">{t('store.order')} {order.id}</CardTitle>
                        <Badge variant="outline" className={getStatusColor(order.status)}>
                          {getStatusIcon(order.status)}
                          <span className="ml-1 capitalize">{order.status}</span>
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {order.date.toLocaleDateString('en-US', { 
                          year: 'numeric', 
                          month: 'long', 
                          day: 'numeric' 
                        })}
                      </p>
                    </CardHeader>
                    <CardContent className="space-y-3">
                      {order.items.map((item, index) => (
                        <div key={index} className="flex items-center justify-between text-sm">
                          <div>
                            <span className="font-medium">{item.product.name}</span>
                            <span className="text-muted-foreground"> x{item.quantity}</span>
                          </div>
                          <span>${(item.product.price * item.quantity).toFixed(2)}</span>
                        </div>
                      ))}
                      <div className="border-t pt-3">
                        <div className="flex justify-between font-semibold">
                          <span>{t('store.total')}</span>
                          <span>${order.total.toFixed(2)}</span>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            )}
          </TabsContent>
        </Tabs>
      </div>
      </div>
    </div>
  );
}