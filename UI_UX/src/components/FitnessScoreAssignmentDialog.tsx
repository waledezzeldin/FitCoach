import React, { useState } from 'react';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Progress } from './ui/progress';
import { Alert, AlertDescription } from './ui/alert';
import { Badge } from './ui/badge';
import { Slider } from './ui/slider';
import { 
  TrendingUp, 
  TrendingDown, 
  Minus, 
  Info,
  CheckCircle 
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { toast } from 'sonner@2.0.3';

interface FitnessScoreAssignmentDialogProps {
  open: boolean;
  onClose: () => void;
  clientName: string;
  currentScore: number;
  onUpdateScore: (newScore: number, reason: string) => void;
}

export function FitnessScoreAssignmentDialog({
  open,
  onClose,
  clientName,
  currentScore,
  onUpdateScore,
}: FitnessScoreAssignmentDialogProps) {
  const { t, isRTL } = useLanguage();
  const [newScore, setNewScore] = useState(currentScore);
  const [reason, setReason] = useState('');

  const handleSubmit = () => {
    if (!reason.trim()) {
      toast.error('Please provide a reason for the score update');
      return;
    }

    onUpdateScore(newScore, reason);
    toast.success(t('coach.scoreUpdated'));
    onClose();
    
    // Reset form
    setReason('');
    setNewScore(currentScore);
  };

  const scoreDiff = newScore - currentScore;
  const getTrendIcon = () => {
    if (scoreDiff > 0) return <TrendingUp className="w-4 h-4 text-green-500" />;
    if (scoreDiff < 0) return <TrendingDown className="w-4 h-4 text-red-500" />;
    return <Minus className="w-4 h-4 text-gray-500" />;
  };

  const getScoreCategory = (score: number) => {
    if (score >= 90) return { label: 'Elite', color: 'text-purple-600' };
    if (score >= 80) return { label: 'Excellent', color: 'text-green-600' };
    if (score >= 70) return { label: 'Good', color: 'text-blue-600' };
    if (score >= 60) return { label: 'Fair', color: 'text-yellow-600' };
    return { label: 'Needs Improvement', color: 'text-orange-600' };
  };

  const currentCategory = getScoreCategory(currentScore);
  const newCategory = getScoreCategory(newScore);

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className={isRTL ? 'text-right' : 'text-left'}>
            {t('coach.assignFitnessScore')}
          </DialogTitle>
          <DialogDescription className={isRTL ? 'text-right' : 'text-left'}>
            Update fitness score for {clientName}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Current Score Display */}
          <div className="space-y-2">
            <Label>{t('coach.currentScore')}</Label>
            <div className="flex items-center gap-3">
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-2xl font-bold">{currentScore}</span>
                  <span className={`text-sm ${currentCategory.color}`}>
                    {currentCategory.label}
                  </span>
                </div>
                <Progress value={currentScore} className="h-2" />
              </div>
            </div>
          </div>

          {/* New Score Input */}
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <Label htmlFor="newScore">{t('coach.newScore')}</Label>
              <div className="flex items-center gap-2">
                {getTrendIcon()}
                <span className={`text-sm font-medium ${
                  scoreDiff > 0 ? 'text-green-600' : 
                  scoreDiff < 0 ? 'text-red-600' : 
                  'text-gray-600'
                }`}>
                  {scoreDiff > 0 && '+'}{scoreDiff}
                </span>
              </div>
            </div>
            
            <div className="space-y-2">
              <Slider
                id="newScore"
                min={0}
                max={100}
                step={1}
                value={[newScore]}
                onValueChange={(values) => setNewScore(values[0])}
                className="w-full"
              />
              
              <div className="flex items-center justify-between">
                <Input
                  type="number"
                  min={0}
                  max={100}
                  value={newScore}
                  onChange={(e) => setNewScore(Math.min(100, Math.max(0, parseInt(e.target.value) || 0)))}
                  className="w-20 text-center"
                />
                <span className={`text-sm ${newCategory.color}`}>
                  {newCategory.label}
                </span>
              </div>

              <Progress value={newScore} className="h-2" />
            </div>
          </div>

          {/* Reason for Update */}
          <div className="space-y-2">
            <Label htmlFor="reason">{t('coach.scoreReason')} *</Label>
            <Textarea
              id="reason"
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder={t('coach.scoreReasonPlaceholder')}
              rows={3}
              className="resize-none"
            />
          </div>

          {/* Impact Notice */}
          <Alert>
            <Info className="h-4 w-4" />
            <AlertDescription className="text-sm">
              {t('coach.scoreImpact')}
              <ul className="mt-2 space-y-1 text-xs">
                <li>• Higher scores (80-100): Advanced exercises, higher intensity</li>
                <li>• Medium scores (60-79): Intermediate difficulty, progressive overload</li>
                <li>• Lower scores (0-59): Beginner-friendly, focus on form and basics</li>
              </ul>
            </AlertDescription>
          </Alert>
        </div>

        <DialogFooter className={isRTL ? 'flex-row-reverse' : ''}>
          <Button variant="outline" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button onClick={handleSubmit} disabled={!reason.trim()}>
            <CheckCircle className={`w-4 h-4 ${isRTL ? 'ml-2' : 'mr-2'}`} />
            {t('coach.updateScore')}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
