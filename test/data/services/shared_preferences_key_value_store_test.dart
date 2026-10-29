import 'package:curious_buddy/app/app_dependencies.dart';
import 'package:curious_buddy/data/services/shared_preferences_key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    // The package's own in-memory stand-in for the phone's storage. It
    // outlives individual stores, like the real disk does.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('reads nothing before anything is saved', () async {
    expect(await SharedPreferencesKeyValueStore().read('voice.muted'), isNull);
  });

  test('saves, reads back and deletes', () async {
    final store = SharedPreferencesKeyValueStore();

    await store.write('voice.muted', 'true');
    expect(await store.read('voice.muted'), 'true');

    await store.delete('voice.muted');
    expect(await store.read('voice.muted'), isNull);
  });

  test('survives a "restart" (a new store instance)', () async {
    await SharedPreferencesKeyValueStore().write('progress', '{"a":1}');

    expect(await SharedPreferencesKeyValueStore().read('progress'), '{"a":1}');
  });

  test('keys do not interfere with each other', () async {
    final store = SharedPreferencesKeyValueStore();
    await store.write('voice.muted', 'true');
    await store.write('voice.allowOnlineRecognition', 'false');

    expect(await store.read('voice.muted'), 'true');
    expect(await store.read('voice.allowOnlineRecognition'), 'false');
  });

  test('does not touch storage until first use', () {
    var created = 0;
    SharedPreferencesKeyValueStore(
      create: () {
        created++;
        throw StateError('should not be created yet');
      },
    );

    expect(created, 0);
  });

  test('plugin errors become StorageException, not crashes', () async {
    final broken = SharedPreferencesKeyValueStore(
      create: () => throw StateError('no platform implementation'),
    );

    await expectLater(broken.read('x'), throwsA(isA<StorageException>()));
    await expectLater(broken.write('x', 'y'), throwsA(isA<StorageException>()));
    await expectLater(broken.delete('x'), throwsA(isA<StorageException>()));
  });

  test('the real app saves to the device, not memory', () {
    expect(
      AppDependencies.defaults().settingsStore,
      isA<SharedPreferencesKeyValueStore>(),
    );
  });
}
