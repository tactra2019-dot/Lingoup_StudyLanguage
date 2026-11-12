import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_repository.dart';
import '../../learning_path/data/learning_repository.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;
    final unitsAsync = ref.watch(unitsProvider(user?.selectedLanguageId));
    final progressAsync = ref.watch(progressOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vocabulary Library'),
        centerTitle: false,
        actions: [
          progressAsync.when(
            data: (ProgressOverview p) => Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMint.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${p.learnedVocabulary}/${p.totalVocabulary} Words',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: SafeArea(
        child: unitsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMint),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (units) {
            if (units.isEmpty) {
              return const Center(child: Text('No vocabulary units found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: units.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final unit = units[index];
                return _VocabUnitCard(unit: unit);
              },
            );
          },
        ),
      ),
    );
  }
}

class _VocabUnitCard extends ConsumerWidget {
  final Unit unit;

  const _VocabUnitCard({required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unit.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(unit.emoji ?? '📖', style: const TextStyle(fontSize: 24)),
            ),
          ),
          title: Text(
            'Unit ${unit.orderIndex + 1}: ${unit.title}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${unit.totalLessons} lessons',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: lessonsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(color: AppColors.primaryMint, strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (List<Lesson> lessons) {
                  return Column(
                    children: lessons.map((Lesson lesson) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.style_outlined, size: 16),
                              label: const Text('Flashcards'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                              onPressed: () {
                                context.push('/flashcards/${lesson.id}');
                              },
                            ),
                            const SizedBox(width: 4),
                            TextButton.icon(
                              icon: const Icon(Icons.list_alt_rounded, size: 16),
                              label: const Text('Words'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryMint,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                              onPressed: () {
                                context.push('/vocab/${lesson.id}');
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
