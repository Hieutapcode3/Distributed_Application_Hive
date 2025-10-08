import 'package:distributed_application_hive/features/auth/data/auth_service.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  UserModel? currentUser;
  final authServiceProvider = Provider<AuthService>((ref) => AuthService());

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final box = await Hive.openBox<UserModel>('userBox');
    setState(() {
      currentUser = box.get('user');
    });
  }

  Future<void> _signOut() async {
    final auth = ref.read(authServiceProvider);
    await auth.signOut();

    // Quay về màn hình login
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Chatbox Dashboard',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _signOut,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Center(
        child: currentUser == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${currentUser!.name}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(currentUser!.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
      ),
    );
  }
}
