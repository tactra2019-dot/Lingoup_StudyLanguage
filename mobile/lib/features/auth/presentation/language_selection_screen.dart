import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/data/learning_repository.dart';
import '../data/auth_repository.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  int? _selectedLanguageId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(languagesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMint.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌐', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Choose Your Target Language',
                  textAlign: TextAlign.center,
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
                  'Select the language you want to study on LingoUp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: languagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryMint),
                  ),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: $err', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.refresh(languagesProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (languages) {
                    if (languages.isEmpty) {
                      return const Center(child: Text('No languages available yet.'));
                    }
                    if (_selectedLanguageId == null && languages.isNotEmpty) {
                      _selectedLanguageId = languages.first.id;
                    }
                    return ListView.separated(
                      itemCount: languages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        final isSelected = _selectedLanguageId == lang.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedLanguageId = lang.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryMint : const Color(0xFFE2EBF0),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryMint.withOpacity(0.12),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang.flagEmoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        lang.nativeName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryMint,
                                    size: 26,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedLanguageId == null || _isLoading)
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            final repo = ref.read(learningRepositoryProvider);
                            await repo.enrollInLanguage(_selectedLanguageId!);
                            await ref.read(authStateProvider.notifier).refreshUser();
                            ref.invalidate(unitsProvider);
                            if (mounted) {
                              context.go('/');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Enrollment failed: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Continue to Learning Path',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
