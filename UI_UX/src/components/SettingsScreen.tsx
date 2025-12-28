import React, { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Separator } from './ui/separator';
import { Badge } from './ui/badge';
import { ArrowLeft, Bell, Globe, Shield, Activity, Download, Trash2, Calendar } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';
import { InBodyInputScreen } from './InBodyInputScreen';
import { InBodyData } from '../types/InBodyTypes';

interface SettingsScreenProps {
  onBack: () => void;
  userProfile: any;
  onUpdateProfile: (updatedProfile: any) => void;
}

export function SettingsScreen({ onBack, userProfile, onUpdateProfile }: SettingsScreenProps) {
  const [showInBodyInput, setShowInBodyInput] = useState(false);
  const { t, language, setLanguage } = useLanguage();
  const [settings, setSettings] = useState({
    notifications: {
      workoutReminders: true,
      coachMessages: true,
      nutritionReminders: false,
      promotions: false,
    },
    privacy: {
      shareProgress: true,
      showInLeaderboard: false,
    },
    app: {
      language: language,
      theme: 'system',
      units: 'metric',
    }
  });

  const handleToggle = (category: string, key: string) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [key]: !prev[category][key]
      }
    }));
    toast.success(t('settings.saved'));
  };

  const handleLanguageChange = (newLang: string) => {
    setSettings(prev => ({
      ...prev,
      app: { ...prev.app, language: newLang }
    }));
    setLanguage(newLang as 'en' | 'ar');
    toast.success(t('settings.languageChanged'));
  };

  const handleInBodySave = (data: InBodyData) => {
    const updatedProfile = {
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
    toast.success(t('inbody.dataSaved'));
  };

  // Show InBody input screen if requested
  if (showInBodyInput) {
    return (
      <InBodyInputScreen
        userProfile={userProfile}
        onBack={() => setShowInBodyInput(false)}
        onSave={handleInBodySave}
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
          opacity: 0.8
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-slate-600 to-gray-700 text-white p-4">
        <div className="flex items-center gap-3">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('settings.title')}</h1>
            <p className="text-sm text-white/80">{t('settings.subtitle')}</p>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Notifications */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Bell className="w-5 h-5" />
              {t('settings.notifications')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <Label htmlFor="workout-reminders" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.workoutReminders')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.workoutRemindersDesc')}</p>
                </div>
              </Label>
              <Switch
                id="workout-reminders"
                checked={settings.notifications.workoutReminders}
                onCheckedChange={() => handleToggle('notifications', 'workoutReminders')}
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <Label htmlFor="coach-messages" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.coachMessages')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.coachMessagesDesc')}</p>
                </div>
              </Label>
              <Switch
                id="coach-messages"
                checked={settings.notifications.coachMessages}
                onCheckedChange={() => handleToggle('notifications', 'coachMessages')}
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <Label htmlFor="nutrition-reminders" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.nutritionReminders')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.nutritionRemindersDesc')}</p>
                </div>
              </Label>
              <Switch
                id="nutrition-reminders"
                checked={settings.notifications.nutritionReminders}
                onCheckedChange={() => handleToggle('notifications', 'nutritionReminders')}
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <Label htmlFor="promotions" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.promotions')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.promotionsDesc')}</p>
                </div>
              </Label>
              <Switch
                id="promotions"
                checked={settings.notifications.promotions}
                onCheckedChange={() => handleToggle('notifications', 'promotions')}
              />
            </div>
          </CardContent>
        </Card>

        {/* App Preferences */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Globe className="w-5 h-5" />
              {t('settings.appPreferences')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>{t('settings.language')}</Label>
              <Select value={settings.app.language} onValueChange={handleLanguageChange}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="en">English</SelectItem>
                  <SelectItem value="ar">العربية</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Separator />

            <div className="space-y-2">
              <Label>{t('settings.theme')}</Label>
              <Select value={settings.app.theme} onValueChange={(val) => {
                setSettings(prev => ({ ...prev, app: { ...prev.app, theme: val } }));
                toast.success(t('settings.saved'));
              }}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="light">{t('settings.light')}</SelectItem>
                  <SelectItem value="dark">{t('settings.dark')}</SelectItem>
                  <SelectItem value="system">{t('settings.system')}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Separator />

            <div className="space-y-2">
              <Label>{t('settings.units')}</Label>
              <Select value={settings.app.units} onValueChange={(val) => {
                setSettings(prev => ({ ...prev, app: { ...prev.app, units: val } }));
                toast.success(t('settings.saved'));
              }}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="metric">{t('settings.metric')}</SelectItem>
                  <SelectItem value="imperial">{t('settings.imperial')}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Privacy */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="w-5 h-5" />
              {t('settings.privacy')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <Label htmlFor="share-progress" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.shareProgress')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.shareProgressDesc')}</p>
                </div>
              </Label>
              <Switch
                id="share-progress"
                checked={settings.privacy.shareProgress}
                onCheckedChange={() => handleToggle('privacy', 'shareProgress')}
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <Label htmlFor="leaderboard" className="flex-1">
                <div>
                  <p className="font-medium">{t('settings.showInLeaderboard')}</p>
                  <p className="text-sm text-muted-foreground">{t('settings.showInLeaderboardDesc')}</p>
                </div>
              </Label>
              <Switch
                id="leaderboard"
                checked={settings.privacy.showInLeaderboard}
                onCheckedChange={() => handleToggle('privacy', 'showInLeaderboard')}
              />
            </div>
          </CardContent>
        </Card>

        {/* Health Data */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="w-5 h-5" />
              {t('settings.healthData')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button 
              variant="outline" 
              className="w-full justify-between bg-blue-50 hover:bg-blue-100 border-blue-200"
              onClick={() => setShowInBodyInput(true)}
            >
              <div className="flex items-center">
                <Activity className="w-4 h-4 mr-2 text-blue-600" />
                <span className="text-blue-900">{t('inbody.title')}</span>
              </div>
              {userProfile.inBodyHistory?.latestScan && (
                <Badge variant="secondary" className="text-xs">
                  <Calendar className="w-3 h-3 mr-1" />
                  {new Date(userProfile.inBodyHistory.latestScan.scanDate).toLocaleDateString()}
                </Badge>
              )}
            </Button>
            
            {userProfile.inBodyHistory?.latestScan && (
              <div className="grid grid-cols-3 gap-2 p-3 bg-muted rounded-lg">
                <div className="text-center">
                  <p className="text-xs text-muted-foreground">{t('inbody.weight')}</p>
                  <p className="font-semibold">{userProfile.inBodyHistory.latestScan.weight?.toFixed(1)} kg</p>
                </div>
                <div className="text-center">
                  <p className="text-xs text-muted-foreground">{t('inbody.bmi')}</p>
                  <p className="font-semibold">{userProfile.inBodyHistory.latestScan.bmi?.toFixed(1)}</p>
                </div>
                <div className="text-center">
                  <p className="text-xs text-muted-foreground">{t('inbody.inBodyScore')}</p>
                  <p className="font-semibold">{userProfile.inBodyHistory.latestScan.inBodyScore}</p>
                </div>
              </div>
            )}
            
            <p className="text-xs text-muted-foreground text-center">
              {t('settings.inBodyDesc')}
            </p>
          </CardContent>
        </Card>

        {/* Data Management */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Download className="w-5 h-5" />
              {t('settings.dataManagement')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="outline" className="w-full justify-start">
              <Download className="w-4 h-4 mr-2" />
              {t('settings.downloadData')}
            </Button>
            
            <Button variant="outline" className="w-full justify-start text-destructive hover:text-destructive">
              <Trash2 className="w-4 h-4 mr-2" />
              {t('settings.deleteAccount')}
            </Button>
          </CardContent>
        </Card>
      </div>
      </div>
    </div>
  );
}