import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/dashboard_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _index = 1; // 🐾 Dashboard default
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      setState(() {
        photoUrl = doc.data()?['photoUrl'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      ProfilePage(),
      DashboardPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: pages[_index],

      // 🌟 CUSTOM FLOATING NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              index: 0,
              icon: photoUrl != null
                  ? CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(photoUrl!),
                    )
                  : const Icon(Icons.person),
            ),

            _navItem(
              index: 1,
              icon: const Icon(Icons.pets, size: 32),
              isCenter: true,
            ),

            _navItem(
              index: 2,
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required Widget icon,
    bool isCenter = false,
  }) {
    final selected = _index == index;

    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isCenter ? 12 : 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9B26F) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}
