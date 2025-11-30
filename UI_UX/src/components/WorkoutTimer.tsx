import React, { useState, useEffect, useRef } from 'react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Play, Pause, Square, RotateCcw } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface WorkoutTimerProps {
  onSetComplete?: (duration: number) => void;
  restTime?: number;
  isRestTimer?: boolean;
}

export const WorkoutTimer: React.FC<WorkoutTimerProps> = ({
  onSetComplete,
  restTime = 60,
  isRestTimer = false
}) => {
  const { t } = useLanguage();
  const [time, setTime] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [isResting, setIsResting] = useState(false);
  const intervalRef = useRef<NodeJS.Timeout>();

  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTime(prev => prev + 1);
      }, 1000);
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    }

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [isRunning]);

  useEffect(() => {
    if (isResting && time >= restTime) {
      setIsRunning(false);
      setIsResting(false);
      setTime(0);
    }
  }, [time, restTime, isResting]);

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleStart = () => {
    setIsRunning(true);
  };

  const handlePause = () => {
    setIsRunning(false);
  };

  const handleStop = () => {
    setIsRunning(false);
    if (onSetComplete && !isResting) {
      onSetComplete(time);
    }
    setTime(0);
    setIsResting(false);
  };

  const handleReset = () => {
    setIsRunning(false);
    setTime(0);
    setIsResting(false);
  };

  const handleStartRest = () => {
    if (onSetComplete) {
      onSetComplete(time);
    }
    setIsResting(true);
    setTime(0);
    setIsRunning(true);
  };

  return (
    <Card className="p-4 bg-gradient-to-r from-blue-50 to-purple-50">
      <div className="text-center">
        <div className="mb-4">
          <div className={`text-4xl mb-2 ${isResting ? 'text-orange-600' : 'text-blue-600'}`}>
            {formatTime(time)}
          </div>
          <div className="text-sm text-muted-foreground">
            {isResting ? t('Rest Time') : t('Exercise Time')}
          </div>
          {isResting && (
            <div className="text-xs text-orange-600 mt-1">
              {t('Target')}: {formatTime(restTime)}
            </div>
          )}
        </div>

        <div className="flex justify-center gap-2">
          {!isRunning ? (
            <Button onClick={handleStart} className="flex items-center gap-2">
              <Play size={16} />
              {t('Start')}
            </Button>
          ) : (
            <Button onClick={handlePause} variant="outline" className="flex items-center gap-2">
              <Pause size={16} />
              {t('Pause')}
            </Button>
          )}
          
          <Button onClick={handleReset} variant="outline" className="flex items-center gap-2">
            <RotateCcw size={16} />
            {t('Reset')}
          </Button>

          {!isResting && time > 0 && (
            <Button onClick={handleStartRest} className="flex items-center gap-2 bg-orange-600 hover:bg-orange-700">
              <Square size={16} />
              {t('Finish Set')}
            </Button>
          )}

          {!isResting && (
            <Button onClick={handleStop} variant="destructive" className="flex items-center gap-2">
              <Square size={16} />
              {t('Complete')}
            </Button>
          )}
        </div>

        {isResting && time < restTime && (
          <div className="mt-3">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-orange-600 h-2 rounded-full transition-all duration-1000"
                style={{ width: `${(time / restTime) * 100}%` }}
              />
            </div>
          </div>
        )}
      </div>
    </Card>
  );
};