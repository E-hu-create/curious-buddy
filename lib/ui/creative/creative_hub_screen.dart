import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/creations_repository.dart';
import '../../domain/creative/creation.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import 'creative_view_models.dart';
import 'creature_screen.dart';
import 'drawing_screen.dart';
import 'widgets/creative_art.dart';

class CreativeHubScreen extends StatefulWidget {
  const CreativeHubScreen({
    super.key,
    required this.creationsRepository,
    required this.voice,
  });

  final CreationsRepository creationsRepository;
  final BuddyVoice voice;

  static const title = 'Creative Island';
  static const welcome =
      'Welcome to Creative Island! Draw a picture or build a creature. '
      'Everything you save stays on this phone.';
  static const drawTitle = 'Drawing Studio';
  static const drawText = 'Draw with your finger in lots of colours.';
  static const drawLabel = 'Start drawing';
  static const creatureTitle = 'Creature Maker';
  static const creatureText = 'Build a friendly creature, part by part.';
  static const creatureLabel = 'Make a creature';
  static const shelfTitle = 'My Creations';
  static const emptyShelf =
      'Nothing here yet. Your drawings and creatures will appear here.';
  static const fullShelf =
      'Your shelf is full! Tap a creation and remove it to make room.';
  static const errorMessage =
      "Buddy couldn't open your shelf. Please try again.";
  static const retryLabel = 'Try again';

  static String shelfCount(int n, int max) => '$n of $max';

  @override
  State<CreativeHubScreen> createState() => _CreativeHubScreenState();
}

class _CreativeHubScreenState extends State<CreativeHubScreen> {
  late final CreativeHubViewModel _vm = CreativeHubViewModel(
    creationsRepository: widget.creationsRepository,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _open(Widget Function(BuildContext) builder, String name) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/creative/$name'),
        builder: builder,
      ),
    );
    await _vm.load();
  }

  Future<void> _view(Creation creation) async {
    final remove = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/creative/view'),
        builder: (_) => CreationViewScreen(creation: creation),
      ),
    );
    if (remove == true) await _vm.remove(creation.id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        CreativeHubScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Buddy(height: 96, mood: BuddyMood.excited),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            CreativeHubScreen.welcome,
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._body(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (_vm.status) {
      case CreativeStatus.loading:
        return const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading your creations',
              ),
            ),
          ),
        ];
      case CreativeStatus.error:
        return [
          Text(CreativeHubScreen.errorMessage, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => unawaited(_vm.load()),
              child: const Text(CreativeHubScreen.retryLabel),
            ),
          ),
        ];
      case CreativeStatus.ready:
        final full = _vm.isFull;
        return [
          _ActivityCard(
            icon: Icons.brush_rounded,
            color: AppColors.coral,
            tint: AppColors.coralTint,
            title: CreativeHubScreen.drawTitle,
            text: CreativeHubScreen.drawText,
            label: CreativeHubScreen.drawLabel,
            onStart: full
                ? null
                : () => unawaited(
                    _open(
                      (_) => DrawingScreen(
                        voice: widget.voice,
                        creationsRepository: widget.creationsRepository,
                      ),
                      'drawing',
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          _ActivityCard(
            icon: Icons.pets_rounded,
            color: AppColors.leaf,
            tint: AppColors.leafTint,
            title: CreativeHubScreen.creatureTitle,
            text: CreativeHubScreen.creatureText,
            label: CreativeHubScreen.creatureLabel,
            onStart: full
                ? null
                : () => unawaited(
                    _open(
                      (_) => CreatureScreen(
                        voice: widget.voice,
                        creationsRepository: widget.creationsRepository,
                      ),
                      'creature',
                    ),
                  ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  CreativeHubScreen.shelfTitle,
                  style: textTheme.titleLarge,
                ),
              ),
              Text(
                CreativeHubScreen.shelfCount(
                  _vm.shelf.items.length,
                  CreativeLimits.maxCreations,
                ),
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (full) ...[
            Text(
              CreativeHubScreen.fullShelf,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
          ],
          if (_vm.shelf.items.isEmpty)
            Text(CreativeHubScreen.emptyShelf, style: textTheme.bodyLarge)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 560 ? 4 : 2;
                const gap = 12.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final c in _vm.newestFirst)
                      SizedBox(
                        width: width,
                        child: _ShelfTile(
                          creation: c,
                          onTap: () => unawaited(_view(c)),
                        ),
                      ),
                  ],
                );
              },
            ),
        ];
    }
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.text,
    required this.label,
    required this.onStart,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final String text;
  final String label;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(tint),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 2.5),
                ),
                child: Icon(icon, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(title, style: textTheme.titleLarge),
                    Text(text, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({required this.creation, required this.onTap});

  final Creation creation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Open ${CreationDescriptions.describe(creation)}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: AppShapes.sticker(
              AppColors.white,
              depth: 3,
              radius: 18,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CreationPicture(creation: creation),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CreationDescriptions.title(creation),
                    style: textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One creation, big, with a way to remove it. Pops `true` to remove.
class CreationViewScreen extends StatelessWidget {
  const CreationViewScreen({super.key, required this.creation});

  final Creation creation;

  static const removeLabel = 'Remove from my shelf';
  static const confirmTitle = 'Remove this creation?';
  static const confirmText = 'It will be gone from your shelf for good.';
  static const yesLabel = 'Yes, remove it';
  static const keepLabel = 'Keep it';
  static const backLabel = 'Back to Creative Island';

  Future<void> _confirm(BuildContext context) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(confirmTitle),
        content: const Text(confirmText),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(keepLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(yesLabel),
          ),
        ],
      ),
    );
    if (remove == true && context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      CreationDescriptions.title(creation),
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: AppShapes.sticker(AppColors.white),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CreationPicture(creation: creation),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CreationDescriptions.describe(creation),
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => unawaited(_confirm(context)),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text(removeLabel),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text(backLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
