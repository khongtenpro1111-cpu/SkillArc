import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF00D2FF),
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              SizedBox(height: 15),
              Text(
                'Nguyễn Văn A',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Học viên Ưu tú',
                style: TextStyle(color: Color(0xFF00D2FF)),
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
        _buildStatCard('Kỹ năng đã học', '12 / 45', 0.26),
        const SizedBox(height: 10),
        _buildStatCard('Thời gian học', '120 Giờ', 0.8),
        
        const SizedBox(height: 30),
        const Text(
          'CÀI ĐẶT TÀI KHOẢN',
          style: TextStyle(letterSpacing: 2, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildSettingTile('Thông tin cá nhân', Icons.person_outline_rounded),
        _buildSettingTile('Mục tiêu hàng ngày', Icons.flag_outlined),
        _buildSettingTile('Thông báo', Icons.notifications_none_rounded),
        _buildSettingTile('Ngôn ngữ', Icons.translate_rounded),
        
        const Divider(color: Colors.white10, height: 40),
        ListTile(
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onTap: () {},
        ),
      ],
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

  Widget _buildSettingTile(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white54),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: () {},
    );
  }
}
