import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ScrollArea } from './ui/scroll-area';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Progress } from './ui/progress';
import { 
  ArrowLeft, 
  User, 
  Award, 
  BookOpen, 
  Star, 
  Medal,
  FileText,
  Upload,
  Edit,
  Check,
  Plus,
  X,
  TrendingUp,
  Users,
  Calendar,
  DollarSign,
  Target,
  MessageCircle,
  Video,
  Globe,
  Settings
} from 'lucide-react';
import { UserProfile } from '../App';
import { toast } from 'sonner@2.0.3';
import { useLanguage } from './LanguageContext';

interface Certificate {
  id: string;
  name: string;
  issuingOrganization: string;
  dateObtained: Date;
  expiryDate?: Date;
  certificateUrl?: string;
}

interface Experience {
  id: string;
  title: string;
  organization: string;
  startDate: Date;
  endDate?: Date;
  isCurrent: boolean;
  description: string;
}

interface Achievement {
  id: string;
  title: string;
  description: string;
  date: Date;
  type: 'medal' | 'award' | 'recognition';
}

interface Specialization {
  id: string;
  name: string;
  level: 'beginner' | 'intermediate' | 'expert';
}

interface CoachProfileScreenProps {
  userProfile: UserProfile;
  onBack: () => void;
  onLogout: () => void;
  onUpdateProfile: (updatedProfile: UserProfile) => void;
}

