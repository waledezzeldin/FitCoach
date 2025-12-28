import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback } from './ui/avatar';
import { 
  Users, 
  UserCheck,
  Store,
  CreditCard,
  TrendingUp,
  Settings,
  DollarSign,
  Package,
  Crown,
  BarChart3,
  Edit3,
  Eye,
  CheckCircle,
  LayoutDashboard,
  FileText,
  ChevronRight,
  ChevronDown,
  Menu
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
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuTrigger,
  DropdownMenuSeparator 
} from './ui/dropdown-menu';

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

type NavigationItem = 
  | 'overview'
  | 'users'
  | 'coaches'
  | 'subscriptions'
  | 'store'
  | 'content'
  | 'analytics'
  | 'updates'
  | 'audit'
  | 'settings';

export function AdminDashboard({ userProfile, onNavigate, isDemoMode }: AdminDashboardProps) {
  const { t, isRTL } = useLanguage();
  const [activeSection, setActiveSection] = useState<NavigationItem>('overview');

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

  const navigationItems = [
    { id: 'overview' as NavigationItem, icon: LayoutDashboard, label: t('admin.overview') },
    { id: 'users' as NavigationItem, icon: Users, label: t('admin.userManagement') },
    { id: 'coaches' as NavigationItem, icon: UserCheck, label: t('admin.coachManagement') },
    { id: 'subscriptions' as NavigationItem, icon: CreditCard, label: t('admin.subscriptionPlans') },
    { id: 'store' as NavigationItem, icon: Store, label: t('admin.storeManagement') },
    { id: 'content' as NavigationItem, icon: Edit3, label: 'Content Management' },
    { id: 'analytics' as NavigationItem, icon: BarChart3, label: 'Analytics' },
    { id: 'updates' as NavigationItem, icon: TrendingUp, label: 'Updates' },
    { id: 'audit' as NavigationItem, icon: FileText, label: t('admin.auditLogs') },
    { id: 'settings' as NavigationItem, icon: Settings, label: t('admin.settings') },
  ];

  // Handle navigation between management screens
  if (activeSection === 'users') {
    return (
      <UserManagementScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'coaches') {
    return (
      <CoachManagementScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'subscriptions') {
    return (
      <SubscriptionManagementScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'store') {
    return (
      <StoreManagementScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'content') {
    return (
      <ContentManagementScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'analytics') {
    return (
      <AnalyticsDashboard
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  // Show Updates/Recent Activity
  if (activeSection === 'updates') {
    return (
      <div className="min-h-screen bg-background">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-6">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setActiveSection('overview')}
              className="text-white hover:bg-white/10"
            >
              ← {isRTL ? 'رجوع' : 'Back'}
            </Button>
            <div>
              <h1 className="text-2xl font-semibold">Recent Updates</h1>
              <p className="text-white/80">Platform activity and notifications</p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <Card>
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-green-100 dark:bg-green-950 rounded-full flex items-center justify-center">
                  <CheckCircle className="w-4 h-4 text-green-600 dark:text-green-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">New user registered: Ahmed M.</p>
                  <p className="text-xs text-muted-foreground">2 hours ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-yellow-100 dark:bg-yellow-950 rounded-full flex items-center justify-center">
                  <Crown className="w-4 h-4 text-yellow-600 dark:text-yellow-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Mina H. upgraded to Smart Premium</p>
                  <p className="text-xs text-muted-foreground">4 hours ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-blue-100 dark:bg-blue-950 rounded-full flex items-center justify-center">
                  <Package className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Store item sold: Protein Powder</p>
                  <p className="text-xs text-muted-foreground">6 hours ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-purple-100 dark:bg-purple-950 rounded-full flex items-center justify-center">
                  <UserCheck className="w-4 h-4 text-purple-600 dark:text-purple-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">New coach approved: Sarah Johnson</p>
                  <p className="text-xs text-muted-foreground">1 day ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-orange-100 dark:bg-orange-950 rounded-full flex items-center justify-center">
                  <Store className="w-4 h-4 text-orange-600 dark:text-orange-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Store inventory updated: 3 items restocked</p>
                  <p className="text-xs text-muted-foreground">1 day ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-indigo-100 dark:bg-indigo-950 rounded-full flex items-center justify-center">
                  <CreditCard className="w-4 h-4 text-indigo-600 dark:text-indigo-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Subscription payment received: $39.99</p>
                  <p className="text-xs text-muted-foreground">2 days ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-teal-100 dark:bg-teal-950 rounded-full flex items-center justify-center">
                  <Edit3 className="w-4 h-4 text-teal-600 dark:text-teal-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Content updated: New workout plan published</p>
                  <p className="text-xs text-muted-foreground">2 days ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-red-100 dark:bg-red-950 rounded-full flex items-center justify-center">
                  <Eye className="w-4 h-4 text-red-600 dark:text-red-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Security: Failed login attempt detected</p>
                  <p className="text-xs text-muted-foreground">3 days ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-pink-100 dark:bg-pink-950 rounded-full flex items-center justify-center">
                  <Settings className="w-4 h-4 text-pink-600 dark:text-pink-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">System settings updated by admin</p>
                  <p className="text-xs text-muted-foreground">3 days ago</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-muted rounded-lg">
                <div className="w-8 h-8 bg-amber-100 dark:bg-amber-950 rounded-full flex items-center justify-center">
                  <TrendingUp className="w-4 h-4 text-amber-600 dark:text-amber-400" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Monthly revenue milestone reached: $50,000</p>
                  <p className="text-xs text-muted-foreground">4 days ago</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  if (activeSection === 'audit') {
    return (
      <AuditLogsScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  if (activeSection === 'settings') {
    return (
      <SystemSettingsScreen
        onBack={() => setActiveSection('overview')}
      />
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-white/10 backdrop-blur-sm rounded-xl flex items-center justify-center">
              <LayoutDashboard className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-semibold">عاش Admin</h1>
              <p className="text-white/80 text-sm">{t('admin.welcomeBack')}, {userProfile.name}</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            {/* Navigation Dropdown */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="secondary" className="gap-2">
                  <Menu className="w-4 h-4" />
                  <span className="hidden md:inline">Navigation</span>
                  <ChevronDown className="w-4 h-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                {navigationItems.map((item, index) => {
                  const Icon = item.icon;
                  const isActive = activeSection === item.id;
                  return (
                    <React.Fragment key={item.id}>
                      <DropdownMenuItem 
                        onClick={() => setActiveSection(item.id)}
                        className={isActive ? 'bg-accent' : ''}
                      >
                        <Icon className="w-4 h-4 mr-2" />
                        <span className="flex-1">{item.label}</span>
                        {isActive && <CheckCircle className="w-4 h-4 text-primary" />}
                      </DropdownMenuItem>
                      {(index === 0 || index === 6 || index === 8) && (
                        <DropdownMenuSeparator />
                      )}
                    </React.Fragment>
                  );
                })}
              </DropdownMenuContent>
            </DropdownMenu>

            {/* Account Settings Button */}
            <Button 
              variant="secondary" 
              size="icon"
              onClick={() => onNavigate('account')}
              title="Account Settings"
            >
              <Settings className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        {/* Welcome Section */}
        <Card className="mb-6 bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950/20 dark:to-blue-950/20 border-purple-200 dark:border-purple-800">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl flex items-center justify-center">
                <LayoutDashboard className="w-6 h-6 text-white" />
              </div>
              <div>
                <h2 className="text-xl font-semibold">Welcome to عاش Admin</h2>
                <p className="text-sm text-muted-foreground">Manage your fitness platform from one place</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Sales Analytics */}
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-semibold mb-4">Sales Analytics</h3>
            
            {/* Key Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Total Revenue</p>
                      <h3 className="text-2xl font-bold mt-2">$45,231</h3>
                      <p className="text-xs text-green-600 mt-1">+20.1% from last month</p>
                    </div>
                    <div className="w-12 h-12 bg-green-100 dark:bg-green-950 rounded-full flex items-center justify-center">
                      <DollarSign className="w-6 h-6 text-green-600 dark:text-green-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Store Sales</p>
                      <h3 className="text-2xl font-bold mt-2">$12,450</h3>
                      <p className="text-xs text-green-600 mt-1">+15.3% from last month</p>
                    </div>
                    <div className="w-12 h-12 bg-blue-100 dark:bg-blue-950 rounded-full flex items-center justify-center">
                      <Package className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Subscriptions</p>
                      <h3 className="text-2xl font-bold mt-2">$32,781</h3>
                      <p className="text-xs text-green-600 mt-1">+25.7% from last month</p>
                    </div>
                    <div className="w-12 h-12 bg-purple-100 dark:bg-purple-950 rounded-full flex items-center justify-center">
                      <CreditCard className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Total Orders</p>
                      <h3 className="text-2xl font-bold mt-2">1,234</h3>
                      <p className="text-xs text-green-600 mt-1">+12.5% from last month</p>
                    </div>
                    <div className="w-12 h-12 bg-orange-100 dark:bg-orange-950 rounded-full flex items-center justify-center">
                      <TrendingUp className="w-6 h-6 text-orange-600 dark:text-orange-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Sales Breakdown */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
              <Card>
                <CardHeader>
                  <CardTitle>Top Selling Products</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-blue-100 dark:bg-blue-950 rounded-lg flex items-center justify-center">
                          <Package className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                        </div>
                        <div>
                          <p className="font-medium">Protein Powder</p>
                          <p className="text-xs text-muted-foreground">156 sales</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">$4,680</p>
                        <p className="text-xs text-green-600">+18%</p>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-purple-100 dark:bg-purple-950 rounded-lg flex items-center justify-center">
                          <Package className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                        </div>
                        <div>
                          <p className="font-medium">Resistance Bands</p>
                          <p className="text-xs text-muted-foreground">134 sales</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">$2,680</p>
                        <p className="text-xs text-green-600">+22%</p>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-green-100 dark:bg-green-950 rounded-lg flex items-center justify-center">
                          <Package className="w-5 h-5 text-green-600 dark:text-green-400" />
                        </div>
                        <div>
                          <p className="font-medium">Yoga Mat</p>
                          <p className="text-xs text-muted-foreground">98 sales</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">$1,960</p>
                        <p className="text-xs text-green-600">+15%</p>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-orange-100 dark:bg-orange-950 rounded-lg flex items-center justify-center">
                          <Package className="w-5 h-5 text-orange-600 dark:text-orange-400" />
                        </div>
                        <div>
                          <p className="font-medium">Dumbbells Set</p>
                          <p className="text-xs text-muted-foreground">87 sales</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">$3,480</p>
                        <p className="text-xs text-green-600">+10%</p>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Subscription Distribution</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-2">
                          <Crown className="w-4 h-4 text-yellow-600" />
                          <span className="font-medium">Smart Premium</span>
                        </div>
                        <span className="font-semibold">245 users</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div className="bg-yellow-500 h-2 rounded-full" style={{ width: '45%' }}></div>
                      </div>
                      <p className="text-xs text-muted-foreground mt-1">45% of total</p>
                    </div>

                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-2">
                          <Crown className="w-4 h-4 text-purple-600" />
                          <span className="font-medium">Premium</span>
                        </div>
                        <span className="font-semibold">312 users</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div className="bg-purple-500 h-2 rounded-full" style={{ width: '35%' }}></div>
                      </div>
                      <p className="text-xs text-muted-foreground mt-1">35% of total</p>
                    </div>

                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-2">
                          <Users className="w-4 h-4 text-blue-600" />
                          <span className="font-medium">Freemium</span>
                        </div>
                        <span className="font-semibold">178 users</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div className="bg-blue-500 h-2 rounded-full" style={{ width: '20%' }}></div>
                      </div>
                      <p className="text-xs text-muted-foreground mt-1">20% of total</p>
                    </div>

                    <div className="pt-4 border-t">
                      <div className="flex items-center justify-between">
                        <span className="font-semibold">Total Active Users</span>
                        <span className="text-xl font-bold">735</span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}