import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'core/role/role_controller.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Удерживаем нативный сплэш, пока идёт инициализация — чтобы не было
  // чёрного экрана между заставкой и первым кадром Flutter.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    url: 'https://ppfyjiengpulysyvgawn.supabase.co',
    anonKey: 'sb_publishable_-IR2Sly_KScIw6-mAA2cRg_Vpvb-4Pd',
  );

  // Загружаем сохранённый выбор темы и роли
  await ThemeController.instance.load();
  await RoleController.instance.load();

  runApp(const EasyGoApp());
}