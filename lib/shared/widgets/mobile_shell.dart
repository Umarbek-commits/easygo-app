import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MobileShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTap;

  const MobileShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(110),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30,
                  sigmaY: 30,
                ),
                child: Container(
                  height: 77,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(110),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.65),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = constraints.maxWidth / 3;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            left: widget.currentIndex * tabWidth,
                            top: 5,
                            child: Container(
                              width: tabWidth,
                              height: 67,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius:
                                      BorderRadius.circular(60),
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              _tab(
                                index: 0,
                                icon: CupertinoIcons.chat_bubble_text,
                                label: "Поддержка",
                              ),
                              _tab(
                                index: 1,
                                icon: CupertinoIcons.location_solid,
                                label: "Карта",
                              ),
                              _tab(
                                index: 2,
                                icon: CupertinoIcons.person,
                                label: "Профиль",
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final active = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: active ? 1.0 : 0.95,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 31,
                color: const Color(0xFF222222),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}