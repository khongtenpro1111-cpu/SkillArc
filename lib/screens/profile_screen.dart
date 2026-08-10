import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/main.dart';
import 'package:skill_arc/providers/user_provider.dart';
import 'package:skill_arc/providers/skill_provider.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/screens/login_screen.dart';
import 'package:skill_arc/screens/edit_profile_screen.dart';
import 'package:skill_arc/screens/goal_settings_screen.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer2<UserProvider, SkillProvider>(
      builder: (context, userProvider, skillProvider, child) {
        final user = userProvider.currentUser;

        final sectionTitleStyle = TextStyle(
          letterSpacing: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 145, 20, 130),
          children: [
            // Premium Member Card with rich gradient
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (user != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                    );
                    if (result == true) userProvider.loadUser();
                  }
                },
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppDesignTokens.colorProfileGradientDark1, AppDesignTokens.colorProfileGradientDark2]
                          : [theme.colorScheme.primary, AppDesignTokens.colorProfileGradientLightEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              backgroundImage: (user?.avatarPath != null && File(user!.avatarPath!).existsSync())
                                  ? FileImage(File(user.avatarPath!))
                                  : null,
                              child: (user?.avatarPath == null || !File(user!.avatarPath!).existsSync())
                                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? user?.username ?? AppStrings.of(context, 'notSetName'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    user?.email ?? AppStrings.of(context, 'notSetEmail'),
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ONLINE',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'PRO MEMBER',
                              style: TextStyle(
                                color: Colors.amber[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            
            Text(AppStrings.of(context, 'studyProgress'), style: sectionTitleStyle),
            const SizedBox(height: 15),
            _buildStatCard(
              AppStrings.of(context, 'learnedSkills'), 
              '${skillProvider.completedSkillsCount} / ${skillProvider.skills.length}', 
              skillProvider.overallProgress,
              isDark,
              theme,
              onTap: () {
                context.findAncestorStateOfType<MyHomePageState>()?.setSelectedIndex(1);
              },
            ),
             const SizedBox(height: 12),
             _buildStatCard(
               AppStrings.of(context, 'studyHours'), 
               '${userProvider.studyHours} ${AppStrings.of(context, 'hoursUnit')}', 
               userProvider.studyProgress,
               isDark,
               theme,
               onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const GoalSettingsScreen()),
                 );
               },
             ),
             
             const SizedBox(height: 35),
             Text(AppStrings.of(context, 'accountSettings'), style: sectionTitleStyle),
            const SizedBox(height: 10),
            _buildSettingTile(
              AppStrings.of(context, 'personalInfo'), 
              Icons.person_outline_rounded,
              theme,
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
              AppStrings.of(context, 'dailyGoal'), 
              Icons.flag_outlined,
              theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalSettingsScreen()),
                );
              },
            ),
            
            Divider(color: theme.dividerColor.withValues(alpha: 0.5), height: 50),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(AppStrings.of(context, 'logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: _handleLogout,
            ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                AppStrings.of(context, 'appVersion'),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, double percent, bool isDark, ThemeData theme, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  Text(value, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percent, 
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), 
                  color: theme.colorScheme.primary, 
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, ThemeData theme, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: theme.colorScheme.onSurface, 
          fontWeight: FontWeight.w500,
        )
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
      onTap: onTap,
    );
  }
}
