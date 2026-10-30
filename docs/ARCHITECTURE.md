# Architecture

Follows Flutter's recommended app architecture (UI layer → optional domain
layer → data layer), scaled down to what the app needs today. Add structure
when a feature needs it, not before.

## Layers and folders

```
lib/
  main.dart                 Entry point. Builds AppDependencies and runs the app.
  app/                      App configuration
    app.dart                MaterialApp, theme, routes
    routes.dart             Named route constants
    app_dependencies.dart   Composition root: chooses concrete services
  ui/                       UI layer
    core/themes/            Colours (app_colors.dart), theme and sticker shapes
    core/widgets/           Reusable widgets shared across features
      buddy/                Buddy the robot (CustomPainter, no image assets)
      placeholder_screen.dart   Buddy + message; the page for unknown routes
    home/                   Home and exploration (Phase 1)
      home_screen.dart, home_view_model.dart, home_destination.dart
      widgets/              Greeting bubble, explorer log, destination grid
    missions/               Mystery Missions (Phase 4)
      missions_screen.dart, missions_view_model.dart        Case list
      mission_play_screen.dart, mission_play_view_model.dart  Playing a case
      widgets/              Drawn covers, clue cards, choices, order builder
    stories/                Living Stories (Phase 5)
      stories_screen.dart, stories_view_model.dart          Story shelf
      story_play_screen.dart, story_play_view_model.dart    Reading a story
      widgets/              Drawn scene pictures, choice cards, tags
    quiz/                   Quiz Time
      quiz_hub_screen.dart, quiz_hub_view_model.dart        Topics and levels
      quiz_play_screen.dart, quiz_play_view_model.dart      Playing a round
      widgets/              Topic badges, stars, answer tiles, result panel
    creative/               Creative Island (Phase 7)
      creative_hub_screen.dart   Activities, My Creations shelf, viewer
      drawing_screen.dart, creature_screen.dart             The two activities
      creative_view_models.dart  Shelf, drawing and creature logic
      widgets/              Painters, palette, descriptions, shared controls
    discoveries/            My Discoveries (the explorer journal)
      discoveries_screen.dart, discoveries_view_model.dart
    <feature>/              One folder per feature (see below)
      <feature>_screen.dart
      <feature>_view_model.dart   ChangeNotifier holding screen state/logic
      widgets/
  domain/                   Pure Dart: models and app logic. No Flutter UI,
    models/                 no plugins. Easy to unit test.
    voice/                  Narration policy, educational-response boundary
  data/                     Data layer
    repositories/           Source of truth for app data (e.g. progress)
    services/               Thin wrappers around storage and platform APIs
      voice/                Text-to-speech and speech-recognition interfaces
test/                       Mirrors lib/
  testing/                  Shared fakes and fixtures (not test files)
```

### Dependency direction

`ui` → `domain` → `data/services` interfaces. Never the reverse.

- Screens never call plugins directly. They use view models, which use
  repositories, domain classes or service interfaces.
- Plugin types (from any future TTS, speech or storage package) stay inside
  their `data/services` implementation file.
- `AppDependencies` is the only place that picks concrete implementations.
  Tests pass fakes instead.

### State management

Built-in `ChangeNotifier` + `ListenableBuilder`, passed via constructors. No
state-management package yet. Revisit (likely `provider`, as the Flutter docs
use) once several screens share state; record the decision in DEPENDENCIES.md.

### Navigation

Built-in `Navigator` with named routes in `routes.dart`. Unknown routes show
a friendly page. Switch to `go_router` only if we need deep links or route
guards (e.g. the Parent Zone gate) that become awkward without it.

## Planned feature boundaries

Each becomes a folder under `lib/ui/` (and `lib/domain/` / `lib/data/` only if
it needs its own logic or data). Every Home card now opens a real feature;
Home's cards come from the `HomeDestination` enum, and `PlaceholderScreen` is
only used for unknown routes.

