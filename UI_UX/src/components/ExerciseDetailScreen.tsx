import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Alert, AlertDescription } from './ui/alert';
import { 
  ArrowLeft, 
  Play, 
  RotateCcw, 
  RefreshCw,
  AlertTriangle,
  CheckCircle,
  Info,
  Zap
} from 'lucide-react';
import { ExerciseDetail, getExerciseById, getAlternativeExercises } from './EnhancedExerciseDatabase';
import { useLanguage } from './LanguageContext';

interface ExerciseDetailScreenProps {
  exerciseId: string;
  onBack: () => void;
  onStartExercise: (exerciseId: string) => void;
  onSwapExercise: (newExerciseId: string) => void;
  showFirstTimeOverlay?: boolean;
  onDismissOverlay?: () => void;
}

export function ExerciseDetailScreen({ 
  exerciseId, 
  onBack, 
  onStartExercise,
  onSwapExercise,
  showFirstTimeOverlay = false,
  onDismissOverlay
}: ExerciseDetailScreenProps) {
  const { t, isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('overview');
  const [showAlternatives, setShowAlternatives] = useState(false);
  
  const exercise = getExerciseById(exerciseId);
  const alternatives = getAlternativeExercises(exerciseId);

  if (!exercise) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <p className="text-muted-foreground">{t('exercise.notFound')}</p>
          <Button onClick={onBack} className="mt-4">
            {t('exercise.goBack')}
          </Button>
        </div>
      </div>
    );
  }

  const difficultyColors = {
    beginner: 'bg-green-100 text-green-800',
    intermediate: 'bg-yellow-100 text-yellow-800',
    advanced: 'bg-red-100 text-red-800'
  };

  return (
    <div className="min-h-screen bg-background relative">
      {/* Background Image */}
      <div 
        className="fixed inset-0 z-0"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=1200)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          opacity: 0.4
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
      {/* First-time Tutorial Overlay */}
      {showFirstTimeOverlay && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <Card className="w-full max-w-md">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Info className="w-5 h-5 text-blue-600" />
                {t('exercise.tutorial')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <Play className="w-4 h-4 text-blue-600" />
                  </div>
                  <div>
                    <h4 className="font-medium">{t('exercise.watchVideo')}</h4>
                    <p className="text-sm text-muted-foreground">{t('exercise.reviewForm')}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <Zap className="w-4 h-4 text-green-600" />
                  </div>
                  <div>
                    <h4 className="font-medium">{t('exercise.startSet')}</h4>
                    <p className="text-sm text-muted-foreground">{t('exercise.tapStart')}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <CheckCircle className="w-4 h-4 text-purple-600" />
                  </div>
                  <div>
                    <h4 className="font-medium">{t('exercise.logReps')}</h4>
                    <p className="text-sm text-muted-foreground">{t('exercise.recordWeight')}</p>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" onClick={onDismissOverlay} className="flex-1">
                  {t('exercise.gotIt')}
                </Button>
                <Button onClick={() => {
                  onDismissOverlay?.();
                  onStartExercise(exerciseId);
                }} className="flex-1">
                  {t('exercise.startExercise')}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4">
        <div className={`flex items-center gap-3 mb-4 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            className="text-primary-foreground hover:bg-primary-foreground/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{exercise.name}</h1>
            <p className="text-primary-foreground/80 text-sm">
              {exercise.muscleGroup} • {exercise.category}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant="secondary" className={difficultyColors[exercise.difficulty]}>
              {exercise.difficulty}
            </Badge>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setShowAlternatives(true)}
              className="text-primary-foreground hover:bg-primary-foreground/20"
            >
              <RefreshCw className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Exercise Video/Demo */}
        <Card>
          <CardContent className="p-0">
            <div className="aspect-video bg-muted rounded-lg flex items-center justify-center">
              <div className="text-center">
                <Play className="w-16 h-16 mx-auto mb-3 text-muted-foreground" />
                <p className="text-muted-foreground mb-2">{exercise.name} {t('exercise.demo')}</p>
                <Button variant="outline">
                  <Play className="w-4 h-4 mr-2" />
                  {t('exercise.watchVideoBtn')}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center">
            <div className="text-2xl font-bold">{exercise.defaultSets}</div>
            <div className="text-sm text-muted-foreground">{t('exercise.sets')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{exercise.defaultReps}</div>
            <div className="text-sm text-muted-foreground">{t('exercise.reps')}</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold">{Math.floor(exercise.defaultRestTime / 60)}'</div>
            <div className="text-sm text-muted-foreground">{t('exercise.rest')}</div>
          </div>
        </div>

        {/* Detailed Information Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="overview">{t('exercise.overview')}</TabsTrigger>
            <TabsTrigger value="instructions">{t('exercise.instructions')}</TabsTrigger>
            <TabsTrigger value="tips">{t('exercise.tips')}</TabsTrigger>
          </TabsList>
          
          <TabsContent value="overview" className="space-y-4 mt-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('exercise.equipmentNeeded')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex flex-wrap gap-2">
                  {exercise.equipment.map((item, index) => (
                    <Badge key={index} variant="outline" className="capitalize">
                      {item.replace('_', ' ')}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('exercise.muscleGroups')}</CardTitle>
              </CardHeader>
              <CardContent>
                <Badge variant="secondary" className="capitalize">
                  {exercise.muscleGroup.replace('_', ' ')}
                </Badge>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="instructions" className="space-y-4 mt-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t('exercise.stepByStep')}</CardTitle>
              </CardHeader>
              <CardContent>
                <ol className="space-y-3">
                  {exercise.instructions.map((instruction, index) => (
                    <li key={index} className="flex gap-3">
                      <div className="w-6 h-6 bg-primary text-primary-foreground rounded-full flex items-center justify-center text-sm font-medium flex-shrink-0">
                        {index + 1}
                      </div>
                      <p className="text-sm">{instruction}</p>
                    </li>
                  ))}
                </ol>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="tips" className="space-y-4 mt-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg flex items-center gap-2">
                  <CheckCircle className="w-5 h-5 text-green-600" />
                  {t('exercise.keyCues')}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2">
                  {exercise.cues.map((cue, index) => (
                    <li key={index} className="flex items-start gap-2">
                      <div className="w-2 h-2 bg-green-600 rounded-full mt-2 flex-shrink-0"></div>
                      <p className="text-sm">{cue}</p>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>

            <Alert>
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                <strong>{t('exercise.commonMistakes')}:</strong>
                <ul className="mt-2 space-y-1">
                  {exercise.commonMistakes.map((mistake, index) => (
                    <li key={index} className="text-sm">• {mistake}</li>
                  ))}
                </ul>
              </AlertDescription>
            </Alert>
          </TabsContent>
        </Tabs>

        {/* Action Buttons */}
        <div className="flex gap-3">
          <Button variant="outline" className="flex-1" onClick={() => setShowAlternatives(true)}>
            <RefreshCw className="w-4 h-4 mr-2" />
            {t('exercise.swapExercise')}
          </Button>
          <Button className="flex-1" onClick={() => onStartExercise(exerciseId)}>
            <Play className="w-4 h-4 mr-2" />
            {t('exercise.startExercise')}
          </Button>
        </div>
      </div>

      {/* Alternative Exercises Modal */}
      {showAlternatives && (
        <div className="fixed inset-0 bg-black/50 z-40 flex items-end justify-center p-4">
          <Card className="w-full max-w-md max-h-[80vh] overflow-hidden">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>{t('exercise.alternativeExercises')}</CardTitle>
                <Button variant="ghost" size="icon" onClick={() => setShowAlternatives(false)}>
                  <ArrowLeft className="w-4 h-4" />
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-3 overflow-y-auto">
              {alternatives.length > 0 ? (
                alternatives.map((alt) => (
                  <Card key={alt.id} className="cursor-pointer hover:bg-muted/50" onClick={() => {
                    onSwapExercise(alt.id);
                    setShowAlternatives(false);
                  }}>
                    <CardContent className="p-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-medium">{alt.name}</h4>
                          <p className="text-sm text-muted-foreground">
                            {alt.defaultSets} sets • {alt.defaultReps} reps
                          </p>
                          <div className="flex gap-1 mt-1">
                            {alt.equipment.slice(0, 2).map((eq, i) => (
                              <Badge key={i} variant="outline" className="text-xs">
                                {eq.replace('_', ' ')}
                              </Badge>
                            ))}
                          </div>
                        </div>
                        <Badge variant="secondary" className={difficultyColors[alt.difficulty]}>
                          {alt.difficulty}
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <p className="text-center text-muted-foreground py-8">
                  {t('exercise.noAlternatives')}
                </p>
              )}
            </CardContent>
          </Card>
        </div>
      )}
      </div>
    </div>
  );
}