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
- ✅ Permanent Android application ID: `io.github.e_hu_create.curiousbuddy`
  (based on the developer's GitHub account; replaces the template's
  `com.example.curious_buddy`). Never change it after publishing. iOS,
  macOS, Linux and Windows still use template IDs (not built yet).
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
- ✅ Voice on/off is remembered across restarts (Phase 3).

## Voice companion: Stage A, interface and interaction ✅

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

## Voice companion: Stage B, tap-to-talk ✅ (awaiting review)

- ✅ `speech_to_text` 7.4.0; `RECORD_AUDIO` + `INTERNET`, no Bluetooth.
- ✅ Explanation before the permission prompt; live words; Done / Cancel;
  words go in the text box for checking, never sent automatically.
- ✅ On-device only unless a grown-up allows online (enforced with an
  Android check, because the plugin would silently fall back online).
- ✅ Minimal Parent Zone: parent check + "Allow online voice recognition".
- ✅ Cancelled on navigation, interruptions and close.
- ⏳ Privacy and legal review before external testers (agreed).
- ✅ Settings remembered across restarts (Phase 3).

Details: [STAGE_B_VOICE_INPUT.md](STAGE_B_VOICE_INPUT.md).

## Voice companion: Stage B, review ⏳

Stage B's tap-to-talk awaits phone testing and review.

## Voice companion: Stage C, smarter answers

See [STAGE_C_SMARTER_ANSWERS.md](STAGE_C_SMARTER_ANSWERS.md).

- ✅ Option A (awaiting review): about 120 reviewed offline topics, forgiving
  but guarded matching, pinned answers, honest "not sure" lead-ins.
- ⏳ Option C (cloud AI behind an app-owned backend): only after the
  legal/privacy review, a provider and backend owner, and a parental
  consent approach are decided. Not started.

## Phase 3: Persistent progress and settings ✅

- ✅ `shared_preferences` 2.5.6; `SharedPreferencesKeyValueStore` behind
  `KeyValueStore`. No other code changed.
- ✅ Progress, voice on/off and the grown-up "allow online" setting survive
  restarts.
- ✅ Android cloud backup off, so data stays on the phone.
- ✅ Storage failures (even plugin errors) fall back safely.
- ✅ Device test: settings survive force-stop (confirmed on the Samsung
  SM-A516U, 29 Oct 2026).

## Phase 4: Mystery Missions ✅

- ✅ Missions landing screen with drawn covers, points, badges and status.
- ✅ Three offline missions with different mechanics: The Missing Moonstone
  (evidence and inconsistent statements), The Secret of the Wilting Garden
  (real plant science: fair test and overwatering), The Case of the
  Mixed-Up Signals (patterns, logic ordering, shift code).
- ✅ Clue inspection, pick one / pick all / put in order, progressive hints,
  explanations, encouraging feedback; finishable without a perfect score.
- ✅ Buddy narrates, reads clues on request, Hear again / Stop talking;
  speech stops on leaving; microphone never used.
- ✅ Transparent points (never reduced by hints or mistakes), badges, best
  score saved on the device, replay.
- ✅ Content validated; invalid missions are left out.
- ✅ Device test on the Samsung SM-A516U (confirmed 29 Oct 2026).
- Later: more missions; partial progress inside a mission is not saved
  (leaving restarts the case).

## Phase 5: Living Stories ✅

- ✅ Stories shelf with drawn covers, endings found per story and overall.
- ✅ Three original branching stories, 8 or 9 scenes and 4 endings each:
  The Forest That Forgot Its Colours (light and rainbows), The Lost Signal
  from Planet Luma (signals, prime numbers, solar power, gravity), The Tiny
  Inventor's Big Idea (testing, pulleys, counterweights, teamwork).
- ✅ Consequence line after each choice; every ending is a good one, just
  different; no loops, every path ends (validated and tested).
- ✅ Buddy reads the intro, each page, and the choices on request; Hear
  again / Stop talking; a new page interrupts the old one; speech stops on
  leaving; microphone never used; all text on screen.
