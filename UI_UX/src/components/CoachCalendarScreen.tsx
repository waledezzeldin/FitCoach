import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Calendar } from './ui/calendar';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { ArrowLeft, Plus, Clock, Video, User } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface Appointment {
  id: string;
  clientName: string;
  date: Date;
  time: string;
  duration: number;
  type: 'video' | 'assessment';
  status: 'upcoming' | 'completed' | 'cancelled';
}

interface CoachCalendarScreenProps {
  onBack: () => void;
}

export function CoachCalendarScreen({ onBack }: CoachCalendarScreenProps) {
  const { t } = useLanguage();
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date());
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [appointments] = useState<Appointment[]>([
    {
      id: '1',
      clientName: 'Mina H.',
      date: new Date(2024, 9, 28, 14, 0),
      time: '14:00',
      duration: 30,
      type: 'video',
      status: 'upcoming'
    },
    {
      id: '2',
      clientName: 'Ahmed K.',
      date: new Date(2024, 9, 29, 16, 0),
      time: '16:00',
      duration: 45,
      type: 'assessment',
      status: 'upcoming'
    }
  ]);

  const selectedDateAppointments = appointments.filter(apt => 
    selectedDate && apt.date.toDateString() === selectedDate.toDateString()
  );

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('coach.calendar')}</h1>
            <p className="text-sm text-white/80">{appointments.length} appointments</p>
          </div>
          <Button variant="secondary" onClick={() => setShowAddDialog(true)}>
            <Plus className="w-4 h-4 mr-2" />
            {t('coach.newAppointment')}
          </Button>
        </div>
      </div>

      <div className="p-4 grid md:grid-cols-2 gap-4">
        <Card>
          <CardContent className="p-6">
            <Calendar
              mode="single"
              selected={selectedDate}
              onSelect={setSelectedDate}
              className="rounded-md border"
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>
              {selectedDate ? selectedDate.toLocaleDateString() : t('coach.selectDate')}
            </CardTitle>
          </CardHeader>
          <CardContent>
            {selectedDateAppointments.length > 0 ? (
              <div className="space-y-3">
                {selectedDateAppointments.map(apt => (
                  <Card key={apt.id}>
                    <CardContent className="p-4">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                            <User className="w-5 h-5 text-purple-600" />
                          </div>
                          <div>
                            <p className="font-medium">{apt.clientName}</p>
                            <div className="flex items-center gap-2 text-sm text-muted-foreground">
                              <Clock className="w-3 h-3" />
                              <span>{apt.time} ({apt.duration} min)</span>
                            </div>
                          </div>
                        </div>
                        <Badge variant={apt.type === 'video' ? 'default' : 'secondary'}>
                          {apt.type === 'video' ? <Video className="w-3 h-3 mr-1" /> : null}
                          {apt.type}
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            ) : (
              <div className="text-center py-8 text-muted-foreground">
                <Clock className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>{t('coach.noAppointments')}</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('coach.newAppointment')}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>{t('coach.client')}</Label>
              <Select>
                <SelectTrigger><SelectValue placeholder={t('coach.selectClient')} /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="1">Mina H.</SelectItem>
                  <SelectItem value="2">Ahmed K.</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>{t('coach.time')}</Label>
                <Input type="time" />
              </div>
              <div className="space-y-2">
                <Label>{t('coach.duration')}</Label>
                <Select>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="30">30 min</SelectItem>
                    <SelectItem value="45">45 min</SelectItem>
                    <SelectItem value="60">60 min</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAddDialog(false)}>{t('common.cancel')}</Button>
            <Button onClick={() => { setShowAddDialog(false); toast.success(t('coach.appointmentScheduled')); }}>
              {t('coach.schedule')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}