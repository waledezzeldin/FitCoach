import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Switch } from './ui/switch';
import { 
  Users, 
  UserCheck,
  Store,
  CreditCard,
  TrendingUp,
  Settings,
  Search,
  Filter,
  Plus,
  Edit3,
  Trash2,
  Eye,
  Ban,
  CheckCircle,
  AlertTriangle,
  DollarSign,
  Package,
  Crown,
  BarChart3,
  Calendar,
  Mail,
  Phone
} from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { UserManagementScreen } from './admin/UserManagementScreen';
import { CoachManagementScreen } from './admin/CoachManagementScreen';
import { SubscriptionManagementScreen } from './admin/SubscriptionManagementScreen';
import { StoreManagementScreen } from './admin/StoreManagementScreen';
import { ContentManagementScreen } from './admin/ContentManagementScreen';
import { AnalyticsDashboard } from './admin/AnalyticsDashboard';
import { AuditLogsScreen } from './admin/AuditLogsScreen';
import { SystemSettingsScreen } from './admin/SystemSettingsScreen';

interface AdminDashboardProps {
  userProfile: UserProfile;
  onNavigate: (screen: string) => void;
  isDemoMode: boolean;
}

interface User {
  id: string;
  name: string;
  email: string;
  subscriptionTier: string;
  status: 'active' | 'suspended' | 'inactive';
  joinDate: string;
  lastActive: string;
  coachId?: string;
}

interface Coach {
  id: string;
  name: string;
  email: string;
  specialization: string;
  clientCount: number;
  rating: number;
  status: 'active' | 'suspended';
  joinDate: string;
  revenue: number;
}

interface StoreItem {
  id: string;
  name: string;
  category: string;
  price: number;
  status: 'active' | 'inactive';
  sales: number;
  inventory: number;
}

interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  interval: 'monthly' | 'yearly';
  features: string[];
  subscriberCount: number;
  status: 'active' | 'inactive';
}

