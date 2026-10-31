// Builds docs/review/content_review.html: every fact, question, clue and
// story in the app, in one printable page for a grown-up reviewer. It reads
// the app's own content, so it is always complete. Not part of the normal
// test run. Run from the project root after changing content:
//   flutter test tool/export_content_review_test.dart
import 'dart:io';

import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/domain/games/circuit.dart';
import 'package:curious_buddy/domain/games/dino.dart';
import 'package:curious_buddy/domain/games/game_content.dart';
import 'package:curious_buddy/domain/games/parade.dart';
import 'package:curious_buddy/domain/games/sort_it.dart';
import 'package:curious_buddy/domain/games/sound_game.dart';
import 'package:curious_buddy/domain/games/words.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/domain/quiz/more_quiz_topics.dart';
import 'package:curious_buddy/domain/stories/more_stories.dart';
import 'package:curious_buddy/domain/stories/story_maker.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = 'docs/review/content_review.html';

void main() {
  test('export the content review', () {
    final page = _Page();
    final date = DateTime.now().toIso8601String().substring(0, 10);

    page
      ..raw('<h1>Curious Buddy: content review</h1>')
      ..p(
        'Made from the app on $date. Every fact, question, clue and story '
        'the app shows a child is listed here.',
      )
      ..h2('How to review')
      ..list([
        'Check each item is true, clear and suitable for children aged 8 to '
            '14. Tick the box when it is fine.',
        'If something is wrong or unclear, write the item number and what '
            'should change. The numbers stay the same if this page is made '
            'again.',
        'Correct answers are marked with ✔. Wrong answers are meant to be '
            'wrong, so only check that they are clearly wrong and not unkind.',
        'Rounded numbers say "about" on purpose.',
      ]);

    _buddy(page);
    _quiz(page);
    _missions(page);
    _stories(page);
    _maker(page);
    _games(page);
    _ghanaAfrica(page);

    page.raw(
      '<h2>Summary</h2><p>${page.count} items to review. Thank you!</p>',
    );
    Directory('docs/review').createSync(recursive: true);
    File(_out).writeAsStringSync(page.build());
  });
}

void _buddy(_Page page) {
  page
    ..h2("Buddy's answers")
    ..p(
      'What Buddy says when a child asks a question. Buddy only ever answers '
      'from this list.',
    );
  // Ghana and Africa topics are listed last, so earlier numbers stay put.
  for (final topic in curatedTopics.where(
    (t) => !ghanaAfricaTopics.contains(t),
  )) {
    _topic(page, topic);
  }
  page.item('When Buddy does not know', [fallbackAnswer.text]);
}

void _topic(_Page page, CuratedTopic topic) => page.item('Topic: ${topic.id}', [
  for (final answer in topic.answers) answer,
  if (topic.followUps.isNotEmpty)
    'Suggested next questions: ${topic.followUps.join(' / ')}',
]);

void _ghanaAfrica(_Page page) {
  page
    ..h2('Ghana and Africa')
    ..p('Buddy answers added after the content audit.');
  for (final topic in ghanaAfricaTopics) {
    _topic(page, topic);
  }
}

void _quiz(_Page page) {
  page.h2('Quiz Time');
  for (final topic in allQuizTopics) {
    page.h3(topic.title);
    for (final level in topic.levels) {
      for (final q in level.questions) {
        page.item('${level.difficulty.name}: ${q.prompt}', [
          for (final o in q.options)
            o.id == q.answerId ? '✔ ${o.text}' : '✘ ${o.text}',
          'Explanation: ${q.explanation}',
        ]);
      }
    }
  }
}

void _missions(_Page page) {
  page.h2('Mystery Missions');
  for (final mission in allMissions) {
    page
      ..h3(mission.title)
      ..item('Opening', [
        mission.intro,
        'Goal: ${mission.objective}',
        'Badge: ${mission.badge}',
      ]);
    for (final stage in mission.stages) {
      page.item('Step: ${stage.prompt}', [
        for (final clue in stage.clues) 'Clue, ${clue.title}: ${clue.text}',
        ...switch (stage) {
          ChoiceStage(:final choices) || MultiSelectStage(:final choices) => [
            for (final c in choices)
              '${c.correct ? '✔' : '✘'} ${c.text}: ${c.feedback}',
          ],
          OrderStage(:final pieces) => [
            'Right order: ${pieces.map((p) => p.text).join(' → ')}',
          ],
        },
        for (final hint in stage.hints) 'Hint: $hint',
        'Explanation: ${stage.explanation}',
      ]);
    }
    page.item('Case solved', [mission.solution]);
  }
}

void _stories(_Page page) {
  page.h2('Living Stories');
  for (final story in allStories) {
    page
      ..h3(story.title)
      ..item('Opening', [story.intro]);
    for (final scene in story.scenes) {
      final ending = scene.ending;
      page.item('Scene: ${scene.title}', [
        scene.text,
        for (final choice in scene.choices)
          'Choice: ${choice.text}'
              '${choice.consequence == null ? '' : ' (then: ${choice.consequence})'}',
        if (ending != null)
          'Ending, "${ending.title}". You discovered: ${ending.discovery}',
      ]);
    }
  }
}

