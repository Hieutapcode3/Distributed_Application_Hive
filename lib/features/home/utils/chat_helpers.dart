import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';

class ChatHelpers {
  // Helper function để format thời gian
  static String formatTimeAgo(DateTime timestamp) {
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
  static MessageModel? getLatestMessage(
    String currentUserId,
    String otherUserId,
  ) {
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
  static int getUnreadCount(String currentUserId, String otherUserId) {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messages = messageBox.values.where((message) {
      return message.roomId != 'global' &&
          message.senderId == otherUserId &&
          message.roomId.contains(currentUserId);
    }).toList();

    // Tạm thời trả về số random để demo (sau này có thể lưu trạng thái đã đọc)
    return messages.length > 0 ? (messages.length % 5) + 1 : 0;
  }

  // Helper function để xóa tất cả tin nhắn giữa 2 user
  static void deleteChatWithUser(String currentUserId, String otherUserId) {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messagesToDelete = messageBox.values.where((message) {
      return message.roomId != 'global' &&
          ((message.senderId == currentUserId &&
                  message.roomId.contains(otherUserId)) ||
              (message.senderId == otherUserId &&
                  message.roomId.contains(currentUserId)));
    }).toList();

    // Xóa từng tin nhắn
    for (final message in messagesToDelete) {
      messageBox.delete(message.id);
    }
  }

  // Helper function để lấy tin nhắn mới nhất của global chat
  static MessageModel? getLatestGlobalMessage() {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messages = messageBox.values.where((message) {
      return message.roomId == 'global';
    }).toList();

    if (messages.isEmpty) return null;

    // Sắp xếp theo thời gian và lấy tin nhắn mới nhất
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  // Helper function để xử lý notice
  static void handleNotice(BuildContext context, String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Đã bật thông báo cho $userName",
          style: const TextStyle(fontFamily: 'Circular Std'),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
