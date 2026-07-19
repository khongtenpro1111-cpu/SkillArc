import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/providers/skill_provider.dart';

class SkillTreeScreen extends StatelessWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'LỘ TRÌNH KỸ NĂNG',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: provider.skills.length,
            itemBuilder: (context, index) {
              final skill = provider.skills[index];
              final isLocked = provider.isSkillLocked(skill.id);
              final lockReason = provider.getLockReason(skill.id);
              
              return SkillItemWidget(
                node: skill,
                isLocked: isLocked,
                lockReason: lockReason,
                onToggle: () async {
                  try {
                    await provider.toggleSkillStatus(skill.id);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SkillDetailScreen(skill: skill, isLocked: isLocked),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SkillItemWidget extends StatelessWidget {
  final SkillNode node;
  final bool isLocked;
  final String? lockReason;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const SkillItemWidget({
    super.key,
    required this.node,
    required this.isLocked,
    this.lockReason,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = node.isCompleted 
        ? const Color(0xFF00FF94) 
        : const Color(0xFF00D2FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: node.isCompleted 
                    ? activeColor.withValues(alpha: 0.8) 
                    : Colors.white.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: isLocked ? null : onToggle,
                  icon: Icon(
                    isLocked 
                        ? Icons.lock_outline_rounded
                        : (node.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_off_rounded),
                    color: isLocked ? Colors.white24 : activeColor,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: TextStyle(
                          color: isLocked ? Colors.white38 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: node.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isLocked)
                        Text(
                          lockReason ?? 'Yêu cầu hoàn thành kỹ năng trước',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SkillDetailScreen extends StatelessWidget {
  final SkillNode skill;
  final bool isLocked;
  const SkillDetailScreen({super.key, required this.skill, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        final currentSkill = provider.skills.firstWhere((s) => s.id == skill.id);
        final currentIsLocked = provider.isSkillLocked(currentSkill.id);
        final lockReason = provider.getLockReason(currentSkill.id);

        return Scaffold(
          backgroundColor: const Color(0xFF010409),
          appBar: AppBar(
            title: Text(currentSkill.title),
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentIsLocked ? Icons.lock : (currentSkill.isCompleted ? Icons.verified_rounded : Icons.menu_book_rounded),
                    size: 100,
                    color: currentSkill.isCompleted ? const Color(0xFF00FF94) : const Color(0xFF00D2FF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    currentSkill.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentIsLocked 
                      ? (lockReason ?? "Nội dung này đang bị khóa.") 
                      : (currentSkill.isCompleted ? "Bạn đã làm chủ kỹ năng này!" : "Hãy bắt đầu học kỹ năng này ngay."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentIsLocked ? Colors.redAccent : Colors.white70, 
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!currentIsLocked)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await provider.toggleSkillStatus(currentSkill.id);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      icon: Icon(currentSkill.isCompleted ? Icons.undo : Icons.check_circle),
                      label: Text(
                        currentSkill.isCompleted ? 'HỦY HOÀN THÀNH' : 'ĐÁNH DẤU HOÀN THÀNH',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentSkill.isCompleted ? Colors.white12 : const Color(0xFF00FF94),
                        foregroundColor: currentSkill.isCompleted ? Colors.white : Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('QUAY LẠI', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

