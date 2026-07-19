import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'C# & .NET', 'icon': Icons.code_rounded, 'color': const Color(0xFF7000FF)},
      {'name': 'Web Dev', 'icon': Icons.language_rounded, 'color': const Color(0xFF00D2FF)},
      {'name': 'Database', 'icon': Icons.storage_rounded, 'color': const Color(0xFF00FF94)},
      {'name': 'DevOps', 'icon': Icons.cloud_queue_rounded, 'color': const Color(0xFFFFB800)},
      {'name': 'Mobile Dev', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFFFF00D2)},
      {'name': 'UI/UX Design', 'icon': Icons.palette_outlined, 'color': const Color(0xFF0066FF)},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm kỹ năng...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00D2FF)),
              filled: true,
              fillColor: const Color(0xFF161B22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (data['color'] as Color).withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data['icon'], color: data['color'], size: 40),
          const SizedBox(height: 12),
          Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
