import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_preferences.dart';
import '../theme/theme_controller.dart';
import '../localization/language_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDark = false;
  bool notificationOn = true;

  // 🔗 Current linked device (1 for now)
  final String deviceId = 'PetDispenser-Vera11';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    isDark = await UserPreferences.loadDarkMode();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF2B1E15) : const Color(0xFFE6DDC8),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF3A2A1D)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌙 DARK MODE
              _row(
                'Dark mode',
                Switch(
                  value: isDark,
                  onChanged: (v) async {
                    setState(() => isDark = v);
                    await UserPreferences.saveDarkMode(v);
                    ThemeController.setTheme(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),

              const Divider(height: 30),

              // 🔗 LINKED DEVICE (LIVE)
              const Text(
                'Linked Device',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _linkedDeviceLive(deviceId),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: _addDeviceDialog,
                child: const Text(
                  '+ Add Others',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const Divider(height: 30),

              // 🔔 NOTIFICATION
              _row(
                'Notification',
                Switch(
                  value: notificationOn,
                  onChanged: (v) {
                    setState(() => notificationOn = v);
                  },
                ),
              ),

              const Divider(height: 30),

              // 🌐 LANGUAGE
              const Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _langButton('ms', 'Malay', isDarkMode),
                  const SizedBox(width: 10),
                  _langButton('en', 'English', isDarkMode),
                ],
              ),

              const Divider(height: 30),

              // ❓ HELP / ABOUT / FEEDBACK
              _simpleItem('Help Center', _helpCenter),
              _simpleItem('About', _aboutApp),
              _simpleItem('Send feedback', _sendFeedback),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LINKED DEVICE (LIVE STATUS) =================

  Widget _linkedDeviceLive(String deviceId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading device...');
        }

        if (!snapshot.data!.exists) {
          return const Text('Device not found');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final Timestamp? lastSeen = data['lastSeen'];
        final bool isActive = data['isActive'] ?? true;

        bool isOnline = false;
        if (lastSeen != null) {
          final diff =
              DateTime.now().difference(lastSeen.toDate()).inSeconds;
          isOnline = diff < 10; // ⏱ ONLINE THRESHOLD
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(deviceId),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isOnline && isActive
                    ? Colors.green
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOnline && isActive ? 'Online' : 'Offline',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _row(String text, Widget trailing) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _langButton(String code, String label, bool isDarkMode) {
    final selected =
        LanguageController.locale.value.languageCode == code;

    return GestureDetector(
      onTap: () async {
        await UserPreferences.saveLanguage(code);
        LanguageController.setLanguage(code);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB89B7E)
              : (isDarkMode
                  ? const Color(0xFF5D4037)
                  : Colors.grey[300]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected || isDarkMode
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _simpleItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Text(title),
      ),
    );
  }

  // ================= DIALOGS =================

  void _addDeviceDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Add Device'),
        content: Text(
          'Multiple device support will be added in future versions.',
        ),
      ),
    );
  }

  void _helpCenter() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Help Center'),
        content: Text(
          'For assistance, contact:\n\nsupport@petcare.app',
        ),
      ),
    );
  }

  void _aboutApp() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('About'),
        content: Text(
          'Pet Donation & Smart Dispenser App\n'
          'Version 1.0\n\n'
          'This app connects live donations to automated feeding.',
        ),
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Send Feedback'),
        content: Text(
          'We appreciate your feedback!\n\n'
          'Email: feedback@petcare.app',
        ),
      ),
    );
  }
}
