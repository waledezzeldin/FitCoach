import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Avatar, AvatarFallback } from './ui/avatar';
import { ScrollArea } from './ui/scroll-area';
import { Separator } from './ui/separator';
import { Progress } from './ui/progress';
import { 
  ArrowLeft, 
  Star, 
  Heart, 
  Share2, 
  Plus, 
  Minus, 
  ShoppingCart,
  Shield,
  Truck,
  CheckCircle,
  RefreshCw
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

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
  longDescription: string;
  inStock: boolean;
  stockCount: number;
  isPopular?: boolean;
  discount?: number;
  features: string[];
  nutritionFacts?: {
    servingSize: string;
    servingsPerContainer: number;
    calories: number;
    protein: number;
    carbs: number;
    fats: number;
  };
}

interface Review {
  id: string;
  userName: string;
  rating: number;
  date: Date;
  comment: string;
  verified: boolean;
}

interface ProductDetailScreenProps {
  product: Product;
  onBack: () => void;
  onAddToCart: (product: Product, quantity: number) => void;
}

export function ProductDetailScreen({ product, onBack, onAddToCart }: ProductDetailScreenProps) {
  const { t, isRTL } = useLanguage();
  const [quantity, setQuantity] = useState(1);
  const [activeTab, setActiveTab] = useState('description');
  const [isFavorite, setIsFavorite] = useState(false);

  // Demo reviews
  const reviews: Review[] = [
    {
      id: '1',
      userName: 'Ahmed M.',
      rating: 5,
      date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      comment: 'Excellent product! Results visible within 2 weeks. Highly recommend.',
      verified: true
    },
    {
      id: '2',
      userName: 'Sara K.',
      rating: 4,
      date: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000),
      comment: 'Good quality, mixes well. Taste could be better but overall satisfied.',
      verified: true
    },
    {
      id: '3',
      userName: 'Omar H.',
      rating: 5,
      date: new Date(Date.now() - 21 * 24 * 60 * 60 * 1000),
      comment: 'Best protein I\'ve tried! Great value for money.',
      verified: false
    }
  ];

  // Related products
  const relatedProducts = [
    {
      id: '2',
      name: 'BCAA Recovery',
      brand: 'FitNutrition',
      price: 39.99,
      rating: 4.7,
      image: '/api/placeholder/150/150'
    },
    {
      id: '3',
      name: 'Pre-Workout Boost',
      brand: 'FitNutrition',
      price: 44.99,
      rating: 4.6,
      image: '/api/placeholder/150/150'
    }
  ];

  const handleAddToCart = () => {
    onAddToCart(product, quantity);
    toast.success(t('store.addedToCart', { name: product.name, quantity }));
  };

  const handleIncrement = () => {
    if (quantity < product.stockCount) {
      setQuantity(q => q + 1);
    }
  };

  const handleDecrement = () => {
    if (quantity > 1) {
      setQuantity(q => q - 1);
    }
  };

  const toggleFavorite = () => {
    setIsFavorite(!isFavorite);
    toast.success(isFavorite ? t('store.removedFromFavorites') : t('store.addedToFavorites'));
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        className={`w-4 h-4 ${
          i < Math.floor(rating) ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'
        }`}
      />
    ));
  };

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.4
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
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
            <h1 className="text-xl">{t('store.productDetails')}</h1>
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => toast.success(t('store.linkCopied'))}
            className="text-white hover:bg-white/20"
          >
            <Share2 className="w-5 h-5" />
          </Button>
        </div>
      </div>

      <ScrollArea className="h-[calc(100vh-60px)]">
        <div className="p-4 space-y-4">
          {/* Product Image & Basic Info */}
          <Card>
            <CardContent className="p-6">
              <div className="flex flex-col md:flex-row gap-6">
                {/* Image */}
                <div className="flex-shrink-0">
                  <div className="relative">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full md:w-64 h-64 object-contain rounded-lg"
                    />
                    {product.discount && (
                      <Badge className="absolute top-2 right-2 bg-red-500">
                        -{product.discount}%
                      </Badge>
                    )}
                    <Button
                      variant="ghost"
                      size="icon"
                      className="absolute top-2 left-2"
                      onClick={toggleFavorite}
                    >
                      <Heart className={`w-5 h-5 ${isFavorite ? 'fill-red-500 text-red-500' : ''}`} />
                    </Button>
                  </div>
                </div>

                {/* Info */}
                <div className="flex-1 space-y-4">
                  <div>
                    <p className="text-sm text-muted-foreground">{product.brand}</p>
                    <h2 className="text-2xl font-bold">{product.name}</h2>
                    {product.isPopular && (
                      <Badge variant="secondary" className="mt-2">
                        {t('store.popular')}
                      </Badge>
                    )}
                  </div>

                  {/* Rating */}
                  <div className="flex items-center gap-2">
                    <div className="flex">{renderStars(product.rating)}</div>
                    <span className="font-medium">{product.rating}</span>
                    <span className="text-muted-foreground">
                      ({product.reviewCount} {t('store.reviews')})
                    </span>
                  </div>

                  {/* Price */}
                  <div className="flex items-baseline gap-2">
                    <span className="text-3xl font-bold text-primary">
                      ${product.price.toFixed(2)}
                    </span>
                    {product.originalPrice && (
                      <span className="text-lg text-muted-foreground line-through">
                        ${product.originalPrice.toFixed(2)}
                      </span>
                    )}
                  </div>

                  {/* Stock Status */}
                  <div>
                    {product.inStock ? (
                      <p className="text-green-600 font-medium">
                        {t('store.inStock')} ({product.stockCount} {t('store.available')})
                      </p>
                    ) : (
                      <p className="text-red-600 font-medium">{t('store.outOfStock')}</p>
                    )}
                  </div>

                  {/* Quantity Selector */}
                  <div className="flex items-center gap-4">
                    <span className="font-medium">{t('store.quantity')}:</span>
                    <div className="flex items-center gap-2">
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={handleDecrement}
                        disabled={quantity <= 1}
                      >
                        <Minus className="w-4 h-4" />
                      </Button>
                      <span className="w-12 text-center font-medium">{quantity}</span>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={handleIncrement}
                        disabled={quantity >= product.stockCount}
                      >
                        <Plus className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>

                  {/* Add to Cart Button */}
                  <Button
                    className="w-full"
                    size="lg"
                    onClick={handleAddToCart}
                    disabled={!product.inStock}
                  >
                    <ShoppingCart className="w-5 h-5 mr-2" />
                    {t('store.addToCart')}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Features */}
          <Card>
            <CardHeader>
              <CardTitle>{t('store.features')}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-3">
                {product.features.map((feature, index) => (
                  <div key={index} className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-primary mt-2" />
                    <p className="flex-1">{feature}</p>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Tabs */}
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="description">{t('store.description')}</TabsTrigger>
              <TabsTrigger value="nutrition">{t('store.nutrition')}</TabsTrigger>
              <TabsTrigger value="reviews">{t('store.reviews')}</TabsTrigger>
            </TabsList>

            <TabsContent value="description" className="mt-4">
              <Card>
                <CardContent className="p-6">
                  <p className="text-muted-foreground leading-relaxed">
                    {product.longDescription}
                  </p>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="nutrition" className="mt-4">
              <Card>
                <CardContent className="p-6">
                  {product.nutritionFacts ? (
                    <div className="space-y-3">
                      <div className="grid grid-cols-2 gap-4 pb-3 border-b">
                        <div>
                          <p className="text-sm text-muted-foreground">{t('store.servingSize')}</p>
                          <p className="font-medium">{product.nutritionFacts.servingSize}</p>
                        </div>
                        <div>
                          <p className="text-sm text-muted-foreground">{t('store.servingsPerContainer')}</p>
                          <p className="font-medium">{product.nutritionFacts.servingsPerContainer}</p>
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <div className="flex justify-between">
                          <span>{t('nutrition.calories')}</span>
                          <span className="font-medium">{product.nutritionFacts.calories}</span>
                        </div>
                        <div className="flex justify-between">
                          <span>{t('nutrition.protein')}</span>
                          <span className="font-medium">{product.nutritionFacts.protein}g</span>
                        </div>
                        <div className="flex justify-between">
                          <span>{t('nutrition.carbs')}</span>
                          <span className="font-medium">{product.nutritionFacts.carbs}g</span>
                        </div>
                        <div className="flex justify-between">
                          <span>{t('nutrition.fats')}</span>
                          <span className="font-medium">{product.nutritionFacts.fats}g</span>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <p className="text-muted-foreground">{t('store.noNutritionInfo')}</p>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="reviews" className="mt-4 space-y-3">
              {/* Rating Overview */}
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center gap-6">
                    <div className="text-center">
                      <div className="text-4xl font-bold">{product.rating}</div>
                      <div className="flex mt-2">{renderStars(product.rating)}</div>
                      <p className="text-sm text-muted-foreground mt-1">
                        {product.reviewCount} {t('store.reviews')}
                      </p>
                    </div>
                    
                    <div className="flex-1 space-y-2">
                      {[5, 4, 3, 2, 1].map(stars => (
                        <div key={stars} className="flex items-center gap-2">
                          <span className="text-sm w-8">{stars} ★</span>
                          <Progress value={stars === 5 ? 70 : stars === 4 ? 20 : 10} className="flex-1" />
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Individual Reviews */}
              {reviews.map(review => (
                <Card key={review.id}>
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-medium">{review.userName}</span>
                          {review.verified && (
                            <Badge variant="secondary" className="text-xs">
                              {t('store.verifiedPurchase')}
                            </Badge>
                          )}
                        </div>
                        <div className="flex mt-1">{renderStars(review.rating)}</div>
                      </div>
                      <span className="text-sm text-muted-foreground">
                        {review.date.toLocaleDateString()}
                      </span>
                    </div>
                    <p className="text-muted-foreground">{review.comment}</p>
                  </CardContent>
                </Card>
              ))}
            </TabsContent>
          </Tabs>

          {/* Shipping & Returns */}
          <Card>
            <CardContent className="p-6">
              <div className="grid md:grid-cols-3 gap-6">
                <div className="flex items-start gap-3">
                  <Truck className="w-5 h-5 text-primary mt-0.5" />
                  <div>
                    <h4 className="font-medium mb-1">{t('store.freeShipping')}</h4>
                    <p className="text-sm text-muted-foreground">{t('store.freeShippingDesc')}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <RefreshCw className="w-5 h-5 text-primary mt-0.5" />
                  <div>
                    <h4 className="font-medium mb-1">{t('store.easyReturns')}</h4>
                    <p className="text-sm text-muted-foreground">{t('store.easyReturnsDesc')}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <Shield className="w-5 h-5 text-primary mt-0.5" />
                  <div>
                    <h4 className="font-medium mb-1">{t('store.securePayment')}</h4>
                    <p className="text-sm text-muted-foreground">{t('store.securePaymentDesc')}</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Related Products */}
          <Card>
            <CardHeader>
              <CardTitle>{t('store.relatedProducts')}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {relatedProducts.map(relatedProduct => (
                  <Card key={relatedProduct.id} className="cursor-pointer hover:shadow-lg transition-shadow">
                    <CardContent className="p-3">
                      <img
                        src={relatedProduct.image}
                        alt={relatedProduct.name}
                        className="w-full h-32 object-contain mb-2"
                      />
                      <p className="text-xs text-muted-foreground">{relatedProduct.brand}</p>
                      <h4 className="font-medium text-sm mb-1">{relatedProduct.name}</h4>
                      <div className="flex items-center gap-1 mb-1">
                        <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                        <span className="text-xs">{relatedProduct.rating}</span>
                      </div>
                      <p className="font-bold text-primary">${relatedProduct.price}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </ScrollArea>
      </div>
    </div>
  );
}