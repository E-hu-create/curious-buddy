import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;

  HomeViewModel build({KeyValueStore? progressStore}) => HomeViewModel(
    progressRepository: LocalProgressRepository(progressStore ?? store),
    voice: voice,
  );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
  });

  tearDown(() => voice.dispose());

  test('starts loading with no progress', () {
    final viewModel = build();

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.progress, isNull);
  });

  test('load reads saved progress', () async {
    await LocalProgressRepository(
      store,
    ).save(const LearnerProgress(completedMissionIds: {'a', 'b'}));
    final viewModel = build();

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.progress?.completedMissionIds, {'a', 'b'});
  });

  test('storage failure leaves progress empty instead of throwing', () async {
    final viewModel = build(progressStore: FailingKeyValueStore());

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.progress, isNull);
  });

  test('load gives the welcome once, even if Home loads again', () async {
    await build().load();
    await voice.ready;
    await pumpEventQueue();
    await build().load();
    await pumpEventQueue();

    expect(tts.spoken, [HomeViewModel.greeting]);
  });

  // Replaying what Buddy last said moved to BuddyChatViewModel.replay
  // (see buddy_chat_view_model_test.dart).

  test('toggleMuted switches the voice off and on and notifies', () async {
    final viewModel = build();
    await voice.ready;
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.toggleMuted();
    expect(viewModel.isMuted, isTrue);
    expect(viewModel.canReplay, isFalse);

    await viewModel.toggleMuted();
    expect(viewModel.isMuted, isFalse);
    expect(viewModel.canReplay, isTrue);
    expect(notifications, 2);
  });

  test('reports an unavailable voice', () async {
    tts.available = false;
    final viewModel = build();
    await voice.ready;

    expect(viewModel.voiceStatus, VoiceStatus.unavailable);
    expect(viewModel.canReplay, isFalse);
  });

  test('stops listening to the voice when disposed', () async {
    final viewModel = build();
    await voice.ready;
    viewModel.dispose();

    // Would throw "used after dispose" if the listener were still attached.
    await voice.setMuted(true);
  });
}