export function AdminDashboard({ userProfile, onNavigate, isDemoMode }: AdminDashboardProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');
  const [searchQuery, setSearchQuery] = useState('');
  const [showUserManagement, setShowUserManagement] = useState(false);
  const [showCoachManagement, setShowCoachManagement] = useState(false);
  const [showSubscriptionManagement, setShowSubscriptionManagement] = useState(false);
  const [showStoreManagement, setShowStoreManagement] = useState(false);
  const [showContentManagement, setShowContentManagement] = useState(false);
  const [showAnalytics, setShowAnalytics] = useState(false);
  const [showAuditLogs, setShowAuditLogs] = useState(false);
  const [showSystemSettings, setShowSystemSettings] = useState(false);

  // Demo data
  const [users] = useState<User[]>([
    {
      id: 'user_1',
      name: 'Mina H.',
      email: 'mina.h@demo.com',
      subscriptionTier: 'Smart Premium',
      status: 'active',
      joinDate: '2024-01-15',
      lastActive: '2024-01-20',
      coachId: 'coach_1'
    },
    {
      id: 'user_2',
      name: 'Ahmed M.',
      email: 'ahmed.m@demo.com',
      subscriptionTier: 'Premium',
      status: 'active',
      joinDate: '2024-01-10',
      lastActive: '2024-01-19'
    },
    {
      id: 'user_3',
      name: 'Sara K.',
      email: 'sara.k@demo.com',
      subscriptionTier: 'Freemium',
      status: 'inactive',
      joinDate: '2024-01-05',
      lastActive: '2024-01-18'
    }
  ]);

  const [coaches] = useState<Coach[]>([
    {
      id: 'coach_1',
      name: 'Sarah Johnson',
      email: 'coach@fitcoach.com',
      specialization: 'Strength Training',
      clientCount: 15,
      rating: 4.8,
      status: 'active',
      joinDate: '2023-12-01',
      revenue: 2500
    },
    {
      id: 'coach_2',
      name: 'Mike Chen',
      email: 'mike.chen@fitcoach.com',
      specialization: 'Weight Loss',
      clientCount: 12,
      rating: 4.6,
      status: 'active',
      joinDate: '2023-12-15',
      revenue: 2100
    }
  ]);

  const [storeItems] = useState<StoreItem[]>([
    {
      id: 'item_1',
      name: 'Protein Powder - Vanilla',
      category: 'Supplements',
      price: 49.99,
      status: 'active',
      sales: 150,
      inventory: 25
    },
    {
      id: 'item_2',
      name: 'Resistance Bands Set',
      category: 'Equipment',
      price: 29.99,
      status: 'active',
      sales: 89,
      inventory: 45
    },
    {
      id: 'item_3',
      name: 'Yoga Mat Premium',
      category: 'Equipment',
      price: 39.99,
      status: 'inactive',
      sales: 67,
      inventory: 0
    }
  ]);

  const [subscriptionPlans] = useState<SubscriptionPlan[]>([
    {
      id: 'plan_1',
      name: 'Freemium',
      price: 0,
      interval: 'monthly',
      features: ['Basic workouts', 'Limited nutrition plans'],
      subscriberCount: 1250,
      status: 'active'
    },
    {
      id: 'plan_2',
      name: 'Premium',
      price: 19.99,
      interval: 'monthly',
      features: ['All workouts', 'Full nutrition plans', 'Progress tracking'],
      subscriberCount: 890,
      status: 'active'
    },
    {
      id: 'plan_3',
      name: 'Smart Premium',
      price: 39.99,
      interval: 'monthly',
      features: ['Everything in Premium', 'Personal coach', 'AI recommendations'],
      subscriberCount: 456,
      status: 'active'
    }
  ]);

  const getTotalRevenue = () => {
    return subscriptionPlans.reduce((total, plan) => {
      return total + (plan.price * plan.subscriberCount);
    }, 0);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'suspended': return 'bg-red-500';
      case 'inactive': return 'bg-gray-500';
      default: return 'bg-gray-500';
    }
  };

  // Show System Settings
  if (showSystemSettings) {
    return (
      <SystemSettingsScreen
        onBack={() => setShowSystemSettings(false)}
      />
    );
  }

  // Show Audit Logs
  if (showAuditLogs) {
    return (
      <AuditLogsScreen
        onBack={() => setShowAuditLogs(false)}
      />
    );
  }

  // Show Analytics Dashboard
  if (showAnalytics) {
    return (
      <AnalyticsDashboard
        onBack={() => setShowAnalytics(false)}
      />
    );
  }

  // Show Content Management
  if (showContentManagement) {
    return (
      <ContentManagementScreen
        onBack={() => setShowContentManagement(false)}
      />
    );
  }

  // Show Store Management
  if (showStoreManagement) {
    return (
      <StoreManagementScreen
        onBack={() => setShowStoreManagement(false)}
      />
    );
  }

  // Show Subscription Management
  if (showSubscriptionManagement) {
    return (
      <SubscriptionManagementScreen
        onBack={() => setShowSubscriptionManagement(false)}
      />
    );
  }

  // Show Coach Management
  if (showCoachManagement) {
    return (
      <CoachManagementScreen
        onBack={() => setShowCoachManagement(false)}
      />
    );
  }

  // Show User Management
  if (showUserManagement) {
    return (
      <UserManagementScreen
        onBack={() => setShowUserManagement(false)}
      />
    );
  }

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
      <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-4">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-xl">Admin Dashboard</h1>
            <p className="text-white/80">Welcome back, {userProfile.name}</p>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onNavigate('account')}
            className="text-white border-white/20 hover:bg-white/10"
          >
            <Settings className="w-4 h-4 mr-2" />
            Settings
          </Button>
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="overview">
              <BarChart3 className="w-4 h-4 mr-1" />
              Overview
            </TabsTrigger>
            <TabsTrigger value="users">
              <Users className="w-4 h-4 mr-1" />
              Users
            </TabsTrigger>
            <TabsTrigger value="coaches">
              <UserCheck className="w-4 h-4 mr-1" />
              Coaches
            </TabsTrigger>
            <TabsTrigger value="store">
              <Store className="w-4 h-4 mr-1" />
              Store
            </TabsTrigger>
            <TabsTrigger value="plans">
              <CreditCard className="w-4 h-4 mr-1" />
              Plans
            </TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="mt-4 space-y-4">
            {/* Stats Cards */}
            <div className="grid grid-cols-2 gap-4">
              <Card>
                <CardContent className="p-4">
                  <div className="flex items-center space-x-2">
                    <Users className="w-5 h-5 text-blue-500" />
                    <div>
                      <p className="text-2xl font-bold">{users.length}</p>
                      <p className="text-sm text-muted-foreground">Total Users</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-4">
                  <div className="flex items-center space-x-2">
                    <UserCheck className="w-5 h-5 text-green-500" />
                    <div>
                      <p className="text-2xl font-bold">{coaches.length}</p>
                      <p className="text-sm text-muted-foreground">Active Coaches</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-4">
                  <div className="flex items-center space-x-2">
                    <DollarSign className="w-5 h-5 text-yellow-500" />
                    <div>
                      <p className="text-2xl font-bold">${getTotalRevenue().toLocaleString()}</p>
                      <p className="text-sm text-muted-foreground">Monthly Revenue</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-4">
                  <div className="flex items-center space-x-2">
                    <Package className="w-5 h-5 text-purple-500" />
                    <div>
                      <p className="text-2xl font-bold">{storeItems.length}</p>
                      <p className="text-sm text-muted-foreground">Store Items</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Admin Management Tools */}
            <Card>
              <CardHeader>
                <CardTitle>Management Tools</CardTitle>
              </CardHeader>
              <CardContent className="grid grid-cols-2 gap-3">
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowUserManagement(true)}
                >
                  <Users className="w-4 h-4 mr-2" />
                  User Management
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowCoachManagement(true)}
                >
                  <UserCheck className="w-4 h-4 mr-2" />
                  Coach Management
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowSubscriptionManagement(true)}
                >
                  <CreditCard className="w-4 h-4 mr-2" />
                  Subscriptions
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowStoreManagement(true)}
                >
                  <Store className="w-4 h-4 mr-2" />
                  Store Management
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowContentManagement(true)}
                >
                  <Edit3 className="w-4 h-4 mr-2" />
                  Content Management
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowAnalytics(true)}
                >
                  <BarChart3 className="w-4 h-4 mr-2" />
                  Analytics
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowAuditLogs(true)}
                >
                  <Eye className="w-4 h-4 mr-2" />
                  Audit Logs
                </Button>
                <Button 
                  variant="outline" 
                  className="justify-start"
                  onClick={() => setShowSystemSettings(true)}
                >
                  <Settings className="w-4 h-4 mr-2" />
                  System Settings
                </Button>
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card>
              <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center space-x-3 p-2 bg-muted rounded">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  <div className="flex-1">
                    <p className="text-sm">New user registered: Ahmed M.</p>
                    <p className="text-xs text-muted-foreground">2 hours ago</p>
                  </div>
                </div>
                <div className="flex items-center space-x-3 p-2 bg-muted rounded">
                  <Crown className="w-4 h-4 text-yellow-500" />
                  <div className="flex-1">
                    <p className="text-sm">Mina H. upgraded to Smart Premium</p>
                    <p className="text-xs text-muted-foreground">4 hours ago</p>
                  </div>
                </div>
                <div className="flex items-center space-x-3 p-2 bg-muted rounded">
                  <Package className="w-4 h-4 text-blue-500" />
                  <div className="flex-1">
                    <p className="text-sm">Store item sold: Protein Powder</p>
                    <p className="text-xs text-muted-foreground">6 hours ago</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Users Tab */}
          <TabsContent value="users" className="mt-4 space-y-4">
            <div className="flex gap-2">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input
                  placeholder="Search users..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10"
                />
              </div>
              <Button variant="outline">
                <Filter className="w-4 h-4 mr-2" />
                Filter
              </Button>
            </div>

            {users.map((user) => (
              <Card key={user.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <Avatar>
                        <AvatarFallback>{user.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                      </Avatar>
                      <div>
                        <h3 className="font-medium">{user.name}</h3>
                        <p className="text-sm text-muted-foreground">{user.email}</p>
                        <div className="flex items-center gap-2 mt-1">
                          <Badge variant="outline">{user.subscriptionTier}</Badge>
                          <div className={`w-2 h-2 rounded-full ${getStatusColor(user.status)}`}></div>
                          <span className="text-xs text-muted-foreground capitalize">{user.status}</span>
                        </div>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline">
                        <Eye className="w-3 h-3" />
                      </Button>
                      <Button size="sm" variant="outline">
                        <Edit3 className="w-3 h-3" />
                      </Button>
                      <Button size="sm" variant="outline">
                        <Ban className="w-3 h-3" />
                      </Button>
                    </div>
                  </div>
                  <div className="mt-3 text-xs text-muted-foreground">
                    <p>Joined: {user.joinDate} • Last active: {user.lastActive}</p>
                    {user.coachId && <p>Coach assigned: Yes</p>}
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          {/* Coaches Tab */}
          <TabsContent value="coaches" className="mt-4 space-y-4">
            <div className="flex justify-between items-center">
              <div className="relative flex-1 mr-2">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input
                  placeholder="Search coaches..."
                  className="pl-10"
                />
              </div>
              <Button>
                <Plus className="w-4 h-4 mr-2" />
                Add Coach
              </Button>
            </div>

            {coaches.map((coach) => (
              <Card key={coach.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <Avatar>
                        <AvatarFallback>{coach.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                      </Avatar>
                      <div>
                        <h3 className="font-medium">{coach.name}</h3>
                        <p className="text-sm text-muted-foreground">{coach.email}</p>
                        <div className="flex items-center gap-2 mt-1">
                          <Badge variant="outline">{coach.specialization}</Badge>
                          <div className="flex items-center">
                            <span className="text-yellow-500">★</span>
                            <span className="text-xs ml-1">{coach.rating}</span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium">{coach.clientCount} clients</p>
                      <p className="text-sm text-muted-foreground">${coach.revenue}/month</p>
                      <div className="flex gap-2 mt-2">
                        <Button size="sm" variant="outline">
                          <Eye className="w-3 h-3" />
                        </Button>
                        <Button size="sm" variant="outline">
                          <Edit3 className="w-3 h-3" />
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          {/* Store Tab */}
          <TabsContent value="store" className="mt-4 space-y-4">
            <div className="flex justify-between items-center">
              <div className="relative flex-1 mr-2">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input
                  placeholder="Search store items..."
                  className="pl-10"
                />
              </div>
              <Button>
                <Plus className="w-4 h-4 mr-2" />
                Add Item
              </Button>
            </div>

            {storeItems.map((item) => (
              <Card key={item.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <h3 className="font-medium">{item.name}</h3>
                      <p className="text-sm text-muted-foreground">{item.category}</p>
                      <div className="flex items-center gap-4 mt-2">
                        <Badge variant={item.status === 'active' ? 'default' : 'secondary'}>
                          {item.status}
                        </Badge>
                        <span className="text-sm text-muted-foreground">
                          {item.sales} sold • {item.inventory} in stock
                        </span>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-medium">${item.price}</p>
                      <div className="flex gap-2 mt-2">
                        <Button size="sm" variant="outline">
                          <Edit3 className="w-3 h-3" />
                        </Button>
                        <Button size="sm" variant="outline">
                          <Trash2 className="w-3 h-3" />
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          {/* Subscription Plans Tab */}
          <TabsContent value="plans" className="mt-4 space-y-4">
            <div className="flex justify-between items-center">
              <h2 className="text-lg font-medium">Subscription Plans</h2>
              <Button>
                <Plus className="w-4 h-4 mr-2" />
                Add Plan
              </Button>
            </div>

            {subscriptionPlans.map((plan) => (
              <Card key={plan.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <h3 className="font-medium">{plan.name}</h3>
                        {plan.name === 'Smart Premium' && <Crown className="w-4 h-4 text-yellow-500" />}
                      </div>
                      <p className="text-2xl font-bold mt-1">
                        ${plan.price}
                        <span className="text-sm font-normal text-muted-foreground">
                          /{plan.interval}
                        </span>
                      </p>
                      <div className="mt-2">
                        <Badge variant={plan.status === 'active' ? 'default' : 'secondary'}>
                          {plan.status}
                        </Badge>
                        <span className="text-sm text-muted-foreground ml-2">
                          {plan.subscriberCount} subscribers
                        </span>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium">
                        ${(plan.price * plan.subscriberCount).toLocaleString()}/month revenue
                      </p>
                      <div className="flex gap-2 mt-2">
                        <Button size="sm" variant="outline">
                          <Edit3 className="w-3 h-3" />
                        </Button>
                        <Switch 
                          checked={plan.status === 'active'}
                        />
                      </div>
                    </div>
                  </div>
                  <div className="mt-3">
                    <p className="text-sm text-muted-foreground mb-1">Features:</p>
                    <ul className="text-xs text-muted-foreground space-y-1">
                      {plan.features.map((feature, index) => (
                        <li key={index}>• {feature}</li>
                      ))}
                    </ul>
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