import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/models.dart';
import '../../../core/network/dio_client.dart';

// --- Providers ---
final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.read(dioProvider));
});

final unitsProvider = FutureProvider.family<List<Unit>, int?>((ref, languageId) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getUnits(languageId: languageId);
});

final unitLessonsProvider = FutureProvider.family<List<Lesson>, int>((ref, unitId) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getUnitLessons(unitId);
});

final lessonVocabProvider = FutureProvider.family<List<VocabularyItem>, int>((ref, lessonId) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getLessonVocabulary(lessonId);
});

final lessonQuestionsProvider = FutureProvider.family<List<Question>, int>((ref, lessonId) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getLessonQuestions(lessonId);
});

final progressOverviewProvider = FutureProvider<ProgressOverview>((ref) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getProgressOverview();
});

final streakProvider = FutureProvider<StreakData>((ref) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getStreak();
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getAchievements();
});

final languagesProvider = FutureProvider<List<Language>>((ref) async {
  final repo = ref.read(learningRepositoryProvider);
  return repo.getLanguages();
});

// --- Repository ---
class LearningRepository {
  final Dio _dio;

  LearningRepository(this._dio);

  Future<List<Language>> getLanguages() async {
    try {
      final response = await _dio.get('/content/languages');
      return (response.data as List).map((j) => Language.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Unit>> getUnits({int? languageId, int? levelId}) async {
    try {
      final response = await _dio.get('/content/units', queryParameters: {
        if (languageId != null) 'language_id': languageId,
        if (levelId != null) 'level_id': levelId,
      });
      return (response.data as List).map((j) => Unit.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Lesson>> getUnitLessons(int unitId) async {
    try {
      final response = await _dio.get('/content/units/$unitId/lessons');
      return (response.data as List).map((j) => Lesson.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<VocabularyItem>> getLessonVocabulary(int lessonId) async {
    try {
      final response = await _dio.get('/learning/lessons/$lessonId/vocabulary');
      return (response.data as List).map((j) => VocabularyItem.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Question>> getLessonQuestions(int lessonId) async {
    try {
      final response = await _dio.get('/learning/lessons/$lessonId/questions');
      return (response.data as List).map((j) => Question.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<QuizAttempt> createQuizAttempt(int lessonId) async {
    try {
      final response = await _dio.post('/learning/quiz-attempts', data: {
        'lesson_id': lessonId,
      });
      return QuizAttempt.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AnswerResult> submitAnswer({
    required int attemptId,
    required int questionId,
    int? selectedOptionId,
    String? textAnswer,
  }) async {
    try {
      final response = await _dio.post(
        '/learning/quiz-attempts/$attemptId/answers',
        data: {
          'question_id': questionId,
          if (selectedOptionId != null) 'selected_option_id': selectedOptionId,
          if (textAnswer != null) 'text_answer': textAnswer,
        },
      );
      return AnswerResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<QuizResult> completeQuiz(int attemptId) async {
    try {
      final response = await _dio.post('/learning/quiz-attempts/$attemptId/complete');
      return QuizResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markVocabularyLearned(int wordId, bool isLearned) async {
    try {
      await _dio.post('/learning/vocabulary/$wordId/review', data: {
        'is_learned': isLearned,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProgressOverview> getProgressOverview() async {
    try {
      final response = await _dio.get('/gamification/progress/overview');
      return ProgressOverview.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<StreakData> getStreak() async {
    try {
      final response = await _dio.get('/gamification/streak');
      return StreakData.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _dio.get('/gamification/achievements');
      return (response.data as List).map((j) => Achievement.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> enrollInLanguage(int languageId) async {
    try {
      await _dio.post('/content/enroll', queryParameters: {
        'language_id': languageId,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
