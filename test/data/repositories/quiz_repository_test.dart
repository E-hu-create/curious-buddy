import 'package:curious_buddy/data/repositories/quiz_repository.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:flutter_test/flutter_test.dart';

QuizTopic _copy(QuizTopic source, {String? id, List<QuizLevel>? levels}) =>
    QuizTopic(
      id: id ?? source.id,
      title: source.title,
      tagline: source.tagline,
      levels: levels ?? source.levels,
    );

void main() {
  test('loads all four starter topics offline', () async {
    final topics = await BundledQuizRepository().loadTopics();

    expect(
      [for (final t in topics) t.id],
      ['space', 'animals', 'body', 'earth'],
    );
  });

  test('leaves out invalid topics instead of showing them broken', () async {
    final space = starterQuizTopics.first;
    final broken = _copy(space, id: 'broken', levels: const []);

    final topics = await BundledQuizRepository(
      topics: [broken, space],
    ).loadTopics();

    expect([for (final t in topics) t.id], ['space']);
  });

  test('leaves out a topic repeating an id or a level id', () async {
    final space = starterQuizTopics.first;
    final sameLevels = _copy(space, id: 'space_again');

    final topics = await BundledQuizRepository(
      topics: [space, space, sameLevels],
    ).loadTopics();

    expect([for (final t in topics) t.id], ['space']);
  });

  test('an empty catalogue loads as an empty list', () async {
    expect(await BundledQuizRepository(topics: []).loadTopics(), isEmpty);
  });
}
