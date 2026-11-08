import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class PillPicker<T> extends StatelessWidget {
  const PillPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: Semantics(
                selected: entry.key == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: entry.key == selected
                          ? colors.surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: entry.key == selected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: entry.key == selected
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AccentPicker extends StatelessWidget {
  const AccentPicker({
    super.key,
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  final AppAccent selected;
  final Map<AppAccent, String> labels;
  final ValueChanged<AppAccent> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, accent) in AppAccent.values.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _Swatch(
              color: AppColors.seed(accent),
              label: labels[accent] ?? accent.name,
              selected: accent == selected,
              onTap: () => onChanged(accent),
            ),
          ),
        ],
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: selected
                        ? [
                            BoxShadow(color: color, spreadRadius: 5),
                            BoxShadow(
                              color: theme.scaffoldBackgroundColor,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
