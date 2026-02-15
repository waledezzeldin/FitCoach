import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { ScrollArea } from './ui/scroll-area';
import { ArrowLeft, Plus, Trash2, Save, GripVertical, Search } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { exerciseDatabase, translateExercise } from './EnhancedExerciseDatabase';
import { toast } from 'sonner@2.0.3';

interface Exercise {
  id: string;
  exerciseId: string;
  name: string;
  sets: number;
  reps: string;
  restTime: number;
  notes?: string;
}

interface WorkoutPlanBuilderProps {
  clientId?: string;
  onBack: () => void;
  onSave: (plan: any) => void;
}

export function WorkoutPlanBuilder({ clientId, onBack, onSave }: WorkoutPlanBuilderProps) {
  const { t } = useLanguage();
  const [planName, setPlanName] = useState('');
  const [duration, setDuration] = useState('4');
  const [difficulty, setDifficulty] = useState('intermediate');
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedMuscleGroup, setSelectedMuscleGroup] = useState('all');

  // Translate exercises for display
  const translatedExercises = exerciseDatabase.map(ex => translateExercise(ex, t));

  const filteredExercises = translatedExercises.filter(ex => {
    const matchesSearch = ex.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesMuscle = selectedMuscleGroup === 'all' || ex.muscleGroup === selectedMuscleGroup;
    return matchesSearch && matchesMuscle;
  });

  const handleAddExercise = (exerciseId: string) => {
    const exercise = exerciseDatabase.find(ex => ex.id === exerciseId);
    if (!exercise) return;

    const translated = translateExercise(exercise, t);

    const newExercise: Exercise = {
      id: Date.now().toString(),
      exerciseId: exercise.id,
      name: translated.name,
      sets: exercise.defaultSets,
      reps: exercise.defaultReps,
      restTime: exercise.defaultRestTime,
    };

    setExercises([...exercises, newExercise]);
    toast.success(t('workoutBuilder.exerciseAdded'));
  };

  const handleRemoveExercise = (id: string) => {
    setExercises(exercises.filter(ex => ex.id !== id));
  };

  const handleSavePlan = () => {
    if (!planName || exercises.length === 0) {
      toast.error(t('workoutBuilder.fillRequiredFields'));
      return;
    }

    const plan = {
      name: planName,
      duration: parseInt(duration),
      difficulty,
      exercises,
      clientId
    };

    onSave(plan);
    toast.success(t('workoutBuilder.planSaved'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('workoutBuilder.title')}</h1>
            <p className="text-sm text-white/80">{t('workoutBuilder.subtitle')}</p>
          </div>
          <Button variant="secondary" onClick={handleSavePlan}>
            <Save className="w-4 h-4 mr-2" />
            {t('common.save')}
          </Button>
        </div>
      </div>

      <div className="p-4 grid md:grid-cols-2 gap-4">
        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>{t('workoutBuilder.planDetails')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>{t('workoutBuilder.planName')}</Label>
                <Input value={planName} onChange={(e) => setPlanName(e.target.value)} placeholder="Upper Body Strength" />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>{t('workoutBuilder.duration')}</Label>
                  <Select value={duration} onValueChange={setDuration}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="2">2 {t('workoutBuilder.weeks')}</SelectItem>
                      <SelectItem value="4">4 {t('workoutBuilder.weeks')}</SelectItem>
                      <SelectItem value="8">8 {t('workoutBuilder.weeks')}</SelectItem>
                      <SelectItem value="12">12 {t('workoutBuilder.weeks')}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>{t('workoutBuilder.difficulty')}</Label>
                  <Select value={difficulty} onValueChange={setDifficulty}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="beginner">{t('workouts.beginner')}</SelectItem>
                      <SelectItem value="intermediate">{t('workouts.intermediate')}</SelectItem>
                      <SelectItem value="advanced">{t('workouts.advanced')}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>{t('workoutBuilder.exercises')} ({exercises.length})</CardTitle>
            </CardHeader>
            <CardContent>
              <ScrollArea className="h-96">
                <div className="space-y-2">
                  {exercises.map((ex, index) => (
                    <Card key={ex.id}>
                      <CardContent className="p-3">
                        <div className="flex items-center gap-2">
                          <GripVertical className="w-4 h-4 text-muted-foreground" />
                          <div className="flex-1">
                            <p className="font-medium text-sm">{index + 1}. {ex.name}</p>
                            <p className="text-xs text-muted-foreground">{ex.sets} × {ex.reps}</p>
                          </div>
                          <Button variant="ghost" size="icon" onClick={() => handleRemoveExercise(ex.id)}>
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                  {exercises.length === 0 && (
                    <p className="text-center text-muted-foreground py-8">{t('workoutBuilder.noExercises')}</p>
                  )}
                </div>
              </ScrollArea>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>{t('workoutBuilder.exerciseLibrary')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Input
                  placeholder={t('workoutBuilder.searchExercises')}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full"
                />
                <Select value={selectedMuscleGroup} onValueChange={setSelectedMuscleGroup}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">{t('workoutBuilder.allMuscles')}</SelectItem>
                    <SelectItem value="Chest">{t('workouts.chest')}</SelectItem>
                    <SelectItem value="Back">{t('workouts.back')}</SelectItem>
                    <SelectItem value="Legs">{t('workouts.legs')}</SelectItem>
                    <SelectItem value="Shoulders">{t('workouts.shoulders')}</SelectItem>
                    <SelectItem value="Arms">{t('workouts.arms')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <ScrollArea className="h-96">
                <div className="space-y-2">
                  {filteredExercises.map(ex => (
                    <Card key={ex.id} className="cursor-pointer hover:bg-muted/50" onClick={() => handleAddExercise(ex.id)}>
                      <CardContent className="p-3">
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <p className="font-medium text-sm">{ex.name}</p>
                            <p className="text-xs text-muted-foreground">{ex.muscleGroup}</p>
                          </div>
                          <Button variant="ghost" size="icon">
                            <Plus className="w-4 h-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </ScrollArea>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}