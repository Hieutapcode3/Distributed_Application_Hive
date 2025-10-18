import 'package:flutter/material.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/view/private_chat_screen.dart';
import 'package:distributed_application_hive/features/home/utils/chat_helpers.dart';

class ChatListItem extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;

  const ChatListItem({
    super.key,
    required this.user,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final latestMessage = ChatHelpers.getLatestMessage(
      currentUser.uid,
      user.uid,
    );
    final unreadCount = ChatHelpers.getUnreadCount(currentUser.uid, user.uid);

    return Dismissible(
      key: Key(user.uid),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.white,
        child: Row(
          children: [
            // Phần trống để tạo hiệu ứng liền
            Expanded(child: Container(color: Colors.white)),
            // Phần chứa nút
            Container(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút Notice
                  GestureDetector(
                    onTap: () {
                      ChatHelpers.handleNotice(context, user.name);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      child: Image.asset(
                        'assets/image/notification.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút Trash
                  GestureDetector(
                    onTap: () async {
                      final shouldDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Xóa cuộc trò chuyện",
                              style: TextStyle(fontFamily: 'Caros'),
                            ),
                            content: Text(
                              "Bạn có chắc chắn muốn xóa cuộc trò chuyện với ${user.name}?",
                              style: const TextStyle(
                                fontFamily: 'Circular Std',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  "Hủy",
                                  style: TextStyle(
                                    fontFamily: 'Circular Std',
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  "Xóa",
                                  style: TextStyle(
                                    fontFamily: 'Circular Std',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        ChatHelpers.deleteChatWithUser(
                          currentUser.uid,
                          user.uid,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Đã xóa cuộc trò chuyện với ${user.name}",
                              style: const TextStyle(
                                fontFamily: 'Circular Std',
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      child: Image.asset(
                        'assets/image/Trash.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return false; // Không tự động dismiss
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profilePictureUrl != null
              ? NetworkImage(user.profilePictureUrl!)
              : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
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
          latestMessage?.content ?? "No messages yet",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Circular Std',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              latestMessage != null
                  ? ChatHelpers.formatTimeAgo(latestMessage.timestamp)
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
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Circular Std',
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
                  PrivateChatScreen(currentUser: currentUser, receiver: user),
            ),
          );
        },
      ),
    );
  }
}
