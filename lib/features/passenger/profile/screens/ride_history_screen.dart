import 'package:flutter/material.dart';

import '../../../../core/role/role_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDriver = RoleController.instance.isDriver;
    return AppPage(
      title: isDriver ? 'История заказов' : 'История поездок',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(44),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Пока нет поездок',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Здесь появятся ваши завершённые поездки — маршрут, время и стоимость.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
