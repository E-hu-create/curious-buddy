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
- ✅ Android cloud backup off. Data-extraction rules also leave data out of
  phone-to-phone transfers, though some phone makers may not honour them
  (see CHILD_SAFETY.md).
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

## My Discoveries ✅

- ✅ Explorer journal: rank, summary read by Buddy, totals, mission badges,
  story discoveries, quiz stars and recent creations.
- ✅ One next-adventure suggestion with a button.
- ✅ Endings not yet found are never shown.
- ✅ Saves nothing of its own, so the Parent Zone reset empties it.
- ✅ Every Home card now opens a real feature.
- ✅ Device test on the Samsung SM-A516U: the My Discoveries checks in
  TESTING.md passed (confirmed 30 Oct 2026).

## Look and feel ✅

- ✅ Bundled rounded font (Nunito), with its licence.
- ✅ Gentle page changes, sliding story pages and quiz questions, stickers
  that sink when pressed.
- ✅ Pop for right answers, shake for wrong ones, stars one by one, Buddy
  hops, and confetti for the big moments.
- ✅ Bolder page titles; the last Home card fills its row.
- ✅ Splash: Buddy and the app name on the app's own colour, the same in dark
  mode, with no flash into the app.
- ✅ All of it follows Calmer animations and the phone's Remove animations.
- ✅ Device test on the Samsung SM-A516U: motion, font and splash confirmed
  as good by the product owner (30 Oct 2026).

## Buddy's Wardrobe ✅ (awaiting device test)

- ✅ 10 items (hats, glasses, neckwear) earned through missions, stories,
  quizzes and creations; locked items show how to earn them.
- ✅ Buddy wears his outfit on every screen.
- ✅ Saved with progress (schema 5), shown in the Parent Zone, and cleared by
  its reset.
- ✅ Home card (six cards now) and Buddy's answer open it.
- ⏳ Device test on the Samsung SM-A516U.

## Sound effects ✅ (awaiting device test)

- ✅ Four original sounds (pop, chime, soft notes, fanfare), generated in the
  repo and played with Android's built-in SoundPool: no new package.
- ✅ Never play over Buddy: he speaks when the sound has finished.
- ✅ Parent Zone switch, remembered, separate from Buddy's voice.
- ⏳ Device test on the Samsung SM-A516U, including how the sounds actually
  sound.

## Game Zone: Buddy's Challenge Arena ✅ (awaiting device test)

- ✅ Game Zone Home card, and Buddy's answer opens it.
- ✅ Memory Match, Pattern Power and Spot the Change, three levels each.
- ✅ Quick Create: drawing ideas, never scored.
- ✅ No timers; wrong moves lose nothing.
- ✅ Stars saved on the device (progress schema 6), counted in My Discoveries,
  shown and cleared in the Parent Zone; Champion cap in the Wardrobe.
- ⏳ Device test on the Samsung SM-A516U.

## Game Zone: Dino Discovery ✅ (confirmed on device)

- ✅ Three prehistoric places with drawn scenes and nine drawn creatures.
- ✅ Search spots, identifying from clues, and a short mission for each place.
- ✅ Field Guide, filled in by finishing each place, read aloud on request.
- ✅ Stars saved on the device, counted in My Discoveries, cleared by Delete
  all progress.
- ✅ Memory Match cards now show 12 drawn pictures.
- ⏳ Grown-up review of the creature facts.
- ✅ Confirmed working on the Samsung SM-A516U by the product owner (2026-10-30).

## Game Zone: look and instructions ✅ (awaiting device test)

- ✅ Night-sky menus, big game tiles, scoreboard with stars and ranks.
- ✅ Level map of numbered buttons in the Arena.
- ✅ How to play for every game: read aloud, automatic on a first game, and
  available from each menu and during play.
- ⏳ Device test on the Samsung SM-A516U.

## Game Zone: Treasure Maze ✅ (awaiting device test)

- ✅ A new maze every game, three sizes, arrows and swiping.
- ✅ Gems for stars; the chest finishes; no clock; walls cost nothing.
- ⏳ Device test on the Samsung SM-A516U.

## Game Zone: Code the Robot ✅ (awaiting device test)

- ✅ New solvable puzzles every game, three levels of three puzzles.
- ✅ Write code with arrows, run it, see each line, and fix mistakes.
- ✅ Twice on Expert, for a first taste of repeats.
- ⏳ Device test on the Samsung SM-A516U.

## Game Zone: Word Builder ✅ (awaiting device test)

- ✅ 35 science and nature words in three levels, five in each game.
- ✅ Clues read aloud, pictures for some words, hints, and fixing mistakes.
- ⏳ Grown-up review of the clues.
- ⏳ Device test on the Samsung SM-A516U.

## Game Zone: What's That Sound? ✅ (awaiting device test)

- ✅ 13 real CC0 recordings, approved by the product owner (see
  `docs/SOUNDS.md`), with drawings, written clues and facts.
- ✅ Three levels of five sounds; replay as often as you like.
- ✅ Playable with sounds off, or without being able to hear them.
- ⏳ Listening check: the clips were prepared by measuring them, not by ear.
- ⏳ Grown-up review of the facts.
- ⏳ Device test on the Samsung SM-A516U.

## Ten more Living Stories ✅ (awaiting device test)

- ✅ The Whale Who Lost Her Song, The Secret of the Six-Sided Snowflake, The Bee
  Who Danced a Map, The Dragon Who Sneezed Bubbles, The Library of Old
  Starlight, The Mountain That Kept Warm, The Little Seed's Long Journey, Rusty
  and the Dusty Solar Panels, The Mystery in the Cliff and The Great Butterfly
  Journey, thirteen stories in all.
- ✅ Each has branching choices, three endings and its own drawn pictures.
- ⏳ Grown-up review of the science.
- ⏳ Device test on the Samsung SM-A516U.

## Seven more Mystery Missions ✅ (awaiting device test)

- ✅ The Puddle That Vanished, The Lighthouse That Went Dark, The Mystery
  Postcards, The Strange Tracks on the Beach, The Case of the Flat Loaf, The
  Quiet Orchard and The Case of the Shrinking Shadow, ten missions in all.
- ✅ Real science, a drawn cover and a badge for each.
- ⏳ Grown-up review of the science.
- ⏳ Device test on the Samsung SM-A516U.

## Stronger logo ✅ (awaiting device test)

- ✅ App icon: Buddy on a golden sun, on the Game Zone night sky.
- ✅ Home: `AppLogo` replaces the plain name.
- ✅ Splash: the sun behind Buddy, and a two-colour name.
- ⏳ Device test on the Samsung SM-A516U, including how the icon looks on the
  phone's home screen.

## Game Zone: six more games

- ✅ Four in a Row against Buddy (awaiting device test).
- ✅ Number Pop (awaiting device test).
- ✅ Sort It! (awaiting device test, and a grown-up review of its sorting).
- ✅ Circuit Fixer (awaiting device test).
- ✅ Picture Sudoku (awaiting device test).
- ✅ Planet Parade (awaiting device test, and a grown-up review of its facts).

## Later, each needing an approved requirement

- `EducationalResponseProvider` beyond scripted answers (AI backend).
- Release signing, store listings, privacy policy.
- iOS builds (needs macOS + Xcode).
