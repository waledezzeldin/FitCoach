import React, { useState } from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { ArrowLeft, Search, Heart, Play } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { exerciseDatabase, translateExercise } from './EnhancedExerciseDatabase';
import { toast } from 'sonner@2.0.3';

interface ExerciseLibraryScreenProps {
  onBack: () => void;
  onExerciseSelect?: (exerciseId: string) => void;
}

export function ExerciseLibraryScreen({ onBack, onExerciseSelect }: ExerciseLibraryScreenProps) {
  const { t, isRTL } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedMuscle, setSelectedMuscle] = useState('all');
  const [favorites, setFavorites] = useState<string[]>([]);

  // Translate exercises for display
  const translatedExercises = exerciseDatabase.map(ex => translateExercise(ex, t));

  const filteredExercises = translatedExercises.filter(ex => {
    const matchesSearch = ex.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesMuscle = selectedMuscle === 'all' || ex.muscleGroup === selectedMuscle;
    return matchesSearch && matchesMuscle;
  });

  const toggleFavorite = (id: string) => {
    if (favorites.includes(id)) {
      setFavorites(favorites.filter(f => f !== id));
      toast.success(t('exercises.removedFromFavorites'));
    } else {
      setFavorites([...favorites, id]);
      toast.success(t('exercises.addedToFavorites'));
    }
  };

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-slate-700 to-slate-900 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-semibold">{t('exercises.library')}</h1>
            <p className="text-sm text-white/80">{filteredExercises.length} {t('home.exercises')}</p>
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="p-4 bg-muted/30 border-b">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row gap-3">
            <div className="relative flex-1">
              <Search className={`absolute top-1/2 transform -translate-y-1/2 w-5 h-5 text-muted-foreground ${isRTL ? 'right-3' : 'left-3'}`} />
              <Input
                placeholder={t('exercises.search')}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className={`h-11 ${isRTL ? 'pr-10' : 'pl-10'}`}
              />
            </div>
            <Select value={selectedMuscle} onValueChange={setSelectedMuscle}>
              <SelectTrigger className="w-full md:w-56 h-11">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">{t('exercises.allMuscles')}</SelectItem>
                <SelectItem value="Chest">{t('workouts.chest')}</SelectItem>
                <SelectItem value="Back">{t('workouts.back')}</SelectItem>
                <SelectItem value="Legs">{t('workouts.legs')}</SelectItem>
                <SelectItem value="Shoulders">{t('workouts.shoulders')}</SelectItem>
                <SelectItem value="Arms">{t('workouts.arms')}</SelectItem>
                <SelectItem value="Core">{t('workouts.core')}</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>

      {/* Exercise Grid */}
      <div className="p-4 lg:p-6">
        <div className="max-w-7xl mx-auto">
          {filteredExercises.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto mb-4 bg-muted rounded-full flex items-center justify-center">
                <Search className="w-8 h-8 text-muted-foreground" />
              </div>
              <h3 className="mb-2">No exercises found</h3>
              <p className="text-muted-foreground">Try adjusting your search or filter</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
              {filteredExercises.map(exercise => (
                <Card key={exercise.id} className="hover:shadow-lg transition-all hover:scale-[1.02] duration-200">
                  <CardContent className="p-5">
                    <div className="flex items-start justify-between mb-3">
                      <Badge variant="secondary" className="text-xs">
                        {exercise.muscleGroup}
                      </Badge>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-8 w-8 -mt-1 -mr-1"
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleFavorite(exercise.id);
                        }}
                      >
                        <Heart className={`w-5 h-5 transition-all ${
                          favorites.includes(exercise.id) 
                            ? 'fill-red-500 text-red-500 scale-110' 
                            : 'text-muted-foreground hover:text-red-500'
                        }`} />
                      </Button>
                    </div>
                    
                    <h3 className="font-semibold mb-2 line-clamp-1">{exercise.name}</h3>
                    <p className="text-sm text-muted-foreground mb-4 line-clamp-2">{exercise.description}</p>
                    
                    <div className="flex items-center gap-3 text-sm font-medium text-muted-foreground mb-4 pb-4 border-b">
                      <div className="flex items-center gap-1">
                        <span className="text-primary">{exercise.defaultReps}</span>
                        <span>{t('workout.reps')}</span>
                      </div>
                      <span className="text-muted-foreground/30">•</span>
                      <div className="flex items-center gap-1">
                        <span className="text-primary">{exercise.defaultSets}</span>
                        <span>{t('workout.sets')}</span>
                      </div>
                    </div>

                    <div className="flex gap-2">
                      <Button variant="outline" size="sm" className="flex-1">
                        <Play className="w-4 h-4 mr-2" />
                        {t('exercises.watch')}
                      </Button>
                      {onExerciseSelect && (
                        <Button size="sm" className="flex-1" onClick={() => onExerciseSelect(exercise.id)}>
                          {t('exercises.select')}
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
      </div>
    </div>
  );
}