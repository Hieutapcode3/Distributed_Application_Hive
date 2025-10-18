import 'package:distributed_application_hive/app/web_socket.dart';
import 'package:distributed_application_hive/features/auth/data/auth_service.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/view/global_chat_screen.dart';
import 'package:distributed_application_hive/features/chat/view/private_chat_screen.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
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

  // Helper function để format thời gian
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Helper function để lấy tin nhắn gần nhất giữa 2 user
  MessageModel? _getLatestMessage(String currentUserId, String otherUserId) {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messages = messageBox.values.where((message) {
      // Lấy tin nhắn giữa 2 user (không phải global chat)
      return message.roomId != 'global' &&
          ((message.senderId == currentUserId &&
                  message.roomId.contains(otherUserId)) ||
              (message.senderId == otherUserId &&
                  message.roomId.contains(currentUserId)));
    }).toList();

    if (messages.isEmpty) return null;

    // Sắp xếp theo thời gian và lấy tin nhắn mới nhất
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  // Helper function để đếm tin nhắn chưa đọc
  int _getUnreadCount(String currentUserId, String otherUserId) {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messages = messageBox.values.where((message) {
      return message.roomId != 'global' &&
          message.senderId == otherUserId &&
          message.roomId.contains(currentUserId);
    }).toList();

    // Tạm thời trả về số random để demo (sau này có thể lưu trạng thái đã đọc)
    return messages.length > 0 ? (messages.length % 5) + 1 : 0;
  }

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
            child: const Icon(
              Icons.search,
              color: Color.fromARGB(180, 255, 255, 255),
              size: 24,
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
                  ValueListenableBuilder(
                    valueListenable: Hive.box<UserModel>(
                      'userBox',
                    ).listenable(),
                    builder: (context, Box<UserModel> box, _) {
                      final users = box.values.toList();
                      for (final u in users) {
                        print("🧑 User: ${u.uid} - ${u.name}");
                      }

                      if (users.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Chưa có người dùng nào khác.',
                              style: TextStyle(color: Colors.white),
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            user.profilePictureUrl != null
                                            ? NetworkImage(
                                                user.profilePictureUrl!,
                                              )
                                            : const AssetImage(
                                                    'assets/image/mtp.jpg',
                                                  )
                                                  as ImageProvider,
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
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.name.split(' ').first,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Caros',
                                    ),
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
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box<MessageModel>(
                                  'messageBox',
                                ).listenable(),
                                builder: (context, Box<MessageModel> messageBox, _) {
                                  final userBox = Hive.box<UserModel>(
                                    'userBox',
                                  );
                                  final allUsers = userBox.values.toList();

                                  // Lọc bỏ chính mình khỏi danh sách user
                                  final otherUsers = allUsers
                                      .where((u) => u.uid != currentUser!.uid)
                                      .toList();

                                  return ListView(
                                    children: [
                                      // 🔸 Global Chat (nhóm chung)
                                      ListTile(
                                        leading: const CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blueAccent,
                                          child: Icon(
                                            Icons.public,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: const Text(
                                          "🌍 Global Chat",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Circular Std',
                                          ),
                                        ),
                                        subtitle: const Text(
                                          "Nhắn tin với tất cả mọi người",
                                          style: TextStyle(
                                            fontFamily: 'Circular Std',
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GlobalChatScreen(
                                                currentUser: currentUser!,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      const Divider(),

                                      // 🔸 Danh sách user khác (chat 1-1)
                                      if (otherUsers.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              "Chưa có người dùng nào khác",
                                            ),
                                          ),
                                        )
                                      else
                                        ...otherUsers.map((user) {
                                          final latestMessage =
                                              _getLatestMessage(
                                                currentUser!.uid,
                                                user.uid,
                                              );
                                          final unreadCount = _getUnreadCount(
                                            currentUser!.uid,
                                            user.uid,
                                          );

                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage:
                                                  user.profilePictureUrl != null
                                                  ? NetworkImage(
                                                      user.profilePictureUrl!,
                                                    )
                                                  : const AssetImage(
                                                          'assets/image/mtp.jpg',
                                                        )
                                                        as ImageProvider,
                                              radius: 25,
                                            ),
                                            title: Text(
                                              user.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Caros',
                                                fontSize: 18,
                                              ),
                                            ),
                                            subtitle: Text(
                                              latestMessage?.content ??
                                                  "No messages yet",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  latestMessage != null
                                                      ? _formatTimeAgo(
                                                          latestMessage
                                                              .timestamp,
                                                        )
                                                      : "",
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 14,
                                                    fontFamily: 'Circular Std',
                                                  ),
                                                ),
                                                if (unreadCount > 0) ...[
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      unreadCount.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'Circular Std',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PrivateChatScreen(
                                                        currentUser:
                                                            currentUser!,
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
