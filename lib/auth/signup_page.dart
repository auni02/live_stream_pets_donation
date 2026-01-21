import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> signUp() async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      // 1️⃣ Register user
      final user = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        throw Exception("User creation failed");
      }

      // 2️⃣ Create Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'name': 'New User',
        'username': 'username',
        'phone': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      // 3️⃣ Go back to login (AuthWrapper will handle routing)
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DCC6),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "Sign Up",
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "email@gmail.com",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "password",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "confirm password",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD8B26E),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
