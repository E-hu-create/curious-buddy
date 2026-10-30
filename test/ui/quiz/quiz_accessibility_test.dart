import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/quiz/more_quiz_topics.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_screen.dart';
import 'package:curious_buddy/ui/quiz/widgets/quiz_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

QuizQuestion _current(QuizLevel level) => level.questions.firstWhere(
  (q) => find.text(q.prompt).evaluate().isNotEmpty,
);

/// Answers wrongly, which shows the most on screen (your answer, the right
/// answer and the explanation), then moves on.
Future<void> _answerWrongAndContinue(
  WidgetTester tester,
  QuizLevel level, {
  required bool last,
}) async {
  final q = _current(level);
  final wrong = q.options.firstWhere((o) => o.id != q.answerId);
  await _tap(tester, find.text(wrong.text).first);
  await _tap(
    tester,
    find.text(last ? QuizPlayScreen.finishLabel : QuizPlayScreen.nextLabel),
  );
}

void main() {
  late BuddyVoice voice;
  late InMemoryKeyValueStore store;

  setUp(() {
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
  });

  tearDown(() => voice.dispose());

  Widget page(QuizTopic topic, QuizLevel level) => MaterialApp(
    theme: AppTheme.light(),
    home: QuizPlayScreen(
      topic: topic,
      level: level,
      voice: voice,
      progressRepository: LocalProgressRepository(store),
    ),
  );

  testWidgets('Quiz Time meets tap target, label and contrast guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await _tap(tester, find.text(HomeDestination.quiz.title));

    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('a question, its result and the summary meet the guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    final topic = starterQuizTopics.first;
    final level = topic.levels.first;
    await tester.pumpWidget(page(topic, level));
    await tester.pumpAndSettle();
    await _expectGuidelines(tester);

    final q = _current(level);
    await _tap(tester, find.text(q.answer.text));
    await _expectGuidelines(tester);

    await _tap(tester, find.text(QuizPlayScreen.nextLabel));
    for (var i = 1; i < level.questions.length; i++) {
      await _answerWrongAndContinue(
        tester,
        level,
        last: i == level.questions.length - 1,
      );
    }
    expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('answers are announced with their letter and result', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    final topic = starterQuizTopics.first;
    final level = topic.levels.first;
    await tester.pumpWidget(page(topic, level));
    await tester.pumpAndSettle();
    final q = _current(level);

    expect(find.bySemanticsLabel(RegExp(r'^Answer A: ')), findsOneWidget);
    await _tap(tester, find.text(q.answer.text));
    expect(
      find.bySemanticsLabel(
        RegExp('${q.answer.text}, ${QuizAnswerTile.rightTag}\$'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('Quiz Time lays out without overflow: $name', (tester) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      await _tap(tester, find.text(HomeDestination.quiz.title));
      // Overflow errors fail the test automatically.
      expect(find.text(allQuizTopics.last.title), findsWidgets);
    });

    for (final topic in allQuizTopics) {
      testWidgets('every question of ${topic.title} lays out: $name', (
        tester,
      ) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        for (final level in topic.levels) {
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(page(topic, level));
          await tester.pumpAndSettle();
          for (var i = 0; i < level.questions.length; i++) {
            await _answerWrongAndContinue(
              tester,
              level,
              last: i == level.questions.length - 1,
            );
          }
          expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
        }
      });
    }
  }
}
