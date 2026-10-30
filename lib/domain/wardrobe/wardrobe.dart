import '../discoveries/discovery_journal.dart';

/// Buddy's wardrobe: items earned by exploring. Pure data: no Flutter, no
/// storage.
///
/// Unlocks are worked out from what the child has already done, so nothing
/// about them is saved. Only what Buddy is wearing is saved.
enum WardrobeSlot {
  hat('Hats'),
  glasses('Glasses'),
  neck('Neckwear');

  const WardrobeSlot(this.title);

  final String title;
}

/// What counts towards unlocking an item.
enum WardrobeGoal {
  cases('case solved', 'cases solved'),
  endings('story ending', 'story endings'),
  quizStars('quiz star', 'quiz stars'),
  creations('creation', 'creations'),
  discoveries('discovery', 'discoveries');

  const WardrobeGoal(this.one, this.many);

  final String one;
  final String many;

  int countIn(DiscoveryJournal journal) => switch (this) {
    WardrobeGoal.cases => journal.casesSolved,
    WardrobeGoal.endings => journal.endingsFound,
    WardrobeGoal.quizStars => journal.quizStars,
    WardrobeGoal.creations => journal.creationCount,
    WardrobeGoal.discoveries => journal.discoveries,
  };
}

enum WardrobeItem {
  partyHat('Party hat', WardrobeSlot.hat, WardrobeGoal.endings, 1),
  detectiveHat('Detective hat', WardrobeSlot.hat, WardrobeGoal.cases, 1),
  wizardHat('Wizard hat', WardrobeSlot.hat, WardrobeGoal.endings, 6),
  crown('Golden crown', WardrobeSlot.hat, WardrobeGoal.discoveries, 20),
  roundGlasses(
    'Round glasses',
    WardrobeSlot.glasses,
    WardrobeGoal.quizStars,
    3,
  ),
  sunglasses('Sunglasses', WardrobeSlot.glasses, WardrobeGoal.creations, 3),
  starGlasses('Star glasses', WardrobeSlot.glasses, WardrobeGoal.quizStars, 12),
  bowTie('Bow tie', WardrobeSlot.neck, WardrobeGoal.creations, 1),
  scarf('Cosy scarf', WardrobeSlot.neck, WardrobeGoal.cases, 2),
  medal('Explorer medal', WardrobeSlot.neck, WardrobeGoal.discoveries, 10);

  const WardrobeItem(this.title, this.slot, this.goal, this.needed);

  final String title;
  final WardrobeSlot slot;
  final WardrobeGoal goal;
  final int needed;

  bool isUnlocked(DiscoveryJournal journal) => goal.countIn(journal) >= needed;

  /// How to earn it, e.g. "1 of 6 story endings".
  String progressText(DiscoveryJournal journal) {
    final have = goal.countIn(journal).clamp(0, needed);
    return '$have of $needed ${needed == 1 ? goal.one : goal.many}';
  }

  static WardrobeItem? byName(String? name) {
    for (final item in values) {
      if (item.name == name) return item;
    }
    return null;
  }
}

/// What Buddy is wearing. Each slot holds at most one item.
class BuddyLook {
  const BuddyLook({this.hat, this.glasses, this.neck});

  /// Reads saved slot → item names. Anything unknown, or in the wrong slot,
  /// is ignored.
  factory BuddyLook.fromSaved(Map<String, String> saved) {
    WardrobeItem? read(WardrobeSlot slot) {
      final item = WardrobeItem.byName(saved[slot.name]);
      return item?.slot == slot ? item : null;
    }

    return BuddyLook(
      hat: read(WardrobeSlot.hat),
      glasses: read(WardrobeSlot.glasses),
      neck: read(WardrobeSlot.neck),
    );
  }

  static const none = BuddyLook();

  final WardrobeItem? hat;
  final WardrobeItem? glasses;
  final WardrobeItem? neck;

  List<WardrobeItem> get items => [?hat, ?glasses, ?neck];
  bool get isEmpty => items.isEmpty;

  WardrobeItem? inSlot(WardrobeSlot slot) => switch (slot) {
    WardrobeSlot.hat => hat,
    WardrobeSlot.glasses => glasses,
    WardrobeSlot.neck => neck,
  };

  BuddyLook wearing(WardrobeItem item) => BuddyLook(
    hat: item.slot == WardrobeSlot.hat ? item : hat,
    glasses: item.slot == WardrobeSlot.glasses ? item : glasses,
    neck: item.slot == WardrobeSlot.neck ? item : neck,
  );

  BuddyLook without(WardrobeSlot slot) => BuddyLook(
    hat: slot == WardrobeSlot.hat ? null : hat,
    glasses: slot == WardrobeSlot.glasses ? null : glasses,
    neck: slot == WardrobeSlot.neck ? null : neck,
  );

  Map<String, String> toSaved() => {
    for (final item in items) item.slot.name: item.name,
  };

  @override
  bool operator ==(Object other) =>
      other is BuddyLook &&
      other.hat == hat &&
      other.glasses == glasses &&
      other.neck == neck;

  @override
  int get hashCode => Object.hash(hat, glasses, neck);
}
