import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Calendar } from './ui/calendar';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Separator } from './ui/separator';
import { 
  ArrowLeft, 
  Video, 
  Calendar as CalendarIcon, 
  Clock, 
  Star,
  CheckCircle,
  Crown,
  AlertCircle
} from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { QuotaDisplay } from './QuotaDisplay';
import { TIER_QUOTAS } from '../types/QuotaTypes';
import { toast } from 'sonner@2.0.3';

interface VideoBookingScreenProps {
  userProfile: UserProfile;
  onBack: () => void;
  isDemoMode: boolean;
}

interface Coach {
  id: string;
  name: string;
  avatar?: string;
  specialties: string[];
  rating: number;
  yearsExperience: number;
  hourlyRate: number;
  availableSlots: string[];
}

interface TimeSlot {
  time: string;
  available: boolean;
}

export function VideoBookingScreen({ userProfile, onBack, isDemoMode }: VideoBookingScreenProps) {
  const { t, isRTL } = useLanguage();
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date());
  const [selectedTime, setSelectedTime] = useState<string>('');
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);

  // Quota tracking
  const quotaLimits = TIER_QUOTAS[userProfile.subscriptionTier];
  const callsUsed = isDemoMode ? 1 : 0;
  const callsRemaining = quotaLimits.calls === -1 ? -1 : quotaLimits.calls - callsUsed;
  const hasCallsAvailable = quotaLimits.calls === -1 || callsRemaining > 0;

  // Get assigned coach (in a real app, this would come from userProfile.assignedCoachId)
  // For now, we'll use a default coach assigned by admin
  const assignedCoach: Coach = {
    id: '1',
    name: 'Ahmed Hassan',
    specialties: ['Weight Loss', 'Strength Training', 'Nutrition'],
    rating: 4.9,
    yearsExperience: 8,
    hourlyRate: 150,
    availableSlots: ['09:00', '10:00', '14:00', '16:00', '18:00'],
  };

  // Generate time slots based on assigned coach
  const generateTimeSlots = (): TimeSlot[] => {
    const allSlots = [
      '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
      '19:00', '20:00', '21:00'
    ];

    return allSlots.map(time => ({
      time,
      available: assignedCoach.availableSlots.includes(time)
    }));
  };

  const handleTimeSelect = (time: string) => {
    setSelectedTime(time);
  };

  const handleBookSession = () => {
    if (!hasCallsAvailable) {
      toast.error(t('coach.noCallsRemaining') || 'No video calls remaining');
      return;
    }

    if (!selectedDate || !selectedTime) {
      toast.error(t('coach.fillAllFields') || 'Please select date and time');
      return;
    }

    setShowConfirmDialog(true);
  };

  const confirmBooking = () => {
    // Simulate booking
    toast.success(
      t('coach.bookingConfirmed') || 
      `Video session booked with ${assignedCoach.name} on ${selectedDate?.toLocaleDateString()} at ${selectedTime}`
    );
    setShowConfirmDialog(false);
    onBack();
  };

  const timeSlots = generateTimeSlots();

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.4
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-6 sticky top-0 z-10">
        <div className={`flex items-center gap-4 mb-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button
            variant="ghost"
            size="icon"
            onClick={onBack}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className={`w-5 h-5 ${isRTL ? 'rotate-180' : ''}`} />
          </Button>
          <div className={isRTL ? 'text-right' : 'text-left'}>
            <h1 className="flex items-center gap-2">
              <Video className="w-6 h-6" />
              {t('coach.bookVideoSession') || 'Book Video Session'}
            </h1>
            <p className="text-sm opacity-90">
              {t('coach.bookVideoDesc') || 'Schedule a 1-on-1 video call with your coach'}
            </p>
          </div>
        </div>

        {/* Quota display */}
        {quotaLimits.calls !== -1 && (
          <div className="bg-white/10 rounded-lg p-3 mt-4">
            <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
              <span className="text-sm">
                {t('coach.videoCalls') || 'Video Calls'}
              </span>
              <span className="text-sm font-bold">
                {callsRemaining} / {quotaLimits.calls} {t('coach.remaining') || 'remaining'}
              </span>
            </div>
          </div>
        )}
      </div>

      <div className="p-6 space-y-6">
        {/* No calls available warning */}
        {!hasCallsAvailable && (
          <Card className="border-orange-200 bg-orange-50">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-5 h-5 text-orange-600 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="font-medium text-orange-900">
                    {t('coach.noCallsAvailable') || 'No video calls available'}
                  </p>
                  <p className="text-sm text-orange-700 mt-1">
                    {t('coach.upgradeForCalls') || 'Upgrade your subscription to book video sessions with coaches'}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Assigned Coach Info */}
        <Card className="border-purple-200 bg-purple-50">
          <CardContent className="p-4">
            <div className={`flex items-center gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <Avatar className="w-16 h-16">
                <AvatarImage src={assignedCoach.avatar} />
                <AvatarFallback>{assignedCoach.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
              </Avatar>
              
              <div className={`flex-1 ${isRTL ? 'text-right' : 'text-left'}`}>
                <div className="text-xs text-purple-600 font-medium mb-1">
                  {t('coach.yourAssignedCoach') || 'Your Assigned Coach'}
                </div>
                <h3 className="font-semibold">{assignedCoach.name}</h3>
                <div className="flex items-center gap-2 mt-1">
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    <span className="text-sm">{assignedCoach.rating}</span>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {assignedCoach.yearsExperience} {t('coach.yearsExp') || 'years exp'}
                  </span>
                </div>
                
                <div className="flex flex-wrap gap-1 mt-2">
                  {assignedCoach.specialties.map((specialty, idx) => (
                    <Badge key={idx} variant="secondary" className="text-xs">
                      {specialty}
                    </Badge>
                  ))}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Date Selection */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <CalendarIcon className="w-5 h-5" />
              {t('coach.selectDate') || 'Select Date'}
            </CardTitle>
          </CardHeader>
          <CardContent className="flex justify-center">
            <Calendar
              mode="single"
              selected={selectedDate}
              onSelect={setSelectedDate}
              disabled={(date) => date < new Date()}
              className="rounded-md border"
            />
          </CardContent>
        </Card>

        {/* Time Selection */}
        {selectedDate && (
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <Clock className="w-5 h-5" />
                {t('coach.selectTime') || 'Select Time'}
              </CardTitle>
              <CardDescription>
                {t('coach.availableSlots') || 'Available time slots for'} {selectedDate.toLocaleDateString()}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-2">
                {timeSlots.map((slot) => (
                  <Button
                    key={slot.time}
                    variant={selectedTime === slot.time ? 'default' : 'outline'}
                    disabled={!slot.available}
                    onClick={() => handleTimeSelect(slot.time)}
                    className={`${
                      selectedTime === slot.time 
                        ? 'bg-purple-600 hover:bg-purple-700' 
                        : ''
                    }`}
                  >
                    {slot.time}
                  </Button>
                ))}
              </div>
              {timeSlots.filter(s => s.available).length === 0 && (
                <p className="text-sm text-muted-foreground text-center mt-4">
                  {t('coach.noSlotsAvailable') || 'No slots available for this date'}
                </p>
              )}
            </CardContent>
          </Card>
        )}

        {/* Book Session Button */}
        <Button
          onClick={handleBookSession}
          disabled={!selectedDate || !selectedTime || !hasCallsAvailable}
          className="w-full bg-purple-600 hover:bg-purple-700"
          size="lg"
        >
          <CheckCircle className="w-5 h-5 mr-2" />
          {t('coach.confirmBooking') || 'Confirm Booking'}
        </Button>
      </div>

      {/* Confirmation Dialog */}
      <Dialog open={showConfirmDialog} onOpenChange={setShowConfirmDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('coach.confirmBooking') || 'Confirm Booking'}</DialogTitle>
            <DialogDescription>
              {t('coach.confirmBookingDesc') || 'Please review your booking details'}
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4 py-4">
            <div className="flex items-center gap-3">
              <Avatar className="w-12 h-12">
                <AvatarImage src={assignedCoach.avatar} />
                <AvatarFallback>{assignedCoach.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-semibold">{assignedCoach.name}</p>
                <p className="text-sm text-muted-foreground">
                  {assignedCoach.specialties.slice(0, 2).join(', ')}
                </p>
              </div>
            </div>

            <Separator />

            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-muted-foreground">{t('coach.date') || 'Date'}:</span>
                <span className="font-medium">{selectedDate?.toLocaleDateString()}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">{t('coach.time') || 'Time'}:</span>
                <span className="font-medium">{selectedTime}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">{t('coach.duration') || 'Duration'}:</span>
                <span className="font-medium">60 {t('coach.minutes') || 'minutes'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">{t('coach.cost') || 'Cost'}:</span>
                <span className="font-semibold text-purple-600">{assignedCoach.hourlyRate} SAR</span>
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setShowConfirmDialog(false)}>
              {t('common.cancel') || 'Cancel'}
            </Button>
            <Button onClick={confirmBooking} className="bg-purple-600 hover:bg-purple-700">
              <Video className="w-4 h-4 mr-2" />
              {t('coach.bookNow') || 'Book Now'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      </div>
    </div>
  );
}