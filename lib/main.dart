import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/providers/user_provider.dart';
import 'package:skill_arc/providers/challenge_provider.dart';
import 'package:skill_arc/screens/skill_tree_screen.dart';
import 'package:skill_arc/screens/home_screen.dart';
import 'package:skill_arc/screens/explore_screen.dart';
import 'package:skill_arc/screens/challenge_screen.dart';
import 'package:skill_arc/screens/profile_screen.dart';
import 'package:skill_arc/screens/login_screen.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/services/notification_service.dart';
import 'package:skill_arc/providers/skill_provider.dart';
import 'package:skill_arc/providers/theme_provider.dart';
import 'package:skill_arc/services/challenge_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skill_arc/widgets/floating_chat_bot.dart';
import 'package:skill_arc/providers/language_provider.dart';
import 'package:skill_arc/core/constants/app_strings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tải cấu hình biến môi trường từ .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Config loaded from .env');
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e (Normal if config files are missing)');
  }
  
  // 1. Khởi tạo Hive (Database cục bộ)
  await Hive.initFlutter();
  
  // 2. Mở các "hộp" lưu trữ dữ liệu
  await Hive.openBox('userBox');     // Lưu thông tin người dùng
  await Hive.openBox('progressBox'); // Lưu tiến độ học tập
  await Hive.openBox('challengeBox'); // Lưu thử thách
  await Hive.openBox('notificationBox'); // Lưu thông báo

  // 3. Khởi tạo Challenge Service
  await ChallengeService.init();

  // 3. Khởi tạo Notification Service
  await NotificationService().init();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SkillProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'SkillArc',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _bgController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textTracking;
  late Animation<double> _glowIntensity;

  @override
  void initState() {
    super.initState();

    // Điều khiển luồng chính (Fade In / Scale)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Hiệu ứng nhịp thở cho hào quang
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Điều khiển chuyển động nền
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 40),
    ]).animate(_mainController);

    _logoOpacity = CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn));
    
    _textTracking = Tween<double>(begin: 20.0, end: 6.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutExpo)),
    );

    _glowIntensity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );

    _mainController.forward();

    // Chuyển màn hình sau 5 giây
    Timer(const Duration(milliseconds: 5500), () async {
      if (mounted) {
        final authService = AuthService();
        final isLoggedIn = await authService.isLoggedIn();
        
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                isLoggedIn ? const MyHomePage(title: 'SkillArc') : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010409), // Deep Dark Blue
      body: Stack(
        children: [
          // 1. Dynamic Neural Network Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: NeuralPainter(_bgController.value),
                );
              },
            ),
          ),
          
          // 2. Central Energy Glow
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00D2FF).withValues(alpha: 0.15 * _pulseController.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphic Logo Container
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D2FF).withValues(alpha: 0.3 * _glowIntensity.value),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            padding: const EdgeInsets.all(35),
                            child: Image.asset(
                              'assets/logo.png',
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.auto_awesome_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                
                // Cinematic Typography
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    final opacity = (_mainController.value - 0.4).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Column(
                        children: [
                          Text(
                            'SkillArc'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: _textTracking.value,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00D2FF).withValues(alpha: 0.8),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            height: 1,
                            width: 120 * opacity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF00D2FF).withValues(alpha: 0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'ARCHITECTING YOUR CAREER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w200,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter vẽ mạng lưới thần kinh chuyển động
class NeuralPainter extends CustomPainter {
  final double progress;
  NeuralPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    final random = math.Random(1234);
    final points = List.generate(40, (i) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      
      // Chuyển động lơ lửng
      x += math.cos(progress * 2 * math.pi + i) * 40;
      y += math.sin(progress * 2 * math.pi + i) * 40;
      return Offset(x, y);
    });

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        double dist = (points[i] - points[j]).distance;
        if (dist < 150) {
          paint.color = const Color(0xFF00D2FF).withValues(alpha: (1 - dist / 150) * 0.1);
          canvas.drawLine(points[i], points[j], paint);
        }
      }
      canvas.drawCircle(points[i], 1.2, paint..color = const Color(0xFF00D2FF).withValues(alpha: 0.1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const SkillTreeScreen(),
    const ExploreScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentLocale = context.watch<LanguageProvider>().currentLocale;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: FloatingChatBot(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF00D2FF), const Color(0xFF00A3FF)] 
                    : [const Color(0xFF075985), const Color(0xFF3730A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: RepaintBoundary(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: context.watch<ThemeProvider>().useGlassEffects ? 12 : 0,
                      sigmaY: context.watch<ThemeProvider>().useGlassEffects ? 12 : 0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.12)),
                            (isDark ? Colors.white.withValues(alpha: 0.01) : Colors.white.withValues(alpha: 0.03)),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                        border: Border.all(
                          color: (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              _buildGlassActionButton(
                isDark: isDark,
                onTap: () => context.read<ThemeProvider>().toggleTheme(),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              _buildGlassActionButton(
                isDark: isDark,
                onTap: () => context.read<LanguageProvider>().toggleLanguage(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language_rounded, 
                      size: 14, 
                      color: isDark ? Colors.white70 : Colors.black87
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentLocale.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: Hive.box('notificationBox').listenable(),
                builder: (context, Box box, widget) {
                  final notifications = NotificationService().getAllNotifications();
                  final unreadCount = notifications.where((n) => n['isRead'] == false).length;

                  return _buildGlassActionButton(
                    isDark: isDark,
                    onTap: () => _showNotificationsBottomSheet(context),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                          color: unreadCount > 0 ? const Color(0xFF00D2FF) : primaryColor,
                          size: 18,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              _buildUserAvatar(isDark),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark 
                          ? [const Color(0xFF010409), const Color(0xFF0D1117)]
                          : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: RepaintBoundary(child: _buildFloatingNavBar()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(String timestampStr) {
    try {
      final timestamp = DateTime.parse(timestampStr);
      final diff = DateTime.now().difference(timestamp);

      if (diff.inMinutes < 1) {
        return 'Vừa xong';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} phút trước';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} giờ trước';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } catch (_) {
      return '';
    }
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final notifications = NotificationService().getAllNotifications();
            final unreadCount = notifications.where((n) => n['isRead'] == false).length;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF0D1117).withValues(alpha: 0.9) 
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppStrings.of(context, 'locale') == 'vi' ? 'Thông báo' : 'Notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unreadCount mới',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              if (unreadCount > 0)
                                TextButton(
                                  onPressed: () async {
                                    await NotificationService().markAllAsRead();
                                    setModalState(() {});
                                  },
                                  child: Text(
                                    AppStrings.of(context, 'locale') == 'vi' ? 'Đọc tất cả' : 'Read all',
                                    style: TextStyle(color: primaryColor, fontSize: 13),
                                  ),
                                ),
                              if (notifications.isNotEmpty)
                                TextButton(
                                  onPressed: () async {
                                    await NotificationService().clearAllNotifications();
                                    setModalState(() {});
                                  },
                                  child: const Text(
                                    'Xóa hết',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    // List of notifications
                    Expanded(
                      child: notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 64,
                                    color: isDark ? Colors.white30 : Colors.black26,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppStrings.of(context, 'locale') == 'vi' 
                                        ? 'Không có thông báo nào' 
                                        : 'No notifications',
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: notifications.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index) {
                                final n = notifications[index];
                                final isRead = n['isRead'] ?? false;
                                return Dismissible(
                                  key: Key(n['id']),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.redAccent,
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (direction) async {
                                    await NotificationService().deleteNotification(n['id']);
                                    setModalState(() {});
                                  },
                                  child: ListTile(
                                    onTap: () async {
                                      if (!isRead) {
                                        await NotificationService().markAsRead(n['id']);
                                        setModalState(() {});
                                      }
                                    },
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isRead 
                                            ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                                            : primaryColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getNotificationIcon(n['title']),
                                        color: isRead 
                                            ? (isDark ? Colors.white38 : Colors.black38) 
                                            : primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      n['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                        color: isRead 
                                            ? (isDark ? Colors.white60 : Colors.black54)
                                            : (isDark ? Colors.white : Colors.black87),
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          n['body'] ?? '',
                                          style: TextStyle(
                                            color: isRead 
                                                ? (isDark ? Colors.white38 : Colors.black38)
                                                : (isDark ? Colors.white70 : Colors.black87),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatTimeAgo(n['timestamp'] ?? ''),
                                          style: TextStyle(
                                            color: isDark ? Colors.white30 : Colors.black38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: !isRead 
                                        ? Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.contains('Chào mừng') || title.contains('Welcome')) {
      return Icons.celebration_rounded;
    } else if (title.contains('Gợi ý') || title.contains('Suggest') || title.contains('💡')) {
      return Icons.lightbulb_outline_rounded;
    } else if (title.contains('Thử thách') || title.contains('Challenge') || title.contains('🏆')) {
      return Icons.emoji_events_rounded;
    } else if (title.contains('buổi sáng') || title.contains('☀️')) {
      return Icons.wb_sunny_rounded;
    } else if (title.contains('buổi chiều') || title.contains('☕️')) {
      return Icons.coffee_rounded;
    } else if (title.contains('buổi tối') || title.contains('🌙')) {
      return Icons.dark_mode_rounded;
    } else {
      return Icons.notifications_rounded;
    }
  }

  Widget _buildGlassActionButton({
    required Widget child,
    required VoidCallback onTap,
    required bool isDark,
    double radius = 12,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.03),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.08) 
                    : Colors.black.withValues(alpha: 0.05),
                width: 0.8,
              ),
            ),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(bool isDark) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = 4),
          child: Container(
            margin: const EdgeInsets.only(right: 15, left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              backgroundImage: (user?.avatarPath != null && File(user!.avatarPath!).existsSync())
                  ? FileImage(File(user.avatarPath!))
                  : null,
              child: (user?.avatarPath == null || !File(user!.avatarPath!).existsSync())
                  ? Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavBar() {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: context.watch<ThemeProvider>().useGlassEffects ? 15 : 0,
            sigmaY: context.watch<ThemeProvider>().useGlassEffects ? 15 : 0,
          ),
          child: Container(
            height: 85,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.15)),
                  (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.04)),
                ],
              ),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.4)),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.dashboard_rounded, AppStrings.of(context, 'navHome')),
                _navItem(1, Icons.hub_rounded, AppStrings.of(context, 'navRoadmap')),
                _navItem(2, Icons.explore_rounded, AppStrings.of(context, 'navExplore'), isCenter: true),
                _navItem(3, Icons.emoji_events_rounded, AppStrings.of(context, 'navChallenge')),
                _navItem(4, Icons.person_rounded, AppStrings.of(context, 'navProfile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    if (isCenter) {
      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 25,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: return AppStrings.of(context, 'navHome').toUpperCase();
      case 1: return AppStrings.of(context, 'navRoadmap').toUpperCase();
      case 2: return AppStrings.of(context, 'navExplore').toUpperCase();
      case 3: return AppStrings.of(context, 'navChallenge').toUpperCase();
      case 4: return AppStrings.of(context, 'navProfile').toUpperCase();
      default: return 'SkillArc';
    }
  }
}

