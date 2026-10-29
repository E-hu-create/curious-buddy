# Roadmap

Each phase ends with `tool\verify.ps1` passing, the real-device checklist in
TESTING.md completed, and a commit. Do not start a phase until the previous
one is approved.

## Phase 0: Engineering foundation ✅ (awaiting approval)

Git, lint and analysis rules, layered folder structure, voice and progress
interfaces, tests, documentation.

## Phase 1: App shell and Home

- Decide the real application ID (replace `com.example.curious_buddy`) and
  app name/icon before anything is installed by testers.
- Home and exploration screen with view model and tests.
- Navigation to placeholder feature screens.
- Theme: child-friendly colours, typography, large touch targets.

## Phase 2: Persistent progress

- Add `shared_preferences`; implement `KeyValueStore`.
- Wire `ProgressRepository` into Home.
- Device test: progress survives force-stop.

## Phase 3: Buddy voice output

- Add a TTS package; implement `TextToSpeechService`.
- Use `Narrator` in Home and missions. Text always visible.
- Device tests for interruption, replay and missing voices.

## Phase 4: Mystery missions and learning games

- First mission with scripted content.
- Mission completion updates progress.

## Phase 5: Living Stories

- Narrated stories with replay and page controls.

## Phase 6: Parent Zone

- Parent gate, settings (voice on/off), progress reset, data overview.

## Phase 7: Optional push-to-talk

- Only after the privacy review in CHILD_SAFETY.md.
- Implement `SpeechRecognitionService`; permission requested only on tap.
- Denied-permission and unavailable paths tested on a device.

## Phase 8: Creative Island

- Local-only creative activities; deletion from Parent Zone.

## Later, each needing an approved requirement

- `EducationalResponseProvider` beyond scripted answers (AI backend).
- Release signing, store listings, privacy policy.
- iOS builds (needs macOS + Xcode).