| Feature | UI folder | Depends on |
| --- | --- | --- |
| Home and exploration | `ui/home/` | progress repository |
| Mystery missions and learning games ✅ | `ui/missions/`, `domain/missions/` | mission repository, progress repository, BuddyVoice |
| Buddy voice narration and speech input | `domain/voice/`, `data/services/voice/` | (shared service; no own screen) |
| Living Stories ✅ | `ui/stories/`, `domain/stories/` | story repository, progress repository, BuddyVoice |
| Quiz Time ✅ | `ui/quiz/`, `domain/quiz/` | quiz repository, progress repository, BuddyVoice |
| Creative Island ✅ | `ui/creative/`, `domain/creative/` | creations repository (local only), BuddyVoice |
| Game Zone ✅ (Challenge Arena, Dino Discovery, Treasure Maze, Code the Robot, Word Builder, What's That Sound?) | `ui/games/`, `domain/games/` | progress and creations repositories, BuddyVoice |
| Buddy's Wardrobe ✅ | `ui/wardrobe/`, `domain/wardrobe/` | progress and content repositories, BuddyWardrobe, BuddyVoice |
| My Discoveries ✅ | `ui/discoveries/`, `domain/discoveries/` | reads progress, mission, story, quiz and creations repositories; BuddyVoice |
| Saved progress | `domain/models/`, `data/repositories/` | KeyValueStore |
| Parent Zone ✅ | `ui/parent_zone/`, `domain/parent/`, `domain/settings/` | progress repository, BuddyVoice, BuddyListener, DisplaySettings; behind `ParentGate` |

Features must not import each other's internals. Shared pieces move to
`ui/core/` or `domain/`.

## Visual design and accessibility

- **Style:** UI uses a flat "sticker" look: solid fills, 2.5px dark ink
  outlines and a hard offset shadow (`AppShapes.sticker`). Only Buddy uses
  soft shading. Colours live only in `app_colors.dart`.
- **Buddy** is drawn in code (`BuddyPainter`) as an interim stand-in for
  final art. Six moods: `neutral`, `happy`, `curious`, `surprised`,
  `thoughtful` and `excited`. He waves once when shown and gets excited when
  tapped. Animations are one-shot and are skipped when the system "remove
  animations" setting is on. The character model is defined in
  [MASCOT.md](MASCOT.md).
- **Launcher icon** is generated from `BuddyPainter` by
  `tool/generate_launcher_icons_test.dart` (legacy + adaptive icon).
- **Touch targets:** buttons are at least 56dp tall (`AppTheme.minTouchTarget`)
  and destination cards at least 150dp.
- **Text:** layouts reflow for large system text (one column at 1.5x and
  above) and narrow screens. Tests cover 320dp width, 2x text, landscape
  and tablet sizes.
- **Screen readers:** cards are single labelled buttons, headings are marked
  as headers, and Buddy has a label.
- **Voice-friendly:** all child-facing text is short and on screen. The
  "Hear Buddy" button appears only when a speech engine reports it is
  available, and only speaks when tapped.
- Automated checks: Flutter's tap target, labelled tap target and text
  contrast guidelines (`test/ui/home/home_accessibility_test.dart`).

## Voice system

**Speech output** uses the device's built-in text-to-speech engine.
**Speech input** is explicit tap-to-talk on Android's recogniser,
on-device only unless a grown-up allows online recognition (Stage B; see
[STAGE_B_VOICE_INPUT.md](STAGE_B_VOICE_INPUT.md)).

| Concern | Type | File |
| --- | --- | --- |
| Speech output (interface) | `TextToSpeechService` | `data/services/voice/text_to_speech_service.dart` |
| Speech output (device engine) | `FlutterTtsService` | `data/services/voice/flutter_tts_service.dart` |
| App-wide voice: on/off, welcome once, stop | `BuddyVoice` | `domain/voice/buddy_voice.dart` |
| Stop speech and listening on navigation | `VoiceNavigatorObserver` | `app/voice_navigator_observer.dart` |
| Tap-to-talk input (interface) | `SpeechRecognitionService` | `data/services/voice/speech_recognition_service.dart` |
| Tap-to-talk input (Android) | `SpeechToTextRecognitionService` + `PluginSpeechEngine` | `data/services/voice/speech_to_text_recognition_service.dart` |
| On-device recognition check | `MainActivity.kt` (`curious_buddy/speech` channel) | `android/app/src/main/kotlin/.../MainActivity.kt` |
| App-wide microphone: one session, allow-online setting, cancel | `BuddyListener` | `domain/voice/buddy_listener.dart` |
| Talk flow on Home (explain, permission, listen, draft) | `TalkViewModel` | `ui/home/talk_view_model.dart` |
| Grown-up setting behind a parent check | `ParentZoneScreen` | `ui/parent_zone/parent_zone_screen.dart` |
| Narration and dialogue policy | `Narrator` | `domain/voice/narrator.dart` |
| Answers to children's questions | `EducationalResponseProvider` | `domain/voice/educational_response_provider.dart` |
| Shared failure reasons | `VoiceFailure` | `data/services/voice/voice_failure.dart` |

### How speech flows

```
HomeViewModel ──► BuddyVoice ──► Narrator ──► TextToSpeechService
 (one per screen)   (one per app)   (playback policy)   (FlutterTtsService)
```

- `CuriousBuddyApp` creates the single `BuddyVoice` and disposes it on close.
  Screens get it through constructors, so only one line can ever play.
- **Welcome:** `BuddyVoice.welcomeOnce` speaks at most once per app session.
  Rebuilds, returning to Home and resuming the app do not repeat it.
- **Replay:** "Hear again" calls `BuddyVoice.say` with the same text.
  A new line always interrupts the current one.
- **Voice on/off:** `BuddyVoice.setMuted`. Turning it off stops speech
  immediately and silences later lines; turning it on never speaks by
  itself. Saved under `voice.muted` in `KeyValueStore` (in memory until
  persistent storage is added).
- **Cleanup:** `VoiceNavigatorObserver` stops speech on every push, pop,
  replace and remove; `AppLifecycleListener` stops it when the app becomes
  inactive (call, app switcher, screen off) or hidden; dispose stops it on
  close. `stop()` also cancels a line still waiting for the engine, so a
  stopped welcome can never start on another screen.
- **Engine setup:** `FlutterTtsService` picks the first installed voice from
  en-US, en-GB, en-AU, en-CA, en-IN; rate 0.5 (normal), pitch 1.15. It is
  checked once per session.
- **Why requests are tracked by hand:** on Android, `flutter_tts`'s
  `speak()` future never completes after an engine error. Each request is
  resolved by the completion/error callbacks, `stop()`, or a timeout
  (6s + 120ms per character).

### Failure strategy

| Situation | Behaviour |
| --- | --- |
| No TTS engine or voice not installed | `BuddyVoice.status` is `unavailable`. Home shows "Buddy can't talk on this phone right now, but you can read along!" and no voice buttons. Text is always on screen, so nothing is lost. No error dialog. |
| Engine error, rejected request or timeout mid-speech | Becomes `textOnly` silently; Home stays usable and "Hear again" can retry. |
| Speech interrupted (new line, call, audio focus loss) | New narration stops the old one first. Result `interrupted`; UI may offer replay. |
| Repeated playback | `Narrator.replay()` speaks the last line again. |
| Engine throws (plugin bug) | Caught in `Narrator`; becomes `textOnly`. Never crashes a session. |
| Microphone permission denied | Hide or disable the talk button and show a tap alternative. Never re-prompt automatically. |
| Permanently denied | Explain to the *parent* (in Parent Zone) how to enable it in system settings. |
| Speech recognition unavailable | Push-to-talk is not shown. Every interaction has a tap path. |

Rules:
- Never request microphone permission at launch. Only `requestPermission()`
  may prompt, and only after the child or parent explicitly taps
  push-to-talk. A widget test checks that launch speaks only the welcome
  and makes no microphone calls.
- Buddy only speaks text that is also on screen, from the app's own
  scripts. Nothing a child types or says is sent to the speech engine.
- Speech recognition returns transcripts only. Audio is never stored.

## Talking with Buddy (Stage A)

```
AskBuddyPanel (text box, ideas) ─► BuddyChatViewModel ─► EducationalResponseProvider
                                        │                   └ CuratedResponseProvider
                                        │                        ├ ChildSafetyFilter (first)
                                        │                        └ curated_content.dart
                                        └─► BuddyVoice.say(answer)
```

| Piece | File | Job |
| --- | --- | --- |
| `EducationalResponseProvider` | `domain/voice/educational_response_provider.dart` | Interface for anything that answers. Returns text, kind (answer / fallback / safety), optional `BuddyAction`, follow-up ideas, `hideQuestion`. |
| `ChildSafetyFilter` | `domain/conversation/child_safety_filter.dart` | Runs before matching. Personal info → "keep it private" and the question is hidden on screen. Self-harm, bullying, medical, off-limits → redirect to a trusted grown-up. Conservative keyword rules, not a full safety system. |
| `CuratedResponseProvider` | `domain/conversation/curated_response_provider.dart` | Matches whole words (plurals and possessives fold to the base word; one-letter typos forgiven only for a short list of long names such as "dinosaur"). A topic can pin an answer to a question word ("purr" → the purr answer). If a specific question only matches a subject (e.g. "What do snakes eat?"), Buddy says "I'm not sure about that exact question yet. Here's a snake fact instead!" rather than passing a fact off as an answer. Otherwise rotates answers; honest fallback. Offline, nothing stored. |
| Content | `domain/conversation/curated_content.dart`, `curated_topics_more.dart`, `curated_topics_extra.dart` | About 120 reviewed topics (animals, space, Earth and weather, the body, science and machines, history, jokes, riddles, and a gentle reply to "I'm sad / lonely / scared" that points to a trusted grown-up) and starter ideas. Rules enforced by tests: at most 60 words (including any lead-in), sentences of at most 22 words, never asks for personal details, does not trip the safety filter. |
| `BuddyChatViewModel` | `ui/home/buddy_chat_view_model.dart` | One exchange at a time; `thinking` / `speaking` / `idle`; ignores repeat submissions while thinking; a new question stops current speech; friendly error and recovery; never writes to storage. |
| `routeForAction` | `ui/home/buddy_action_routes.dart` | Exhaustive map from `BuddyAction` to an in-app route. Actions only run when the child taps the button. |

**Actions.** `openMissions`, `openStories`, `openCreative`,
`openDiscoveries` open their feature pages; `startQuiz` opens Quiz Time. No
action can open the web, files or device features.

**Talk button (Stage B).** `HomeScreen._startTalking` →
`TalkViewModel.prepare`: unavailable → notice; permission missing →
explanation dialog, and only on **OK** `requestPermissionAndListen`;
granted → `listen`. `BuddyListener` stops Buddy's voice first and runs one
session (15 s max, 3 s pause). Heard words become a `draft` that
`AskBuddyPanel` puts in the text box; the child sends it with Ask. Details
and failure messages: [STAGE_B_VOICE_INPUT.md](STAGE_B_VOICE_INPUT.md).

**Buddy's states.** Idle: happy (or curious after "I don't know",
thoughtful after a safety reply). Listening: curious + "Listening..."
badge; "Hear again", typing and ideas disabled. Thinking: thoughtful +
"Thinking..." badge. Speaking: "Talking..." badge and "Stop talking" in
place of "Hear again". Error: surprised + friendly message.

