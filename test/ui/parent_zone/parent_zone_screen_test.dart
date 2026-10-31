import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/settings/display_settings.dart';
import 'package:curious_buddy/domain/stories/more_stories.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/missions/missions_screen.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_settings.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

/// Reads a number written in words, as a grown-up would ("twenty-four").
int wordsToNumber(String words) {
  const units = {
    'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, //
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11,
    'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
    'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
    'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
    'seventy': 70, 'eighty': 80, 'ninety': 90,
  };
  return words.split('-').fold(0, (sum, w) => sum + units[w]!);
}

final _played = LearnerProgress.empty
    .withMissionResult('missing_moonstone', 120)
    .withStoryEnding('forest_colours', 'mist')
    .withStoryEnding('forest_colours', 'sunrise')
    .withStoryBookmark('luma_signal', ['beep_in_the_dark', 'glow_ridge']);

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
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> startApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openParentZone(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
  }

  String question(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((t) => t.startsWith('What is '));

  int rightAnswer(WidgetTester tester) {
    final m = RegExp(
      r'^What is ([a-z-]+) times ([a-z-]+)\?$',
    ).firstMatch(question(tester))!;
    return wordsToNumber(m[1]!) * wordsToNumber(m[2]!);
  }

  Future<void> answer(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    await tapText(tester, ParentGateView.checkLabel);
  }

  Future<void> unlock(WidgetTester tester) async {
    await openParentZone(tester);
    await answer(tester, '${rightAnswer(tester)}');
  }

  Future<void> resetProgress(
    WidgetTester tester, {
    bool settingsToo = false,
  }) async {
    await tapText(tester, ParentZoneScreen.resetLabel);
    if (settingsToo) await tapText(tester, ResetExplainDialog.settingsToo);
    await tapText(tester, ResetExplainDialog.continueLabel);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    await tapText(tester, ResetConfirmDialog.deleteLabel);
  }

  group('parent check', () {
    testWidgets('settings are hidden until the check is passed', (
      tester,
    ) async {
      await startApp(tester);
      await openParentZone(tester);

      expect(find.text(ParentGateView.purpose), findsOneWidget);
      expect(find.text(ParentGateView.about), findsOneWidget);
      expect(question(tester), matches(RegExp(r'^What is [a-z-]+ times')));
      expect(find.text(VoiceSettingsSection.title), findsNothing);
      expect(find.text(DataOverviewSection.title), findsNothing);
      // Only one field, for the answer: nothing personal is asked.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a wrong answer keeps it locked and says so', (tester) async {
      await startApp(tester);
      await openParentZone(tester);

      await answer(tester, '${rightAnswer(tester) + 1}');

      expect(find.textContaining(ParentGateView.wrongAnswer), findsOneWidget);
      expect(find.textContaining('2 tries left'), findsOneWidget);
      expect(find.text(VoiceSettingsSection.title), findsNothing);
      expect(question(tester), startsWith('What is '));
    });

    testWidgets('three wrong answers pause the check, even after reopening', (
      tester,
    ) async {
      await startApp(tester);
      await openParentZone(tester);
      for (var i = 0; i < 3; i++) {
        await answer(tester, '1');
      }

      expect(find.textContaining('Too many wrong answers'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tapText(tester, ParentZoneScreen.backToBuddy);
      await openParentZone(tester);
      expect(find.textContaining('Too many wrong answers'), findsOneWidget);
      await tester.pumpWidget(const SizedBox()); // stop the countdown timer
    });

    testWidgets('the right answer opens the Parent Zone', (tester) async {
      await startApp(tester);
      await unlock(tester);

      expect(find.text(VoiceSettingsSection.title), findsOneWidget);
      expect(find.text(ListeningSettingsSection.title), findsOneWidget);
      expect(find.text(DisplaySettingsSection.title), findsOneWidget);
      await tester.ensureVisible(find.text(DataOverviewSection.title));
      expect(find.text(DataOverviewSection.title), findsOneWidget);
    });

    testWidgets('the check is asked again every time', (tester) async {
      await startApp(tester);
      await unlock(tester);
      await tapText(tester, ParentZoneScreen.backToBuddy);

      await openParentZone(tester);

      expect(find.text(VoiceSettingsSection.title), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('it locks again when the app is hidden', (tester) async {
      await startApp(tester);
      await unlock(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text(VoiceSettingsSection.title), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets("Back to Buddy returns to the child's Home", (tester) async {
      await startApp(tester);
      await openParentZone(tester);

      await tapText(tester, ParentZoneScreen.backToBuddy);

      expect(find.text(HomeViewModel.greeting), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('voice settings apply at once and are saved', (tester) async {
      await startApp(tester);
      await unlock(tester);

      await tapText(tester, VoiceSettingsSection.talksTitle);
      await tapText(tester, 'Slower');
      await tapText(tester, VoiceSettingsSection.autoReadTitle);
      await tapText(tester, VoiceSettingsSection.soundsTitle);

      expect(await store.read(BuddyVoice.soundsKey), 'false');
      expect(await store.read(BuddyVoice.mutedKey), 'true');
      expect(await store.read(BuddyVoice.speedKey), 'slower');
      expect(await store.read(BuddyVoice.autoReadKey), 'false');
      expect(tts.speed, SpeechSpeed.slower);
    });

    testWidgets('online recognition is off by default and explained', (
      tester,
    ) async {
      speech.onDevice = false;
      await startApp(tester);
      await unlock(tester);

      final online = find.widgetWithText(
        SwitchListTile,
        ListeningSettingsSection.onlineTitle,
      );
      expect(tester.widget<SwitchListTile>(online).value, isFalse);
      expect(find.textContaining('may send the audio'), findsOneWidget);
      expect(find.textContaining('not on-device'), findsOneWidget);
      expect(
        find.text(ListeningSettingsSection.onDeviceUnavailable),
        findsOneWidget,
      );

      await tapText(tester, ListeningSettingsSection.onlineTitle);
      expect(await store.read(BuddyListener.allowOnlineKey), 'true');
    });

    testWidgets('calmer animations are saved and applied app-wide', (
      tester,
    ) async {
      await startApp(tester);
      await unlock(tester);

      await tapText(tester, DisplaySettingsSection.motionTitle);

      expect(await store.read(DisplaySettings.reduceMotionKey), 'true');
      final context = tester.element(find.text(ParentZoneScreen.title));
      expect(MediaQuery.disableAnimationsOf(context), isTrue);
    });

    testWidgets('settings survive an app restart', (tester) async {
      await startApp(tester);
      await unlock(tester);
      await tapText(tester, 'Faster');
      await tapText(tester, DisplaySettingsSection.motionTitle);
      await tapText(tester, ListeningSettingsSection.onlineTitle);

      await tester.pumpWidget(const SizedBox());
      await startApp(tester);
      await unlock(tester);

      final speed = tester.widget<SegmentedButton<SpeechSpeed>>(
        find.byType(SegmentedButton<SpeechSpeed>),
      );
      expect(speed.selected, {SpeechSpeed.faster});
      bool switchValue(String title) => tester
          .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
          .value;
      expect(switchValue(DisplaySettingsSection.motionTitle), isTrue);
      expect(switchValue(ListeningSettingsSection.onlineTitle), isTrue);
    });

    testWidgets('with automatic reading off, Buddy waits to be asked', (
      tester,
    ) async {
      await startApp(tester);
      await unlock(tester);
      await tapText(tester, VoiceSettingsSection.autoReadTitle);
      await tapText(tester, ParentZoneScreen.backToBuddy);
      await tapText(tester, HomeDestination.stories.title);
      final spokenBefore = tts.spoken.length;

      await tapText(tester, StoriesScreen.startLabel);

      expect(tts.spoken.length, spokenBefore, reason: 'intro not read');
      await tapText(tester, 'Hear again');
      expect(tts.spoken.length, spokenBefore + 1);
    });

    testWidgets('the Parent Zone never asks for the microphone', (
      tester,
    ) async {
      await startApp(tester);
      await unlock(tester);

      expect(speech.permissionRequests, 0);
    });
  });

  group('saved-data overview', () {
    testWidgets('shows what is really saved, read from storage', (
      tester,
    ) async {
      await LocalProgressRepository(store).save(_played);
      await startApp(tester);
      await unlock(tester);
      await tester.ensureVisible(find.text(DataOverviewSection.missionsTitle));

      expect(find.text('1 case solved, 120 points'), findsOneWidget);
      expect(find.text('1 story finished, 2 endings found'), findsOneWidget);
      expect(find.text('1 story in progress'), findsOneWidget);
      expect(find.text('None'), findsOneWidget); // no backup
      expect(
        find.textContaining('Voice on, normal speed, reads automatically'),
        findsOneWidget,
      );
      expect(find.text(DataOverviewSection.memoryTitle), findsOneWidget);
      expect(find.text(DataOverviewSection.sentTitle), findsOneWidget);
    });
  });

  group('reset', () {
    testWidgets('step 1 lists exactly what will be deleted and kept', (
      tester,
    ) async {
      await LocalProgressRepository(store).save(_played);
      await startApp(tester);
      await unlock(tester);

      await tapText(tester, ParentZoneScreen.resetLabel);

      expect(find.text(ResetExplainDialog.title), findsOneWidget);
      expect(
        find.text('Mystery Missions results: 1 case solved, 120 points.'),
        findsOneWidget,
      );
      expect(
        find.text('Living Stories: 1 story finished, 2 endings found.'),
        findsOneWidget,
      );
      expect(
        find.text('Place in unfinished stories: 1 story in progress.'),
        findsOneWidget,
      );
      expect(find.text(ResetExplainDialog.keeps.first), findsOneWidget);
      expect(find.text(ResetExplainDialog.cannotUndo), findsOneWidget);
    });

    testWidgets('cancelling at either step deletes nothing', (tester) async {
      await LocalProgressRepository(store).save(_played);
      await startApp(tester);
      await unlock(tester);

      await tapText(tester, ParentZoneScreen.resetLabel);
      await tapText(tester, ResetExplainDialog.cancelLabel);
      expect(await LocalProgressRepository(store).load(), _played);

      await tapText(tester, ParentZoneScreen.resetLabel);
      await tapText(tester, ResetExplainDialog.continueLabel);
      await tapText(tester, ResetConfirmDialog.cancelLabel);
      expect(await LocalProgressRepository(store).load(), _played);
    });

    testWidgets('Delete stays disabled until DELETE is typed', (tester) async {
      await startApp(tester);
      await unlock(tester);
      await tapText(tester, ParentZoneScreen.resetLabel);
      await tapText(tester, ResetExplainDialog.continueLabel);

      FilledButton deleteButton() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
      );
      expect(deleteButton().onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'DEL');
      await tester.pumpAndSettle();
      expect(deleteButton().onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'delete');
      await tester.pumpAndSettle();
      expect(deleteButton().onPressed, isNotNull);
    });

    testWidgets('confirming deletes all progress and keeps settings', (
      tester,
    ) async {
      await LocalProgressRepository(store).save(_played);
      await store.write(LocalProgressRepository.corruptBackupKey, 'old');
      await store.write(BuddyListener.allowOnlineKey, 'true');
      await startApp(tester);
      await unlock(tester);

      await resetProgress(tester);

      expect(find.text(ParentZoneScreen.resetDone), findsOneWidget);
      expect(find.text(ParentZoneScreen.resetDoneSettings), findsNothing);
      expect(find.text('0 cases solved, 0 points'), findsOneWidget);
      expect(find.text('0 stories finished, 0 endings found'), findsOneWidget);
      expect(find.text('0 stories in progress'), findsOneWidget);
      expect(await store.read(LocalProgressRepository.storageKey), isNull);
      expect(
        await store.read(LocalProgressRepository.corruptBackupKey),
        isNull,
      );
      expect(await store.read(BuddyListener.allowOnlineKey), 'true');
    });

    testWidgets('ticking the box restores default settings too', (
      tester,
    ) async {
      await store.write(BuddyVoice.mutedKey, 'true');
      await store.write(BuddyVoice.speedKey, 'faster');
      await store.write(BuddyListener.allowOnlineKey, 'true');
      await store.write(DisplaySettings.reduceMotionKey, 'true');
      await startApp(tester);
      await unlock(tester);

      await resetProgress(tester, settingsToo: true);

      expect(find.text(ParentZoneScreen.resetDoneSettings), findsOneWidget);
      expect(await store.read(BuddyVoice.mutedKey), 'false');
      expect(await store.read(BuddyVoice.speedKey), 'normal');
      expect(await store.read(BuddyListener.allowOnlineKey), 'false');
      expect(await store.read(DisplaySettings.reduceMotionKey), 'false');
    });

    testWidgets('Home, missions and stories show the cleared progress', (
      tester,
    ) async {
      await LocalProgressRepository(store).save(_played);
      await startApp(tester);
      expect(find.text('1 mission solved'), findsOneWidget);

      await unlock(tester);
      await resetProgress(tester);
      await tapText(tester, ParentZoneScreen.backToBuddy);

      expect(find.text('0 missions solved'), findsOneWidget);
      expect(find.text('0 stories finished'), findsOneWidget);

      await tapText(tester, HomeDestination.missions.title);
      expect(find.text(MissionsScreen.solvedLabel), findsNothing);
      expect(
        find.text(MissionsScreen.playLabel),
        findsNWidgets(allMissions.length),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapText(tester, HomeDestination.stories.title);
      expect(find.text(StoriesScreen.continueLabel), findsNothing);
      expect(
        find.text(StoriesScreen.startLabel),
        findsNWidgets(allStories.length),
      );
      expect(
        find.text(
          StoriesScreen.endingsLabel(
            0,
            allStories.expand((s) => s.endings).length,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reopening the app does not bring deleted progress back', (
      tester,
    ) async {
      await LocalProgressRepository(store).save(_played);
      await startApp(tester);
      await unlock(tester);
      await resetProgress(tester);

      await tester.pumpWidget(const SizedBox());
      await startApp(tester);

      expect(find.text('0 missions solved'), findsOneWidget);
      expect(
        await LocalProgressRepository(store).load(),
        LearnerProgress.empty,
      );
    });

    testWidgets('a storage failure is reported honestly', (tester) async {
      final failing = _DeleteFailsStore();
      await LocalProgressRepository(failing).save(_played);
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(tts: tts, store: failing));
      await tester.pumpAndSettle();
      await unlock(tester);

      await resetProgress(tester);

      expect(find.text(ParentZoneScreen.resetFailed), findsOneWidget);
      expect(find.text(ParentZoneScreen.resetDone), findsNothing);
      expect(find.text('1 case solved, 120 points'), findsOneWidget);
    });
  });
}

class _DeleteFailsStore extends InMemoryKeyValueStore {
  @override
  Future<void> delete(String key) async =>
      throw const FileSystemLikeException();
}
