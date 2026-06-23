import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/mobile_shell.dart';
import '../../profile/screens/profile_screen.dart';
import '../../support/screens/support_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SupportListScreen(),
            ),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
        }
      },
      child: Stack(
        children: [
          // MAP
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(42.8746, 74.5698),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.easygo.app',
              ),
            ],
          ),

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

          // SEARCH BUTTON
          Positioned(
            bottom: 120,
            left: 80,
            child: Container(
              width: 213,
              height: 60,
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
                  const Text(
                    'Куда едем?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}