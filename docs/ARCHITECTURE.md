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
it needs its own logic or data). Only Home exists. The other destinations
are routes in `routes.dart` that show `PlaceholderScreen` until built; Home's
cards come from the `HomeDestination` enum.

| Feature | UI folder | Depends on |
| --- | --- | --- |
| Home and exploration | `ui/home/` | progress repository |
| Mystery missions and learning games | `ui/missions/` | progress repository, Narrator |
| Buddy voice narration and speech input | `domain/voice/`, `data/services/voice/` | (shared service; no own screen) |
| Living Stories | `ui/stories/` | Narrator, progress repository |
| Creative Island | `ui/creative/` | local storage only |
| Saved progress | `domain/models/`, `data/repositories/` | KeyValueStore |
| Parent Zone | `ui/parent_zone/` | progress repository; behind a parent gate |

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

Interfaces only. **No real speech engine is implemented.** The app ships with
`UnavailableTextToSpeechService` and `UnavailableSpeechRecognitionService`,
which honestly report "unavailable".

| Concern | Type | File |
| --- | --- | --- |
| Speech output | `TextToSpeechService` | `data/services/voice/text_to_speech_service.dart` |
| Push-to-talk input | `SpeechRecognitionService` | `data/services/voice/speech_recognition_service.dart` |
| Narration and dialogue policy | `Narrator` | `domain/voice/narrator.dart` |
| Answers to children's questions | `EducationalResponseProvider` | `domain/voice/educational_response_provider.dart` |
| Shared failure reasons | `VoiceFailure` | `data/services/voice/voice_failure.dart` |

### Failure strategy

| Situation | Behaviour |
| --- | --- |
| No TTS engine or voice not installed | `Narrator` returns `textOnly`. Text is always on screen, so nothing is lost. No error dialog. |
| Speech interrupted (new line, call, audio focus loss) | New narration stops the old one first. Result `interrupted`; UI may offer replay. |
| Repeated playback | `Narrator.replay()` speaks the last line again. |
| Engine throws (plugin bug) | Caught in `Narrator`; becomes `textOnly`. Never crashes a session. |
| Microphone permission denied | Hide or disable the talk button and show a tap alternative. Never re-prompt automatically. |
| Permanently denied | Explain to the *parent* (in Parent Zone) how to enable it in system settings. |
| Speech recognition unavailable | Push-to-talk is not shown. Every interaction has a tap path. |

Rules:
- Never request microphone permission at launch. Only `requestPermission()`
  may prompt, and only after the child or parent explicitly taps
  push-to-talk. A widget test checks that launch makes no speech or
  microphone calls.
- Speech recognition returns transcripts only. Audio is never stored.

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
- **Migrations:** bump `schemaVersion` and handle older versions in
  `tryFromJson`.

Currently backed by `InMemoryKeyValueStore`, so **progress is not persisted
across app restarts yet.** A persistent store needs a dependency (see
DEPENDENCIES.md).

## Platforms

Android is the target. iOS folders exist but cannot be built on this Windows
machine (needs macOS + Xcode). `linux/`, `macos/`, `windows/` and `web/` are
template leftovers; they are harmless and can be removed later if we decide
not to support those platforms.
