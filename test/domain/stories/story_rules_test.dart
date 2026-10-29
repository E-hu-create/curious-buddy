import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_rules.dart';
import 'package:flutter_test/flutter_test.dart';

StoryChoice _to(String target, {String? id}) => StoryChoice(
  id: id ?? 'to_$target',
  text: 'Go to $target',
  nextSceneId: target,
);

StoryScene _scene(String id, List<StoryChoice> choices) => StoryScene(
  id: id,
  title: 'Scene $id',
  text: 'Something happens in $id.',
  picture: ScenePicture.forestGrey,
  choices: choices,
);

StoryScene _end(String id) => StoryScene(
  id: id,
  title: 'End $id',
  text: 'It ends at $id.',
  picture: ScenePicture.forestRainbow,
  ending: StoryEnding(id: 'e_$id', title: 'Ending $id', discovery: 'Learned.'),
);

Story _story(List<StoryScene> scenes, {String start = 'a'}) => Story(
  id: 'test_story',
  title: 'Test',
  tagline: 'A test.',
  cover: ScenePicture.forestGrey,
  intro: 'Intro.',
  startSceneId: start,
  scenes: scenes,
);

StoryScene _namedEnd(String id, String endingId) => StoryScene(
  id: id,
  title: id,
  text: '$id.',
  picture: ScenePicture.forestGrey,
  ending: StoryEnding(id: endingId, title: id, discovery: '$id.'),
);

/// a -> b | c, b -> end1 | end2, c -> end2 | end3.
final _valid = _story([
  _scene('a', [_to('b'), _to('c')]),
  _scene('b', [_to('end1'), _to('end2')]),
  _scene('c', [_to('end2'), _to('end3')]),
  _end('end1'),
  _end('end2'),
  _end('end3'),
]);

Matcher _problem(String fragment) => contains(contains(fragment));

