import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/splash_screen.dart';

class EasyGoApp extends StatelessWidget {
  const EasyGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyGO',
      theme: AppTheme.darkTheme,
      home:  SplashScreen(),
    );
  }
}