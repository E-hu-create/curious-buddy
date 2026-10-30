import 'dart:io';

import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/core/widgets/motion.dart';
import 'package:curious_buddy/ui/creative/creature_screen.dart';
import 'package:curious_buddy/ui/discoveries/discoveries_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_screen.dart';
import 'package:curious_buddy/ui/quiz/widgets/quiz_widgets.dart';
import 'package:curious_buddy/ui/stories/story_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes.dart';
import '../../../testing/test_app.dart';

final _confetti = find.byType(ConfettiBurst);
final _space = starterQuizTopics.first;
final _forest = starterStories.first;

void main() {
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;

  setUp(() {
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
  });

  tearDown(() => voice.dispose());

  Widget app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

  Widget quiz() => app(
    QuizPlayScreen(
      topic: _space,
      level: _space.levels.first,
      voice: voice,
      progressRepository: LocalProgressRepository(store),
    ),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> playQuiz(WidgetTester tester, int rightCount) async {
    final level = _space.levels.first;
    for (var i = 0; i < level.questions.length; i++) {
      final q = level.questions.firstWhere(
        (q) => find.text(q.prompt).evaluate().isNotEmpty,
      );
      final option = i < rightCount
          ? q.answer
          : q.options.firstWhere((o) => o.id != q.answerId);
      await tapText(tester, option.text);
      await tapText(
        tester,
        i == level.questions.length - 1
            ? QuizPlayScreen.finishLabel
            : QuizPlayScreen.nextLabel,
      );
    }
  }

  group('celebrations come only at the right moments', () {
    testWidgets('a perfect quiz: confetti and a tap on the phone', (
      tester,
    ) async {
      usePhoneScreen(tester);
      var buzzes = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') buzzes++;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(quiz());
      await tester.pumpAndSettle();

      await playQuiz(tester, 5);

      expect(_confetti, findsOneWidget);
      expect(buzzes, 1);
    });

    testWidgets('a quiz with mistakes: no confetti', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(quiz());
      await tester.pumpAndSettle();

      await playQuiz(tester, 4);

      expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
      expect(_confetti, findsNothing);
    });

    testWidgets('a new story ending: confetti; one found before: none', (
      tester,
    ) async {
      usePhoneScreen(tester);
      const path = ['grey_morning', 'sparkling_stream', 'rainbow_mist'];
      Widget story(Set<String> found) => app(
        StoryPlayScreen(
          story: _forest,
          voice: voice,
          progressRepository: LocalProgressRepository(store),
          resumePath: path,
          foundEndingIds: found,
        ),
      );

      await tester.pumpWidget(story(const {}));
      await tester.pumpAndSettle();
      expect(_confetti, findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(story(const {'mist'}));
      await tester.pumpAndSettle();
      expect(_confetti, findsNothing);
    });

    testWidgets('saving a creation: confetti', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(
        app(
          CreatureScreen(
            voice: voice,
            creationsRepository: LocalCreationsRepository(store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_confetti, findsNothing);

      await tapText(tester, CreatureScreen.saveLabel);

      expect(_confetti, findsOneWidget);
    });

    testWidgets('a new rank while the journal is open: confetti', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await LocalProgressRepository(store).save(LearnerProgress.empty);
      await tester.pumpWidget(buildTestApp(store: store));
      await tester.pumpAndSettle();
      await tapText(tester, HomeDestination.discoveries.title);
      expect(_confetti, findsNothing);

      await tapText(tester, DiscoveriesScreen.openCreative);
      final creations = LocalCreationsRepository(store);
      for (var i = 0; i < 3; i++) {
        await creations.add((id) => Drawing(id: id, strokes: const []));
      }
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Keen Explorer'), findsOneWidget);
      expect(_confetti, findsOneWidget);
    });
  });

  testWidgets('confetti cannot be touched and screen readers skip it', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConfettiBurst()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.descendant(
        of: find.byType(ConfettiBurst),
        matching: find.byWidgetPredicate(
          (w) => w is IgnorePointer && w.ignoring,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ConfettiBurst),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle(); // ends by itself; nothing loops
  });

  group('with calm settings, nothing moves', () {
    testWidgets('the phone setting skips confetti and the phone tap', (
      tester,
    ) async {
      usePhoneScreen(tester);
      useReducedMotion(tester);
      var buzzes = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') buzzes++;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(quiz());
      await tester.pumpAndSettle();

      await playQuiz(tester, 5);

      expect(find.text(QuizPlayScreen.summaryTitle), findsOneWidget);
      expect(_confetti, findsNothing);
      expect(buzzes, 0);
    });

    Widget calm(Widget child) => MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: child,
      ),
    );

    testWidgets('PopIn, ReactOnce and StickerPress add no animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        calm(
          const Column(
            children: [
              PopIn(child: Text('a')),
              ReactOnce(
                active: true,
                kind: ReactionKind.shake,
                child: Text('b'),
              ),
              StickerPress(child: Text('c')),
            ],
          ),
        ),
      );

      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('PageSwap changes page at once', (tester) async {
      await tester.pumpWidget(
        calm(const PageSwap(pageKey: 1, child: Text('one'))),
      );
      await tester.pumpWidget(
        calm(const PageSwap(pageKey: 2, child: Text('two'))),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('two'), findsOneWidget);
      expect(find.text('one'), findsNothing);
    });

    testWidgets('page transitions show the page straight away', (tester) async {
      const page = Text('page');
      late Widget built;
      await tester.pumpWidget(
        calm(
          Builder(
            builder: (context) {
              built = const GentlePageTransitions().buildTransitions(
                MaterialPageRoute<void>(builder: (_) => const SizedBox()),
                context,
                const AlwaysStoppedAnimation(0.5),
                const AlwaysStoppedAnimation(0),
                page,
              );
              return built;
            },
          ),
        ),
      );

      expect(identical(built, page), isTrue);
    });
  });

  group('quiz stars', () {
    testWidgets('earned stars pop in one by one, and all arrive', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuizStars(stars: 2, animate: true)),
      );

      expect(find.byType(PopIn), findsNWidgets(2));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });
  });

  group('look and feel', () {
    test('the font is bundled, with its licence, and nothing downloads it', () {
      for (final name in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
        expect(File('assets/fonts/Nunito-$name.ttf').existsSync(), isTrue);
      }
      expect(
        File('assets/fonts/OFL.txt').readAsStringSync(),
        contains('SIL Open Font License'),
      );
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: Nunito'));
      expect(pubspec, contains('- assets/fonts/OFL.txt'));
      expect(pubspec, isNot(contains('google_fonts')));
      expect(
        AppTheme.light().textTheme.bodyLarge!.fontFamily,
        AppTheme.fontFamily,
      );
    });

    test('headings are bold, including page titles', () {
      final text = AppTheme.light().textTheme;
      expect(text.headlineSmall!.fontWeight, FontWeight.w800);
      expect(text.headlineMedium!.fontWeight, FontWeight.w800);
    });

    testWidgets('the last Home card fills its row on phones', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(store: store));
      await tester.pumpAndSettle();

      final last = find.text(HomeDestination.values.last.title);
      final first = find.text(HomeDestination.values.first.title);
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      double cardWidth(Finder text) => tester
          .getSize(
            find.ancestor(of: text, matching: find.byType(Expanded)).first,
          )
          .width;

      expect(cardWidth(last), greaterThan(cardWidth(first) * 1.5));
    });
  });
}
