import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/home/widgets/ask_buddy_panel.dart';
import 'package:curious_buddy/ui/home/widgets/buddy_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
  });

  Future<void> openHome(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, speech: speech));
    await tester.pumpAndSettle();
  }

  Future<void> tapChip(WidgetTester tester, String label) async {
    final chip = find.widgetWithText(SuggestionButton, label);
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  Future<void> typeAndAsk(WidgetTester tester, String question) async {
    await tester.enterText(find.byType(TextField), question);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, AskBuddyPanel.askLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('shows Buddy, the talk button, text box and starter ideas', (
    tester,
  ) async {
    await openHome(tester);

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
    expect(find.text(AskBuddyPanel.talkLabel), findsOneWidget);
    expect(find.text(AskBuddyPanel.comingSoonTag), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    for (final prompt in starterPrompts) {
      expect(find.widgetWithText(SuggestionButton, prompt), findsOneWidget);
    }
  });

  testWidgets('tapping an idea shows the question, answer and speaks it', (
    tester,
  ) async {
    await openHome(tester);

    await tapChip(tester, 'Why is the sky blue?');

    expect(
      find.text(BuddyGreeting.youAskedLabel('Why is the sky blue?')),
      findsOneWidget,
    );
    expect(find.textContaining('blue light'), findsOneWidget);
    expect(tts.spoken.last, contains('blue light'));
    // Follow-up ideas replace the starters.
    expect(
      find.widgetWithText(SuggestionButton, 'Why are sunsets orange?'),
      findsOneWidget,
    );
  });

  testWidgets('typing a question and tapping Ask answers it', (tester) async {
    await openHome(tester);

    await typeAndAsk(tester, 'Are you human?');

    expect(find.textContaining('computer character'), findsOneWidget);
    // The box is cleared for the next question.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Ask is disabled until something is typed', (tester) async {
    await openHome(tester);

    final ask = find.widgetWithText(FilledButton, AskBuddyPanel.askLabel);
    expect(tester.widget<FilledButton>(ask).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(tester.widget<FilledButton>(ask).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump();
    expect(tester.widget<FilledButton>(ask).onPressed, isNotNull);
  });

  testWidgets('the keyboard send key also asks', (tester) async {
    await openHome(tester);

    await tester.enterText(find.byType(TextField), 'Tell me a space fact.');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(
      find.text(BuddyGreeting.youAskedLabel('Tell me a space fact.')),
      findsOneWidget,
    );
  });

  testWidgets('Stop talking stops an answer mid-sentence', (tester) async {
    tts.holdSpeech = true;
    await openHome(tester);
    await tester.tap(find.text(BuddyGreeting.stopLabel)); // stop welcome
    await tester.pumpAndSettle();

    await tapChip(tester, 'Tell me an animal fact.');
    expect(tts.isSpeaking, isTrue);
    await tester.ensureVisible(find.text(BuddyGreeting.stopLabel));
    await tester.tap(find.text(BuddyGreeting.stopLabel));
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
    expect(find.text(BuddyGreeting.replayLabel), findsOneWidget);
  });

  testWidgets("an answer's activity button opens that screen", (tester) async {
    await openHome(tester);
    await tapChip(tester, "Let's play a quiz.");

    final peek = find.text('Peek at quizzes');
    await tester.ensureVisible(peek);
    await tester.tap(peek);
    await tester.pumpAndSettle();

    expect(find.text('Quiz Time'), findsOneWidget);
    expect(find.textContaining('Quizzes are coming soon'), findsOneWidget);
  });

  testWidgets('adventure opens Mystery Missions', (tester) async {
    await openHome(tester);
    await tapChip(tester, 'Take me on an adventure.');

    final open = find.text('Open Mystery Missions');
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();

    expect(find.textContaining('Mystery Missions are coming soon'), findsOne);
  });

  testWidgets('activities never open by themselves', (tester) async {
    await openHome(tester);

    await tapChip(tester, 'Take me on an adventure.');

    // Still on Home: the child has to tap the button.
    expect(find.text(AskBuddyPanel.talkLabel), findsOneWidget);
  });

  testWidgets('personal information is hidden on screen', (tester) async {
    await openHome(tester);

    await typeAndAsk(tester, 'my phone number is 07700 900123');

    expect(find.textContaining('07700'), findsNothing);
    expect(find.text(BuddyGreeting.hiddenQuestionNote), findsOneWidget);
    expect(
      find.text(ChildSafetyFilter.personalInfoResponse.text),
      findsOneWidget,
    );
  });

  testWidgets('unknown questions get an honest answer', (tester) async {
    await openHome(tester);

    await typeAndAsk(tester, 'What is the capital of Mongolia?');

    expect(find.textContaining("I don't know that one yet"), findsOneWidget);
  });

  group('talk button (voice input not built yet)', () {
    testWidgets('explains it is coming soon and never touches the mic', (
      tester,
    ) async {
      await openHome(tester);

      await tester.tap(find.text(AskBuddyPanel.talkLabel));
      await tester.pumpAndSettle();

      expect(find.text(AskBuddyPanel.talkSoonTitle), findsOneWidget);
      expect(speech.totalCalls, 0);
      expect(speech.permissionRequests, 0);
    });

    testWidgets('"Type instead" closes it and focuses the text box', (
      tester,
    ) async {
      await openHome(tester);
      await tester.tap(find.text(AskBuddyPanel.talkLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AskBuddyPanel.typeInsteadLabel));
      await tester.pumpAndSettle();

      expect(find.text(AskBuddyPanel.talkSoonTitle), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isTrue);
    });
  });

  testWidgets('status badge shows Talking only while Buddy talks', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openHome(tester);
    expect(find.text(BuddyStatus.talking.label), findsOneWidget);

    await tester.tap(find.text(BuddyGreeting.stopLabel));
    await tester.pumpAndSettle();

    expect(find.text(BuddyStatus.talking.label), findsNothing);
    expect(find.text(BuddyStatus.thinking.label), findsNothing);
  });

  testWidgets('long ideas wrap instead of being cut off at 2x text', (
    tester,
  ) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(buildTestApp(tts: tts, speech: speech));
    await tester.pumpAndSettle();

    final label = find.descendant(
      of: find.widgetWithText(SuggestionButton, 'Take me on an adventure.'),
      matching: find.byType(Text),
    );
    await tester.ensureVisible(label);
    final paragraph = tester.renderObject<RenderParagraph>(label);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.size.height, greaterThan(40), reason: 'wrapped lines');
  });

  testWidgets('navigating away mid-answer stops speech', (tester) async {
    tts.holdSpeech = true;
    await openHome(tester);
    await typeAndAsk(tester, 'Tell me a space fact.');
    expect(tts.spoken.last, isNot(HomeViewModel.greeting));
    expect(tts.isSpeaking, isTrue);

    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
  });
}
