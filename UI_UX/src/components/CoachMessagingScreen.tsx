import React, { useState } from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback } from './ui/avatar';
import { ScrollArea } from './ui/scroll-area';
import { 
  ArrowLeft, 
  Send, 
  Image as ImageIcon, 
  FileText, 
  Paperclip,
  Search
} from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface Client {
  id: string;
  name: string;
  email: string;
  subscriptionTier: string;
  lastMessage?: string;
  lastMessageTime?: Date;
  unreadCount?: number;
}

interface Message {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: Date;
  isFromCoach: boolean;
  attachments?: {
    id: string;
    type: 'image' | 'pdf';
    url: string;
    name: string;
  }[];
}

interface CoachMessagingScreenProps {
  coachId: string;
  onBack: () => void;
  isDemoMode: boolean;
}

export function CoachMessagingScreen({ coachId, onBack, isDemoMode }: CoachMessagingScreenProps) {
  const { t, isRTL } = useLanguage();
  const [selectedClient, setSelectedClient] = useState<Client | null>(null);
  const [messageInput, setMessageInput] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  // Demo clients
  const [clients] = useState<Client[]>([
    {
      id: '1',
      name: 'Mina H.',
      email: 'mina.h@demo.com',
      subscriptionTier: 'Smart Premium',
      lastMessage: 'Thanks for the workout plan!',
      lastMessageTime: new Date(Date.now() - 30 * 60 * 1000),
      unreadCount: 2
    },
    {
      id: '2',
      name: 'Ahmed K.',
      email: 'ahmed.k@demo.com',
      subscriptionTier: 'Premium',
      lastMessage: 'Can we reschedule tomorrow?',
      lastMessageTime: new Date(Date.now() - 2 * 60 * 60 * 1000),
      unreadCount: 1
    },
    {
      id: '3',
      name: 'Fatima A.',
      email: 'fatima.a@demo.com',
      subscriptionTier: 'Freemium',
      lastMessage: 'Great session today!',
      lastMessageTime: new Date(Date.now() - 24 * 60 * 60 * 1000),
      unreadCount: 0
    }
  ]);

  // Demo messages for selected client
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      senderId: '1',
      senderName: 'Mina H.',
      content: 'Hi Coach! I have a question about my nutrition plan.',
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
      isFromCoach: false
    },
    {
      id: '2',
      senderId: coachId,
      senderName: 'Coach',
      content: 'Hi Mina! Of course, what would you like to know?',
      timestamp: new Date(Date.now() - 1.5 * 60 * 60 * 1000),
      isFromCoach: true
    },
    {
      id: '3',
      senderId: '1',
      senderName: 'Mina H.',
      content: 'Can I swap the chicken for fish in my dinner meals?',
      timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000),
      isFromCoach: false
    },
    {
      id: '4',
      senderId: coachId,
      senderName: 'Coach',
      content: 'Absolutely! Fish is a great protein source. Just make sure to adjust the portion sizes to match the protein content. I\'ll update your plan.',
      timestamp: new Date(Date.now() - 30 * 60 * 1000),
      isFromCoach: true
    }
  ]);

  const sendMessage = () => {
    if (!messageInput.trim() || !selectedClient) return;

    const newMessage: Message = {
      id: Date.now().toString(),
      senderId: coachId,
      senderName: 'Coach',
      content: messageInput,
      timestamp: new Date(),
      isFromCoach: true,
    };

    setMessages(prev => [...prev, newMessage]);
    setMessageInput('');
  };

  const formatTime = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return t('coach.justNow');
    if (minutes < 60) return `${minutes}m ${t('coach.ago')}`;
    if (hours < 24) return `${hours}h ${t('coach.ago')}`;
    if (days < 7) return `${days}d ${t('coach.ago')}`;
    return date.toLocaleDateString();
  };

  const filteredClients = clients.filter(client =>
    client.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    client.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4">
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
            <h1 className="text-xl">{t('coach.messaging')}</h1>
            <p className="text-sm text-white/80">{t('coach.messagingSubtitle')}</p>
          </div>
        </div>
      </div>

      <div className="flex h-[calc(100vh-80px)]">
        {/* Client List */}
        <div className={`w-80 border-r bg-muted/20 ${selectedClient ? 'hidden md:block' : 'block'}`}>
          {/* Search */}
          <div className="p-3 border-b">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder={t('coach.searchClients')}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
          </div>

          {/* Clients */}
          <ScrollArea className="h-[calc(100%-60px)]">
            {filteredClients.map(client => (
              <div
                key={client.id}
                className={`p-4 border-b cursor-pointer hover:bg-muted/50 transition-colors ${
                  selectedClient?.id === client.id ? 'bg-muted' : ''
                }`}
                onClick={() => setSelectedClient(client)}
              >
                <div className="flex items-start gap-3">
                  <Avatar>
                    <AvatarFallback className="bg-primary text-primary-foreground">
                      {client.name.split(' ').map(n => n[0]).join('')}
                    </AvatarFallback>
                  </Avatar>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <h3 className="font-medium truncate">{client.name}</h3>
                      {client.unreadCount! > 0 && (
                        <Badge variant="destructive" className="ml-2 h-5 min-w-5 rounded-full text-xs px-1.5">
                          {client.unreadCount}
                        </Badge>
                      )}
                    </div>
                    
                    <p className="text-sm text-muted-foreground truncate mb-1">
                      {client.lastMessage}
                    </p>
                    
                    <div className="flex items-center justify-between text-xs">
                      <Badge variant="outline" className="text-xs">
                        {client.subscriptionTier}
                      </Badge>
                      <span className="text-muted-foreground">
                        {client.lastMessageTime && formatTime(client.lastMessageTime)}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </ScrollArea>
        </div>

        {/* Chat Area */}
        {selectedClient ? (
          <div className="flex-1 flex flex-col">
            {/* Chat Header */}
            <div className="p-4 border-b bg-muted/20">
              <div className="flex items-center gap-3">
                <Button
                  variant="ghost"
                  size="icon"
                  className="md:hidden"
                  onClick={() => setSelectedClient(null)}
                >
                  <ArrowLeft className="w-5 h-5" />
                </Button>
                
                <Avatar>
                  <AvatarFallback className="bg-primary text-primary-foreground">
                    {selectedClient.name.split(' ').map(n => n[0]).join('')}
                  </AvatarFallback>
                </Avatar>
                
                <div className="flex-1">
                  <h3 className="font-medium">{selectedClient.name}</h3>
                  <p className="text-sm text-muted-foreground">{selectedClient.email}</p>
                </div>
                
                <Badge>{selectedClient.subscriptionTier}</Badge>
              </div>
            </div>

            {/* Messages */}
            <ScrollArea className="flex-1 p-4">
              <div className="space-y-4">
                {messages.map(message => (
                  <div
                    key={message.id}
                    className={`flex ${message.isFromCoach ? 'justify-end' : 'justify-start'}`}
                  >
                    <div
                      className={`max-w-[70%] rounded-2xl p-3 ${
                        message.isFromCoach
                          ? 'bg-primary text-primary-foreground'
                          : 'bg-muted'
                      }`}
                    >
                      <p className="text-sm">{message.content}</p>
                      
                      {message.attachments && message.attachments.length > 0 && (
                        <div className="mt-2 space-y-1">
                          {message.attachments.map(att => (
                            <div key={att.id} className="flex items-center gap-2 text-xs">
                              {att.type === 'image' ? <ImageIcon className="w-3 h-3" /> : <FileText className="w-3 h-3" />}
                              <span>{att.name}</span>
                            </div>
                          ))}
                        </div>
                      )}
                      
                      <p className={`text-xs mt-1 ${
                        message.isFromCoach ? 'text-primary-foreground/70' : 'text-muted-foreground'
                      }`}>
                        {message.timestamp.toLocaleTimeString('en-US', { 
                          hour: '2-digit', 
                          minute: '2-digit',
                          hour12: true 
                        })}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </ScrollArea>

            {/* Message Input */}
            <div className="p-4 border-t">
              <div className="flex gap-2">
                <Button variant="ghost" size="icon">
                  <Paperclip className="w-4 h-4" />
                </Button>
                
                <Input
                  placeholder={t('coach.typeMessage')}
                  value={messageInput}
                  onChange={(e) => setMessageInput(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                />
                
                <Button size="icon" onClick={sendMessage} disabled={!messageInput.trim()}>
                  <Send className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex-1 hidden md:flex items-center justify-center text-muted-foreground">
            <div className="text-center">
              <Send className="w-12 h-12 mx-auto mb-4 opacity-50" />
              <p>{t('coach.selectClientToStart')}</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
