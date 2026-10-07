import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 220;

          return Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 18),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _StatIcon(icon: icon, color: color, size: 30),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.65),
                          fontSize: 10,
                          letterSpacing: 0.65,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.55),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _StatIcon(icon: icon, color: color, size: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface.withValues(alpha: 0.65),
                                fontSize: 10,
                                letterSpacing: 0.65,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface.withValues(alpha: 0.55),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color),
    );
  }
}
