import 'package:distributed_application_hive/features/auth/view/login.dart';
import 'package:distributed_application_hive/features/auth/view/resgister.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Chatbox',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3a0ca3), // tím đậm
              Color(0xFF000000), // đen
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Connect friends',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'easily & quickly',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our chat app is the perfect way to stay connected with friends and family.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                SignInButton(
                  Buttons.google,
                  onPressed: () {
                    
                  },
                ),
                SignInButton(
                  Buttons.facebook,
                  onPressed: () {
                    // Handle Google sign-in
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.white70, // màu đường kẻ
                        thickness: 1, // độ dày
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white70, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ResgisterScreen();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(350, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Sign up with Email'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
