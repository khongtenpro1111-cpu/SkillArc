import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/providers/skill_provider.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';
import 'package:skill_arc/utils/app_toast.dart';

class SkillTreeScreen extends StatelessWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SkillProvider, bool>((p) => p.isLoading);
    final skills = context.select<SkillProvider, List<SkillNode>>((p) => p.skills);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (skills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Kiểm tra kết nối Backend hoặc đăng nhập lại',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<SkillProvider>().refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Selector<SkillProvider, List<SkillNode>>(
      selector: (_, provider) => provider.skills,
      builder: (context, skills, child) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 130),
          itemCount: skills.length,
          itemBuilder: (context, index) {
              final String skillId = skills[index].id;
              return Selector<SkillProvider, _SkillItemData>(
                selector: (_, provider) => _SkillItemData(
                  skill: provider.skillMap[skillId]!,
                  isLocked: provider.isSkillLocked(skillId),
                  lockReason: provider.getLockReason(skillId),
                  depth: provider.getNodeDepth(skillId),
                  isLastChild: provider.isLastChild(skillId),
                ),
                builder: (context, data, _) {
                  return SkillItemWidget(
                    node: data.skill,
                    isLocked: data.isLocked,
                    lockReason: data.lockReason,
                    depth: data.depth,
                    isLastChild: data.isLastChild,
                    onToggle: () async {
                      try {
                        await context.read<SkillProvider>().toggleSkillStatus(skillId);
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.show(context, AppStrings.of(context, e.toString()));
                        }
                      }
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkillDetailScreen(skill: data.skill, isLocked: data.isLocked),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
      },
    );
  }
}

// Helper class để tối ưu hóa Selector
class _SkillItemData {
  final SkillNode skill;
  final bool isLocked;
  final String? lockReason;
  final int depth;
  final bool isLastChild;
  