**Adding a provider later (Stage C).** Implement
`EducationalResponseProvider`, keep `ChildSafetyFilter` in front of it,
and filter its output too. Any external AI service must sit behind an
app-owned backend that holds API keys, applies safety checks and stores
nothing; no keys in the app. Document and get approval first.

## Mystery Missions (Phase 4)

```
MissionsScreen ─► MissionsViewModel ─► MissionRepository (BundledMissionRepository)
      │                     └────────► ProgressRepository (best points, solved)
      └─ push ─► MissionPlayScreen ─► MissionPlayViewModel ─► StageEvaluator, MissionScore
                                             ├─► BuddyVoice (narration)
                                             └─► ProgressRepository (save on finish)
```

| Piece | File | Job |
| --- | --- | --- |
| Models | `domain/missions/mission.dart` | `Mission`, `Clue`, `Choice`, `OrderPiece`, and the stage mechanics as a sealed class: `ChoiceStage` (pick one), `MultiSelectStage` (pick all that fit), `OrderStage` (put in order). Every stage has optional clues, progressive hints and an explanation. |
| Rules | `domain/missions/mission_rules.dart` | `StageEvaluator` (right/wrong with specific feedback), `MissionScore` (transparent points), `MissionValidator` (playability checks). |
| Content | `domain/missions/mission_content.dart` | The three starter missions, as data separate from UI. |
| Repository | `data/repositories/mission_repository.dart` | Loads bundled missions offline; leaves out invalid or duplicate ones instead of showing them broken. |
| Play flow | `ui/missions/mission_play_view_model.dart` | Intro → stages → completion; clue inspection; selections; hints; check/next; replay; save; narration. |

