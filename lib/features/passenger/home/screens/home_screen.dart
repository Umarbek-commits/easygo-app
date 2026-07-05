import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import '../cached_tile_provider.dart';
import '../../../../core/role/role_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../config/secrets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mapbox: путь к стилю в формате "user/styleId".
  // ВАЖНО: растровый tiles-API рисует только КЛАССИЧЕСКИЕ стили.
  // Стиль на базе Mapbox Standard даёт пустые (белые) тайлы.
  // Классические варианты: mapbox/streets-v12, mapbox/light-v11,
  // mapbox/dark-v11, mapbox/navigation-day-v1.
  static const String _mapboxStyle = 'mapbox/streets-v12';
  static const String _mapboxToken = AppSecrets.mapboxToken;

  // Границы Кыргызстана — карту нельзя увести за их пределы
  static final LatLngBounds _kyrgyzstanBounds = LatLngBounds(
    const LatLng(39.10, 69.20), // юго-запад
    const LatLng(43.35, 80.35), // северо-восток
  );

  static const double _minZoom = 6;
  static const double _maxZoom = 18;

  final MapController _map = MapController();
  LatLng? _userLocation;
  bool _locating = false;

  // Заказ поездки (пассажир)
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  LatLng? _pickupPoint; // выбранная на карте точка «Откуда»
  bool _pickingOnMap = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final z = (_map.camera.zoom + 1).clamp(_minZoom, _maxZoom);
    _map.move(_map.camera.center, z);
  }

  void _zoomOut() {
    final z = (_map.camera.zoom - 1).clamp(_minZoom, _maxZoom);
    _map.move(_map.camera.center, z);
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _snack('Включите геолокацию на устройстве');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Нет доступа к геолокации');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _userLocation = loc);
      _map.move(loc, 16);
    } catch (_) {
      _snack('Не удалось определить местоположение');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: const Color(0xFFAE00FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MAP (Mapbox, ограничен Бишкеком)
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: const LatLng(42.8746, 74.5698),
            initialZoom: 13,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            cameraConstraint: CameraConstraint.contain(
              bounds: _kyrgyzstanBounds,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/$_mapboxStyle/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken',
              userAgentPackageName: 'com.easygo.app',
            ),

            // Метка местоположения пользователя
            if (_userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2F80FF),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2F80FF).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Метка выбранной точки «Откуда»
            if (_pickupPoint != null && !_pickingOnMap)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickupPoint!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFAE00FF),
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Режим выбора точки на карте: центральная булавка
        if (_pickingOnMap)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFFAE00FF),
                  size: 50,
                ),
              ),
            ),
          ),

        // Подсказка + подтверждение выбора точки
        if (_pickingOnMap) ...[
          Positioned(
            top: 130,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Двигайте карту и наведите на точку «Откуда»',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _pickingOnMap = false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _confirmPickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAE00FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Подтвердить точку',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // LOGO
        Positioned(
          top: 60,
          left: 11,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Easy',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 62,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: 'GO!',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA020F0),
                    fontSize: 58,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // КНОПКИ УПРАВЛЕНИЯ КАРТОЙ (справа по центру)
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Зум +/- одной группой
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ctrlButton(Icons.add_rounded, _zoomIn),
                      Container(
                        width: 26,
                        height: 1,
                        color: const Color(0xFFE6E6E6),
                      ),
                      _ctrlButton(Icons.remove_rounded, _zoomOut),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Локатор
                GestureDetector(
                  onTap: _locate,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _locating
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Color(0xFFAE00FF),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFFAE00FF),
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // SEARCH BUTTON
        if (!_pickingOnMap)
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _onSearchTap,
              child: Container(
              height: 60,
              constraints: const BoxConstraints(minWidth: 213),
              decoration: BoxDecoration(
                color: const Color(0xFFAE00FF),
                borderRadius: BorderRadius.circular(110),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAE00FF).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ValueListenableBuilder<AppRole>(
                    valueListenable: RoleController.instance.role,
                    builder: (context, role, _) => Text(
                      role == AppRole.driver ? 'Принять заказы' : 'Куда едем?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),
                ],
              ),
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctrlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 48,
        child: Icon(icon, color: const Color(0xFF222222), size: 26),
      ),
    );
  }

  // Нажатие на главную кнопку
  void _onSearchTap() {
    if (RoleController.instance.isDriver) {
      _snack('Приём заказов — скоро');
      return;
    }
    _openRideSheet();
  }

  // Переход в режим выбора точки «Откуда» на карте
  void _startPickOnMap() {
    setState(() => _pickingOnMap = true);
  }

  void _confirmPickup() {
    setState(() {
      _pickupPoint = _map.camera.center;
      _fromController.text = 'Точка на карте';
      _pickingOnMap = false;
    });
    _openRideSheet();
  }

  void _searchCar() {
    _snack('Ищем машину рядом с вами…');
  }

  // Панель заказа поездки
  void _openRideSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Куда едем?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 8),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface(ctx),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                    const SizedBox(height: 20),

                    _sheetLabel(ctx, 'Откуда'),
                    const SizedBox(height: 6),
                    // «Откуда» — можно ввести адрес ИЛИ выбрать на карте
                    _sheetField(
                      ctx,
                      icon: Icons.location_on,
                      controller: _fromController,
                      hint: 'Ваше местоположение',
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _startPickOnMap();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_outlined,
                                  color: Color(0xFFAE00FF), size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Карта',
                                style: TextStyle(
                                  color: Color(0xFFAE00FF),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _sheetLabel(ctx, 'Куда'),
                    const SizedBox(height: 6),
                    // «Куда» — только вручную
                    _sheetField(
                      ctx,
                      icon: Icons.radio_button_checked,
                      controller: _toController,
                      hint: 'Введите адрес',
                    ),
                    const SizedBox(height: 24),

                    // Кнопка — покороче, по центру
                    Center(
                      child: SizedBox(
                        width: 230,
                        height: 54,
                        child: AnimatedBuilder(
                          animation: _toController,
                          builder: (context, _) {
                            final enabled =
                                _toController.text.trim().isNotEmpty;
                            return ElevatedButton.icon(
                              onPressed: enabled
                                  ? () {
                                      Navigator.pop(ctx);
                                      _searchCar();
                                    }
                                  : null,
                              icon: const Icon(Icons.local_taxi_rounded),
                              label: const Text(
                                'Искать машину',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFAE00FF),
                                disabledBackgroundColor:
                                    const Color(0xFFAE00FF).withOpacity(0.4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetLabel(BuildContext ctx, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface(ctx),
      ),
    );
  }

  Widget _sheetField(
    BuildContext ctx, {
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    Widget? trailing,
  }) {
    return Container(
      height: 56,
      padding: EdgeInsets.only(left: 16, right: trailing != null ? 6 : 16),
      decoration: BoxDecoration(
        color: AppColors.isDark(ctx)
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(28), // овальные поля
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFAE00FF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface(ctx),
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface(ctx).withOpacity(0.45),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
