import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/providers/user_provider.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _githubController;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _bioController = TextEditingController(text: widget.user.bio);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _githubController = TextEditingController(text: widget.user.githubUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(UserProvider userProvider) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      await userProvider.updateAvatar(image.path);
      setState(() {}); // Refresh avatar display
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
              Navigator.of(context).pop(true); // Đóng màn hình chỉnh sửa
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState == null) {
      _showErrorDialog(context, "Lỗi: Form không khả dụng.");
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final userProvider = context.read<UserProvider>();
        final success = await userProvider.updateProfileDetails(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          bio: _bioController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          githubUrl: _githubController.text.trim(),
        );

        if (mounted) {
          _showSuccessDialog(
            context,
            success ? AppStrings.of(context, 'updateProfileSuccess') : AppStrings.of(context, 'saveLocalSuccess'),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(context, '${AppStrings.of(context, 'errorPrefix')} $e');
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppDesignTokens.colorPrimary : theme.colorScheme.primary;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser ?? widget.user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'editProfile')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? AppDesignTokens.msgBotBgDark : theme.colorScheme.primaryContainer,
                          backgroundImage: (currentUser.avatarPath != null && File(currentUser.avatarPath!).existsSync())
                              ? FileImage(File(currentUser.avatarPath!))
                              : null,
                          child: (currentUser.avatarPath == null || !File(currentUser.avatarPath!).existsSync())
                              ? Icon(Icons.person, size: 50, color: accentColor)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(userProvider),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? AppDesignTokens.chatBgDark : Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildFieldLabel(theme, AppStrings.of(context, 'fullName')),
                _buildTextField(
                  controller: _nameController,
                  hint: AppStrings.of(context, 'enterFullName'),
                  icon: Icons.person_outline,
                  accentColor: accentColor,
                  isDark: isDark,
                  theme: theme,
                  validator: (value) => value!.isEmpty ? AppStrings.of(context, 'fullNameRequired') : null,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel(theme, 'Email'),
                _buildTextField(
                  controller: _emailController,
                  hint: AppStrings.of(context, 'enterEmail'),
                  icon: Icons.email_outlined,
                  accentColor: accentColor,
                  isDark: isDark,
                  theme: theme,
                  validator: (value) => value!.isEmpty ? AppStrings.of(context, 'emailRequired') : null,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel(theme, AppStrings.of(context, 'phone')),
                _buildTextField(
                  controller: _phoneController,
                  hint: AppStrings.of(context, 'enterPhone'),
                  icon: Icons.phone_outlined,
                  accentColor: accentColor,
                  isDark: isDark,
                  theme: theme,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel(theme, AppStrings.of(context, 'bio')),
                _buildTextField(
                  controller: _bioController,
                  hint: AppStrings.of(context, 'bioHint'),
                  icon: Icons.notes_rounded,
                  accentColor: accentColor,
                  isDark: isDark,
                  theme: theme,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel(theme, 'GitHub Link'),
                _buildTextField(
                  controller: _githubController,
                  hint: 'https://github.com/username',
                  icon: Icons.code_rounded,
                  accentColor: accentColor,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
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
                      : Text(AppStrings.of(context, 'save'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildFieldLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required ThemeData theme,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: accentColor),
      ),
      validator: validator,
    );
  }
}
