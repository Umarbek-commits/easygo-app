import 'package:flutter/material.dart';

import '../../shared/widgets/mobile_shell.dart';
import 'home/screens/home_screen.dart';
import 'profile/screens/profile_screen.dart';
import 'support/screens/support_list_screen.dart';

/// Хост вкладок: одна общая панель + IndexedStack.
/// Вкладки не пересоздаются при переключении — состояние (карта, скролл,
/// загруженные данные) сохраняется, а переход мгновенный, как в iOS.
class MainTabScreen extends StatefulWidget {
  final int initialIndex;

  const MainTabScreen({super.key, this.initialIndex = 1});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _index = widget.initialIndex;

  static const _tabs = [
    SupportListScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      currentIndex: _index,
      onTap: (i) {
        if (i == _index) return;
        setState(() => _index = i);
      },
      child: IndexedStack(
        index: _index,
        children: _tabs,
      ),
    );
  }
}
