# Testing

## Commands

Run from the project root (`curious_buddy/`).

| Check | Command |
| --- | --- |
| All checks | `powershell -ExecutionPolicy Bypass -File tool\verify.ps1` |
| Reproducible dependencies | `flutter pub get --enforce-lockfile` |
| Formatting check | `dart format --output=none --set-exit-if-changed .` |
| Apply formatting | `dart format .` |
| Static analysis | `flutter analyze` |
| All tests | `flutter test` |
| One file | `flutter test test/domain/voice/narrator_test.dart` |
| Coverage | `flutter test --coverage` (writes `coverage/lcov.info`, git-ignored) |
| Android debug build | `flutter build apk --debug` |

A change is not done until all of these pass. Do not disable lint rules or
delete or skip failing tests to make them pass; fix the cause, or record why
and ask first.

## Conventions

- `test/` mirrors `lib/`: `lib/domain/voice/narrator.dart` →
  `test/domain/voice/narrator_test.dart`.
- Shared fakes live in `test/testing/fakes.dart`. Test fakes are hand-written;
  no mocking package.
- **Unit tests** (`test(...)`): domain models, repositories, view models and
  narration logic. No widgets, no platform channels.
- **Widget tests** (`testWidgets(...)`): build `CuriousBuddyApp` or a single
  screen with fake `AppDependencies`. Check visible text and behaviour, not
  implementation details.
- **Navigation tests**: push routes through the `Navigator` and check the
  resulting screen (see `test/widget_test.dart`).
- **State tests**: test a view model by calling its methods and checking its
  properties and `notifyListeners` calls, without building widgets.
- Every bug fix gets a test that fails without the fix.
- Tests never touch real storage, network, microphone or speech engines.

## Current tests

| File | Covers |
| --- | --- |
| `test/widget_test.dart` | App launches; launch makes no microphone/speech calls; unknown routes; default dependencies |
| `test/domain/models/learner_progress_test.dart` | Progress JSON validation and versioning |
| `test/data/repositories/progress_repository_test.dart` | Save/load, corrupt-data backup and recovery, storage errors |
| `test/domain/voice/narrator_test.dart` | Narration, interruption, replay, unavailable and failing engines |
| `test/ui/home/home_view_model_test.dart` | Loading progress, storage failure, speech availability, never speaking on load |
| `test/ui/home/home_screen_test.dart` | Destinations, explorer log, navigation to each page and back, Parent Zone, "Hear Buddy" button |
| `test/ui/home/home_accessibility_test.dart` | Tap target, label and contrast guidelines; screen-reader labels; no overflow at small/large/landscape/tablet sizes and 2x text; reduced motion |
| `test/ui/core/widgets/buddy_test.dart` | Buddy label, one-shot wave, tap reaction, reduced motion, every mood paints |

Shared helpers in `test/testing/test_app.dart`: `buildTestApp`,
`usePhoneScreen`, `useTextScale`, `useReducedMotion`.

Widget tests render text with Flutter's test font (solid blocks), so they
check layout and behaviour, not appearance. Check appearance on a device.

## Real-device checklist

Run on a physical Android phone (verified device: Samsung SM-A516U,
Android 13) with `flutter run -d <device-id>` before merging any
user-visible change:

- [ ] App installs and opens without crashing.
- [ ] No permission prompt appears at launch.
- [ ] Home: Buddy waves once; tapping Buddy makes him smile and wave again.
- [ ] Each Home card opens its "coming soon" page; the back arrow and
      "Back to Home" both return to Home.
- [ ] "Grown-ups" opens the Parent Zone placeholder.
- [ ] No "Hear Buddy" button is shown (no speech engine yet).
- [ ] With Settings → Accessibility → "Remove animations" on, Buddy does
      not move.
- [ ] Text is readable at the largest system font size.
- [ ] Layout works in portrait and landscape (or orientation is locked on
      purpose).
- [ ] Back button behaves sensibly on every new screen.
- [ ] Send the app to the background and reopen it: state is intact.
- [ ] Airplane mode: everything still works (the app needs no network).
- [ ] *Once voice exists:* narration plays; tapping again interrupts and
      restarts cleanly; media volume at 0 does not break the flow; a call or
      alarm during narration does not crash; denying the microphone leaves a
      working tap alternative.
- [ ] *Once progress persists:* force-stop and reopen; progress is kept.
- [ ] No new warnings in `flutter run` console output.
