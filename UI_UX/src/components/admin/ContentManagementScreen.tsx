import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Badge } from '../ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { ArrowLeft, Plus, Edit3, Trash2, Search } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

export function ContentManagementScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeTab, setActiveTab] = useState('exercises');

  const exercises = [
    { id: '1', name: 'Bench Press', category: 'Chest', difficulty: 'Intermediate', status: 'active' },
    { id: '2', name: 'Squat', category: 'Legs', difficulty: 'Advanced', status: 'active' },
    { id: '3', name: 'Deadlift', category: 'Back', difficulty: 'Advanced', status: 'active' },
  ];

  const meals = [
    { id: '1', name: 'Grilled Chicken Salad', calories: 350, protein: 35, status: 'active' },
    { id: '2', name: 'Protein Smoothie', calories: 280, protein: 25, status: 'active' },
    { id: '3', name: 'Salmon Bowl', calories: 450, protein: 40, status: 'active' },
  ];

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-teal-600 to-cyan-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('admin.contentManagement')}</h1>
            <p className="text-sm text-white/80">{t('admin.exercisesAndMeals')}</p>
          </div>
          <Button variant="secondary">
            <Plus className="w-4 h-4 mr-2" />
            {t('admin.addNew')}
          </Button>
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList>
            <TabsTrigger value="exercises">{t('admin.exercises')}</TabsTrigger>
            <TabsTrigger value="meals">{t('admin.meals')}</TabsTrigger>
            <TabsTrigger value="plans">{t('admin.templates')}</TabsTrigger>
          </TabsList>

          <TabsContent value="exercises" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input placeholder={t('admin.searchExercises')} value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} className="pl-9" />
                </div>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>{t('admin.name')}</TableHead>
                      <TableHead>{t('admin.category')}</TableHead>
                      <TableHead>{t('admin.difficulty')}</TableHead>
                      <TableHead>{t('admin.status')}</TableHead>
                      <TableHead>{t('admin.actions')}</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {exercises.map(ex => (
                      <TableRow key={ex.id}>
                        <TableCell className="font-medium">{ex.name}</TableCell>
                        <TableCell>{ex.category}</TableCell>
                        <TableCell><Badge variant="outline">{ex.difficulty}</Badge></TableCell>
                        <TableCell><Badge>{ex.status}</Badge></TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button variant="outline" size="icon"><Edit3 className="w-4 h-4" /></Button>
                            <Button variant="outline" size="icon"><Trash2 className="w-4 h-4 text-destructive" /></Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="meals" className="space-y-4">
            <Card>
              <CardContent className="p-6">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>{t('admin.name')}</TableHead>
                      <TableHead>{t('nutrition.calories')}</TableHead>
                      <TableHead>{t('nutrition.protein')}</TableHead>
                      <TableHead>{t('admin.status')}</TableHead>
                      <TableHead>{t('admin.actions')}</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {meals.map(meal => (
                      <TableRow key={meal.id}>
                        <TableCell className="font-medium">{meal.name}</TableCell>
                        <TableCell>{meal.calories} kcal</TableCell>
                        <TableCell>{meal.protein}g</TableCell>
                        <TableCell><Badge>{meal.status}</Badge></TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button variant="outline" size="icon"><Edit3 className="w-4 h-4" /></Button>
                            <Button variant="outline" size="icon"><Trash2 className="w-4 h-4 text-destructive" /></Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="plans">
            <Card>
              <CardContent className="p-12 text-center text-muted-foreground">
                <p>{t('admin.templateManagementComing')}</p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}