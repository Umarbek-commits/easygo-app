import 'dart:ui';
import 'package:flutter/material.dart';

/// Анимированный фон с мягко движущимися фиолетовыми свечениями.
class GlowBackground extends StatefulWidget {
  const GlowBackground({super.key});

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // TOP RIGHT GLOW
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Positioned(
            top: -120 + _animation.value,
            right: -120 + _animation.value * 0.5,
            child: child!,
          ),
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
          builder: (context, child) => Positioned(
            top: -80 + _animation.value,
            right: -80 + _animation.value * 0.5,
            child: child!,
          ),
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
          builder: (context, child) => Positioned(
            bottom: -130 - _animation.value,
            left: -130 - _animation.value * 0.5,
            child: child!,
          ),
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
          builder: (context, child) => Positioned(
            bottom: -90 - _animation.value,
            left: -90 - _animation.value * 0.5,
            child: child!,
          ),
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
      ],
    );
  }
}
