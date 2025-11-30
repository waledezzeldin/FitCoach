import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Switch } from '../ui/switch';
import { Textarea } from '../ui/textarea';
import { Separator } from '../ui/separator';
import { ArrowLeft, Save } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

export function SystemSettingsScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();
  const [settings, setSettings] = useState({
    appName: 'FitCoach+',
    maintenanceMode: false,
    allowRegistration: true,
    emailNotifications: true,
    smsNotifications: false,
    defaultLanguage: 'en',
    sessionTimeout: 30,
    maxFileSize: 5,
    termsOfService: 'Terms of service content...',
    privacyPolicy: 'Privacy policy content...'
  });

  const handleSave = () => {
    toast.success(t('admin.settingsSaved'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-gray-700 to-slate-800 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('admin.systemSettings')}</h1>
            <p className="text-sm text-white/80">{t('admin.appConfiguration')}</p>
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
            <CardTitle>{t('admin.general')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>{t('admin.appName')}</Label>
              <Input value={settings.appName} onChange={(e) => setSettings({...settings, appName: e.target.value})} />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">{t('admin.maintenanceMode')}</p>
                <p className="text-sm text-muted-foreground">{t('admin.maintenanceModeDesc')}</p>
              </div>
              <Switch checked={settings.maintenanceMode} onCheckedChange={(checked) => setSettings({...settings, maintenanceMode: checked})} />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">{t('admin.allowRegistration')}</p>
                <p className="text-sm text-muted-foreground">{t('admin.allowRegistrationDesc')}</p>
              </div>
              <Switch checked={settings.allowRegistration} onCheckedChange={(checked) => setSettings({...settings, allowRegistration: checked})} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('admin.notifications')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <Label>{t('admin.emailNotifications')}</Label>
              <Switch checked={settings.emailNotifications} onCheckedChange={(checked) => setSettings({...settings, emailNotifications: checked})} />
            </div>
            <div className="flex items-center justify-between">
              <Label>{t('admin.smsNotifications')}</Label>
              <Switch checked={settings.smsNotifications} onCheckedChange={(checked) => setSettings({...settings, smsNotifications: checked})} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('admin.security')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('admin.sessionTimeout')} (min)</Label>
                <Input type="number" value={settings.sessionTimeout} onChange={(e) => setSettings({...settings, sessionTimeout: parseInt(e.target.value)})} />
              </div>
              <div className="space-y-2">
                <Label>{t('admin.maxFileSize')} (MB)</Label>
                <Input type="number" value={settings.maxFileSize} onChange={(e) => setSettings({...settings, maxFileSize: parseInt(e.target.value)})} />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('admin.legal')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>{t('admin.termsOfService')}</Label>
              <Textarea value={settings.termsOfService} onChange={(e) => setSettings({...settings, termsOfService: e.target.value})} rows={5} />
            </div>
            <div className="space-y-2">
              <Label>{t('admin.privacyPolicy')}</Label>
              <Textarea value={settings.privacyPolicy} onChange={(e) => setSettings({...settings, privacyPolicy: e.target.value})} rows={5} />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}