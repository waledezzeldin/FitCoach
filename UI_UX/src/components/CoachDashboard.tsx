import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  Users, 
  Calendar,
  MessageCircle,
  TrendingUp,
  Clock,
  Video,
  CheckCircle,
  AlertTriangle,
  User,
  Settings,
  BarChart3,
  ClipboardList,
  Dumbbell,
  Apple
} from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { ClientPlanManager } from './ClientPlanManager';
import { FitnessScoreAssignmentDialog } from './FitnessScoreAssignmentDialog';
import { WorkoutPlanBuilder } from './WorkoutPlanBuilder';
import { NutritionPlanBuilder } from './NutritionPlanBuilder';
import { CoachCalendarScreen } from './CoachCalendarScreen';
import { CoachMessagingScreen } from './CoachMessagingScreen';
import { CoachSettingsScreen } from './CoachSettingsScreen';
import { ClientDetailScreen } from './ClientDetailScreen';
import { toast } from 'sonner@2.0.3';

interface CoachDashboardProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'workout' | 'nutrition' | 'coach' | 'store' | 'account') => void;
  isDemoMode: boolean;
}

interface Client {
  id: string;
  name: string;
  email: string;
  joinDate: Date;
  lastActivity: Date;
  goal: string;
  status: 'active' | 'inactive' | 'new';
  subscriptionTier: string;
  progress: number;
  fitnessScore?: number;
}

interface Appointment {
  id: string;
  clientName: string;
  date: Date;
  time: string;
  duration: number;
  type: 'video' | 'chat' | 'assessment';
  status: 'upcoming' | 'completed' | 'missed';
}

