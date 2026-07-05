import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/storage/user_storage.dart';
import '../../passenger/main_tab_screen.dart';
import '../widgets/glow_background.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoRise;
  late Animation<double> _subFade;
  late Animation<Offset> _subRise;

  @override
  void initState() {
    super.initState();

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // Лого медленно проявляется и мягко поднимается
    _logoFade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoRise = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Подпись появляется следом
    _subFade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _subRise = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _entry.forward();

    // Убираем нативный сплэш, как только нарисован первый кадр Flutter —
    // переход получается без чёрного экрана.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // Через паузу уходим дальше
    Future.delayed(const Duration(milliseconds: 2600), _goNext);
  }

  Future<void> _goNext() async {
    final phone = await UserStorage.getPhone();
    if (!mounted) return;

    final Widget next = (phone != null && phone.isNotEmpty)
        ? const MainTabScreen()
        : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          const Positioned.fill(child: GlowBackground()),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ЛОГОТИП EasyGO!
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoRise,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Easy',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 72,
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
                              fontSize: 72,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFFAE00FF).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ПОДПИСЬ
                FadeTransition(
                  opacity: _subFade,
                  child: SlideTransition(
                    position: _subRise,
                    child: Text(
                      'Твоя поездка рядом',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
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
