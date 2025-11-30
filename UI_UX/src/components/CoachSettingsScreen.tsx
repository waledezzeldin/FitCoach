import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Switch } from './ui/switch';
import { ArrowLeft, Save } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface CoachSettingsScreenProps {
  onBack: () => void;
}

export function CoachSettingsScreen({ onBack }: CoachSettingsScreenProps) {
  const { t } = useLanguage();
  const [profile, setProfile] = useState({
    name: 'Sara Ahmed',
    email: 'sara.ahmed@fitcoach.com',
    phone: '+966501234567',
    bio: 'Certified personal trainer with 8 years of experience',
    specializations: 'Strength Training, Weight Loss, Nutrition',
    acceptingClients: true,
    sessionRate: '50',
    planRate: '200'
  });

  const handleSave = () => {
    toast.success(t('coach.settingsSaved'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('coach.settings')}</h1>
          </div>
          <Button variant="secondary" onClick={handleSave}>
            <Save className="w-4 h-4 mr-2" />
            {t('common.save')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>{t('coach.profileInfo')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('coach.name')}</Label>
                <Input value={profile.name} onChange={(e) => setProfile({...profile, name: e.target.value})} />
              </div>
              <div className="space-y-2">
                <Label>{t('coach.email')}</Label>
                <Input type="email" value={profile.email} onChange={(e) => setProfile({...profile, email: e.target.value})} />
              </div>
            </div>
            
            <div className="space-y-2">
              <Label>{t('coach.phone')}</Label>
              <Input value={profile.phone} onChange={(e) => setProfile({...profile, phone: e.target.value})} />
            </div>

            <div className="space-y-2">
              <Label>{t('coach.bio')}</Label>
              <Textarea value={profile.bio} onChange={(e) => setProfile({...profile, bio: e.target.value})} rows={4} />
            </div>

            <div className="space-y-2">
              <Label>{t('coach.specializations')}</Label>
              <Input value={profile.specializations} onChange={(e) => setProfile({...profile, specializations: e.target.value})} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('coach.pricing')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('coach.sessionRate')} (SAR)</Label>
                <Input type="number" value={profile.sessionRate} onChange={(e) => setProfile({...profile, sessionRate: e.target.value})} />
              </div>
              <div className="space-y-2">
                <Label>{t('coach.planRate')} (SAR)</Label>
                <Input type="number" value={profile.planRate} onChange={(e) => setProfile({...profile, planRate: e.target.value})} />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('coach.availability')}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">{t('coach.acceptingClients')}</p>
                <p className="text-sm text-muted-foreground">{t('coach.acceptingClientsDesc')}</p>
              </div>
              <Switch
                checked={profile.acceptingClients}
                onCheckedChange={(checked) => setProfile({...profile, acceptingClients: checked})}
              />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}