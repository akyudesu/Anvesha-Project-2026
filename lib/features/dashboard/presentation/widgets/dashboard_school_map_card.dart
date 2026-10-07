import 'package:flutter/material.dart';

class DashboardSchoolMapCard extends StatelessWidget {
  const DashboardSchoolMapCard({
    super.key,
    this.zones = const [],
    this.risksByZone = const {},
  });

  final List<Map<String, dynamic>> zones;
  final Map<String, Map<String, dynamic>> risksByZone;

  Color _riskColor(String? level) => switch (level) {
    'critical' || 'high' => const Color(0xFFE63946),
    'caution' => const Color(0xFFF6C453),
    _ => const Color(0xFF55C987),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeHazards = risksByZone.values.where((risk) {
      final level = risk['risk_level'];
      return level == 'high' || level == 'critical';
    }).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, color: colors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Live school map',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${zones.length} ZONES',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.55),
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: Colors.white,
                child: AspectRatio(
                  aspectRatio: 1.08,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.asset(
                      'unnamed.png',
                      fit: BoxFit.contain,
                      semanticLabel: 'School campus evacuation map',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  activeHazards == 0 ? Icons.check_circle : Icons.warning,
                  color: activeHazards == 0
                      ? const Color(0xFF55C987)
                      : const Color(0xFFE63946),
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activeHazards == 0
                        ? 'No high-risk zones reported'
                        : '$activeHazards zone(s) marked high risk',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'PINCH TO ZOOM',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.45),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            if (zones.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zones.map((zone) {
                  final id = zone['id']?.toString();
                  final risk = id == null ? null : risksByZone[id];
                  final level = risk?['risk_level']?.toString() ?? 'safe';
                  final color = _riskColor(level);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '${zone['name'] ?? 'Zone'} · ${level.toUpperCase()}',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
