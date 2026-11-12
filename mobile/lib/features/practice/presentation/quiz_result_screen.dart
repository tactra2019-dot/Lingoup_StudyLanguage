import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../learning_path/data/learning_repository.dart';
import '../../auth/data/auth_repository.dart';

class QuizResultScreen extends ConsumerWidget {
  final QuizResult result;
  final String lessonTitle;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracyPercent = (result.accuracy * 100).round();
    final isGreat = accuracyPercent >= 70;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Badge
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: isGreat ? AppColors.greenGradient : AppColors.blueGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isGreat ? AppColors.successGreen : AppColors.accentBlue).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    result.isPerfect ? '👑' : isGreat ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 54),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                result.isPerfect
                    ? 'Perfect Score!'
                    : isGreat
                        ? 'Great Job!'
                        : 'Practice Makes Perfect!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.isPerfect
                    ? 'You answered every question correctly!'
                    : 'You got ${result.correctAnswers} out of ${result.totalQuestions} questions right.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Stat Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '💎',
                      value: '+${result.xpEarned} XP',
                      label: 'Total XP',
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '🎯',
                      value: '$accuracyPercent%',
                      label: 'Accuracy',
                      color: isGreat ? AppColors.successGreen : AppColors.errorRed,
                    ),
                  ),
                  if (result.streakUpdated) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _StatCard(
                        emoji: '🔥',
                        value: '+1 Day',
                        label: 'Streak!',
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ],
              ),

              if (result.isPerfect) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD56B)),
                  ),
                  child: const Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Perfect Quiz Bonus: +10 Extra XP awarded!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF996B00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Invalidate all learning state so path shows fresh data
                    ref.invalidate(unitsProvider);
                    ref.invalidate(unitLessonsProvider);
                    ref.invalidate(authStateProvider);
                    ref.invalidate(streakProvider);
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue to Path',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
