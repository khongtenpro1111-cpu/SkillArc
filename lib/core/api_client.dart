import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.1.104:8080/api'; // Đã cập nhật theo IP máy tính của bạn
  late Dio dio;
  final storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15), // Tăng lên 15 giây
      receiveTimeout: const Duration(seconds: 13), // Tăng lên 13 giây
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ bộ nhớ bảo mật và thêm vào header
        String? token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Xử lý khi token hết hạn (ví dụ: logout hoặc refresh token)
        }
        return handler.next(e);
      },
    ));
  }
}
