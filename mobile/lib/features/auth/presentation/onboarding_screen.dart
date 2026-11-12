import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      emoji: '🌟',
      title: 'Gamified Learning',
      subtitle: 'Master English through bite-sized, interactive levels that feel like playing a game.',
    ),
    OnboardingItem(
      emoji: '🔥',
      title: 'Build Daily Streaks',
      subtitle: 'Stay motivated with daily streaks, earn XP, unlock achievements, and level up your skills.',
    ),
    OnboardingItem(
      emoji: '🎧',
      title: 'Audio Pronunciation',
      subtitle: 'Listen to native pronunciations and practice interactive quizzes designed for real communication.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryMint.withOpacity(0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryMint : AppColors.lockedGray.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/register');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
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

class OnboardingItem {
  final String emoji;
  final String title;
  final String subtitle;

  const OnboardingItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
