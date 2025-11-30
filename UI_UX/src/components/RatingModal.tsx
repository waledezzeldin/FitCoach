import React, { useState } from 'react';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Button } from './ui/button';
import { Textarea } from './ui/textarea';
import { Star } from 'lucide-react';
import { useLanguage } from './LanguageContext';

export interface Rating {
  stars: 1 | 2 | 3 | 4 | 5;
  comment?: string;
  timestamp: Date;
  interactionType: 'chat' | 'call';
}

interface RatingModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  interactionType: 'chat' | 'call';
  coachName: string;
  onSubmit: (rating: Rating) => void;
  onSkip: () => void;
}

export function RatingModal({
  open,
  onOpenChange,
  interactionType,
  coachName,
  onSubmit,
  onSkip
}: RatingModalProps) {
  const { t, isRTL } = useLanguage();
  const [stars, setStars] = useState<number>(0);
  const [hoveredStar, setHoveredStar] = useState<number>(0);
  const [comment, setComment] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async () => {
    if (stars === 0) return;

    setIsSubmitting(true);

    const rating: Rating = {
      stars: stars as 1 | 2 | 3 | 4 | 5,
      comment: comment.trim() || undefined,
      timestamp: new Date(),
      interactionType
    };

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));

    onSubmit(rating);
    setIsSubmitting(false);
    
    // Reset state
    setStars(0);
    setComment('');
  };

  const handleSkip = () => {
    onSkip();
    setStars(0);
    setComment('');
  };

  const interactionLabel = interactionType === 'chat' 
    ? t('rating.chatSession') 
    : t('rating.videoCall');

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{t('rating.title')}</DialogTitle>
          <DialogDescription>
            {t('rating.howWas')} {interactionLabel} {t('common.with')} {coachName}?
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Star Rating */}
          <div className="flex justify-center gap-2">
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                type="button"
                onClick={() => setStars(star)}
                onMouseEnter={() => setHoveredStar(star)}
                onMouseLeave={() => setHoveredStar(0)}
                className="transition-transform hover:scale-110 focus:outline-none"
              >
                <Star
                  className={`w-10 h-10 ${
                    star <= (hoveredStar || stars)
                      ? 'fill-yellow-400 text-yellow-400'
                      : 'fill-gray-200 text-gray-200'
                  }`}
                />
              </button>
            ))}
          </div>

          {/* Star Label */}
          {stars > 0 && (
            <div className="text-center text-sm text-muted-foreground">
              {stars === 5 && t('rating.excellent')}
              {stars === 4 && t('rating.good')}
              {stars === 3 && t('rating.average')}
              {stars === 2 && t('rating.fair')}
              {stars === 1 && t('rating.poor')}
            </div>
          )}

          {/* Comment */}
          <div className="space-y-2">
            <label className="text-sm">{t('rating.optional')}</label>
            <Textarea
              placeholder={t('rating.commentPlaceholder')}
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              rows={3}
              maxLength={500}
              dir={isRTL ? 'rtl' : 'ltr'}
            />
            <div className="text-xs text-muted-foreground text-right">
              {comment.length}/500
            </div>
          </div>
        </div>

        <DialogFooter className={`flex gap-2 ${isRTL ? 'flex-row-reverse' : ''}`}>
          <Button
            variant="outline"
            onClick={handleSkip}
            disabled={isSubmitting}
          >
            {t('rating.skip')}
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={stars === 0 || isSubmitting}
          >
            {isSubmitting ? t('common.loading') : t('rating.submit')}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
