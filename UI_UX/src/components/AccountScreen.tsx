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
import { Textarea } from './ui/textarea';
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
  Plus,
  Award,
  BookOpen,
  Upload,
  X,
  Calendar,
  Briefcase,
  CheckCircle,
  BarChart3
} from 'lucide-react';
import { UserProfile, SubscriptionTier } from '../App';
import { toast } from 'sonner@2.0.3';
import { useLanguage, Language } from './LanguageContext';
import { SubscriptionManager } from './SubscriptionManager';
import { InBodyInputScreen } from './InBodyInputScreen';
import { ProgressDetailScreen } from './ProgressDetailScreen';
import { InBodyData } from '../types/InBodyTypes';

type UserType = 'user' | 'coach' | 'admin';

interface AccountScreenProps {
  userProfile: UserProfile;
  userType: UserType;
  onNavigate: (screen: 'home' | 'workout' | 'nutrition' | 'coach' | 'store') => void;
  onLogout: () => void;
  onUpdateProfile: (updatedProfile: UserProfile) => void;
  isDemoMode: boolean;
}

export function AccountScreen({ userProfile, userType, onNavigate, onLogout, onUpdateProfile, isDemoMode }: AccountScreenProps) {
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

  // Coach-specific notifications
  const [coachNotifications, setCoachNotifications] = useState({
    newClientAssignments: true,
    clientMessages: true,
    sessionReminders: true,
    paymentAlerts: true,
  });

  // Admin-specific notifications
  const [adminNotifications, setAdminNotifications] = useState({
    systemAlerts: true,
    userReports: true,
    coachApplications: true,
    paymentIssues: true,
    securityAlerts: true,
  });

  // Coach-specific profile data
  const [coachProfile, setCoachProfile] = useState({
    bio: 'Certified fitness coach with 8+ years of experience specializing in strength training and nutrition. Passionate about helping clients achieve their fitness goals through personalized training programs.',
    yearsOfExperience: 8,
    specializations: ['Strength Training', 'Nutrition', 'Weight Loss', 'Muscle Gain'],
    certifications: [
      { id: '1', name: 'NASM Certified Personal Trainer', organization: 'National Academy of Sports Medicine', year: 2016 },
      { id: '2', name: 'Precision Nutrition Level 1', organization: 'Precision Nutrition', year: 2018 },
      { id: '3', name: 'Functional Movement Screen', organization: 'FMS', year: 2019 },
    ],
    experience: [
      { id: '1', title: 'Senior Fitness Coach', organization: 'Elite Fitness Center', years: '2018 - Present', description: 'Lead coach managing 20+ clients' },
      { id: '2', title: 'Personal Trainer', organization: 'Gold Gym', years: '2016 - 2018', description: 'Trained individuals and small groups' },
    ]
  });
  const [isEditingCoachProfile, setIsEditingCoachProfile] = useState(false);

  // Admin-specific profile data
  const [adminProfile, setAdminProfile] = useState({
    role: 'System Administrator',
    department: 'Platform Operations',
    permissions: ['User Management', 'Coach Management', 'Content Management', 'System Settings', 'Analytics'],
    employeeId: 'ADM-001',
    joinedDate: '2023-01-15',
  });
  const [isEditingAdminProfile, setIsEditingAdminProfile] = useState(false);

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
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-80"
        style={{ 
          backgroundImage: 'url(https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=1200)',
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
            {userType !== 'coach' && (
              <Badge variant="secondary" className="bg-primary-foreground/20 text-primary-foreground">
                {userProfile.subscriptionTier}
              </Badge>
            )}
            {userType === 'coach' && (
              <Badge variant="secondary" className="bg-primary-foreground/20 text-primary-foreground">
                <Award className="w-3 h-3 mr-1" />
                Coach
              </Badge>
            )}
          </div>
          {userType !== 'coach' ? (
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
          ) : (
            <div className="grid grid-cols-2 gap-4 text-center text-sm">
              <div>
                <div className="font-semibold">{coachProfile.yearsOfExperience} years</div>
                <div className="text-primary-foreground/70">Experience</div>
              </div>
              <div>
                <div className="font-semibold">{coachProfile.certifications.length}</div>
                <div className="text-primary-foreground/70">Certifications</div>
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="p-4">
        {/* Dropdown Menu for Tab Selection */}
        <div className="mb-4">
          <Label className="text-sm font-medium mb-2 block">
            {isRTL ? 'اختر القسم' : 'Select Section'}
          </Label>
          <Select value={activeTab} onValueChange={setActiveTab}>
            <SelectTrigger className="w-full">
              <SelectValue>
                <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  {activeTab === 'profile' && (
                    <>
                      <User className="w-4 h-4" />
                      <span>{t('account.profile')}</span>
                    </>
                  )}
                  {activeTab === 'health' && (
                    <>
                      <Activity className="w-4 h-4" />
                      <span>{t('account.health')}</span>
                    </>
                  )}
                  {activeTab === 'subscription' && (
                    <>
                      <CreditCard className="w-4 h-4" />
                      <span>{t('account.plan')}</span>
                    </>
                  )}
                  {activeTab === 'notifications' && (
                    <>
                      <Bell className="w-4 h-4" />
                      <span>{t('account.notifications')}</span>
                    </>
                  )}
                  {activeTab === 'settings' && (
                    <>
                      <Settings className="w-4 h-4" />
                      <span>{t('account.settings')}</span>
                    </>
                  )}
                </div>
              </SelectValue>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="profile">
                <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <User className="w-4 h-4" />
                  <span>{t('account.profile')}</span>
                </div>
              </SelectItem>
              {userType !== 'coach' && userType !== 'admin' && (
                <>
                  <SelectItem value="health">
                    <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <Activity className="w-4 h-4" />
                      <span>{t('account.health')}</span>
                    </div>
                  </SelectItem>
                  <SelectItem value="subscription">
                    <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <CreditCard className="w-4 h-4" />
                      <span>{t('account.plan')}</span>
                    </div>
                  </SelectItem>
                </>
              )}
              <SelectItem value="notifications">
                <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <Bell className="w-4 h-4" />
                  <span>{t('account.notifications')}</span>
                </div>
              </SelectItem>
              <SelectItem value="settings">
                <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <Settings className="w-4 h-4" />
                  <span>{t('account.settings')}</span>
                </div>
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsContent value="profile" className="mt-4 space-y-4">
            {/* Basic Info - Same for all users */}
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>{t('account.personalInfo')}</CardTitle>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => {
                      if (userType === 'coach') {
                        setIsEditingCoachProfile(!isEditingCoachProfile);
                        if (isEditingCoachProfile) {
                          toast.success('Profile updated successfully');
                        }
                      } else {
                        setIsEditing(!isEditing);
                      }
                    }}
                  >
                    {(userType === 'coach' ? isEditingCoachProfile : isEditing) ? <Check className="w-4 h-4" /> : <Edit className="w-4 h-4" />}
                    {(userType === 'coach' ? isEditingCoachProfile : isEditing) ? t('account.save') : t('account.edit')}
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
                      disabled={userType === 'coach' ? !isEditingCoachProfile : !isEditing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">{t('auth.email')}</Label>
                    <Input
                      id="email"
                      value={profileData.email}
                      onChange={(e) => setProfileData(prev => ({ ...prev, email: e.target.value }))}
                      disabled={userType === 'coach' ? !isEditingCoachProfile : !isEditing}
                    />
                  </div>
                </div>

                {userType !== 'coach' && userType !== 'admin' && (
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
                )}
              </CardContent>
            </Card>

            {/* Coach-specific sections */}
            {userType === 'coach' ? (
              <>
                {/* Coach Bio */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <User className="w-5 h-5" />
                      Professional Bio
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Textarea
                      value={coachProfile.bio}
                      onChange={(e) => setCoachProfile(prev => ({ ...prev, bio: e.target.value }))}
                      disabled={!isEditingCoachProfile}
                      rows={4}
                      className="resize-none"
                    />
                  </CardContent>
                </Card>

                {/* Experience */}
                <Card>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <CardTitle className="flex items-center gap-2">
                        <Briefcase className="w-5 h-5" />
                        Work Experience
                      </CardTitle>
                      {isEditingCoachProfile && (
                        <Button size="sm" variant="outline">
                          <Plus className="w-4 h-4 mr-2" />
                          Add Experience
                        </Button>
                      )}
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label>Years of Experience</Label>
                      <Input
                        type="number"
                        value={coachProfile.yearsOfExperience}
                        onChange={(e) => setCoachProfile(prev => ({ ...prev, yearsOfExperience: parseInt(e.target.value) || 0 }))}
                        disabled={!isEditingCoachProfile}
                      />
                    </div>
                    {coachProfile.experience.map((exp) => (
                      <div key={exp.id} className="border rounded-lg p-4 space-y-2">
                        <div className="flex items-start justify-between">
                          <div>
                            <h4 className="font-semibold">{exp.title}</h4>
                            <p className="text-sm text-muted-foreground">{exp.organization}</p>
                            <p className="text-xs text-muted-foreground">{exp.years}</p>
                          </div>
                          {isEditingCoachProfile && (
                            <Button size="sm" variant="ghost">
                              <X className="w-4 h-4" />
                            </Button>
                          )}
                        </div>
                        <p className="text-sm">{exp.description}</p>
                      </div>
                    ))}
                  </CardContent>
                </Card>

                {/* Certifications */}
                <Card>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <CardTitle className="flex items-center gap-2">
                        <Award className="w-5 h-5" />
                        Certifications
                      </CardTitle>
                      {isEditingCoachProfile && (
                        <Button size="sm" variant="outline">
                          <Plus className="w-4 h-4 mr-2" />
                          Add Certification
                        </Button>
                      )}
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {coachProfile.certifications.map((cert) => (
                      <div key={cert.id} className="border rounded-lg p-4 flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold flex items-center gap-2">
                            <Award className="w-4 h-4 text-blue-600" />
                            {cert.name}
                          </h4>
                          <p className="text-sm text-muted-foreground">{cert.organization}</p>
                          <p className="text-xs text-muted-foreground">Obtained: {cert.year}</p>
                        </div>
                        {isEditingCoachProfile && (
                          <Button size="sm" variant="ghost">
                            <X className="w-4 h-4" />
                          </Button>
                        )}
                      </div>
                    ))}
                  </CardContent>
                </Card>

                {/* Specializations */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <BookOpen className="w-5 h-5" />
                      Specializations
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {coachProfile.specializations.map((spec, index) => (
                        <Badge key={index} variant="secondary" className="text-sm">
                          {spec}
                          {isEditingCoachProfile && (
                            <button className="ml-2">
                              <X className="w-3 h-3" />
                            </button>
                          )}
                        </Badge>
                      ))}
                      {isEditingCoachProfile && (
                        <Button size="sm" variant="outline">
                          <Plus className="w-3 h-3 mr-1" />
                          Add
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </>
            ) : userType === 'admin' ? (
              <>
                {/* Admin Role & Department */}
                <Card>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <CardTitle className="flex items-center gap-2">
                        <Shield className="w-5 h-5" />
                        {t('admin.adminInfo')}
                      </CardTitle>
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={() => {
                          setIsEditingAdminProfile(!isEditingAdminProfile);
                          if (isEditingAdminProfile) {
                            toast.success('Admin profile updated successfully');
                          }
                        }}
                      >
                        {isEditingAdminProfile ? <Check className="w-4 h-4" /> : <Edit className="w-4 h-4" />}
                        {isEditingAdminProfile ? t('account.save') : t('account.edit')}
                      </Button>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="role">{t('admin.role')}</Label>
                        <Input
                          id="role"
                          value={adminProfile.role}
                          onChange={(e) => setAdminProfile(prev => ({ ...prev, role: e.target.value }))}
                          disabled={!isEditingAdminProfile}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="department">{t('admin.department')}</Label>
                        <Input
                          id="department"
                          value={adminProfile.department}
                          onChange={(e) => setAdminProfile(prev => ({ ...prev, department: e.target.value }))}
                          disabled={!isEditingAdminProfile}
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="employeeId">{t('admin.employeeId')}</Label>
                      <Input
                        id="employeeId"
                        value={adminProfile.employeeId}
                        disabled
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{t('admin.joinedDate')}</Label>
                      <p className="text-sm text-muted-foreground">
                        {new Date(adminProfile.joinedDate).toLocaleDateString()}
                      </p>
                    </div>
                  </CardContent>
                </Card>

                {/* Admin Permissions */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <CheckCircle className="w-5 h-5" />
                      {t('admin.permissions')}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-1 gap-2">
                      {adminProfile.permissions.map((permission, index) => (
                        <div key={index} className="flex items-center gap-2 p-3 bg-muted rounded-lg">
                          <CheckCircle className="w-4 h-4 text-green-600" />
                          <span className="text-sm">{permission}</span>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                {/* Admin Statistics */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <BarChart3 className="w-5 h-5" />
                      {t('admin.activityStats')}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-blue-50 dark:bg-blue-950 rounded-lg p-4">
                        <div className="text-2xl font-bold">1,247</div>
                        <div className="text-xs text-muted-foreground">{t('admin.totalUsers')}</div>
                      </div>
                      <div className="bg-purple-50 dark:bg-purple-950 rounded-lg p-4">
                        <div className="text-2xl font-bold">43</div>
                        <div className="text-xs text-muted-foreground">{t('admin.activeCoaches')}</div>
                      </div>
                      <div className="bg-green-50 dark:bg-green-950 rounded-lg p-4">
                        <div className="text-2xl font-bold">87</div>
                        <div className="text-xs text-muted-foreground">{t('admin.actionThisWeek')}</div>
                      </div>
                      <div className="bg-orange-50 dark:bg-orange-950 rounded-lg p-4">
                        <div className="text-2xl font-bold">12</div>
                        <div className="text-xs text-muted-foreground">{t('admin.pendingReviews')}</div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </>
            ) : (
              /* User-specific fitness profile - only for regular users */
              userType === 'user' && (
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
              )
            )}
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
                {userType === 'coach' ? (
                  <>
                    <div className="flex items-center justify-between">
                      <div>
                        <Label>New Client Assignments</Label>
                        <p className="text-sm text-muted-foreground">Get notified when admin assigns you new clients</p>
                      </div>
                      <Switch 
                        checked={coachNotifications.newClientAssignments}
                        onCheckedChange={() => setCoachNotifications(prev => ({ ...prev, newClientAssignments: !prev.newClientAssignments }))}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <Label>Client Messages</Label>
                        <p className="text-sm text-muted-foreground">Receive notifications for messages from clients</p>
                      </div>
                      <Switch 
                        checked={coachNotifications.clientMessages}
                        onCheckedChange={() => setCoachNotifications(prev => ({ ...prev, clientMessages: !prev.clientMessages }))}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <Label>Session Reminders</Label>
                        <p className="text-sm text-muted-foreground">Get reminders about upcoming client sessions</p>
                      </div>
                      <Switch 
                        checked={coachNotifications.sessionReminders}
                        onCheckedChange={() => setCoachNotifications(prev => ({ ...prev, sessionReminders: !prev.sessionReminders }))}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <Label>Payment Alerts</Label>
                        <p className="text-sm text-muted-foreground">Notifications about payment processing and earnings</p>
                      </div>
                      <Switch 
                        checked={coachNotifications.paymentAlerts}
                        onCheckedChange={() => setCoachNotifications(prev => ({ ...prev, paymentAlerts: !prev.paymentAlerts }))}
                      />
                    </div>
                  </>
                ) : (
                  <>
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
                  </>
                )}
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
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
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
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
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
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => {
                    toast.success('Data export started. Download will begin shortly.');
                  }}
                >
                  <Package className="w-4 h-4 mr-2" />
                  Export My Data
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => toast.info('Privacy settings coming soon')}
                >
                  Privacy Settings
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{isRTL ? 'إعادة تعيين الشاشات الترحيبية' : 'Reset Welcome Screens'}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  {isRTL 
                    ? 'مسح جميع شاشات الترحيب لرؤيتها مرة أخرى عند زيارة كل قسم'
                    : 'Clear all welcome screens to see them again when visiting each section'
                  }
                </p>
                <Button 
                  variant="outline" 
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => {
                    localStorage.removeItem('workout_intro_seen');
                    localStorage.removeItem('nutrition_intro_seen');
                    localStorage.removeItem('coach_intro_seen');
                    localStorage.removeItem('store_intro_seen');
                    toast.success(
                      isRTL 
                        ? '✅ تم إعادة تعيين جميع الشاشات الترحيبية! قم بزيارة أي قسم لرؤية الشاشة الترحيبية.'
                        : '✅ All welcome screens reset! Visit any section to see the welcome screen.'
                    );
                  }}
                >
                  <Zap className="w-4 h-4 mr-2" />
                  {isRTL ? 'إعادة تعيين الآن' : 'Reset Now'}
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
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => window.open('https://help.fitcoach.com', '_blank')}
                >
                  Help Center
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => toast.info('Contact support at support@fitcoach.com')}
                >
                  Contact Support
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
                  onClick={() => window.open('https://fitcoach.com/terms', '_blank')}
                >
                  Terms of Service
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-start border-border hover:bg-accent hover:text-accent-foreground"
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