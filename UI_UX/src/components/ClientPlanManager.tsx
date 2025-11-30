import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Textarea } from './ui/textarea';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { 
  ArrowLeft,
  Dumbbell,
  Apple,
  Edit3,
  Save,
  Plus,
  Trash2,
  Clock,
  Target,
  Calendar
} from 'lucide-react';
import { UserProfile } from '../App';

interface ClientPlanManagerProps {
  clientId: string;
  onBack: () => void;
  isDemoMode: boolean;
}

interface Exercise {
  id: string;
  name: string;
  sets: number;
  reps: string;
  weight?: string;
  restTime: string;
  notes?: string;
}

interface WorkoutPlan {
  id: string;
  name: string;
  exercises: Exercise[];
  duration: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  notes?: string;
}

interface MealPlan {
  id: string;
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  ingredients: string[];
  instructions: string;
}

interface Client {
  id: string;
  name: string;
  email: string;
  goal: string;
  workoutPlans: WorkoutPlan[];
  mealPlans: MealPlan[];
}

export function ClientPlanManager({ clientId, onBack, isDemoMode }: ClientPlanManagerProps) {
  const [activeTab, setActiveTab] = useState('workout');
  const [editingWorkout, setEditingWorkout] = useState<string | null>(null);
  const [editingMeal, setEditingMeal] = useState<string | null>(null);

  // Demo client data
  const [client, setClient] = useState<Client>({
    id: clientId,
    name: 'Mina H.',
    email: 'mina.h@demo.com',
    goal: 'Muscle Gain',
    workoutPlans: [
      {
        id: 'workout_1',
        name: 'Upper Body Strength',
        duration: '45 min',
        difficulty: 'intermediate',
        notes: 'Focus on progressive overload. Increase weight by 2.5kg when all sets can be completed with perfect form.',
        exercises: [
          {
            id: 'ex_1',
            name: 'Bench Press',
            sets: 4,
            reps: '8-10',
            weight: '80kg',
            restTime: '2-3 min',
            notes: 'Control the descent, pause at chest'
          },
          {
            id: 'ex_2',
            name: 'Pull-ups',
            sets: 3,
            reps: '6-8',
            restTime: '2 min',
            notes: 'Use assistance band if needed'
          },
          {
            id: 'ex_3',
            name: 'Overhead Press',
            sets: 3,
            reps: '8-10',
            weight: '55kg',
            restTime: '2 min'
          },
          {
            id: 'ex_4',
            name: 'Barbell Rows',
            sets: 3,
            reps: '8-10',
            weight: '70kg',
            restTime: '90 sec'
          }
        ]
      },
      {
        id: 'workout_2',
        name: 'Lower Body Power',
        duration: '50 min',
        difficulty: 'intermediate',
        notes: 'Focus on explosive movements and proper form.',
        exercises: [
          {
            id: 'ex_5',
            name: 'Squats',
            sets: 4,
            reps: '6-8',
            weight: '100kg',
            restTime: '3 min',
            notes: 'Go below parallel, drive through heels'
          },
          {
            id: 'ex_6',
            name: 'Romanian Deadlifts',
            sets: 3,
            reps: '8-10',
            weight: '90kg',
            restTime: '2 min'
          },
          {
            id: 'ex_7',
            name: 'Bulgarian Split Squats',
            sets: 3,
            reps: '10 each leg',
            weight: '20kg DBs',
            restTime: '90 sec'
          }
        ]
      }
    ],
    mealPlans: [
      {
        id: 'meal_1',
        mealType: 'breakfast',
        name: 'Protein Power Bowl',
        calories: 520,
        protein: 35,
        carbs: 45,
        fat: 18,
        ingredients: ['3 eggs', '1 cup oatmeal', '1 banana', '1 tbsp almond butter', '1 cup berries'],
        instructions: 'Cook oatmeal, scramble eggs, top with sliced banana, berries, and almond butter.'
      },
      {
        id: 'meal_2',
        mealType: 'lunch',
        name: 'Lean Muscle Plate',
        calories: 680,
        protein: 45,
        carbs: 55,
        fat: 22,
        ingredients: ['200g chicken breast', '1.5 cups brown rice', '1 cup broccoli', '1 tbsp olive oil', 'mixed herbs'],
        instructions: 'Grill chicken, steam broccoli, serve over brown rice with olive oil and herbs.'
      },
      {
        id: 'meal_3',
        mealType: 'dinner',
        name: 'Recovery Feast',
        calories: 620,
        protein: 40,
        carbs: 50,
        fat: 20,
        ingredients: ['180g salmon', '200g sweet potato', '2 cups spinach', '1 tbsp olive oil', 'lemon'],
        instructions: 'Bake salmon and sweet potato, sauté spinach with olive oil, serve with lemon.'
      }
    ]
  });

  const addNewWorkout = () => {
    const newWorkout: WorkoutPlan = {
      id: `workout_${Date.now()}`,
      name: 'New Workout',
      duration: '30 min',
      difficulty: 'beginner',
      exercises: []
    };
    setClient(prev => ({
      ...prev,
      workoutPlans: [...prev.workoutPlans, newWorkout]
    }));
    setEditingWorkout(newWorkout.id);
  };

  const addNewMeal = () => {
    const newMeal: MealPlan = {
      id: `meal_${Date.now()}`,
      mealType: 'snack',
      name: 'New Meal',
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      ingredients: [],
      instructions: ''
    };
    setClient(prev => ({
      ...prev,
      mealPlans: [...prev.mealPlans, newMeal]
    }));
    setEditingMeal(newMeal.id);
  };

  const updateWorkout = (workoutId: string, updates: Partial<WorkoutPlan>) => {
    setClient(prev => ({
      ...prev,
      workoutPlans: prev.workoutPlans.map(workout =>
        workout.id === workoutId ? { ...workout, ...updates } : workout
      )
    }));
  };

  const updateMeal = (mealId: string, updates: Partial<MealPlan>) => {
    setClient(prev => ({
      ...prev,
      mealPlans: prev.mealPlans.map(meal =>
        meal.id === mealId ? { ...meal, ...updates } : meal
      )
    }));
  };

  const deleteWorkout = (workoutId: string) => {
    setClient(prev => ({
      ...prev,
      workoutPlans: prev.workoutPlans.filter(workout => workout.id !== workoutId)
    }));
  };

  const deleteMeal = (mealId: string) => {
    setClient(prev => ({
      ...prev,
      mealPlans: prev.mealPlans.filter(meal => meal.id !== mealId)
    }));
  };

  const addExerciseToWorkout = (workoutId: string) => {
    const newExercise: Exercise = {
      id: `ex_${Date.now()}`,
      name: 'New Exercise',
      sets: 3,
      reps: '8-12',
      restTime: '60 sec'
    };
    
    updateWorkout(workoutId, {
      exercises: [...(client.workoutPlans.find(w => w.id === workoutId)?.exercises || []), newExercise]
    });
  };

  const updateExercise = (workoutId: string, exerciseId: string, updates: Partial<Exercise>) => {
    const workout = client.workoutPlans.find(w => w.id === workoutId);
    if (workout) {
      const updatedExercises = workout.exercises.map(ex =>
        ex.id === exerciseId ? { ...ex, ...updates } : ex
      );
      updateWorkout(workoutId, { exercises: updatedExercises });
    }
  };

  const deleteExercise = (workoutId: string, exerciseId: string) => {
    const workout = client.workoutPlans.find(w => w.id === workoutId);
    if (workout) {
      const updatedExercises = workout.exercises.filter(ex => ex.id !== exerciseId);
      updateWorkout(workoutId, { exercises: updatedExercises });
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-purple-600 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{client.name}'s Plans</h1>
            <p className="text-white/80">{client.goal} • {client.email}</p>
          </div>
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="workout">
              <Dumbbell className="w-4 h-4 mr-2" />
              Workouts
            </TabsTrigger>
            <TabsTrigger value="nutrition">
              <Apple className="w-4 h-4 mr-2" />
              Nutrition
            </TabsTrigger>
          </TabsList>

          <TabsContent value="workout" className="mt-4 space-y-4">
            {/* Add New Workout Button */}
            <Button onClick={addNewWorkout} className="w-full">
              <Plus className="w-4 h-4 mr-2" />
              Add New Workout Plan
            </Button>

            {/* Workout Plans */}
            {client.workoutPlans.map((workout) => (
              <Card key={workout.id}>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      {editingWorkout === workout.id ? (
                        <Input
                          value={workout.name}
                          onChange={(e) => updateWorkout(workout.id, { name: e.target.value })}
                          className="text-lg font-medium"
                        />
                      ) : (
                        <CardTitle className="text-lg">{workout.name}</CardTitle>
                      )}
                      <div className="flex items-center gap-2 mt-1">
                        <Badge variant="outline">{workout.difficulty}</Badge>
                        <Badge variant="outline">
                          <Clock className="w-3 h-3 mr-1" />
                          {workout.duration}
                        </Badge>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setEditingWorkout(editingWorkout === workout.id ? null : workout.id)}
                      >
                        {editingWorkout === workout.id ? <Save className="w-4 h-4" /> : <Edit3 className="w-4 h-4" />}
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => deleteWorkout(workout.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {editingWorkout === workout.id && (
                    <div className="space-y-3">
                      <div>
                        <Label>Duration</Label>
                        <Input
                          value={workout.duration}
                          onChange={(e) => updateWorkout(workout.id, { duration: e.target.value })}
                        />
                      </div>
                      <div>
                        <Label>Notes</Label>
                        <Textarea
                          value={workout.notes || ''}
                          onChange={(e) => updateWorkout(workout.id, { notes: e.target.value })}
                          placeholder="Add workout notes..."
                        />
                      </div>
                    </div>
                  )}

                  {workout.notes && !editingWorkout && (
                    <div className="p-3 bg-muted rounded-lg">
                      <p className="text-sm text-muted-foreground">{workout.notes}</p>
                    </div>
                  )}

                  {/* Exercises */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <h4 className="font-medium">Exercises ({workout.exercises.length})</h4>
                      {editingWorkout === workout.id && (
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => addExerciseToWorkout(workout.id)}
                        >
                          <Plus className="w-3 h-3 mr-1" />
                          Add Exercise
                        </Button>
                      )}
                    </div>

                    {workout.exercises.map((exercise) => (
                      <div key={exercise.id} className="border rounded-lg p-3">
                        <div className="flex items-center justify-between mb-2">
                          {editingWorkout === workout.id ? (
                            <Input
                              value={exercise.name}
                              onChange={(e) => updateExercise(workout.id, exercise.id, { name: e.target.value })}
                              className="font-medium"
                            />
                          ) : (
                            <h5 className="font-medium">{exercise.name}</h5>
                          )}
                          {editingWorkout === workout.id && (
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => deleteExercise(workout.id, exercise.id)}
                            >
                              <Trash2 className="w-3 h-3" />
                            </Button>
                          )}
                        </div>

                        {editingWorkout === workout.id ? (
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <Label className="text-xs">Sets</Label>
                              <Input
                                type="number"
                                value={exercise.sets}
                                onChange={(e) => updateExercise(workout.id, exercise.id, { sets: parseInt(e.target.value) })}
                              />
                            </div>
                            <div>
                              <Label className="text-xs">Reps</Label>
                              <Input
                                value={exercise.reps}
                                onChange={(e) => updateExercise(workout.id, exercise.id, { reps: e.target.value })}
                              />
                            </div>
                            <div>
                              <Label className="text-xs">Weight</Label>
                              <Input
                                value={exercise.weight || ''}
                                onChange={(e) => updateExercise(workout.id, exercise.id, { weight: e.target.value })}
                              />
                            </div>
                            <div>
                              <Label className="text-xs">Rest</Label>
                              <Input
                                value={exercise.restTime}
                                onChange={(e) => updateExercise(workout.id, exercise.id, { restTime: e.target.value })}
                              />
                            </div>
                          </div>
                        ) : (
                          <div className="text-sm text-muted-foreground space-y-1">
                            <p>{exercise.sets} sets × {exercise.reps} reps {exercise.weight && `@ ${exercise.weight}`}</p>
                            <p>Rest: {exercise.restTime}</p>
                            {exercise.notes && <p className="italic">Note: {exercise.notes}</p>}
                          </div>
                        )}

                        {editingWorkout === workout.id && (
                          <div className="mt-2">
                            <Label className="text-xs">Notes</Label>
                            <Textarea
                              value={exercise.notes || ''}
                              onChange={(e) => updateExercise(workout.id, exercise.id, { notes: e.target.value })}
                              placeholder="Exercise notes..."
                              className="text-xs"
                            />
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="nutrition" className="mt-4 space-y-4">
            {/* Add New Meal Button */}
            <Button onClick={addNewMeal} className="w-full">
              <Plus className="w-4 h-4 mr-2" />
              Add New Meal Plan
            </Button>

            {/* Meal Plans */}
            {client.mealPlans.map((meal) => (
              <Card key={meal.id}>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      {editingMeal === meal.id ? (
                        <div className="space-y-2">
                          <Input
                            value={meal.name}
                            onChange={(e) => updateMeal(meal.id, { name: e.target.value })}
                            className="text-lg font-medium"
                          />
                          <select
                            value={meal.mealType}
                            onChange={(e) => updateMeal(meal.id, { mealType: e.target.value as any })}
                            className="w-full p-2 border rounded"
                          >
                            <option value="breakfast">Breakfast</option>
                            <option value="lunch">Lunch</option>
                            <option value="dinner">Dinner</option>
                            <option value="snack">Snack</option>
                          </select>
                        </div>
                      ) : (
                        <>
                          <CardTitle className="text-lg">{meal.name}</CardTitle>
                          <Badge variant="outline" className="capitalize">{meal.mealType}</Badge>
                        </>
                      )}
                    </div>
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setEditingMeal(editingMeal === meal.id ? null : meal.id)}
                      >
                        {editingMeal === meal.id ? <Save className="w-4 h-4" /> : <Edit3 className="w-4 h-4" />}
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => deleteMeal(meal.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {/* Macros */}
                  <div className="grid grid-cols-4 gap-2 text-center">
                    <div className="p-2 bg-muted rounded">
                      <div className="text-lg font-medium">{meal.calories}</div>
                      <div className="text-xs text-muted-foreground">Calories</div>
                    </div>
                    <div className="p-2 bg-muted rounded">
                      <div className="text-lg font-medium text-blue-600">{meal.protein}g</div>
                      <div className="text-xs text-muted-foreground">Protein</div>
                    </div>
                    <div className="p-2 bg-muted rounded">
                      <div className="text-lg font-medium text-green-600">{meal.carbs}g</div>
                      <div className="text-xs text-muted-foreground">Carbs</div>
                    </div>
                    <div className="p-2 bg-muted rounded">
                      <div className="text-lg font-medium text-yellow-600">{meal.fat}g</div>
                      <div className="text-xs text-muted-foreground">Fat</div>
                    </div>
                  </div>

                  {editingMeal === meal.id && (
                    <div className="space-y-3">
                      <div className="grid grid-cols-4 gap-2">
                        <div>
                          <Label className="text-xs">Calories</Label>
                          <Input
                            type="number"
                            value={meal.calories}
                            onChange={(e) => updateMeal(meal.id, { calories: parseInt(e.target.value) || 0 })}
                          />
                        </div>
                        <div>
                          <Label className="text-xs">Protein (g)</Label>
                          <Input
                            type="number"
                            value={meal.protein}
                            onChange={(e) => updateMeal(meal.id, { protein: parseInt(e.target.value) || 0 })}
                          />
                        </div>
                        <div>
                          <Label className="text-xs">Carbs (g)</Label>
                          <Input
                            type="number"
                            value={meal.carbs}
                            onChange={(e) => updateMeal(meal.id, { carbs: parseInt(e.target.value) || 0 })}
                          />
                        </div>
                        <div>
                          <Label className="text-xs">Fat (g)</Label>
                          <Input
                            type="number"
                            value={meal.fat}
                            onChange={(e) => updateMeal(meal.id, { fat: parseInt(e.target.value) || 0 })}
                          />
                        </div>
                      </div>
                      
                      <div>
                        <Label>Ingredients</Label>
                        <Textarea
                          value={meal.ingredients.join('\n')}
                          onChange={(e) => updateMeal(meal.id, { ingredients: e.target.value.split('\n').filter(i => i.trim()) })}
                          placeholder="One ingredient per line..."
                        />
                      </div>
                      
                      <div>
                        <Label>Instructions</Label>
                        <Textarea
                          value={meal.instructions}
                          onChange={(e) => updateMeal(meal.id, { instructions: e.target.value })}
                          placeholder="Cooking instructions..."
                        />
                      </div>
                    </div>
                  )}

                  {!editingMeal && (
                    <>
                      {/* Ingredients */}
                      <div>
                        <h5 className="font-medium mb-2">Ingredients:</h5>
                        <ul className="text-sm text-muted-foreground space-y-1">
                          {meal.ingredients.map((ingredient, index) => (
                            <li key={index}>• {ingredient}</li>
                          ))}
                        </ul>
                      </div>

                      {/* Instructions */}
                      <div>
                        <h5 className="font-medium mb-2">Instructions:</h5>
                        <p className="text-sm text-muted-foreground">{meal.instructions}</p>
                      </div>
                    </>
                  )}
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}