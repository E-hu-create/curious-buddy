# Roadmap

Each phase ends with `tool\verify.ps1` passing, the real-device checklist in
TESTING.md completed, and a commit. Do not start a phase until the previous
one is approved.

## Phase 0: Engineering foundation ✅

Git, lint and analysis rules, layered folder structure, voice and progress
interfaces, tests, documentation. Gradle heap set to 3 GB. Verified on a
Samsung SM-A516U.

## Phase 1: App shell and Home ✅

- ✅ Home and exploration screen with view model and tests.
- ✅ Navigation to placeholder feature screens and a Parent Zone placeholder
  (no settings yet; the parent gate comes in Phase 6).
- ✅ Theme: flat sticker style, child-friendly colours, 56dp touch targets.
- ✅ Buddy redesigned per the mascot brief: a teal creature with a golden
  backpack, drawn in code with six moods (interim, see MASCOT.md).
- ✅ Android app label "Curious Buddy".
- ⏳ Permanent application ID: still `com.example.curious_buddy` by choice.
  Must be decided before anyone outside the team installs a build.
- ✅ Launcher icon generated from Buddy (Android legacy + adaptive).
- ⏳ Final mascot art (premium 3D renders) from an artist or a tool with
  clear usage rights; see MASCOT.md for the spec and integration plan.

## Phase 2: Buddy voice output ✅

Swapped ahead of persistent progress at the product owner's request.

- ✅ `FlutterTtsService` on the device's built-in engine (`flutter_tts`).
- ✅ `BuddyVoice`: one app-wide voice with on/off setting and
  welcome-once-per-session.
- ✅ Spoken welcome on launch; "Hear again" and "Voice off / Voice on" on Home.
- ✅ Speech stops on navigation, when the app is hidden or interrupted, and
  on close.
- ✅ Text fallback when no engine or voice is installed, or speech fails.
- ⏳ Voice on/off is remembered only for the current session until
  Phase 3 adds persistent storage (the code already saves it through
  `KeyValueStore`).

## Voice companion: Stage A, interface and interaction ✅ (awaiting review)

- ✅ Home built around Buddy: bubble with "You asked", Buddy's answer,
  "Thinking..." / "Talking..." status, Stop talking, Hear again, Voice off/on.
- ✅ Text box and suggested ideas; follow-up ideas after each answer.
- ✅ Reviewed offline answers (`CuratedResponseProvider`) behind
  `EducationalResponseProvider`; honest fallback for unknown questions.
- ✅ `ChildSafetyFilter`: personal information (hidden on screen),
  self-harm, bullying, medical and off-limits topics redirect to a grown-up.
- ✅ Fixed set of `BuddyAction`s mapped to existing screens; the child taps
  to open them. Quiz is a placeholder page.
- ✅ "Talk to Buddy" is an honest placeholder; never touches the microphone.
- ✅ Conversations are never saved.

## Voice companion: Stage B, tap-to-talk (proposal, needs approval)

See [STAGE_B_VOICE_INPUT.md](STAGE_B_VOICE_INPUT.md).

## Voice companion: Stage C, smarter answers (needs approval)

- Architecture and safety review first; any external AI provider only
  behind a backend that holds the keys, filters input and output, and stores
  nothing. Not started.

## Phase 3: Persistent progress and settings

- Add `shared_preferences`; implement `KeyValueStore`.
- Wire `ProgressRepository` into Home. Voice on/off then survives restarts.
- Device test: progress and voice setting survive force-stop.

## Phase 4: Mystery missions and learning games

- First mission with scripted content.
- Mission completion updates progress.

## Phase 5: Living Stories

- Narrated stories with replay and page controls.

## Phase 6: Parent Zone

- Parent gate, settings (voice on/off), progress reset, data overview.

## Phase 7: Creative Island

- Local-only creative activities; deletion from Parent Zone.

## Later, each needing an approved requirement

- `EducationalResponseProvider` beyond scripted answers (AI backend).
- Release signing, store listings, privacy policy.
- iOS builds (needs macOS + Xcode).
