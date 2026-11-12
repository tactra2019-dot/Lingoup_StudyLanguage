// Shared data models for LingoUp

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int? selectedLanguageId;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.selectedLanguageId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        email: json['email'],
        displayName: json['display_name'],
        avatarUrl: json['avatar_url'],
        totalXp: json['total_xp'] ?? 0,
        currentStreak: json['current_streak'] ?? 0,
        longestStreak: json['longest_streak'] ?? 0,
        lastActivityDate: json['last_activity_date'],
        selectedLanguageId: json['selected_language_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'total_xp': totalXp,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_activity_date': lastActivityDate,
        'selected_language_id': selectedLanguageId,
      };

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    String? lastActivityDate,
    int? selectedLanguageId,
  }) =>
      UserProfile(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        totalXp: totalXp ?? this.totalXp,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActivityDate: lastActivityDate ?? this.lastActivityDate,
        selectedLanguageId: selectedLanguageId ?? this.selectedLanguageId,
      );
}

class Language {
  final int id;
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const Language({
    required this.id,
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        nativeName: json['native_name'],
        flagEmoji: json['flag_emoji'],
      );
}

class Level {
  final int id;
  final int languageId;
  final String code;
  final String name;
  final String? description;
  final int orderIndex;

  const Level({
    required this.id,
    required this.languageId,
    required this.code,
    required this.name,
    this.description,
    required this.orderIndex,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json['id'],
        languageId: json['language_id'],
        code: json['code'],
        name: json['name'],
        description: json['description'],
        orderIndex: json['order_index'],
      );
}

enum UnitStatus { locked, available, completed }

class Unit {
  final int id;
  final int levelId;
  final String title;
  final String? description;
  final int orderIndex;
  final String? emoji;
  final UnitStatus status;
  final int completedLessons;
  final int totalLessons;
  final double progressPercent;

  const Unit({
    required this.id,
    required this.levelId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.emoji,
    this.status = UnitStatus.locked,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.progressPercent = 0.0,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'],
        levelId: json['level_id'],
        title: json['title'],
        description: json['description'],
        orderIndex: json['order_index'],
        emoji: json['emoji'],
        status: _parseStatus(json['status'] ?? 'locked'),
        completedLessons: json['completed_lessons'] ?? 0,
        totalLessons: json['total_lessons'] ?? 0,
        progressPercent: (json['progress_percent'] ?? 0.0).toDouble(),
      );

  static UnitStatus _parseStatus(String s) => switch (s) {
        'completed' => UnitStatus.completed,
        'available' => UnitStatus.available,
        _ => UnitStatus.locked,
      };
}

enum LessonStatus { locked, available, inProgress, completed }

class Lesson {
  final int id;
  final int unitId;
  final String title;
  final String? description;
  final String? objectives;
  final int orderIndex;
  final int xpReward;
  final String lessonType;
  final LessonStatus status;
  final int score;
  final int attempts;

  const Lesson({
    required this.id,
    required this.unitId,
    required this.title,
    this.description,
    this.objectives,
    required this.orderIndex,
    this.xpReward = 20,
    this.lessonType = 'mixed',
    this.status = LessonStatus.locked,
    this.score = 0,
    this.attempts = 0,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        unitId: json['unit_id'],
        title: json['title'],
        description: json['description'],
        objectives: json['objectives'],
        orderIndex: json['order_index'],
        xpReward: json['xp_reward'] ?? 20,
        lessonType: json['lesson_type'] ?? 'mixed',
        status: _parseStatus(json['status'] ?? 'locked'),
        score: json['score'] ?? 0,
        attempts: json['attempts'] ?? 0,
      );

  static LessonStatus _parseStatus(String s) => switch (s) {
        'completed' => LessonStatus.completed,
        'in_progress' => LessonStatus.inProgress,
        'available' => LessonStatus.available,
        _ => LessonStatus.locked,
      };
}

class VocabularyItem {
  final int id;
  final int lessonId;
  final String word;
  final String translation;
  final String? pronunciation;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? meaning;
  final String? imageUrl;
  final String? partOfSpeech;
  final bool isLearned;
  final int reviewCount;

  const VocabularyItem({
    required this.id,
    required this.lessonId,
    required this.word,
    required this.translation,
    this.pronunciation,
    this.exampleSentence,
    this.exampleTranslation,
    this.meaning,
    this.imageUrl,
    this.partOfSpeech,
    this.isLearned = false,
    this.reviewCount = 0,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
        id: json['id'],
        lessonId: json['lesson_id'],
        word: json['word'],
        translation: json['translation'],
        pronunciation: json['pronunciation'],
        exampleSentence: json['example_sentence'],
        exampleTranslation: json['example_translation'],
        meaning: json['meaning'],
        imageUrl: json['image_url'],
        partOfSpeech: json['part_of_speech'],
        isLearned: json['is_learned'] ?? false,
        reviewCount: json['review_count'] ?? 0,
      );
}

class QuestionOption {
  final int id;
  final String text;
  final int orderIndex;

