import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Calendar } from './ui/calendar';
import { ArrowLeft, TrendingUp, TrendingDown, Award, Target, Flame, Activity } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';

interface ProgressDetailScreenProps {
  onBack: () => void;
  userProfile: any;
}

export function ProgressDetailScreen({ onBack, userProfile }: ProgressDetailScreenProps) {
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('weight');
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date());

  // Mock data
  const weightData = [
    { date: 'Week 1', weight: 85, goal: 80 },
    { date: 'Week 2', weight: 84.5, goal: 80 },
    { date: 'Week 3', weight: 84, goal: 80 },
    { date: 'Week 4', weight: 83.5, goal: 80 },
    { date: 'Week 5', weight: 83, goal: 80 },
    { date: 'Week 6', weight: 82.5, goal: 80 },
  ];

  const workoutData = [
    { week: 'W1', completed: 4, target: 5 },
    { week: 'W2', completed: 5, target: 5 },
    { week: 'W3', completed: 4, target: 5 },
    { week: 'W4', completed: 5, target: 5 },
  ];

  const strengthData = [
    { exercise: 'Bench Press', previous: 80, current: 85 },
    { exercise: 'Squat', previous: 100, current: 110 },
    { exercise: 'Deadlift', previous: 120, current: 130 },
  ];

  const achievements = [
    { id: 1, name: '7 Day Streak', icon: '🔥', unlocked: true, date: new Date(2024, 9, 15) },
    { id: 2, name: '50 Workouts', icon: '💪', unlocked: true, date: new Date(2024, 9, 20) },
    { id: 3, name: 'Weight Goal', icon: '🎯', unlocked: false },
    { id: 4, name: '100 Workouts', icon: '⭐', unlocked: false },
  ];

  const workoutCalendar = Array.from({ length: 30 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - (29 - i));
    return {
      date,
      completed: Math.random() > 0.3 // 70% completion rate
    };
  });

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.4
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-pink-600 text-white p-4">
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
            <h1 className="text-xl">{t('progress.title')}</h1>
            <p className="text-sm text-white/80">{t('progress.subtitle')}</p>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-3">
          <Card className="bg-white/10 border-white/20">
            <CardContent className="p-3 text-center">
              <TrendingDown className="w-5 h-5 mx-auto mb-1 text-white" />
              <div className="text-lg font-bold text-white">-2.5kg</div>
              <div className="text-xs text-white/80">{t('progress.weightLoss')}</div>
            </CardContent>
          </Card>
          
          <Card className="bg-white/10 border-white/20">
            <CardContent className="p-3 text-center">
              <Flame className="w-5 h-5 mx-auto mb-1 text-white" />
              <div className="text-lg font-bold text-white">18</div>
              <div className="text-xs text-white/80">{t('progress.workouts')}</div>
            </CardContent>
          </Card>
          
          <Card className="bg-white/10 border-white/20">
            <CardContent className="p-3 text-center">
              <Award className="w-5 h-5 mx-auto mb-1 text-white" />
              <div className="text-lg font-bold text-white">85%</div>
              <div className="text-xs text-white/80">{t('progress.adherence')}</div>
            </CardContent>
          </Card>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="weight">{t('progress.weight')}</TabsTrigger>
            <TabsTrigger value="workouts">{t('progress.workouts')}</TabsTrigger>
            <TabsTrigger value="strength">{t('progress.strength')}</TabsTrigger>
            <TabsTrigger value="achievements">{t('progress.achievements')}</TabsTrigger>
          </TabsList>

          {/* Weight Progress */}
          <TabsContent value="weight" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('progress.weightTrend')}</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <LineChart data={weightData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis domain={[78, 86]} />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="weight" stroke="#8b5cf6" strokeWidth={2} name={t('progress.current')} />
                    <Line type="monotone" dataKey="goal" stroke="#22c55e" strokeDasharray="5 5" name={t('progress.goal')} />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('progress.measurements')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span className="text-sm">{t('progress.currentWeight')}</span>
                    <span className="font-bold">82.5 kg</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span className="text-sm">{t('progress.startWeight')}</span>
                    <span className="font-medium text-muted-foreground">85 kg</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span className="text-sm">{t('progress.goalWeight')}</span>
                    <span className="font-medium text-muted-foreground">80 kg</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">{t('progress.remaining')}</span>
                    <span className="font-bold text-primary">2.5 kg</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Workout Progress */}
          <TabsContent value="workouts" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('progress.workoutAdherence')}</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <BarChart data={workoutData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="week" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="completed" fill="#8b5cf6" name={t('progress.completed')} />
                    <Bar dataKey="target" fill="#e5e7eb" name={t('progress.target')} />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('progress.workoutCalendar')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-7 gap-1">
                  {workoutCalendar.map((day, index) => (
                    <div
                      key={index}
                      className={`aspect-square rounded flex items-center justify-center text-xs ${
                        day.completed ? 'bg-green-500 text-white' : 'bg-muted'
                      }`}
                      title={day.date.toLocaleDateString()}
                    >
                      {day.date.getDate()}
                    </div>
                  ))}
                </div>
                <div className="flex gap-4 mt-4 text-xs">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 bg-green-500 rounded" />
                    <span>{t('progress.workoutCompleted')}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 bg-muted rounded" />
                    <span>{t('progress.restDay')}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Strength Progress */}
          <TabsContent value="strength" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('progress.strengthGains')}</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <BarChart data={strengthData} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis type="number" />
                    <YAxis dataKey="exercise" type="category" width={100} />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="previous" fill="#94a3b8" name={t('progress.previous')} />
                    <Bar dataKey="current" fill="#8b5cf6" name={t('progress.current')} />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <div className="space-y-3">
              {strengthData.map((exercise, index) => {
                const improvement = ((exercise.current - exercise.previous) / exercise.previous * 100).toFixed(1);
                return (
                  <Card key={index}>
                    <CardContent className="p-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-medium">{exercise.exercise}</h4>
                          <p className="text-sm text-muted-foreground">
                            {exercise.previous}kg → {exercise.current}kg
                          </p>
                        </div>
                        <Badge variant="secondary" className="bg-green-100 text-green-800">
                          <TrendingUp className="w-3 h-3 mr-1" />
                          +{improvement}%
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          </TabsContent>

          {/* Achievements */}
          <TabsContent value="achievements" className="space-y-3">
            {achievements.map(achievement => (
              <Card key={achievement.id} className={achievement.unlocked ? 'border-green-200 bg-green-50/50' : ''}>
                <CardContent className="p-4">
                  <div className="flex items-center gap-4">
                    <div className={`w-16 h-16 rounded-full flex items-center justify-center text-3xl ${
                      achievement.unlocked ? 'bg-green-100' : 'bg-muted grayscale opacity-50'
                    }`}>
                      {achievement.icon}
                    </div>
                    <div className="flex-1">
                      <h4 className="font-medium">{achievement.name}</h4>
                      {achievement.unlocked && achievement.date && (
                        <p className="text-sm text-muted-foreground">
                          {t('progress.unlockedOn')} {achievement.date.toLocaleDateString()}
                        </p>
                      )}
                      {!achievement.unlocked && (
                        <p className="text-sm text-muted-foreground">{t('progress.locked')}</p>
                      )}
                    </div>
                    {achievement.unlocked && (
                      <Badge variant="secondary" className="bg-green-100 text-green-800">
                        <Award className="w-3 h-3 mr-1" />
                        {t('progress.earned')}
                      </Badge>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>
      </div>
    </div>
  );
}