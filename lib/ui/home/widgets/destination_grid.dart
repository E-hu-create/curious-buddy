import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../home_destination.dart';
import 'destination_art.dart';

/// Responsive grid of destination cards. Drops to one column on narrow
/// screens or with large system text so nothing gets squeezed or clipped.
class DestinationGrid extends StatelessWidget {
  const DestinationGrid({
    super.key,
    required this.destinations,
    required this.onSelected,
  });

  final List<HomeDestination> destinations;
  final ValueChanged<HomeDestination> onSelected;

  static const _spacing = 16.0;

  int _rowEnd(int start, int columns) {
    final end = start + columns;
    return columns < 3 && end > destinations.length ? destinations.length : end;
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = textScale >= 1.5 || width < 300
            ? 1
            : width >= 700
            ? 4
            : 2;
        // Rows of equal-height cards, so a long title in one card does not
        // leave its neighbour looking short.
        return Column(
          children: [
            for (var start = 0; start < destinations.length; start += columns)
              Padding(
                padding: EdgeInsets.only(
                  top: start == 0 ? 0 : _spacing + AppShapes.shadowDepth,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: .stretch,
                    children: [
                      // On phones a card left alone in its row fills it.
                      for (var i = start; i < _rowEnd(start, columns); i++) ...[
                        if (i > start) const SizedBox(width: _spacing),
                        Expanded(
                          child: i < destinations.length
                              ? DestinationCard(
                                  destination: destinations[i],
                                  onTap: () => onSelected(destinations[i]),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DestinationCard extends StatefulWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final HomeDestination destination;
  final VoidCallback onTap;

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final textTheme = Theme.of(context).textTheme;
    final sink = _pressed ? AppShapes.shadowDepth - 1 : 0.0;
    final borderRadius = BorderRadius.circular(AppShapes.radius);

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, sink, 0),
          constraints: const BoxConstraints(minHeight: 150),
          decoration: AppShapes.sticker(
            destination.tint,
            depth: AppShapes.shadowDepth - sink,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: widget.onTap,
              onHighlightChanged: (pressed) =>
                  setState(() => _pressed = pressed),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    DestinationArt(destination: destination),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        destination.title,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Text(
                        destination.subtitle,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
