import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';

class ChatHelpers {
  // Helper function để format thời gian với AM/PM
  static String formatTimeWithAMPM(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Helper function để format ngày
  static String formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format: "Dec 25, 2023" hoặc "25/12/2023"
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  // Helper function để kiểm tra xem có cần hiển thị ngày không
  static bool shouldShowDateHeader(
    DateTime currentMessage,
    DateTime? previousMessage,
  ) {
    if (previousMessage == null) return true;

    final currentDate = DateTime(
      currentMessage.year,
      currentMessage.month,
      currentMessage.day,
    );
    final previousDate = DateTime(
      previousMessage.year,
      previousMessage.month,
      previousMessage.day,
    );

    return currentDate != previousDate;
  }

  // Helper function để format thời gian (giữ nguyên cho chat list)
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

  //  Lấy tin nhắn mới nhất (1:1 hoặc nhóm)
  static MessageModel? getLatestMessage(String currentUserId, String otherId) {
    final messageBox = Hive.box<MessageModel>('messageBox');

    final messages = messageBox.values.where((message) {
      if (!message.isGroup) {
        return (message.senderId == currentUserId && message.receiverId == otherId) ||
            (message.senderId == otherId && message.receiverId == currentUserId);
      }

      return message.isGroup && message.roomId == otherId;
    }).toList();

    if (messages.isEmpty) return null;

    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  // Đếm số tin nhắn chưa đọc
  static int getUnreadCount(String currentUserId, String targetId, {bool isGroup = false}) {
    final messageBox = Hive.box<MessageModel>('messageBox');

    final messages = messageBox.values.where((message) {
      if (isGroup) {
        // Tin nhắn nhóm: user chưa xem
        return message.isGroup && message.roomId == targetId && message.senderId != currentUserId;
      } else {
        // Chat 1:1
        return !message.isGroup && message.receiverId == currentUserId && message.senderId == targetId;
      }
    }).toList();

    return messages.length > 0 ? (messages.length % 5) + 1 : 0;
  }

  //  Xóa toàn bộ tin nhắn giữa 2 user (1:1)
  static void deleteChatWithUser(String currentUserId, String otherUserId) {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messagesToDelete = messageBox.values.where((message) {
      return !message.isGroup &&
          ((message.senderId == currentUserId && message.receiverId == otherUserId) ||
              (message.senderId == otherUserId && message.receiverId == currentUserId));
    }).toList();

    for (final message in messagesToDelete) {
      messageBox.delete(message.id);
    }
  }

  //  Lấy tin nhắn mới nhất trong global chat
  static MessageModel? getLatestGlobalMessage() {
    final messageBox = Hive.box<MessageModel>('messageBox');
    final messages = messageBox.values.where((message) => message.roomId == 'global').toList();

    if (messages.isEmpty) return null;

    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  // Helper function để xử lý notice
  static void handleNotice(BuildContext context, String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã bật thông báo cho $userName", style: const TextStyle(fontFamily: 'Circular Std')),
        backgroundColor: Colors.green,
      ),
    );
  }
}
