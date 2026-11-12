import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/home_shell.dart';
import '../features/learning_path/presentation/learning_path_screen.dart';
import '../features/vocabulary/presentation/vocabulary_screen.dart';
import '../features/practice/presentation/practice_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/lessons/presentation/lesson_screen.dart';
import '../features/lessons/presentation/lesson_intro_screen.dart';
import '../features/vocabulary/presentation/vocabulary_detail_screen.dart';
import '../features/vocabulary/presentation/flashcard_screen.dart';
import '../features/practice/presentation/quiz_screen.dart';
import '../features/practice/presentation/quiz_result_screen.dart';
import '../features/gamification/presentation/achievements_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/auth/presentation/language_selection_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;

      if (isLoading) return '/splash';

      final authRoutes = ['/login', '/register', '/onboarding'];
      final isAuthRoute = authRoutes.any((r) => location.startsWith(r));
      final isSplash = location == '/splash';

      if (isSplash) {
        return isLoggedIn ? '/' : '/onboarding';
      }

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (ctx, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (ctx, state) => const LanguageSelectionScreen(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (ctx, state) => const NoTransitionPage(
              child: LearningPathScreen(),
            ),
          ),
          GoRoute(
            path: '/vocab',
            pageBuilder: (ctx, state) => const NoTransitionPage(
              child: VocabularyScreen(),
            ),
          ),
          GoRoute(
            path: '/practice',
            pageBuilder: (ctx, state) => const NoTransitionPage(
              child: PracticeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (ctx, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      // Full-screen routes (outside shell)
      GoRoute(
        path: '/lesson/:id/intro',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => LessonIntroScreen(
          lessonId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/lesson/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => LessonScreen(
          lessonId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/lesson/:id/quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => QuizScreen(
          lessonId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/quiz-result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(result: extra['result'], lessonTitle: extra['lessonTitle']);
        },
      ),
      GoRoute(
        path: '/vocab/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => VocabularyDetailScreen(
          lessonId: int.parse(state.pathParameters['lessonId']!),
        ),
      ),
      GoRoute(
        path: '/flashcards/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => FlashcardScreen(
          lessonId: int.parse(state.pathParameters['lessonId']!),
        ),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const SettingsScreen(),
      ),
    ],
  );
});
