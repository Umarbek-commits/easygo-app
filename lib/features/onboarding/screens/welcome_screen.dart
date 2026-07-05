import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/screens/register_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/glow_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openWithSlide(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          const Positioned.fill(child: GlowBackground()),

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
                      onPressed: () =>
                          _openWithSlide(context, const RegisterScreen()),
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
                  onPressed: () =>
                      _openWithSlide(context, const LoginScreen()),
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
