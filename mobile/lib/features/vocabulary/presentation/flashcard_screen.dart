import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/data/learning_repository.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const FlashcardScreen({super.key, required this.lessonId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  bool _showBack = false;

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

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(lessonVocabProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Interactive Flashcards'),
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
              return const Center(child: Text('No flashcards available.'));
            }

            final item = vocabList[_currentIndex];
            final progress = (_currentIndex + 1) / vocabList.length;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFDCE5EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryMint),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Card ${_currentIndex + 1} of ${vocabList.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Flippable Flashcard
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showBack = !_showBack);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: _showBack ? AppColors.accentBlue : AppColors.primaryMint,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_showBack ? AppColors.accentBlue : AppColors.primaryMint).withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showBack ? 'VIETNAMESE' : 'ENGLISH',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: _showBack ? AppColors.accentBlue : AppColors.primaryMint,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _showBack ? item.translation : item.word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (!_showBack && item.pronunciation != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                item.pronunciation!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 32),
                              color: AppColors.primaryMint,
                              onPressed: () => _speak(item.word),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 6),
                                  Text(
                                    _showBack ? 'Tap to see English' : 'Tap to flip translation',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Next / Prev controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentIndex > 0
                              ? () {
                                  setState(() {
                                    _currentIndex--;
                                    _showBack = false;
                                  });
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < vocabList.length - 1) {
                              setState(() {
                                _currentIndex++;
                                _showBack = false;
                              });
                            } else {
                              context.pop();
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
                            _currentIndex < vocabList.length - 1 ? 'Next Card' : 'Finish',
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
