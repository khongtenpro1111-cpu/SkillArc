import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:skill_arc/core/api_client.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/services/local_db_service.dart';

class AuthService {
  final _apiClient = ApiClient();

  // Đăng nhập qua API Backend
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/signin', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        // Lưu JWT Token vào bộ nhớ bảo mật
        await _apiClient.storage.write(key: 'jwt_token', value: token);
        // Lưu thông tin user cơ bản
        await _apiClient.storage.write(key: 'user_data', value: jsonEncode(response.data));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      return false;
    }
  }

  // Đăng ký qua API Backend
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/signup', data: {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw e.response?.data['message'] ?? 'Lỗi đăng ký';
      }
      throw 'Không thể kết nối đến máy chủ';
    }
  }

  Future<void> logout() async {
    await _apiClient.storage.deleteAll();
  }

  Future<User?> getCurrentUser() async {
    String? userData = await _apiClient.storage.read(key: 'user_data');
    if (userData != null) {
      final map = jsonDecode(userData);
      
      // Lấy thêm thông tin cập nhật ở cục bộ (như avatarPath, bio, phoneNumber, githubUrl)
      final localUser = LocalDbService.getUser();
      final localFullName = localUser != null ? localUser['fullName'] as String? : null;
      final localAvatarPath = localUser != null ? localUser['avatarPath'] as String? : null;
      final localBio = localUser != null ? localUser['bio'] as String? : null;
      final localPhoneNumber = localUser != null ? localUser['phoneNumber'] as String? : null;
      final localGithubUrl = localUser != null ? localUser['githubUrl'] as String? : null;

      return User(
        id: map['id'],
        username: map['username'],
        email: localUser != null ? (localUser['email'] as String? ?? map['email']) : map['email'],
        fullName: localFullName ?? map['fullName'] ?? '',
        avatarPath: localAvatarPath,
        bio: localBio ?? map['bio'] as String?,
        phoneNumber: localPhoneNumber ?? map['phoneNumber'] as String?,
        githubUrl: localGithubUrl ?? map['githubUrl'] as String?,
      );
    }
    return null;
  }

  // Cập nhật thông tin hồ sơ lên Backend và bộ nhớ Secure Storage
  Future<bool> updateProfile({
    required String fullName,
    required String email,
    String? bio,
    String? phoneNumber,
    String? githubUrl,
  }) async {
    try {
      final response = await _apiClient.dio.put('/users/profile', data: {
        'fullName': fullName,
        'email': email,
        'bio': bio,
        'phoneNumber': phoneNumber,
        'githubUrl': githubUrl,
      });

      if (response.statusCode == 200) {
        // Cập nhật lại cache user_data trong secure storage
        final currentDataStr = await _apiClient.storage.read(key: 'user_data');
        if (currentDataStr != null) {
          final currentMap = jsonDecode(currentDataStr);
          currentMap['fullName'] = fullName;
          currentMap['email'] = email;
          currentMap['bio'] = bio;
          currentMap['phoneNumber'] = phoneNumber;
          currentMap['githubUrl'] = githubUrl;
          await _apiClient.storage.write(key: 'user_data', value: jsonEncode(currentMap));
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('UPDATE PROFILE ERROR: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    String? token = await _apiClient.storage.read(key: 'jwt_token');
    if (token == null) return false;
    
    try {
      // Kiểm tra token có hợp lệ không bằng cách gọi API /progress/me
      final response = await _apiClient.dio.get('/progress/me');
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        // Chỉ xóa token nếu máy chủ trả về mã lỗi 401 hoặc 403 (Token thực sự không hợp lệ / Hết hạn)
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          await _apiClient.storage.deleteAll();
          return false;
        }
        // Nếu là lỗi mạng khác (Mất mạng, Timeout, Server 500 tạm thời...), giữ lại Token để dùng offline
        return true;
      }
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _apiClient.storage.read(key: 'jwt_token');
  }
}
