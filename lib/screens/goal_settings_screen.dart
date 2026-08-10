import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skill_arc/services/local_db_service.dart';
import 'package:skill_arc/services/notification_service.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  int _hoursPerDay = 2;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoal();
  }

  Future<void> _loadCurrentGoal() async {
    final goal = LocalDbService.getGoal();
    if (goal != null) {
      setState(() {
        _hoursPerDay = goal['hoursPerDay'] ?? 2;
        _reminderTime = TimeOfDay(
          hour: goal['reminderHour'] ?? 7,
          minute: goal['reminderMinute'] ?? 0,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppDesignTokens.colorPrimary,
              onPrimary: Colors.black,
              surface: AppDesignTokens.msgBotBgDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D1117) : Colors.white),
        title: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 50),
            SizedBox(height: 10),
            Text(
              'Lưu thành công',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Đóng hộp thoại
              Navigator.of(context).pop(true); // Đóng màn hình mục tiêu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Đồng ý', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D1117) : Colors.white),
        title: const Column(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 50),
            SizedBox(height: 10),
            Text(
              'Lưu thất bại',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng hộp thoại
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGoal() async {
    setState(() => _isSaving = true);
    try {
      final goal = {
        'hoursPerDay': _hoursPerDay,
        'reminderHour': _reminderTime.hour,
        'reminderMinute': _reminderTime.minute,
      };
      
      await LocalDbService.saveGoal(goal);

      if (!mounted) return;

      // Lập lịch thông báo
      await NotificationService().scheduleDailyNotification(
        id: 100,
        title: AppStrings.of(context, 'notifTitle'),
        body: AppStrings.of(context, 'notifBody', placeholders: {'hours': '$_hoursPerDay'}),
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );

      if (mounted) {
        _showSuccessDialog(context, AppStrings.of(context, 'saveGoalSuccess'));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, '${AppStrings.of(context, 'errorPrefix')} $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppDesignTokens.colorPrimary : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'goalTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.of(context, 'goalDesc'),
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle(AppStrings.of(context, 'hoursPerDay'), theme),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_hoursPerDay ${AppStrings.of(context, 'hoursUnit').toLowerCase()}', 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        )
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _hoursPerDay = (_hoursPerDay > 1) ? _hoursPerDay - 1 : 1),
                            icon: Icon(Icons.remove_circle_outline, color: accentColor),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _hoursPerDay = (_hoursPerDay < 24) ? _hoursPerDay + 1 : 24),
                            icon: Icon(Icons.add_circle_outline, color: accentColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle(AppStrings.of(context, 'reminderTime'), theme),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _selectTime(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: accentColor),
                        const SizedBox(width: 15),
                        Text(
                          _reminderTime.format(context),
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppStrings.of(context, 'reminderChange'), 
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                ),
                if (Platform.isAndroid) ...[
                  const SizedBox(height: 25),
                  _buildSectionTitle(AppStrings.of(context, 'batteryOptimizeTitle'), theme),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.of(context, 'batteryOptimizeDesc'),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => NotificationService().requestIgnoreBatteryOptimizations(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: accentColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: Icon(Icons.battery_saver_rounded, size: 16, color: accentColor),
                                label: Text(AppStrings.of(context, 'disableBatteryOptimization'), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => NotificationService().openAutostartSettings(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: accentColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: Icon(Icons.flash_on_rounded, size: 16, color: accentColor),
                                label: Text(AppStrings.of(context, 'autoStart'), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => NotificationService().openExactAlarmSettings(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: accentColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: Icon(Icons.alarm_on_rounded, size: 16, color: accentColor),
                                label: Text(AppStrings.of(context, 'alarmPermission'), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await NotificationService().showInstantNotification(
                                id: 999,
                                title: '🔔 ${AppStrings.of(context, 'batteryOptimizeTitle')}',
                                body: AppStrings.of(context, 'notificationOk'),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: accentColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(Icons.notifications_active_rounded, size: 18, color: accentColor),
                            label: Text(AppStrings.of(context, 'testNotification'), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: isDark ? 8 : 4,
                      shadowColor: accentColor.withValues(alpha: 0.3),
                    ),
                    child: _isSaving 
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2),
                        )
                      : Text(AppStrings.of(context, 'saveGoal'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
