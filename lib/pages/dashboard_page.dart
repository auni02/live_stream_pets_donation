import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manual_control_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _openTikTok() async {
    final Uri tiktokUrl = 
    Uri.parse('https://www.tiktok.com/@letherbee');

    if (!await launchUrl(
      tiktokUrl,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('Could not open Tiktok');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DDC8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              //  TIKTOK 
              _card(
                iconWidget: const Icon(Icons.tiktok, size: 50), // ✅ add this asset
                title: 'TikTok',
                onTap: _openTikTok, 
              ),

              const SizedBox(height: 20),

              //  MANUAL CONTROL 
              _card(
                iconWidget: const Icon(Icons.touch_app, size: 50),
                title: 'Manual Control',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManualControlPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget iconWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
