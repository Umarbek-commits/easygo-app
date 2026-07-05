import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Активная роль пользователя. Аккаунт один — роль переключается.
enum AppRole { passenger, driver }

/// Статус водительского профиля.
enum DriverStatus { none, pending, approved }

/// Глобальный контроллер роли. Хранит активную роль и статус водителя,
/// сохраняет их между запусками. Экраны подписываются на [role] и
/// перестраивают только нужные части (карта/баланс/история).
class RoleController {
  RoleController._();
  static final RoleController instance = RoleController._();

  static const _roleKey = 'active_role';
  static const _driverStatusKey = 'driver_status';

  final ValueNotifier<AppRole> role = ValueNotifier(AppRole.passenger);
  final ValueNotifier<DriverStatus> driverStatus =
      ValueNotifier(DriverStatus.none);

  bool get isDriver => role.value == AppRole.driver;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final s = prefs.getString(_driverStatusKey);
    driverStatus.value = DriverStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DriverStatus.none,
    );

    // Роль «водитель» доступна только после подтверждения
    final r = prefs.getString(_roleKey);
    if (r == AppRole.driver.name &&
        driverStatus.value == DriverStatus.approved) {
      role.value = AppRole.driver;
    } else {
      role.value = AppRole.passenger;
    }
  }

  Future<void> _saveRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.value.name);
  }

  Future<void> _saveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverStatusKey, driverStatus.value.name);
  }

  Future<void> setPassenger() async {
    role.value = AppRole.passenger;
    await _saveRole();
  }

  /// Пытается включить режим водителя. Возвращает false, если нельзя
  /// (не зарегистрирован / на проверке) — тогда экран покажет регистрацию.
  Future<bool> tryEnableDriver() async {
    if (driverStatus.value == DriverStatus.approved) {
      role.value = AppRole.driver;
      await _saveRole();
      return true;
    }
    return false;
  }

  /// Отправка заявки на регистрацию водителя → статус «на проверке».
  Future<void> submitDriverRegistration() async {
    driverStatus.value = DriverStatus.pending;
    await _saveStatus();
  }

  /// Подтверждение (в реальном приложении — модератор).
  /// Здесь используется для демонстрации.
  Future<void> approveDriver() async {
    driverStatus.value = DriverStatus.approved;
    await _saveStatus();
  }
}
