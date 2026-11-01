// Lists every sentence Buddy can say, for recording with tool/record_voice.py.
// Run after changing content, from the project root:
//   VOICE_LINES=lines.json flutter test tool/export_voice_lines_test.dart
// Sentences come from the app's content, plus tool/voice_extra_lines.txt:
// lines screens build themselves, captured while the tests ran.
import 'dart:convert';
import 'dart:io';

import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/domain/games/circuit.dart';
import 'package:curious_buddy/domain/games/dino.dart';
import 'package:curious_buddy/domain/games/game_content.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/parade.dart';
import 'package:curious_buddy/domain/games/sort_it.dart';
import 'package:curious_buddy/domain/games/sound_game.dart';
import 'package:curious_buddy/domain/games/words.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/domain/quiz/more_quiz_topics.dart';
import 'package:curious_buddy/domain/stories/more_stories.dart';
import 'package:curious_buddy/domain/voice/voice_clips.dart';
import 'package:curious_buddy/ui/games/how_to_play.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('export the sentences to record', () {
    final sentences = <String>{};
    void add(String? text) {
      if (text != null) sentences.addAll(VoiceClips.sentences(text));
    }

    // Buddy's answers and safety replies.
    for (final topic in curatedTopics) {
      topic.answers.forEach(add);
      if (topic.subject case final subject?) add(notSureLeadIn(subject));
    }
    add(fallbackAnswer.text);
    for (final reply in [
      ChildSafetyFilter.personalInfoResponse,
      ChildSafetyFilter.selfHarmResponse,
      ChildSafetyFilter.bullyingResponse,
      ChildSafetyFilter.unsafeResponse,
      ChildSafetyFilter.secretResponse,
      ChildSafetyFilter.medicalResponse,
      ChildSafetyFilter.offLimitsResponse,
      ChildSafetyFilter.strangersResponse,
    ]) {
      add(reply.text);
    }

    // Stories.
    add('What should we do?');
    for (final story in allStories) {
      add(story.intro);
      for (final scene in story.scenes) {
        add(scene.text);
        final ending = scene.ending;
        if (ending != null) {
          add(ending.title);
          add(ending.discovery);
        }
        for (final (i, choice) in scene.choices.indexed) {
          add(choice.consequence);
          add('Choice ${i + 1}: ${choice.text}.');
        }
      }
    }

    // Missions.
    for (final mission in allMissions) {
      add(mission.intro);
      add(mission.objective);
      add(mission.solution);
      for (final stage in mission.stages) {
        add(stage.prompt);
        add(stage.explanation);
        for (final hint in stage.hints) {
          add('Hint. $hint');
        }
        for (final clue in stage.clues) {
          add('${clue.title}. ${clue.text}');
        }
        if (stage
            case ChoiceStage(:final choices) ||
                MultiSelectStage(:final choices)) {
          for (final choice in choices) {
            add(choice.feedback);
          }
        }
      }
    }

    // Quiz Time.
    for (final total in [5, 10]) {
      for (var i = 1; i <= total; i++) {
        add('Question $i of $total.');
      }
    }
    for (final topic in allQuizTopics) {
      for (final level in topic.levels) {
        for (final q in level.questions) {
          add(q.prompt);
          add(q.explanation);
          add(
            '${QuizPlayViewModel.wrongTitle} The answer is ${q.answer.text}.',
          );
          add(QuizPlayViewModel.rightTitle);
          for (final (i, option) in q.options.indexed) {
            add('${QuizPlayViewModel.letters[i]}: ${option.text}.');
          }
        }
      }
    }

    // Game Zone.
    for (final kind in GameKind.values) {
      add(HowToPlay.of(kind).spoken);
    }
    add(HowToPlay.quickCreate.spoken);
    for (final place in DinoPlace.values) {
      add(place.intro);
      for (final task in place.mission) {
        add(task.prompt);
        add(task.explanation);
      }
    }
    for (final creature in DinoCreature.values) {
      creature.clues.forEach(add);
      add(creature.fact);
      add(creature.guideLine);
    }
    for (final words in wordLevels.values) {
      for (final word in words) {
        add(word.clue);
      }
    }
    for (final sound in GameSound.values) {
      add(sound.clue);
      add(sound.fact);
    }
    for (final sets in sortLevels.values) {
      for (final set in sets) {
        add(set.question);
        for (final item in set.items) {
          add(item.note);
        }
      }
    }
    for (final sets in paradeLevels.values) {
      for (final set in sets) {
        add(set.question);
        add(set.fact);
      }
    }
    for (final rounds in patternLevels.values) {
      for (final round in rounds) {
        add(round.explanation);
      }
    }
    CircuitGame.facts.forEach(add);
    quickCreateIdeas.forEach(add);

    // Lines screens build themselves.
    File('tool/voice_extra_lines.txt').readAsLinesSync().forEach(add);

    final lines = [
      for (final sentence in sentences)
        {'name': VoiceClips.name(sentence), 'text': sentence},
    ];
    File(
      Platform.environment['VOICE_LINES']!,
    ).writeAsStringSync(jsonEncode(lines));
    // ignore: avoid_print
    print('${lines.length} sentences');
  });
}
