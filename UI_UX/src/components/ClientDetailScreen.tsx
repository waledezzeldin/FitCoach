import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { ScrollArea } from './ui/scroll-area';
import {
  ArrowLeft,
  MessageCircle,
  Video,
  TrendingUp,
  TrendingDown,
  Calendar,
  Activity,
  Apple,
  Dumbbell,
  Award,
  Edit,
  CheckCircle,
  XCircle,
  Clock
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';

interface Client {
  id: string;
  name: string;
  email: string;
  joinDate: Date;
  lastActivity: Date;
  goal: string;
  status: 'active' | 'new' | 'inactive';
  subscriptionTier: 'Freemium' | 'Premium' | 'Smart Premium';
  progress: number;
  fitnessScore: number;
  avatar?: string;
}

interface ClientDetailScreenProps {
  client: Client;
  onBack: () => void;
  onMessage: () => void;
  onCall: () => void;
  onAssignPlan: () => void;
  onEditFitnessScore: () => void;
}

export function ClientDetailScreen({
  client,
  onBack,
  onMessage,
  onCall,
  onAssignPlan,
  onEditFitnessScore
}: ClientDetailScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');

  // Mock progress data
  const progressData = [
    { week: 'Week 1', weight: 85, fitnessScore: 55 },
    { week: 'Week 2', weight: 84.5, fitnessScore: 58 },
    { week: 'Week 3', weight: 84, fitnessScore: 62 },
    { week: 'Week 4', weight: 83.5, fitnessScore: 68 },
  ];

  // Mock workout data
  const workoutData = [
    { day: 'Mon', completed: 1, total: 1 },
    { day: 'Tue', completed: 1, total: 1 },
    { day: 'Wed', completed: 0, total: 1 },
    { day: 'Thu', completed: 1, total: 1 },
    { day: 'Fri', completed: 1, total: 1 },
    { day: 'Sat', completed: 1, total: 1 },
    { day: 'Sun', completed: 0, total: 0 },
  ];

  // Mock workout history
  const recentWorkouts = [
    {
      id: '1',
      name: 'Upper Body Strength',
      date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      duration: 45,
      completed: true
    },
    {
      id: '2',
      name: 'Lower Body Power',
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      duration: 50,
      completed: true
    },
    {
      id: '3',
      name: 'Core & Cardio',
      date: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      duration: 30,
      completed: false
    },
  ];

  // Mock InBody data
  const inBodyData = {
    weight: 83.5,
    muscleMass: 38.2,
    bodyFatPercentage: 18.5,
    bmr: 1850,
    inBodyScore: 78,
    lastUpdated: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000)
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'new': return 'bg-blue-500';
      case 'inactive': return 'bg-yellow-500';
      default: return 'bg-gray-500';
    }
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric',
      year: 'numeric'
    });
  };

  const getDaysSinceJoin = () => {
    const days = Math.floor((Date.now() - client.joinDate.getTime()) / (1000 * 60 * 60 * 24));
    return days;
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
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
            <h1 className="text-xl font-semibold">{t('coach.clientDetails')}</h1>
          </div>
        </div>

        {/* Client Info Card */}
        <Card className="bg-white/10 border-white/20">
          <CardContent className="p-4">
            <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <Avatar className="w-16 h-16">
                <AvatarImage src={client.avatar} />
                <AvatarFallback className="bg-white/20 text-white text-xl">
                  {client.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              
              <div className="flex-1">
                <h2 className="text-xl font-bold text-white">{client.name}</h2>
                <p className="text-white/80 text-sm">{client.email}</p>
                
                <div className={`flex gap-2 mt-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <Badge variant="secondary">
                    {client.subscriptionTier}
                  </Badge>
                  <Badge 
                    className={getStatusColor(client.status)}
                  >
                    {t(`coach.status.${client.status}`)}
                  </Badge>
                </div>

                <p className="text-white/70 text-sm mt-2">
                  {t('coach.memberFor')} {getDaysSinceJoin()} {t('coach.days')}
                </p>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-3 gap-2 mt-4">
              <Button
                variant="secondary"
                size="sm"
                onClick={onMessage}
              >
                <MessageCircle className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('coach.message')}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={onCall}
              >
                <Video className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('coach.call')}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={onAssignPlan}
              >
                <Dumbbell className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
                {t('coach.assignPlan')}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="p-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">{t('coach.overview')}</TabsTrigger>
          <TabsTrigger value="workouts">{t('coach.workouts')}</TabsTrigger>
          <TabsTrigger value="nutrition">{t('coach.nutrition')}</TabsTrigger>
          <TabsTrigger value="inbody">{t('coach.inbody')}</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-4">
          {/* Stats Grid */}
          <div className="grid grid-cols-2 gap-3">
            <Card>
              <CardContent className="p-4">
                <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div>
                    <p className="text-sm text-muted-foreground">{t('coach.fitnessScore')}</p>
                    <p className="text-2xl font-bold">{client.fitnessScore}</p>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={onEditFitnessScore}
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                </div>
                <Progress value={client.fitnessScore} className="mt-2" />
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.progress')}</p>
                <p className="text-2xl font-bold">{client.progress}%</p>
                <Progress value={client.progress} className="mt-2" />
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.goal')}</p>
                <p className="font-semibold">{client.goal}</p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">{t('coach.lastActive')}</p>
                <p className="text-sm font-medium">
                  {formatDate(client.lastActivity)}
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Progress Chart */}
          <Card>
            <CardHeader>
              <CardTitle>{t('coach.progressOverTime')}</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={progressData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="week" />
                  <YAxis />
                  <Tooltip />
                  <Line 
                    type="monotone" 
                    dataKey="fitnessScore" 
                    stroke="#8b5cf6" 
                    strokeWidth={2}
                    name={t('coach.fitnessScore')}
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Weekly Activity */}
          <Card>
            <CardHeader>
              <CardTitle>{t('coach.weeklyActivity')}</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={150}>
                <BarChart data={workoutData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="day" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="completed" fill="#10b981" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Workouts Tab */}
        <TabsContent value="workouts" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>{t('coach.recentWorkouts')}</CardTitle>
            </CardHeader>
            <CardContent>
              <ScrollArea className="h-96">
                {recentWorkouts.map(workout => (
                  <div 
                    key={workout.id} 
                    className={`flex items-center justify-between p-3 border-b last:border-0 ${isRTL ? 'flex-row-reverse' : ''}`}
                  >
                    <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      {workout.completed ? (
                        <CheckCircle className="w-5 h-5 text-green-500" />
                      ) : (
                        <XCircle className="w-5 h-5 text-red-500" />
                      )}
                      <div>
                        <p className="font-medium">{workout.name}</p>
                        <p className="text-sm text-muted-foreground">
                          {formatDate(workout.date)} • {workout.duration} {t('coach.minutes')}
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </ScrollArea>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Nutrition Tab */}
        <TabsContent value="nutrition" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>{t('coach.nutritionAdherence')}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <div className={`flex justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <span className="text-sm">{t('nutrition.calories')}</span>
                    <span className="text-sm font-medium">85%</span>
                  </div>
                  <Progress value={85} />
                </div>
                <div>
                  <div className={`flex justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <span className="text-sm">{t('nutrition.protein')}</span>
                    <span className="text-sm font-medium">92%</span>
                  </div>
                  <Progress value={92} />
                </div>
                <div>
                  <div className={`flex justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <span className="text-sm">{t('nutrition.carbs')}</span>
                    <span className="text-sm font-medium">78%</span>
                  </div>
                  <Progress value={78} />
                </div>
                <div>
                  <div className={`flex justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <span className="text-sm">{t('nutrition.fats')}</span>
                    <span className="text-sm font-medium">88%</span>
                  </div>
                  <Progress value={88} />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* InBody Tab */}
        <TabsContent value="inbody" className="space-y-4">
          <Card>
            <CardHeader>
              <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                <CardTitle>{t('coach.latestInBody')}</CardTitle>
                <Badge variant="outline">
                  {formatDate(inBodyData.lastUpdated)}
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center p-3 bg-accent rounded-lg">
                  <p className="text-sm text-muted-foreground">{t('inbody.weight')}</p>
                  <p className="text-2xl font-bold">{inBodyData.weight} kg</p>
                </div>
                <div className="text-center p-3 bg-accent rounded-lg">
                  <p className="text-sm text-muted-foreground">{t('inbody.muscleMass')}</p>
                  <p className="text-2xl font-bold">{inBodyData.muscleMass} kg</p>
                </div>
                <div className="text-center p-3 bg-accent rounded-lg">
                  <p className="text-sm text-muted-foreground">{t('inbody.bodyFatPercentage')}</p>
                  <p className="text-2xl font-bold">{inBodyData.bodyFatPercentage}%</p>
                </div>
                <div className="text-center p-3 bg-accent rounded-lg">
                  <p className="text-sm text-muted-foreground">{t('inbody.bmr')}</p>
                  <p className="text-2xl font-bold">{inBodyData.bmr}</p>
                </div>
                <div className="col-span-2 text-center p-4 bg-primary text-primary-foreground rounded-lg">
                  <p className="text-sm">{t('inbody.inBodyScore')}</p>
                  <p className="text-3xl font-bold">{inBodyData.inBodyScore}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
