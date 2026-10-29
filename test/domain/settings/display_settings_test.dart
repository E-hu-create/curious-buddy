import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/settings/display_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  test('calmer animations are off by default', () async {
    final display = DisplaySettings(settings: InMemoryKeyValueStore());
    await display.ready;

    expect(display.reduceMotion, isFalse);
    display.dispose();
  });

  test('the setting is saved and restored', () async {
    final store = InMemoryKeyValueStore();
    final display = DisplaySettings(settings: store);
    await display.setReduceMotion(true);
    expect(await store.read(DisplaySettings.reduceMotionKey), 'true');
    display.dispose();

    final again = DisplaySettings(settings: store);
    await again.ready;
    expect(again.reduceMotion, isTrue);
    again.dispose();
  });

  test(
    'a storage failure falls back to off and still applies changes',
    () async {
      final display = DisplaySettings(settings: FailingKeyValueStore());
      await display.ready;
      expect(display.reduceMotion, isFalse);

      await display.setReduceMotion(true);
      expect(display.reduceMotion, isTrue);
      display.dispose();
    },
  );
}
