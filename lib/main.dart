import 'package:distributed_application_hive/app/app.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/chat/data/chat_room_model.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:distributed_application_hive/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ChatRoomModelAdapter());

  // Xóa dữ liệu cũ để tránh conflict với cấu trúc mới
  try {
    await Hive.deleteBoxFromDisk('userBox');
    await Hive.deleteBoxFromDisk('currentUserBox');
    await Hive.deleteBoxFromDisk('messageBox');
    await Hive.deleteBoxFromDisk('chatRoomBox');
  } catch (e) {
    // Box có thể chưa tồn tại, bỏ qua lỗi
    print('Box chưa tồn tại hoặc đã được xóa: $e');
  }

  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<UserModel>('currentUserBox');
  await Hive.openBox<MessageModel>('messageBox');
  await Hive.openBox<ChatRoomModel>('chatRoomBox');
  runApp(const ProviderScope(child: MyApp()));
}
