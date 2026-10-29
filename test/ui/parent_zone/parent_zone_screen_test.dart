import 'dart:math';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

/// Always "rolls" 0, so the question is always 6 × 6.
class FixedRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late BuddyListener listener;

  setUp(() {
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
    listener = BuddyListener(recognizer: speech, settings: store, voice: voice);
  });

  tearDown(() {
    listener.dispose();
    voice.dispose();
  });

  Future<void> open(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ParentZoneScreen(listener: listener, random: FixedRandom()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> answer(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    await tester.tap(find.text(ParentZoneScreen.checkLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('settings are hidden behind the parent check', (tester) async {
    await open(tester);

    expect(find.text('What is 6 × 6?'), findsOneWidget);
    expect(find.text(ParentZoneScreen.onlineTitle), findsNothing);
  });

  testWidgets('a wrong answer keeps settings locked', (tester) async {
    await open(tester);

    await answer(tester, '12');

    expect(find.text(ParentZoneScreen.wrongAnswer), findsOneWidget);
    expect(find.text(ParentZoneScreen.onlineTitle), findsNothing);
  });

  testWidgets('the right answer shows the online setting, off by default', (
    tester,
  ) async {
    await open(tester);

    await answer(tester, '36');

    expect(find.text(ParentZoneScreen.onlineTitle), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.textContaining('may send the audio'), findsOneWidget);
  });

  testWidgets('turning it on is applied and saved', (tester) async {
    await open(tester);
    await answer(tester, '36');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(listener.allowOnline, isTrue);
    expect(await store.read(BuddyListener.allowOnlineKey), 'true');
  });

  testWidgets('shows whether this phone recognises speech on-device', (
    tester,
  ) async {
    speech.onDevice = false;
    await open(tester);
    await answer(tester, '36');

    expect(find.text(ParentZoneScreen.onDeviceUnavailable), findsOneWidget);
    expect(speech.permissionRequests, 0, reason: 'never prompts here');
  });

  testWidgets('reached from Home via Grown-ups, gate asked every time', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(speech: speech));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    expect(find.text(ParentZoneScreen.gateIntro), findsOneWidget);
  });
}
