import 'package:flutter/material.dart';

import '../../../core/role/role_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  static const _docs = [
    ('Паспорт', Icons.badge_rounded),
    ('Водительское удостоверение', Icons.card_membership_rounded),
    ('Техпаспорт', Icons.description_rounded),
    ('Фото автомобиля', Icons.directions_car_rounded),
  ];

  // Отмеченные (условно «загруженные») документы
  final Set<int> _uploaded = {};

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Режим водителя',
      child: ValueListenableBuilder<DriverStatus>(
        valueListenable: RoleController.instance.driverStatus,
        builder: (context, status, _) {
          switch (status) {
            case DriverStatus.pending:
              return _pending();
            case DriverStatus.approved:
              return _approved();
            case DriverStatus.none:
              return _registration();
          }
        },
      ),
    );
  }

  // ─────────────── Регистрация ───────────────
  Widget _registration() {
    final allUploaded = _uploaded.length == _docs.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Чтобы использовать режим водителя, необходимо пройти регистрацию.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface(context).withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 20),

          // Документы
          Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _docs.length; i++) ...[
                  _docRow(i),
                  if (i != _docs.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Divider(
                          height: 1, color: AppColors.divider(context)),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: allUploaded ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAE00FF),
                disabledBackgroundColor:
                    const Color(0xFFAE00FF).withOpacity(0.35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                allUploaded
                    ? 'Начать регистрацию'
                    : 'Прикрепите все документы',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docRow(int i) {
    final done = _uploaded.contains(i);
    final (title, icon) = _docs[i];
    return GestureDetector(
      onTap: () => setState(() {
        done ? _uploaded.remove(i) : _uploaded.add(i);
      }),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
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
            Icon(
              done ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: done ? const Color(0xFF48D06B) : Colors.white54,
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await RoleController.instance.submitDriverRegistration();
  }

  // ─────────────── На проверке ───────────────
  Widget _pending() {
    return _statusView(
      icon: Icons.hourglass_top_rounded,
      color: const Color(0xFFF5A623),
      title: 'На проверке',
      text:
          'Мы проверяем ваши документы. Обычно это занимает до 24 часов. '
          'Как только модератор подтвердит — вы сможете включить режим водителя.',
      // Демо-кнопка (в реальном приложении подтверждает модератор)
      action: OutlinedButton(
        onPressed: () => RoleController.instance.approveDriver(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface(context),
          side: BorderSide(color: AppColors.divider(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(220, 48),
        ),
        child: const Text('Одобрить (демо)'),
      ),
    );
  }

  // ─────────────── Одобрено ───────────────
  Widget _approved() {
    return _statusView(
      icon: Icons.verified_rounded,
      color: const Color(0xFF48D06B),
      title: 'Вы водитель!',
      text: 'Ваш водительский профиль подтверждён. '
          'Можно включать режим водителя в профиле.',
      action: ElevatedButton(
        onPressed: () async {
          await RoleController.instance.tryEnableDriver();
          if (mounted) Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAE00FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(220, 50),
        ),
        child: const Text(
          'Включить режим водителя',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _statusView({
    required IconData icon,
    required Color color,
    required String title,
    required String text,
    required Widget action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 46),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 28),
            action,
          ],
        ),
      ),
    );
  }
}