export function CoachProfileScreen({ 
  userProfile, 
  onBack, 
  onLogout, 
  onUpdateProfile 
}: CoachProfileScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');
  const [isEditingBasic, setIsEditingBasic] = useState(false);
  const [isEditingBio, setIsEditingBio] = useState(false);

  // Basic Info
  const [basicInfo, setBasicInfo] = useState({
    name: userProfile.name,
    email: userProfile.email || '',
    phone: '+966 50 123 4567',
    bio: 'Certified fitness coach with 8+ years of experience specializing in strength training and nutrition. Passionate about helping clients achieve their fitness goals through personalized training programs.',
    yearsOfExperience: 8,
    specializations: ['Strength Training', 'Nutrition', 'Weight Loss', 'Muscle Gain']
  });

  // Certificates
  const [certificates, setCertificates] = useState<Certificate[]>([
    {
      id: '1',
      name: 'Certified Personal Trainer (CPT)',
      issuingOrganization: 'National Academy of Sports Medicine (NASM)',
      dateObtained: new Date(2017, 5, 15),
      expiryDate: new Date(2027, 5, 15),
    },
    {
      id: '2',
      name: 'Nutrition Specialist Certification',
      issuingOrganization: 'International Sports Sciences Association (ISSA)',
      dateObtained: new Date(2018, 8, 20),
    },
    {
      id: '3',
      name: 'Advanced Strength and Conditioning Specialist',
      issuingOrganization: 'National Strength and Conditioning Association (NSCA)',
      dateObtained: new Date(2019, 3, 10),
      expiryDate: new Date(2025, 3, 10),
    },
  ]);

  // Experience
  const [experiences, setExperiences] = useState<Experience[]>([
    {
      id: '1',
      title: 'Senior Fitness Coach',
      organization: 'Elite Fitness Center',
      startDate: new Date(2020, 0, 1),
      isCurrent: true,
      description: 'Lead trainer managing 30+ clients, specializing in strength training and body transformation programs.'
    },
    {
      id: '2',
      title: 'Personal Trainer',
      organization: 'Gold\'s Gym',
      startDate: new Date(2017, 5, 1),
      endDate: new Date(2019, 11, 31),
      isCurrent: false,
      description: 'Provided one-on-one training sessions focusing on weight loss and muscle building.'
    },
  ]);

  // Achievements
  const [achievements, setAchievements] = useState<Achievement[]>([
    {
      id: '1',
      title: 'Top Trainer of the Year 2023',
      description: 'Awarded for exceptional client results and satisfaction ratings',
      date: new Date(2023, 11, 15),
      type: 'award'
    },
    {
      id: '2',
      title: 'National Bodybuilding Championship - 1st Place',
      description: 'Men\'s Physique Category',
      date: new Date(2021, 6, 20),
      type: 'medal'
    },
    {
      id: '3',
      title: 'Client Success Award',
      description: 'Recognized for helping 50+ clients achieve their fitness goals',
      date: new Date(2022, 9, 10),
      type: 'recognition'
    },
  ]);

  // Stats
  const coachStats = {
    totalClients: 87,
    activeClients: 45,
    completedSessions: 1240,
    avgRating: 4.8,
    successRate: 92,
    totalRevenue: 45000,
    monthlyRevenue: 5600
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString(isRTL ? 'ar-SA' : 'en-US', { 
      month: 'short', 
      year: 'numeric' 
    });
  };

  const getAchievementIcon = (type: string) => {
    switch (type) {
      case 'medal': return <Medal className="w-5 h-5 text-yellow-500" />;
      case 'award': return <Award className="w-5 h-5 text-purple-500" />;
      case 'recognition': return <Star className="w-5 h-5 text-blue-500" />;
      default: return <Award className="w-5 h-5" />;
    }
  };

  const handleSaveBasicInfo = () => {
    onUpdateProfile({
      ...userProfile,
      name: basicInfo.name,
      email: basicInfo.email
    });
    setIsEditingBasic(false);
    toast.success(t('account.profileUpdated'));
  };

  const handleSaveBio = () => {
    setIsEditingBio(false);
    toast.success(t('account.bioUpdated'));
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
        <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-semibold">{t('coach.myProfile')}</h1>
            <p className="text-sm text-white/80">{t('coach.professionalProfile')}</p>
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={onLogout}
            className="text-white hover:bg-white/20"
          >
            <Settings className="w-5 h-5" />
          </Button>
        </div>
      </div>

      {/* Profile Header Card */}
      <div className="p-4">
        <Card className="mb-4">
          <CardContent className="p-6">
            <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <Avatar className="w-20 h-20">
                <AvatarImage src={userProfile.avatar} />
                <AvatarFallback className="bg-purple-100 text-purple-700 text-2xl">
                  {basicInfo.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              
              <div className="flex-1">
                <div className={`flex items-center gap-2 mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <h2 className="text-2xl font-bold">{basicInfo.name}</h2>
                  <Badge className="bg-purple-100 text-purple-700 hover:bg-purple-100">
                    <Award className={`w-3 h-3 ${isRTL ? 'ml-1' : 'mr-1'}`} />
                    {t('coach.verified')}
                  </Badge>
                </div>
                
                <p className="text-muted-foreground mb-3">{basicInfo.email}</p>
                
                <div className={`flex items-center gap-4 text-sm ${isRTL ? 'flex-row-reverse' : ''}`}>
                  <div className={`flex items-center gap-1 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                    <span className="font-semibold">{coachStats.avgRating}</span>
                    <span className="text-muted-foreground">({coachStats.totalClients} {t('coach.reviews')})</span>
                  </div>
                  <span className="text-muted-foreground">•</span>
                  <div className={`flex items-center gap-1 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <Users className="w-4 h-4 text-muted-foreground" />
                    <span>{coachStats.activeClients} {t('coach.activeClients')}</span>
                  </div>
                  <span className="text-muted-foreground">•</span>
                  <div className={`flex items-center gap-1 ${isRTL ? 'flex-row-reverse' : ''}`}>
                    <Calendar className="w-4 h-4 text-muted-foreground" />
                    <span>{basicInfo.yearsOfExperience} {t('coach.yearsExp')}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Specializations */}
            <div className={`flex flex-wrap gap-2 mt-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
              {basicInfo.specializations.map((spec, index) => (
                <Badge key={index} variant="secondary">
                  {spec}
                </Badge>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Quick Stats */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <Card>
            <CardContent className="p-4 text-center">
              <Users className="w-6 h-6 mx-auto mb-2 text-purple-600" />
              <p className="text-2xl font-bold">{coachStats.totalClients}</p>
              <p className="text-xs text-muted-foreground">{t('coach.totalClients')}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <Video className="w-6 h-6 mx-auto mb-2 text-blue-600" />
              <p className="text-2xl font-bold">{coachStats.completedSessions}</p>
              <p className="text-xs text-muted-foreground">{t('coach.sessions')}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <TrendingUp className="w-6 h-6 mx-auto mb-2 text-green-600" />
              <p className="text-2xl font-bold">{coachStats.successRate}%</p>
              <p className="text-xs text-muted-foreground">{t('coach.successRate')}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <DollarSign className="w-6 h-6 mx-auto mb-2 text-orange-600" />
              <p className="text-2xl font-bold">${coachStats.monthlyRevenue}</p>
              <p className="text-xs text-muted-foreground">{t('coach.monthlyRevenue')}</p>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="px-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">{t('coach.overview')}</TabsTrigger>
          <TabsTrigger value="certificates">{t('coach.certificates')}</TabsTrigger>
          <TabsTrigger value="experience">{t('coach.experience')}</TabsTrigger>
          <TabsTrigger value="achievements">{t('coach.achievements')}</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-4 mt-4">
          {/* Bio Section */}
          <Card>
            <CardHeader>
              <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                <CardTitle className="flex items-center gap-2">
                  <User className="w-5 h-5" />
                  {t('coach.bio')}
                </CardTitle>
                {!isEditingBio ? (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setIsEditingBio(true)}
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                ) : (
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsEditingBio(false)}
                    >
                      <X className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="default"
                      size="sm"
                      onClick={handleSaveBio}
                    >
                      <Check className="w-4 h-4" />
                    </Button>
                  </div>
                )}
              </div>
            </CardHeader>
            <CardContent>
              {isEditingBio ? (
                <Textarea
                  value={basicInfo.bio}
                  onChange={(e) => setBasicInfo({ ...basicInfo, bio: e.target.value })}
                  rows={4}
                  className="w-full"
                />
              ) : (
                <p className="text-muted-foreground leading-relaxed">{basicInfo.bio}</p>
              )}
            </CardContent>
          </Card>

          {/* Contact Information */}
          <Card>
            <CardHeader>
              <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                <CardTitle>{t('coach.contactInfo')}</CardTitle>
                {!isEditingBasic ? (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setIsEditingBasic(true)}
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                ) : (
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsEditingBasic(false)}
                    >
                      <X className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="default"
                      size="sm"
                      onClick={handleSaveBasicInfo}
                    >
                      <Check className="w-4 h-4" />
                    </Button>
                  </div>
                )}
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label>{t('account.email')}</Label>
                {isEditingBasic ? (
                  <Input
                    type="email"
                    value={basicInfo.email}
                    onChange={(e) => setBasicInfo({ ...basicInfo, email: e.target.value })}
                  />
                ) : (
                  <p className="text-muted-foreground mt-1">{basicInfo.email}</p>
                )}
              </div>
              <div>
                <Label>{t('account.phone')}</Label>
                {isEditingBasic ? (
                  <Input
                    type="tel"
                    value={basicInfo.phone}
                    onChange={(e) => setBasicInfo({ ...basicInfo, phone: e.target.value })}
                  />
                ) : (
                  <p className="text-muted-foreground mt-1">{basicInfo.phone}</p>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Certificates Tab */}
        <TabsContent value="certificates" className="space-y-4 mt-4">
          <div className={`flex items-center justify-between mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <h3 className="text-lg font-semibold">{t('coach.myCertificates')}</h3>
            <Button size="sm">
              <Plus className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
              {t('coach.addCertificate')}
            </Button>
          </div>

          <ScrollArea className="h-[500px]">
            <div className="space-y-3">
              {certificates.map((cert) => (
                <Card key={cert.id}>
                  <CardContent className="p-4">
                    <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center flex-shrink-0">
                        <Award className="w-6 h-6 text-blue-600" />
                      </div>
                      <div className="flex-1">
                        <h4 className="font-semibold mb-1">{cert.name}</h4>
                        <p className="text-sm text-muted-foreground mb-2">
                          {cert.issuingOrganization}
                        </p>
                        <div className={`flex items-center gap-4 text-xs text-muted-foreground ${isRTL ? 'flex-row-reverse' : ''}`}>
                          <span>{t('coach.issued')}: {formatDate(cert.dateObtained)}</span>
                          {cert.expiryDate && (
                            <>
                              <span>•</span>
                              <span>{t('coach.expires')}: {formatDate(cert.expiryDate)}</span>
                            </>
                          )}
                        </div>
                        {cert.certificateUrl && (
                          <Button variant="link" size="sm" className="mt-2 p-0 h-auto">
                            <FileText className={`w-4 h-4 ${isRTL ? 'ml-1' : 'mr-1'}`} />
                            {t('coach.viewCertificate')}
                          </Button>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </ScrollArea>
        </TabsContent>

        {/* Experience Tab */}
        <TabsContent value="experience" className="space-y-4 mt-4">
          <div className={`flex items-center justify-between mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <h3 className="text-lg font-semibold">{t('coach.workExperience')}</h3>
            <Button size="sm">
              <Plus className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
              {t('coach.addExperience')}
            </Button>
          </div>

          <ScrollArea className="h-[500px]">
            <div className="space-y-3">
              {experiences.map((exp) => (
                <Card key={exp.id}>
                  <CardContent className="p-4">
                    <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <div className="w-12 h-12 rounded-lg bg-purple-100 flex items-center justify-center flex-shrink-0">
                        <BookOpen className="w-6 h-6 text-purple-600" />
                      </div>
                      <div className="flex-1">
                        <div className={`flex items-start justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
                          <div>
                            <h4 className="font-semibold mb-1">{exp.title}</h4>
                            <p className="text-sm text-muted-foreground mb-2">
                              {exp.organization}
                            </p>
                          </div>
                          {exp.isCurrent && (
                            <Badge variant="secondary" className="bg-green-100 text-green-700">
                              {t('coach.current')}
                            </Badge>
                          )}
                        </div>
                        <p className="text-xs text-muted-foreground mb-2">
                          {formatDate(exp.startDate)} - {exp.isCurrent ? t('coach.present') : formatDate(exp.endDate!)}
                        </p>
                        <p className="text-sm text-muted-foreground">
                          {exp.description}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </ScrollArea>
        </TabsContent>

        {/* Achievements Tab */}
        <TabsContent value="achievements" className="space-y-4 mt-4">
          <div className={`flex items-center justify-between mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
            <h3 className="text-lg font-semibold">{t('coach.myAchievements')}</h3>
            <Button size="sm">
              <Plus className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
              {t('coach.addAchievement')}
            </Button>
          </div>

          <ScrollArea className="h-[500px]">
            <div className="space-y-3">
              {achievements.map((achievement) => (
                <Card key={achievement.id} className="overflow-hidden">
                  <CardContent className="p-4">
                    <div className={`flex items-start gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
                      <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-yellow-100 to-yellow-200 flex items-center justify-center flex-shrink-0">
                        {getAchievementIcon(achievement.type)}
                      </div>
                      <div className="flex-1">
                        <div className={`flex items-start justify-between mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
                          <h4 className="font-semibold">{achievement.title}</h4>
                          <Badge variant="outline" className="capitalize">
                            {achievement.type}
                          </Badge>
                        </div>
                        <p className="text-sm text-muted-foreground mb-2">
                          {achievement.description}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          {formatDate(achievement.date)}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </ScrollArea>
        </TabsContent>
      </Tabs>
    </div>
  );
}
