  import 'package:distributed_application_hive/app/web_socket.dart';
  import 'package:distributed_application_hive/features/auth/data/auth_service.dart';
  import 'package:distributed_application_hive/features/auth/data/user_model.dart';
  import 'package:distributed_application_hive/features/home/widgets/user_avatar_list.dart';
  import 'package:distributed_application_hive/features/home/widgets/chat_list.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:hive_flutter/hive_flutter.dart';

  class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _DashboardScreenState();
  }

  class _DashboardScreenState extends ConsumerState<HomeScreen> {
    UserModel? currentUser;
    final authServiceProvider = Provider<AuthService>((ref) => AuthService());
    late WebSocketService wsService;
    late Box<UserModel> userBox;

    @override
    void initState() {
      super.initState();
      _initData();
    }

    Future<void> _initData() async {
      final currentBox = await Hive.openBox<UserModel>('currentUserBox');
      setState(() {
        currentUser = currentBox.get(currentBox.keys.first);
      });

      // 🔹 Mở box chứa tất cả user
    userBox = await Hive.openBox<UserModel>('userBox');

    // 🔹 In thông tin tất cả user ra console
    print('========== DANH SÁCH NGƯỜI DÙNG ==========');
    for (var user in userBox.values) {
      print('UID: ${user.uid}');
      print('Tên: ${user.name}');
      print('Email: ${user.email}');
      print('Ảnh đại diện: ${user.profilePictureUrl}');
      print('Trạng thái online: ${user.isOnline}');
      print('------------------------------------------');
    }

      // 🔹 Nếu đã có currentUser, kết nối WebSocket
      if (currentUser != null) {
        wsService = WebSocketService();
        wsService.connect(currentUser!);

        // Đánh dấu user hiện tại là online
        wsService.setUserOnline(currentUser!.uid);
      }
    }

    Future<void> _signOut() async {
      // Đánh dấu user offline trước khi đăng xuất
      if (currentUser != null) {
        wsService.setUserOffline(currentUser!.uid);
      }

      final auth = ref.read(authServiceProvider);
      await auth.signOut();
      if (mounted) {
        Navigator.pop(context);
      }
    }

    @override
    void dispose() {
      // Đánh dấu user offline khi thoát màn hình
      if (currentUser != null) {
        wsService.setUserOffline(currentUser!.uid);
      }
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Caros',
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(180, 255, 255, 255),
                  width: 1,
                ),
              ),
              child: Image.asset(
                'assets/image/Search.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Search tapped!')));
            },
          ),
          actions: [
            GestureDetector(
              onTap: _signOut,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.logout, color: Colors.white),
              ),
            ),
          ],
        ),
        body: currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.black,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 🔹 Hàng avatar người dùng (giống Messenger)
                    const UserAvatarList(),

                    const SizedBox(height: 10),

                    // 🔹 Container bo góc trên - nền trắng
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Text(
                              //   "Đoạn chat",
                              //   style: TextStyle(
                              //     fontSize: 22,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black87,
                              //     fontFamily: 'Circular Std',
                              //   ),
                              // ),
                              const SizedBox(height: 16),

                              // 🔹 Danh sách chat (Global + User)
                              Expanded(
                                child: ChatList(currentUser: currentUser!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    }
  }
