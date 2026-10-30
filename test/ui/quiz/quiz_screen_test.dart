import 'dart:async';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/repositories/quiz_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/quiz/more_quiz_topics.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:curious_buddy/ui/quiz/quiz_hub_screen.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_screen.dart';
import 'package:curious_buddy/ui/quiz/widgets/quiz_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import '../parent_zone/parent_zone_screen_test.dart' show wordsToNumber;

class _FailingQuizzes implements QuizRepository {
  @override
  Future<List<QuizTopic>> loadTopics() async => throw Exception('disk broke');
}

class _SlowQuizzes implements QuizRepository {
  final done = Completer<List<QuizTopic>>();
  @override
  Future<List<QuizTopic>> loadTopics() => done.future;
}

final space = starterQuizTopics.first;

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> startApp(WidgetTester tester, {QuizRepository? quizzes}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store, quizzes: quizzes),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openQuiz(WidgetTester tester, {QuizRepository? quizzes}) async {
    await startApp(tester, quizzes: quizzes);
    await tapText(tester, HomeDestination.quiz.title);
  }

  /// The question on screen, found among [level]'s questions.
  QuizQuestion current(QuizLevel level) => level.questions.firstWhere(
    (q) => find.text(q.prompt).evaluate().isNotEmpty,
  );

  /// Answers the question on screen through the answer tile.
  Future<void> answer(
    WidgetTester tester,
    QuizLevel level, {
    required bool right,
  }) async {
    final q = current(level);
    final option = right
        ? q.answer
        : q.options.firstWhere((o) => o.id != q.answerId);
    await tapText(tester, option.text);
  }

  /// Plays a whole round, the first [rightCount] answers right.
  Future<void> playRound(
    WidgetTester tester,
    QuizLevel level,
    int rightCount,
  ) async {
    for (var i = 0; i < level.questions.length; i++) {
      await answer(tester, level, right: i < rightCount);
      await tapText(
        tester,
        i == level.questions.length - 1
            ? QuizPlayScreen.finishLabel
            : QuizPlayScreen.nextLabel,
      );
    }
  }

  testWidgets('Home has a Quiz Time card that opens four topics', (
    tester,
  ) async {
    await openQuiz(tester);

    expect(find.text(QuizHubScreen.title), findsOneWidget);
    for (final topic in allQuizTopics) {
      await tester.ensureVisible(find.text(topic.title));
      expect(find.text(topic.title), findsOneWidget);
    }
    final count = allQuizTopics.length;
    expect(find.text(QuizHubScreen.starsLabel(0, count * 9)), findsOneWidget);
    expect(find.text('Play Starter'), findsNWidgets(count));
    expect(
      find.text(QuizHubScreen.lockedLabel('Starter')),
      findsNWidgets(count),
    );
    expect(
      find.text(QuizHubScreen.lockedLabel('Explorer')),
      findsNWidgets(count),
    );
  });

  testWidgets('shows a loading state, then the quizzes', (tester) async {
    final slow = _SlowQuizzes();
    await startApp(tester, quizzes: slow);
    final card = find.text(HomeDestination.quiz.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    slow.done.complete(starterQuizTopics);
    await tester.pumpAndSettle();
    expect(find.text(space.title), findsOneWidget);
  });

  testWidgets('empty and failed loads are friendly', (tester) async {
    await openQuiz(tester, quizzes: BundledQuizRepository(topics: []));
    expect(find.text(QuizHubScreen.emptyMessage), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await openQuiz(tester, quizzes: _FailingQuizzes());
    expect(find.text(QuizHubScreen.errorMessage), findsOneWidget);
    expect(find.text(QuizHubScreen.retryLabel), findsOneWidget);
  });

  testWidgets('a right answer is confirmed and explained', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    final level = space.levels.first;
    final q = current(level);

    expect(find.text(QuizPlayScreen.questionLabel(1, 5)), findsOneWidget);
    await answer(tester, level, right: true);

    expect(find.text(QuizResultPanel.rightTitle), findsOneWidget);
    expect(find.text(q.explanation), findsOneWidget);
    expect(find.text(QuizAnswerTile.rightTag), findsOneWidget);
    expect(find.text(QuizPlayScreen.nextLabel), findsOneWidget);
  });

  testWidgets('a wrong answer shows the right one; no second try', (
    tester,
  ) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    final level = space.levels.first;
    final q = current(level);

    await answer(tester, level, right: false);

    expect(
      find.text(
        '${QuizResultPanel.wrongTitle} The answer is ${q.answer.text}.',
      ),
      findsOneWidget,
    );
    expect(find.text(QuizAnswerTile.yourAnswerTag), findsOneWidget);
    expect(find.text(QuizAnswerTile.rightTag), findsOneWidget);

    // Tapping the right answer now changes nothing.
    await tapText(tester, q.answer.text);
    expect(find.text(QuizResultPanel.rightTitle), findsNothing);
  });

  testWidgets('a perfect round: summary, stars, and the next level', (
    tester,
  ) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 5);

    expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
    expect(find.text(QuizPlayScreen.scoreLabel(5, 5)), findsOneWidget);
    expect(find.bySemanticsLabel(QuizStars.label(3)), findsOneWidget);
    expect(find.textContaining('You opened the next level!'), findsOneWidget);
    expect(find.text(QuizPlayScreen.yourAnswers), findsOneWidget);
    expect(find.textContaining('Right!'), findsNWidgets(5));

    await tapText(tester, '${QuizPlayScreen.nextLevelLabel}: Explorer');
    expect(find.text('Space: Explorer'), findsOneWidget);
    expect(find.text(QuizPlayScreen.questionLabel(1, 5)), findsOneWidget);
  });

  testWidgets('back on Quiz Time, stars show and the next level is open', (
    tester,
  ) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 4);
    await tapText(tester, QuizPlayScreen.backLabel);

    expect(find.text(QuizHubScreen.title), findsOneWidget);
    expect(find.text(QuizHubScreen.starsLabel(2, 90)), findsOneWidget);
    expect(find.text(QuizHubScreen.bestLabel(4, 5)), findsOneWidget);
    expect(find.text('Play again Starter'), findsOneWidget);
    expect(find.text('Play Explorer'), findsOneWidget);
  });

  testWidgets('not passing keeps the next level locked and encourages', (
    tester,
  ) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 2);

    expect(find.text(QuizPlayScreen.scoreLabel(2, 5)), findsOneWidget);
    expect(find.text(QuizPlayScreen.keepGoing('Starter')), findsOneWidget);
    expect(find.textContaining(QuizPlayScreen.nextLevelLabel), findsNothing);

    await tapText(tester, QuizPlayScreen.backLabel);
    expect(find.text('Play Explorer'), findsNothing);
  });

  testWidgets('Play again starts the same level fresh', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 1);

    await tapText(tester, QuizPlayScreen.playAgainLabel);

    expect(find.text(QuizPlayScreen.questionLabel(1, 5)), findsOneWidget);
    expect(find.text(QuizResultPanel.rightTitle), findsNothing);
  });

  testWidgets('results survive an app restart', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 3);

    await tester.pumpWidget(const SizedBox());
    await openQuiz(tester);

    expect(find.text(QuizHubScreen.bestLabel(3, 5)), findsOneWidget);
    expect(find.text('Play Explorer'), findsOneWidget);
    expect((await LocalProgressRepository(store).load()).quizBest, {
      'space_starter': 3,
    });
  });

  testWidgets('Home shows the quiz level in the explorer log', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 5);
    await tapText(tester, QuizPlayScreen.backLabel);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
    expect(find.text('1 quiz level done'), findsOneWidget);
  });

  testWidgets('Parent Zone shows quiz results, and reset deletes them', (
    tester,
  ) async {
    await LocalProgressRepository(store).save(
      LearnerProgress.empty
          .withQuizResult('space_starter', 4)
          .withQuizResult('body_starter', 3),
    );
    await startApp(tester);
    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('What is '));
    final m = RegExp(
      r'^What is ([a-z-]+) times ([a-z-]+)\?$',
    ).firstMatch(question)!;
    await tester.enterText(
      find.byType(TextField),
      '${wordsToNumber(m[1]!) * wordsToNumber(m[2]!)}',
    );
    await tapText(tester, ParentGateView.checkLabel);

    await tester.ensureVisible(find.text(DataOverviewSection.quizTitle));
    expect(
      find.text('2 levels played, 7 right answers at best'),
      findsOneWidget,
    );

    await tapText(tester, ParentZoneScreen.resetLabel);
    expect(
      find.text('Quiz Time results: 2 levels played, 7 right answers at best.'),
      findsOneWidget,
    );
    await tapText(tester, ResetExplainDialog.continueLabel);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    // "Delete progress" is also the section heading behind the dialog.
    await tester.tap(
      find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('0 levels played, 0 right answers at best'),
      findsOneWidget,
    );
    expect((await LocalProgressRepository(store).load()).quizBest, isEmpty);

    await tapText(tester, ParentZoneScreen.backToBuddy);
    await tapText(tester, HomeDestination.quiz.title);
    expect(find.text(QuizHubScreen.starsLabel(0, 90)), findsOneWidget);
    expect(find.text('Play Explorer'), findsNothing);
  });

  testWidgets('leaving a quiz mid-question stops Buddy at once', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    expect(tts.isSpeaking, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
    expect(find.text(QuizHubScreen.title), findsOneWidget);
  });

  testWidgets('Stop talking silences Buddy; the question stays', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    final q = current(space.levels.first);

    await tapText(tester, MissionVoiceBar.stopLabel);

    expect(tts.isSpeaking, isFalse);
    expect(find.text(q.prompt), findsOneWidget);
  });

  testWidgets('Read the answers reads them with their letters', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');

    await tapText(tester, QuizPlayScreen.readAnswersLabel);

    expect(tts.spoken.last, startsWith('A: '));
    expect(tts.spoken.last, contains('B: '));
  });

  testWidgets('with no speech engine, quizzes are fully playable', (
    tester,
  ) async {
    tts.available = false;
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    expect(find.text(QuizPlayScreen.readAnswersLabel), findsNothing);
    await playRound(tester, space.levels[0], 5);

    expect(tts.spoken, isEmpty);
    expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
  });

  testWidgets('quizzes never touch the microphone', (tester) async {
    await openQuiz(tester);
    await tapText(tester, 'Play Starter');
    await playRound(tester, space.levels[0], 3);

    expect(speech.totalCalls, 0);
  });
}