**Mechanics.** Clues start face down and are revealed with "Inspect clue".
Wrong answers explain why and, if clues are still hidden, Buddy asks
"Have you inspected every clue?". Single-choice answers unlock for a retry;
multi-select and order answers keep the child's work. Order pieces are shown
in a fixed shuffle that is never already correct. A solved step locks and
shows its explanation.

**Scoring** (`MissionScore`): 50 for solving the case, 10 per step, a 10
bonus per step right first time, and 5 per clue inspected. Hints and mistakes
never subtract points, so every child can finish. The completion screen shows
the breakdown. The best score per mission is kept; replays never lower it.

**Narration.** Buddy reads the opening scene when a case opens, reads the
question after each step change, reads clues and the question on request,
speaks feedback, hints and the wrap-up, and offers "Hear again" and "Stop
talking". Everything spoken is also on screen. Speech stops when the child
leaves (`MissionPlayViewModel.dispose` and `VoiceNavigatorObserver`); the
shared `BuddyVoice` prevents overlap. The microphone is never used in
missions (tested).

**Validation.** `MissionValidator` requires: at least two stages with unique
ids; a prompt, at least one hint and an explanation per stage; exactly one
correct choice for single-choice stages; at least one right and one wrong
option for multi-select; at least three unique pieces for order stages; and
texts of at most 70 words. Tests also check the puzzles' logic by computing
the answers (for example decoding the shift code).

