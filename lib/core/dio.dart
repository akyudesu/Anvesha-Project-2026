import 'package:dio/dio.dart';
import 'package:fire_evacuation_app/core/fire_evacuation_api.dart';

final dio = Dio(BaseOptions(baseUrl: FireEvacuationApi.defaultBaseUrl));
