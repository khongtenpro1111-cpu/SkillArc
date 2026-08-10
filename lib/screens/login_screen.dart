import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/main.dart';
import 'package:skill_arc/screens/register_screen.dart';
import 'package:skill_arc/providers/challenge_provider.dart';
import 'package:skill_arc/providers/skill_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isLoading = false);

      // Navigate ngay, data load ngầm ở background
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'SkillArc')),
      );

      // Load data sau khi navigate (không block UI)
      Provider.of<ChallengeProvider>(context, listen: false).loadChallenges();
      Provider.of<SkillProvider>(context, listen: false).refreshData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = AppStrings.of(context, 'loginFailed');
      });
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Hero(
                    tag: 'app_logo',
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 80,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SKILL ARC',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: AppStrings.of(context, 'username'),
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    prefixIcon: Icon(Icons.person_outline, color: accentColor),
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
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: AppStrings.of(context, 'password'),
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                      : Text(AppStrings.of(context, 'login'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    AppStrings.of(context, 'noAccount'),
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
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
}
