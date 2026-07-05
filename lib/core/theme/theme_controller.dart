import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Глобальный контроллер темы. Хранит выбор пользователя и сохраняет его
/// между запусками. MaterialApp подписан на [mode] и перестраивается при смене.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _key = 'dark_theme_enabled';

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  bool get isDark => mode.value == ThemeMode.dark;

  /// Загрузка сохранённого выбора (вызывать до runApp).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_key) ?? false;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool dark) async {
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}
