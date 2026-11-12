import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_repository.dart';
import '../../learning_path/data/learning_repository.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;
    final unitsAsync = ref.watch(unitsProvider(user?.selectedLanguageId));
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practice & Quizzes'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // Daily Challenge Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.mintGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMint.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'DAILY GOAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Keep Your Streak!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        streakAsync.when(
                          data: (StreakData s) => Text(
                            'Current streak: ${s.currentStreak} days 🔥',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Unit Practice Quizzes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            unitsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.primaryMint),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (List<Unit> units) {
                if (units.isEmpty) {
                  return const Text('No units available.');
                }

                return Column(
                  children: units.map((Unit unit) {
                    final isLocked = unit.status == UnitStatus.locked;
                    final isCompleted = unit.status == UnitStatus.completed;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLocked ? AppColors.surfaceLight : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.primaryMint
                                : isLocked
                                    ? const Color(0xFFE2EBF0)
                                    : AppColors.accentBlue,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFFE8FAF5)
                                    : isLocked
                                        ? const Color(0xFFE8EFF4)
                                        : const Color(0xFFE8F6FC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  unit.emoji ?? '📝',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: isLocked ? Colors.grey : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit ${unit.orderIndex + 1}: ${unit.title}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isLocked ? AppColors.textHint : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isCompleted
                                        ? 'Mastered • 100% complete'
                                        : isLocked
                                            ? 'Complete previous units to unlock'
                                            : '${unit.completedLessons}/${unit.totalLessons} lessons done',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isLocked
                                  ? null
                                  : () {
                                      // Start quiz for first lesson of unit
                                      _startFirstLessonQuiz(context, ref, unit.id);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted ? AppColors.primaryMint : AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isCompleted ? 'Review' : 'Practice',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startFirstLessonQuiz(BuildContext context, WidgetRef ref, int unitId) async {
    try {
      final repo = ref.read(learningRepositoryProvider);
      final lessons = await repo.getUnitLessons(unitId);
      if (lessons.isNotEmpty && context.mounted) {
        // Pick first available/in-progress lesson, or fallback to first lesson for review
        final target = lessons.firstWhere(
          (l) => l.status == LessonStatus.available || l.status == LessonStatus.inProgress,
          orElse: () => lessons.first,
        );
        context.push('/lesson/${target.id}/quiz');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching quiz: $e')),
        );
      }
    }
  }
}
