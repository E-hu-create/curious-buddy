import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// How a child asks Buddy something: tap-to-talk, a text box, and suggested
/// questions.
///
/// Talking never sends anything by itself: recognised words arrive as a
/// [draft] in the text box, and the child taps Ask when they are happy.
class AskBuddyPanel extends StatefulWidget {
  const AskBuddyPanel({
    super.key,
    required this.enabled,
    required this.suggestions,
    required this.onAsk,
    required this.onTalk,
    required this.onFinishListening,
    required this.onCancelListening,
    this.isListening = false,
    this.liveWords = '',
    this.notice,
    this.draft,
    this.draftId = 0,
  });

  /// False while Buddy is preparing an answer.
  final bool enabled;
  final List<String> suggestions;
  final ValueChanged<String> onAsk;
  final VoidCallback onTalk;
  final VoidCallback onFinishListening;
  final VoidCallback onCancelListening;
  final bool isListening;
  final String liveWords;
  final String? notice;
  final String? draft;
  final int draftId;

  static const talkLabel = 'Talk to Buddy';
  static const listeningLabel = 'Listening...';
  static const listeningPrompt = 'Say your question now.';
  static const doneLabel = 'Done';
  static const cancelLabel = 'Cancel';
  static const fieldHint = 'Type a question';
  static const askLabel = 'Ask';
  static const maxLength = 200;

  @override
  State<AskBuddyPanel> createState() => _AskBuddyPanelState();
}

class _AskBuddyPanelState extends State<AskBuddyPanel> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(AskBuddyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final draft = widget.draft;
    if (widget.draftId != oldWidget.draftId && draft != null) {
      // Put the heard words in the box for checking; never auto-send.
      _controller.value = TextEditingValue(
        text: draft,
        selection: TextSelection.collapsed(offset: draft.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _inputEnabled => widget.enabled && !widget.isListening;
  bool get _canSend => _inputEnabled && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    final question = _controller.text;
    _controller.clear();
    _focus.unfocus();
    widget.onAsk(question);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final field = TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: _inputEnabled,
      maxLength: AskBuddyPanel.maxLength,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: (_) => _send(),
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: AskBuddyPanel.fieldHint,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.inkSoft,
          fontWeight: FontWeight.w500,
        ),
        counterText: '',
        filled: true,
        fillColor: AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: _border(),
        enabledBorder: _border(),
        disabledBorder: _border(),
        focusedBorder: _border(AppColors.brandBlueDeep),
      ),
    );
    final ask = FilledButton(
      onPressed: _canSend ? _send : null,
      child: const Text(AskBuddyPanel.askLabel),
    );
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= 1.3 ||
        MediaQuery.sizeOf(context).width < 340;
    final notice = widget.notice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.white, depth: 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          if (widget.isListening)
            _ListeningCard(
              words: widget.liveWords,
              onDone: widget.onFinishListening,
              onCancel: widget.onCancelListening,
            )
          else
            _TalkButton(onPressed: widget.enabled ? widget.onTalk : null),
          if (notice != null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(notice, style: textTheme.bodyMedium),
            ),
          ],
          const SizedBox(height: 10),
          // Side by side normally; stacked with large text or on narrow
          // screens so the box keeps room to show what is typed.
          if (stacked) ...[
            field,
            const SizedBox(height: 8),
            ask,
          ] else
            Row(
              children: [
                Expanded(child: field),
                const SizedBox(width: 8),
                ask,
              ],
            ),
          const SizedBox(height: 10),
          // One line that slides sideways, to keep the box small. Each idea
          // fits the box, so very large text wraps, not runs off the edge.
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  for (final (i, suggestion) in widget.suggestions.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: SuggestionButton(
                        label: suggestion,
                        onPressed: _inputEnabled
                            ? () => widget.onAsk(suggestion)
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border([Color color = AppColors.ink]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: AppShapes.outlineWidth),
      );
}

class _TalkButton extends StatelessWidget {
  const _TalkButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      icon: const Icon(Icons.mic_rounded, size: 26),
      label: const Text(AskBuddyPanel.talkLabel),
    );
  }
}

/// Shown only while the microphone is on: what is being heard, plus clear
/// ways to stop.
class _ListeningCard extends StatelessWidget {
  const _ListeningCard({
    required this.words,
    required this.onDone,
    required this.onCancel,
  });

  final String words;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.leafTint,
        borderRadius: BorderRadius.circular(AppShapes.radius),
        border: Border.all(color: AppColors.ink, width: AppShapes.outlineWidth),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.mic_rounded, color: AppColors.ink, size: 28),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  AskBuddyPanel.listeningLabel,
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(
              words.isEmpty ? AskBuddyPanel.listeningPrompt : words,
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_rounded),
                label: const Text(AskBuddyPanel.doneLabel),
              ),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded),
                label: const Text(AskBuddyPanel.cancelLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A suggested question. Unlike a chip, its text wraps, so long ideas stay
/// readable with large system text.
class SuggestionButton extends StatelessWidget {
  const SuggestionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        backgroundColor: AppColors.sunTint,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label, textAlign: TextAlign.start),
    );
  }
}
