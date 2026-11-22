import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: iconColor ?? colors.primary),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
