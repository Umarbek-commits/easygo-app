import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/role/role_controller.dart';
import '../../../../shared/widgets/role_toggle.dart';
import 'settings_screen.dart';
import 'promo_code_screen.dart';
import 'ride_history_screen.dart';
import 'notifications_screen.dart';
import 'addresses_screen.dart';
import 'info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    // Перестраиваем профиль при смене роли (карточка баланса, история и т.д.)
    RoleController.instance.role.addListener(_onRoleChanged);
  }

  void _onRoleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RoleController.instance.role.removeListener(_onRoleChanged);
    super.dispose();
  }

  Future<void> loadUser() async {
    try {
      final phone = await UserStorage.getPhone();

      if (phone == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final data = await SupabaseService.getUserByPhone(phone);

      setState(() {
        user = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffold(context),
        body: Stack(
          children: [
            // Градиентный фон в верхней части
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFAE00FF),
                    const Color(0xFFD17CF8),
                    AppColors.scaffold(context),
                  ],
                ),
              ),
            ),
            // Основной контент
            SafeArea(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Блок с аватаром, именем и телефоном
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        user?['phone'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Переключатель роли Пассажир/Водитель
                          const RoleToggle(),
                          const SizedBox(height: 30),
                          // Блок с токенами
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFAE00FF),
                                  Color(0xFFE042FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -80,
                                  left: 60,
                                  child: Opacity(
                                    opacity: 0.12,
                                    child: SvgPicture.asset(
                                      "assets/svgs/solarwalletmoneybold.svg",
                                      width: 170,
                                      height: 170,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -40,
                                  left: -40,
                                  child: Opacity(
                                    opacity: 0.12,
                                    child: SvgPicture.asset(
                                      "assets/svgs/solarwalletmoneybold.svg",
                                      width: 80,
                                      height: 140,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  right: -25,
                                  child: Opacity(
                                    opacity: 0.12,
                                    child: SvgPicture.asset(
                                      "assets/svgs/solarwalletmoneybold.svg",
                                      width: 140,
                                      height: 140,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  top: 18,
                                  left: 18,
                                  child: Icon(
                                    CupertinoIcons.info_circle_fill,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _walletPill(
                                        icon: Icons.arrow_downward_rounded,
                                        label: 'Снять',
                                        filled: false,
                                        onTap: () => _walletAction('Снятие'),
                                      ),
                                      const SizedBox(width: 8),
                                      _walletPill(
                                        icon: Icons.add_circle_outline,
                                        label: 'Пополнить',
                                        filled: true,
                                        onTap: () =>
                                            _walletAction('Пополнение'),
                                      ),
                                    ],
                                  ),
                                ),
                                const Positioned(
                                  left: 18,
                                  bottom: 18,
                                  child: Text(
                                    'Мои токены',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  right: 18,
                                  bottom: 8,
                                  child: Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Меню — первая группа
                          _menuGroup([
                            _menuRow(Icons.percent, 'Ввести промокод',
                                () => _open(const PromoCodeScreen())),
                            _menuRow(
                                Icons.history,
                                RoleController.instance.isDriver
                                    ? 'История заказов'
                                    : 'История поездок',
                                () => _open(const RideHistoryScreen())),
                            _menuRow(Icons.notifications_none, 'Уведомления',
                                () => _open(const NotificationsScreen())),
                            _menuRow(Icons.location_on, 'Мои адреса',
                                () => _open(const AddressesScreen())),
                          ]),
                          const SizedBox(height: 20),
                          // Меню — вторая группа
                          _menuGroup([
                            _menuRow(Icons.settings, 'Настройки',
                                () => _open(const SettingsScreen())),
                            _menuRow(Icons.info, 'Информация',
                                () => _open(const InfoScreen())),
                          ]),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
  }

  // Сгруппированный блок пунктов с разделителями между ними
  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _walletAction(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type — скоро'),
        backgroundColor: const Color(0xFFAE00FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _walletPill({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final fg = filled ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(30),
          border: filled
              ? null
              : Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuGroup(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider(context),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Одна строка меню (без собственного фона — фон даёт группа)
  Widget _menuRow(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}