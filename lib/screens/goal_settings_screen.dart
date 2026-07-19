import 'package:flutter/material.dart';
import 'package:skill_arc/services/local_db_service.dart';
import 'package:skill_arc/services/notification_service.dart';

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
              primary: Color(0xFF00D2FF),
              onPrimary: Colors.black,
              surface: Color(0xFF161B22),
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

  Future<void> _saveGoal() async {
    setState(() => _isSaving = true);
    try {
      final goal = {
        'hoursPerDay': _hoursPerDay,
        'reminderHour': _reminderTime.hour,
        'reminderMinute': _reminderTime.minute,
      };
      
      await LocalDbService.saveGoal(goal);

      // Lập lịch thông báo
      await NotificationService().scheduleDailyNotification(
        id: 100,
        title: 'Đã đến giờ học rồi!',
        body: 'Mục tiêu hôm nay của bạn là học $_hoursPerDay tiếng. Cố gắng lên nhé!',
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu mục tiêu và cài đặt thông báo!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MỤC TIÊU HỌC TẬP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thiết lập mục tiêu hàng ngày giúp bạn duy trì kỷ luật và tiến xa hơn trên lộ trình nghề nghiệp.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Số giờ học mỗi ngày'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_hoursPerDay giờ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _hoursPerDay = (_hoursPerDay > 1) ? _hoursPerDay - 1 : 1),
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00D2FF)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _hoursPerDay = (_hoursPerDay < 24) ? _hoursPerDay + 1 : 24),
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D2FF)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Thời gian nhắc nhở'),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFF00D2FF)),
                      const SizedBox(width: 15),
                      Text(
                        _reminderTime.format(context),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text('Thay đổi', style: TextStyle(color: Color(0xFF00D2FF))),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D2FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('LƯU MỤC TIÊU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        letterSpacing: 1.5,
        color: Colors.white54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
