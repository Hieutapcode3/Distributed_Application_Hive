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

    channel!.sink.add(
      jsonEncode({'type': 'connect', 'user': currentUser.toJson()}),
    );

    channel!.stream.listen((message) {
      final data = jsonDecode(message);
      switch (data['type']) {
        case 'init':
          for (var u in data['users']) {
            userBox.put(u['uid'], UserModel.fromJson(u));
          }
          for (var m in data['messages']) {
            messageBox.put(m['id'], MessageModel.fromJson(m));
          }
          break;

        case 'new_user':
          userBox.put(data['user']['uid'], UserModel.fromJson(data['user']));
          break;

        case 'message':
          messageBox.put(
            data['message']['id'],
            MessageModel.fromJson(data['message']),
          );
          break;
      }
    });
  }

  void sendMessage(MessageModel message) {
    if (channel == null) return;
    channel!.sink.add(
      jsonEncode({'type': 'message', 'message': message.toJson()}),
    );
  }

  void close() {
    channel?.sink.close();
    channel = null;
  }
}
