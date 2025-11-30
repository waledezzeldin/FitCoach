import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Calendar } from './ui/calendar';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from './ui/tooltip';
import { 
  ArrowLeft, 
  Send, 
  Video, 
  Calendar as CalendarIcon, 
  Clock, 
  MessageCircle,
  CheckCircle,
  XCircle,
  Star,
  Paperclip,
  Lock,
  Image as ImageIcon,
  FileText,
  X
} from 'lucide-react';
import { UserProfile } from '../App';
import { useLanguage } from './LanguageContext';
import { QuotaDisplay } from './QuotaDisplay';
import { RatingModal, Rating } from './RatingModal';
import { QuotaUsage, TIER_QUOTAS } from '../types/QuotaTypes';
import { VideoBookingScreen } from './VideoBookingScreen';
import { toast } from 'sonner@2.0.3';
import { CoachIntroScreen } from './CoachIntroScreen';

interface CoachScreenProps {
  userProfile: UserProfile;
  onNavigate: (screen: 'home' | 'workout' | 'nutrition' | 'store' | 'account') => void;
  onViewCoachProfile?: () => void;
  isDemoMode: boolean;
}

interface Coach {
  id: string;
  name: string;
  avatar?: string;
  specialties: string[];
  rating: number;
  yearsExperience: number;
}

interface Attachment {
  id: string;
  type: 'image' | 'pdf';
  url: string;
  name: string;
  size: number;
}

interface Message {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: Date;
  isFromCoach: boolean;
  attachments?: Attachment[];
}

interface Session {
  id: string;
  date: Date;
  time: string;
  duration: number;
  status: 'pending' | 'approved' | 'rejected' | 'completed';
  type: 'chat' | 'video';
}

