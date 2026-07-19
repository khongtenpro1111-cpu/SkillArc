import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/services/local_db_service.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Đăng nhập (Hỗ trợ cả username hoặc email, không phân biệt hoa thường)
  Future<bool> login(String inputUsername, String inputPassword) async {
    final localUser = LocalDbService.getUser();
    
    if (localUser != null) {
      final storedUser = localUser['username'].toString().trim().toLowerCase();
      final storedEmail = localUser['email'].toString().trim().toLowerCase();
      final storedPass = localUser['password'].toString().trim();
      
      final typedUser = inputUsername.trim().toLowerCase();
      final typedPass = inputPassword.trim();

      print('DEBUG: So sánh: [$typedUser] vs [$storedUser] hoặc [$storedEmail]');

      if ((typedUser == storedUser || typedUser == storedEmail) && typedPass == storedPass) {
        await _storage.write(key: 'jwt_token', value: 'local_token_success');
        return true;
      }
    }
    return false;
  }

  // Đăng ký (Lưu vào Local Database)
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Truyền tham số theo tên (Named Parameters) để khớp với định nghĩa trong LocalDbService
      await LocalDbService.saveUser(
        username: username.trim(),
        email: email.trim(),
        password: password.trim(),
        fullName: fullName?.trim(),
      );
      
      // Đăng ký xong thì coi như đã có Token
      await _storage.write(key: 'jwt_token', value: 'local_token_success');
      return true;
    } catch (e) {
      print('DEBUG ERROR: $e');
      throw 'Lỗi đăng ký: $e';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<User?> getCurrentUser() async {
    final userMap = LocalDbService.getUser();
    if (userMap != null) {
      return User(
        id: 1,
        username: userMap['username'],
        email: userMap['email'],
        fullName: userMap['fullName'],
        avatarPath: userMap['avatarPath'],
      );
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
