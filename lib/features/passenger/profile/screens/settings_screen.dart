import 'package:flutter/material.dart';
import 'package:easygo_app/features/onboarding/screens/splash_screen.dart';
import 'package:easygo_app/core/storage/user_storage.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFAE00FF),
                    Color(0xFFD9A6EA),
                    Color(0xFFF3F3F3),
                  ],
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Настройки",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 55),

                  const Text(
                    "Основное",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2B36),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _settingsCard(
                    children: [
                      _tile(
                        icon: Icons.phone_rounded,
                        title: "Номер телефона",
                        onTap: () {},
                      ),
                      const Divider(
                        color: Color(0xFF494654),
                        height: 1,
                      ),
                      _tile(
                        icon: Icons.email_rounded,
                        title: "Добавить почту",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Тема",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2B36),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2B36),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1D27),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dark_mode_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            "Темная тема",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: darkTheme,
                          onChanged: (value) {
                            setState(() {
                              darkTheme = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Аккаунт",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2B36),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _settingsCard(
                    children: [
                      _tile(
                        icon: Icons.person_rounded,
                        title: "Выйти",
                        onTap: () async {
                          await UserStorage.clear();

                          if (!mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplashScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2B36),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            const SizedBox(width: 12),

            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1D27),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
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
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),

            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}