## Living Stories (Phase 5)

```
StoriesScreen ─► StoriesViewModel ─► StoryRepository (BundledStoryRepository)
      │                    └───────► ProgressRepository (endings, bookmarks)
      └─ push ─► StoryPlayScreen ─► StoryPlayViewModel ─► StoryGraph
                                           ├─► BuddyVoice (narration)
                                           └─► ProgressRepository (save every page)
```

| Piece | File | Job |
| --- | --- | --- |
| Models | `domain/stories/story.dart` | `Story`, `StoryScene` (a decision point with `choices`, or an ending with a `StoryEnding`), `StoryChoice` (text, target scene, consequence line), `ScenePicture`. |
| Rules | `domain/stories/story_rules.dart` | `StoryValidator` (playability checks) and `StoryGraph` (reachability, loop detection, path counting, checking saved paths). Both are safe on broken, looping content. |
| Content | `domain/stories/story_content.dart` | The three starter stories as data: The Forest That Forgot Its Colours, The Lost Signal from Planet Luma, The Tiny Inventor's Big Idea. Each has 8 or 9 scenes and 4 endings. |
| Repository | `data/repositories/story_repository.dart` | Loads bundled stories offline; leaves out invalid or duplicate ones. |
| Reading flow | `ui/stories/story_play_view_model.dart` | Intro → scenes → ending; choose; restart; resume; save; narration. |
| Pictures | `ui/stories/widgets/story_picture.dart` | 12 scenes drawn with `CustomPainter` in the sticker style, four per story, with the characters Fennel (hedgehog), Dot (rover) and Pim (mouse). Each has a spoken description. |

**Branching.** A story is a graph of scenes: choices point at scene ids.
The child's path is the list of scenes from the start. A choice is ignored
if it is not on the current scene or would revisit a scene, so there are no
loops even with bad data. Every ending is a good outcome that differs
naturally from the others; each choice shows a short consequence line on the
next page ("You followed the stream..."), never a judgement.

**Validation.** `StoryValidator` requires: valid unique ids for the story,
scenes, choices and endings; an existing start scene; at least two endings;
every non-ending scene has a choice, every ending none; choices point at
existing, different scenes and never at their own scene; no cycles; every
scene reachable; every path ends at an ending; every ending reachable; scene
text of at most 110 words.

**Narration.** Buddy reads the intro when a story opens (or the saved page
when continuing), then each page as it opens: consequence, scene text, and
at an ending the ending's name and discovery. "Read the choices" reads them
numbered as on screen; a speaker button rereads the page; "Hear again" and
"Stop talking" work as in missions. A new page interrupts the last one
through the shared `BuddyVoice`; leaving the story stops speech
(`StoryPlayViewModel.dispose` and `VoiceNavigatorObserver`). With the voice
off or no speech engine, every word is still on screen. The microphone is
never used.

**Saving.** After every page the path is saved as a bookmark; reaching an
ending records it (`storyEndings`), marks the story finished
(`completedStoryIds`) and clears the bookmark. Saves run one after another so
a quick tap cannot let an older save overwrite a newer one. A failed save is
shown in a small note and the story carries on. On the shelf, a bookmark is
offered as "Continue the story" only if it is still a real route through the
current story; otherwise it is ignored.

## Quiz Time

```
QuizHubScreen ─► QuizHubViewModel ─► QuizRepository (BundledQuizRepository)
      │                   └────────► ProgressRepository (best per level)
      └─ push ─► QuizPlayScreen ─► QuizPlayViewModel ─► QuizRules
                                         ├─► BuddyVoice (narration)
                                         └─► ProgressRepository (save on finish)
```

| Piece | File | Job |
| --- | --- | --- |
| Models | `domain/quiz/quiz.dart` | `QuizTopic` → `QuizLevel` (Starter, Explorer, Expert) → `QuizQuestion` with 3–4 `QuizOption`s, one answer and an explanation. |
| Rules | `domain/quiz/quiz_rules.dart` | `QuizRules`: pass mark (3 of 5), stars (5 = 3, 4 = 2, 3 = 1), which levels are open. `QuizValidator`: playability checks. |
| Content | `domain/quiz/quiz_content.dart` | Four topics (Space, Animals, Amazing Body, Earth & Weather), 3 levels of 5 questions: 60 questions, consistent with Buddy's answers. |
| Repository | `data/repositories/quiz_repository.dart` | Loads bundled topics offline; leaves out invalid ones, repeated topic ids and level ids used by another topic. |
| Round | `ui/quiz/quiz_play_view_model.dart` | Shuffled answers; one pick per question; feedback and explanation; summary; save the best; play again; next level. |

