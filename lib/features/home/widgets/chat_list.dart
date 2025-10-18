import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:distributed_application_hive/features/chat/view/global_chat_screen.dart';
import 'package:distributed_application_hive/features/home/widgets/chat_list_item.dart';
import 'package:distributed_application_hive/features/home/utils/chat_helpers.dart';

class ChatList extends StatelessWidget {
  final UserModel currentUser;

  const ChatList({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<MessageModel>('messageBox').listenable(),
      builder: (context, Box<MessageModel> messageBox, _) {
        final userBox = Hive.box<UserModel>('userBox');
        final allUsers = userBox.values.toList();

        // Lọc bỏ chính mình khỏi danh sách user
        final otherUsers = allUsers
            .where((u) => u.uid != currentUser.uid)
            .toList();

        // Lấy tin nhắn mới nhất của global chat
        final latestGlobalMessage = ChatHelpers.getLatestGlobalMessage();

        return ListView(
          children: [
            // Global Chat (nhóm chung)
            ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.public, color: Colors.white),
              ),
              title: const Text(
                "🌍 Global Chat",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Circular Std',
                ),
              ),
              subtitle: Text(
                latestGlobalMessage != null
                    ? "${latestGlobalMessage.senderName}: ${latestGlobalMessage.content}"
                    : "Chưa có tin nhắn nào",
                style: TextStyle(
                  fontFamily: 'Circular Std',
                  color: latestGlobalMessage != null
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GlobalChatScreen(currentUser: currentUser),
                  ),
                );
              },
            ),

            const Divider(),

            // Danh sách user khác (chat 1-1)
            if (otherUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: Text("Chưa có người dùng nào khác")),
              )
            else
              ...otherUsers.map((user) {
                return ChatListItem(user: user, currentUser: currentUser);
              }).toList(),
          ],
        );
      },
    );
  }
}
