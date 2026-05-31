import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../auth/screens/register_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/storage/user_storage.dart';
import '../../passenger/home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Future<void> _checkLogin() async {
    final phone = await UserStorage.getPhone();

    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // TOP RIGHT GLOW
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: -120 + _animation.value,
                right: -120 + _animation.value * 0.5,
                child: child!,
              );
            },
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAE00FF).withOpacity(1.0),
                    const Color(0xFF9300D7).withOpacity(0.6),
                    const Color(0xFFAE00FF).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // TOP RIGHT BLUR
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: -80 + _animation.value,
                right: -80 + _animation.value * 0.5,
                child: child!,
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFAE00FF).withOpacity(0.45),
                ),
              ),
            ),
          ),

          // BOTTOM LEFT GLOW
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: -130 - _animation.value,
                left: -130 - _animation.value * 0.5,
                child: child!,
              );
            },
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAE00FF).withOpacity(1.0),
                    const Color(0xFF9300D7).withOpacity(0.65),
                    const Color(0xFFAE00FF).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // BOTTOM LEFT BLUR
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: -90 - _animation.value,
                left: -90 - _animation.value * 0.5,
                child: child!,
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9300D7).withOpacity(0.5),
                ),
              ),
            ),
          ),

          // ОСНОВНОЙ КОНТЕНТ
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // ЛОГОТИП EasyGO!
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Easy',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 75,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: 'GO!',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFAE00FF),
                          fontSize: 75,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFAE00FF).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // КНОПКА РЕГИСТРАЦИЯ
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (_, animation, __) =>
                                const RegisterScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              const begin = Offset(0.15, 0);
                              const end = Offset.zero;

                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(
                                CurveTween(curve: Curves.easeOutCubic),
                              );

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E2E),
                        elevation: 12,
                        shadowColor: Colors.black.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Регистрация',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ССЫЛКА ВОЙТИ
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 350),
                        pageBuilder: (_, animation, __) =>
                            const LoginScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          const begin = Offset(0.15, 0);
                          const end = Offset.zero;

                          final tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(
                            CurveTween(curve: Curves.easeOutCubic),
                          );

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'v0.0.1',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}