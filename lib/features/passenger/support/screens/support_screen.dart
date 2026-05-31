import 'package:flutter/material.dart';

import '../../../../shared/widgets/mobile_shell.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        body: SafeArea(
          child: Stack(
            children: [
              // Фиолетовый градиент сверху
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFAE00FF),
                      Color(0xFFD8A8E8),
                      Color(0xFFF3F3F3),
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Text(
                      "Поддержка",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Сообщение от поддержки
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Аватар с иконкой headset
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2B36),
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: const Icon(
                            Icons.headset_mic_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "EasyGO! Поддержка",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2B36),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                "Здравствуйте,чем могу\nпомочь?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Растягиваем пространство
                  const SizedBox(height: 395),

                  // Чипы быстрых ответов
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                   padding: const EdgeInsets.fromLTRB(
  20,
  4,
  20,
  4,
),
                    
                    child: Row(
                      children: [
                        _chip("Проблема с водителем"),
                        _chip("Как работает рейтинг?"),
                        _chip("Как вернуть вещь?"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Поле ввода
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 95),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Text(
                              "Сообщение",
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Кнопка отправки
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(String text) {
    return Container(
      margin: const EdgeInsets.only(right:16),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2B36),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}