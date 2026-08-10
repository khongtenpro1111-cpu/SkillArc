import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/main.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/services/skill_service.dart';
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

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _forecastKey = GlobalKey();
  final GlobalKey _remindersKey = GlobalKey();
  final GlobalKey _roadmapKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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

  Widget _buildQuickLinks() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      {'label': 'Thống kê', 'icon': Icons.analytics_outlined, 'key': _statsKey, 'color': const Color(0xFF00D2FF)},
      {'label': 'Dự báo', 'icon': Icons.auto_graph_rounded, 'key': _forecastKey, 'color': Colors.purpleAccent},
      {'label': 'Nhắc nhở', 'icon': Icons.alarm_on_rounded, 'key': _remindersKey, 'color': Colors.orangeAccent},
      {'label': 'Lộ trình', 'icon': Icons.auto_awesome, 'key': _roadmapKey, 'color': Colors.greenAccent},
      {'label': 'Kỹ năng', 'icon': Icons.psychology_outlined, 'key': _skillsKey, 'color': Colors.pinkAccent},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _scrollToSection(item['key'] as GlobalKey),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)));
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 110, 20, 130),
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
                      AppStrings.of(context, 'welcomeBack'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), 
                        fontSize: 14
                      ),
                    ),
                    Text(
                      user?.fullName ?? user?.username ?? AppStrings.of(context, 'defaultUsername'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
        const SizedBox(height: 20),
        _buildQuickLinks(),
        const SizedBox(height: 30),
        
        Container(
          key: _statsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context, 'journeyOverview'),
                style: const TextStyle(
                  letterSpacing: 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              _buildQuickStats(),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          key: _forecastKey,
          child: _buildProjectionCard(),
        ),
        const SizedBox(height: 25),
        Container(
          key: _remindersKey,
          child: _buildRemindersSection(),
        ),
        const SizedBox(height: 25),
        Container(
          key: _roadmapKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context, 'continueLearning'),
                style: TextStyle(
                  letterSpacing: 2,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              _buildCurrentRoadmapCard(),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          key: _skillsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context, 'activeSkills'),
                style: TextStyle(
                  letterSpacing: 2,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              _buildInProgressSkills(),
            ],
          ),
        ),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark 
                  ? Colors.purpleAccent.withValues(alpha: 0.3) 
                  : Colors.purpleAccent.withValues(alpha: 0.1)
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withValues(alpha: 0.3) 
                    : Colors.purpleAccent.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                  Text(
                    AppStrings.of(context, 'forecastTitle'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2, 
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProjectionItem(
                    AppStrings.of(context, 'daysToFinish'),
                    '${finishDate.day}/${finishDate.month}/${finishDate.year}',
                    Icons.calendar_today_rounded
                  ),
                  _buildProjectionItem(
                    AppStrings.of(context, 'skillsRemaining'),
                    '$daysToFinish ${AppStrings.of(context, 'daysUnit')}',
                    Icons.timer_outlined
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.of(context, 'forecastDesc', placeholders: {'hours': '$dailyHours', 'skills': '$remaining'}),
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black54),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? Colors.white54 : Colors.black54),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).colorScheme.onSurface
          )
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    if (_reminders.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myHomePageState = context.findAncestorStateOfType<MyHomePageState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.of(context, 'todayReminder'),
          style: const TextStyle(
            letterSpacing: 2,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 15),
        ..._reminders.map((reminder) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                myHomePageState?.setSelectedIndex(1);
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: reminder['isUrgent'] == true 
                      ? const Color(0xFFFF4D4D).withValues(alpha: 0.1) 
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: reminder['isUrgent'] == true 
                        ? const Color(0xFFFF4D4D).withValues(alpha: 0.3) 
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        reminder['title'] is String
                            ? AppStrings.of(context, reminder['title'] as String)
                            : '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                    ),
                    Text(
                      reminder['time'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildInProgressSkills() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myHomePageState = context.findAncestorStateOfType<MyHomePageState>();

    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        final activeSkills = provider.inProgressSkills;
        if (activeSkills.isEmpty) {
          return Center(
            child: Text(AppStrings.of(context, 'completedAll'), 
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38, 
                fontStyle: FontStyle.italic
              )),
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
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    myHomePageState?.setSelectedIndex(1);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF00D2FF).withValues(alpha: isDark ? 0.1 : 0.2)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology_outlined, color: Color(0xFF00D2FF), size: 30),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.of(context, skill.title),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                        ),
                      ],
                    ),
                  ),
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
        final myHomePageState = context.findAncestorStateOfType<MyHomePageState>();
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                AppStrings.of(context, 'skillsLearned'), 
                '${provider.completedSkillsCount}', 
                Icons.check_circle_outline, 
                const Color(0xFF00D2FF),
                onTap: () {
                  myHomePageState?.setSelectedIndex(1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                AppStrings.of(context, 'skillsRemaining'), 
                '${provider.remainingSkillsCount}', 
                Icons.pending_outlined, 
                Colors.orangeAccent,
                onTap: () {
                  myHomePageState?.setSelectedIndex(1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                AppStrings.of(context, 'ratio'), 
                '${(provider.overallProgress * 100).toInt()}%', 
                Icons.analytics_outlined, 
                Colors.purpleAccent,
                onTap: () {
                  myHomePageState?.setSelectedIndex(1);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color!.withValues(alpha: isDark ? 0.7 : 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.05 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface
                )
              ),
              Text(
                label, 
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54, 
                  fontSize: 11, 
                  letterSpacing: 0.5
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentRoadmapCard() {
    final myHomePageState = context.findAncestorStateOfType<MyHomePageState>();
    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        final progress = provider.overallProgress;
        final percentage = (progress * 100).toInt();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              myHomePageState?.setSelectedIndex(1);
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: isDark ? 0.15 : 0.1), 
                    isDark ? Colors.transparent : Colors.white
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withValues(alpha: 0.05),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.of(context, 'Lộ trình Phát triển SkillArc & Hệ thống'), 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.auto_awesome, color: Color(0xFF00D2FF)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                    color: const Color(0xFF00D2FF),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.of(context, 'progressPrefix', placeholders: {'percentage': '$percentage', 'status': percentage == 100 ? AppStrings.of(context, 'Hoàn thành xuất sắc!') : AppStrings.of(context, 'Tiếp tục cố gắng')}),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), 
                      fontSize: 13
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
