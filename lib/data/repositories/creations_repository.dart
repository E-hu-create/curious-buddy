import 'dart:convert';

import '../../domain/creative/creation.dart';
import '../../domain/creative/creation_shelf.dart';
import '../services/key_value_store.dart';

/// The shelf is full; remove a creation before saving a new one.
class CreationsFullException implements Exception {
  const CreationsFullException();
}

/// Creative Island creations, saved on this phone only.
abstract interface class CreationsRepository {
  /// Saved creations, or an empty shelf if none or unreadable. Storage
  /// failures are rethrown so a temporary error is never mistaken for an
  /// empty shelf and saved over.
  Future<CreationShelf> load();

  /// Adds a new creation and returns it with its id. Throws
  /// [CreationsFullException] when the shelf is full.
  Future<Creation> add(Creation Function(String id) create);

  Future<void> remove(String id);

  /// Deletes every creation, including any backup of unreadable data.
  Future<void> clear();

  Future<bool> hasCorruptBackup();
}

class LocalCreationsRepository implements CreationsRepository {
  LocalCreationsRepository(this._store);

  static const storageKey = 'creations';

  /// Unreadable data is copied here before being replaced, so a child's
  /// work is never silently lost.
  static const corruptBackupKey = 'creations.corrupt_backup';

  final KeyValueStore _store;

  @override
  Future<CreationShelf> load() async {
    final raw = await _store.read(storageKey);
    if (raw == null) return CreationShelf.empty;
    CreationShelf? shelf;
    try {
      shelf = CreationShelf.tryFromJson(jsonDecode(raw));
    } on FormatException {
      shelf = null;
    }
    if (shelf != null) return shelf;
    await _store.write(corruptBackupKey, raw);
    return CreationShelf.empty;
  }

  @override
  Future<Creation> add(Creation Function(String id) create) async {
    final shelf = await load();
    if (shelf.isFull) throw const CreationsFullException();
    final creation = create(shelf.newId());
    await _save(
      CreationShelf(
        items: [...shelf.items, creation],
        nextId: shelf.nextId + 1,
      ),
    );
    return creation;
  }

  @override
  Future<void> remove(String id) async {
    final shelf = await load();
    await _save(
      CreationShelf(
        items: [
          for (final item in shelf.items)
            if (item.id != id) item,
        ],
        nextId: shelf.nextId,
      ),
    );
  }

  @override
  Future<void> clear() async {
    await _store.delete(storageKey);
    await _store.delete(corruptBackupKey);
  }

  @override
  Future<bool> hasCorruptBackup() async =>
      await _store.read(corruptBackupKey) != null;

  Future<void> _save(CreationShelf shelf) =>
      _store.write(storageKey, jsonEncode(shelf.toJson()));
}
