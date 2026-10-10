import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  static Future<void> signOut() => _client.auth.signOut();

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profile = await _client
        .from('users')
        .select('id,registered_at,designated_wing,class_incharge,class')
        .eq('id', user.id)
        .maybeSingle();
    return profile == null ? null : Map<String, dynamic>.from(profile);
  }

  static Future<Map<String, dynamic>> createUserProfile({
    required String registeredAt,
    String? designatedWing,
    bool? isClassIncharge,
    String? className,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in before creating a profile.');
    final profile = await _client
        .from('users')
        .insert({
          'id': user.id,
          'registered_at': registeredAt,
          'designated_wing': designatedWing,
          'class_incharge': isClassIncharge,
          'class': className,
        })
        .select('id,registered_at,designated_wing,class_incharge,class')
        .single();
    return Map<String, dynamic>.from(profile);
  }

  static Future<void> updateCurrentUserProfile({
    String? designatedWing,
    bool? isClassIncharge,
    String? className,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in before updating a profile.');
    final values = <String, dynamic>{
      'designated_wing': designatedWing,
      'class_incharge': isClassIncharge,
      'class': className,
    }..removeWhere((_, value) => value == null);
    if (values.isEmpty) return;
    await _client.from('users').update(values).eq('id', user.id);
  }

  static Future<List<Map<String, dynamic>>> getZones() =>
      _select('zones', orderBy: 'name');

  static Future<List<Map<String, dynamic>>> getDevices() =>
      _select('devices', orderBy: 'device_name');

  static Future<List<Map<String, dynamic>>> getSensors() =>
      _select('sensors', orderBy: 'sensor_name');

  static Future<List<Map<String, dynamic>>> getRecentSensorReadings({
    int limit = 100,
  }) => _select(
    'sensor_readings',
    orderBy: 'recorded_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getRecentOccupancyReadings({
    int limit = 100,
  }) => _select(
    'occupancy_readings',
    orderBy: 'recorded_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getZoneRisks() =>
      _select('zone_risk');

  static Future<List<Map<String, dynamic>>> getActiveIncidents({
    int limit = 50,
  }) => _select(
    'incidents',
    filters: {'status': 'active'},
    orderBy: 'detected_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getActiveAlerts({
    int limit = 50,
  }) => _select(
    'alerts',
    filters: {'is_acknowledged': false},
    orderBy: 'created_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getRecommendedRoutes({
    int limit = 10,
  }) => _select(
    'evacuation_routes',
    filters: {'is_recommended': true},
    orderBy: 'calculated_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getEvacuationRoutes({
    int limit = 50,
  }) => _select(
    'evacuation_routes',
    orderBy: 'calculated_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getDeviceCommands({
    int limit = 50,
  }) => _select(
    'device_commands',
    orderBy: 'created_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getSystemEvents({
    int limit = 50,
  }) => _select(
    'system_events',
    orderBy: 'created_at',
    descending: true,
    limit: limit,
  );

  static Future<List<Map<String, dynamic>>> getRouteSteps(String routeId) =>
      _select(
        'evacuation_route_steps',
        filters: {'route_id': routeId},
        orderBy: 'step_order',
      );

  static Future<Map<String, dynamic>> addSensorReading({
    required String sensorId,
    required num value,
    String? zoneId,
    String? unit,
  }) => _insert('sensor_readings', {
    'sensor_id': sensorId,
    'zone_id': zoneId,
    'value': value,
    'unit': unit,
  });

  static Future<Map<String, dynamic>> addOccupancyReading({
    required String zoneId,
    required int personCount,
    num? confidence,
    String source = 'manual',
  }) => _insert('occupancy_readings', {
    'zone_id': zoneId,
    'person_count': personCount,
    'confidence': confidence,
    'source': source,
  });

  static Future<Map<String, dynamic>> createIncident({
    required String incidentType,
    required String severity,
    String? zoneId,
    String? description,
  }) => _insert('incidents', {
    'incident_type': incidentType,
    'severity': severity,
    'zone_id': zoneId,
    'description': description,
  });

  static Future<Map<String, dynamic>> createAlert({
    required String title,
    required String message,
    required String severity,
    String? zoneId,
    String? incidentId,
  }) => _insert('alerts', {
    'title': title,
    'message': message,
    'severity': severity,
    'zone_id': zoneId,
    'incident_id': incidentId,
  });

  static Future<void> acknowledgeAlert(String alertId) async {
    await _client
        .from('alerts')
        .update({
          'is_acknowledged': true,
          'acknowledged_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', alertId);
  }

  static Future<Map<String, dynamic>> createDeviceCommand({
    required String deviceId,
    required String commandType,
    Map<String, dynamic>? payload,
  }) => _insert('device_commands', {
    'device_id': deviceId,
    'command_type': commandType,
    'payload': payload,
  });

  static Future<List<Map<String, dynamic>>> _select(
    String table, {
    Map<String, Object> filters = const {},
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    dynamic query = _client.from(table).select();
    for (final filter in filters.entries) {
      query = query.eq(filter.key, filter.value);
    }
    if (orderBy != null) {
      query = query.order(orderBy, ascending: !descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    final rows = await query;
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> _insert(
    String table,
    Map<String, dynamic> values,
  ) async {
    values.removeWhere((_, value) => value == null);
    final row = await _client.from(table).insert(values).select().single();
    return Map<String, dynamic>.from(row);
  }
}
