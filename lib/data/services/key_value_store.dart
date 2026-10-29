/// Minimal local string storage. Repositories depend on this, not on a
/// storage package, so the backing store can change without touching
/// feature code.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Non-persistent store. Data is lost when the app closes.
///
/// Used until a persistent implementation (e.g. shared_preferences) is
/// approved and added; see docs/DEPENDENCIES.md.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