**Rules.** One pick per question; the right answer and the explanation are
always shown. Wrong answers never remove anything. The first level of each
topic is open; the next opens when the level before has been passed (3 of
5). The best score per level is kept; replays never lower it. A round in
progress is not saved.

**Validation.** `QuizValidator` requires valid, unique ids; at least one
level and one question; 3–4 different answers with exactly one correct;
no "all/none of the above"; an explanation; and short text (question 25,
answer 8, explanation 40 words). Tests also check the right answer is in
varied positions and that key facts match Buddy's curated answers.

**Narration.** Buddy reads each question with lettered answers, then the
result and explanation, then the summary. "Read the question", "Read the
answers", Hear again and Stop talking; automatic reading follows the Parent
Zone setting. Speech stops on leaving; the microphone is never used.

## Creative Island (Phase 7)

```
CreativeHubScreen ─► CreativeHubViewModel ─► CreationsRepository
      ├─ push ─► DrawingScreen ─► DrawingViewModel ─┐
      ├─ push ─► CreatureScreen ─► CreatureViewModel ┴─► CreationsRepository, BuddyVoice
      └─ push ─► CreationViewScreen (view, remove)
```

| Piece | File | Job |
| --- | --- | --- |
| Models | `domain/creative/creation.dart` | `Drawing` (strokes of points in 0–1000 canvas units), `Creature` (chosen parts and a listed name), `CreativeLimits`, the reviewed `creatureNames`, and Buddy's `creatureFact`s. |
| Saved shape | `domain/creative/creation_shelf.dart` | Versioned JSON with tolerant parsing: invalid or oversized entries are dropped, unlisted names are refused, ids are never reused. |
| Repository | `data/repositories/creations_repository.dart` | Load, add (refuses when full), remove, clear; unreadable data is copied to a backup key. |
| Activities | `ui/creative/creative_view_models.dart` | Tools, undo, point cap, parts, Surprise me, New name, saving, narration. |
| Art | `ui/creative/widgets/creative_art.dart` | `DrawingPainter`, `CreaturePainter`, the palette, and descriptions in words for screen readers. |

**No free text.** Creatures take their names from a fixed list and nothing
can be typed anywhere on Creative Island, so a creation cannot hold personal
information. There is no camera, photo access, export or sharing.

**Size limits.** 12 creations, 4,000 points and 300 strokes per drawing, and
points closer than 6 canvas units are dropped. Creations have their own key
(`creations`), separate from `progress`, because they are larger.

**Drawing.** The canvas claims the finger on touch (`_ImmediatePanRecognizer`)
so strokes draw instead of scrolling the page. The eraser paints with the
paper colour.

**Narration.** Buddy gives instructions when an activity opens, shares a real
fact when a creature's extra, pattern or eyes change, and confirms saving.
Hear again / Stop talking as elsewhere; automatic reading follows the Parent
Zone setting. Speech stops on leaving; the microphone is never used.

## My Discoveries

`DiscoveryJournal.build` (`domain/discoveries/discovery_journal.dart`) turns
saved progress and the content lists into the journal: badges, endings found,
quiz stars per topic, the explorer rank and one next-adventure suggestion. It
is pure logic and **stores nothing**, so the Parent Zone needs no changes and
its reset empties the journal.

- **No spoilers:** endings not yet found are only counted.
- **Rank:** cases, endings, quiz stars and creations each count one
  discovery. Curious Beginner (0), Keen Explorer (3), Brave Adventurer (10),
  Master Discoverer (20).
- **Next adventure:** the area with the least done so far, a started story
  first; Creative Island when everything else is finished.
- **Failures:** without readable progress the page offers a retry. If one
  other source fails, its section is hidden with a note. Saved ids that no
  longer match content are ignored.
- **Narration:** Buddy reads the summary on opening, and a discovery when its
  speaker is tapped. Automatic reading follows the Parent Zone setting.

## Buddy's Wardrobe

`domain/wardrobe/wardrobe.dart` lists 10 items in three slots (hats, glasses,
neckwear), each with a goal such as "6 story endings". Unlocks are worked out
from `DiscoveryJournal`, so they are never saved. Only what Buddy is wearing
is saved, as `buddyLook` in `LearnerProgress`, so Delete all progress clears
it. `BuddyWardrobe` (one instance, owned by the app root) reaches every Buddy
through `BuddyLookScope`; `BuddyOutfitPainter` draws the items on his grid.
Saved items that are unknown or in the wrong slot are ignored.

