import 'package:flutter/material.dart';

class DashboardRouteCard extends StatelessWidget {
  const DashboardRouteCard({
    super.key,
    this.routes = const [],
    this.zones = const [],
  });

  final List<Map<String, dynamic>> routes;
  final List<Map<String, dynamic>> zones;

  String _zoneName(Object? zoneId) {
    for (final zone in zones) {
      if (zone['id'] == zoneId) return zone['name']?.toString() ?? 'Zone';
    }
    return 'Unknown zone';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final route = routes.isEmpty ? null : routes.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route_rounded, color: colors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Recommended evacuation route',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Route recommendations stored by the evacuation engine',
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            if (route == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No recommended route is currently stored.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              )
            else ...[
              _RouteStep(
                label: _zoneName(route['source_zone_id']),
                icon: Icons.my_location_rounded,
              ),
              const _RouteConnector(),
              _RouteStep(
                label: _zoneName(route['destination_zone_id']),
                icon: Icons.exit_to_app_rounded,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _RouteMetric(
                    label: 'DISTANCE',
                    value: '${route['distance'] ?? '—'}',
                  ),
                  _RouteMetric(
                    label: 'RISK SCORE',
                    value: '${route['risk_score'] ?? '—'}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteStep extends StatelessWidget {
  const _RouteStep({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.primary, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _RouteConnector extends StatelessWidget {
  const _RouteConnector();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 15,
        width: 2,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
      ),
    ),
  );
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          fontSize: 9,
        ),
      ),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
