import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../utils/l10n.dart';

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onScan,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(35);
    final l10n = context.l10n;
    final brand = context.brand;

    Widget item(int index, IconData icon, String label) {
      final selected = index == currentIndex;
      final color = selected ? scheme.primary : scheme.onSurfaceVariant;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: InkResponse(
            onTap: () => onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.4 : 0.14,
                      ),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(
                          alpha: isDark ? 0.55 : 0.62,
                        ),
                        borderRadius: radius,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.08 : 0.75,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          item(0, LucideIcons.house, l10n.navHome),
                          item(1, LucideIcons.history, l10n.navHistory),
                          // empty gap under the raised scan button
                          const SizedBox(width: 76),
                          item(2, LucideIcons.mapPin, l10n.navGarages),
                          item(3, LucideIcons.layoutGrid, l10n.navMore),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -26,
              child: Tooltip(
                message: l10n.navScan,
                child: Material(
                  color: brand.fill,
                  elevation: 6,
                  shadowColor: brand.fill.withValues(alpha: 0.5),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: theme.scaffoldBackgroundColor,
                      width: 6,
                    ),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onScan,
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: Icon(
                        LucideIcons.scanLine,
                        color: brand.onFill,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
