import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'screens/skill_tree_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillArc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF010409),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFF00A3FF),
          surface: Color(0xFF0D1117),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1117),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00D2FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(color: Color(0xFF8B949E)),
        ),
      ),
      home: const SplashScreen(),
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
    Timer(const Duration(milliseconds: 5500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(title: 'SkillArc'),
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
                        const Color(0xFF00D2FF).withOpacity(0.15 * _pulseController.value),
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
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D2FF).withOpacity(0.3 * _glowIntensity.value),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.white.withOpacity(0.05),
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
                                  color: const Color(0xFF00D2FF).withOpacity(0.8),
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
                                  const Color(0xFF00D2FF).withOpacity(0.5),
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
                              color: Colors.white.withOpacity(0.5),
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
      ..color = const Color(0xFF00D2FF).withOpacity(0.1)
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
          paint.color = const Color(0xFF00D2FF).withOpacity((1 - dist / 150) * 0.1);
          canvas.drawLine(points[i], points[j], paint);
        }
      }
      canvas.drawCircle(points[i], 1.2, paint..color = const Color(0xFF00D2FF).withOpacity(0.1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SkillTreeScreen(),
    const ExploreScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF00D2FF)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              setState(() => _selectedIndex = 4); // Chuyển đến Profile
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF010409), Color(0xFF0D1117)],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1117),
        selectedItemColor: const Color(0xFF00D2FF),
        unselectedItemColor: Colors.white24,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), activeIcon: Icon(Icons.hub), label: 'Lộ trình'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Khám phá'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), activeIcon: Icon(Icons.emoji_events), label: 'Thử thách'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: return 'DASHBOARD';
      case 1: return 'SKILL TREE';
      case 2: return 'EXPLORE';
      case 3: return 'CHALLENGES';
      case 4: return 'MY PROFILE';
      default: return 'SkillArc';
    }
  }
}

