import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/shared_preferences_key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/home/widgets/buddy_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

/// "Restarting" = tearing the app down and building a fresh one with a new
/// store on the same (fake) device storage.
void main() {
  late FakeTextToSpeechService tts;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tts = FakeTextToSpeechService();
  });

  Future<void> startApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, store: SharedPreferencesKeyValueStore()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> restart(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    tts = FakeTextToSpeechService();
    await startApp(tester);
  }

  testWidgets('voice off is remembered after a restart', (tester) async {
    await startApp(tester);
    await tester.tap(find.text(BuddyGreeting.voiceOffLabel));
    await tester.pumpAndSettle();

    await restart(tester);

    expect(find.text(BuddyGreeting.voiceOnLabel), findsOneWidget);
    expect(tts.spoken, isEmpty, reason: 'no welcome while voice is off');
  });

  testWidgets('voice back on is remembered too', (tester) async {
    await startApp(tester);
    await tester.tap(find.text(BuddyGreeting.voiceOffLabel));
    await tester.pumpAndSettle();
    await restart(tester);
    await tester.tap(find.text(BuddyGreeting.voiceOnLabel));
    await tester.pumpAndSettle();

    await restart(tester);

    expect(find.text(BuddyGreeting.voiceOffLabel), findsOneWidget);
    expect(tts.spoken, hasLength(1), reason: 'welcome plays again');
  });

  testWidgets('saved progress is shown after a restart', (tester) async {
    await LocalProgressRepository(
      SharedPreferencesKeyValueStore(),
    ).save(const LearnerProgress(completedMissionIds: {'m1', 'm2', 'm3'}));

    await startApp(tester);

    expect(find.text('3 missions solved'), findsOneWidget);
  });

  test('the grown-up online setting is remembered', () async {
    final voice = FakeTextToSpeechService();
    final first = BuddyListener(
      recognizer: FakeSpeechRecognitionService(),
      settings: SharedPreferencesKeyValueStore(),
      voice: _voice(voice),
    );
    await first.setAllowOnline(true);
    first.dispose();

    final second = BuddyListener(
      recognizer: FakeSpeechRecognitionService(),
      settings: SharedPreferencesKeyValueStore(),
      voice: _voice(voice),
    );
    await second.ready;

    expect(second.allowOnline, isTrue);
    second.dispose();
  });
}

BuddyVoice _voice(FakeTextToSpeechService tts) =>
    BuddyVoice(textToSpeech: tts, settings: SharedPreferencesKeyValueStore());