void _maker(_Page page) {
  page
    ..h2('Story Maker')
    ..p(
      'Stories are built from these pieces. {hero}, {place} and {friend} '
      'are filled in with the choices below.',
    )
    ..item('Heroes', [for (final h in StoryMaker.heroes) h.intro])
    ..item('Places', [
      for (final p in StoryMaker.places)
        '${p.name}: ${p.scene} Friend: ${p.friend}.',
    ]);
  for (final m in StoryMaker.mysteries) {
    page.item('Mystery: ${m.title}', [
      m.problem,
      '${m.lookChoice}: ${m.look}',
      '${m.askChoice}: ${m.ask}',
      '${m.scienceChoice}: ${m.science}',
      for (final e in m.endings)
        'Ending, "${e.title}": ${e.text} You discovered: ${e.discovery}',
    ]);
  }
}

void _games(_Page page) {
  page
    ..h2('Game Zone')
    ..h3('Dino Discovery');
  for (final place in DinoPlace.values) {
    page.item('Place: ${place.name}', [
      'Era: ${place.era}',
      place.intro,
      for (final task in place.mission)
        'Mission: ${task.prompt} ✔ ${task.answer.name}. ${task.explanation}',
    ]);
  }
  for (final c in DinoCreature.values) {
    page.item(c.name, [
      'Say it: ${c.sayIt}. Ate: ${c.diet.label}. Size: ${c.size}. '
          '${c.isDinosaur ? 'A dinosaur.' : 'Not a dinosaur.'}',
      for (final clue in c.clues) 'Clue: $clue',
      'Fact: ${c.fact}',
    ]);
  }

  page.h3('Word Builder');
  for (final MapEntry(key: level, value: words) in wordLevels.entries) {
    for (final w in words) {
      page.item('Level $level: ${w.word}', ['Clue: ${w.clue}']);
    }
  }

  page.h3("What's That Sound?");
  for (final s in GameSound.values) {
    page.item(s.title, ['Clue: ${s.clue}', 'Fact: ${s.fact}']);
  }

  page.h3('Sort It!');
  for (final sets in sortLevels.values) {
    for (final set in sets) {
      page.item(set.question, [
        for (final (i, group) in set.groups.indexed)
          '$group: ${set.items.where((x) => x.group == i).map((x) => x.name).join(', ')}',
        for (final x in set.items.where((x) => x.note != null))
          'Note on ${x.name}: ${x.note}',
      ]);
    }
  }

  page.h3('Planet Parade');
  for (final sets in paradeLevels.values) {
    for (final set in sets) {
      page.item(set.question, [
        'Right order: ${set.order.join(' → ')}',
        'Fact: ${set.fact}',
      ]);
    }
  }

  page
    ..h3('Pattern Power')
    ..p('Only the explanations need checking; the answers are tested.');
  for (final MapEntry(key: level, value: rounds) in patternLevels.entries) {
    for (final r in rounds) {
      page.item('Level $level: ${r.shown.map((t) => t.label).join(', ')}, ?', [
        '✔ ${r.answer.label}. ${r.explanation}',
      ]);
    }
  }

  page.h3('Circuit Fixer');
  for (final fact in CircuitGame.facts) {
    page.item('Fact', [fact]);
  }

  page
    ..h3('Quick Create drawing ideas')
    ..item('Ideas', quickCreateIdeas);
}

/// A simple HTML page with numbered items to tick.
class _Page {
  final _body = StringBuffer();
  int count = 0;

  static String _esc(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  void raw(String html) => _body.writeln(html);
  void h2(String text) => _body.writeln('<h2>${_esc(text)}</h2>');
  void h3(String text) => _body.writeln('<h3>${_esc(text)}</h3>');
  void p(String text) => _body.writeln('<p>${_esc(text)}</p>');

  void list(List<String> lines) {
    _body.writeln('<ul>');
    for (final line in lines) {
      _body.writeln('<li>${_esc(line)}</li>');
    }
    _body.writeln('</ul>');
  }

  void item(String title, List<String> lines) {
    count++;
    _body
      ..writeln('<div class="item">')
      ..writeln(
        '<label><input type="checkbox"> <b>$count.</b> ${_esc(title)}</label>',
      );
    list(lines);
    _body.writeln('</div>');
  }

  String build() =>
      '''
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Curious Buddy content review</title>
<style>
  body { font: 16px/1.5 system-ui, sans-serif; color: #1f2a44;
         background: #fff8ee; max-width: 860px; margin: 0 auto; padding: 16px; }
  h1 { font-size: 28px; }
  h2 { margin-top: 40px; border-bottom: 3px solid #1f2a44; }
  h3 { margin-top: 28px; color: #2a68c9; }
  .item { background: #fff; border: 1.5px solid #1f2a44; border-radius: 12px;
          padding: 10px 14px; margin: 10px 0; break-inside: avoid; }
  .item ul { margin: 6px 0 0; padding-left: 22px; }
  input { transform: scale(1.3); margin-right: 6px; }
  @media print { body { background: #fff; } .item { border-color: #999; } }
</style>
</head>
<body>
$_body</body>
</html>
''';
}
