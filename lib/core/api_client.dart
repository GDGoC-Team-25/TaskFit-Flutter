import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient() : dio = Dio(BaseOptions(baseUrl: "https://taskfit-api-286917368950.asia-northeast3.run.app")) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 백엔드 표준 응답 래퍼 {"success": true, "data": ...} 자동 언래핑
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('success') && data.containsKey('data')) {
          response.data = data['data'];
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("API Error: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }
}