## Game Zone

The Home card opens `GameZoneScreen`, the way into every game.

- **Logic:** `domain/games/games.dart` holds `MemoryGame`, `SpotGame`, pattern
  rounds and `ArenaRules`, with no Flutter. `game_content.dart` holds the
  patterns and Quick Create ideas.
- **Screens:** `GamePlayViewModel` is shared by every scored game (voice,
  finish, saving); `GameShell` is the shared frame and finish panel.
- **Levels:** three per game, opened by any star on the level before.
- **Kind by design:** no timers (a mismatched pair stays showing until the
  next tap), a wrong move never loses anything, and finishing Memory Match or
  Spot the Change always earns a star. Quick Create is never scored; it opens
  the Drawing Studio with an idea.
- **Saved:** `gameBest` in `LearnerProgress` (schema 6). Game stars count in
  My Discoveries and unlock the Champion cap.
- **Menus:** `GameWorld` gives the Game Zone, Arena and Dino Discovery menus
  their night-sky look, and `PlayButton` their yellow start button. The Game
  Zone shows a scoreboard: total stars and a `GameRank` worked out from them,
  so a rank can never go down. Arena levels are a map of numbered buttons.
- **How to play:** `how_to_play.dart` holds short steps for every game and the
  sheet that shows them while Buddy reads them. It opens by itself on a first
  game, worked out from `gameBest` (nothing extra is saved), so Delete all
  progress brings it back. Every game menu has a How to play button, and so
  does the top of every game.
- **Art:** `InkPen` draws the sticker style in code. `PictureArt` holds the 12
  Memory Match pictures and `DinoArt` the creatures and scenes, so there are
  no image files or licences to manage.

### Treasure Maze

`domain/games/maze.dart` makes a new maze each game by wandering from the start
and backing up at dead ends, so every cell has exactly one route. The chest
goes on the farthest cell and gems go in dead ends first. `go()` runs Buddy
until a wall, a turning, a gem or the chest. It is a `GameKind` with three
levels, saved in `gameBest`, but `GameKind.arena` leaves it out of the Arena
list: it has its own Game Zone tile, which opens `ArenaScreen` with `only` set.

### Code the Robot

`domain/games/robot.dart` makes a new puzzle for each of a level's three
rounds, only keeping layouts it can solve; the solution sets the line limit.
`trace()` runs the code and ties each move to its line, which the view model
plays back one move at a time. A run that goes wrong keeps the code and counts
against the stars. Expert adds Twice, which repeats the last line. Like the
maze, it has its own Game Zone tile.

### Word Builder

`domain/games/words.dart` holds 35 words in three levels, and `WordGame` picks
five for each game. Letters go to the first empty space; a full wrong word asks
the child to move a letter. Hint fixes the next letter and locks it. Words that
spell another common word when mixed up are left out on purpose, so check any
new word for that. It has its own Game Zone tile.

### What's That Sound?

`domain/games/sound_game.dart` holds 13 sounds, each with a written clue and a
fact, and `SoundQuiz` runs five of them per level. The recordings are real CC0
clips in `res/raw/snd_*.wav`, listed in `docs/SOUNDS.md`; check the licence of
any new recording before adding it. `MainActivity` plays them through the same
SoundPool as the effects, so Android must know each new clip by name.
`BuddyVoice.clip` stops Buddy first and stays silent if a grown-up has turned
sounds off. Then the game shows the clue, so it can always be played, and it
can be played by a child who can't hear the clips.

### Four in a Row

`domain/games/four_in_a_row.dart` is an Arena game played against Buddy. Starter
plays anywhere, Explorer takes wins and blocks, and Expert also looks four moves
ahead. The child goes first, and the two sides differ by shape as well as
colour. New quick games join `GameKind.arena`, not the Game Zone tiles, to keep
that screen short.

### Dino Discovery

`domain/games/dino.dart` holds the creatures, places, missions and
`DinoExpedition`, with no Flutter. A trip moves through explore (tap search
spots), identify (pick from three pictures using clues; a wrong pick brings the
second clue), discovered (the creature joins the scene), then a three-question
mission. `dinoProblems()` checks that the content is fair.

Places use the saved ids `dino_fern_forest`, `dino_open_plains` and
`dino_ancient_sea` in `gameBest`, so no new schema was needed. The Field Guide
is worked out from those results: finishing a place adds its three creatures.
A trip left halfway is not saved.

