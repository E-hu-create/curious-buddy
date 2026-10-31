import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/purchase/purchase_service.dart';
import 'package:curious_buddy/domain/access/access_controller.dart';
import 'package:curious_buddy/domain/access/free_content.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/stories/more_stories.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late InMemoryKeyValueStore store;
  late FakePurchaseService purchases;

  setUp(() {
    store = InMemoryKeyValueStore();
    purchases = FakePurchaseService();
  });

  AccessController build({bool locksOn = true}) => AccessController(
    store: store,
    purchases: purchases,
    locksOn: locksOn,
    restoreWait: const Duration(seconds: 2),
  );

  test('test builds are fully open', () async {
    final access = build(locksOn: false);
    await access.ready;

    expect(access.storyLocked('ananse_wisdom'), isFalse);
    expect(access.missionLocked('flat_loaf'), isFalse);
    expect(access.gameLocked('sudoku'), isFalse);
    expect(access.quizLevelLocked(QuizDifficulty.expert), isFalse);
  });

  test('the free version keeps the free things open', () async {
    final access = build();
    await access.ready;

    for (final story in allStories) {
      expect(
        access.storyLocked(story.id),
        !FreeContent.storyIds.contains(story.id),
        reason: story.id,
      );
    }
    for (final mission in allMissions) {
      expect(
        access.missionLocked(mission.id),
        !FreeContent.missionIds.contains(mission.id),
        reason: mission.id,
      );
    }
    expect(access.gameLocked('dino'), isFalse);
    expect(access.gameLocked('maze'), isFalse);
    expect(access.gameLocked('arena'), isFalse);
    expect(access.gameLocked('sudoku'), isTrue);
    expect(access.quizLevelLocked(QuizDifficulty.starter), isFalse);
    expect(access.quizLevelLocked(QuizDifficulty.explorer), isTrue);
  });

  test('every free id is a real story or mission', () {
    final storyIds = {for (final s in allStories) s.id};
    final missionIds = {for (final m in allMissions) m.id};
    expect(storyIds.containsAll(FreeContent.storyIds), isTrue);
    expect(missionIds.containsAll(FreeContent.missionIds), isTrue);
  });

  test('buying unlocks everything and is remembered', () async {
    final access = build();
    await access.ready;

    await access.buy();
    await pumpEventQueue();

    expect(access.unlocked, isTrue);
    expect(access.storyLocked('ananse_wisdom'), isFalse);
    expect(await store.read(AccessController.key), 'true');

    final later = build();
    await later.ready;
    expect(later.unlocked, isTrue);
  });

  test('a payment that goes through later still unlocks', () async {
    purchases.afterBuy = PurchaseEvent.pending;
    final access = build();
    await access.ready;

    await access.buy();
    await pumpEventQueue();
    expect(access.status, UnlockStatus.pending);
    expect(access.unlocked, isFalse);

    purchases.report(PurchaseEvent.owned);
    await pumpEventQueue();
    expect(access.unlocked, isTrue);
  });

  test('cancelling or failing leaves it locked and says so', () async {
    final access = build();
    await access.ready;

    purchases.afterBuy = PurchaseEvent.cancelled;
    await access.buy();
    await pumpEventQueue();
    expect(access.status, UnlockStatus.cancelled);

    purchases.afterBuy = PurchaseEvent.failed;
    await access.buy();
    await pumpEventQueue();
    expect(access.status, UnlockStatus.failed);
    expect(access.unlocked, isFalse);
  });

  test('no store: says so, and nothing changes', () async {
    purchases.storeReachable = false;
    final access = build();
    await access.ready;

    await access.buy();
    expect(access.status, UnlockStatus.storeUnavailable);
    await access.loadPrice();
    expect(access.price, isNull);
  });

  test('restore finds an earlier purchase', () async {
    purchases.ownedBefore = true;
    final access = build();
    await access.ready;

    await access.restore();
    await pumpEventQueue();
    expect(access.unlocked, isTrue);
  });

  test('restore with nothing to find says so after a short wait', () async {
    final access = AccessController(
      store: store,
      purchases: purchases,
      locksOn: true,
      restoreWait: const Duration(milliseconds: 50),
    );
    await access.ready;

    await access.restore();
    expect(access.status, UnlockStatus.working);

    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(access.status, UnlockStatus.notFound);
    expect(access.unlocked, isFalse);
  });
}
