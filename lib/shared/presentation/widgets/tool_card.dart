import 'package:flutter/material.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isExternal;

  const ToolCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final iconSize = (cardWidth * 0.28).clamp(24.0, 40.0);
            final iconPadding = (cardWidth * 0.08).clamp(8.0, 14.0);
            final externalIconSize = (cardWidth * 0.1).clamp(10.0, 16.0);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: isDark ? 0.25 : 0.08),
                    color.withValues(alpha: isDark ? 0.1 : 0.02),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: iconSize, color: color),
                      ),
                      if (isExternal)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(Icons.open_in_new,
                              size: externalIconSize, color: color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
