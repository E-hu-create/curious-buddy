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
| `test/domain/models/learner_progress_test.dart` | Progress JSON validation and versioning; story endings and bookmarks (schema 3), older data, malformed entries |
| `test/data/repositories/progress_repository_test.dart` | Save/load, corrupt-data backup and recovery, storage errors |
| `test/domain/voice/narrator_test.dart` | Narration, interruption, replay, unavailable and failing engines |
| `test/domain/voice/buddy_voice_test.dart` | Availability, welcome once, replay, interrupting, stop, dispose, mute stops/silences/saves/restores, storage failures |
| `test/data/services/voice/flutter_tts_service_test.dart` | Voice selection and fallback language, missing plugin, completion, engine error (no hang), rejected speak, stop, timeout (simulated plugin channel) |
| `test/ui/home/home_view_model_test.dart` | Loading progress, storage failure, welcome once, replay, voice on/off, unavailable voice |
| `test/ui/home/home_screen_test.dart` | Destinations, explorer log, navigation to each page and back, Parent Zone |
| `test/ui/home/home_voice_test.dart` | Welcome once (not after navigation or resume, not when off); "Hear again"; voice off/on; speech stops on navigation, back, app inactive and close; a slow-starting welcome never plays on another screen; no-engine and engine-error fallbacks |
| `test/ui/home/home_conversation_test.dart` | Ideas and typed questions answered and spoken; Ask disabled when empty; keyboard send; Stop talking; Talking badge; activity buttons open screens (never automatically); personal info hidden; honest unknown answer; navigating away stops speech; ideas wrap at 2x text |
| `test/ui/home/home_talk_test.dart` | No recogniser calls at launch or in normal use; explanation before prompt; Not now / OK; denied notice and no re-prompt; listening UI, live words, draft for checking (not auto-sent), Done keeps / Cancel discards; Hear again, typing and ideas disabled while listening; Buddy stops talking first; cancelled on navigation, interruption and close; nothing heard / network / error / unavailable notices; on-device default, offline-unavailable notice, online when a grown-up allows |
| `test/domain/voice/buddy_listener_test.dart` | Touches nothing when created; one session at a time; live words; stops voice first; stop vs cancel; dispose; allow-online default, save, restore, unreadable |
| `test/data/services/voice/speech_to_text_recognition_service_test.dart` | Fake plugin engine: check never prompts, request via initialize, denied, no recogniser, unsupported platform; final/partial results, done status, no match, network, stop/cancel, idle safety, one session, safety timer; refuses without on-device unless online allowed; language pack missing; lazy plugin creation |
| `test/domain/parent/parent_gate_test.dart` | Numbers in words; questions vary; right/wrong answers; new question after a wrong one; pause after three wrong answers and its end; right answer resets the count |
| `test/domain/voice/buddy_voice_settings_test.dart` | Speed applied, saved, restored; unknown speed; automatic reading off speaks only requested lines and still silences old speech; restored after restart; storage failure defaults |
| `test/domain/settings/display_settings_test.dart` | Calmer animations default, saved, restored, storage failure |
| `test/ui/parent_zone/parent_zone_view_model_test.dart` | Summary counts; backup detection; storage error; reset deletes every record and keeps settings; reset with default settings; nothing restored afterwards; failed delete reported |
| `test/ui/parent_zone/parent_zone_screen_test.dart` | Gate: hidden settings, nothing personal asked, wrong answer, pause survives reopening, asked every time, relocks when hidden, Back to Buddy. Settings: voice, speed, automatic reading, online recognition (explained, off by default), calmer animations applied app-wide, all survive restart, automatic reading off in a story, no microphone. Overview from real storage. Reset: step 1 lists counts, cancel at either step, DELETE required, deletes all and keeps settings, optional defaults, Home/missions/stories cleared, app restart, storage failure |
| `test/ui/parent_zone/parent_zone_accessibility_test.dart` | Guidelines on the check, settings and both reset dialogs; no overflow on small phones and 2x text |
| `test/data/services/shared_preferences_key_value_store_test.dart` | Save / read / delete, survives a new store ("restart"), keys independent, lazy creation, plugin errors become `StorageException`, real app uses device storage |
| `test/ui/home/home_restart_test.dart` | Voice off and back on remembered across app restarts; saved progress shown after restart; grown-up online setting remembered |
| `test/domain/missions/mission_content_test.dart` | Three valid missions; every step solvable; mixed mechanics; wrong choices explain; content safe; puzzle logic computed (shift code, decoys, doubling, beep pattern, word-order uniqueness, timeline, garden clues) |
| `test/domain/missions/mission_rules_test.dart` | Evaluator for single / multi / order (wrong pick, missing, misplaced, incomplete); scoring (hints never cost, mistakes only skip bonus, max); validator rejects bad stages and missions |
| `test/data/repositories/mission_repository_test.dart` | Loads three missions offline; leaves out invalid and duplicate missions; empty catalogue |
| `test/ui/missions/mission_play_view_model_test.dart` | Intro narration; clues; hints; check/retry; locking; next; order editing; shuffle never pre-solved; each mission finished, scored and saved; finishing with mistakes; replay keeps best; failed save; Hear again / Stop; dispose stops speech; voice off |
| `test/ui/missions/missions_screen_test.dart` | Home opens real Missions; loading, empty, error; full play-throughs; hints and wrong answers; saved, solved, best score, replay; Play again; leaving and Stop silence Buddy; no microphone; Home shows new points |
| `test/ui/missions/missions_accessibility_test.dart` | Tap target, label and contrast guidelines on list and step; every step of a mission without overflow on small phones and 2x text |
| `test/domain/stories/story_content_test.dart` | Three valid stories; several scenes and at least two endings each; every ending reachable; every path ends without repeating a scene; distinct pictures per story; consequence lines without lecturing; no personal questions |
| `test/domain/stories/story_rules_test.dart` | Validator rejects missing text, missing start, missing targets, duplicate ids, invalid ids, fewer than two endings, fake branching, dead ends, endings with choices, self-loops, multi-scene loops, unreachable scenes and endings, over-long text; graph reachability, path count, saved-path checks |
| `test/data/repositories/story_repository_test.dart` | Loads three stories offline; leaves out invalid and duplicate stories; empty catalogue |
| `test/ui/stories/story_play_view_model_test.dart` | Intro and scene narration; choices and consequences; invalid and out-of-place choices ignored; ending recorded, new vs found before; bookmark saved each page; resume; invalid saved paths start fresh; restart; replay finds other endings; every ending reachable by choosing; read the choices; Hear again / Stop; new page interrupts; dispose stops speech; voice off; failed save; saves in order |
| `test/ui/stories/stories_screen_test.dart` | Home opens real Stories; loading, empty, error, broken content left out; full read to an ending; endings on the card; different path; found before; continue after leaving and after an app restart; Start again; stale bookmark ignored; leaving, page turns and Stop silence Buddy; Read the choices; no speech engine; no microphone; Home shows the finished story |
| `test/domain/quiz/quiz_content_test.dart` | Four topics, three levels of five; unique level ids; every topic valid; right answers in varied positions; no repeated questions; facts match Buddy's answers; no personal questions |
| `test/domain/quiz/quiz_rules_test.dart` | Pass mark, stars for every score, level unlocking, next level; validator rejects missing levels/questions, repeated ids, wrong answer counts, repeated answers, missing text, "all of the above", long text, invalid ids |
| `test/data/repositories/quiz_repository_test.dart` | Loads four topics offline; leaves out invalid topics, repeated topic ids and repeated level ids; empty catalogue |
| `test/ui/quiz/quiz_play_view_model_test.dart` | Question narration; shuffling keeps every answer and never the written order; right and wrong feedback; one pick only; next; stars for every score; save and best kept; next level opens and is announced once; last level; play again; failed save; read question/answers; automatic reading off; voice off; dispose stops speech |
| `test/ui/quiz/quiz_screen_test.dart` | Home card; four topics with locks; loading, empty, error; right/wrong answers; no second try; perfect round, summary, Next level; stars and open levels back on Quiz Time; not passing; Play again; app restart; explorer log; Parent Zone shows and deletes quiz results; leaving and Stop silence Buddy; Read the answers; no speech engine; no microphone |
| `test/ui/quiz/quiz_accessibility_test.dart` | Guidelines on Quiz Time, a question, its result and the summary; lettered answer labels; every question of every level without overflow on small phones and 2x text |
| `test/domain/creative/creation_shelf_test.dart` | Saving and reading drawings and creatures; unusable data; bad entries, unlisted names, out-of-range points and over-cap drawings dropped; shelf limit; ids never reused; creature names (unique, short, word list); a fact for every creature |
| `test/data/repositories/creations_repository_test.dart` | Add, ids, remove, full shelf, backup of unreadable data, clear leaves other data, storage errors |
| `test/ui/creative/creative_view_models_test.dart` | Strokes, tiny moves dropped, canvas bounds, dots, colours and sizes, eraser, undo, clear, point cap, save and lock, Draw another, full shelf, failed save; creature parts, facts, Surprise me, New name, save, Make another; narration, automatic reading off, voice off, dispose stops speech; shelf order, remove, storage error |
| `test/ui/creative/creative_screen_test.dart` | Real Creative Island from Home; storage error; vertical strokes draw instead of scrolling; Save enabled only with a drawing; tools; Undo and Start over; saved flow; leaving stops speech; building and saving a creature; no text boxes anywhere; New name, Surprise me; view and remove with confirmation; full shelf; app restart; explorer log; Buddy's button; Parent Zone shows and deletes creations; no speech engine; no microphone |
| `test/ui/creative/creative_accessibility_test.dart` | Guidelines on the page, both activities and the viewer; canvas and creation labels; every creature described and painted; no overflow on small phones and 2x text |
| `test/domain/discoveries/discovery_journal_test.dart` | Empty journal; counting; pass mark for stars; unknown ids ignored; only found endings included; every rank threshold; top rank reachable; summary wording; next-adventure choices; sections left out when content fails |
| `test/ui/discoveries/discoveries_screen_test.dart` | New and busy journals; narration; no spoilers; speaker reads a discovery; next adventure opens the right place and the journal updates; Buddy's button; saves nothing; retry; partial failure; parent reset, including after a restart; leaving and Stop silence Buddy; no speech engine; no microphone |
| `test/ui/discoveries/discoveries_accessibility_test.dart` | Guidelines on new and busy journals; latest four creations; no overflow on small phones and 2x text |
| `test/android/splash_test.dart` | Splash colour matches the app; Android 12+ shows Buddy and the name; same in dark mode; no white or black flash; older Android matches; all images for every density |
| `test/android/backup_rules_test.dart` | Manifest turns backup off and links the data-extraction rules; cloud backup and device transfer exclude every data location; the Parent Zone wording does not over-promise |
| `test/ui/core/widgets/motion_test.dart` | Confetti and phone tap only at the right moments (perfect quiz, new ending, saved creation, new rank; not for mistakes or repeat endings); confetti ignores touch and screen readers, and ends by itself; calm settings skip everything; stars pop in; bundled font and licence; bold headings; last Home card fills its row |
| `test/domain/wardrobe/wardrobe_test.dart` | Unlocking from each activity; everything earnable; progress text; one item per slot; saved form and bad entries; schema 5; BuddyWardrobe saving, restart, reset, storage failure |
| `test/ui/wardrobe/wardrobe_screen_test.dart` | Locked items and how to earn them; wearing and taking off; locked items cannot be worn; Buddy matches on other screens; restart; Buddy's button; storage error; Parent Zone shows and clears the outfit; speech stops; no microphone; every item painted in every mood; accessibility; no overflow |
| `test/domain/voice/sound_effects_test.dart` | A sound plays before Buddy speaks; old speech stops first; stop and newer lines cancel the wait; works with voice off; sounds off; remembered; small effects skipped during speech; which moments play what; defaults; files exist and match their lengths in the code; native player knows every effect |
| `test/domain/games/games_test.dart` | Levels and unlocking; star totals; Memory dealing, pairs, mismatches staying visible, stars; pattern content and number rules checked by calculation; validator; Spot differences, taps, stars; Quick Create ideas |
| `test/ui/games/games_screens_test.dart` | View models for all three games, saving, best kept, failed save, speech stops; saved-data format; journal and Wardrobe link; Home to Arena; coming-soon labels; Buddy's button; all three games played through the screens; level opening; restart; Quick Create; full shelf; storage error; no typing or microphone; Parent Zone shows and deletes results; accessibility; no overflow at every level |
| `test/domain/games/dino_test.dart` | Fairness checks on the content; places and saved ids; opening places; Field Guide; expedition stages, stars, clues, wrong picks, out-of-turn taps, missions; Memory pictures |
| `test/ui/games/dino_screens_test.dart` | View model speech, sounds, saving, failed save, speech stops; hub; every place played through the screens; creatures appear in the scene; wrong picks; next place; Field Guide stays secret and reads aloud; storage error; no typing or microphone; accessibility; no overflow |
| `test/domain/games/maze_test.dart` | Every cell reachable by one route; passages match; gems and chest placed fairly; levels grow; walls; running; gems; stars |
| `test/ui/games/maze_screens_test.dart` | Saving, wall bumps, a new maze on replay; arrows reach the chest; swipes; Game Zone tile |
| `test/ui/games/how_to_play_test.dart` | Short steps for every game; opens by itself the first time only; help button during a game; menu buttons; closing stops Buddy; ranks; scoreboard; storage error; accessibility; no overflow |
| `test/ui/stories/stories_accessibility_test.dart` | Tap target, label and contrast guidelines on the shelf, intro, a choice page and an ending; numbered choice labels; picture descriptions; every page of every story without overflow on small phones and 2x text |
| `test/ui/home/buddy_chat_view_model_test.dart` | Thinking state and repeat-submission guard; new question interrupts; stop; replay; voice off; hidden personal info; provider failure and recovery; length cap; nothing written to storage; dispose |
| `test/domain/conversation/child_safety_filter_test.dart` | Personal info, self-harm, bullying, medical and off-limits detection; ordinary questions (incl. big numbers, look-alike words) pass |
| `test/domain/conversation/curated_response_provider_test.dart` | Starter prompts, brief example, matching, rotation, quiz/adventure actions, honesty about being a computer, fallback, safety precedence; content rules over every answer |
| `test/domain/conversation/curated_matching_test.dart` | About 55 real questions and the topic each must reach; specific beats broad; typo and plural forgiveness; misfire guards ("planes", "trains", "plants"); pinned answers; honest "not sure" lead-ins vs fact requests; lead-ins within 60 words; pinned indexes valid; library size |
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
- [ ] Every Home card opens its feature, and the back arrow returns to Home.
- [ ] "Grown-ups" opens the Parent Zone.
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
  - [ ] "Let's play a quiz." → "Play Quiz Time" opens Quiz Time.
        "Take me on an adventure." → "Open Mystery Missions" works.
        Nothing opens until the button is tapped.
  - [ ] Type "my phone number is 07700 900123": the number is not shown;
        Buddy says to keep it private.
  - [ ] Ask "why do cats purr" (twice), "can dogs see colours", "how do bees
        make honey": each gets an answer to that exact question.
  - [ ] Ask "what do snakes eat": Buddy says he is not sure of that exact
        question and offers a snake fact.
  - [ ] Type something unknown ("capital of Mongolia"): Buddy says he does
        not know yet.
  - [ ] Voice off: answers still appear, Buddy stays silent.
