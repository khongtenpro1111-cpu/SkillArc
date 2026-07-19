import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/services/skill_service.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/providers/skill_provider.dart';
import 'package:skill_arc/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final SkillService _skillService = SkillService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final reminders = await _skillService.fetchReminders(user.username);
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Câu chào cá nhân hóa
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;
            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào mừng trở lại,',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                    ),
                    Text(
                      user?.fullName ?? user?.username ?? 'Học viên',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                  backgroundImage: (user?.avatarPath != null && File(user!.avatarPath!).existsSync())
                      ? FileImage(File(user.avatarPath!))
                      : null,
                  child: (user?.avatarPath == null || !File(user!.avatarPath!).existsSync())
                      ? const Icon(Icons.person, color: Color(0xFF00D2FF))
                      : null,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        
        const Text(
          'TỔNG QUAN HÀNH TRÌNH',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildQuickStats(),
        const SizedBox(height: 25),
        _buildProjectionCard(),
        const SizedBox(height: 25),
        _buildRemindersSection(),
        const SizedBox(height: 25),
        const Text(
          'TIẾP TỤC HỌC',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildCurrentRoadmapCard(),
        const SizedBox(height: 25),
        const Text(
          'KỸ NĂNG ĐANG CHINH PHỤC',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildInProgressSkills(),
      ],
    );
  }

  Widget _buildProjectionCard() {
    return Consumer2<SkillProvider, UserProvider>(
      builder: (context, skillProvider, userProvider, child) {
        final remaining = skillProvider.remainingSkillsCount;
        if (remaining == 0) return const SizedBox.shrink();

        // Giả định: Mỗi kỹ năng cần trung bình 10 giờ học tập trung
        const hoursPerSkill = 10;
        final totalHoursNeeded = remaining * hoursPerSkill;
        final dailyHours = userProvider.targetHoursPerDay > 0 ? userProvider.targetHoursPerDay : 2;
        
        final daysToFinish = (totalHoursNeeded / dailyHours).ceil();
        final finishDate = DateTime.now().add(Duration(days: daysToFinish));
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_graph_rounded, color: Colors.purpleAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DỰ BÁO LỘ TRÌNH AI',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProjectionItem(
                    'Ngày về đích',
                    '${finishDate.day}/${finishDate.month}/${finishDate.year}',
                    Icons.calendar_today_rounded
                  ),
                  _buildProjectionItem(
                    'Còn lại',
                    '$daysToFinish ngày',
                    Icons.timer_outlined
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.white38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dựa trên mục tiêu ${dailyHours}h/ngày và $remaining kỹ năng còn lại.',
                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectionItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildRemindersSection() {
    if (_reminders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NHẮC NHỞ HÔM NAY',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._reminders.map((reminder) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: reminder['isUrgent'] == true 
                ? const Color(0xFFFF4D4D).withValues(alpha: 0.1) 
                : const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: reminder['isUrgent'] == true 
                  ? const Color(0xFFFF4D4D).withValues(alpha: 0.3) 
                  : Colors.white.withValues(alpha: 0.05)
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.alarm_on_rounded, 
                color: reminder['isUrgent'] == true ? Colors.redAccent : const Color(0xFF00D2FF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                reminder['time'],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInProgressSkills() {
    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        final activeSkills = provider.inProgressSkills;
        if (activeSkills.isEmpty) {
          return const Center(
            child: Text('Bạn đã hoàn thành mọi mục tiêu hiện tại!', 
              style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic)),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: activeSkills.length,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final skill = activeSkills[index];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology_outlined, color: Color(0xFF00D2FF), size: 30),
                    const SizedBox(height: 10),
                    Text(
                      skill.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Đã học', 
                '${provider.completedSkillsCount}', 
                Icons.check_circle_outline, 
                const Color(0xFF00D2FF)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Còn lại', 
                '${provider.remainingSkillsCount}', 
                Icons.pending_outlined, 
                Colors.orangeAccent
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Tỷ lệ', 
                '${(provider.overallProgress * 100).toInt()}%', 
                Icons.analytics_outlined, 
                Colors.purpleAccent
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCurrentRoadmapCard() {
    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        final progress = provider.overallProgress;
        final percentage = (progress * 100).toInt();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF00D2FF).withValues(alpha: 0.1), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lộ trình Backend Architect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Icon(Icons.auto_awesome, color: Color(0xFF00D2FF)),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                color: const Color(0xFF00D2FF),
                minHeight: 8,
              ),
              const SizedBox(height: 10),
              Text(
                'Tiến độ: $percentage% - ${percentage == 100 ? "Hoàn thành xuất sắc!" : "Tiếp tục cố gắng"}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
