import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/data/services/voice/voice_failure.dart';
import 'package:curious_buddy/domain/voice/narrator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late Narrator narrator;

  setUp(() {
    tts = FakeTextToSpeechService();
    narrator = Narrator(tts);
  });

  test('speaks text when voice is available', () async {
    expect(await narrator.narrate('Hello!'), NarrationOutcome.spoken);
    expect(tts.spoken, ['Hello!']);
  });

  test('stops current playback before starting new narration', () async {
    await narrator.narrate('First');
    await narrator.narrate('Second');

    expect(tts.stopCalls, 2);
    expect(tts.spoken, ['First', 'Second']);
  });

  test('falls back to text only when no voice is available', () async {
    tts.available = false;

    expect(await narrator.narrate('Hello!'), NarrationOutcome.textOnly);
    expect(tts.spoken, isEmpty);
  });

  test('falls back to text only when the engine fails', () async {
    tts.nextResult = const SpeakFailed(VoiceFailure.voiceNotInstalled);

    expect(await narrator.narrate('Hello!'), NarrationOutcome.textOnly);
  });

  test('falls back to text only when the engine throws', () async {
    tts.throwOnSpeak = Exception('plugin crashed');

    expect(await narrator.narrate('Hello!'), NarrationOutcome.textOnly);
  });

  test('reports interruptions', () async {
    tts.nextResult = const SpeakInterrupted();

    expect(await narrator.narrate('Hello!'), NarrationOutcome.interrupted);
  });

  test('replays the last line', () async {
    await narrator.narrate('Look up!');

    expect(await narrator.replay(), NarrationOutcome.spoken);
    expect(tts.spoken, ['Look up!', 'Look up!']);
  });

  test('replay with nothing narrated yet does nothing', () async {
    expect(await narrator.replay(), NarrationOutcome.nothingToReplay);
    expect(tts.spoken, isEmpty);
  });

  test('unavailable default service never claims to speak', () async {
    final outcome = await Narrator(
      const UnavailableTextToSpeechService(),
    ).narrate('Hello!');

    expect(outcome, NarrationOutcome.textOnly);
  });
}
