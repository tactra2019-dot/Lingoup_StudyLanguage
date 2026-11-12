import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../learning_path/data/learning_repository.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  void _speak(String word) async {
    setState(() => _isPlayingAudio = true);
    await _tts.speak(word);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(lessonVocabProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vocabulary Lesson'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: vocabAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMint),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (vocabList) {
            if (vocabList.isEmpty) {
              return const Center(child: Text('No vocabulary found.'));
            }

            final item = vocabList[_currentIndex];
            final progress = (_currentIndex + 1) / vocabList.length;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFDCE5EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Card ${_currentIndex + 1} of ${vocabList.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Word Card
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item.partOfSpeech != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.partOfSpeech!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            item.word,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (item.pronunciation != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.pronunciation!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          // Pronounce Audio Button
                          GestureDetector(
                            onTap: () => _speak(item.word),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isPlayingAudio ? AppColors.accentBlue : const Color(0xFFE8F6FC),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.volume_up_rounded,
                                color: _isPlayingAudio ? Colors.white : AppColors.accentBlue,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Divider(),
                          const SizedBox(height: 20),
                          Text(
                            item.translation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (item.exampleSentence != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '"${item.exampleSentence}"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (item.exampleTranslation != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.exampleTranslation!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _currentIndex--);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < vocabList.length - 1) {
                              setState(() => _currentIndex++);
                            } else {
                              // Finished all cards -> Go to quiz!
                              context.pushReplacement('/lesson/${widget.lessonId}/quiz');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMint,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentIndex < vocabList.length - 1 ? 'Next Word' : 'Take Quiz',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
