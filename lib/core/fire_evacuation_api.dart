import 'package:dio/dio.dart';

class FireEvacuationApi {
  FireEvacuationApi({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  baseUrl ??
                  const String.fromEnvironment(
                    'API_BASE_URL',
                    defaultValue: 'http://127.0.0.1:8000',
                  ),
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio _dio;

  Future<Map<String, dynamic>> getStatus() => _requestMap(
    _dio.get<Map<String, dynamic>>('/status'),
  );

  Future<Object?> getStudentCount({
    required String key,
    required String place,
  }) async =>
      (await _dio.get<Object>(
      '/student',
      queryParameters: {'key': key, 'place': place},
    )).data;

  Future<Map<String, dynamic>> postSmokeDensity({
    required String key,
    required String room,
    required int smokeVal,
  }) => _requestMap(
    _dio.post<Map<String, dynamic>>(
      '/smoke_density',
      queryParameters: {'key': key, 'room': room, 'smokeVal': smokeVal},
    ),
  );

  Future<Map<String, dynamic>> postCafeTemperature({
    required String key,
    required double temp,
  }) => _requestMap(
    _dio.post<Map<String, dynamic>>(
      '/cafe_temperature',
      queryParameters: {'key': key, 'temp': temp},
    ),
  );

  Future<Map<String, dynamic>> postEvacuationLights({
    required String key,
    required String dangerZone,
  }) => _requestMap(
    _dio.post<Map<String, dynamic>>(
      '/evacuation_lights',
      queryParameters: {'key': key, 'danger_zone': dangerZone},
    ),
  );

  Future<Map<String, dynamic>> postSensorReadings({
    required String key,
    required Map<String, int> readings,
    double? temp,
  }) {
    final payload = <String, dynamic>{'key': key, 'readings': readings};
    if (temp != null) payload['temp'] = temp;
    return _requestMap(_dio.post<Map<String, dynamic>>(
      '/sensor_readings',
      data: payload,
    ));
  }

  Future<Map<String, dynamic>> postPotentialFire({
    required String key,
    required String room,
    required int smokeVal,
    double? temp,
  }) {
    final parameters = <String, dynamic>{
      'key': key,
      'room': room,
      'smokeVal': smokeVal,
    };
    if (temp != null) parameters['temp'] = temp;
    return _requestMap(
      _dio.post<Map<String, dynamic>>(
        '/potential_fire',
        queryParameters: parameters,
      ),
    );
  }

  Future<Map<String, dynamic>> _requestMap(
    Future<Response<Map<String, dynamic>>> response,
  ) async {
    final data = (await response).data;
    if (data == null) {
      throw const FormatException('The fire server returned an empty response.');
    }
    return data;
  }
}
