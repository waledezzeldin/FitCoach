import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ArrowLeft, DollarSign, TrendingUp, Calendar, Download } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface CoachEarningsScreenProps {
  onBack: () => void;
}

export function CoachEarningsScreen({ onBack }: CoachEarningsScreenProps) {
  const { t } = useLanguage();

  const earningsData = [
    { month: 'Jan', amount: 2500 },
    { month: 'Feb', amount: 3200 },
    { month: 'Mar', amount: 2800 },
    { month: 'Apr', amount: 3500 },
    { month: 'May', amount: 4000 },
    { month: 'Jun', amount: 4200 },
  ];

  const transactions = [
    { id: '1', date: '2024-10-27', client: 'Mina H.', type: 'Session', amount: 50 },
    { id: '2', date: '2024-10-26', client: 'Ahmed K.', type: 'Plan', amount: 100 },
    { id: '3', date: '2024-10-25', client: 'Fatima A.', type: 'Session', amount: 50 },
  ];

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-green-600 to-emerald-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('coach.earnings')}</h1>
            <p className="text-sm text-white/80">{t('coach.revenueTracking')}</p>
          </div>
          <Button variant="secondary">
            <Download className="w-4 h-4 mr-2" />
            {t('coach.export')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('coach.thisMonth')}</p>
                  <p className="text-2xl font-bold">$4,200</p>
                </div>
                <div className="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center">
                  <DollarSign className="w-6 h-6 text-green-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('coach.totalEarnings')}</p>
                  <p className="text-2xl font-bold">$20,200</p>
                </div>
                <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-blue-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('coach.pending')}</p>
                  <p className="text-2xl font-bold">$850</p>
                </div>
                <div className="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center">
                  <Calendar className="w-6 h-6 text-yellow-600" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>{t('coach.earningsTrend')}</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={earningsData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="amount" stroke="#10b981" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('coach.recentTransactions')}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {transactions.map(tx => (
                <div key={tx.id} className="flex items-center justify-between p-3 border rounded-lg">
                  <div>
                    <p className="font-medium">{tx.client}</p>
                    <p className="text-sm text-muted-foreground">{tx.type} • {tx.date}</p>
                  </div>
                  <Badge className="bg-green-100 text-green-800">
                    +${tx.amount}
                  </Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
