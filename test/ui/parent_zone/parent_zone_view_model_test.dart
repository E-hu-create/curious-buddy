import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/settings/display_settings.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

/// Reads and writes work, but deleting fails (e.g. a storage error).
class _DeleteFailsStore extends InMemoryKeyValueStore {
  @override
  Future<void> delete(String key) async =>
      throw const FileSystemLikeException();
}

final _played = LearnerProgress.empty
    .withMissionResult('missing_moonstone', 120)
    .withMissionResult('wilting_garden', 90)
    .withStoryEnding('forest_colours', 'mist')
    .withStoryEnding('forest_colours', 'sunrise')
    .withStoryEnding('luma_signal', 'tow')
    .withStoryBookmark('tiny_inventor', ['big_idea', 'first_test']);

void main() {
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late BuddyListener listener;
  late DisplaySettings display;

  ParentZoneViewModel build([KeyValueStore? progressStore]) =>
      ParentZoneViewModel(
        progressRepository: LocalProgressRepository(progressStore ?? store),
        voice: voice,
        listener: listener,
        display: display,
      );

  setUp(() async {
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
    listener = BuddyListener(
      recognizer: FakeSpeechRecognitionService(),
      settings: store,
      voice: voice,
    );
    display = DisplaySettings(settings: store);
    await LocalProgressRepository(store).save(_played);
  });

  tearDown(() {
    listener.dispose();
    voice.dispose();
    display.dispose();
  });

  test('summarises exactly what is saved', () async {
    final vm = build();
    await vm.load();

    final s = vm.summary!;
    expect(vm.status, SummaryStatus.ready);
    expect(s.missionsSolved, 2);
    expect(s.missionPoints, 210);
    expect(s.storiesFinished, 2);
    expect(s.endingsFound, 3);
    expect(s.storiesInProgress, 1);
    expect(s.hasBackup, isFalse);
    vm.dispose();
  });

  test('reports a backup of unreadable progress', () async {
    await store.write(LocalProgressRepository.storageKey, '{not json');
    final vm = build();
    await vm.load();

    expect(vm.summary!.hasBackup, isTrue);
    expect(vm.summary!.missionsSolved, 0);
    vm.dispose();
  });

  test('a storage error shows an error, not empty progress', () async {
    final vm = ParentZoneViewModel(
      progressRepository: LocalProgressRepository(FailingKeyValueStore()),
      voice: voice,
      listener: listener,
      display: display,
    );
    await vm.load();

    expect(vm.status, SummaryStatus.error);
    expect(vm.summary, isNull);
    vm.dispose();
  });

  test('reset deletes every activity record and keeps settings', () async {
    await voice.setMuted(true);
    await voice.setSpeed(SpeechSpeed.slower);
    await listener.setAllowOnline(true);
    await display.setReduceMotion(true);
    await store.write(LocalProgressRepository.corruptBackupKey, 'old');
    final vm = build();
    await vm.load();

    await vm.reset(settingsToo: false);

    expect(vm.resetStatus, ResetStatus.done);
    expect(vm.summary!.isEmpty, isTrue);
    expect(await store.read(LocalProgressRepository.storageKey), isNull);
    expect(await store.read(LocalProgressRepository.corruptBackupKey), isNull);
    // Settings untouched.
    expect(voice.isMuted, isTrue);
    expect(voice.speed, SpeechSpeed.slower);
    expect(listener.allowOnline, isTrue);
    expect(display.reduceMotion, isTrue);
    expect(await store.read(BuddyVoice.mutedKey), 'true');
    vm.dispose();
  });

  test('reset with settings restores every default', () async {
    await voice.setMuted(true);
    await voice.setSpeed(SpeechSpeed.faster);
    await voice.setAutoRead(false);
    await listener.setAllowOnline(true);
    await display.setReduceMotion(true);
    final vm = build();
    await vm.load();

    await vm.reset(settingsToo: true);

    expect(vm.resetStatus, ResetStatus.done);
    expect(vm.lastResetIncludedSettings, isTrue);
    expect(voice.isMuted, isFalse);
    expect(voice.speed, SpeechSpeed.normal);
    expect(voice.autoRead, isTrue);
    expect(listener.allowOnline, isFalse);
    expect(display.reduceMotion, isFalse);
    expect(await store.read(BuddyListener.allowOnlineKey), 'false');
    vm.dispose();
  });

  test('after a reset, a fresh start finds nothing to restore', () async {
    final vm = build();
    await vm.load();
    await vm.reset(settingsToo: false);
    vm.dispose();

    expect(await LocalProgressRepository(store).load(), LearnerProgress.empty);
  });

  test('a failed delete is reported, never shown as done', () async {
    final failing = _DeleteFailsStore();
    await LocalProgressRepository(failing).save(_played);
    final vm = build(failing);
    await vm.load();

    await vm.reset(settingsToo: false);

    expect(vm.resetStatus, ResetStatus.failed);
    expect(vm.summary!.missionsSolved, 2, reason: 'shows what is still saved');
    vm.dispose();
  });
}
