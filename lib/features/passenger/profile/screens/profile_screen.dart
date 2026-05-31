import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../../../shared/widgets/mobile_shell.dart';
import '../../home/screens/home_screen.dart';
import '../../support/screens/support_screen.dart';
import 'settings_screen.dart';

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
    return MobileShell(
      currentIndex: 2,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SupportScreen(),
            ),
          );
        }

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Stack(
          children: [
            // Градиентный фон в верхней части
            Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFAE00FF),
                    Color(0xFFD17CF8),
                    Colors.white,
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
                                    // Белая плашка для номера телефона
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
                          // Увеличен отступ между профилем и карточкой токенов
                          const SizedBox(height: 40),
                          // Блок с токенами (обновленный с дополнительными элементами)
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
                                // Декоративные SVG элементы
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
                                // Иконка информации (Cupertino icon)
                                Positioned(
                                  top: 18,
                                  left: 18,
                                  child: const Icon(
                                    CupertinoIcons.info_circle_fill,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                // Кнопка "Пополнить" (справа сверху)
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Пополнить',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Текст "Мои токены" (слева снизу)
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
                                // Количество токенов (справа снизу)
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
                          // Меню
                          _menuItem(Icons.discount, 'Ввести промокод', () {}),
                          _menuItem(Icons.history, 'История поездок', () {}),
                          _menuItem(Icons.notifications, 'Уведомления', () {}),
                          _menuItem(Icons.location_on, 'Мои адреса', () {}),
                          _menuItem(Icons.settings, 'Настройки', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          }),
                          _menuItem(Icons.info, 'Информация', () {}),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2733),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
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
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}