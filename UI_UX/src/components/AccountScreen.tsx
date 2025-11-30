import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Alert, AlertDescription } from './ui/alert';
import { Progress } from './ui/progress';
import { 
  ArrowLeft, 
  User, 
  CreditCard, 
  Bell, 
  Shield, 
  LogOut, 
  Edit, 
  Check,
  Crown,
  Star,
  Package,
  Settings,
  Globe,
  Zap,
  Activity,
  Plus
} from 'lucide-react';
import { UserProfile, SubscriptionTier } from '../App';
import { toast } from 'sonner@2.0.3';
import { useLanguage, Language } from './LanguageContext';
import { SubscriptionManager } from './SubscriptionManager';
import { InBodyInputScreen } from './InBodyInputScreen';
import { ProgressDetailScreen } from './ProgressDetailScreen';
import { InBodyData } from '../types/InBodyTypes';

interface AccountScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'workout' | 'nutrition' | 'coach' | 'store') => void;
  onLogout: () => void;
  onUpdateProfile: (updatedProfile: UserProfile) => void;
  isDemoMode: boolean;
}

export function AccountScreen({ userProfile, onNavigate, onLogout, onUpdateProfile, isDemoMode }: AccountScreenProps) {
  const { t, language, setLanguage, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('profile');
  const [isEditing, setIsEditing] = useState(false);
  const [showSubscriptionManager, setShowSubscriptionManager] = useState(false);
  const [showInBodyInput, setShowInBodyInput] = useState(false);
  const [showProgressDetail, setShowProgressDetail] = useState(false);
  const [profileData, setProfileData] = useState({
    name: userProfile.name,
    email: userProfile.email || '',
    age: userProfile.age.toString(),
    weight: userProfile.weight.toString(),
    height: userProfile.height.toString(),
    gender: userProfile.gender,
  });
  const [notifications, setNotifications] = useState({
    workoutReminders: true,
    coachMessages: true,
    nutritionTracking: false,
    promotions: true,
  });

  const subscriptionPlans = [
    {
      name: 'Freemium',
      price: 0,
      features: [
        'Basic workout plans',
        '1 coach session/month',
        'Store access',
        'Basic progress tracking'
      ],
      limitations: [
        'No nutrition plans',
        'Limited coach messages (50/month)',
        'Basic analytics'
      ]
    },
    {
      name: 'Premium',
      price: 19.99,
      features: [
        'All Freemium features',
        'Personalized nutrition plans',
        '4 coach sessions/month',
        'Unlimited coach messages',
        'Advanced progress tracking',
        'Priority support'
      ],
      popular: false
    },
    {
      name: 'Smart Premium',
      price: 39.99,
      features: [
        'All Premium features',
        '8 coach sessions/month',
        'Custom meal planning',
        'AI workout adjustments',
        'Supplement recommendations',
        'Priority booking'
      ],
      popular: true
    }
  ];

  const handleSaveProfile = () => {
    // In a real app, this would save to backend
    setIsEditing(false);
    // Show success message or update parent state
  };

  const handleSubscriptionUpgrade = (newTier: SubscriptionTier) => {
    const wasFreemium = userProfile.subscriptionTier === 'Freemium';
    
    console.log('[AccountScreen] handleSubscriptionUpgrade START:', {
      wasFreemium,
      currentTier: userProfile.subscriptionTier,
      newTier,
      phoneNumber: userProfile.phoneNumber,
      timestamp: new Date().toISOString()
    });
    
    // v2.0: If upgrading from Freemium to a paid plan with nutrition, mark nutrition intake as pending
    if (wasFreemium && newTier !== 'Freemium') {
      const hasCompletedNutrition = localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`) === 'true';
      console.log('[AccountScreen] User upgrading from Freemium, hasCompletedNutrition:', hasCompletedNutrition);
      
      if (!hasCompletedNutrition) {
        const key = `pending_nutrition_intake_${userProfile.phoneNumber}`;
        localStorage.setItem(key, 'true');
        const verification = localStorage.getItem(key);
        console.log('[AccountScreen] Set pending nutrition intake:', {
          key,
          value: 'true',
          verification,
          phoneNumber: userProfile.phoneNumber,
          timestamp: new Date().toISOString()
        });
        
        // Show prompt to visit nutrition screen after a short delay
        setTimeout(() => {
          toast.success(isRTL ? '🎉 مبروك الترقية!' : '🎉 Upgrade Successful!', {
            description: isRTL 
              ? 'لنبدأ بإعداد خطة التغذية الخاصة بك. اضغط هنا للمتابعة.' 
              : 'Let\'s set up your nutrition plan. Tap here to continue.',
            duration: 8000,
            action: {
              label: isRTL ? 'ابدأ الآن' : 'Start Now',
              onClick: () => {
                console.log('[AccountScreen] Toast action clicked, navigating to nutrition');
                onNavigate('nutrition');
              }
            }
          });
        }, 2000);
      }
      // Remove the freemium tracking flag since user is upgrading
      localStorage.removeItem(`was_freemium_${userProfile.phoneNumber}`);
    }
    
    const updatedProfile: UserProfile = {
      ...userProfile,
      subscriptionTier: newTier
    };
    onUpdateProfile(updatedProfile);
  };

  const toggleNotification = (key: keyof typeof notifications) => {
    setNotifications(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const handleInBodySave = (data: InBodyData) => {
    const updatedProfile: UserProfile = {
      ...userProfile,
      inBodyHistory: {
        scans: [
          ...(userProfile.inBodyHistory?.scans || []),
          data
        ],
        latestScan: data
      }
    };
    onUpdateProfile(updatedProfile);
    setShowInBodyInput(false);
  };

  // Show subscription manager if requested
  if (showSubscriptionManager) {
    return (
      <SubscriptionManager
        userProfile={userProfile}
        onBack={() => setShowSubscriptionManager(false)}
        onUpgrade={handleSubscriptionUpgrade}
      />
    );
  }

  // Show InBody input screen if requested
  if (showInBodyInput) {
    return (
      <InBodyInputScreen
        onSave={handleInBodySave}
        onBack={() => setShowInBodyInput(false)}
        existingData={userProfile.inBodyHistory?.latestScan}
        userGender={userProfile.gender}
        subscriptionTier={userProfile.subscriptionTier}
        onUpgrade={() => {
          setShowInBodyInput(false);
          setShowSubscriptionManager(true);
        }}
      />
    );
  }

  // Show Progress Detail screen if requested
  if (showProgressDetail) {
    return (
      <ProgressDetailScreen
        userProfile={userProfile}
        onBack={() => setShowProgressDetail(false)}
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
      <div className="bg-primary text-primary-foreground p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={() => onNavigate('home')}
            className="text-primary-foreground hover:bg-primary-foreground/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('account.title')}</h1>
            <p className="text-primary-foreground/80">{t('account.manageProfile')}</p>
          </div>
        </div>

        {/* Profile Summary */}
        <div className="bg-primary-foreground/10 rounded-2xl p-4">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-12 h-12 bg-primary-foreground/20 rounded-full flex items-center justify-center">
              <User className="w-6 h-6" />
            </div>
            <div className="flex-1">
              <h3>{userProfile.name}</h3>
              <p className="text-primary-foreground/80 text-sm">{userProfile.email}</p>
            </div>
            <Badge variant="secondary" className="bg-primary-foreground/20 text-primary-foreground">
              {userProfile.subscriptionTier}
            </Badge>
          </div>
          <div className="grid grid-cols-3 gap-4 text-center text-sm">
            <div>
              <div className="font-semibold">{userProfile.age}</div>
              <div className="text-primary-foreground/70">{t('account.years')}</div>
            </div>
            <div>
              <div className="font-semibold">{userProfile.weight}kg</div>
              <div className="text-primary-foreground/70">{t('account.weight')}</div>
            </div>
            <div>
              <div className="font-semibold">{userProfile.height}cm</div>
              <div className="text-primary-foreground/70">{t('account.height')}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="profile">{t('account.profile')}</TabsTrigger>
            <TabsTrigger value="health">{t('account.health')}</TabsTrigger>
            <TabsTrigger value="subscription">{t('account.plan')}</TabsTrigger>
            <TabsTrigger value="notifications">{t('account.alerts')}</TabsTrigger>
            <TabsTrigger value="settings">{t('account.settings')}</TabsTrigger>
          </TabsList>

          <TabsContent value="profile" className="mt-4 space-y-4">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>{t('account.personalInfo')}</CardTitle>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => setIsEditing(!isEditing)}
                  >
                    {isEditing ? <Check className="w-4 h-4" /> : <Edit className="w-4 h-4" />}
                    {isEditing ? t('account.save') : t('account.edit')}
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">{t('auth.fullName')}</Label>
                    <Input
                      id="name"
                      value={profileData.name}
                      onChange={(e) => setProfileData(prev => ({ ...prev, name: e.target.value }))}
                      disabled={!isEditing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">{t('auth.email')}</Label>
                    <Input
                      id="email"
                      value={profileData.email}
                      onChange={(e) => setProfileData(prev => ({ ...prev, email: e.target.value }))}
                      disabled={!isEditing}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="age">{t('onboarding.age')}</Label>
                    <Input
                      id="age"
                      type="number"
                      value={profileData.age}
                      onChange={(e) => setProfileData(prev => ({ ...prev, age: e.target.value }))}
                      disabled={!isEditing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="weight">{t('onboarding.weight')}</Label>
                    <Input
                      id="weight"
                      type="number"
                      value={profileData.weight}
                      onChange={(e) => setProfileData(prev => ({ ...prev, weight: e.target.value }))}
                      disabled={!isEditing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="height">{t('onboarding.height')}</Label>
                    <Input
                      id="height"
                      type="number"
                      value={profileData.height}
                      onChange={(e) => setProfileData(prev => ({ ...prev, height: e.target.value }))}
                      disabled={!isEditing}
                    />
                  </div>
                </div>

                {isEditing && (
                  <div className="flex gap-2 pt-4">
                    <Button onClick={handleSaveProfile} className="flex-1">
                      {t('account.saveChanges')}
                    </Button>
                    <Button 
                      variant="outline" 
                      onClick={() => setIsEditing(false)}
                      className="flex-1"
                    >
                      {t('account.cancel')}
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('account.fitnessProfile')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>{t('account.experienceLevel')}</Label>
                    <p className="capitalize text-muted-foreground">{userProfile.experienceLevel}</p>
                  </div>
                  <div>
                    <Label>{t('account.workoutLocation')}</Label>
                    <p className="capitalize text-muted-foreground">{userProfile.workoutLocation}</p>
                  </div>
                </div>
                <div>
                  <Label>{t('account.workoutFrequency')}</Label>
                  <p className="text-muted-foreground">{userProfile.workoutFrequency} {t('account.daysPerWeek')}</p>
                </div>
                <Button variant="outline" className="w-full">
                  {t('account.updateGoals')}
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="health" className="mt-4 space-y-4">
            {/* Fitness Score */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Activity className="w-5 h-5" />
                  {t('home.fitnessScore')}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="text-center">
                  <div className="text-4xl font-bold mb-2">
                    {userProfile.fitnessScore || 0}
                  </div>
                  <p className="text-xs text-muted-foreground mb-4">
                    {userProfile.fitnessScoreUpdatedBy === 'coach' 
                      ? t('home.updateByCoach') 
                      : t('home.autoUpdated')}
                  </p>
                  <Progress value={userProfile.fitnessScore || 0} className="h-2" />
                </div>
                {userProfile.fitnessScoreLastUpdated && (
                  <p className="text-xs text-center text-muted-foreground">
                    Last updated: {new Date(userProfile.fitnessScoreLastUpdated).toLocaleDateString()}
                  </p>
                )}
              </CardContent>
            </Card>

            {/* InBody Data */}
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Activity className="w-5 h-5" />
                    {t('inbody.title')}
                  </CardTitle>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setShowInBodyInput(true)}
                  >
                    <Plus className="w-4 h-4 mr-2" />
                    {userProfile.inBodyHistory?.latestScan ? t('common.update') : t('common.add')}
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                {userProfile.inBodyHistory?.latestScan ? (
                  <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-muted rounded-lg p-3">
                        <div className="text-xs text-muted-foreground mb-1">{t('inbody.weight')}</div>
                        <div className="text-xl font-semibold">{userProfile.inBodyHistory.latestScan.weight} kg</div>
                      </div>
                      <div className="bg-muted rounded-lg p-3">
                        <div className="text-xs text-muted-foreground mb-1">{t('inbody.bmi')}</div>
                        <div className="text-xl font-semibold">{userProfile.inBodyHistory.latestScan.bmi}</div>
                      </div>
                      <div className="bg-muted rounded-lg p-3">
                        <div className="text-xs text-muted-foreground mb-1">{t('inbody.percentBodyFat')}</div>
                        <div className="text-xl font-semibold">{userProfile.inBodyHistory.latestScan.percentBodyFat}%</div>
                      </div>
                      <div className="bg-muted rounded-lg p-3">
                        <div className="text-xs text-muted-foreground mb-1">{t('inbody.skeletalMuscleMass')}</div>
                        <div className="text-xl font-semibold">{userProfile.inBodyHistory.latestScan.skeletalMuscleMass} kg</div>
                      </div>
                    </div>
                    
                    <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                      <div>
                        <div className="text-xs text-muted-foreground">{t('inbody.inBodyScore')}</div>
                        <div className="text-2xl font-bold">{userProfile.inBodyHistory.latestScan.inBodyScore}</div>
                      </div>
                      <Progress value={userProfile.inBodyHistory.latestScan.inBodyScore} className="w-32" />
                    </div>

                    <div className="text-xs text-muted-foreground text-center">
                      {t('inbody.scanOn')} {new Date(userProfile.inBodyHistory.latestScan.scanDate).toLocaleDateString()}
                    </div>

                    <div className="space-y-2">
                      {userProfile.inBodyHistory.scans.length > 1 && (
                        <Button variant="outline" className="w-full" size="sm">
                          {t('inbody.viewHistory')} ({userProfile.inBodyHistory.scans.length} {t('common.scans')})
                        </Button>
                      )}
                      <Button 
                        className="w-full" 
                        size="sm"
                        onClick={() => setShowProgressDetail(true)}
                      >
                        <Activity className="w-4 h-4 mr-2" />
                        View Detailed Progress
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Activity className="w-12 h-12 mx-auto mb-3 text-muted-foreground" />
                    <p className="text-muted-foreground mb-4">{t('inbody.noData')}</p>
                    <Button onClick={() => setShowInBodyInput(true)}>
                      <Plus className="w-4 h-4 mr-2" />
                      {t('inbody.addFirst')}
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="subscription" className="mt-4 space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('account.currentPlan')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="font-semibold flex items-center gap-2">
                      {userProfile.subscriptionTier}
                      {userProfile.subscriptionTier === 'Smart Premium' && (
                        <Crown className="w-4 h-4 text-yellow-500" />
                      )}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {userProfile.subscriptionTier === 'Freemium' ? t('account.free') : 
                       userProfile.subscriptionTier === 'Premium' ? `$19.99${t('account.month')}` : `$39.99${t('account.month')}`}
                    </p>
                  </div>
                  <Badge variant={userProfile.subscriptionTier === 'Freemium' ? 'secondary' : 'default'}>
                    {userProfile.subscriptionTier === 'Freemium' ? t('account.free') : t('account.active')}
                  </Badge>
                </div>
                
                {userProfile.subscriptionTier !== 'Freemium' && (
                  <Alert>
                    <AlertDescription>
                      {t('account.renewsOn')} {new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toLocaleDateString()}
                    </AlertDescription>
                  </Alert>
                )}
              </CardContent>
            </Card>

            <div className="space-y-4">
              <h3 className="font-semibold">{t('account.availablePlans')}</h3>
              {subscriptionPlans.map((plan) => (
                <Card key={plan.name} className={plan.popular ? 'border-primary' : ''}>
                  <CardHeader className="pb-3">
                    <div className="flex items-center justify-between">
                      <div>
                        <CardTitle className="text-lg flex items-center gap-2">
                          {plan.name}
                          {plan.popular && (
                            <Badge variant="default">
                              <Star className="w-3 h-3 mr-1" />
                              {t('account.popular')}
                            </Badge>
                          )}
                        </CardTitle>
                        <p className="text-2xl font-bold">
                          ${plan.price}
                          {plan.price > 0 && <span className="text-sm font-normal text-muted-foreground">{t('account.month')}</span>}
                        </p>
                      </div>
                      {userProfile.subscriptionTier === plan.name ? (
                        <Badge variant="secondary">{t('account.current')}</Badge>
                      ) : (
                        <Button 
                          variant={plan.popular ? 'default' : 'outline'}
                          onClick={() => setShowSubscriptionManager(true)}
                        >
                          {userProfile.subscriptionTier === 'Freemium' ? t('subscription.upgrade') : t('account.changePlan')}
                        </Button>
                      )}
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {plan.features.map((feature, index) => (
                        <div key={index} className="flex items-center gap-2 text-sm">
                          <Check className="w-4 h-4 text-green-600" />
                          <span>{feature}</span>
                        </div>
                      ))}
                      {plan.limitations && (
                        <>
                          <div className="border-t pt-2 mt-2">
                            <p className="text-xs text-muted-foreground mb-2">{t('account.limitations')}</p>
                            {plan.limitations.map((limitation, index) => (
                              <div key={index} className="flex items-center gap-2 text-xs text-muted-foreground">
                                <div className="w-1 h-1 bg-muted-foreground rounded-full" />
                                <span>{limitation}</span>
                              </div>
                            ))}
                          </div>
                        </>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          <TabsContent value="notifications" className="mt-4 space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('account.notificationPrefs')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label>{t('account.workoutReminders')}</Label>
                    <p className="text-sm text-muted-foreground">{t('account.workoutRemindersDesc')}</p>
                  </div>
                  <Switch 
                    checked={notifications.workoutReminders}
                    onCheckedChange={() => toggleNotification('workoutReminders')}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label>{t('account.coachMessages')}</Label>
                    <p className="text-sm text-muted-foreground">{t('account.coachMessagesDesc')}</p>
                  </div>
                  <Switch 
                    checked={notifications.coachMessages}
                    onCheckedChange={() => toggleNotification('coachMessages')}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label>{t('account.nutritionTracking')}</Label>
                    <p className="text-sm text-muted-foreground">{t('account.nutritionTrackingDesc')}</p>
                  </div>
                  <Switch 
                    checked={notifications.nutritionTracking}
                    onCheckedChange={() => toggleNotification('nutritionTracking')}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label>{t('account.promotions')}</Label>
                    <p className="text-sm text-muted-foreground">{t('account.promotionsDesc')}</p>
                  </div>
                  <Switch 
                    checked={notifications.promotions}
                    onCheckedChange={() => toggleNotification('promotions')}
                  />
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="settings" className="mt-4 space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>{t('settings.language')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="language">{t('settings.language')}</Label>
                  <Select value={language} onValueChange={(value: Language) => setLanguage(value)}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="en">
                        <div className="flex items-center gap-2">
                          <Globe className="w-4 h-4" />
                          {t('settings.english')}
                        </div>
                      </SelectItem>
                      <SelectItem value="ar">
                        <div className="flex items-center gap-2">
                          <Globe className="w-4 h-4" />
                          {t('settings.arabic')}
                        </div>
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('account.security')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => toast.info(isDemoMode 
                    ? 'Demo: Password change is disabled in demo mode' 
                    : 'Opening password change...'
                  )}
                >
                  <Shield className="w-4 h-4 mr-2" />
                  Change Password
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => toast.info('Security settings coming soon')}
                >
                  Security Settings
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Data & Privacy</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => {
                    toast.success('Data export started. Download will begin shortly.');
                  }}
                >
                  <Package className="w-4 h-4 mr-2" />
                  Export My Data
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => toast.info('Privacy settings coming soon')}
                >
                  Privacy Settings
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start text-destructive"
                  onClick={() => {
                    if (confirm('Are you sure you want to delete your account? This cannot be undone.')) {
                      toast.error('Account deletion is disabled in demo mode');
                    }
                  }}
                >
                  Delete Account
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Support</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => window.open('https://help.fitcoach.com', '_blank')}
                >
                  Help Center
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => toast.info('Contact support at support@fitcoach.com')}
                >
                  Contact Support
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => window.open('https://fitcoach.com/terms', '_blank')}
                >
                  Terms of Service
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start"
                  onClick={() => window.open('https://fitcoach.com/privacy', '_blank')}
                >
                  Privacy Policy
                </Button>
              </CardContent>
            </Card>

            {isDemoMode && (
              <Alert>
                <AlertDescription>
                  <strong>Demo Mode:</strong> You're currently in demo mode. 
                  Some features may not work as expected in the real application.
                </AlertDescription>
              </Alert>
            )}

            <Card>
              <CardContent className="p-4">
                <Button 
                  variant="destructive" 
                  className="w-full"
                  onClick={onLogout}
                >
                  <LogOut className="w-4 h-4 mr-2" />
                  {isDemoMode ? 'Exit Demo' : 'Sign Out'}
                </Button>
              </CardContent>
            </Card>

            <div className="text-center text-xs text-muted-foreground pt-4">
              FitCoach v1.0.0 • Made with ❤️ for your fitness journey
            </div>
          </TabsContent>
        </Tabs>
      </div>
      </div>
    </div>
  );
}