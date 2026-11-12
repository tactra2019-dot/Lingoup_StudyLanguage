import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        final auth = ref.read(authStateProvider);
        if (!auth.isLoading) {
          if (auth.valueOrNull != null) {
            final user = auth.valueOrNull!;
            if (user.selectedLanguageId == null) {
              context.go('/language-selection');
            } else {
              context.go('/');
            }
          } else {
            context.go('/onboarding');
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to navigate
    ref.listen(authStateProvider, (prev, next) {
      if (next.isLoading) return;
      if (next.valueOrNull != null) {
        // Check if user has selected a language
        final user = next.valueOrNull!;
        if (user.selectedLanguageId == null) {
          context.go('/language-selection');
        } else {
          context.go('/');
        }
      } else {
        // Check if first time
        context.go('/onboarding');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌍', style: TextStyle(fontSize: 52)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'LingoUp',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn. Play. Master.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
