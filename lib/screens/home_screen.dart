import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Cấp độ', '12', Icons.workspace_premium_rounded, Colors.amber),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatItem('Streak', '5 Ngày', Icons.local_fire_department_rounded, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00D2FF).withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fullstack .NET Developer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.trending_up, color: Color(0xFF00D2FF)),
            ],
          ),
          const SizedBox(height: 15),
          const LinearProgressIndicator(
            value: 0.4,
            backgroundColor: Colors.white10,
            color: Color(0xFF00D2FF),
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text(
            'Tiến độ: 40% - Còn 5 kỹ năng',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
