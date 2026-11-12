import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/data/learning_repository.dart';

class LessonIntroScreen extends ConsumerWidget {
  final int lessonId;

  const LessonIntroScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(lessonVocabProvider(lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lesson Overview'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('📖', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Lesson Ready!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Learn words and complete practice quiz to earn XP and extend your streak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Reward Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2EBF0)),
                      ),
                      child: const Column(
                        children: [
                          Text('💎', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 6),
                          Text(
                            '+20 XP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentBlue,
                            ),
                          ),
                          Text('Reward', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2EBF0)),
                      ),
                      child: const Column(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 6),
                          Text(
                            '+1 Day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          Text('Streak', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Vocabulary in this lesson',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: vocabAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryMint),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (vocabList) {
                    return ListView.separated(
                      itemCount: vocabList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final v = vocabList[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2EBF0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.word,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (v.pronunciation != null)
                                    Text(
                                      v.pronunciation!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.accentBlue,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                v.translation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/lesson/$lessonId'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Study Words'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/lesson/$lessonId/quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMint,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
