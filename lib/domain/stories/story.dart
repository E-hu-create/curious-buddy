/// Living Stories content model: a branching story as a graph of scenes.
/// Pure data: no Flutter, no storage.
///
/// A [StoryScene] is either a decision point (it has [StoryScene.choices])
/// or an ending (it has a [StoryScene.ending]). Choices point at other
/// scenes by id. StoryValidator guarantees the graph is playable: every
/// scene reachable, no loops, and every path finishes at an ending.
library;

/// Which locally drawn picture a scene shows.
enum ScenePicture {
  forestGrey,
  forestOak,
  forestStream,
  forestRainbow,
  lumaCamp,
  lumaRidge,
  lumaCrater,
  lumaSignal,
  inventorShed,
  inventorWorkshop,
  inventorHill,
  inventorGarden,
  whaleSea,
  whaleReef,
  whaleSong,
  snowHill,
  snowCrystal,
  snowSunny,
  beeMeadow,
  beeHive,
  beeBusy,
  bubbleCave,
  bubbleBig,
  bubbleRainbow,
  starNight,
  starScope,
  starMap,
  springMountain,
  springPool,
  springHappy,
  seedHill,
  seedRiver,
  seedTall,
  robotDust,
  robotPanel,
  robotSun,
  fossilCliff,
  fossilBrush,
  fossilDisplay,
  monarchField,
  monarchMountains,
  monarchForest,
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.text,
    required this.nextSceneId,
    this.consequence,
  });

  final String id;
  final String text;
  final String nextSceneId;

  /// Shown at the top of the next scene: what happened because of this
  /// choice. Explains consequences without judging the choice.
  final String? consequence;
}

class StoryEnding {
  const StoryEnding({
    required this.id,
    required this.title,
    required this.discovery,
  });

  final String id;

  /// Short name shown in the endings collection.
  final String title;

  /// What the child learned on this path.
  final String discovery;
}

class StoryScene {
  const StoryScene({
    required this.id,
    required this.title,
    required this.text,
    required this.picture,
    this.choices = const [],
    this.ending,
  });

  final String id;
  final String title;

  /// The scene itself, read aloud by Buddy.
  final String text;
  final ScenePicture picture;
  final List<StoryChoice> choices;

  /// Set only on ending scenes, which have no choices.
  final StoryEnding? ending;

  bool get isEnding => ending != null;
}

class Story {
  const Story({
    required this.id,
    required this.title,
    required this.tagline,
    required this.cover,
    required this.intro,
    required this.startSceneId,
    required this.scenes,
  });

  final String id;
  final String title;

  /// One line for the story card.
  final String tagline;
  final ScenePicture cover;

  /// Buddy's introduction before the first scene.
  final String intro;
  final String startSceneId;
  final List<StoryScene> scenes;

  StoryScene? sceneById(String id) {
    for (final scene in scenes) {
      if (scene.id == id) return scene;
    }
    return null;
  }

  List<StoryEnding> get endings => [for (final scene in scenes) ?scene.ending];
}
