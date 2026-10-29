import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// A titled card in the Parent Zone.
class ParentSection extends StatelessWidget {
  const ParentSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.color = AppColors.white,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: AppShapes.sticker(color, depth: 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: textTheme.titleLarge),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// A plain paragraph in a section.
class ParentNote extends StatelessWidget {
  const ParentNote(this.text, {super.key, this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: bold ? style?.copyWith(fontWeight: FontWeight.w700) : style,
      ),
    );
  }
}

/// A short bulleted list.
class ParentBullets extends StatelessWidget {
  const ParentBullets(this.items, {super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Text('•  ', style: style),
                  Expanded(child: Text(item, style: style)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
