import 'package:flutter/material.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/utils/app_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = AppStrings.of(context, 'confirmPasswordMismatch'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          AppToast.show(context, AppStrings.of(context, 'registerSuccess'));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppDesignTokens.colorPrimary : theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'registerTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.primary),
        titleTextStyle: TextStyle(
          color: isDark ? AppDesignTokens.colorPrimary : theme.colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 80, color: accentColor),
                const SizedBox(height: 32),
                _buildField(_usernameController, AppStrings.of(context, 'username'), Icons.person, theme, accentColor, isDark),
                const SizedBox(height: 16),
                _buildField(_emailController, AppStrings.of(context, 'email'), Icons.email, theme, accentColor, isDark),
                const SizedBox(height: 16),
                _buildField(_fullNameController, AppStrings.of(context, 'fullName'), Icons.badge, theme, accentColor, isDark),
                const SizedBox(height: 16),
                _buildField(_passwordController, AppStrings.of(context, 'password'), Icons.lock, theme, accentColor, isDark, obscure: true),
                const SizedBox(height: 16),
                _buildField(_confirmPasswordController, AppStrings.of(context, 'confirmPassword'), Icons.lock_reset, theme, accentColor, isDark, obscure: true),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.colorErrorBgDark,
                      border: Border.all(color: AppDesignTokens.colorErrorBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_errorMessage',
                      style: const TextStyle(color: AppDesignTokens.colorErrorText, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: isDark ? 8 : 4,
                      shadowColor: accentColor.withValues(alpha: 0.4),
                    ),
                    child: _isLoading 
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2),
                        )
                      : Text(AppStrings.of(context, 'register'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, ThemeData theme, Color accentColor, bool isDark, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
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
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      ),
    );
  }
}
