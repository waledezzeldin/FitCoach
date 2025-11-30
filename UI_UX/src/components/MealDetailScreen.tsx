import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ScrollArea } from './ui/scroll-area';
import { 
  ArrowLeft, 
  Clock, 
  Flame, 
  Plus, 
  Edit,
  Trash2,
  ChefHat 
} from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface FoodItem {
  id: string;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  serving: string;
  recipeId?: string;
}

interface Meal {
  id: string;
  name: string;
  time: string;
  foods: FoodItem[];
  totalCalories: number;
  totalProtein?: number;
  totalCarbs?: number;
  totalFats?: number;
}

interface MealDetailScreenProps {
  meal: Meal;
  onBack: () => void;
  onAddFood: () => void;
  onEditFood: (foodId: string) => void;
  onRemoveFood: (foodId: string) => void;
  onViewRecipe?: (recipeId: string) => void;
}

export function MealDetailScreen({
  meal,
  onBack,
  onAddFood,
  onEditFood,
  onRemoveFood,
  onViewRecipe
}: MealDetailScreenProps) {
  const { t, isRTL } = useLanguage();

  // Calculate totals
  const totalProtein = meal.totalProtein || meal.foods.reduce((sum, food) => sum + food.protein, 0);
  const totalCarbs = meal.totalCarbs || meal.foods.reduce((sum, food) => sum + food.carbs, 0);
  const totalFats = meal.totalFats || meal.foods.reduce((sum, food) => sum + food.fats, 0);

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-600 text-white p-4">
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
            <h1 className="text-xl font-bold">{meal.name}</h1>
            <p className={`text-sm text-white/90 flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <Clock className="w-4 h-4" />
              {meal.time}
            </p>
          </div>
        </div>

        {/* Meal Summary */}
        <div className="grid grid-cols-4 gap-2 bg-white/10 rounded-lg p-3">
          <div className="text-center">
            <div className="text-2xl font-bold">{meal.totalCalories}</div>
            <div className="text-xs">{t('nutrition.calories')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{Math.round(totalProtein)}g</div>
            <div className="text-xs">{t('nutrition.protein')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{Math.round(totalCarbs)}g</div>
            <div className="text-xs">{t('nutrition.carbs')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{Math.round(totalFats)}g</div>
            <div className="text-xs">{t('nutrition.fats')}</div>
          </div>
        </div>
      </div>

      {/* Food Items List */}
      <div className="p-4 space-y-3">
        <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
          <h2 className="font-semibold">{t('nutrition.foodItems')}</h2>
          <Button size="sm" onClick={onAddFood}>
            <Plus className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
            {t('nutrition.addFood')}
          </Button>
        </div>

        <ScrollArea className="h-[calc(100vh-300px)]">
          {meal.foods.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <ChefHat className="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>{t('nutrition.noFoodsYet')}</p>
              <p className="text-sm mt-1">{t('nutrition.addFirstFood')}</p>
            </div>
          ) : (
            meal.foods.map(food => (
              <Card key={food.id} className="mb-3">
                <CardContent className="p-4">
                  <div className={`flex items-start justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <div className="flex-1">
                      <h3 className="font-medium">{food.name}</h3>
                      <p className="text-sm text-muted-foreground">
                        {food.serving}
                      </p>
                    </div>
                    <div className={`flex gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => onEditFood(food.id)}
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => onRemoveFood(food.id)}
                      >
                        <Trash2 className="w-4 h-4 text-destructive" />
                      </Button>
                    </div>
                  </div>

                  <div className="grid grid-cols-4 gap-2 text-center text-sm">
                    <div>
                      <div className="font-semibold">{food.calories}</div>
                      <div className="text-xs text-muted-foreground">{t('nutrition.cal')}</div>
                    </div>
                    <div>
                      <div className="font-semibold">{food.protein}g</div>
                      <div className="text-xs text-muted-foreground">{t('nutrition.protein')}</div>
                    </div>
                    <div>
                      <div className="font-semibold">{food.carbs}g</div>
                      <div className="text-xs text-muted-foreground">{t('nutrition.carbs')}</div>
                    </div>
                    <div>
                      <div className="font-semibold">{food.fats}g</div>
                      <div className="text-xs text-muted-foreground">{t('nutrition.fats')}</div>
                    </div>
                  </div>

                  {food.recipeId && onViewRecipe && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="w-full mt-2"
                      onClick={() => onViewRecipe(food.recipeId!)}
                    >
                      <ChefHat className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                      {t('nutrition.viewRecipe')}
                    </Button>
                  )}
                </CardContent>
              </Card>
            ))
          )}
        </ScrollArea>
      </div>
    </div>
  );
}
