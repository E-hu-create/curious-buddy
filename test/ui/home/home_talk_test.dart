import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/voice_failure.dart';
import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_screen.dart';
import 'package:curious_buddy/ui/home/talk_view_model.dart';
import 'package:curious_buddy/ui/home/widgets/ask_buddy_panel.dart';
import 'package:curious_buddy/ui/home/widgets/buddy_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
  });

  Future<void> openHome(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapTalk(WidgetTester tester) async {
    await tester.ensureVisible(find.text(AskBuddyPanel.talkLabel));
    await tester.tap(find.text(AskBuddyPanel.talkLabel));
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  group('never touches the microphone uninvited', () {
    testWidgets('launch and normal use make no recogniser calls', (
      tester,
    ) async {
      await openHome(tester);
      await tester.ensureVisible(find.text(HomeDestination.missions.title));
      await tester.tap(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(speech.totalCalls, 0);
    });
  });

  group('first time: explanation before the permission prompt', () {
    testWidgets('tapping Talk explains first and does not prompt yet', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      expect(find.text(HomeScreen.micTitle), findsOneWidget);
      expect(speech.permissionRequests, 0);
      expect(speech.listenCalls, 0);
    });

    testWidgets('"Not now" never prompts or listens', (tester) async {
      await openHome(tester);
      await tapTalk(tester);

      await tester.tap(find.text(HomeScreen.micNotNowLabel));
      await tester.pumpAndSettle();

      expect(find.text(HomeScreen.micTitle), findsNothing);
      expect(speech.permissionRequests, 0);
      expect(speech.listenCalls, 0);
    });

    testWidgets('OK asks Android once, then listens', (tester) async {
      await openHome(tester);
      await tapTalk(tester);

      await tester.tap(find.text(HomeScreen.micOkLabel));
      await tester.pumpAndSettle();

      expect(speech.permissionRequests, 1);
      expect(speech.listenCalls, 1);
    });

    testWidgets('denied: friendly notice, typing still works, no re-prompt', (
      tester,
    ) async {
      speech.grantOnRequest = false;
      await openHome(tester);
      await tapTalk(tester);
      await tester.tap(find.text(HomeScreen.micOkLabel));
      await tester.pumpAndSettle();

      expect(find.text(TalkViewModel.deniedNotice), findsOneWidget);
      expect(speech.listenCalls, 0);
      expect(speech.permissionRequests, 1);

      // Typing still works.
      await tester.enterText(find.byType(TextField), 'Are you human?');
      await tester.pump();
      await tester.tap(
        find.widgetWithText(FilledButton, AskBuddyPanel.askLabel),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('computer character'), findsOneWidget);
    });
  });

  group('listening', () {
    setUp(() {
      speech
        ..permission = MicrophonePermission.granted
        ..holdListening = true;
    });

    testWidgets('permission granted: no dialog, listening starts at once', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      expect(find.text(HomeScreen.micTitle), findsNothing);
      expect(speech.isListening, isTrue);
      expect(find.text(AskBuddyPanel.listeningLabel), findsWidgets);
      expect(find.text(BuddyStatus.listening.label), findsWidgets);
      expect(find.text(AskBuddyPanel.listeningPrompt), findsOneWidget);
    });

    testWidgets('Buddy stops talking before listening', (tester) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue); // welcome

      await tapTalk(tester);

      expect(tts.isSpeaking, isFalse);
      expect(speech.isListening, isTrue);
    });

    testWidgets('words appear live, then Buddy answers by itself', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      speech.hear('why is the');
      await tester.pump();
      expect(find.text('why is the'), findsOneWidget);

      speech
        ..hear('why is the sky blue')
        ..finish();
      await tester.pumpAndSettle();

      // No Ask tap needed, and the box stays empty for the next question.
      expect(find.textContaining('blue light'), findsOneWidget);
      expect(fieldText(tester), isEmpty);
      expect(tts.spoken.last, contains('blue light'));
    });

    testWidgets('spoken questions get the same safety replies', (tester) async {
      await openHome(tester);
      await tapTalk(tester);

      speech
        ..hear('my dad hits me')
        ..finish();
      await tester.pumpAndSettle();

      expect(
        find.textContaining(ChildSafetyFilter.unsafeResponse.text),
        findsOneWidget,
      );
      // Private words are not repeated on screen.
      expect(find.textContaining('my dad hits me'), findsNothing);
    });

    testWidgets('Done stops listening and Buddy answers', (tester) async {
      await openHome(tester);
      await tapTalk(tester);
      speech.hear('tell me an animal fact');
      await tester.pump();

      await tester.tap(find.text(AskBuddyPanel.doneLabel));
      await tester.pumpAndSettle();

      expect(speech.isListening, isFalse);
      expect(speech.stopCalls, 1);
      expect(tts.spoken, hasLength(2), reason: 'the welcome, then the answer');
    });

    testWidgets('Cancel stops listening and discards the words', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);
      speech.hear('oops never mind');
      await tester.pump();

      await tester.tap(find.text(AskBuddyPanel.cancelLabel));
      await tester.pumpAndSettle();

      expect(speech.isListening, isFalse);
      expect(fieldText(tester), isEmpty);
      expect(find.text(AskBuddyPanel.talkLabel), findsOneWidget);
    });

    testWidgets('"Hear again" is disabled so Buddy never talks over a child', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      final replay = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text(BuddyGreeting.replayLabel),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      expect(replay.onPressed, isNull);
      expect(tts.spoken, hasLength(1), reason: 'only the welcome');
    });

    testWidgets('typing and ideas are disabled while listening', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
      final idea = tester.widget<SuggestionButton>(
        find.byType(SuggestionButton).first,
      );
      expect(idea.onPressed, isNull);
    });

    testWidgets('navigating away cancels listening', (tester) async {
      await openHome(tester);
      await tapTalk(tester);
      expect(speech.isListening, isTrue);

      await tester.ensureVisible(find.text('Grown-ups'));
      await tester.tap(find.text('Grown-ups'));
      await tester.pumpAndSettle();

      expect(speech.isListening, isFalse);
      expect(speech.cancelCalls, 1);
    });

    testWidgets('an interruption (call, app switcher) cancels listening', (
      tester,
    ) async {
      await openHome(tester);
      await tapTalk(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();

      expect(speech.isListening, isFalse);
      expect(find.text(AskBuddyPanel.talkLabel), findsOneWidget);
    });

    testWidgets('closing the app cancels listening', (tester) async {
      await openHome(tester);
      await tapTalk(tester);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(speech.isListening, isFalse);
    });
  });

  group('outcomes', () {
    setUp(() => speech.permission = MicrophonePermission.granted);

    for (final (name, result, notice) in [
      (
        'nothing heard',
        const ListenNothingHeard(),
        TalkViewModel.nothingHeardNotice,
      ),
      (
        'network error',
        const ListenFailed(VoiceFailure.network),
        TalkViewModel.networkNotice,
      ),
      (
        'engine error',
        const ListenFailed(VoiceFailure.platformError),
        TalkViewModel.errorNotice,
      ),
    ]) {
      testWidgets('$name shows a friendly notice', (tester) async {
        speech.nextResult = result;
        await openHome(tester);
        await tapTalk(tester);

        expect(find.text(notice), findsOneWidget);
        expect(fieldText(tester), isEmpty);
        expect(find.text(AskBuddyPanel.talkLabel), findsOneWidget);
      });
    }

    testWidgets('no recogniser on this platform', (tester) async {
      speech.available = false;
      await openHome(tester);
      await tapTalk(tester);

      expect(find.text(TalkViewModel.unavailableNotice), findsOneWidget);
      expect(speech.permissionRequests, 0);
      expect(speech.listenCalls, 0);
    });
  });

  group('online recognition is a grown-up choice', () {
    setUp(() => speech.permission = MicrophonePermission.granted);

    testWidgets('off by default: listens on-device only', (tester) async {
      await openHome(tester);
      await tapTalk(tester);

      expect(speech.lastAllowOnline, isFalse);
    });

    testWidgets('no on-device recogniser: explains, points to grown-up', (
      tester,
    ) async {
      speech.onDevice = false;
      await openHome(tester);
      await tapTalk(tester);

      expect(find.text(TalkViewModel.offlineUnavailableNotice), findsOneWidget);
      expect(find.textContaining('Parent Zone'), findsWidgets);
    });

    testWidgets('allowed by a grown-up: listens with online allowed', (
      tester,
    ) async {
      speech.onDevice = false;
      await store.write(BuddyListener.allowOnlineKey, 'true');
      await openHome(tester);
      await tapTalk(tester);

      expect(speech.lastAllowOnline, isTrue);
      expect(find.textContaining('blue light'), findsOneWidget);
    });
  });
}
