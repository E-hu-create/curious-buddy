import 'dart:async';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/home/widgets/buddy_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const greeting = HomeViewModel.greeting;

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
  });

  Future<void> openHome(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, store: store));
    await tester.pumpAndSettle();
  }

  Future<void> openAndReturn(WidgetTester tester, String title) async {
    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  group('welcome', () {
    testWidgets('is spoken once when the app opens', (tester) async {
      await openHome(tester);

      expect(tts.spoken, [greeting]);
      expect(find.text(greeting), findsOneWidget);
    });

    testWidgets('is not repeated after navigating away and back', (
      tester,
    ) async {
      await openHome(tester);

      await openAndReturn(tester, HomeDestination.missions.title);
      await openAndReturn(tester, HomeDestination.stories.title);
      await openAndReturn(tester, 'Grown-ups');

      expect(tts.spoken, [greeting]);
    });

    testWidgets('is not repeated when the app is resumed', (tester) async {
      await openHome(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(tts.spoken, [greeting]);
    });

    testWidgets('is not spoken when the voice was turned off before', (
      tester,
    ) async {
      await store.write(BuddyVoice.mutedKey, 'true');
      await openHome(tester);

      expect(tts.spoken, isEmpty);
      expect(find.text(BuddyGreeting.voiceOnLabel), findsOneWidget);
    });
  });

  group('replay', () {
    testWidgets('"Hear again" speaks the greeting again, every tap', (
      tester,
    ) async {
      await openHome(tester);

      await tester.tap(find.text(BuddyGreeting.replayLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(BuddyGreeting.replayLabel));
      await tester.pumpAndSettle();

      expect(tts.spoken, [greeting, greeting, greeting]);
    });

    testWidgets('while talking, "Stop talking" replaces "Hear again"', (
      tester,
    ) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue);
      expect(find.text(BuddyGreeting.stopLabel), findsOneWidget);
      expect(find.text(BuddyGreeting.replayLabel), findsNothing);

      await tester.tap(find.text(BuddyGreeting.stopLabel));
      await tester.pumpAndSettle();

      expect(tts.isSpeaking, isFalse);
      expect(find.text(BuddyGreeting.stopLabel), findsNothing);

      await tester.tap(find.text(BuddyGreeting.replayLabel));
      await tester.pumpAndSettle();
      expect(tts.spoken, [greeting, greeting]);
      expect(find.text(BuddyGreeting.stopLabel), findsOneWidget);
      tts.finishSpeaking();
      await tester.pumpAndSettle();
      expect(find.text(BuddyGreeting.replayLabel), findsOneWidget);
    });
  });

  group('mute', () {
    testWidgets('"Voice off" stops speech and hides "Hear again"', (
      tester,
    ) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue);

      await tester.tap(find.text(BuddyGreeting.voiceOffLabel));
      await tester.pumpAndSettle();

      expect(tts.isSpeaking, isFalse);
      expect(find.text(BuddyGreeting.replayLabel), findsNothing);
      expect(find.text(BuddyGreeting.voiceOnLabel), findsOneWidget);
    });

    testWidgets('"Voice on" brings back replay without speaking by itself', (
      tester,
    ) async {
      await openHome(tester);
      await tester.tap(find.text(BuddyGreeting.voiceOffLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.text(BuddyGreeting.voiceOnLabel));
      await tester.pumpAndSettle();

      expect(tts.spoken, [greeting]);
      expect(find.text(BuddyGreeting.replayLabel), findsOneWidget);
    });

    testWidgets('stays off after visiting other screens', (tester) async {
      await openHome(tester);
      await tester.tap(find.text(BuddyGreeting.voiceOffLabel));
      await tester.pumpAndSettle();

      await openAndReturn(tester, HomeDestination.creative.title);

      expect(find.text(BuddyGreeting.voiceOnLabel), findsOneWidget);
      expect(await store.read(BuddyVoice.mutedKey), 'true');
    });
  });

  group('cleanup', () {
    testWidgets('speech stops when opening another screen', (tester) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue);

      await tester.ensureVisible(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();

      expect(tts.isSpeaking, isFalse);
    });

    testWidgets('speech stops when going back to Home', (tester) async {
      await openHome(tester);
      await tester.ensureVisible(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      final stopsBefore = tts.stopCalls;

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(tts.stopCalls, greaterThan(stopsBefore));
    });

    testWidgets('speech stops when the app is hidden or interrupted', (
      tester,
    ) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(tts.isSpeaking, isFalse);
    });

    testWidgets('speech stops when the app is closed', (tester) async {
      tts.holdSpeech = true;
      await openHome(tester);
      expect(tts.isSpeaking, isTrue);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(tts.isSpeaking, isFalse);
    });

    testWidgets('a welcome still loading never plays on another screen', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final slow = SlowStartTextToSpeechService();
      await tester.pumpWidget(buildTestApp(tts: slow, store: store));
      await tester.pump();

      // Child taps a card before the engine has finished starting.
      await tester.ensureVisible(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      slow.finishStarting();
      await tester.pumpAndSettle();

      expect(slow.spoken, isEmpty);
    });
  });

  group('fallback', () {
    testWidgets('no speech engine: read-along note, no voice buttons', (
      tester,
    ) async {
      tts.available = false;
      await openHome(tester);

      expect(find.text(greeting), findsOneWidget);
      expect(find.text(BuddyGreeting.unavailableMessage), findsOneWidget);
      expect(find.text(BuddyGreeting.replayLabel), findsNothing);
      expect(find.text(BuddyGreeting.voiceOffLabel), findsNothing);
      expect(tts.spoken, isEmpty);
    });

    testWidgets('engine error while speaking keeps Home usable', (
      tester,
    ) async {
      tts.throwOnSpeak = Exception('engine crashed');
      await openHome(tester);

      expect(tester.takeException(), isNull);
      await tester.tap(find.text(BuddyGreeting.replayLabel));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HomeDestination.missions.title));
      await tester.pumpAndSettle();

      expect(find.text(HomeDestination.missions.comingSoonMessage), findsOne);
    });
  });
}

/// An engine that takes a while to start, like a cold TTS engine on a phone.
class SlowStartTextToSpeechService extends FakeTextToSpeechService {
  final _started = Completer<bool>();

  void finishStarting() => _started.complete(true);

  @override
  Future<bool> isAvailable() => _started.future;
}
