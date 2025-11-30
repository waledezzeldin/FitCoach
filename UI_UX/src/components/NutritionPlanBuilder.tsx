import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ArrowLeft, Save, Plus, Trash2 } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface Meal {
  id: string;
  name: string;
  time: string;
  foods: { name: string; portion: string; calories: number; protein: number; carbs: number; fats: number }[];
}

interface NutritionPlanBuilderProps {
  clientId?: string;
  onBack: () => void;
  onSave: (plan: any) => void;
}

export function NutritionPlanBuilder({ clientId, onBack, onSave }: NutritionPlanBuilderProps) {
  const { t } = useLanguage();
  const [planName, setPlanName] = useState('');
  const [dailyCalories, setDailyCalories] = useState('2000');
  const [proteinTarget, setProteinTarget] = useState('150');
  const [carbsTarget, setCarbsTarget] = useState('200');
  const [fatsTarget, setFatsTarget] = useState('67');
  const [meals, setMeals] = useState<Meal[]>([
    { id: '1', name: 'Breakfast', time: '08:00', foods: [] },
    { id: '2', name: 'Lunch', time: '13:00', foods: [] },
    { id: '3', name: 'Dinner', time: '19:00', foods: [] },
  ]);
  const [notes, setNotes] = useState('');

  const addMeal = () => {
    const newMeal: Meal = {
      id: Date.now().toString(),
      name: 'Snack',
      time: '15:00',
      foods: []
    };
    setMeals([...meals, newMeal]);
  };

  const removeMeal = (id: string) => {
    setMeals(meals.filter(m => m.id !== id));
  };

  const handleSave = () => {
    if (!planName) {
      toast.error(t('nutritionBuilder.enterPlanName'));
      return;
    }

    const plan = {
      name: planName,
      dailyCalories: parseInt(dailyCalories),
      macros: {
        protein: parseInt(proteinTarget),
        carbs: parseInt(carbsTarget),
        fats: parseInt(fatsTarget)
      },
      meals,
      notes,
      clientId
    };

    onSave(plan);
    toast.success(t('nutritionBuilder.planSaved'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-green-600 to-emerald-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('nutritionBuilder.title')}</h1>
            <p className="text-sm text-white/80">{t('nutritionBuilder.subtitle')}</p>
          </div>
          <Button variant="secondary" onClick={handleSave}>
            <Save className="w-4 h-4 mr-2" />
            {t('common.save')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>{t('nutritionBuilder.planDetails')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>{t('nutritionBuilder.planName')}</Label>
              <Input value={planName} onChange={(e) => setPlanName(e.target.value)} placeholder="Weight Loss Plan" />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('nutritionBuilder.dailyCalories')}</Label>
                <Input type="number" value={dailyCalories} onChange={(e) => setDailyCalories(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>{t('nutritionBuilder.protein')} (g)</Label>
                <Input type="number" value={proteinTarget} onChange={(e) => setProteinTarget(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>{t('nutritionBuilder.carbs')} (g)</Label>
                <Input type="number" value={carbsTarget} onChange={(e) => setCarbsTarget(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>{t('nutritionBuilder.fats')} (g)</Label>
                <Input type="number" value={fatsTarget} onChange={(e) => setFatsTarget(e.target.value)} />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>{t('nutritionBuilder.meals')}</CardTitle>
              <Button size="sm" onClick={addMeal}>
                <Plus className="w-4 h-4 mr-2" />
                {t('nutritionBuilder.addMeal')}
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue={meals[0]?.id} className="w-full">
              <TabsList className="w-full">
                {meals.map(meal => (
                  <TabsTrigger key={meal.id} value={meal.id} className="flex-1">
                    {meal.name}
                  </TabsTrigger>
                ))}
              </TabsList>

              {meals.map(meal => (
                <TabsContent key={meal.id} value={meal.id} className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label>{t('nutritionBuilder.mealName')}</Label>
                      <Input
                        value={meal.name}
                        onChange={(e) => {
                          const updated = meals.map(m => m.id === meal.id ? { ...m, name: e.target.value } : m);
                          setMeals(updated);
                        }}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{t('nutritionBuilder.mealTime')}</Label>
                      <Input
                        type="time"
                        value={meal.time}
                        onChange={(e) => {
                          const updated = meals.map(m => m.id === meal.id ? { ...m, time: e.target.value } : m);
                          setMeals(updated);
                        }}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>{t('nutritionBuilder.foods')}</Label>
                    <div className="text-center text-muted-foreground py-8">
                      {t('nutritionBuilder.addFoodsPlaceholder')}
                    </div>
                  </div>

                  {meals.length > 1 && (
                    <Button variant="outline" className="w-full" onClick={() => removeMeal(meal.id)}>
                      <Trash2 className="w-4 h-4 mr-2" />
                      {t('nutritionBuilder.removeMeal')}
                    </Button>
                  )}
                </TabsContent>
              ))}
            </Tabs>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('nutritionBuilder.notes')}</CardTitle>
          </CardHeader>
          <CardContent>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder={t('nutritionBuilder.notesPlaceholder')}
              rows={4}
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}