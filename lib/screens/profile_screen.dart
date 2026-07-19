import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/providers/user_provider.dart';
import 'package:skill_arc/providers/skill_provider.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/screens/login_screen.dart';
import 'package:skill_arc/screens/edit_profile_screen.dart';
import 'package:skill_arc/screens/goal_settings_screen.dart';
import 'package:skill_arc/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(UserProvider userProvider) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      await userProvider.updateAvatar(image.path);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, SkillProvider>(
      builder: (context, userProvider, skillProvider, child) {
        final user = userProvider.currentUser;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF00D2FF),
                        backgroundImage: (user?.avatarPath != null && File(user!.avatarPath!).existsSync())
                            ? FileImage(File(user.avatarPath!))
                            : null,
                        child: (user?.avatarPath == null || !File(user!.avatarPath!).existsSync())
                            ? const Icon(Icons.person, size: 50, color: Colors.black)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _pickImage(userProvider),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00D2FF), width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF00D2FF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.fullName ?? user?.username ?? 'Chưa đặt tên',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'Chưa có email',
                    style: const TextStyle(color: Color(0xFF00D2FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'TIẾN ĐỘ HỌC TẬP',
              style: TextStyle(letterSpacing: 2, color: Colors.white54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              'Kỹ năng đã học', 
              '${skillProvider.completedSkillsCount} / ${skillProvider.skills.length}', 
              skillProvider.overallProgress
            ),
            const SizedBox(height: 10),
            _buildStatCard(
              'Thời gian học', 
              '${userProvider.studyHours} Giờ', 
              userProvider.studyProgress
            ),
            
            const SizedBox(height: 30),
            const Text(
              'CÀI ĐẶT TÀI KHOẢN',
              style: TextStyle(letterSpacing: 2, color: Colors.white54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              'Thông tin cá nhân', 
              Icons.person_outline_rounded,
              onTap: () async {
                if (user != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                  );
                  if (result == true) userProvider.loadUser();
                }
              },
            ),
            _buildSettingTile(
              'Mục tiêu hàng ngày', 
              Icons.flag_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalSettingsScreen()),
                );
              },
            ),
            _buildSettingTile(
              'Thông báo kiểm tra', 
              Icons.notifications_none_rounded, 
              onTap: () async {
                await NotificationService().requestPermissions();
                await NotificationService().showInstantNotification(
                  id: 1,
                  title: 'SkillArc Test',
                  body: 'Thông báo tức thời hoạt động!',
                );
              },
            ),
            
            const Divider(color: Colors.white10, height: 40),
            ListTile(
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onTap: _handleLogout,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, double percent) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(value, style: const TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: percent, backgroundColor: Colors.white10, color: const Color(0xFF00D2FF), minHeight: 4),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white54),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }
}

