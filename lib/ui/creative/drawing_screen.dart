import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/creations_repository.dart';
import '../../domain/creative/creation.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import 'creative_view_models.dart';
import 'widgets/creative_art.dart';
import 'widgets/creative_controls.dart';

/// Drawing Studio: draw with a finger, then save to the shelf.
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({
    super.key,
    required this.voice,
    required this.creationsRepository,
  });

  final BuddyVoice voice;
  final CreationsRepository creationsRepository;

  static const title = 'Drawing Studio';
  static const canvasLabel = 'Drawing area. Draw with your finger.';
  static const coloursTitle = 'Colour';
  static const sizeTitle = 'Brush';
  static const eraserLabel = 'Eraser';
  static const undoLabel = 'Undo';
  static const clearLabel = 'Start over';
  static const saveLabel = 'Save my drawing';
  static const drawAnother = 'Draw another';
  static const clearTitle = 'Start over?';
  static const clearText = 'Your drawing will be cleared.';
  static const clearYes = 'Yes, start over';
  static const clearNo = 'Keep drawing';
  static const fullText = DrawingViewModel.pointsFullLine;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late final DrawingViewModel _vm = DrawingViewModel(
    voice: widget.voice,
    creationsRepository: widget.creationsRepository,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateIntro();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  static DrawPoint _toCanvas(Offset local, double side) => DrawPoint(
    (local.dx / side * DrawPoint.scale).round(),
    (local.dy / side * DrawPoint.scale).round(),
  );

  Future<void> _confirmClear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(DrawingScreen.clearTitle),
        content: const Text(DrawingScreen.clearText),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(DrawingScreen.clearNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(DrawingScreen.clearYes),
          ),
        ],
      ),
    );
    if (yes == true) _vm.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(DrawingScreen.title, style: textTheme.titleMedium),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            final saved = _vm.saveStatus == CreationSaveStatus.saved;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      CreativeBuddyRow(vm: _vm),
                      const SizedBox(height: 10),
                      _canvas(),
                      if (_vm.pointsFull && !saved) ...[
                        const SizedBox(height: 8),
                        Text(
                          DrawingScreen.fullText,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      if (_vm.saveStatus != CreationSaveStatus.notSaved &&
                          _vm.saveStatus != CreationSaveStatus.saving) ...[
                        CreativeSaveNote(
                          status: _vm.saveStatus,
                          onAnother: _vm.startAgain,
                          anotherLabel: DrawingScreen.drawAnother,
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (!saved) ..._tools(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _canvas() => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.maxWidth;
      return Semantics(
        label: DrawingScreen.canvasLabel,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.ink, width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            // Claims the finger at once, so strokes draw instead of
            // scrolling the page.
            child: RawGestureDetector(
              gestures: {
                _ImmediatePanRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      _ImmediatePanRecognizer
                    >(_ImmediatePanRecognizer.new, (r) {
                      r.dragStartBehavior = DragStartBehavior.down;
                      r.onStart = (d) =>
                          _vm.startStroke(_toCanvas(d.localPosition, side - 5));
                      r.onUpdate = (d) => _vm.extendStroke(
                        _toCanvas(d.localPosition, side - 5),
                      );
                      r.onEnd = (_) => _vm.endStroke();
                      r.onCancel = _vm.endStroke;
                    }),
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: DrawingPainter(
                    strokes: _vm.strokes,
                    active: _vm.active,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  List<Widget> _tools() => [
    CreativeOptionGroup(
      title: DrawingScreen.coloursTitle,
      children: [
        for (var i = 0; i < CreativePalette.colors.length; i++)
          CreativeOption(
            label: CreativePalette.names[i],
            swatch: CreativePalette.colors[i],
            selected: !_vm.eraser && _vm.colorIndex == i,
            onTap: () => _vm.pickColor(i),
          ),
      ],
    ),
    const SizedBox(height: 12),
    CreativeOptionGroup(
      title: DrawingScreen.sizeTitle,
      children: [
        for (var i = 0; i < CreativePalette.sizeNames.length; i++)
          CreativeOption(
            label: CreativePalette.sizeNames[i],
            selected: _vm.sizeIndex == i,
            onTap: () => _vm.pickSize(i),
          ),
        CreativeOption(
          label: DrawingScreen.eraserLabel,
          selected: _vm.eraser,
          onTap: _vm.toggleEraser,
        ),
      ],
    ),
    const SizedBox(height: 14),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _vm.strokes.isEmpty ? null : _vm.undo,
          icon: const Icon(Icons.undo_rounded),
          label: const Text(DrawingScreen.undoLabel),
        ),
        OutlinedButton.icon(
          onPressed: _vm.strokes.isEmpty
              ? null
              : () => unawaited(_confirmClear()),
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text(DrawingScreen.clearLabel),
        ),
      ],
    ),
    const SizedBox(height: 14),
    FilledButton.icon(
      onPressed: _vm.canSave ? () => unawaited(_vm.save()) : null,
      icon: const Icon(Icons.save_rounded),
      label: const Text(DrawingScreen.saveLabel),
    ),
  ];
}

/// A pan that wins as soon as the finger touches the canvas, before the
/// page's scrolling can claim it.
class _ImmediatePanRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
