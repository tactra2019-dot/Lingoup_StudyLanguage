import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_repository.dart';
import '../data/learning_repository.dart';
import 'widgets/learning_header.dart';
import 'widgets/lesson_node.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;
    final unitsAsync = ref.watch(unitsProvider(user?.selectedLanguageId));

    if (userAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryMint),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Header (compact flag/level, fire streak, diamond XP)
          LearningHeader(
            user: user,
            levelCode: 'A1',
            flagEmoji: '🇺🇸',
            onLanguageTap: () => context.push('/language-selection'),
          ),

          // Learning Progression Path
          Expanded(
            child: unitsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMint),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load learning path',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('$err', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(unitsProvider(user?.selectedLanguageId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (units) {
                if (units.isEmpty) {
                  return const Center(child: Text('No units found.'));
                }

                return RefreshIndicator(
                  color: AppColors.primaryMint,
                  onRefresh: () async {
                    ref.invalidate(unitsProvider(user?.selectedLanguageId));
                    ref.invalidate(authStateProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      // Zigzag alignment: 0 right, 1 left, 2 right, 3 left...
                      final isRightAligned = index % 2 == 0;

                      return LessonNodeWidget(
                        unit: unit,
                        isRightAligned: isRightAligned,
                        onTap: () {
                          _showUnitLessonsSheet(context, unit);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUnitLessonsSheet(BuildContext context, Unit unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UnitLessonsModal(unit: unit),
    );
  }
}

class _UnitLessonsModal extends ConsumerWidget {
  final Unit unit;

  const _UnitLessonsModal({required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unit.id));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE5EB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                unit.emoji ?? '📚',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit ${unit.orderIndex + 1}: ${unit.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (unit.description != null)
                      Text(
                        unit.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Lessons',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: lessonsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.primaryMint),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (lessons) {
                if (lessons.isEmpty) {
                  return const Text('No lessons available in this unit.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final lesson = lessons[idx];
                    final isCompleted = lesson.status == LessonStatus.completed;
                    final isLocked = lesson.status == LessonStatus.locked;

                    return Material(
                      color: isLocked ? AppColors.surfaceLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.primaryMint
                                : isLocked
                                    ? const Color(0xFFE2EBF0)
                                    : AppColors.accentBlue,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isCompleted
                                ? AppColors.primaryMint
                                : isLocked
                                    ? AppColors.lockedGray.withOpacity(0.3)
                                    : AppColors.accentBlue,
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : isLocked
                                      ? Icons.lock
                                      : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            lesson.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isLocked ? AppColors.textHint : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '+${lesson.xpReward} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentBlue,
                            ),
                          ),
                          trailing: isLocked
                              ? null
                              : const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                          onTap: isLocked
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  context.push('/lesson/${lesson.id}/intro');
                                },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
