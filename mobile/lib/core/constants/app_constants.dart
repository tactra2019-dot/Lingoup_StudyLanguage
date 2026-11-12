class AppConstants {
  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String localBaseUrl = 'http://localhost:8000/api/v1';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String selectedLanguageKey = 'selected_language_id';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // App info
  static const String appName = 'LingoUp';
  static const String appVersion = '1.0.0';

  // Learning
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerLesson = 20;
  static const int xpPerfectBonus = 10;

  // Pagination
  static const int defaultPageSize = 20;

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
}
