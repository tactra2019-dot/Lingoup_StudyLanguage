import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../learning_path/data/learning_repository.dart';
import '../../auth/data/auth_repository.dart';
import 'widgets/feedback_bottom_sheet.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _attemptId;
  int _currentQuestionIndex = 0;
  int? _selectedOptionId;
  bool _isSubmitting = false;
  AnswerResult? _lastAnswerResult;
  bool _showFeedback = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _initQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initQuiz() async {
    try {
      final repo = ref.read(learningRepositoryProvider);
      final attempt = await repo.createQuizAttempt(widget.lessonId);
      if (mounted) {
        setState(() {
          _attemptId = attempt.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize quiz: $e')),
        );
      }
    }
  }

  void _submitAnswer(Question question) async {
    if (_selectedOptionId == null || _attemptId == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(learningRepositoryProvider);
      final result = await repo.submitAnswer(
        attemptId: _attemptId!,
        questionId: question.id,
        selectedOptionId: _selectedOptionId,
      );

      if (mounted) {
        setState(() {
          _lastAnswerResult = result;
          _showFeedback = true;
          _isSubmitting = false;
        });

        if (result.isCorrect) {
          _confettiController.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting answer: $e')),
        );
      }
    }
  }

  void _onNext(List<Question> questions) async {
    setState(() {
      _showFeedback = false;
      _lastAnswerResult = null;
      _selectedOptionId = null;
    });

    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Completed all questions in the quiz!
      if (_attemptId == null) return;
      try {
        final repo = ref.read(learningRepositoryProvider);
        final quizResult = await repo.completeQuiz(_attemptId!);
        
        // Invalidate ALL learning state so UI reflects backend truth
        ref.invalidate(authStateProvider);
        ref.invalidate(streakProvider);
        ref.invalidate(progressOverviewProvider);
        ref.invalidate(unitsProvider);       // Refresh learning path + unit unlock
        ref.invalidate(unitLessonsProvider); // Refresh lesson statuses in all units

        if (mounted) {
          context.pushReplacement('/quiz-result', extra: {
            'result': quizResult,
            'lessonTitle': 'Lesson Complete',
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete quiz: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(lessonQuestionsProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: questionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMint),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lessonQuestionsProvider(widget.lessonId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (questions) {
                if (questions.isEmpty) {
                  return const Center(child: Text('No questions for this lesson.'));
                }

                final currentQuestion = questions[_currentQuestionIndex];
                final progress = (_currentQuestionIndex + 1) / questions.length;

                return Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              color: AppColors.textPrimary,
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Practice Question',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 44), // balance back button
                        ],
                      ),
                    ),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFDCE5EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryMint),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Question Card
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryMint,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentQuestion.prompt,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text('😋💬', style: TextStyle(fontSize: 28)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Option Cards
                            ...currentQuestion.options.map((option) {
                              final isSelected = _selectedOptionId == option.id;
                              final hasResult = _lastAnswerResult != null;
                              final isCorrectOption = hasResult &&
                                  _lastAnswerResult!.correctOptionId == option.id;
                              final isWrongSelection = hasResult &&
                                  isSelected &&
                                  !_lastAnswerResult!.isCorrect;

                              Color bgColor = Colors.white;
                              Color borderColor = const Color(0xFFE2EBF0);
                              Color textColor = AppColors.textPrimary;
                              Widget? trailingIcon;

                              if (hasResult) {
                                if (isCorrectOption) {
                                  bgColor = const Color(0xFF2ED887);
                                  borderColor = const Color(0xFF2ED887);
                                  textColor = Colors.white;
                                  trailingIcon = const Text('👋', style: TextStyle(fontSize: 20));
                                } else if (isWrongSelection) {
                                  bgColor = const Color(0xFFFFEBEB);
                                  borderColor = AppColors.errorRed;
                                  textColor = AppColors.errorRed;
                                  trailingIcon = const Icon(Icons.close, color: AppColors.errorRed);
                                }
                              } else if (isSelected) {
                                bgColor = const Color(0xFFE8FAF5);
                                borderColor = AppColors.primaryMint;
                                textColor = AppColors.primaryDark;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: hasResult
                                      ? null
                                      : () {
                                          setState(() => _selectedOptionId = option.id);
                                        },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: borderColor,
                                        width: (isSelected || isCorrectOption) ? 2.0 : 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Radio circle
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: (isSelected || isCorrectOption)
                                                  ? Colors.transparent
                                                  : const Color(0xFFBCC6CE),
                                              width: 2,
                                            ),
                                            color: isCorrectOption
                                                ? Colors.white
                                                : isSelected
                                                    ? AppColors.primaryMint
                                                    : Colors.transparent,
                                          ),
                                          child: isCorrectOption
                                              ? const Icon(Icons.check, size: 14, color: Color(0xFF2ED887))
                                              : isSelected
                                                  ? const Center(
                                                      child: CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            option.text,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        if (trailingIcon != null) trailingIcon,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Submit Button (if feedback not open)
                    if (!_showFeedback)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (_selectedOptionId == null || _isSubmitting)
                                ? null
                                : () => _submitAnswer(currentQuestion),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMint,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Check Answer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryMint,
                AppColors.accentBlue,
                Color(0xFFFFB946),
                Color(0xFF2ED887),
              ],
            ),
          ),

          // Feedback Bottom Sheet (Matches Reference Screen 3)
          if (_showFeedback && _lastAnswerResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FeedbackBottomSheet(
                isCorrect: _lastAnswerResult!.isCorrect,
                explanation: _lastAnswerResult!.explanation,
                onNext: () {
                  final questions = questionsAsync.valueOrNull ?? [];
                  _onNext(questions);
                },
                onClose: () {
                  setState(() => _showFeedback = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}