- [ ] **Talking to Buddy (tap-to-talk):**
  - [ ] Fresh install: tapping Talk shows "Can Buddy use the microphone?"
        first. **Not now** → no Android prompt.
  - [ ] Talk → **OK** → Android's prompt appears. **Don't allow** → the
        "You can type instead" notice; typing still works; tapping Talk again
        shows the explanation again (no surprise prompt).
  - [ ] Allow → "Listening..." card and badge; Buddy stops talking. Say "why
        is the sky blue": words appear live, then land in the text box with
        "Check your words, then tap Ask." Nothing is answered until you tap
        Ask.
  - [ ] Done mid-sentence keeps the words; Cancel clears them.
  - [ ] While listening: Hear again, typing and ideas are disabled.
  - [ ] Mid-listen, press Home or open the app switcher: listening stops
        (microphone indicator in the status bar turns off).
  - [ ] Mid-listen, tap Grown-ups: listening stops.
  - [ ] Stay silent: "I didn't catch that..." after a few seconds.
  - [ ] If "This phone can't listen without the internet..." appears:
        on-device English is not installed. Either install it (Settings →
        Google → Search, Assistant & Voice → Voice → Offline speech
        recognition, or the phone's equivalent) or allow online in the
        Parent Zone.
- [ ] **Parent Zone (Phase 6):**
  - [ ] Grown-ups → "For grown-ups", a question in words ("What is nineteen
        times six?") and "About this check". Only one field; nothing
        personal asked.
  - [ ] A wrong answer: "That's not right..." with tries left and a new
        question. Three wrong: "Please wait 60 seconds"; Back to Buddy and
        reopen: still waiting; after a minute it asks again.
  - [ ] The right answer opens the settings at the top of the page.
  - [ ] Buddy talks off: Home is silent. Speed Slower / Faster: Hear again
        on Home sounds slower / faster.
  - [ ] Read aloud automatically off: open a story; Buddy is quiet until
        Hear again or the speaker is tapped. Turn it back on.
  - [ ] Listening: online recognition off by default, with the
        explanation; the on-device line matches this phone.
  - [ ] Calmer animations on: Buddy no longer waves on Home.
  - [ ] "What's saved on this phone" shows the real counts (play a mission
        and part of a story first).
  - [ ] Press Home (the app goes to the background) and come back: the
        check is asked again.
  - [ ] Force-stop and reopen: all Parent Zone settings are as you left
        them.
  - [ ] Delete all progress: step 1 lists the counts and what is kept;
        Cancel keeps everything. Continue → step 2: Delete is disabled until
        DELETE is typed. Delete: "Done..." and the counts show 0.
  - [ ] Back to Buddy: Home shows 0 missions / 0 stories; Missions show no
        "Solved"; Stories show no "Continue" and 0 of 12 endings. Settings
        are unchanged.
  - [ ] Force-stop and reopen: progress is still gone.
  - [ ] Repeat the reset with "Also restore default settings" ticked:
        voice on, normal speed, reads automatically, online off, normal
        animations.
- [ ] Settings → Apps → Curious Buddy → Permissions shows only Microphone
      (and nothing else that asks the user).
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
- [ ] **Mystery Missions (Phase 4):**
  - [ ] Home → Mystery Missions: three cases with covers, "New case", 0 points.
  - [ ] Open a case: Buddy reads the scene; "Stop talking" silences him;
        "Hear again" repeats.
  - [ ] Inspect clues; tap the speaker on a clue to hear it.
  - [ ] Pick a wrong answer → "Keep investigating!" with the reason; pick
        the right one → "Great reasoning!" plus the explanation.
  - [ ] Hints appear one at a time; the last says "No more hints".
  - [ ] Garden step 3 and Signals step 3: tap pieces to order them; tap a
        placed piece to take it back; "Start over" clears.
  - [ ] Finish: badge, points breakdown, solution read aloud.
  - [ ] Back to missions: "Solved", best score, badge on the shelf;
        "Play again" restarts.
  - [ ] Press back mid-narration: Buddy stops at once.
  - [ ] Go back to Home: the explorer log shows the mission and points.
  - [ ] Force-stop and reopen: solved missions and points are still there.
  - [ ] Voice off: missions still fully playable with text only.
- [ ] **Splash:** close the app fully (swipe it away, or Force stop), then open
      it from its icon: warm paper background, Buddy in the middle, "Curious
      Buddy" at the bottom, then Home with no white or black flash. Repeat
      with the phone in dark mode: the same.
- [ ] **Game Zone:**
  - [ ] Home → Game Zone → Enter the Arena: three games, Starter open, others
        locked; Quick Create with an idea. What's That Sound? says Coming soon.
  - [ ] Memory Match: drawn pictures on the cards; a wrong pair stays showing until your next
        tap; matches stay up; finish with stars; Next level opens.
  - [ ] Pattern Power: pick an answer; see right or wrong and why; finish
        with stars. 2 or fewer right: no star, next level stays closed.
  - [ ] Spot the Change: tap what changed in the second picture; a wrong tap
        says keep looking; finish with stars.
  - [ ] All 3 stars: confetti. Play again gives a new board.
  - [ ] Quick Create: New idea changes it; Start drawing opens the Drawing
        Studio with the idea shown.
  - [ ] Force-stop and reopen: stars and open levels remain.
  - [ ] My Discoveries counts game stars; 6 stars earns the Champion cap.
  - [ ] Parent Zone: "Game Zone results" shows; Delete all progress clears it.
- [ ] **Game Zone look and How to play:**
  - [ ] Game Zone: night-sky screen, scoreboard with rank and stars, big game
        tiles with pictures.
  - [ ] Win a game, go back: the stars and rank have gone up.
  - [ ] Arena: each game shows numbered level buttons; locked ones show a lock;
        each game has a How to play button, and so does Quick Create.
  - [ ] First game of each kind: How to play opens by itself and Buddy reads
        it. Let's play! closes it and Buddy stops.
  - [ ] Second game of that kind: it doesn't open by itself.
  - [ ] During a game, the ? at the top opens it. Got it returns to the game
        with nothing lost.
- [ ] **Treasure Maze:**
  - [ ] Game Zone → Find the treasure: three levels, with How to play.
  - [ ] The arrows move Buddy; Buddy runs until a wall, a turning or a gem.
  - [ ] Swiping on the maze moves Buddy too, and doesn't scroll the page.
  - [ ] Bumping a wall plays a soft sound and costs nothing.
  - [ ] Gems disappear and the count goes up. All gems and the chest: 3 stars.
  - [ ] Play again and each new level: a different maze.
- [ ] **Dino Discovery:**
  - [ ] Game Zone → Start exploring: Fern Forest open, the other two say to
        explore the place before.
  - [ ] Field Guide at 0 of 9: dark shapes, no names or facts.
  - [ ] Explore Fern Forest: tap a search spot; read the clue; each picture
        really shows what the clue says.
  - [ ] Pick wrong: a kind note, a second clue, and that card can't be tapped
        again. Pick right: the creature, how to say it, and a fact.
  - [ ] Keep exploring: the creature now stands in the scene.
  - [ ] All three found: the mission, three questions. Finish with stars and
        see the three creatures. Next place opens.
  - [ ] Ancient Sea: each creature says Not a dinosaur!
  - [ ] Field Guide: found creatures show facts; Hear about it reads aloud;
        leaving stops Buddy.
  - [ ] Leave a trip halfway, then reopen: it starts again, nothing is lost.
  - [ ] Force-stop and reopen: stars and the Field Guide remain.
  - [ ] Parent Zone: Delete all progress clears the stars and the Field Guide.
- [ ] **Sound effects** (media volume up):
  - [ ] Right answer: a rising chime, then Buddy. Wrong answer: soft notes,
        never harsh, then Buddy. They never talk over each other.
  - [ ] Passing a quiz, solving a case, a new story ending and saving a
        creation: a small fanfare. Choosing creature parts: a light pop.
  - [ ] The sounds are pleasant, not too loud, and not annoying when repeated.
  - [ ] With Bluetooth earbuds or a speaker connected: the sounds are heard.
  - [ ] Voice off: sounds still play. Parent Zone → Sound effects off: none,
        and Buddy still speaks. Still off after a force-stop.
- [ ] **Buddy's Wardrobe:**
  - [ ] Home → Buddy's Wardrobe: earned items can be tapped; locked ones show
        how to earn them.
  - [ ] Tap an item: Buddy wears it at once and says so. Tap again: it comes
        off. Only one item per slot.
  - [ ] Each item sits properly on Buddy (hats, glasses, neckwear).
  - [ ] Back to Home, and in other activities: Buddy still wears it.
  - [ ] Force-stop and reopen: the outfit is still on.
  - [ ] Parent Zone: "Buddy's outfit" shows; Delete all progress takes it off.
- [ ] **Look and feel:**
  - [ ] The rounded font appears everywhere, and text fits on every page.
  - [ ] Page changes fade gently; story pages and quiz questions slide.
  - [ ] Story choices, quiz answers and shelf tiles sink when pressed.
  - [ ] Right answer: a small pop and Buddy hops. Wrong answer: a gentle
        shake.
  - [ ] Quiz stars appear one by one. A perfect quiz: confetti and a light
        tap on the phone. 4 of 5: no confetti.
  - [ ] Confetti also for a solved case, a new story ending (not a repeat)
        and a saved creation. You can tap buttons during it.
  - [ ] New rank: from My Discoveries, go and earn it, then come back.
  - [ ] Parent Zone → Calmer animations on: no motion, confetti or phone
        taps anywhere. Everything still works.
  - [ ] Everything feels smooth on this phone.
- [ ] **My Discoveries:**
  - [ ] Home → My Discoveries: your rank, a summary read by Buddy, totals,
        and Your next adventure.
  - [ ] Stop talking and Hear again work; back mid-speech stops Buddy.
  - [ ] Go to ... opens the suggested place; after doing something and
        coming back, the journal has updated.
  - [ ] Mission badges: earned ones shown, others locked with "Not earned
        yet".
  - [ ] Story discoveries: found endings with their discovery and a speaker;
        unfound endings only as "n more endings to find".
  - [ ] Quiz stars per topic; the latest four creations; Open Creative Island.
  - [ ] Parent Zone → Delete all progress: the journal is back to Curious
        Beginner, and stays so after a force-stop.
  - [ ] Voice off and automatic reading off: still fully readable.
- [ ] **Creative Island (Phase 7):**
  - [ ] Home → Creative Island: Drawing Studio, Creature Maker, an empty
        shelf, "0 of 12".
  - [ ] Drawing Studio: Buddy gives instructions. Draw straight up and down
        on the canvas: it draws and the page does not scroll. Scroll by
        swiping below the canvas.
  - [ ] Try colours, Thin/Medium/Thick, Eraser, Undo. Start over asks first.
  - [ ] Save stays off until something is drawn. Save: "Saved to My
        Creations!", Draw another, Back to Creative Island.
  - [ ] Creature Maker: every choice changes the picture; extras, patterns
        and eyes get a fact from Buddy; Surprise me; New name; Save.
  - [ ] Shelf shows both, newest first. Tap one: big view and a description;
        Remove asks first; Keep it keeps it; Yes removes it.
  - [ ] Save 12 creations: the shelf says it is full and the Start buttons
        turn off; removing one turns them back on.
  - [ ] Home explorer log: "n creations".
  - [ ] Force-stop and reopen: creations are all there and look the same.
  - [ ] Parent Zone: "Creative Island creations" shows the counts; Delete all
        progress lists and deletes them; still gone after a restart.
  - [ ] Press back while Buddy talks: he stops. Voice off and automatic
        reading off: everything still works.
  - [ ] No permission prompts appear, and nothing can be typed.
- [ ] **Quiz Time:**
  - [ ] Home → Quiz Time card: four topics, "0 of 36 stars", Starter open,
        Explorer and Expert locked ("Get 3 right in ... to open").
  - [ ] Play Starter: Buddy reads "Question 1 of 5", the question and the
        lettered answers. "Read the answers" and the speaker work; Stop
        talking silences him.
  - [ ] Pick a wrong answer: "Not quite. The answer is ...", "Your answer"
        and "Right answer" marked, explanation shown; tapping another
        answer changes nothing.
  - [ ] Pick a right answer: "That's right!" and the explanation.
  - [ ] Finish with 3 or more right: summary with score, stars, "You opened
        the next level!", your answers; Next level opens Explorer.
  - [ ] Finish with 2 or fewer: encouraging message, no Next level; Play
        again restarts with the answers in a new order.
  - [ ] Back to Quiz Time: stars and "Best: n of 5"; Explorer open.
  - [ ] Press back mid-question: Buddy stops at once.
  - [ ] Home explorer log: "1 quiz level done".
  - [ ] Force-stop and reopen: stars and open levels remain.
  - [ ] Parent Zone: "Quiz Time results" shows the levels; Delete all
        progress lists and deletes them; Quiz Time is back to 0 stars.
  - [ ] Voice off and automatic reading off: still fully playable.
- [ ] **Living Stories (Phase 5):**
  - [ ] Home → Living Stories: three stories with pictures, "New story",
        "0 of 12 endings found".
  - [ ] Start a story: Buddy reads the intro; "Begin the story" reads
        page 1; "Stop talking" silences him; "Hear again" repeats.
  - [ ] "Read the choices" reads "Choice 1 ... Choice 2 ..."; the speaker
        next to the title rereads the page.
  - [ ] Tap a choice: the next page starts with what happened; Buddy stops
        the old page and reads the new one (no overlap).
  - [ ] Reach an ending: "The End", "New ending!", the discovery,
        "1 of 4 endings"; "Try a different path" returns to page 1.
  - [ ] Reach the same ending again: "You found this ending before".
  - [ ] Back to stories: ending chips on the card; "Find another ending".
  - [ ] Leave mid-story (back button) mid-narration: Buddy stops at once;
        the card shows "Reading", "Continue the story" and "Start again".
  - [ ] Force-stop and reopen: Continue opens the same page with "Welcome
        back!"; found endings are still there.
  - [ ] Home explorer log counts the finished story.
  - [ ] Voice off: stories fully readable with text only.
  - [ ] Each story looks different (green wood, purple Luma, warm garden).
- [ ] **Saved settings (Phase 3):** turn Voice off, then force-stop the app
      (Settings → Apps → Curious Buddy → Force stop) and reopen: Buddy stays
      quiet and shows "Voice on". Turn it back on, force-stop, reopen: the
      welcome plays. In the Parent Zone, allow online recognition,
      force-stop, reopen the Parent Zone: still on.
- [ ] No new warnings in `flutter run` console output.
