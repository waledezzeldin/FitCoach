import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Label } from './ui/label';
import { Calendar } from './ui/calendar';
import { ArrowLeft, Download, FileText } from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface ClientReportGeneratorProps {
  clientId: string;
  clientName: string;
  onBack: () => void;
}

export function ClientReportGenerator({ clientId, clientName, onBack }: ClientReportGeneratorProps) {
  const { t } = useLanguage();
  const [reportType, setReportType] = useState('progress');
  const [dateRange, setDateRange] = useState('30days');
  const [startDate, setStartDate] = useState<Date | undefined>(new Date());
  const [endDate, setEndDate] = useState<Date | undefined>(new Date());

  const handleGenerate = () => {
    toast.success(t('coach.reportGenerated'));
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('coach.generateReport')}</h1>
            <p className="text-sm text-white/80">{clientName}</p>
          </div>
        </div>
      </div>

      <div className="p-4 max-w-2xl mx-auto space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>{t('coach.reportSettings')}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>{t('coach.reportType')}</Label>
              <Select value={reportType} onValueChange={setReportType}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="progress">{t('coach.progressReport')}</SelectItem>
                  <SelectItem value="workout">{t('coach.workoutSummary')}</SelectItem>
                  <SelectItem value="nutrition">{t('coach.nutritionAnalysis')}</SelectItem>
                  <SelectItem value="comprehensive">{t('coach.comprehensiveReport')}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>{t('coach.dateRange')}</Label>
              <Select value={dateRange} onValueChange={setDateRange}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="7days">{t('coach.last7Days')}</SelectItem>
                  <SelectItem value="30days">{t('coach.last30Days')}</SelectItem>
                  <SelectItem value="90days">{t('coach.last90Days')}</SelectItem>
                  <SelectItem value="custom">{t('coach.customRange')}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {dateRange === 'custom' && (
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>{t('coach.startDate')}</Label>
                  <Calendar mode="single" selected={startDate} onSelect={setStartDate} className="rounded-md border" />
                </div>
                <div className="space-y-2">
                  <Label>{t('coach.endDate')}</Label>
                  <Calendar mode="single" selected={endDate} onSelect={setEndDate} className="rounded-md border" />
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{t('coach.reportPreview')}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="border-2 border-dashed rounded-lg p-8 text-center text-muted-foreground">
              <FileText className="w-12 h-12 mx-auto mb-4 opacity-50" />
              <p>{t('coach.reportPreviewPlaceholder')}</p>
            </div>
          </CardContent>
        </Card>

        <div className="flex gap-3">
          <Button className="flex-1" onClick={handleGenerate}>
            <Download className="w-4 h-4 mr-2" />
            {t('coach.downloadPDF')}
          </Button>
          <Button variant="outline" className="flex-1" onClick={() => toast.success(t('coach.reportShared'))}>
            {t('coach.shareWithClient')}
          </Button>
        </div>
      </div>
    </div>
  );
}