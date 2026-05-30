import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ppfyjiengpulysyvgawn.supabase.co',
    anonKey: 'sb_publishable_-IR2Sly_KScIw6-mAA2cRg_Vpvb-4Pd',
  );

  runApp(const EasyGoApp());
}