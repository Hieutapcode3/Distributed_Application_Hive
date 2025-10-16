import 'package:distributed_application_hive/app/web_socket.dart';
import 'package:distributed_application_hive/features/auth/data/auth_service.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/view/global_chat_screen.dart';
import 'package:distributed_application_hive/features/chat/view/private_chat_screen.dart';
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

    // 🔹 Nếu đã có currentUser, kết nối WebSocket
    if (currentUser != null) {
      wsService = WebSocketService();
      wsService.connect(currentUser!);
    }
  }

  Future<void> _signOut() async {
    final auth = ref.read(authServiceProvider);

    await auth.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search tapped!')));
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
                  ValueListenableBuilder(
                    valueListenable: Hive.box<UserModel>('userBox').listenable(),
                    builder: (context, Box<UserModel> box, _) {
                      final users = box.values.toList();
                      for (final u in users) {
                        print("🧑 User: ${u.uid} - ${u.name}");
                      }

                      if (users.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('Chưa có người dùng nào khác.', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: user.profilePictureUrl != null
                                            ? NetworkImage(user.profilePictureUrl!)
                                            : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.black, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.name.split(' ').first,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Container bo góc trên - nền trắng
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Đoạn chat",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Danh sách chat (Global + User)
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box<UserModel>('userBox').listenable(),
                                builder: (context, Box<UserModel> box, _) {
                                  final allUsers = box.values.toList();

                                  // Lọc bỏ chính mình khỏi danh sách user
                                  final otherUsers = allUsers.where((u) => u.uid != currentUser!.uid).toList();

                                  return ListView(
                                    children: [
                                      // 🔸 Global Chat (nhóm chung)
                                      ListTile(
                                        leading: const CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blueAccent,
                                          child: Icon(Icons.public, color: Colors.white),
                                        ),
                                        title: const Text(
                                          "🌍 Global Chat",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: const Text("Nhắn tin với tất cả mọi người"),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GlobalChatScreen(currentUser: currentUser!),
                                            ),
                                          );
                                        },
                                      ),

                                      const Divider(),

                                      // 🔸 Danh sách user khác (chat 1-1)
                                      if (otherUsers.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Center(child: Text("Chưa có người dùng nào khác")),
                                        )
                                      else
                                        ...otherUsers.map((user) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: user.profilePictureUrl != null
                                                  ? NetworkImage(user.profilePictureUrl!)
                                                  : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
                                              radius: 25,
                                            ),
                                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: const Text("Nhấn để nhắn tin riêng"),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PrivateChatScreen(
                                                    currentUser: currentUser!,
                                                    receiver: user,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                    ],
                                  );
                                },
                              ),
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