  _SkillItemData({
    required this.skill,
    required this.isLocked,
    this.lockReason,
    required this.depth,
    required this.isLastChild,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SkillItemData &&
          runtimeType == other.runtimeType &&
          skill.id == other.skill.id &&
          skill.isCompleted == other.skill.isCompleted &&
          isLocked == other.isLocked &&
          lockReason == other.lockReason &&
          depth == other.depth &&
          isLastChild == other.isLastChild;

  @override
  int get hashCode => Object.hash(skill.id, skill.isCompleted, isLocked, lockReason, depth, isLastChild);
}

class TreeConnectionPainter extends CustomPainter {
  final int depth;
  final bool isLastChild;
  final bool isCompleted;
  final bool isDark;

  TreeConnectionPainter({
    required this.depth,
    required this.isLastChild,
    required this.isCompleted,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted
          ? (isDark ? AppDesignTokens.colorCompletedDark.withValues(alpha: 0.5) : AppDesignTokens.colorCompletedLight.withValues(alpha: 0.4))
          : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Vẽ các đường thẳng đứng cho các nhánh trước đó (nếu có)
    for (int i = 0; i < depth - 1; i++) {
      double x = i * 32.0 + 16.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Vẽ nhánh kết nối cho nút hiện tại
    double currentX = (depth - 1) * 32.0 + 16.0;
    double nextX = depth * 32.0;
    double centerY = size.height / 2;

    // Đường thẳng đứng đi xuống từ trên
    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, isLastChild ? centerY : size.height),
      paint,
    );

    // Đường ngang rẽ nhánh vào nút hình tròn
    canvas.drawLine(
      Offset(currentX, centerY),
      Offset(nextX, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant TreeConnectionPainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.isLastChild != isLastChild ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isDark != isDark;
  }
}

class SkillItemWidget extends StatelessWidget {
  final SkillNode node;
  final bool isLocked;
  final String? lockReason;
  final int depth;
  final bool isLastChild;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const SkillItemWidget({
    super.key,
    required this.node,
    required this.isLocked,
    this.lockReason,
    required this.depth,
    required this.isLastChild,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Màu sắc chủ đạo tương ứng với trạng thái
    final Color activeColor = node.isCompleted 
        ? (isDark ? AppDesignTokens.colorCompletedDark : AppDesignTokens.colorCompletedLight) 
        : (isDark ? AppDesignTokens.colorPrimary : AppDesignTokens.colorActiveLight);

    final double nodeSize = depth == 0 ? 56.0 : 40.0;

    // Thiết kế nút tròn (Node/Circle)
    Widget circleNode = Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked
            ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
            : (node.isCompleted 
                ? activeColor.withValues(alpha: 0.2) 
                : activeColor.withValues(alpha: 0.1)),
        border: Border.all(
          color: isLocked
              ? (isDark ? Colors.white24 : Colors.black26)
              : activeColor,
          width: depth == 0 ? 3.0 : 2.5,
        ),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: activeColor.withValues(alpha: isDark ? 0.4 : 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ],
      ),
      child: Center(
        child: Icon(
          isLocked
              ? Icons.lock_outline_rounded
              : (node.isCompleted ? Icons.check_rounded : (depth == 0 ? Icons.star_rounded : Icons.menu_book_rounded)),
          color: isLocked
              ? (isDark ? Colors.white24 : Colors.black26)
              : activeColor,
          size: depth == 0 ? 26.0 : 20.0,
        ),
      ),
    );

    // Bọc InkWell để khi click vào Node tròn sẽ thực hiện Toggle hoặc Click
    Widget nodeInteractive = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onToggle,
        customBorder: const CircleBorder(),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: circleNode,
        ),
      ),
    );

    // Nội dung text mô tả kỹ năng
    Widget nodeDetails = Expanded(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: activeColor.withValues(alpha: 0.05),
        highlightColor: activeColor.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.of(context, node.title),
                style: TextStyle(
                  color: isLocked 
                      ? (isDark ? Colors.white38 : Colors.black38) 
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: depth == 0 ? 18 : 15,
                  fontWeight: FontWeight.bold,
                  decoration: node.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: activeColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLocked 
                    ? (lockReason != null 
                        ? AppStrings.of(context, 'prerequisiteRequired', placeholders: {'skill': AppStrings.of(context, lockReason!)})
                        : AppStrings.of(context, 'skillsLocked'))
                    : (node.isCompleted ? AppStrings.of(context, 'skillsMastered') : AppStrings.of(context, 'skillsTapDetail')),
                style: TextStyle(
                  color: isLocked 
                      ? Colors.redAccent.withValues(alpha: 0.8) 
                      : (node.isCompleted 
                          ? (isDark ? AppDesignTokens.colorCompletedDark : AppDesignTokens.colorCompletedLight)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (depth > 0)
              CustomPaint(
                size: Size(depth * 32.0, 0),
                painter: TreeConnectionPainter(
                  depth: depth,
                  isLastChild: isLastChild,
                  isCompleted: node.isCompleted,
                  isDark: isDark,
                ),
              ),
            nodeInteractive,
            nodeDetails,
          ],
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
    final skillId = skill.id;
    return Selector<SkillProvider, _SkillItemData>(
      selector: (_, provider) => _SkillItemData(
        skill: provider.skillMap[skillId]!,
        isLocked: provider.isSkillLocked(skillId),
        lockReason: provider.getLockReason(skillId),
        depth: provider.getNodeDepth(skillId),
        isLastChild: provider.isLastChild(skillId),
      ),
      builder: (context, data, child) {
        final currentSkill = data.skill;
        final currentIsLocked = data.isLocked;
        final lockReason = data.lockReason;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              AppStrings.of(context, 'skillDetailTitle'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
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
                    color: currentSkill.isCompleted ? AppDesignTokens.colorCompletedDark : AppDesignTokens.colorPrimary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.of(context, currentSkill.title),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentIsLocked 
                      ? (lockReason != null 
                          ? AppStrings.of(context, 'prerequisiteRequired', placeholders: {'skill': AppStrings.of(context, lockReason)})
                          : AppStrings.of(context, 'skillsLocked')) 
                      : (currentSkill.isCompleted ? AppStrings.of(context, 'skillsMastered') : AppStrings.of(context, 'skillsStart')),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentIsLocked ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), 
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!currentIsLocked)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await context.read<SkillProvider>().toggleSkillStatus(currentSkill.id);
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.show(context, AppStrings.of(context, e.toString()));
                          }
                        }
                      },
                      icon: Icon(currentSkill.isCompleted ? Icons.undo : Icons.check_circle),
                      label: Text(
                        currentSkill.isCompleted ? AppStrings.of(context, 'markUncompleted') : AppStrings.of(context, 'markCompleted'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentSkill.isCompleted 
                            ? (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)) 
                            : AppDesignTokens.colorCompletedDark,
                        foregroundColor: currentSkill.isCompleted 
                            ? Theme.of(context).colorScheme.onSurface 
                            : Colors.black,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: currentSkill.isCompleted ? 0 : 10,
                        shadowColor: AppDesignTokens.colorCompletedDark.withValues(alpha: 0.5),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.of(context, 'back'), 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))
                    ),
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
