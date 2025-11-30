import React, { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ScrollArea } from './ui/scroll-area';
import { Card, CardContent } from './ui/card';
import { Search, Apple, Beef, Wheat } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface FoodItem {
  id: string;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  serving: string;
}

interface FoodLoggingDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAddFood: (food: FoodItem) => void;
}

export function FoodLoggingDialog({
  open,
  onOpenChange,
  onAddFood
}: FoodLoggingDialogProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('search');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Custom food form
  const [customFood, setCustomFood] = useState({
    name: '',
    serving: '',
    calories: '',
    protein: '',
    carbs: '',
    fats: ''
  });

  // Common foods database
  const commonFoods: FoodItem[] = [
    {
      id: 'chicken_breast',
      name: t('foods.chickenBreast'),
      calories: 165,
      protein: 31,
      carbs: 0,
      fats: 3.6,
      serving: '100g'
    },
    {
      id: 'brown_rice',
      name: t('foods.brownRice'),
      calories: 112,
      protein: 2.6,
      carbs: 24,
      fats: 0.9,
      serving: '100g'
    },
    {
      id: 'eggs',
      name: t('foods.eggs'),
      calories: 155,
      protein: 13,
      carbs: 1.1,
      fats: 11,
      serving: '2 large'
    },
    {
      id: 'salmon',
      name: t('foods.salmon'),
      calories: 206,
      protein: 22,
      carbs: 0,
      fats: 13,
      serving: '100g'
    },
    {
      id: 'sweet_potato',
      name: t('foods.sweetPotato'),
      calories: 86,
      protein: 1.6,
      carbs: 20,
      fats: 0.1,
      serving: '100g'
    },
    {
      id: 'greek_yogurt',
      name: t('foods.greekYogurt'),
      calories: 59,
      protein: 10,
      carbs: 3.6,
      fats: 0.4,
      serving: '100g'
    },
    {
      id: 'oatmeal',
      name: t('foods.oatmeal'),
      calories: 68,
      protein: 2.4,
      carbs: 12,
      fats: 1.4,
      serving: '40g dry'
    },
    {
      id: 'banana',
      name: t('foods.banana'),
      calories: 89,
      protein: 1.1,
      carbs: 23,
      fats: 0.3,
      serving: '1 medium'
    }
  ];

  const filteredFoods = commonFoods.filter(food => 
    food.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAddCustomFood = () => {
    if (!customFood.name || !customFood.calories) return;

    const food: FoodItem = {
      id: `custom_${Date.now()}`,
      name: customFood.name,
      serving: customFood.serving || '1 serving',
      calories: parseFloat(customFood.calories),
      protein: parseFloat(customFood.protein) || 0,
      carbs: parseFloat(customFood.carbs) || 0,
      fats: parseFloat(customFood.fats) || 0,
    };
    
    onAddFood(food);
    onOpenChange(false);
    
    // Reset form
    setCustomFood({
      name: '',
      serving: '',
      calories: '',
      protein: '',
      carbs: '',
      fats: ''
    });
  };

  const handleAddCommonFood = (food: FoodItem) => {
    onAddFood(food);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>{t('nutrition.addFood')}</DialogTitle>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="search">{t('nutrition.searchFood')}</TabsTrigger>
            <TabsTrigger value="custom">{t('nutrition.customFood')}</TabsTrigger>
          </TabsList>

          <TabsContent value="search" className="space-y-3">
            <div className="relative">
              <Search className={`absolute ${isRTL ? 'right-3' : 'left-3'} top-3 w-4 h-4 text-muted-foreground`} />
              <Input
                placeholder={t('nutrition.searchPlaceholder')}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className={isRTL ? 'pr-9' : 'pl-9'}
              />
            </div>

            <ScrollArea className="h-64">
              <div className="space-y-2">
                {filteredFoods.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <p>{t('nutrition.noFoodsFound')}</p>
                    <p className="text-sm mt-1">{t('nutrition.tryCustomFood')}</p>
                  </div>
                ) : (
                  filteredFoods.map(food => (
                    <Card key={food.id} className="cursor-pointer hover:bg-accent transition-colors">
                      <CardContent className="p-3" onClick={() => handleAddCommonFood(food)}>
                        <div className={`flex items-start justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                          <div className="flex-1">
                            <div className="font-medium">{food.name}</div>
                            <div className="text-xs text-muted-foreground">
                              {food.serving} • {food.calories} {t('nutrition.cal')} • {food.protein}g {t('nutrition.protein')}
                            </div>
                          </div>
                          <Button size="sm" variant="ghost">
                            {t('common.add')}
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))
                )}
              </div>
            </ScrollArea>
          </TabsContent>

          <TabsContent value="custom" className="space-y-3">
            <div className="space-y-2">
              <Label>{t('nutrition.foodName')}</Label>
              <Input
                value={customFood.name}
                onChange={(e) => setCustomFood({...customFood, name: e.target.value})}
                placeholder={t('nutrition.foodNamePlaceholder')}
              />
            </div>

            <div className="space-y-2">
              <Label>{t('nutrition.servingSize')}</Label>
              <Input
                value={customFood.serving}
                onChange={(e) => setCustomFood({...customFood, serving: e.target.value})}
                placeholder={t('nutrition.servingSizePlaceholder')}
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label>{t('nutrition.calories')}</Label>
                <Input
                  type="number"
                  value={customFood.calories}
                  onChange={(e) => setCustomFood({...customFood, calories: e.target.value})}
                  placeholder="0"
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.protein')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.protein}
                  onChange={(e) => setCustomFood({...customFood, protein: e.target.value})}
                  placeholder="0"
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.carbs')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.carbs}
                  onChange={(e) => setCustomFood({...customFood, carbs: e.target.value})}
                  placeholder="0"
                />
              </div>
              <div className="space-y-2">
                <Label>{t('nutrition.fats')} (g)</Label>
                <Input
                  type="number"
                  value={customFood.fats}
                  onChange={(e) => setCustomFood({...customFood, fats: e.target.value})}
                  placeholder="0"
                />
              </div>
            </div>

            <Button
              className="w-full"
              onClick={handleAddCustomFood}
              disabled={!customFood.name || !customFood.calories}
            >
              {t('nutrition.addToMeal')}
            </Button>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
