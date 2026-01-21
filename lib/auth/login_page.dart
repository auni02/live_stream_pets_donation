import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void login() async {
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // ✅ NO navigation here
      print("CURRENT USER AFTER LOGIN: ${FirebaseAuth.instance.currentUser}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login successful")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceAll('Exception:', ''),
        ),
      ),
    );
  }
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DCC6),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text(
              "Log In",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text("Forgot password"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD8B26E),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Log In"),
            ),

            TextButton(
              child: const Text("Sign up"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUpPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
