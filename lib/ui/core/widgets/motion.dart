import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_colors.dart';

/// Short, one-off motion shared across the app. Nothing here loops forever,
/// and everything is skipped when the phone's "Remove animations" or the
/// Parent Zone's "Calmer animations" is on.
abstract final class AppMotion {
  static const quick = Duration(milliseconds: 160);
  static const page = Duration(milliseconds: 280);

  static bool isCalm(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// A light tap on the phone for a good moment.
  static void buzz(BuildContext context) {
    if (!isCalm(context)) HapticFeedback.lightImpact().ignore();
  }
}

/// Fade with a small rise, used for every page change on Android.
class GentlePageTransitions extends PageTransitionsBuilder {
  const GentlePageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.isCalm(context)) return child;
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Makes a sticker sink slightly while it is pressed.
class StickerPress extends StatefulWidget {
  const StickerPress({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<StickerPress> createState() => _StickerPressState();
}

class _StickerPressState extends State<StickerPress> {
  bool _down = false;

  void _set(bool down) {
    if (widget.enabled && down != _down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isCalm(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: AppMotion.quick,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Slides and fades between pages of the same screen: story pages, quiz
/// questions, mission steps. Give each page its own [pageKey].
class PageSwap extends StatelessWidget {
  const PageSwap({super.key, required this.pageKey, required this.child});

  final Object pageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppMotion.isCalm(context) ? Duration.zero : AppMotion.page,
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    layoutBuilder: (current, previous) => Stack(
      alignment: Alignment.topCenter,
      children: [...previous, ?current],
    ),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: KeyedSubtree(key: ValueKey(pageKey), child: child),
  );
}

/// Pops in once when it first appears, after an optional [delay].
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  static const _pop = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isCalm(context)) return child;
    final total = delay + _pop;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutBack,
      ),
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: child,
    );
  }
}

enum ReactionKind { pop, shake }

/// Plays once when [active] turns on: a small pop or a gentle shake. Give
/// it a new key for each new thing it reacts to.
class ReactOnce extends StatelessWidget {
  const ReactOnce({
    super.key,
    required this.active,
    required this.kind,
    required this.child,
  });

  final bool active;
  final ReactionKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isCalm(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? 1 : 0),
      duration: const Duration(milliseconds: 380),
      builder: (context, t, child) => switch (kind) {
        ReactionKind.pop => Transform.scale(
          scale: 1 + 0.035 * math.sin(math.pi * t),
          child: child,
        ),
        ReactionKind.shake => Transform.translate(
          offset: Offset(math.sin(t * math.pi * 4) * 5 * (1 - t), 0),
          child: child,
        ),
      },
      child: child,
    );
  }
}

/// Covers [child] and bursts confetti whenever [celebrationKey] gives a new
/// key. Return null when there is nothing to celebrate.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.listenable,
    required this.celebrationKey,
    required this.child,
  });

  final Listenable listenable;
  final Object? Function() celebrationKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      ListenableBuilder(
        listenable: listenable,
        builder: (context, _) {
          final key = celebrationKey();
          if (key == null || AppMotion.isCalm(context)) {
            return const SizedBox.shrink();
          }
          return ConfettiBurst(key: ValueKey(key));
        },
      ),
    ],
  );
}

/// One burst of paper confetti, drawn in code. Purely decorative: it cannot
/// be touched and screen readers skip it.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  static const duration = Duration(milliseconds: 1600);

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ConfettiBurst.duration,
  )..forward();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppMotion.buzz(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: CustomPaint(
        painter: _ConfettiPainter(_controller),
        size: Size.infinite,
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static const _colors = [
    AppColors.coral,
    AppColors.sun,
    AppColors.leaf,
    AppColors.brandBlue,
    AppColors.grape,
  ];
  static const _pieces = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    final random = math.Random(7);
    final fade = t > 0.75 ? (1 - t) / 0.25 : 1.0;
    for (var i = 0; i < _pieces; i++) {
      final x = random.nextDouble() * size.width;
      final start = random.nextDouble() * 0.2;
      final speed = 0.8 + random.nextDouble() * 0.7;
      final drift = (random.nextDouble() - 0.5) * 60;
      final spin = random.nextDouble() * 6 + 2;
      final color = _colors[i % _colors.length];
      final local = ((t - start) / (1 - start)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -20 + local * speed * size.height;
      canvas
        ..save()
        ..translate(x + drift * math.sin(local * math.pi * 2), y)
        ..rotate(local * spin)
        ..drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-5, -3, 10, 6),
            const Radius.circular(1.5),
          ),
          Paint()..color = color.withValues(alpha: fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