export function CoachScreen({ userProfile, onNavigate, onViewCoachProfile, isDemoMode }: CoachScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('messages');
  const [messageInput, setMessageInput] = useState('');
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date());
  const [showVideoBooking, setShowVideoBooking] = useState(false);
  
  // Show intro screen on first usage
  const [showIntro, setShowIntro] = React.useState(() => {
    const hasSeenIntro = localStorage.getItem('coach_intro_seen');
    return !hasSeenIntro;
  });
  
  // v2.0: Quota tracking
  const quotaLimits = TIER_QUOTAS[userProfile.subscriptionTier];
  const [quotaUsage, setQuotaUsage] = useState<QuotaUsage>({
    messagesUsed: isDemoMode ? 8 : 0,
    messagesTotal: quotaLimits.messages,
    callsUsed: isDemoMode ? 1 : 0,
    callsTotal: quotaLimits.calls,
    resetDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
  });
  
  // v2.0: Rating system
  const [showRatingModal, setShowRatingModal] = useState(false);
  const [ratingSessionId, setRatingSessionId] = useState<string | null>(null);
  const [ratings, setRatings] = useState<Rating[]>([]);
  
  // v2.0: File attachments (Premium+ only)
  const [selectedAttachments, setSelectedAttachments] = useState<Attachment[]>([]);
  
  // Booking dialog
  const [showBookingDialog, setShowBookingDialog] = useState(false);
  const [selectedTime, setSelectedTime] = useState<string>('');

  // Demo coach data
  const coach: Coach = {
    id: 'coach_sara',
    name: 'Sara A.',
    specialties: ['Strength Training', 'Weight Loss', 'Nutrition'],
    rating: 4.9,
    yearsExperience: 8,
  };

  // Demo messages
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      senderId: 'coach_sara',
      senderName: 'Sara A.',
      content: "Hi Mina! Great job on completing your workout yesterday. I noticed you increased the weight on your bench press. How did it feel?",
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
      isFromCoach: true,
    },
    {
      id: '2',
      senderId: userProfile.id,
      senderName: userProfile.name,
      content: "Thanks Sara! It felt challenging but manageable. I think I can handle the progression.",
      timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000), // 1 hour ago
      isFromCoach: false,
    },
    {
      id: '3',
      senderId: 'coach_sara',
      senderName: 'Sara A.',
      content: "Perfect! That's exactly what we want to hear. I've updated your program for next week with a slight increase in volume. Keep up the excellent work! 💪",
      timestamp: new Date(Date.now() - 30 * 60 * 1000), // 30 minutes ago
      isFromCoach: true,
    },
  ]);

  // Demo sessions
  const sessions: Session[] = [
    {
      id: '1',
      date: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 days from now
      time: '14:00',
      duration: 30,
      status: 'pending',
      type: 'video',
    },
    {
      id: '2',
      date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 1 week ago
      time: '15:00',
      duration: 30,
      status: 'completed',
      type: 'video',
    },
  ];

  // Subscription limits
  const subscriptionLimits = {
    Freemium: { videoSessions: 1, chatMessages: 50 },
    Premium: { videoSessions: 4, chatMessages: 200 },
    'Smart Premium': { videoSessions: 8, chatMessages: -1 }, // -1 means unlimited
  };

  const currentLimits = subscriptionLimits[userProfile.subscriptionTier];
  const usedSessions = sessions.filter(s => s.status === 'completed' && 
    s.date > new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)).length;
  const usedMessages = messages.filter(m => !m.isFromCoach).length;

  // v2.0: Enhanced sendMessage with quota check and attachments
  const sendMessage = () => {
    if (!messageInput.trim() && selectedAttachments.length === 0) return;

    // Check message quota
    if (quotaUsage.messagesTotal !== 'unlimited' && 
        quotaUsage.messagesUsed >= (quotaUsage.messagesTotal as number)) {
      toast.error(t('coach.quotaExhausted'));
      return;
    }

    const newMessage: Message = {
      id: Date.now().toString(),
      senderId: userProfile.id,
      senderName: userProfile.name,
      content: messageInput,
      timestamp: new Date(),
      isFromCoach: false,
      attachments: selectedAttachments.length > 0 ? [...selectedAttachments] : undefined,
    };

    setMessages(prev => [...prev, newMessage]);
    setMessageInput('');
    setSelectedAttachments([]);
    
    // Update quota
    setQuotaUsage(prev => ({
      ...prev,
      messagesUsed: prev.messagesUsed + 1
    }));

    // Simulate coach auto-reply in demo mode
    if (isDemoMode) {
      setTimeout(() => {
        const autoReply: Message = {
          id: (Date.now() + 1).toString(),
          senderId: 'coach_sara',
          senderName: 'Sara A.',
          content: t('coach.autoReply'),
          timestamp: new Date(),
          isFromCoach: true,
        };
        setMessages(prev => [...prev, autoReply]);
      }, 2000);
    }
  };
  
  // v2.0: Handle file attachment
  const handleAttachFile = () => {
    if (userProfile.subscriptionTier !== 'Smart Premium') {
      toast.error(t('coach.attachmentRequiresPremiumPlus'));
      return;
    }
    
    // Simulate file picker
    const mockAttachment: Attachment = {
      id: Date.now().toString(),
      type: 'image',
      url: '/api/placeholder/400/300',
      name: 'workout-form.jpg',
      size: 245000
    };
    
    setSelectedAttachments(prev => [...prev, mockAttachment]);
    toast.success(t('coach.attachmentAdded'));
  };
  
  const removeAttachment = (id: string) => {
    setSelectedAttachments(prev => prev.filter(a => a.id !== id));
  };
  
  // v2.0: Booking handlers
  const handleBookSession = () => {
    if (quotaUsage.callsUsed >= quotaUsage.callsTotal) {
      toast.error(t('coach.callQuotaExhausted'));
      return;
    }
    setShowBookingDialog(true);
  };
  
  const handleConfirmBooking = () => {
    if (!selectedDate || !selectedTime) {
      toast.error(t('coach.selectDateAndTime'));
      return;
    }
    
    toast.success(t('coach.bookingConfirmed'));
    setShowBookingDialog(false);
    setSelectedTime('');
  };
  
  // v2.0: Rating handlers
  const handleRatingSubmit = (rating: Rating) => {
    setRatings(prev => [...prev, rating]);
    toast.success(t('coach.ratingSubmitted'));
    setShowRatingModal(false);
  };
  
  // Check for completed sessions and trigger rating
  useEffect(() => {
    const completedSessions = sessions.filter(s => s.status === 'completed');
    if (completedSessions.length > 0 && ratings.length === 0 && isDemoMode) {
      // Trigger rating modal for the most recent completed session
      setTimeout(() => {
        setRatingSessionId(completedSessions[0].id);
        setShowRatingModal(true);
      }, 1000);
    }
  }, []);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: true 
    });
  };

  const formatDate = (date: Date) => {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return t('coach.today');
    } else if (date.toDateString() === yesterday.toDateString()) {
      return t('coach.yesterday');
    } else {
      return date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric' 
      });
    }
  };

  // Show video booking screen if requested
  if (showVideoBooking) {
    return (
      <VideoBookingScreen
        userProfile={userProfile}
        onBack={() => setShowVideoBooking(false)}
        isDemoMode={isDemoMode}
      />
    );
  }
  
  // Show intro screen on first visit
  if (showIntro) {
    return (
      <CoachIntroScreen
        onGetStarted={() => {
          setShowIntro(false);
          localStorage.setItem('coach_intro_seen', 'true');
        }}
      />
    );
  }

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-40"
        style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1540206063137-4a88ca974d1a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080)' }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* Header */}
      <div className="bg-purple-600 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={() => onNavigate('home')}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('coach.title')}</h1>
            <p className="text-white/80">{t('coach.subtitle')}</p>
          </div>
        </div>

        {/* Coach Info */}
        <div className="bg-white/10 rounded-2xl p-4">
          <div className="flex items-center gap-3 mb-3">
            <Avatar className="w-12 h-12">
              <AvatarImage src={coach.avatar} />
              <AvatarFallback className="bg-purple-700 text-white">
                {coach.name.split(' ').map(n => n[0]).join('')}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <h3>{coach.name}</h3>
              <div className="flex items-center gap-2 text-sm text-white/80">
                <Star className="w-4 h-4 fill-current" />
                <span>{coach.rating}</span>
                <span>•</span>
                <span>{coach.yearsExperience} {t('coach.years')}</span>
              </div>
            </div>
          </div>
          <div className="flex flex-wrap gap-2 mb-3">
            {coach.specialties.map((specialty, index) => (
              <Badge key={index} variant="secondary" className="bg-white/20 text-white text-xs">
                {specialty}
              </Badge>
            ))}
          </div>
          {onViewCoachProfile && (
            <Button
              variant="secondary"
              size="sm"
              className="w-full"
              onClick={onViewCoachProfile}
            >
              <Star className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
              {t('coach.viewProfile')}
            </Button>
          )}
        </div>
      </div>

      <div className="p-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="messages" className="relative">
              {t('coach.messages')}
              {isDemoMode && (
                <Badge 
                  variant="destructive" 
                  className="absolute -top-2 -right-2 w-5 h-5 p-0 flex items-center justify-center text-xs"
                >
                  1
                </Badge>
              )}
            </TabsTrigger>
            <TabsTrigger value="sessions">{t('coach.sessions')}</TabsTrigger>
          </TabsList>

          <TabsContent value="messages" className="mt-4 space-y-4">
            {/* v2.0: QuotaDisplay */}
            <QuotaDisplay 
              quota={quotaUsage}
              compact={false}
              showUpgradePrompt={userProfile.subscriptionTier === 'Freemium'}
              onUpgrade={() => toast.info(t('common.upgradeToAccessMore'))}
            />

            {/* Messages */}
            <Card className="h-96">
              <CardContent className="p-0 h-full flex flex-col">
                <div className="flex-1 overflow-y-auto p-4 space-y-4">
                  {messages.map((message) => (
                    <div
                      key={message.id}
                      className={`flex ${message.isFromCoach ? 'justify-start' : 'justify-end'}`}
                    >
                      <div
                        className={`max-w-[80%] rounded-2xl p-3 ${
                          message.isFromCoach
                            ? 'bg-muted'
                            : 'bg-primary text-primary-foreground'
                        }`}
                      >
                        <p className="text-sm">{message.content}</p>
                        
                        {/* v2.0: Display attachments */}
                        {message.attachments && message.attachments.length > 0 && (
                          <div className="mt-2 space-y-1">
                            {message.attachments.map(att => (
                              <div key={att.id} className="flex items-center gap-2 text-xs bg-background/20 rounded px-2 py-1">
                                {att.type === 'image' ? <ImageIcon className="w-3 h-3" /> : <FileText className="w-3 h-3" />}
                                <span>{att.name}</span>
                              </div>
                            ))}
                          </div>
                        )}
                        
                        <p className={`text-xs mt-1 ${
                          message.isFromCoach ? 'text-muted-foreground' : 'text-primary-foreground/70'
                        }`}>
                          {formatDate(message.timestamp)} at {formatTime(message.timestamp)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
                
                {/* Message Input */}
                <div className="p-4 border-t space-y-2">
                  {/* v2.0: Selected attachments preview */}
                  {selectedAttachments.length > 0 && (
                    <div className="flex flex-wrap gap-2">
                      {selectedAttachments.map(att => (
                        <div key={att.id} className="flex items-center gap-1 bg-muted rounded-lg px-2 py-1 text-xs">
                          {att.type === 'image' ? <ImageIcon className="w-3 h-3" /> : <FileText className="w-3 h-3" />}
                          <span>{att.name}</span>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-4 w-4"
                            onClick={() => removeAttachment(att.id)}
                          >
                            <X className="w-3 h-3" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  )}
                  
                  <div className="flex gap-2">
                    {/* v2.0: File attachment button (Premium+ only) */}
                    {userProfile.subscriptionTier === 'Smart Premium' ? (
                      <Button 
                        variant="ghost" 
                        size="icon"
                        onClick={handleAttachFile}
                      >
                        <Paperclip className="w-4 h-4" />
                      </Button>
                    ) : (
                      <TooltipProvider>
                        <Tooltip>
                          <TooltipTrigger asChild>
                            <span>
                              <Button variant="ghost" size="icon" disabled>
                                <Lock className="w-4 h-4" />
                              </Button>
                            </span>
                          </TooltipTrigger>
                          <TooltipContent>
                            <p className="text-xs">{t('coach.attachmentRequiresPremiumPlus')}</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    )}
                    
                    <Input
                      placeholder={t('coach.typePlaceholder')}
                      value={messageInput}
                      onChange={(e) => setMessageInput(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                      disabled={quotaUsage.messagesTotal !== 'unlimited' && quotaUsage.messagesUsed >= (quotaUsage.messagesTotal as number)}
                    />
                    <Button 
                      size="icon" 
                      onClick={sendMessage}
                      disabled={(!messageInput.trim() && selectedAttachments.length === 0) || 
                        (quotaUsage.messagesTotal !== 'unlimited' && quotaUsage.messagesUsed >= (quotaUsage.messagesTotal as number))}
                    >
                      <Send className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="sessions" className="mt-4 space-y-4">
            {/* Usage Limits */}
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between text-sm mb-2">
                  <span>{t('coach.videoSessionsUsed')}</span>
                  <span>{usedSessions} / {currentLimits.videoSessions}</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div 
                    className="bg-primary h-2 rounded-full" 
                    style={{ width: `${Math.min((usedSessions / currentLimits.videoSessions) * 100, 100)}%` }}
                  />
                </div>
              </CardContent>
            </Card>

            {/* Book Session - New Enhanced Booking */}
            <Card className="border-purple-200 bg-gradient-to-br from-purple-50 to-blue-50">
              <CardHeader>
                <CardTitle className="text-lg flex items-center gap-2">
                  <Video className="w-5 h-5 text-purple-600" />
                  {t('coach.bookVideoSession') || 'Book Video Session'}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  {t('coach.bookVideoDesc') || 'Schedule a personalized video session with expert coaches'}
                </p>
                <Button 
                  className="w-full bg-purple-600 hover:bg-purple-700"
                  onClick={() => setShowVideoBooking(true)}
                >
                  <Video className="w-4 h-4 mr-2" />
                  {t('coach.bookVideoSession') || 'Book Video Session'}
                </Button>
              </CardContent>
            </Card>

            {/* Quick Book Session (Simple) */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('coach.quickBook') || 'Quick Book with Current Coach'}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={setSelectedDate}
                  disabled={(date) => date < new Date() || date.getDay() === 0 || date.getDay() === 6}
                  className="rounded-md border"
                />
                
                <div className="grid grid-cols-2 gap-2">
                  {['14:00', '15:00', '16:00', '17:00'].map((time) => (
                    <Button key={time} variant="outline" className="text-sm">
                      {time}
                    </Button>
                  ))}
                </div>

                <Button 
                  className="w-full"
                  disabled={quotaUsage.callsUsed >= quotaUsage.callsTotal}
                  onClick={handleBookSession}
                >
                  <Video className="w-4 h-4 mr-2" />
                  {quotaUsage.callsUsed >= quotaUsage.callsTotal ? t('coach.limitReachedSessions') : t('coach.bookSession')}
                </Button>
                
                {usedSessions >= currentLimits.videoSessions && (
                  <p className="text-xs text-muted-foreground text-center">
                    {t('coach.upgradeForSessions')}
                  </p>
                )}
              </CardContent>
            </Card>

            {/* Upcoming & Past Sessions */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('coach.sessionsSectionTitle')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {sessions.map((session) => (
                  <div key={session.id} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className={`w-3 h-3 rounded-full ${
                        session.status === 'completed' ? 'bg-green-500' :
                        session.status === 'approved' ? 'bg-blue-500' :
                        session.status === 'pending' ? 'bg-yellow-500' :
                        'bg-red-500'
                      }`} />
                      <div>
                        <div className="text-sm font-medium">
                          {formatDate(session.date)} at {session.time}
                        </div>
                        <div className="text-xs text-muted-foreground">
                          {session.duration} {t('coach.minutes')}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {session.status === 'pending' && (
                        <Badge variant="outline" className="text-yellow-600">
                          <Clock className="w-3 h-3 mr-1" />
                          {t('coach.pending')}
                        </Badge>
                      )}
                      {session.status === 'approved' && (
                        <Badge variant="outline" className="text-blue-600">
                          <CheckCircle className="w-3 h-3 mr-1" />
                          {t('coach.approved')}
                        </Badge>
                      )}
                      {session.status === 'completed' && (
                        <Badge variant="outline" className="text-green-600">
                          <CheckCircle className="w-3 h-3 mr-1" />
                          {t('coach.completed')}
                        </Badge>
                      )}
                      {session.status === 'rejected' && (
                        <Badge variant="outline" className="text-red-600">
                          <XCircle className="w-3 h-3 mr-1" />
                          {t('coach.rejected')}
                        </Badge>
                      )}
                    </div>
                  </div>
                ))}
                
                {sessions.length === 0 && (
                  <div className="text-center py-8 text-muted-foreground">
                    <MessageCircle className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <p>{t('coach.noSessions')}</p>
                    <p className="text-sm">{t('coach.bookFirst')}</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
      
      {/* v2.0: Booking Dialog */}
      <Dialog open={showBookingDialog} onOpenChange={setShowBookingDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('coach.bookSession')}</DialogTitle>
            <DialogDescription>
              {t('coach.selectDateAndTime')}
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium">{t('coach.selectDate')}</label>
              <Calendar
                mode="single"
                selected={selectedDate}
                onSelect={setSelectedDate}
                disabled={(date) => date < new Date() || date.getDay() === 0 || date.getDay() === 6}
                className="rounded-md border mt-2"
              />
            </div>
            
            <div>
              <label className="text-sm font-medium">{t('coach.selectTime')}</label>
              <Select value={selectedTime} onValueChange={setSelectedTime}>
                <SelectTrigger className="mt-2">
                  <SelectValue placeholder={t('coach.chooseTime')} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="14:00">2:00 PM</SelectItem>
                  <SelectItem value="15:00">3:00 PM</SelectItem>
                  <SelectItem value="16:00">4:00 PM</SelectItem>
                  <SelectItem value="17:00">5:00 PM</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowBookingDialog(false)}>
              {t('common.cancel')}
            </Button>
            <Button onClick={handleConfirmBooking} disabled={!selectedDate || !selectedTime}>
              {t('coach.confirmBooking')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      
      {/* v2.0: Rating Modal */}
      <RatingModal
        open={showRatingModal}
        onOpenChange={setShowRatingModal}
        interactionType="call"
        coachName={coach.name}
        onSubmit={handleRatingSubmit}
        onSkip={() => setShowRatingModal(false)}
      />
      </div>
    </div>
  );
}