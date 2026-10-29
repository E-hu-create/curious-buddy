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
| `test/widget_test.dart` | App launches; launch speaks only the welcome and makes no microphone calls; unknown routes; real dependencies fall back to text with no engine |
| `test/domain/models/learner_progress_test.dart` | Progress JSON validation and versioning |
| `test/data/repositories/progress_repository_test.dart` | Save/load, corrupt-data backup and recovery, storage errors |
| `test/domain/voice/narrator_test.dart` | Narration, interruption, replay, unavailable and failing engines |
| `test/domain/voice/buddy_voice_test.dart` | Availability, welcome once, replay, interrupting, stop, dispose, mute stops/silences/saves/restores, storage failures |
| `test/data/services/voice/flutter_tts_service_test.dart` | Voice selection and fallback language, missing plugin, completion, engine error (no hang), rejected speak, stop, timeout (simulated plugin channel) |
| `test/ui/home/home_view_model_test.dart` | Loading progress, storage failure, welcome once, replay, voice on/off, unavailable voice |
| `test/ui/home/home_screen_test.dart` | Destinations, explorer log, navigation to each page and back, Parent Zone |
| `test/ui/home/home_voice_test.dart` | Welcome once (not after navigation or resume, not when off); "Hear again"; voice off/on; speech stops on navigation, back, app inactive and close; a slow-starting welcome never plays on another screen; no-engine and engine-error fallbacks |
| `test/ui/home/home_conversation_test.dart` | Ideas and typed questions answered and spoken; Ask disabled when empty; keyboard send; Stop talking; Talking badge; activity buttons open screens (never automatically); personal info hidden; honest unknown answer; Talk button never touches the mic; navigating away stops speech; ideas wrap at 2x text |
| `test/ui/home/buddy_chat_view_model_test.dart` | Thinking state and repeat-submission guard; new question interrupts; stop; replay; voice off; hidden personal info; provider failure and recovery; length cap; nothing written to storage; dispose |
| `test/domain/conversation/child_safety_filter_test.dart` | Personal info, self-harm, bullying, medical and off-limits detection; ordinary questions (incl. big numbers, look-alike words) pass |
| `test/domain/conversation/curated_response_provider_test.dart` | Starter prompts, brief example, matching, rotation, quiz/adventure actions, honesty about being a computer, fallback, safety precedence; content rules over every answer |
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
- [ ] Launcher shows the Buddy icon (not the Flutter logo) with the name
      "Curious Buddy".
- [ ] Home: Buddy waves once; tapping Buddy makes him excited (arms up,
      eyes squeezed) and then he settles.
- [ ] Each Home card opens its "coming soon" page; the back arrow and
      "Back to Home" both return to Home.
- [ ] "Grown-ups" opens the Parent Zone placeholder.
- [ ] **Voice** (media volume up, phone not on silent-media):
  - [ ] Buddy says the welcome once on a fresh start (force-stop first).
  - [ ] Visiting a card and coming back does not repeat it.
  - [ ] "Hear again" repeats it; tapping it mid-sentence restarts cleanly,
        no overlap.
  - [ ] Tapping a card mid-sentence stops speech at once.
  - [ ] Pressing Home or opening the app switcher mid-sentence stops speech.
  - [ ] "Voice off" stops speech at once and hides "Hear again"; "Voice on"
        brings it back without talking by itself.
  - [ ] Voice off, visit a card, come back: still off.
  - [ ] Settings → General management → Text-to-speech → Preferred engine
        disabled/removed (or no English voice): Home shows the read-along
        note and no voice buttons, and nothing crashes.
  - [ ] No permission prompt appears at any point.
- [ ] **Talking with Buddy:**
  - [ ] Each of the five ideas gets a spoken answer; "You asked" shows
        the question; new follow-up ideas appear.
  - [ ] "Talking..." shows under Buddy while he speaks; "Stop talking"
        stops at once; "Hear again" repeats the answer.
  - [ ] Tapping a second idea mid-answer cuts off the first; no overlap.
  - [ ] Type a question, press the keyboard's send key: it is answered and
        the box clears. "Ask" is greyed out when the box is empty.
  - [ ] "Let's play a quiz." → "Peek at quizzes" opens the Quiz Time page.
        "Take me on an adventure." → "Open Mystery Missions" works.
        Nothing opens until the button is tapped.
  - [ ] Type "my phone number is 07700 900123": the number is not shown;
        Buddy says to keep it private.
  - [ ] Type something unknown ("capital of Mongolia"): Buddy says he does
        not know yet.
  - [ ] "Talk to Buddy" shows "Talking is coming soon!"; no microphone
        prompt; "Type instead" opens the keyboard.
  - [ ] Voice off: answers still appear, Buddy stays silent.
  - [ ] Largest font size: ideas wrap onto two lines rather than being cut.
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
