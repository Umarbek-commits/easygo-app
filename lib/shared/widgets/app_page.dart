import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Общий каркас внутренней страницы: градиентная шапка с кнопкой «назад»
/// и заголовком. Адаптируется под светлую/тёмную тему.
class AppPage extends StatelessWidget {
  final String title;
  final Widget child;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      body: Stack(
        children: [
          // Градиентная шапка — до самого верха, под статус-бар
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFAE00FF),
                  const Color(0xFFD9A6EA),
                  AppColors.scaffold(context),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
