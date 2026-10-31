import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/access/access_controller.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/ui/core/widgets/access_scope.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/unlock_section.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const _forest = 'The Forest That Forgot Its Colours';
const _ananse = 'Ananse and the Pot of Wisdom';

int _wordsToNumber(String words) {
  const units = {
    'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, //
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11,
    'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
    'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
    'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
    'seventy': 70, 'eighty': 80, 'ninety': 90,
  };
  return words.split('-').fold(0, (sum, w) => sum + units[w]!);
}

void main() {
  late InMemoryKeyValueStore store;
  late FakePurchaseService purchases;

  setUp(() {
    store = InMemoryKeyValueStore();
    purchases = FakePurchaseService();
  });

  Future<void> start(WidgetTester tester, {bool locksOn = true}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(store: store, purchases: purchases, locksOn: locksOn),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) =>
      tapFinder(tester, find.text(text).first);

  Future<void> openGrownUps(WidgetTester tester) async {
    await tapText(tester, 'Grown-ups');
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('What is '));
    final m = RegExp(
      r'^What is ([a-z-]+) times ([a-z-]+)\?$',
    ).firstMatch(question)!;
    final answer = _wordsToNumber(m[1]!) * _wordsToNumber(m[2]!);
    await tester.enterText(find.byType(TextField), '$answer');
    await tapText(tester, ParentGateView.checkLabel);
  }

  testWidgets('free stories play; others ask for a grown-up, calmly', (
    tester,
  ) async {
    await start(tester);
    await tapText(tester, HomeDestination.stories.title);

    expect(
      storyCardButton(StoriesScreen.startLabel, story: _forest),
      findsOneWidget,
    );
    expect(
      storyCardButton(AskGrownUpButton.label, story: _ananse),
      findsOneWidget,
    );

    await tapFinder(
      tester,
      storyCardButton(AskGrownUpButton.label, story: _ananse),
    );
    expect(find.text(AskGrownUpButton.message), findsOneWidget);
    // No prices or sales talk for children.
    expect(find.textContaining(purchases.storePrice!), findsNothing);
    await tapText(tester, AskGrownUpButton.okLabel);
    expect(purchases.buyCalls, 0);
  });

  testWidgets('Game Zone: five games are free, the rest ask', (tester) async {
    await start(tester);
    await tapText(tester, HomeDestination.games.title);

    // Dino Discovery, Treasure Maze and the Arena keep their Play buttons.
    expect(find.text(GameZoneScreen.dinoLabel), findsOneWidget);
    expect(find.text(GameZoneScreen.mazeLabel), findsOneWidget);
    expect(find.text(GameZoneScreen.arenaLabel), findsOneWidget);
    expect(find.text(GameZoneScreen.sudokuLabel), findsNothing);
    expect(find.text(AskGrownUpButton.label), findsNWidgets(9));
    expect(find.text(GameKind.sudoku.title), findsOneWidget);
  });

  testWidgets('a grown-up unlocks everything in Grown-ups', (tester) async {
    await start(tester);
    await openGrownUps(tester);

    expect(find.text(UnlockSection.title), findsWidgets);
    expect(
      find.text(UnlockSection.priceLabel(purchases.storePrice!)),
      findsOneWidget,
    );
    await tapText(tester, UnlockSection.unlockLabel);

    expect(purchases.buyCalls, 1);
    expect(find.text(UnlockSection.unlockedNote), findsOneWidget);
    expect(await store.read(AccessController.key), 'true');

    await tapText(tester, 'Back to Buddy');
    await tapText(tester, HomeDestination.stories.title);
    expect(find.text(AskGrownUpButton.label), findsNothing);
  });

  testWidgets('restore with nothing to find says so', (tester) async {
    await start(tester);
    await openGrownUps(tester);

    await tapText(tester, UnlockSection.restoreLabel);
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();

    expect(find.text(UnlockSection.notFound), findsOneWidget);
    expect(find.text(UnlockSection.unlockedNote), findsNothing);
  });

  testWidgets('test builds are fully open and say so in Grown-ups', (
    tester,
  ) async {
    await start(tester, locksOn: false);
    await tapText(tester, HomeDestination.stories.title);
    expect(find.text(AskGrownUpButton.label), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await openGrownUps(tester);
    expect(find.text(UnlockSection.testBuild), findsOneWidget);
    expect(find.text(UnlockSection.unlockLabel), findsNothing);
  });
}
