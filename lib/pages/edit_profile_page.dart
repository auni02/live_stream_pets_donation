import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String email = '';
  String username = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          email = user.email ?? '';
          nameController.text = doc.data()?['name'] ?? '';
          phoneController.text = doc.data()?['phone'] ?? '';
          username = doc.data()?['username'] ?? 'admin8888';
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Edit Profile Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': user.email,
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================= CHANGE PASSWORD =================
  Future<void> _changePassword() async {
    if (email.isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your inbox.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send reset email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DCC8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: _box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📧 EMAIL
                  _sectionTitle('Email'),
                  _infoRow('Official', email),
                  const Divider(),

                  // 📱 MOBILE NUMBER
                  _sectionTitle('Mobile Number'),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '+60 12 345 6789',
                    ),
                  ),
                  const Divider(),

                  // 👤 NAME
                  _sectionTitle('Name'),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔐 USERNAME
                  _sectionTitle('Username'),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  // 🔒 CHANGE PASSWORD BUTTON
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Change Password'),
                            content: const Text(
                              'A password reset link will be sent to your email. Continue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _changePassword();
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE6DCC8),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 💾 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD9B26F),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= HELPERS =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      );
}
