import 'package:flutter/material.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'THỬ THÁCH HÀNG NGÀY',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildChallengeCard(
          'Code Warrior',
          'Hoàn thành 3 bài tập C# nâng cao',
          '300 XP',
          0.6,
          Colors.orange,
        ),
        const SizedBox(height: 15),
        _buildChallengeCard(
          'Bug Hunter',
          'Tìm và sửa 5 lỗi logic trong project mẫu',
          '500 XP',
          0.2,
          Colors.redAccent,
        ),
        const SizedBox(height: 25),
        const Text(
          'SỰ KIỆN ĐẶC BIỆT',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildEventCard(),
      ],
    );
  }

  Widget _buildChallengeCard(String title, String desc, String reward, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(reward, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7000FF), Color(0xFF00D2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.emoji_events_rounded, size: 120, color: Colors.white.withValues(alpha: 0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HACKATHON CUỐI TUẦN',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Xây dựng App Portfolio trong 48h',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('THAM GIA NGAY'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