  const QuestionOption({
    required this.id,
    required this.text,
    required this.orderIndex,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) => QuestionOption(
        id: json['id'],
        text: json['text'],
        orderIndex: json['order_index'],
      );
}

class Question {
  final int id;
  final int lessonId;
  final String questionType;
  final String prompt;
  final String? imageUrl;
  final int difficulty;
  final int orderIndex;
  final List<QuestionOption> options;

  const Question({
    required this.id,
    required this.lessonId,
    required this.questionType,
    required this.prompt,
    this.imageUrl,
    this.difficulty = 1,
    required this.orderIndex,
    this.options = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        lessonId: json['lesson_id'],
        questionType: json['question_type'],
        prompt: json['prompt'],
        imageUrl: json['image_url'],
        difficulty: json['difficulty'] ?? 1,
        orderIndex: json['order_index'],
        options: (json['options'] as List? ?? [])
            .map((o) => QuestionOption.fromJson(o))
            .toList(),
      );
}

class QuizAttempt {
  final int id;
  final int lessonId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final bool isCompleted;

  const QuizAttempt({
    required this.id,
    required this.lessonId,
    this.score = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.xpEarned = 0,
    this.isCompleted = false,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'],
        lessonId: json['lesson_id'],
        score: json['score'] ?? 0,
        totalQuestions: json['total_questions'] ?? 0,
        correctAnswers: json['correct_answers'] ?? 0,
        xpEarned: json['xp_earned'] ?? 0,
        isCompleted: json['is_completed'] ?? false,
      );
}

class AnswerResult {
  final bool isCorrect;
  final int? correctOptionId;
  final String? explanation;
  final int pointsEarned;

  const AnswerResult({
    required this.isCorrect,
    this.correctOptionId,
    this.explanation,
    required this.pointsEarned,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) => AnswerResult(
        isCorrect: json['is_correct'],
        correctOptionId: json['correct_option_id'],
        explanation: json['explanation'],
        pointsEarned: json['points_earned'],
      );
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final bool isPerfect;
  final bool lessonCompleted;
  final int newTotalXp;
  final bool streakUpdated;

  const QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.isPerfect,
    required this.lessonCompleted,
    required this.newTotalXp,
    required this.streakUpdated,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        score: json['score'],
        totalQuestions: json['total_questions'],
        correctAnswers: json['correct_answers'],
        xpEarned: json['xp_earned'],
        isPerfect: json['is_perfect'],
        lessonCompleted: json['lesson_completed'],
        newTotalXp: json['new_total_xp'],
        streakUpdated: json['streak_updated'],
      );

  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final List<String> calendarDays;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.calendarDays = const [],
  });

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
        currentStreak: json['current_streak'],
        longestStreak: json['longest_streak'],
        lastActivityDate: json['last_activity_date'],
        calendarDays: (json['calendar_days'] as List? ?? []).cast<String>(),
      );
}

class Achievement {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String iconEmoji;
  final int xpReward;
  final bool earned;
  final DateTime? earnedAt;

  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.iconEmoji,
    required this.xpReward,
    this.earned = false,
    this.earnedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        code: json['code'],
        title: json['title'],
        description: json['description'],
        iconEmoji: json['icon_emoji'],
        xpReward: json['xp_reward'],
        earned: json['earned'] ?? false,
        earnedAt: json['earned_at'] != null
            ? DateTime.tryParse(json['earned_at'])
            : null,
      );
}

class ProgressOverview {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int completedLessons;
  final int totalLessons;
  final int learnedVocabulary;
  final int totalVocabulary;
  final double levelProgressPercent;

  const ProgressOverview({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedLessons,
    required this.totalLessons,
    required this.learnedVocabulary,
    required this.totalVocabulary,
    required this.levelProgressPercent,
  });

  factory ProgressOverview.fromJson(Map<String, dynamic> json) => ProgressOverview(
        totalXp: json['total_xp'],
        currentStreak: json['current_streak'],
        longestStreak: json['longest_streak'],
        completedLessons: json['completed_lessons'],
        totalLessons: json['total_lessons'],
        learnedVocabulary: json['learned_vocabulary'],
        totalVocabulary: json['total_vocabulary'],
        levelProgressPercent: (json['level_progress_percent'] ?? 0.0).toDouble(),
      );
}
