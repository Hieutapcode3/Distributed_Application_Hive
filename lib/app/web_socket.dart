import 'dart:convert';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:hive/hive.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? channel;

  Future<void> connect(UserModel currentUser) async {
    if (channel != null) return;

    final userBox = Hive.isBoxOpen('userBox')
        ? Hive.box<UserModel>('userBox')
        : await Hive.openBox<UserModel>('userBox');

    final messageBox = Hive.isBoxOpen('messageBox')
        ? Hive.box<MessageModel>('messageBox')
        : await Hive.openBox<MessageModel>('messageBox');

    channel = IOWebSocketChannel.connect('wss://chat-server-wlv5.onrender.com');

    // Gửi connect
    channel!.sink.add(jsonEncode({'type': 'connect', 'user': currentUser.toJson()}));

    channel!.stream.listen((message) async {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'init_users':
          // Đồng bộ toàn bộ user từ Redis
          for (var u in data['users']) {
            userBox.put(u['uid'], UserModel.fromJson(u));
          }
          break;

        case 'new_user':
          userBox.put(data['user']['uid'], UserModel.fromJson(data['user']));
          break;

        case 'user_online':
          final uid = data['uid'];
          // Nếu là chính mình, update luôn local
          final user = userBox.get(uid);
          if (user != null) {
            final updatedUser = user.copyWith(isOnline: true);
            await userBox.put(uid, updatedUser);
            print('${updatedUser.name} vừa online');
          } else {
            print('User $uid chưa có trong Hive khi nhận user_online');
          }
          break;

        case 'user_offline':
          final uid = data['uid'];
          final user = userBox.get(uid);
          if (user != null) {
            final updatedUser = user.copyWith(isOnline: false);
            await userBox.put(uid, updatedUser);
            print('${updatedUser.name} vừa offline');
          }
          break;

        case 'message':
          messageBox.put(data['message']['id'], MessageModel.fromJson(data['message']));
          break;

        case 'message_update':
          messageBox.put(data['message']['id'], MessageModel.fromJson(data['message']));
          break;

        case 'message_delete':
          messageBox.delete(data['messageId']);
          break;

        case 'sync_messages':
          for (var m in data['messages']) {
            messageBox.put(m['id'], MessageModel.fromJson(m));
          }
          break;
      }
    });

    // Cập nhật trạng thái online của chính mình ngay
    final localUser = userBox.get(currentUser.uid);
    if (localUser != null) {
      final updatedUser = localUser.copyWith(isOnline: true);
      await userBox.put(currentUser.uid, updatedUser);
    } else {
      await userBox.put(currentUser.uid, currentUser.copyWith(isOnline: true));
    }
  }

  // Gửi tin nhắn
  void sendMessage(MessageModel message) {
    if (channel == null) return;
    channel!.sink.add(jsonEncode({'type': 'message', 'message': message.toJson()}));
  }

  void updateMessage(MessageModel message) {
    if (channel == null) return;
    channel!.sink.add(jsonEncode({'type': 'message_update', 'message': message.toJson()}));
  }

  void deleteMessage(String messageId) {
    if (channel == null) return;
    channel!.sink.add(jsonEncode({'type': 'message_delete', 'messageId': messageId}));
  }

  void requestMessageSync(String userId) {
    if (channel == null) return;
    channel!.sink.add(jsonEncode({'type': 'sync_messages', 'userId': userId}));
  }

  void setUserOnline(String uid) {
    if (channel == null) return;
    // Gửi trực tiếp cho server, server sẽ broadcast cho tất cả (bao gồm chính mình)
    channel!.sink.add(jsonEncode({'type': 'user_online', 'uid': uid}));
  }

  void setUserOffline(String uid) {
    if (channel == null) return;
    channel!.sink.add(jsonEncode({'type': 'user_offline', 'uid': uid}));
  }

  void close() {
    channel?.sink.close();
    channel = null;
  }
}
