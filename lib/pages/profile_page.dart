import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/edit_profile_page.dart';
import '../pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  String name = '';
  String username = '';
  String? photoUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          name = doc.data()?['name'] ?? '';
          username = doc.data()?['username'] ?? 'admin8888';
          photoUrl = doc.data()?['photoUrl'];
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _pickAndUploadImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked == null) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final file = File(picked.path);

  final ref = FirebaseStorage.instance
      .ref()
      .child('profile_pictures')
      .child('${user.uid}.jpg');

  await ref.putFile(file);
  final url = await ref.getDownloadURL();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'photoUrl': url}, SetOptions(merge: true));

  setState(() {
    photoUrl = url;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DDC8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 20),

                  // 🔙 TITLE
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 👤 PROFILE IMAGE
                  GestureDetector(
                     onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                     child: photoUrl == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
                     ),
                      ),


                  const SizedBox(height: 8),

                  // ✏️ EDIT PICTURE
                  const Text(
                    'Edit Picture',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ⬜ WHITE CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuTile(
                          title: 'Edit Profile',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                            _loadProfile();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          title: 'Settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        _divider(),
                        _menuTile(
                          title: 'Log Out',
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _menuTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }
}
