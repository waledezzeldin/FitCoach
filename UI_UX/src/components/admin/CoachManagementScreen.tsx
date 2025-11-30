import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Badge } from '../ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { ArrowLeft, Search, CheckCircle, XCircle, Eye, Star } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

interface Coach {
  id: string;
  name: string;
  email: string;
  specialization: string;
  clientCount: number;
  rating: number;
  status: 'active' | 'pending' | 'suspended';
  joinDate: string;
}

export function CoachManagementScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [coaches] = useState<Coach[]>([
    {
      id: '1',
      name: 'Sara Ahmed',
      email: 'sara.ahmed@fitcoach.com',
      specialization: 'Strength Training',
      clientCount: 25,
      rating: 4.9,
      status: 'active',
      joinDate: '2024-01-10'
    },
    {
      id: '2',
      name: 'Mohammed Ali',
      email: 'mohammed.ali@fitcoach.com',
      specialization: 'Weight Loss',
      clientCount: 18,
      rating: 4.7,
      status: 'active',
      joinDate: '2024-02-15'
    },
    {
      id: '3',
      name: 'Layla Hassan',
      email: 'layla.hassan@fitcoach.com',
      specialization: 'Nutrition',
      clientCount: 0,
      rating: 0,
      status: 'pending',
      joinDate: '2024-10-25'
    }
  ]);

  const filteredCoaches = coaches.filter(coach =>
    coach.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    coach.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleApprove = (id: string) => {
    toast.success(t('admin.coachApproved'));
  };

  const handleReject = (id: string) => {
    toast.success(t('admin.coachRejected'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-purple-600 to-pink-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-semibold">{t('admin.coachManagement')}</h1>
            <p className="text-sm text-white/80">{filteredCoaches.length} {filteredCoaches.length === 1 ? 'coach' : 'coaches'}</p>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Card>
          <CardHeader>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder={t('admin.searchCoaches')}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
          </CardHeader>
          <CardContent>
            {filteredCoaches.length === 0 ? (
              <div className="text-center py-12">
                <div className="flex justify-center mb-4">
                  <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center">
                    <CheckCircle className="w-8 h-8 text-muted-foreground" />
                  </div>
                </div>
                <h3 className="text-lg font-semibold mb-2">{t('admin.noCoaches')}</h3>
                <p className="text-sm text-muted-foreground">{t('admin.adjustFilters')}</p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>{t('admin.name')}</TableHead>
                    <TableHead>{t('admin.specialization')}</TableHead>
                    <TableHead>{t('admin.clients')}</TableHead>
                    <TableHead>{t('admin.rating')}</TableHead>
                    <TableHead>{t('admin.status')}</TableHead>
                    <TableHead className="text-right">{t('admin.actions')}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredCoaches.map(coach => (
                    <TableRow key={coach.id}>
                    <TableCell>
                      <div>
                        <p className="font-medium">{coach.name}</p>
                        <p className="text-sm text-muted-foreground">{coach.email}</p>
                      </div>
                    </TableCell>
                    <TableCell>{coach.specialization}</TableCell>
                    <TableCell>{coach.clientCount}</TableCell>
                    <TableCell>
                      {coach.rating > 0 ? (
                        <div className="flex items-center gap-1">
                          <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                          <span>{coach.rating}</span>
                        </div>
                      ) : (
                        <span className="text-muted-foreground">N/A</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant={
                        coach.status === 'active' ? 'default' :
                        coach.status === 'pending' ? 'secondary' : 'destructive'
                      }>
                        {coach.status}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2 justify-end">
                        <Button variant="outline" size="icon">
                          <Eye className="w-4 h-4" />
                        </Button>
                        {coach.status === 'pending' && (
                          <>
                            <Button variant="outline" size="icon" onClick={() => handleApprove(coach.id)}>
                              <CheckCircle className="w-4 h-4 text-green-600" />
                            </Button>
                            <Button variant="outline" size="icon" onClick={() => handleReject(coach.id)}>
                              <XCircle className="w-4 h-4 text-red-600" />
                            </Button>
                          </>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}