import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// Storage failed (plugin missing, disk error, corrupt store).
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => 'StorageException: $message';
}

/// [KeyValueStore] saved on the device with `shared_preferences`
/// (Android DataStore). Survives app restarts; deleted when the app is
/// uninstalled. Android cloud backup is off (`android:allowBackup="false"`),
/// and data-extraction rules ask Android to leave it out of phone-to-phone
/// transfers, though some phone makers may not honour that.
///
/// Every failure surfaces as a [StorageException], including plugin
/// *errors* (e.g. no platform implementation), so callers' existing
/// `on Exception` handling covers it and a child's session never gets stuck.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore({
    SharedPreferencesAsync Function() create = SharedPreferencesAsync.new,
  }) : _create = create;

  final SharedPreferencesAsync Function() _create;

  /// Created on first use, like the other plugins, so nothing touches the
  /// platform before the Flutter binding exists.
  late final SharedPreferencesAsync _prefs = _create();

  @override
  Future<String?> read(String key) => _guard(() => _prefs.getString(key));

  @override
  Future<void> write(String key, String value) =>
      _guard(() => _prefs.setString(key, value));

  @override
  Future<void> delete(String key) => _guard(() => _prefs.remove(key));

  static Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Exception catch (error) {
      throw StorageException(error.toString());
    } on Error catch (error) {
      // Plugin errors (e.g. missing implementation) must not escape as
      // Errors that callers do not expect.
      throw StorageException(error.toString());
    }
  }
}
