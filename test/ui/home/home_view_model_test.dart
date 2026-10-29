import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;

  HomeViewModel build({KeyValueStore? withStore}) => HomeViewModel(
    progressRepository: LocalProgressRepository(withStore ?? store),
    textToSpeech: tts,
  );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
  });

  test('starts loading with no progress and no speech', () {
    final viewModel = build();

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.progress, isNull);
    expect(viewModel.canSpeak, isFalse);
  });

  test('load reads saved progress and notifies once', () async {
    await LocalProgressRepository(
      store,
    ).save(const LearnerProgress(completedMissionIds: {'a', 'b'}));
    final viewModel = build();
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.progress?.completedMissionIds, {'a', 'b'});
    expect(notifications, 1);
  });

  test('storage failure leaves progress empty instead of throwing', () async {
    final viewModel = build(withStore: FailingKeyValueStore());

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.progress, isNull);
  });

  test('canSpeak follows speech availability', () async {
    tts.available = false;
    final silent = build();
    await silent.load();
    expect(silent.canSpeak, isFalse);

    tts.available = true;
    final speaking = build();
    await speaking.load();
    expect(speaking.canSpeak, isTrue);
  });

  test('loading never speaks; speakGreeting does', () async {
    final viewModel = build();

    await viewModel.load();
    expect(tts.spoken, isEmpty);

    await viewModel.speakGreeting();
    expect(tts.spoken, [HomeViewModel.greeting]);
  });

  test('load after dispose does not notify', () async {
    final viewModel = build();
    final pending = viewModel.load();
    viewModel.dispose();

    await expectLater(pending, completes);
  });
}
