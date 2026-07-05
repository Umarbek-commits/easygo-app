import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page.dart';

class _Address {
  final String label;
  final String value;
  final IconData icon;
  _Address(this.label, this.value, this.icon);
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<_Address> _addresses = [
    _Address('Дом', 'ул. Чуй, 120', Icons.home_rounded),
    _Address('Работа', 'пр. Манаса, 40', Icons.work_rounded),
  ];

  Future<void> _addAddress() async {
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: AppColors.scaffold(ctx),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(ctx),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Новый адрес',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface(ctx),
                  ),
                ),
                const SizedBox(height: 16),
                _field(ctx, labelCtrl, 'Название (Дом, Работа...)'),
                const SizedBox(height: 12),
                _field(ctx, valueCtrl, 'Адрес'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (valueCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE00FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (added == true) {
      setState(() {
        _addresses.add(_Address(
          labelCtrl.text.trim().isEmpty ? 'Адрес' : labelCtrl.text.trim(),
          valueCtrl.text.trim(),
          Icons.location_on_rounded,
        ));
      });
    }
  }

  Widget _field(BuildContext ctx, TextEditingController c, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8A8A8E)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Мои адреса',
      child: Stack(
        children: [
          _addresses.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = _addresses[index];
                    return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardIcon(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.value,
                              style: const TextStyle(
                                color: Color(0xFF9A98A4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _addresses.removeAt(index)),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFF9A98A4),
                        ),
                      ),
                    ],
                  ),
                );
                  },
                ),

          // Кнопка добавления адреса
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: _addAddress,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFAE00FF),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAE00FF).withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Добавить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded,
              size: 64, color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text(
            'Нет сохранённых адресов',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface(context),
            ),
          ),
        ],
      ),
    );
  }
}
