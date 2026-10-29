# Roadmap

Each phase ends with `tool\verify.ps1` passing, the real-device checklist in
TESTING.md completed, and a commit. Do not start a phase until the previous
one is approved.

## Phase 0: Engineering foundation ✅

Git, lint and analysis rules, layered folder structure, voice and progress
interfaces, tests, documentation. Gradle heap set to 3 GB. Verified on a
Samsung SM-A516U.

## Phase 1: App shell and Home ✅ (awaiting review)

- ✅ Home and exploration screen with view model and tests.
- ✅ Navigation to placeholder feature screens and a Parent Zone placeholder
  (no settings yet; the parent gate comes in Phase 6).
- ✅ Theme: flat sticker style, child-friendly colours, 56dp touch targets.
- ✅ Buddy drawn in code with three moods and a one-shot wave.
- ✅ Android app label "Curious Buddy".
- ⏳ Permanent application ID: still `com.example.curious_buddy` by choice.
  Must be decided before anyone outside the team installs a build.
- ⏳ Launcher icon: still the Flutter default. Planned: a Buddy icon.

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
