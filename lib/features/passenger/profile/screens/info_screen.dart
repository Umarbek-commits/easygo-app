import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Информация',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Логотип + версия на чистой подложке (чётко виден в любой теме)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Easy',
                          style: TextStyle(
                            color: AppColors.onSurface(context),
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: 'GO!',
                          style: TextStyle(
                            color: Color(0xFFAE00FF),
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Версия 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Container(
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _row(context, Icons.description_rounded,
                      'Условия использования'),
                  _divider(context),
                  _row(context, Icons.privacy_tip_rounded,
                      'Политика конфиденциальности'),
                  _divider(context),
                  _row(context, Icons.star_rounded, 'Оценить приложение'),
                  _divider(context),
                  _row(context, Icons.support_agent_rounded,
                      'Связаться с нами'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              '© 2026 EasyGO. Все права защищены.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 60),
        child: Divider(height: 1, color: AppColors.divider(context)),
      );

  Widget _row(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('«$title» — скоро'),
            backgroundColor: const Color(0xFFAE00FF),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardIcon(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
