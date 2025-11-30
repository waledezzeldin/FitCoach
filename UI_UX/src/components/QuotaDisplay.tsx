import React from 'react';
import { Card, CardContent } from './ui/card';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { MessageCircle, Video, AlertCircle, Crown } from 'lucide-react';
import { QuotaUsage } from '../types/QuotaTypes';
import { useLanguage } from './LanguageContext';

interface QuotaDisplayProps {
  quota: QuotaUsage;
  compact?: boolean;
  showUpgradePrompt?: boolean;
  onUpgrade?: () => void;
}

export function QuotaDisplay({ quota, compact = false, showUpgradePrompt = false, onUpgrade }: QuotaDisplayProps) {
  const { t, isRTL } = useLanguage();

  const messagesPercent = quota.messagesTotal === 'unlimited' 
    ? 100 
    : (quota.messagesUsed / (quota.messagesTotal as number)) * 100;

  const callsPercent = (quota.callsUsed / quota.callsTotal) * 100;

  const messagesRemaining = quota.messagesTotal === 'unlimited'
    ? 'unlimited'
    : (quota.messagesTotal as number) - quota.messagesUsed;

  const callsRemaining = quota.callsTotal - quota.callsUsed;

  const isMessagesLow = typeof messagesRemaining === 'number' && messagesPercent >= 80;
  const isCallsLow = callsPercent >= 80;

  if (compact) {
    return (
      <div className={`flex gap-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
        {/* Messages */}
        <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <MessageCircle className="w-4 h-4 text-muted-foreground" />
          <span className="text-sm">
            {quota.messagesTotal === 'unlimited' 
              ? t('quota.unlimited')
              : `${messagesRemaining}/${quota.messagesTotal}`
            }
          </span>
          {isMessagesLow && (
            <AlertCircle className="w-4 h-4 text-orange-500" />
          )}
        </div>

        {/* Calls */}
        <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Video className="w-4 h-4 text-muted-foreground" />
          <span className="text-sm">
            {callsRemaining}/{quota.callsTotal}
          </span>
          {isCallsLow && (
            <AlertCircle className="w-4 h-4 text-orange-500" />
          )}
        </div>
      </div>
    );
  }

  return (
    <Card>
      <CardContent className="p-4 space-y-4">
        <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
          <h3 className="text-sm">{t('quota.monthlyUsage')}</h3>
          <Badge variant="outline" className="text-xs">
            {t('quota.resetsOn')} {new Date(quota.resetDate).toLocaleDateString()}
          </Badge>
        </div>

        {/* Messages Quota */}
        <div className="space-y-2">
          <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
            <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <MessageCircle className="w-4 h-4" />
              <span className="text-sm">{t('quota.messages')}</span>
            </div>
            <span className="text-sm font-medium">
              {quota.messagesTotal === 'unlimited' ? (
                <Badge variant="secondary" className="bg-green-100 text-green-800">
                  {t('quota.unlimited')}
                </Badge>
              ) : (
                <>
                  {messagesRemaining} {t('quota.remaining')}
                </>
              )}
            </span>
          </div>
          {quota.messagesTotal !== 'unlimited' && (
            <Progress 
              value={messagesPercent} 
              className={isMessagesLow ? 'bg-orange-100' : ''} 
            />
          )}
          {isMessagesLow && (
            <p className="text-xs text-orange-600 flex items-center gap-1">
              <AlertCircle className="w-3 h-3" />
              {t('quota.runningLow')}
            </p>
          )}
        </div>

        {/* Calls Quota */}
        <div className="space-y-2">
          <div className={`flex items-center justify-between ${isRTL ? 'flex-row-reverse' : ''}`}>
            <div className={`flex items-center gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
              <Video className="w-4 h-4" />
              <span className="text-sm">{t('quota.calls')}</span>
            </div>
            <span className="text-sm font-medium">
              {callsRemaining} {t('quota.remaining')}
            </span>
          </div>
          <Progress 
            value={callsPercent} 
            className={isCallsLow ? 'bg-orange-100' : ''} 
          />
          {isCallsLow && (
            <p className="text-xs text-orange-600 flex items-center gap-1">
              <AlertCircle className="w-3 h-3" />
              {t('quota.runningLow')}
            </p>
          )}
        </div>

        {/* Upgrade Prompt */}
        {showUpgradePrompt && (messagesPercent >= 100 || callsPercent >= 100) && onUpgrade && (
          <div className="pt-2 border-t">
            <button
              onClick={onUpgrade}
              className="w-full flex items-center justify-center gap-2 p-2 rounded-lg bg-gradient-to-r from-purple-50 to-blue-50 border border-purple-200 text-purple-900 hover:border-purple-300 transition-colors"
            >
              <Crown className="w-4 h-4" />
              <span className="text-sm">{t('quota.upgradeForMore')}</span>
            </button>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
