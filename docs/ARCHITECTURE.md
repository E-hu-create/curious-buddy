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
      placeholder_screen.dart   Buddy + message; "coming soon" and unknown routes
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
it needs its own logic or data). Home, Mystery Missions and Living Stories exist. The other
destinations are routes in `routes.dart` that show `PlaceholderScreen` until
built; Home's cards come from the `HomeDestination` enum.

| Feature | UI folder | Depends on |
| --- | --- | --- |
| Home and exploration | `ui/home/` | progress repository |
| Mystery missions and learning games ✅ | `ui/missions/`, `domain/missions/` | mission repository, progress repository, BuddyVoice |
| Buddy voice narration and speech input | `domain/voice/`, `data/services/voice/` | (shared service; no own screen) |
| Living Stories ✅ | `ui/stories/`, `domain/stories/` | story repository, progress repository, BuddyVoice |
| Creative Island | `ui/creative/` | local storage only |
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
`openDiscoveries` open existing (placeholder) feature pages; `startQuiz`
opens a "Quiz Time, coming soon" page. No action can open the web, files
or device features.

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
- **Migrations:** bump `schemaVersion` and handle older versions in
  `tryFromJson`.

Backed by `SharedPreferencesKeyValueStore`
(`data/services/shared_preferences_key_value_store.dart`, Android
DataStore), so progress and settings (`voice.muted`,
`voice.allowOnlineRecognition`) **survive restarts**. Data stays in the
app's private storage: Android cloud backup is off (`allowBackup="false"`),
and uninstalling deletes it. Any storage failure, including plugin errors,
becomes a `StorageException`, which every caller already handles: settings
fall back to safe defaults (voice on, online off), and progress is hidden
rather than overwritten. Tests use `InMemoryKeyValueStore` or the plugin's
`InMemorySharedPreferencesAsync`.

## Platforms

Android is the target. iOS folders exist but cannot be built on this Windows
machine (needs macOS + Xcode). `linux/`, `macos/`, `windows/` and `web/` are
template leftovers; they are harmless and can be removed later if we decide
not to support those platforms.
