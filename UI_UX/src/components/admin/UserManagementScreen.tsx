import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Badge } from '../ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { ArrowLeft, Search, Filter, Edit3, Ban, CheckCircle, Mail, Phone } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  subscriptionTier: string;
  status: 'active' | 'suspended' | 'inactive';
  joinDate: string;
  lastActive: string;
}

interface UserManagementScreenProps {
  onBack: () => void;
}

export function UserManagementScreen({ onBack }: UserManagementScreenProps) {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [filterTier, setFilterTier] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  const [users] = useState<User[]>([
    {
      id: '1',
      name: 'Mina H.',
      email: 'mina.h@demo.com',
      phone: '+966501234567',
      subscriptionTier: 'Smart Premium',
      status: 'active',
      joinDate: '2024-01-15',
      lastActive: '2024-10-27'
    },
    {
      id: '2',
      name: 'Ahmed K.',
      email: 'ahmed.k@demo.com',
      phone: '+966502345678',
      subscriptionTier: 'Premium',
      status: 'active',
      joinDate: '2024-02-20',
      lastActive: '2024-10-26'
    },
    {
      id: '3',
      name: 'Fatima A.',
      email: 'fatima.a@demo.com',
      phone: '+966503456789',
      subscriptionTier: 'Freemium',
      status: 'inactive',
      joinDate: '2024-03-10',
      lastActive: '2024-10-15'
    }
  ]);

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesTier = filterTier === 'all' || user.subscriptionTier === filterTier;
    const matchesStatus = filterStatus === 'all' || user.status === filterStatus;
    return matchesSearch && matchesTier && matchesStatus;
  });

  const handleSuspendUser = (userId: string) => {
    toast.success(t('admin.userSuspended'));
  };

  const handleActivateUser = (userId: string) => {
    toast.success(t('admin.userActivated'));
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'suspended': return 'bg-red-100 text-red-800';
      case 'inactive': return 'bg-gray-100 text-gray-800';
      default: return '';
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-semibold">{t('admin.userManagement')}</h1>
            <p className="text-sm text-white/80">{filteredUsers.length} {filteredUsers.length === 1 ? 'user' : 'users'}</p>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Card>
          <CardHeader>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  placeholder={t('admin.searchUsers')}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Select value={filterTier} onValueChange={setFilterTier}>
                <SelectTrigger className="w-full md:w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.allTiers')}</SelectItem>
                  <SelectItem value="Freemium">Freemium</SelectItem>
                  <SelectItem value="Premium">Premium</SelectItem>
                  <SelectItem value="Smart Premium">Smart Premium</SelectItem>
                </SelectContent>
              </Select>
              <Select value={filterStatus} onValueChange={setFilterStatus}>
                <SelectTrigger className="w-full md:w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.allStatuses')}</SelectItem>
                  <SelectItem value="active">{t('admin.active')}</SelectItem>
                  <SelectItem value="inactive">{t('admin.inactive')}</SelectItem>
                  <SelectItem value="suspended">{t('admin.suspended')}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            {filteredUsers.length === 0 ? (
              <div className="text-center py-12">
                <div className="flex justify-center mb-4">
                  <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center">
                    <Mail className="w-8 h-8 text-muted-foreground" />
                  </div>
                </div>
                <h3 className="text-lg font-semibold mb-2">{t('admin.noUsers')}</h3>
                <p className="text-sm text-muted-foreground">{t('admin.adjustFilters')}</p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>{t('admin.name')}</TableHead>
                    <TableHead>{t('admin.contact')}</TableHead>
                    <TableHead>{t('admin.subscription')}</TableHead>
                    <TableHead>{t('admin.status')}</TableHead>
                    <TableHead>{t('admin.joined')}</TableHead>
                    <TableHead className="text-right">{t('admin.actions')}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredUsers.map(user => (
                    <TableRow key={user.id}>
                    <TableCell className="font-medium">{user.name}</TableCell>
                    <TableCell>
                      <div className="space-y-1 text-sm">
                        <div className="flex items-center gap-2">
                          <Mail className="w-3 h-3" />
                          <span>{user.email}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Phone className="w-3 h-3" />
                          <span>{user.phone}</span>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge>{user.subscriptionTier}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge className={getStatusColor(user.status)}>
                        {user.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {new Date(user.joinDate).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2 justify-end">
                        <Button variant="outline" size="icon">
                          <Edit3 className="w-4 h-4" />
                        </Button>
                        {user.status === 'active' ? (
                          <Button variant="outline" size="icon" onClick={() => handleSuspendUser(user.id)}>
                            <Ban className="w-4 h-4 text-destructive" />
                          </Button>
                        ) : (
                          <Button variant="outline" size="icon" onClick={() => handleActivateUser(user.id)}>
                            <CheckCircle className="w-4 h-4 text-green-600" />
                          </Button>
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