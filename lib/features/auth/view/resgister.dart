import 'package:distributed_application_hive/features/auth/data/auth_service.dart';
import 'package:distributed_application_hive/features/auth/view/login.dart';
import 'package:distributed_application_hive/features/auth/view/resgister.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

class ResgisterScreen extends ConsumerStatefulWidget {
  const ResgisterScreen({super.key});

  @override
  ConsumerState<ResgisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<ResgisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isPasswordVisible = false;
  final authServiceProvider = Provider<AuthService>((ref) => AuthService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chatbox',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign up with Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get chatting with friends and family today by signing up for our chat app!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Social login buttons
                SignInButton(Buttons.google, onPressed: () {
                }),
                SignInButton(Buttons.facebook, onPressed: () {}),
                const SizedBox(height: 22),

                // OR divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 22),

                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email input
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password input
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final auth = ref.read(authServiceProvider);
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      final name = nameController.text.trim();

                      try{
                        auth.registerWithEmail(
                          email: email,
                          password: password,
                          name: name,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration successful! Please log in.')),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registration failed: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Have an account? ', style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: const Text('Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
