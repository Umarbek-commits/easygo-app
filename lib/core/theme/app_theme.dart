import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandPurple = Color(0xFFAE00FF);

  // ─────────────────────────── СВЕТЛАЯ ТЕМА ───────────────────────────
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F3F3),
    colorScheme: const ColorScheme.light(
      primary: brandPurple,
      secondary: Color(0xFF8B5CF6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    switchTheme: _switchTheme,
  );

  // ─────────────────────────── ТЁМНАЯ ТЕМА ───────────────────────────
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0E12),
    colorScheme: const ColorScheme.dark(
      primary: brandPurple,
      secondary: Color(0xFF8B5CF6),
      surface: Color(0xFF1B1A20),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    switchTheme: _switchTheme,
  );

  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => Colors.white,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? brandPurple
          : const Color(0xFF6E6C78),
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );
}

/// Семантические цвета, зависящие от текущей темы.
/// Использование: `AppColors.scaffold(context)`.
class AppColors {
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Фон страницы (и «низ» градиентных шапок).
  static Color scaffold(BuildContext c) =>
      isDark(c) ? const Color(0xFF0E0E12) : const Color(0xFFF3F3F3);

  /// Светлые поверхности (белые карточки, поле ввода-контейнеры).
  static Color surface(BuildContext c) =>
      isDark(c) ? const Color(0xFF1B1A20) : Colors.white;

  /// Текст на [surface].
  static Color onSurface(BuildContext c) =>
      isDark(c) ? Colors.white : Colors.black87;

  /// Тёмные акцентные карточки (меню, настройки, пузыри поддержки).
  static Color card(BuildContext c) =>
      isDark(c) ? const Color(0xFF1F1E25) : const Color(0xFF2D2B36);

  /// Фон иконки-плашки внутри [card].
  static Color cardIcon(BuildContext c) =>
      isDark(c) ? const Color(0xFF2E2C38) : const Color(0xFF1F1D27);

  /// Заголовки секций (крупный жирный текст на фоне страницы).
  static Color sectionTitle(BuildContext c) =>
      isDark(c) ? const Color(0xFFC8C6D0) : const Color(0xFF2D2B36);

  /// Приглушённый вторичный текст.
  static Color textSecondary(BuildContext c) =>
      isDark(c) ? const Color(0xFF9A98A4) : const Color(0xFF8A8A8E);

  /// Разделитель внутри тёмных карточек.
  static Color divider(BuildContext c) =>
      isDark(c) ? Colors.white.withOpacity(0.08) : const Color(0xFF3C3A46);

  /// Фон поля ввода в чате.
  static Color inputBg(BuildContext c) =>
      isDark(c) ? const Color(0xFF232228) : const Color(0xFFE5E5E5);
}
