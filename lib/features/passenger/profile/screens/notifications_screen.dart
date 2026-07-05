import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _push = true;
  bool _promos = true;
  bool _rides = true;
  bool _sound = false;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Уведомления',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _row('Push-уведомления', Icons.notifications_rounded, _push,
                  (v) => setState(() => _push = v)),
              _divider(context),
              _row('Акции и скидки', Icons.local_offer_rounded, _promos,
                  (v) => setState(() => _promos = v)),
              _divider(context),
              _row('Статус поездки', Icons.local_taxi_rounded, _rides,
                  (v) => setState(() => _rides = v)),
              _divider(context),
              _row('Звук', Icons.volume_up_rounded, _sound,
                  (v) => setState(() => _sound = v)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 60),
        child: Divider(height: 1, color: AppColors.divider(context)),
      );

  Widget _row(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      height: 66,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
