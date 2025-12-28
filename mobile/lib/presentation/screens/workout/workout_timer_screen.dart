import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_button.dart';
import 'dart:async';

class WorkoutTimerScreen extends StatefulWidget {
  final String exerciseName;
  final int sets;
  final int reps;
  final int restSeconds;
  
  const WorkoutTimerScreen({
    super.key,
    required this.exerciseName,
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = 60,
  });

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  int _currentSet = 1;
  int _remainingSeconds = 0;
  bool _isResting = false;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmExit(context, isArabic),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: _currentSet / widget.sets,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Set counter
                  Text(
                    isArabic
                        ? 'المجموعة $_currentSet من ${widget.sets}'
                        : 'Set $_currentSet of ${widget.sets}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Timer circle
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isResting
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      border: Border.all(
                        color: _isResting ? AppColors.warning : AppColors.success,
                        width: 8,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isResting) ...[
                            const Icon(
                              Icons.timer,
                              size: 60,
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic ? 'استراحة' : 'Rest',
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${widget.reps}',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic ? 'تكرارات' : 'Reps',
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Status message
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isResting
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusMessage(isArabic),
                      style: TextStyle(
                        fontSize: 16,
                        color: _isResting ? AppColors.warning : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Control buttons
                  if (_isResting) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pause/Resume
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            text: _isPaused
                                ? (isArabic ? 'استئناف' : 'Resume')
                                : (isArabic ? 'إيقاف' : 'Pause'),
                            onPressed: _togglePause,
                            variant: ButtonVariant.secondary,
                            size: ButtonSize.large,
                            icon: _isPaused ? Icons.play_arrow : Icons.pause,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Skip rest
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            text: isArabic ? 'تخطي' : 'Skip',
                            onPressed: _skipRest,
                            variant: ButtonVariant.secondary,
                            size: ButtonSize.large,
                            icon: Icons.skip_next,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: isArabic ? 'اكتملت المجموعة' : 'Set Complete',
                        onPressed: _completeSet,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        icon: Icons.check,
                        fullWidth: true,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Secondary actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _adjustRest(context, isArabic),
                        icon: const Icon(Icons.settings),
                        label: Text(
                          isArabic ? 'تعديل الراحة' : 'Adjust Rest',
                        ),
                      ),
                      const SizedBox(width: 24),
                      TextButton.icon(
                        onPressed: () => _skipExercise(context, isArabic),
                        icon: const Icon(Icons.skip_next),
                        label: Text(
                          isArabic ? 'تخطي التمرين' : 'Skip Exercise',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  String _getStatusMessage(bool isArabic) {
    if (_isResting) {
      if (_isPaused) {
        return isArabic ? 'الراحة متوقفة' : 'Rest Paused';
      }
      return isArabic
          ? 'خذ قسطاً من الراحة، أنت تقوم بعمل رائع!'
          : 'Take a rest, you\'re doing great!';
    } else {
      return isArabic
          ? 'أكمل ${widget.reps} تكرار ثم اضغط على اكتمال'
          : 'Complete ${widget.reps} reps then tap complete';
    }
  }
  
  void _completeSet() {
    if (_currentSet < widget.sets) {
      // Start rest timer
      setState(() {
        _isResting = true;
        _remainingSeconds = widget.restSeconds;
        _isPaused = false;
      });
      _startRestTimer();
    } else {
      // Workout complete
      _showWorkoutComplete();
    }
  }
  
  void _startRestTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isResting = false;
            _currentSet++;
          }
        });
      }
    });
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }
  
  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _currentSet++;
      _isPaused = false;
    });
  }
  
  void _adjustRest(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تعديل وقت الراحة' : 'Adjust Rest Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [30, 45, 60, 90, 120].map((seconds) {
            return ListTile(
              title: Text(
                isArabic
                    ? '$seconds ثانية'
                    : '$seconds seconds',
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Update rest time
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _skipExercise(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تخطي التمرين؟' : 'Skip Exercise?'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد أنك تريد تخطي هذا التمرين؟'
              : 'Are you sure you want to skip this exercise?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to workout screen
            },
            child: Text(isArabic ? 'تخطي' : 'Skip'),
          ),
        ],
      ),
    );
  }
  
  void _confirmExit(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إنهاء التمرين؟' : 'End Workout?'),
        content: Text(
          isArabic
              ? 'سيتم فقدان تقدمك. هل أنت متأكد؟'
              : 'Your progress will be lost. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'إنهاء' : 'End'),
          ),
        ],
      ),
    );
  }
  
  void _showWorkoutComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isArabic = context.read<LanguageProvider>().isArabic;
        return AlertDialog(
          title: Column(
            children: [
              const Icon(
                Icons.celebration,
                size: 60,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'أحسنت!' : 'Great Job!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'لقد أكملت جميع المجموعات!'
                : 'You\'ve completed all sets!',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text(isArabic ? 'تم' : 'Done'),
            ),
          ],
        );
      },
    );
  }
}
