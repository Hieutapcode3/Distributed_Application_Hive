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

    channel = IOWebSocketChannel.connect('wss://chat-server-00oc.onrender.com');

    channel!.sink.add(jsonEncode({'type': 'connect', 'user': currentUser.toJson()}));

    channel!.stream.listen((message) async {
      final data = jsonDecode(message);
      switch (data['type']) {
        case 'init':
          // Đồng bộ danh sách user
          for (var u in data['users']) {
            userBox.put(u['uid'], UserModel.fromJson(u));
          }
          // Đồng bộ tin nhắn
          for (var m in data['messages']) {
            messageBox.put(m['id'], MessageModel.fromJson(m));
          }
          break;

        case 'new_user':
          userBox.put(data['user']['uid'], UserModel.fromJson(data['user']));
          break;

        case 'user_online':
          final user = userBox.get(data['uid']);
          if (user == null) {
            print('User ${data['uid']} chưa có trong Hive khi nhận user_online');
          } else {
            final updatedUser = user.copyWith(isOnline: true);
            await userBox.put(data['uid'], updatedUser);
            print('${updatedUser.name} vừa online');
          }

          break;

        case 'user_offline':
          final user = userBox.get(data['uid']);
          if (user != null) {
            final updatedUser = user.copyWith(isOnline: false);
            await userBox.put(data['uid'], updatedUser);
            print('${updatedUser.name} vừa offline');
          }
          break;

        case 'message':
          // Đồng bộ tin nhắn mới
          messageBox.put(data['message']['id'], MessageModel.fromJson(data['message']));
          break;

        case 'message_update':
          // Cập nhật tin nhắn đã có
          messageBox.put(data['message']['id'], MessageModel.fromJson(data['message']));
          break;

        case 'message_delete':
          // Xóa tin nhắn
          messageBox.delete(data['messageId']);
          break;

        case 'sync_messages':
          // Đồng bộ nhiều tin nhắn cùng lúc
          for (var m in data['messages']) {
            messageBox.put(m['id'], MessageModel.fromJson(m));
          }
          break;
      }
    });
  }

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
