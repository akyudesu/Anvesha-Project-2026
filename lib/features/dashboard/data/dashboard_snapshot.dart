import 'package:fire_evacuation_app/core/supabase_service.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.zones,
    required this.devices,
    required this.sensors,
    required this.sensorReadings,
    required this.occupancyReadings,
    required this.zoneRisks,
    required this.incidents,
    required this.alerts,
    required this.routes,
    required this.userProfile,
  });

  final List<Map<String, dynamic>> zones;
  final List<Map<String, dynamic>> devices;
  final List<Map<String, dynamic>> sensors;
  final List<Map<String, dynamic>> sensorReadings;
  final List<Map<String, dynamic>> occupancyReadings;
  final List<Map<String, dynamic>> zoneRisks;
  final List<Map<String, dynamic>> incidents;
  final List<Map<String, dynamic>> alerts;
  final List<Map<String, dynamic>> routes;
  final Map<String, dynamic>? userProfile;

  static Future<DashboardSnapshot> load() async {
    final results = await Future.wait<List<Map<String, dynamic>>>([
      SupabaseService.getZones(),
      SupabaseService.getDevices(),
      SupabaseService.getSensors(),
      SupabaseService.getRecentSensorReadings(),
      SupabaseService.getRecentOccupancyReadings(),
      SupabaseService.getZoneRisks(),
      SupabaseService.getActiveIncidents(),
      SupabaseService.getActiveAlerts(),
      SupabaseService.getRecommendedRoutes(),
    ]);
    return DashboardSnapshot(
      zones: results[0],
      devices: results[1],
      sensors: results[2],
      sensorReadings: results[3],
      occupancyReadings: results[4],
      zoneRisks: results[5],
      incidents: results[6],
      alerts: results[7],
      routes: results[8],
      userProfile: await SupabaseService.getCurrentUserProfile(),
    );
  }

  int get peopleInside {
    final latestByZone = <String, int>{};
    for (final reading in occupancyReadings) {
      final zoneId = reading['zone_id']?.toString();
      final count = reading['person_count'];
      if (zoneId != null && count is num) {
        latestByZone.putIfAbsent(zoneId, () => count.toInt());
      }
    }
    return latestByZone.values.fold(0, (total, count) => total + count);
  }

  int get totalCapacity => zones.fold<int>(
    0,
    (total, zone) => total + ((zone['capacity'] as num?)?.toInt() ?? 0),
  );

  int get dangerZoneCount => zoneRisks.where((risk) {
    final level = risk['risk_level'];
    return level == 'high' || level == 'critical';
  }).length;

  int get availableExits => zones.where((zone) {
    if (zone['zone_type'] != 'exit' || zone['is_active'] == false) {
      return false;
    }
    final risk = zoneRisks.where((item) => item['zone_id'] == zone['id']);
    if (risk.isEmpty) return true;
    final level = risk.first['risk_level'];
    return level != 'high' && level != 'critical';
  }).length;

  List<Map<String, dynamic>> get latestOccupancyByZone {
    final latestByZone = <String, Map<String, dynamic>>{};
    for (final reading in occupancyReadings) {
      final zoneId = reading['zone_id']?.toString();
      if (zoneId != null) latestByZone.putIfAbsent(zoneId, () => reading);
    }
    return latestByZone.values.toList(growable: false);
  }

  Map<String, Map<String, dynamic>> get risksByZone {
    return {
      for (final risk in zoneRisks)
        if (risk['zone_id'] != null) risk['zone_id'].toString(): risk,
    };
  }
}
