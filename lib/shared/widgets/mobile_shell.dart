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
  static const double _barHeight = 82;

  // Текущая тема — влияет на «стекло» панели
  bool _dark = false;

  Color get _activeColor => _dark ? Colors.white : const Color(0xFF1A1A1A);
  Color get _inactiveColor =>
      _dark ? const Color(0xFF9A98A4) : const Color(0xFF8A8A8E);

  // Состояние перетаскивания линзы
  bool _dragging = false;
  double? _dragLeft;
  // Вкладка, которая сейчас подсвечена (во время drag — та, над которой линза)
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    _dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                // Внешние тени — за пределами стекла (мягкая подложка)
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 34,
                      spreadRadius: -4,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: BackdropFilter(
                    // Сильное размытие фона = «жидкое стекло»
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      height: _barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
                        // Полупрозрачный градиентный слой стекла
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _dark
                              ? [
                                  const Color(0xFF3A3844).withOpacity(0.62),
                                  const Color(0xFF25232D).withOpacity(0.52),
                                ]
                              : [
                                  Colors.white.withOpacity(0.62),
                                  Colors.white.withOpacity(0.42),
                                ],
                        ),
                        // Ободок по краю (преломление света)
                        border: Border.all(
                          color: _dark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.white.withOpacity(0.7),
                          width: 1.2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Верхний блик (specular highlight)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: _barHeight * 0.55,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white
                                        .withOpacity(_dark ? 0.10 : 0.45),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final barWidth = constraints.maxWidth;
                              final tabWidth = barWidth / 3;
                              const lensMargin = 8.0;
                              final lensWidth = tabWidth - 16;
                              final maxLeft = barWidth - lensWidth - lensMargin;

                              double leftForIndex(int i) =>
                                  i * tabWidth + lensMargin;

                              int indexForLeft(double left) {
                                final center = left + lensWidth / 2;
                                return (center / tabWidth).floor().clamp(0, 2);
                              }

                              // Позиция линзы: за пальцем при drag, иначе на вкладке
                              final double lensLeft =
                                  _dragging && _dragLeft != null
                                      ? _dragLeft!.clamp(lensMargin, maxLeft)
                                      : leftForIndex(widget.currentIndex);

                              // Подсветка вкладки следует за линзой
                              _activeIndex = _dragging
                                  ? indexForLeft(lensLeft)
                                  : widget.currentIndex;

                              void endDrag() {
                                final idx = indexForLeft(lensLeft);
                                setState(() {
                                  _dragging = false;
                                  _dragLeft = null;
                                });
                                widget.onTap(idx);
                              }

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragStart: (_) {
                                  setState(() {
                                    _dragging = true;
                                    _dragLeft =
                                        leftForIndex(widget.currentIndex);
                                  });
                                },
                                onHorizontalDragUpdate: (d) {
                                  setState(() {
                                    _dragLeft = ((_dragLeft ??
                                                leftForIndex(
                                                    widget.currentIndex)) +
                                            d.delta.dx)
                                        .clamp(lensMargin, maxLeft);
                                  });
                                },
                                onHorizontalDragEnd: (_) => endDrag(),
                                onHorizontalDragCancel: () {
                                  setState(() {
                                    _dragging = false;
                                    _dragLeft = null;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    // Плавающая «линза» активной вкладки
                                    AnimatedPositioned(
                                      // Без задержки при drag — линза идёт за пальцем,
                                      // при отпускании пружинисто примагничивается
                                      duration: _dragging
                                          ? Duration.zero
                                          : const Duration(milliseconds: 480),
                                      curve: Curves.easeOutBack,
                                      left: lensLeft,
                                      top: 10,
                                      child: TweenAnimationBuilder<double>(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        curve: Curves.easeOut,
                                        tween: Tween(
                                          end: _dragging ? 1.0 : 0.0,
                                        ),
                                        builder: (context, t, child) {
                                          // Liquid squash-stretch при захвате
                                          final sx = 1.0 + 0.12 * t;
                                          final sy = 1.0 - 0.06 * t;
                                          return Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..scale(sx, sy),
                                            child: child,
                                          );
                                        },
                                        child: _GlassLens(
                                          width: lensWidth,
                                          height: _barHeight - 20,
                                          isDark: _dark,
                                        ),
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        _tab(
                                          index: 0,
                                          icon:
                                              CupertinoIcons.chat_bubble_text,
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
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
    final active = _activeIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          scale: active ? 1.06 : 0.94,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Плавная смена цвета иконки
              TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 300),
                tween: ColorTween(
                  end: active ? _activeColor : _inactiveColor,
                ),
                builder: (context, color, _) => Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _activeColor : _inactiveColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Стеклянная «линза» под активной вкладкой.
class _GlassLens extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;

  const _GlassLens({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        // Более яркое стекло = приподнятая линза
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.20),
                  Colors.white.withOpacity(0.08),
                ]
              : [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.58),
                ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.20 : 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          // Внутренний верхний блик имитируем светлой тенью сверху
          BoxShadow(
            color: Colors.white.withOpacity(isDark ? 0.18 : 0.6),
            blurRadius: 6,
            spreadRadius: -3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
    );
  }
}