export function CoachDashboard({ userProfile, onNavigate, isDemoMode }: CoachDashboardProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedClientForPlans, setSelectedClientForPlans] = useState<string | null>(null);
  const [selectedClientDetail, setSelectedClientDetail] = useState<string | null>(null);
  const [showWorkoutBuilder, setShowWorkoutBuilder] = useState(false);
  const [showNutritionBuilder, setShowNutritionBuilder] = useState(false);
  const [showCalendar, setShowCalendar] = useState(false);
  const [showMessaging, setShowMessaging] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [fitnessScoreDialog, setFitnessScoreDialog] = useState<{
    open: boolean;
    clientId: string;
    clientName: string;
    currentScore: number;
  } | null>(null);

  // Demo clients data
  const clients: Client[] = [
    {
      id: '1',
      name: 'Mina H.',
      email: 'mina.h@demo.com',
      joinDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
      lastActivity: new Date(Date.now() - 2 * 60 * 60 * 1000),
      goal: 'Muscle Gain',
      status: 'active',
      subscriptionTier: 'Smart Premium',
      progress: 85,
      fitnessScore: 82
    },
    {
      id: '2',
      name: 'Ahmed K.',
      email: 'ahmed.k@demo.com',
      joinDate: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000),
      lastActivity: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      goal: 'Fat Loss',
      status: 'active',
      subscriptionTier: 'Premium',
      progress: 72,
      fitnessScore: 68
    },
    {
      id: '3',
      name: 'Fatima A.',
      email: 'fatima.a@demo.com',
      joinDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      lastActivity: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      goal: 'General Fitness',
      status: 'new',
      subscriptionTier: 'Freemium',
      progress: 45,
      fitnessScore: 55
    },
    {
      id: '4',
      name: 'Omar S.',
      email: 'omar.s@demo.com',
      joinDate: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000),
      lastActivity: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
      goal: 'Strength Training',
      status: 'inactive',
      subscriptionTier: 'Premium',
      progress: 35,
      fitnessScore: 48
    }
  ];

  // Demo appointments
  const appointments: Appointment[] = [
    {
      id: '1',
      clientName: 'Mina H.',
      date: new Date(Date.now() + 2 * 60 * 60 * 1000),
      time: '14:00',
      duration: 30,
      type: 'video',
      status: 'upcoming'
    },
    {
      id: '2',
      clientName: 'Ahmed K.',
      date: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000),
      time: '16:00',
      duration: 45,
      type: 'assessment',
      status: 'upcoming'
    },
    {
      id: '3',
      clientName: 'Fatima A.',
      date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      time: '15:00',
      duration: 30,
      type: 'video',
      status: 'completed'
    }
  ];

  const stats = {
    totalClients: clients.length,
    activeClients: clients.filter(c => c.status === 'active').length,
    upcomingAppointments: appointments.filter(a => a.status === 'upcoming').length,
    completedThisWeek: appointments.filter(a => 
      a.status === 'completed' && 
      a.date > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    ).length
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'new': return 'bg-blue-500';
      case 'inactive': return 'bg-yellow-500';
      default: return 'bg-gray-500';
    }
  };

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: true 
    });
  };

  const formatDate = (date: Date) => {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === tomorrow.toDateString()) {
      return 'Tomorrow';
    } else {
      return date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric' 
      });
    }
  };

  const handleUpdateFitnessScore = (newScore: number, reason: string) => {
    // In a real app, this would update the backend
    // For demo, we just show a toast notification
    console.log(`Updating fitness score for ${fitnessScoreDialog?.clientName} to ${newScore}. Reason: ${reason}`);
    toast.success(`Fitness score updated to ${newScore}. Workout plan will adjust automatically.`);
    setFitnessScoreDialog(null);
  };

  // Show Settings Screen
  if (showSettings) {
    return (
      <CoachSettingsScreen
        userProfile={userProfile}
        onBack={() => setShowSettings(false)}
        onUpdateProfile={(profile) => {
          toast.success('Settings updated');
          setShowSettings(false);
        }}
      />
    );
  }

  // Show Messaging Screen
  if (showMessaging) {
    return (
      <CoachMessagingScreen
        userProfile={userProfile}
        onBack={() => setShowMessaging(false)}
        onNavigateToClientDetail={(clientId) => {
          setShowMessaging(false);
          setSelectedClientDetail(clientId);
        }}
      />
    );
  }

  // Show Calendar Screen
  if (showCalendar) {
    return (
      <CoachCalendarScreen
        onBack={() => setShowCalendar(false)}
      />
    );
  }

  // Show Nutrition Plan Builder
  if (showNutritionBuilder) {
    return (
      <NutritionPlanBuilder
        onBack={() => setShowNutritionBuilder(false)}
        onSave={(plan) => {
          toast.success('Nutrition plan saved');
          setShowNutritionBuilder(false);
        }}
      />
    );
  }

  // Show Workout Plan Builder
  if (showWorkoutBuilder) {
    return (
      <WorkoutPlanBuilder
        onBack={() => setShowWorkoutBuilder(false)}
        onSave={(plan) => {
          toast.success('Workout plan saved');
          setShowWorkoutBuilder(false);
        }}
      />
    );
  }

  // Show Client Detail Screen
  if (selectedClientDetail) {
    const client = clients.find(c => c.id === selectedClientDetail);
    if (client) {
      return (
        <ClientDetailScreen
          client={{
            ...client,
            phone: '+966501234567',
            fitnessScore: client.fitnessScore || 0,
            workoutPlan: client.currentWorkoutPlan || null,
            nutritionPlan: client.currentNutritionPlan || null
          }}
          onBack={() => setSelectedClientDetail(null)}
          onManagePlans={() => {
            setSelectedClientDetail(null);
            setSelectedClientForPlans(client.id);
          }}
          onUpdateFitnessScore={(score) => {
            toast.success(`Fitness score updated to ${score}`);
          }}
        />
      );
    }
  }

  // Show ClientPlanManager if a client is selected
  if (selectedClientForPlans) {
    return (
      <ClientPlanManager
        clientId={selectedClientForPlans}
        onBack={() => setSelectedClientForPlans(null)}
        isDemoMode={isDemoMode}
      />
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.8
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-purple-600 text-white p-4">
        <div className={`flex items-center justify-between mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <div>
            <h1 className="text-2xl font-bold">Coach Dashboard</h1>
            <p className="text-white/80">Welcome back, {userProfile.name}</p>
          </div>
          <div className="flex gap-2">
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => onNavigate('account')}
              className="text-white hover:bg-white/20"
            >
              <Settings className="w-5 h-5" />
            </Button>
          </div>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white/10 rounded-xl p-3 text-center">
            <div className="text-2xl font-bold">{stats.totalClients}</div>
            <div className="text-xs text-white/80">Total Clients</div>
          </div>
          <div className="bg-white/10 rounded-xl p-3 text-center">
            <div className="text-2xl font-bold">{stats.activeClients}</div>
            <div className="text-xs text-white/80">Active Clients</div>
          </div>
          <div className="bg-white/10 rounded-xl p-3 text-center">
            <div className="text-2xl font-bold">{stats.upcomingAppointments}</div>
            <div className="text-xs text-white/80">Upcoming Sessions</div>
          </div>
          <div className="bg-white/10 rounded-xl p-3 text-center">
            <div className="text-2xl font-bold">{stats.completedThisWeek}</div>
            <div className="text-xs text-white/80">This Week</div>
          </div>
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="clients">Clients</TabsTrigger>
            <TabsTrigger value="schedule">Schedule</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="mt-4 space-y-4">
            {/* Quick Actions */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Quick Actions</CardTitle>
              </CardHeader>
              <CardContent className="grid grid-cols-2 gap-3">
                <Button 
                  variant="outline" 
                  className="h-16 flex flex-col"
                  onClick={() => setShowMessaging(true)}
                >
                  <MessageCircle className="w-5 h-5 mb-1" />
                  <span className="text-xs">Message Client</span>
                </Button>
                <Button 
                  variant="outline" 
                  className="h-16 flex flex-col"
                  onClick={() => setShowCalendar(true)}
                >
                  <Video className="w-5 h-5 mb-1" />
                  <span className="text-xs">Schedule Session</span>
                </Button>
                <Button 
                  variant="outline" 
                  className="h-16 flex flex-col"
                  onClick={() => toast.info('Add client feature coming soon')}
                >
                  <Users className="w-5 h-5 mb-1" />
                  <span className="text-xs">Add Client</span>
                </Button>
              </CardContent>
            </Card>

            {/* Coach Tools */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Coach Tools</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => setShowWorkoutBuilder(true)}
                >
                  <Dumbbell className="w-4 h-4 mr-2" />
                  Create Workout Plan
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => setShowNutritionBuilder(true)}
                >
                  <Apple className="w-4 h-4 mr-2" />
                  Create Nutrition Plan
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => setShowCalendar(true)}
                >
                  <Calendar className="w-4 h-4 mr-2" />
                  Manage Calendar
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => setShowSettings(true)}
                >
                  <Settings className="w-4 h-4 mr-2" />
                  Coach Settings
                </Button>
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recent Activity</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center gap-3 p-2 rounded-lg bg-muted">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  <div className="flex-1">
                    <div className="text-sm">Session completed with Mina H.</div>
                    <div className="text-xs text-muted-foreground">2 hours ago</div>
                  </div>
                </div>
                <div className="flex items-center gap-3 p-2 rounded-lg bg-muted">
                  <MessageCircle className="w-4 h-4 text-blue-500" />
                  <div className="flex-1">
                    <div className="text-sm">New message from Ahmed K.</div>
                    <div className="text-xs text-muted-foreground">4 hours ago</div>
                  </div>
                </div>
                <div className="flex items-center gap-3 p-2 rounded-lg bg-muted">
                  <User className="w-4 h-4 text-purple-500" />
                  <div className="flex-1">
                    <div className="text-sm">Fatima A. joined your program</div>
                    <div className="text-xs text-muted-foreground">1 day ago</div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Today's Schedule */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Today's Schedule</CardTitle>
              </CardHeader>
              <CardContent>
                {appointments.filter(a => 
                  a.status === 'upcoming' && 
                  a.date.toDateString() === new Date().toDateString()
                ).length > 0 ? (
                  <div className="space-y-3">
                    {appointments.filter(a => 
                      a.status === 'upcoming' && 
                      a.date.toDateString() === new Date().toDateString()
                    ).map((appointment) => (
                      <div key={appointment.id} className="flex items-center justify-between p-3 border rounded-lg">
                        <div className="flex items-center gap-3">
                          <div className="w-2 h-2 rounded-full bg-blue-500" />
                          <div>
                            <div className="text-sm font-medium">{appointment.clientName}</div>
                            <div className="text-xs text-muted-foreground">
                              {appointment.time} • {appointment.duration} min
                            </div>
                          </div>
                        </div>
                        <Badge variant="outline">
                          {appointment.type === 'video' ? 'Video' : 'Assessment'}
                        </Badge>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8 text-muted-foreground">
                    <Calendar className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <p>No sessions scheduled for today</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="clients" className="mt-4 space-y-4">
            {/* Client Filters */}
            <div className="flex gap-2 overflow-x-auto pb-2">
              <Badge variant="default">All ({clients.length})</Badge>
              <Badge variant="outline">Active ({clients.filter(c => c.status === 'active').length})</Badge>
              <Badge variant="outline">New ({clients.filter(c => c.status === 'new').length})</Badge>
              <Badge variant="outline">Inactive ({clients.filter(c => c.status === 'inactive').length})</Badge>
            </div>

            {/* Clients List */}
            <div className="space-y-3">
              {clients.map((client) => (
                <Card 
                  key={client.id} 
                  className="cursor-pointer hover:bg-muted/50 transition-colors"
                  onClick={() => setSelectedClientDetail(client.id)}
                >
                  <CardContent className="p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <Avatar className="w-10 h-10">
                          <AvatarFallback>
                            {client.name.split(' ').map(n => n[0]).join('')}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">{client.name}</div>
                          <div className="text-xs text-muted-foreground">{client.goal}</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className={`w-3 h-3 rounded-full ${getStatusColor(client.status)} mb-1`} />
                        <div className="text-xs text-muted-foreground capitalize">{client.status}</div>
                      </div>
                    </div>
                    
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span>Progress</span>
                        <span>{client.progress}%</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div 
                          className="bg-primary h-2 rounded-full" 
                          style={{ width: `${client.progress}%` }}
                        />
                      </div>
                      <div className="flex justify-between text-xs text-muted-foreground">
                        <span>Last active: {formatDate(client.lastActivity)}</span>
                        <span>{client.subscriptionTier}</span>
                      </div>
                    </div>
                    
                    {/* Fitness Score Display */}
                    {client.fitnessScore && (
                      <div className="flex items-center justify-between p-2 bg-muted rounded-lg mt-2">
                        <span className="text-xs text-muted-foreground">Fitness Score</span>
                        <Badge variant="secondary" className="font-semibold">
                          {client.fitnessScore}/100
                        </Badge>
                      </div>
                    )}
                    
                    <div className="grid grid-cols-2 gap-2 mt-3" onClick={(e) => e.stopPropagation()}>
                      <Button 
                        size="sm" 
                        variant="outline"
                        onClick={(e) => {
                          e.stopPropagation();
                          setShowMessaging(true);
                        }}
                      >
                        <MessageCircle className="w-3 h-3 mr-1" />
                        Message
                      </Button>
                      <Button 
                        size="sm" 
                        variant="outline"
                        onClick={(e) => {
                          e.stopPropagation();
                          setShowCalendar(true);
                        }}
                      >
                        <Video className="w-3 h-3 mr-1" />
                        Schedule
                      </Button>
                      <Button 
                        size="sm" 
                        variant="outline"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedClientForPlans(client.id);
                        }}
                      >
                        <ClipboardList className="w-3 h-3 mr-1" />
                        Plans
                      </Button>
                      <Button 
                        size="sm" 
                        variant="outline"
                        onClick={(e) => {
                          e.stopPropagation();
                          setFitnessScoreDialog({
                            open: true,
                            clientId: client.id,
                            clientName: client.name,
                            currentScore: client.fitnessScore || 50
                          });
                        }}
                      >
                        <TrendingUp className="w-3 h-3 mr-1" />
                        Score
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          <TabsContent value="schedule" className="mt-4 space-y-4">
            {/* Schedule Overview */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Upcoming Sessions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {appointments.filter(a => a.status === 'upcoming').map((appointment) => (
                  <div key={appointment.id} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className="w-3 h-3 rounded-full bg-blue-500" />
                      <div>
                        <div className="text-sm font-medium">{appointment.clientName}</div>
                        <div className="text-xs text-muted-foreground">
                          {formatDate(appointment.date)} at {appointment.time}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <Badge variant="outline" className="mb-1">
                        {appointment.type === 'video' ? <Video className="w-3 h-3 mr-1" /> : <User className="w-3 h-3 mr-1" />}
                        {appointment.duration} min
                      </Badge>
                    </div>
                  </div>
                ))}
                
                {appointments.filter(a => a.status === 'upcoming').length === 0 && (
                  <div className="text-center py-8 text-muted-foreground">
                    <Calendar className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <p>No upcoming sessions</p>
                    <Button variant="outline" className="mt-4">
                      <Video className="w-4 h-4 mr-2" />
                      Schedule New Session
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Recent Completed Sessions */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recent Sessions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {appointments.filter(a => a.status === 'completed').map((appointment) => (
                  <div key={appointment.id} className="flex items-center justify-between p-3 border rounded-lg opacity-75">
                    <div className="flex items-center gap-3">
                      <CheckCircle className="w-4 h-4 text-green-500" />
                      <div>
                        <div className="text-sm font-medium">{appointment.clientName}</div>
                        <div className="text-xs text-muted-foreground">
                          {formatDate(appointment.date)} at {appointment.time}
                        </div>
                      </div>
                    </div>
                    <Badge variant="outline" className="text-green-600">
                      Completed
                    </Badge>
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>

      {/* Fitness Score Assignment Dialog */}
      {fitnessScoreDialog && (
        <FitnessScoreAssignmentDialog
          open={fitnessScoreDialog.open}
          onClose={() => setFitnessScoreDialog(null)}
          clientName={fitnessScoreDialog.clientName}
          currentScore={fitnessScoreDialog.currentScore}
          onUpdateScore={handleUpdateFitnessScore}
        />
      )}
      </div>
    </div>
  );
}