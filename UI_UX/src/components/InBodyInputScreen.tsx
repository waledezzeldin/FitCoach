import React, { useState, useRef } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { Alert, AlertDescription } from './ui/alert';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  ArrowLeft, 
  Activity, 
  Scale, 
  Droplets, 
  TrendingUp,
  AlertCircle,
  CheckCircle,
  Info,
  Calendar,
  Upload,
  Camera,
  Sparkles,
  Lock,
  Crown,
  Loader2,
  X,
  CheckCircle2
} from 'lucide-react';
import { useLanguage } from './LanguageContext';
import { InBodyData, calculateBodyShape, getBMICategory, getBodyFatCategory, getVisceralFatCategory, getInBodyScoreCategory } from '../types/InBodyTypes';
import { SubscriptionTier } from '../App';
import { toast } from 'sonner@2.0.3';

interface InBodyInputScreenProps {
  onSave: (data: InBodyData) => void;
  onBack: () => void;
  userProfile?: any;
  existingData?: InBodyData;
  userGender?: 'male' | 'female' | 'other';
  subscriptionTier?: SubscriptionTier;
  onUpgrade?: () => void;
}

type InputMode = 'selection' | 'ai-scan' | 'manual';

export function InBodyInputScreen({ onSave, onBack, userProfile, existingData, userGender: userGenderProp, subscriptionTier: subscriptionTierProp, onUpgrade }: InBodyInputScreenProps) {
  // Extract values from userProfile if provided
  const userGender = userGenderProp || userProfile?.gender || 'other';
  const subscriptionTier = subscriptionTierProp || userProfile?.subscriptionTier || 'Freemium';
  const existingInBodyData = existingData || userProfile?.inBodyHistory?.latestScan;
  const { t, isRTL } = useLanguage();
  const [inputMode, setInputMode] = useState<InputMode>('selection');
  const [currentStep, setCurrentStep] = useState(1);
  const totalSteps = 5;
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [uploadedImage, setUploadedImage] = useState<string | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [extractionComplete, setExtractionComplete] = useState(false);

  const [formData, setFormData] = useState<Partial<InBodyData>>(existingInBodyData || {
    weight: 0,
    totalBodyWater: 0,
    intracellularWater: 0,
    extracellularWater: 0,
    dryLeanMass: 0,
    bodyFatMass: 0,
    skeletalMuscleMass: 0,
    bmi: 0,
    percentBodyFat: 0,
    basalMetabolicRate: 0,
    visceralFatLevel: 0,
    ecwTbwRatio: 0,
    inBodyScore: 0,
    segmentalLean: {
      leftArm: 100,
      rightArm: 100,
      trunk: 100,
      leftLeg: 100,
      rightLeg: 100,
    },
    scanDate: new Date(),
    notes: '',
  });

  const isPremium = subscriptionTier === 'Premium' || subscriptionTier === 'Smart Premium';

  // Helper function to round to 3 decimal places
  const roundTo3Decimals = (value: number): number => {
    return parseFloat(value.toFixed(3));
  };

  const updateField = (field: keyof InBodyData, value: any) => {
    // Round numeric values to 3 decimal places (except integers like inBodyScore, visceralFatLevel, basalMetabolicRate)
    const integerFields = ['inBodyScore', 'visceralFatLevel', 'basalMetabolicRate'];
    
    if (typeof value === 'number' && !integerFields.includes(field)) {
      value = roundTo3Decimals(value);
    }
    
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const updateSegmentalField = (segment: keyof InBodyData['segmentalLean'], value: number) => {
    setFormData(prev => ({
      ...prev,
      segmentalLean: {
        ...prev.segmentalLean!,
        [segment]: value,
      }
    }));
  };

  const handleNext = () => {
    if (currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handlePrevious = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleSave = () => {
    // Auto-calculate body shape
    const bodyShape = calculateBodyShape(
      formData.weight || 0,
      formData.skeletalMuscleMass || 0,
      formData.bodyFatMass || 0
    );

    const completeData: InBodyData = {
      ...formData,
      bodyShape,
      scanDate: formData.scanDate || new Date(),
    } as InBodyData;

    onSave(completeData);
  };

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setUploadedImage(reader.result as string);
        simulateAIExtraction();
      };
      reader.readAsDataURL(file);
    }
  };

  const handleCameraCapture = () => {
    // In a real app, this would open the device camera
    // For demo, we'll use file input
    fileInputRef.current?.click();
  };

  const simulateAIExtraction = () => {
    setIsAnalyzing(true);
    
    // Simulate AI processing delay
    setTimeout(() => {
      // Generate realistic demo data - all values rounded to 3 decimal places
      const extractedData: Partial<InBodyData> = {
        weight: parseFloat((75.2 + Math.random() * 10).toFixed(3)),
        bmi: parseFloat((23.5 + Math.random() * 2).toFixed(3)),
        percentBodyFat: parseFloat((18.5 + Math.random() * 5).toFixed(3)),
        inBodyScore: 75 + Math.floor(Math.random() * 15),
        totalBodyWater: parseFloat((42.5 + Math.random() * 5).toFixed(3)),
        intracellularWater: parseFloat((26.5 + Math.random() * 3).toFixed(3)),
        extracellularWater: parseFloat((16.0 + Math.random() * 2).toFixed(3)),
        dryLeanMass: parseFloat((12.8 + Math.random() * 2).toFixed(3)),
        bodyFatMass: parseFloat((14.2 + Math.random() * 3).toFixed(3)),
        skeletalMuscleMass: parseFloat((32.5 + Math.random() * 5).toFixed(3)),
        ecwTbwRatio: parseFloat((0.375 + Math.random() * 0.01).toFixed(3)),
        basalMetabolicRate: 1650 + Math.floor(Math.random() * 200),
        visceralFatLevel: 8 + Math.floor(Math.random() * 4),
        segmentalLean: {
          leftArm: 95 + Math.floor(Math.random() * 10),
          rightArm: 97 + Math.floor(Math.random() * 10),
          trunk: 98 + Math.floor(Math.random() * 10),
          leftLeg: 102 + Math.floor(Math.random() * 10),
          rightLeg: 103 + Math.floor(Math.random() * 10),
        },
        scanDate: new Date(),
      };

      setFormData(prev => ({ ...prev, ...extractedData }));
      setIsAnalyzing(false);
      setExtractionComplete(true);
      toast.success(t('inbody.extractionComplete'));
    }, 3000);
  };

  const handleRetakePhoto = () => {
    setUploadedImage(null);
    setExtractionComplete(false);
    setIsAnalyzing(false);
  };

  const handleUseExtractedData = () => {
    setInputMode('manual');
    setCurrentStep(1);
  };

  // Mode Selection Screen
  if (inputMode === 'selection') {
    return (
      <div className="min-h-screen bg-background">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4">
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
              <h1 className="text-xl">{t('inbody.title')}</h1>
              <p className="text-sm text-white/90">{t('inbody.subtitle')}</p>
            </div>
            <Activity className="w-6 h-6" />
          </div>
        </div>

        {/* Mode Selection */}
        <div className="p-4 lg:p-6">
          <div className="max-w-2xl mx-auto space-y-4">
            <div className="text-center mb-8">
              <h2 className="text-2xl font-semibold mb-2">Choose Input Method</h2>
              <p className="text-muted-foreground">Select how you want to add your InBody data</p>
            </div>

            {/* AI Scan Option */}
            <Card 
              className={`relative overflow-hidden transition-all hover:shadow-lg ${
                isPremium ? 'cursor-pointer hover:border-purple-500' : 'opacity-75'
              }`}
              onClick={() => {
                if (isPremium) {
                  setInputMode('ai-scan');
                }
              }}
            >
              {!isPremium && (
                <div className="absolute top-3 right-3">
                  <Badge className="bg-gradient-to-r from-orange-500 to-pink-500 text-white border-0">
                    <Crown className="w-3 h-3 mr-1" />
                    {t('inbody.premiumFeature')}
                  </Badge>
                </div>
              )}
              
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <div className={`w-12 h-12 rounded-lg flex items-center justify-center ${
                    isPremium ? 'bg-gradient-to-br from-purple-500 to-blue-500' : 'bg-muted'
                  }`}>
                    <Sparkles className={`w-6 h-6 ${isPremium ? 'text-white' : 'text-muted-foreground'}`} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-semibold">{t('inbody.aiScan')}</h3>
                      {!isPremium && <Lock className="w-4 h-4 text-muted-foreground" />}
                    </div>
                    <p className="text-sm text-muted-foreground mb-3">
                      {t('inbody.aiExtractionDesc')}
                    </p>
                    {isPremium ? (
                      <div className="flex items-center gap-2 text-sm text-purple-600">
                        <CheckCircle2 className="w-4 h-4" />
                        <span>Instant data extraction</span>
                      </div>
                    ) : (
                      <Button 
                        variant="outline" 
                        size="sm"
                        className="mt-2"
                        onClick={(e) => {
                          e.stopPropagation();
                          onUpgrade?.();
                        }}
                      >
                        {t('inbody.upgradeForAI')}
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Manual Entry Option */}
            <Card 
              className="cursor-pointer hover:shadow-lg hover:border-blue-500 transition-all"
              onClick={() => setInputMode('manual')}
            >
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <Scale className="w-6 h-6 text-blue-600" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold mb-1">{t('inbody.manualEntry')}</h3>
                    <p className="text-sm text-muted-foreground">
                      Enter your InBody scan data manually step by step
                    </p>
                    <div className="flex items-center gap-2 mt-3 text-sm text-muted-foreground">
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Available for all users</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Premium Locked Notice */}
            {!isPremium && (
              <Alert className="bg-gradient-to-r from-orange-50 to-pink-50 border-orange-200">
                <Info className="w-4 h-4 text-orange-600" />
                <AlertDescription className="text-sm">
                  {t('inbody.aiScanLockedDesc')}
                </AlertDescription>
              </Alert>
            )}
          </div>
        </div>
      </div>
    );
  }

  // AI Scan Mode
  if (inputMode === 'ai-scan' && isPremium) {
    return (
      <div className="min-h-screen bg-background">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-4">
          <div className="flex items-center gap-3">
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => setInputMode('selection')}
              className="text-white hover:bg-white/20"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div className="flex-1">
              <h1 className="text-xl">{t('inbody.aiExtraction')}</h1>
              <p className="text-sm text-white/90">{t('inbody.uploadOrTake')}</p>
            </div>
            <Sparkles className="w-6 h-6" />
          </div>
        </div>

        <div className="p-4 lg:p-6">
          <div className="max-w-3xl mx-auto">
            {!uploadedImage ? (
              /* Upload/Camera Options */
              <div className="space-y-4">
                <Card>
                  <CardContent className="p-8">
                    <div className="text-center space-y-6">
                      <div className="w-20 h-20 mx-auto bg-gradient-to-br from-purple-500 to-blue-500 rounded-full flex items-center justify-center">
                        <Sparkles className="w-10 h-10 text-white" />
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold mb-2">{t('inbody.aiExtraction')}</h3>
                        <p className="text-muted-foreground">
                          {t('inbody.uploadOrTake')}
                        </p>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4">
                        <Button
                          size="lg"
                          variant="outline"
                          className="h-32 flex-col gap-3 hover:border-purple-500 hover:bg-purple-50"
                          onClick={() => fileInputRef.current?.click()}
                        >
                          <Upload className="w-8 h-8 text-purple-600" />
                          <span>{t('inbody.uploadPhoto')}</span>
                        </Button>

                        <Button
                          size="lg"
                          variant="outline"
                          className="h-32 flex-col gap-3 hover:border-blue-500 hover:bg-blue-50"
                          onClick={handleCameraCapture}
                        >
                          <Camera className="w-8 h-8 text-blue-600" />
                          <span>{t('inbody.takePhoto')}</span>
                        </Button>
                      </div>

                      <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/*"
                        capture="environment"
                        className="hidden"
                        onChange={handleFileSelect}
                      />
                    </div>
                  </CardContent>
                </Card>

                <div className="text-center">
                  <Button 
                    variant="ghost" 
                    onClick={() => setInputMode('manual')}
                    className="text-muted-foreground"
                  >
                    {t('inbody.orManualEntry')} →
                  </Button>
                </div>
              </div>
            ) : (
              /* Image Preview & Analysis */
              <div className="space-y-4">
                <Card>
                  <CardContent className="p-6">
                    {/* Image Preview */}
                    <div className="relative mb-4 rounded-lg overflow-hidden bg-muted">
                      <img 
                        src={uploadedImage} 
                        alt="InBody scan" 
                        className="w-full h-auto max-h-96 object-contain"
                      />
                      {!isAnalyzing && !extractionComplete && (
                        <Button
                          size="icon"
                          variant="secondary"
                          className="absolute top-2 right-2"
                          onClick={handleRetakePhoto}
                        >
                          <X className="w-4 h-4" />
                        </Button>
                      )}
                    </div>

                    {/* Analysis Status */}
                    {isAnalyzing && (
                      <div className="text-center py-8">
                        <Loader2 className="w-12 h-12 mx-auto mb-4 text-purple-600 animate-spin" />
                        <h3 className="font-semibold mb-2">{t('inbody.analyzing')}</h3>
                        <p className="text-sm text-muted-foreground">
                          Our AI is extracting data from your InBody scan...
                        </p>
                        <Progress value={66} className="w-full max-w-xs mx-auto mt-4" />
                      </div>
                    )}

                    {/* Extraction Complete */}
                    {extractionComplete && !isAnalyzing && (
                      <div className="space-y-4">
                        <div className="text-center py-4">
                          <div className="w-16 h-16 mx-auto mb-4 bg-green-100 rounded-full flex items-center justify-center">
                            <CheckCircle className="w-8 h-8 text-green-600" />
                          </div>
                          <h3 className="font-semibold text-green-600 mb-2">
                            {t('inbody.extractionComplete')}
                          </h3>
                          <p className="text-sm text-muted-foreground">
                            {t('inbody.reviewData')}
                          </p>
                        </div>

                        {/* Quick Preview of Extracted Data */}
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 p-4 bg-muted rounded-lg">
                          <div className="text-center">
                            <p className="text-2xl font-bold text-purple-600">
                              {formData.weight?.toFixed(3)}
                            </p>
                            <p className="text-xs text-muted-foreground">Weight (kg)</p>
                          </div>
                          <div className="text-center">
                            <p className="text-2xl font-bold text-blue-600">
                              {formData.bmi?.toFixed(3)}
                            </p>
                            <p className="text-xs text-muted-foreground">BMI</p>
                          </div>
                          <div className="text-center">
                            <p className="text-2xl font-bold text-green-600">
                              {formData.percentBodyFat?.toFixed(3)}%
                            </p>
                            <p className="text-xs text-muted-foreground">Body Fat</p>
                          </div>
                          <div className="text-center">
                            <p className="text-2xl font-bold text-orange-600">
                              {formData.inBodyScore}
                            </p>
                            <p className="text-xs text-muted-foreground">InBody Score</p>
                          </div>
                        </div>

                        {/* Action Buttons */}
                        <div className="flex gap-3">
                          <Button
                            variant="outline"
                            className="flex-1"
                            onClick={handleRetakePhoto}
                          >
                            {t('inbody.retakePhoto')}
                          </Button>
                          <Button
                            className="flex-1 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"
                            onClick={handleUseExtractedData}
                          >
                            {t('inbody.useThisData')} →
                          </Button>
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  // Manual Entry Mode (existing form)
  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return (
          <div className="space-y-6">
            <div className="text-center mb-6">
              <Scale className="w-12 h-12 mx-auto mb-3 text-primary" />
              <h2 className="text-xl font-semibold mb-2">{t('inbody.basicMetrics')}</h2>
              <p className="text-sm text-muted-foreground">{t('inbody.basicMetricsDesc')}</p>
            </div>

            <div className="space-y-4">
              <div>
                <Label htmlFor="weight">{t('inbody.weight')} (kg) *</Label>
                <Input
                  id="weight"
                  type="number"
                  step="0.001"
                  value={formData.weight || ''}
                  onChange={(e) => updateField('weight', parseFloat(e.target.value))}
                  placeholder="70.500"
                />
              </div>

              <div>
                <Label htmlFor="bmi">{t('inbody.bmi')} *</Label>
                <Input
                  id="bmi"
                  type="number"
                  step="0.001"
                  value={formData.bmi || ''}
                  onChange={(e) => updateField('bmi', parseFloat(e.target.value))}
                  placeholder="22.500"
                />
                {formData.bmi && formData.bmi > 0 && (
                  <p className="text-xs text-muted-foreground mt-1">
                    {t('inbody.category')}: {getBMICategory(formData.bmi)}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="percentBodyFat">{t('inbody.percentBodyFat')} (%) *</Label>
                <Input
                  id="percentBodyFat"
                  type="number"
                  step="0.001"
                  value={formData.percentBodyFat || ''}
                  onChange={(e) => updateField('percentBodyFat', parseFloat(e.target.value))}
                  placeholder="18.500"
                />
                {formData.percentBodyFat && formData.percentBodyFat > 0 && (
                  <p className="text-xs text-muted-foreground mt-1">
                    {t('inbody.category')}: {getBodyFatCategory(formData.percentBodyFat, userGender)}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="inBodyScore">{t('inbody.inBodyScore')} (0-100) *</Label>
                <Input
                  id="inBodyScore"
                  type="number"
                  step="1"
                  value={formData.inBodyScore || ''}
                  onChange={(e) => updateField('inBodyScore', parseFloat(e.target.value))}
                  placeholder="75"
                />
                {formData.inBodyScore && formData.inBodyScore > 0 && (
                  <div className="mt-2">
                    <Progress value={formData.inBodyScore} />
                    <p className="text-xs text-muted-foreground mt-1">
                      {t('inbody.category')}: {getInBodyScoreCategory(formData.inBodyScore)}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div className="text-center mb-6">
              <Droplets className="w-12 h-12 mx-auto mb-3 text-blue-500" />
              <h2 className="text-xl font-semibold mb-2">{t('inbody.bodyComposition')}</h2>
              <p className="text-sm text-muted-foreground">{t('inbody.bodyCompositionDesc')}</p>
            </div>

            <div className="space-y-4">
              <div>
                <Label htmlFor="totalBodyWater">{t('inbody.totalBodyWater')} (kg)</Label>
                <Input
                  id="totalBodyWater"
                  type="number"
                  step="0.001"
                  value={formData.totalBodyWater || ''}
                  onChange={(e) => updateField('totalBodyWater', parseFloat(e.target.value))}
                  placeholder="42.500"
                />
              </div>

              <div>
                <Label htmlFor="intracellularWater">{t('inbody.intracellularWater')} (kg)</Label>
                <Input
                  id="intracellularWater"
                  type="number"
                  step="0.001"
                  value={formData.intracellularWater || ''}
                  onChange={(e) => updateField('intracellularWater', parseFloat(e.target.value))}
                  placeholder="26.500"
                />
              </div>

              <div>
                <Label htmlFor="extracellularWater">{t('inbody.extracellularWater')} (kg)</Label>
                <Input
                  id="extracellularWater"
                  type="number"
                  step="0.001"
                  value={formData.extracellularWater || ''}
                  onChange={(e) => updateField('extracellularWater', parseFloat(e.target.value))}
                  placeholder="16.000"
                />
              </div>

              <div>
                <Label htmlFor="dryLeanMass">
                  {t('inbody.dryLeanMass')} (kg)
                </Label>
                <Input
                  id="dryLeanMass"
                  type="number"
                  step="0.001"
                  value={formData.dryLeanMass || ''}
                  onChange={(e) => updateField('dryLeanMass', parseFloat(e.target.value))}
                  placeholder="12.800"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {t('inbody.dryLeanMassDesc')}
                </p>
              </div>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div className="text-center mb-6">
              <Activity className="w-12 h-12 mx-auto mb-3 text-green-500" />
              <h2 className="text-xl font-semibold mb-2">{t('inbody.muscleFatAnalysis')}</h2>
              <p className="text-sm text-muted-foreground">{t('inbody.muscleFatAnalysisDesc')}</p>
            </div>

            <div className="space-y-4">
              <div>
                <Label htmlFor="bodyFatMass">{t('inbody.bodyFatMass')} (kg)</Label>
                <Input
                  id="bodyFatMass"
                  type="number"
                  step="0.001"
                  value={formData.bodyFatMass || ''}
                  onChange={(e) => updateField('bodyFatMass', parseFloat(e.target.value))}
                  placeholder="14.200"
                />
              </div>

              <div>
                <Label htmlFor="skeletalMuscleMass">
                  {t('inbody.skeletalMuscleMass')} (kg)
                </Label>
                <Input
                  id="skeletalMuscleMass"
                  type="number"
                  step="0.001"
                  value={formData.skeletalMuscleMass || ''}
                  onChange={(e) => updateField('skeletalMuscleMass', parseFloat(e.target.value))}
                  placeholder="32.500"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {t('inbody.smmDesc')}
                </p>
              </div>

              <div>
                <Label htmlFor="ecwTbwRatio">
                  {t('inbody.ecwTbwRatio')}
                </Label>
                <Input
                  id="ecwTbwRatio"
                  type="number"
                  step="0.001"
                  value={formData.ecwTbwRatio || ''}
                  onChange={(e) => updateField('ecwTbwRatio', parseFloat(e.target.value))}
                  placeholder="0.375"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {t('inbody.ecwTbwRatioDesc')}
                </p>
              </div>
            </div>
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div className="text-center mb-6">
              <TrendingUp className="w-12 h-12 mx-auto mb-3 text-orange-500" />
              <h2 className="text-xl font-semibold mb-2">{t('inbody.segmentalAnalysis')}</h2>
              <p className="text-sm text-muted-foreground">{t('inbody.segmentalAnalysisDesc')}</p>
            </div>

            <Alert>
              <Info className="w-4 h-4" />
              <AlertDescription className="text-sm">
                {t('inbody.segmentalNote')}
              </AlertDescription>
            </Alert>

            <div className="space-y-4">
              <div>
                <Label htmlFor="leftArm">{t('inbody.leftArm')} (%)</Label>
                <Input
                  id="leftArm"
                  type="number"
                  step="1"
                  value={formData.segmentalLean?.leftArm || ''}
                  onChange={(e) => updateSegmentalField('leftArm', parseFloat(e.target.value))}
                  placeholder="100"
                />
              </div>

              <div>
                <Label htmlFor="rightArm">{t('inbody.rightArm')} (%)</Label>
                <Input
                  id="rightArm"
                  type="number"
                  step="1"
                  value={formData.segmentalLean?.rightArm || ''}
                  onChange={(e) => updateSegmentalField('rightArm', parseFloat(e.target.value))}
                  placeholder="100"
                />
              </div>

              <div>
                <Label htmlFor="trunk">{t('inbody.trunk')} (%)</Label>
                <Input
                  id="trunk"
                  type="number"
                  step="1"
                  value={formData.segmentalLean?.trunk || ''}
                  onChange={(e) => updateSegmentalField('trunk', parseFloat(e.target.value))}
                  placeholder="100"
                />
              </div>

              <div>
                <Label htmlFor="leftLeg">{t('inbody.leftLeg')} (%)</Label>
                <Input
                  id="leftLeg"
                  type="number"
                  step="1"
                  value={formData.segmentalLean?.leftLeg || ''}
                  onChange={(e) => updateSegmentalField('leftLeg', parseFloat(e.target.value))}
                  placeholder="100"
                />
              </div>

              <div>
                <Label htmlFor="rightLeg">{t('inbody.rightLeg')} (%)</Label>
                <Input
                  id="rightLeg"
                  type="number"
                  step="1"
                  value={formData.segmentalLean?.rightLeg || ''}
                  onChange={(e) => updateSegmentalField('rightLeg', parseFloat(e.target.value))}
                  placeholder="100"
                />
              </div>
            </div>
          </div>
        );

      case 5:
        return (
          <div className="space-y-6">
            <div className="text-center mb-6">
              <Calendar className="w-12 h-12 mx-auto mb-3 text-purple-500" />
              <h2 className="text-xl font-semibold mb-2">{t('inbody.additionalMetrics')}</h2>
              <p className="text-sm text-muted-foreground">{t('inbody.additionalMetricsDesc')}</p>
            </div>

            <div className="space-y-4">
              <div>
                <Label htmlFor="bmr">{t('inbody.bmr')} (kcal/day)</Label>
                <Input
                  id="bmr"
                  type="number"
                  step="1"
                  value={formData.basalMetabolicRate || ''}
                  onChange={(e) => updateField('basalMetabolicRate', parseFloat(e.target.value))}
                  placeholder="1650"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {t('inbody.bmrDesc')}
                </p>
              </div>

              <div>
                <Label htmlFor="vfl">{t('inbody.vfl')} (1-20)</Label>
                <Input
                  id="vfl"
                  type="number"
                  step="1"
                  value={formData.visceralFatLevel || ''}
                  onChange={(e) => updateField('visceralFatLevel', parseFloat(e.target.value))}
                  placeholder="10"
                />
                {formData.visceralFatLevel && formData.visceralFatLevel > 0 && (
                  <p className="text-xs text-muted-foreground mt-1">
                    {t('inbody.category')}: {getVisceralFatCategory(formData.visceralFatLevel)}
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="scanDate">{t('inbody.scanDate')}</Label>
                <Input
                  id="scanDate"
                  type="date"
                  value={formData.scanDate ? new Date(formData.scanDate).toISOString().split('T')[0] : ''}
                  onChange={(e) => updateField('scanDate', new Date(e.target.value))}
                />
              </div>

              <div>
                <Label htmlFor="scanLocation">{t('inbody.scanLocation')}</Label>
                <Input
                  id="scanLocation"
                  type="text"
                  value={formData.scanLocation || ''}
                  onChange={(e) => updateField('scanLocation', e.target.value)}
                  placeholder={t('inbody.scanLocationPlaceholder')}
                />
              </div>

              <div>
                <Label htmlFor="notes">{t('inbody.notes')}</Label>
                <Textarea
                  id="notes"
                  value={formData.notes || ''}
                  onChange={(e) => updateField('notes', e.target.value)}
                  placeholder={t('inbody.notesPlaceholder')}
                  rows={3}
                />
              </div>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={() => {
              if (currentStep === 1) {
                setInputMode('selection');
              } else {
                handlePrevious();
              }
            }}
            className="text-white hover:bg-white/20"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('inbody.title')}</h1>
            <p className="text-sm text-white/90">
              {t('common.of').replace('{current}', currentStep.toString()).replace('{total}', totalSteps.toString()) || `Step ${currentStep} of ${totalSteps}`}
            </p>
          </div>
          <Activity className="w-6 h-6" />
        </div>
      </div>

      {/* Progress Bar */}
      <div className="p-4 pb-0">
        <Progress value={(currentStep / totalSteps) * 100} className="h-2" />
      </div>

      {/* Form Content */}
      <div className="p-4 lg:p-6">
        <div className="max-w-2xl mx-auto">
          <Card>
            <CardContent className="p-6">
              {renderStep()}
            </CardContent>
          </Card>

          {/* Navigation Buttons */}
          <div className="flex gap-3 mt-6">
            {currentStep > 1 && (
              <Button
                variant="outline"
                onClick={handlePrevious}
                className="flex-1"
              >
                {t('common.back')}
              </Button>
            )}
            {currentStep < totalSteps ? (
              <Button
                onClick={handleNext}
                className="flex-1"
              >
                {t('common.next')}
              </Button>
            ) : (
              <Button
                onClick={handleSave}
                className="flex-1 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700"
              >
                {t('inbody.save')}
              </Button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
