import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Badge } from '../ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { ArrowLeft, Search, Download, Filter, FileText } from 'lucide-react';
import { useLanguage } from '../LanguageContext';
import { toast } from 'sonner@2.0.3';

interface AuditLog {
  id: string;
  timestamp: Date;
  user: string;
  action: string;
  resource: string;
  status: 'success' | 'failed';
  ipAddress: string;
}

export function AuditLogsScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [filterAction, setFilterAction] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  const logs: AuditLog[] = [
    {
      id: '1',
      timestamp: new Date(2024, 9, 27, 14, 30),
      user: 'admin@fitcoach.com',
      action: 'USER_CREATED',
      resource: 'User: mina.h@demo.com',
      status: 'success',
      ipAddress: '192.168.1.1'
    },
    {
      id: '2',
      timestamp: new Date(2024, 9, 27, 14, 25),
      user: 'coach@fitcoach.com',
      action: 'PLAN_UPDATED',
      resource: 'Plan: Upper Body Strength',
      status: 'success',
      ipAddress: '192.168.1.2'
    },
    {
      id: '3',
      timestamp: new Date(2024, 9, 27, 14, 20),
      user: 'admin@fitcoach.com',
      action: 'LOGIN_FAILED',
      resource: 'Admin Dashboard',
      status: 'failed',
      ipAddress: '192.168.1.1'
    },
    {
      id: '4',
      timestamp: new Date(2024, 9, 27, 14, 15),
      user: 'sara.ahmed@fitcoach.com',
      action: 'CLIENT_ASSIGNED',
      resource: 'Client: Ahmed K.',
      status: 'success',
      ipAddress: '192.168.1.3'
    }
  ];

  const filteredLogs = logs.filter(log => {
    const matchesSearch = log.user.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         log.resource.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesAction = filterAction === 'all' || log.action === filterAction;
    const matchesStatus = filterStatus === 'all' || log.status === filterStatus;
    return matchesSearch && matchesAction && matchesStatus;
  });

  const handleExport = () => {
    toast.success(t('admin.logsExported'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-slate-600 to-gray-700 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-semibold">{t('admin.auditLogs')}</h1>
            <p className="text-sm text-white/80">{filteredLogs.length} {filteredLogs.length === 1 ? 'entry' : 'entries'}</p>
          </div>
          <Button variant="secondary" onClick={handleExport} className="bg-white/10 hover:bg-white/20 text-white border-0">
            <Download className="w-4 h-4 mr-2" />
            {t('admin.export')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <Card>
          <CardHeader>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  placeholder={t('admin.searchLogs')}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Select value={filterAction} onValueChange={setFilterAction}>
                <SelectTrigger className="w-full md:w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.allActions')}</SelectItem>
                  <SelectItem value="USER_CREATED">User Created</SelectItem>
                  <SelectItem value="PLAN_UPDATED">Plan Updated</SelectItem>
                  <SelectItem value="LOGIN_FAILED">Login Failed</SelectItem>
                  <SelectItem value="CLIENT_ASSIGNED">Client Assigned</SelectItem>
                </SelectContent>
              </Select>
              <Select value={filterStatus} onValueChange={setFilterStatus}>
                <SelectTrigger className="w-full md:w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.allStatuses')}</SelectItem>
                  <SelectItem value="success">{t('admin.success')}</SelectItem>
                  <SelectItem value="failed">{t('admin.failed')}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            {filteredLogs.length === 0 ? (
              <div className="text-center py-12">
                <div className="flex justify-center mb-4">
                  <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center">
                    <FileText className="w-8 h-8 text-muted-foreground" />
                  </div>
                </div>
                <h3 className="text-lg font-semibold mb-2">{t('admin.noUsers')}</h3>
                <p className="text-sm text-muted-foreground">{t('admin.adjustFilters')}</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="min-w-[180px]">{t('admin.timestamp')}</TableHead>
                      <TableHead className="min-w-[200px]">{t('admin.user')}</TableHead>
                      <TableHead className="min-w-[140px]">{t('admin.action')}</TableHead>
                      <TableHead className="min-w-[200px]">{t('admin.resource')}</TableHead>
                      <TableHead className="min-w-[100px]">{t('admin.status')}</TableHead>
                      <TableHead className="min-w-[130px]">{t('admin.ipAddress')}</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredLogs.map(log => (
                      <TableRow key={log.id}>
                    <TableCell className="text-sm">{log.timestamp.toLocaleString()}</TableCell>
                    <TableCell className="text-sm">{log.user}</TableCell>
                    <TableCell>
                      <Badge variant="outline">{log.action}</Badge>
                    </TableCell>
                    <TableCell className="text-sm">{log.resource}</TableCell>
                    <TableCell>
                      <Badge variant={log.status === 'success' ? 'default' : 'destructive'}>
                        {log.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm font-mono">{log.ipAddress}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}