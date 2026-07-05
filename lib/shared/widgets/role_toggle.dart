import 'package:flutter/material.dart';

import '../../core/role/role_controller.dart';
import '../../features/driver/screens/driver_registration_screen.dart';

/// Переключатель роли Пассажир/Водитель для шапки профиля.
/// Ползунок плавно переезжает, экран не перезагружается.
class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key});

  void _select(BuildContext context, bool wantDriver) {
    final rc = RoleController.instance;
    if (!wantDriver) {
      rc.setPassenger();
      return;
    }
    // Хотим стать водителем
    if (rc.driverStatus.value == DriverStatus.approved) {
      rc.tryEnableDriver();
    } else {
      // Не зарегистрирован или на проверке — открываем экран водителя
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DriverRegistrationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppRole>(
      valueListenable: RoleController.instance.role,
      builder: (context, role, _) {
        final isDriver = role == AppRole.driver;
        return Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final segW = c.maxWidth / 2;
              return Stack(
                children: [
                  // Ползунок
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment:
                        isDriver ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        width: segW - 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _segment(
                          context,
                          icon: Icons.directions_walk_rounded,
                          label: 'Пассажир',
                          active: !isDriver,
                          onTap: () => _select(context, false),
                        ),
                        _segment(
                          context,
                          icon: Icons.local_taxi_rounded,
                          label: 'Водитель',
                          active: isDriver,
                          onTap: () => _select(context, true),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _segment(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final color = active ? const Color(0xFFAE00FF) : Colors.white;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
