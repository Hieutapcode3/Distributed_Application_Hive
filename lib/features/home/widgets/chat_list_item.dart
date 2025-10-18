import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/view/private_chat_screen.dart';
import 'package:distributed_application_hive/features/home/utils/chat_helpers.dart';

class ChatListItem extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;

  const ChatListItem({
    super.key,
    required this.user,
    required this.currentUser,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem>
    with TickerProviderStateMixin {
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  Widget build(BuildContext context) {
    final latestMessage = ChatHelpers.getLatestMessage(
      widget.currentUser.uid,
      widget.user.uid,
    );
    final unreadCount = ChatHelpers.getUnreadCount(
      widget.currentUser.uid,
      widget.user.uid,
    );

    return Slidable(
      key: Key(widget.user.uid),
      controller: _slidableController,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          // Nút Notice
          GestureDetector(
            onTap: () {
              ChatHelpers.handleNotice(context, widget.user.name);
              _slidableController.close();
            },
            child: Container(
              color: const Color(0xFFF1F6FA),
              child: Center(
                child: Image.asset(
                  'assets/image/notification_2.png',
                  width: 56,
                  height: 56,
                ),
              ),
            ),
          ),
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
                      "Bạn có chắc chắn muốn xóa cuộc trò chuyện với ${widget.user.name}?",
                      style: const TextStyle(fontFamily: 'Circular Std'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(
                            fontFamily: 'Circular Std',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
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

              // Đóng slideable sau khi dialog đóng
              _slidableController.close();

              if (shouldDelete == true) {
                ChatHelpers.deleteChatWithUser(
                  widget.currentUser.uid,
                  widget.user.uid,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Đã xóa cuộc trò chuyện với ${widget.user.name}",
                      style: const TextStyle(fontFamily: 'Circular Std'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              color: const Color(0xFFF1F6FA),
              child: Center(
                child: Image.asset(
                  'assets/image/Trash.png',
                  width: 56,
                  height: 56,
                ),
              ),
            ),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _slidableController.animation,
        builder: (context, child) {
          final animationValue = _slidableController.animation.value;
          final isSliding = animationValue > 0;

          return Container(
            color: isSliding ? const Color(0xFFF1F6FA) : Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.user.profilePictureUrl != null
                    ? NetworkImage(widget.user.profilePictureUrl!)
                    : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
                radius: 25,
              ),
              title: Text(
                widget.user.name,
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
                    builder: (_) => PrivateChatScreen(
                      currentUser: widget.currentUser,
                      receiver: widget.user,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
