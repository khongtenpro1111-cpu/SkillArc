import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 1. Model dữ liệu SkillNode
class SkillNode {
  final String id;
  final String title;
  bool isCompleted;

  SkillNode({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  /// 2. Quản lý trạng thái: Danh sách các kỹ năng
  final List<SkillNode> _skillList = [
    SkillNode(id: '1', title: 'Backend Architect'),
    SkillNode(id: '2', title: 'ASP.NET Core / C#'),
    SkillNode(id: '3', title: 'SQL & Database Design'),
    SkillNode(id: '4', title: 'Docker & Kubernetes'),
    SkillNode(id: '5', title: 'System Security'),
    SkillNode(id: '6', title: 'Cloud Deployment'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSkillData();
  }

  /// Tải trạng thái từ bộ nhớ điện thoại (SharedPreferences)
  Future<void> _loadSkillData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var skill in _skillList) {
        // Lấy giá trị bool đã lưu theo ID, mặc định là false nếu chưa có
        skill.isCompleted = prefs.getBool('skill_status_${skill.id}') ?? false;
      }
    });
  }

  /// Hàm đảo ngược trạng thái hoàn thành và lưu vào bộ nhớ
  Future<void> _toggleSkillStatus(int index) async {
    final skill = _skillList[index];
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      skill.isCompleted = !skill.isCompleted;
      // Lưu giá trị mới vào SharedPreferences
      prefs.setBool('skill_status_${skill.id}', skill.isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Dark Mode chuyên nghiệp
      appBar: AppBar(
        title: const Text(
          'LỘ TRÌNH KỸ NĂNG',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      /// 3. Logic ListView: Hiển thị danh sách kỹ năng
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _skillList.length,
        itemBuilder: (context, index) {
          final skill = _skillList[index];
          return SkillItemWidget(
            node: skill,
            onToggle: () => _toggleSkillStatus(index),
            onTap: () {
              /// 4. Điều hướng sang trang chi tiết giả lập
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkillDetailScreen(skill: skill),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget hiển thị từng khối kỹ năng
class SkillItemWidget extends StatelessWidget {
  final SkillNode node;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const SkillItemWidget({
    super.key,
    required this.node,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Hiệu ứng thay đổi màu sắc viền dựa trên isCompleted
    final Color borderColor = node.isCompleted 
        ? const Color(0xFF00FF94)  // Màu xanh lá
        : const Color(0xFF81D4FA); // Màu xanh dương nhạt

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap, // Điều hướng sang trang chi tiết khi nhấn vào khối
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: borderColor.withOpacity(node.isCompleted ? 0.8 : 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icon hiển thị trạng thái bên trái
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  node.isCompleted
                      ? Icons.check_circle_rounded 
                      : Icons.radio_button_off_rounded,
                  color: borderColor,
                  size: 28,
                ),
              ),
              // Tên kỹ năng hiển thị ở chính giữa
              Expanded(
                child: Text(
                  node.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Khoảng trống giả lập để text nằm chính giữa tuyệt đối
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trang chi tiết giả lập (Skill Detail Screen)
class SkillDetailScreen extends StatelessWidget {
  final SkillNode skill;
  const SkillDetailScreen({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(skill.title),
        backgroundColor: const Color(0xFF161B22),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              skill.isCompleted ? Icons.verified_rounded : Icons.menu_book_rounded,
              size: 100,
              color: skill.isCompleted ? const Color(0xFF00FF94) : const Color(0xFF81D4FA),
            ),
            const SizedBox(height: 24),
            Text(
              'CHI TIẾT: ${skill.title}',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Trạng thái: ${skill.isCompleted ? "Đã hoàn thành" : "Đang tiến hành"}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại lộ trình'),
            ),
          ],
        ),
      ),
    );
  }
}
