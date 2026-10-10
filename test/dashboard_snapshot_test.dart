import 'package:fire_evacuation_app/features/dashboard/data/dashboard_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the backend dashboard response', () {
    final snapshot = DashboardSnapshot.fromJson({
      'zones': [
        {'id': 'zone-1', 'name': 'BLOCK A', 'capacity': 40},
      ],
      'devices': [],
      'sensors': [],
      'sensor_readings': [
        {'zone_id': 'zone-1', 'value': 220, 'unit': 'ppm'},
      ],
      'occupancy_readings': [
        {'zone_id': 'zone-1', 'person_count': 12},
      ],
      'zone_risks': [
        {'zone_id': 'zone-1', 'risk_level': 'safe'},
      ],
      'incidents': [],
      'alerts': [],
      'routes': [],
      'user_profile': {'designated_wing': 'North'},
    });

    expect(snapshot.zones.single['name'], 'BLOCK A');
    expect(snapshot.sensorReadings.single['value'], 220);
    expect(snapshot.peopleInside, 12);
    expect(snapshot.totalCapacity, 40);
    expect(snapshot.userProfile?['designated_wing'], 'North');
  });

  test('rejects a malformed backend dashboard response', () {
    expect(
      () => DashboardSnapshot.fromJson({'zones': 'not-a-list'}),
      throwsFormatException,
    );
  });
}