- ✅ 12 scenes drawn in code with three characters and a look per story.
- ✅ Endings found and the place in an unfinished story saved on the device
  (progress schema 3); Continue / Start again / Try a different path.
- ✅ Invalid stories are left out.
- ✅ Device test on the Samsung SM-A516U: all 11 checks in TESTING.md
  passed (confirmed 29 Oct 2026).
- Later: more stories; a "go back one page" button.

## Phase 6: Parent Zone ✅

- ✅ Parent check: a multiplication in words, new every try, a 60-second
  pause after three wrong answers, asked every time and again after the app
  is hidden; its limits are explained; nothing personal asked.
- ✅ Settings: Buddy talks, speaking speed, read aloud automatically,
  online voice recognition (explained as online, not on-device), calmer
  animations; all saved on the phone; Back to Buddy.
- ✅ "What's saved on this phone": every stored record with live values,
  why it is kept and whether reset deletes it; what is only in memory;
  what is never collected; where it is kept; what leaves the phone.
- ✅ Delete all progress: two steps (what is deleted and kept, then type
  DELETE), optional restore of default settings, storage checked
  afterwards, failure reported honestly.
- ✅ Fixed on the way: saved settings now load at start-up, so the Parent
  Zone never shows a default before the saved value.
- ✅ Device test on the Samsung SM-A516U: all 13 Parent Zone checks in
  TESTING.md passed (confirmed 29 Oct 2026).
- ⏳ Before external testers: privacy/legal review, privacy policy,
  permanent application ID (see CHILD_SAFETY.md).

## Quiz Time ✅

Built before Creative Island at the product owner's request.

- ✅ Quiz Time card on Home; Buddy's "Let's play a quiz." opens it.
- ✅ 60 reviewed offline questions: Space, Animals, Amazing Body, Earth &
  Weather, each with Starter, Explorer and Expert levels of 5 questions.
- ✅ One pick per question, immediate feedback with the right answer and an
  explanation; answers shuffled each round.
- ✅ Stars (5 = 3, 4 = 2, 3 = 1); the next level opens at 3 of 5; best
  scores kept on the device (progress schema 4); Play again and Next level.
- ✅ Buddy reads questions, answers, results and the summary; follows the
  Parent Zone voice settings; stops on leaving; no microphone.
- ✅ Quiz results in the Parent Zone overview and deleted by its reset.
- ✅ Device test on the Samsung SM-A516U: the Quiz Time checks in TESTING.md
  passed (confirmed 29 Oct 2026).
- ⏳ Grown-up review of the quiz questions before external testers.
- Later: more questions per level, so replays vary more.

## Phase 7: Creative Island ✅

- ✅ Creative Island page with activities and a My Creations shelf.
- ✅ Drawing Studio: finger drawing with 8 colours, 3 brushes, eraser, undo,
  Start over; strokes draw instead of scrolling the page.
- ✅ Creature Maker: shape, colour, eyes, mouth, extra and pattern; Surprise
  me; names from a reviewed list; Buddy shares real facts.
- ✅ Shelf of up to 12 creations; view, and remove with a check; saved on
  the device under their own key.
- ✅ No typing, camera, photos, export or sharing, and no new permissions.
- ✅ Buddy's voice follows the Parent Zone settings; no microphone.
- ✅ Creations in the Parent Zone overview and deleted by its reset.
- ✅ Device test on the Samsung SM-A516U: the Creative Island checks in
  TESTING.md passed (confirmed 30 Oct 2026).
- Later: Invention Workshop (combine problem, power and parts cards).

## My Discoveries ✅ (awaiting device test)

- ✅ Explorer journal: rank, summary read by Buddy, totals, mission badges,
  story discoveries, quiz stars and recent creations.
- ✅ One next-adventure suggestion with a button.
- ✅ Endings not yet found are never shown.
- ✅ Saves nothing of its own, so the Parent Zone reset empties it.
- ✅ Every Home card now opens a real feature.
- ⏳ Device test on the Samsung SM-A516U.

## Later, each needing an approved requirement

- `EducationalResponseProvider` beyond scripted answers (AI backend).
- Release signing, store listings, privacy policy.
- iOS builds (needs macOS + Xcode).
