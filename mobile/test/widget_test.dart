import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingoup/app/app.dart';
import 'package:lingoup/shared/models/models.dart';
import 'package:lingoup/features/practice/presentation/widgets/feedback_bottom_sheet.dart';
import 'package:lingoup/features/learning_path/presentation/widgets/lesson_node.dart';
import 'package:lingoup/features/home/custom_bottom_nav.dart';

void main() {
  group('LingoUp Model Tests', () {
    test('UserProfile JSON serialization', () {
      final json = {
        'id': 'user-123',
        'email': 'alex@example.com',
        'display_name': 'Alex',
        'total_xp': 150,
        'current_streak': 5,
        'longest_streak': 12,
        'selected_language_id': 1,
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 'user-123');
      expect(profile.totalXp, 150);
      expect(profile.currentStreak, 5);
      expect(profile.longestStreak, 12);
      expect(profile.displayName, 'Alex');

      final output = profile.toJson();
      expect(output['email'], 'alex@example.com');
    });

    test('Unit and Lesson model status parsing', () {
      final unit = Unit.fromJson({
        'id': 1,
        'level_id': 1,
        'title': 'Introductions',
        'order_index': 0,
        'status': 'completed',
        'completed_lessons': 3,
        'total_lessons': 3,
        'progress_percent': 100.0,
      });

      expect(unit.status, UnitStatus.completed);
      expect(unit.progressPercent, 100.0);

      final lesson = Lesson.fromJson({
        'id': 10,
        'unit_id': 1,
        'title': 'Saying Hello',
        'order_index': 0,
        'status': 'available',
        'xp_reward': 20,
      });

      expect(lesson.status, LessonStatus.available);
      expect(lesson.xpReward, 20);
    });

    test('QuizResult model computation', () {
      final result = QuizResult.fromJson({
        'score': 50,
        'total_questions': 5,
        'correct_answers': 5,
        'xp_earned': 30,
        'is_perfect': true,
        'lesson_completed': true,
        'new_total_xp': 180,
        'streak_updated': true,
      });

      expect(result.isPerfect, true);
      expect(result.accuracy, 1.0);
      expect(result.streakUpdated, true);
    });
  });

  group('LingoUp Widget Tests', () {
    testWidgets('FeedbackBottomSheet renders Correct state with Next button', (tester) async {
      bool nextTapped = false;
      bool closeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(
              isCorrect: true,
              explanation: 'Well done!',
              onNext: () => nextTapped = true,
              onClose: () => closeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('Well done!'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      expect(nextTapped, true);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closeTapped, true);
    });

    testWidgets('FeedbackBottomSheet renders Incorrect state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(
              isCorrect: false,
              explanation: 'Try again with Hello!',
              onNext: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Not quite!'), findsOneWidget);
      expect(find.text('Try again with Hello!'), findsOneWidget);
    });

    testWidgets('CustomBottomNavBar highlights active item', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: 0,
              onTap: (idx) => tappedIndex = idx,
            ),
          ),
        ),
      );

      expect(find.text('Path'), findsOneWidget);
      expect(find.text('Vocab'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Vocab'));
      expect(tappedIndex, 1);
    });

    testWidgets('LessonNodeWidget renders unit title and order', (tester) async {
      const unit = Unit(
        id: 1,
        levelId: 1,
        title: 'Introductions',
        orderIndex: 0,
        status: UnitStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonNodeWidget(
              unit: unit,
              isRightAligned: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Unit 1:'), findsOneWidget);
      expect(find.text('Introductions'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('App root renders without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: LingoUpApp(),
        ),
      );

      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