void main() {
  group('StoryValidator', () {
    test('accepts a well-formed branching story', () {
      expect(StoryValidator.problems(_valid), isEmpty);
    });

    test('rejects a story with no scenes', () {
      expect(StoryValidator.problems(_story([])), _problem('no scenes'));
    });

    test('rejects missing titles, text and discoveries', () {
      final blank = Story(
        id: 'blank',
        title: ' ',
        tagline: '',
        cover: ScenePicture.forestGrey,
        intro: '',
        startSceneId: 'a',
        scenes: [
          _scene('a', [_to('x'), _to('y')]),
          _end('x'),
          const StoryScene(
            id: 'y',
            title: '',
            text: ' ',
            picture: ScenePicture.forestGrey,
            ending: StoryEnding(id: 'ey', title: '', discovery: ''),
          ),
        ],
      );
      final problems = StoryValidator.problems(blank);
      expect(problems, _problem('missing title'));
      expect(problems, _problem('missing intro'));
      expect(problems, _problem('scene y: missing text'));
      expect(problems, _problem('ending needs a title'));
      expect(problems, _problem('ending needs a discovery'));
    });

    test('rejects a missing start scene', () {
      expect(
        StoryValidator.problems(_story(_valid.scenes, start: 'nowhere')),
        _problem('start scene nowhere does not exist'),
      );
    });

    test('rejects choices pointing at scenes that do not exist', () {
      final story = _story([
        _scene('a', [_to('end1'), _to('ghost')]),
        _end('end1'),
        _end('end2'),
      ]);
      expect(
        StoryValidator.problems(story),
        _problem('points at missing scene ghost'),
      );
    });

    test('rejects duplicate scene, choice and ending ids', () {
      expect(
        StoryValidator.problems(_story([..._valid.scenes, _end('end1')])),
        _problem('scene ids must be unique'),
      );
      expect(
        StoryValidator.problems(
          _story([
            _scene('a', [_to('end1', id: 'same'), _to('end2', id: 'same')]),
            _end('end1'),
            _end('end2'),
          ]),
        ),
        _problem('choice ids must be unique'),
      );
      expect(
        StoryValidator.problems(
          _story([
            _scene('a', [_to('x'), _to('y')]),
            _namedEnd('x', 'same'),
            _namedEnd('y', 'same'),
          ]),
        ),
        _problem('ending ids must be unique'),
      );
    });

    test('rejects invalid ids', () {
      final story = _story([
        _scene('a', [_to('Bad Id'), _to('end2')]),
        _end('Bad Id'),
        _end('end2'),
      ]);
      expect(StoryValidator.problems(story), _problem('invalid id'));
    });

    test('rejects fewer than two endings', () {
      final story = _story([
        _scene('a', [_to('b'), _to('end1')]),
        _scene('b', [_to('end1')]),
        _end('end1'),
      ]);
      expect(
        StoryValidator.problems(story),
        _problem('needs at least 2 endings'),
      );
    });

    test('rejects two choices that lead to the same place', () {
      final story = _story([
        _scene('a', [_to('end1', id: 'one'), _to('end1', id: 'two')]),
        _end('end1'),
        _end('end2'),
      ]);
      expect(StoryValidator.problems(story), _problem('fake branching'));
    });

    test('rejects a scene with neither choices nor an ending', () {
      final story = _story([
        _scene('a', [_to('end1'), _to('stuck')]),
        _scene('stuck', []),
        _end('end1'),
        _end('end2'),
      ]);
      expect(
        StoryValidator.problems(story),
        _problem('scene stuck: needs a choice or an ending'),
      );
    });

    test('rejects an ending that also has choices', () {
      const story = Story(
        id: 'x',
        title: 'X',
        tagline: 'X',
        cover: ScenePicture.forestGrey,
        intro: 'X',
        startSceneId: 'a',
        scenes: [
          StoryScene(
            id: 'a',
            title: 'A',
            text: 'A.',
            picture: ScenePicture.forestGrey,
            choices: [StoryChoice(id: 'c', text: 'C', nextSceneId: 'b')],
            ending: StoryEnding(id: 'ea', title: 'A', discovery: 'A.'),
          ),
          StoryScene(
            id: 'b',
            title: 'B',
            text: 'B.',
            picture: ScenePicture.forestGrey,
            ending: StoryEnding(id: 'eb', title: 'B', discovery: 'B.'),
          ),
        ],
      );
      expect(
        StoryValidator.problems(story),
        _problem('an ending cannot have choices'),
      );
    });

    test('rejects a scene that points at itself', () {
      final story = _story([
        _scene('a', [_to('a'), _to('end1')]),
        _end('end1'),
        _end('end2'),
      ]);
      expect(StoryValidator.problems(story), _problem('loops to itself'));
    });

    test('rejects a loop through several scenes', () {
      final story = _story([
        _scene('a', [_to('b'), _to('end1')]),
        _scene('b', [_to('c'), _to('end2')]),
        _scene('c', [_to('a'), _to('end1')]),
        _end('end1'),
        _end('end2'),
      ]);
      expect(StoryValidator.problems(story), _problem('scenes form a loop'));
    });

    test('rejects unreachable scenes and endings', () {
      final story = _story([
        _scene('a', [_to('end1'), _to('end2')]),
        _end('end1'),
        _end('end2'),
        _end('island'),
      ]);
      final problems = StoryValidator.problems(story);
      expect(problems, _problem('unreachable scenes: island'));
      expect(problems, _problem('some endings can never be reached'));
    });

    test('rejects scene text too long to read aloud', () {
      final story = _story([
        StoryScene(
          id: 'a',
          title: 'A',
          text: List.filled(
            StoryValidator.maxWordsPerScene + 1,
            'word',
          ).join(' '),
          picture: ScenePicture.forestGrey,
          choices: [_to('end1'), _to('end2')],
        ),
        _end('end1'),
        _end('end2'),
      ]);
      expect(StoryValidator.problems(story), _problem('text too long'));
    });
  });

  group('StoryGraph', () {
    final graph = StoryGraph(_valid);

    test('finds reachable scenes, endings and path counts', () {
      expect(graph.reachable, hasLength(6));
      expect(graph.reachableEndingIds, {'e_end1', 'e_end2', 'e_end3'});
      expect(graph.pathCount, 4);
      expect(graph.hasCycle, isFalse);
    });

    test('accepts real routes and rejects made-up or repeating ones', () {
      expect(graph.isValidPath(['a']), isTrue);
      expect(graph.isValidPath(['a', 'b', 'end2']), isTrue);
      expect(graph.isValidPath(['a', 'c', 'end3']), isTrue);
      expect(graph.isValidPath([]), isFalse);
      expect(graph.isValidPath(['b', 'end1']), isFalse, reason: 'wrong start');
      expect(graph.isValidPath(['a', 'end1']), isFalse, reason: 'no choice');
      expect(graph.isValidPath(['a', 'b', 'b']), isFalse, reason: 'repeats');
      expect(graph.isValidPath(['a', 'ghost']), isFalse);
    });
  });
}
