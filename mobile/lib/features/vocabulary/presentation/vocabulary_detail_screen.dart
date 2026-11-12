import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../learning_path/data/learning_repository.dart';

class VocabularyDetailScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const VocabularyDetailScreen({super.key, required this.lessonId});

  @override
  ConsumerState<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends ConsumerState<VocabularyDetailScreen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
  }

  void _speak(String word) async {
    await _tts.speak(word);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _toggleLearned(VocabularyItem item) async {
    try {
      final repo = ref.read(learningRepositoryProvider);
      await repo.markVocabularyLearned(item.id, !item.isLearned);
      ref.invalidate(lessonVocabProvider(widget.lessonId));
      ref.invalidate(progressOverviewProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(lessonVocabProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vocabulary List'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Flashcards',
            onPressed: () => context.push('/flashcards/${widget.lessonId}'),
          ),
        ],
      ),
      body: SafeArea(
        child: vocabAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMint),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (vocabList) {
            if (vocabList.isEmpty) {
              return const Center(child: Text('No vocabulary items found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vocabList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = vocabList[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: item.isLearned ? AppColors.primaryMint : const Color(0xFFE2EBF0),
                      width: item.isLearned ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
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
                                Row(
                                  children: [
                                    Text(
                                      item.word,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                                      color: AppColors.accentBlue,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _speak(item.word),
                                    ),
                                  ],
                                ),
                                if (item.pronunciation != null)
                                  Text(
                                    item.pronunciation!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleLearned(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: item.isLearned
                                    ? const Color(0xFFE8FAF5)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: item.isLearned
                                      ? AppColors.primaryMint
                                      : const Color(0xFFDCE5EB),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.isLearned ? Icons.check_circle : Icons.circle_outlined,
                                    size: 16,
                                    color: item.isLearned ? AppColors.primaryMint : AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.isLearned ? 'Learned' : 'Learn',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: item.isLearned ? AppColors.primaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.translation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      if (item.exampleSentence != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '"${item.exampleSentence}"',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.exampleTranslation != null)
                          Text(
                            item.exampleTranslation!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