## Sound effects

Four short sounds in `res/raw/`, synthesised by `tool/generate_sounds.py` (no
third-party audio). `PlatformSoundEffectsService` plays them through Android's
`SoundPool` over the app's own `curious_buddy/sounds` channel, so no package
is needed. They follow the media volume, a little quieter than Buddy. The
main sounds start with 120ms of silence, because Bluetooth audio can take a
moment to wake and would otherwise swallow the start.

`BuddyVoice` owns the rule that **sounds never play over speech**: `say(text,
lead: effect)` ends old speech, plays the effect, waits for it, then speaks,
and a stop or a newer line cancels the wait. `effect()` plays a small sound
alone and is skipped while Buddy talks. Sound effects are separate from
Buddy's voice, with their own Parent Zone switch (`sound.effects`).

## Look and feel

- **Font:** Nunito, bundled in `assets/fonts/` with its licence (`OFL.txt`,
  shipped inside the app). Four fixed weights made from the official variable
  font, because Flutter's `fontWeight` does not drive a variable font by
  itself. It is never fetched from the network.
- **Motion:** `ui/core/widgets/motion.dart` holds `GentlePageTransitions`,
  `StickerPress`, `PageSwap`, `PopIn`, `ReactOnce` and `CelebrationOverlay`.
- **One-off only:** nothing loops forever. Endless animations would drain the
  battery, distract readers and stop tests from settling.
- **Calm settings:** every effect, and the phone tap, is skipped when the
  phone's Remove animations or the Parent Zone's Calmer animations is on.
- **Celebrations:** a solved case, a new story ending, a perfect quiz, a saved
  creation, and a new rank while the journal is open. Rank-ups are noticed
  only within a visit, because My Discoveries saves nothing.
- Confetti is decorative: it ignores touches and screen readers skip it.
- **Splash:** native Android, so it appears instantly with no added wait and
  no package. Android 12+ uses `values-v31/styles.xml`; older versions use
  `launch_background.xml`. The same light splash is used in dark mode because
  the app is always light (`night` beats the version in resource matching, so
  `values-night-v31` must match). Images come from
  `tool/generate_splash_test.dart`.

## Saved progress

`LearnerProgress` (domain model) is stored as versioned JSON by
`LocalProgressRepository` through the `KeyValueStore` interface.

- **Validation:** `tryFromJson` rejects wrong shapes and unknown/future
  schema versions, and drops single malformed ids instead of discarding
  everything.
- **Recovery:** unreadable data is copied to `progress.corrupt_backup` before
  the app falls back to empty progress. Only the latest bad copy is kept.
- **Storage errors** are rethrown, not treated as "no progress", so a
  temporary failure cannot lead to valid data being overwritten.
- **Schema 2** adds `missionBestPoints` (best score per mission, 0 to
  100,000). Version 1 data is still read, with no scores.
- **Schema 3** adds `storyEndings` (ending ids found per story) and
  `storyBookmarks` (the scene path of an unfinished story, at most 64
  entries; a bookmark with any bad entry is dropped whole). Older data is
  still read, with no story details.
- **Schema 6** adds `gameBest` (best stars per game level, 0 to 3). Older data
  is still read, with no game results.
- **Schema 5** adds `buddyLook` (wardrobe slot to item name). Older data is
  still read, with no outfit.
- **Schema 4** adds `quizBest` (best correct answers per quiz level id, 0 to
  100). Older data is still read, with no quiz results.
- **Migrations:** bump `schemaVersion` and handle older versions in
  `tryFromJson`.

Backed by `SharedPreferencesKeyValueStore`
(`data/services/shared_preferences_key_value_store.dart`, Android
DataStore), so progress and settings (`voice.muted`,
`voice.allowOnlineRecognition`) **survive restarts**. Data stays in the
app's private storage: Android cloud backup is off (`allowBackup="false"`),
data-extraction rules ask Android to leave it out of phone-to-phone transfers
(some phone makers may not honour this), and uninstalling deletes it. Any storage failure, including plugin errors,
becomes a `StorageException`, which every caller already handles: settings
fall back to safe defaults (voice on, online off), and progress is hidden
rather than overwritten. Tests use `InMemoryKeyValueStore` or the plugin's
`InMemorySharedPreferencesAsync`.

## Platforms

Android is the target. iOS folders exist but cannot be built on this Windows
machine (needs macOS + Xcode). `linux/`, `macos/`, `windows/` and `web/` are
template leftovers; they are harmless and can be removed later if we decide
not to support those platforms.
