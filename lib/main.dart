import 'package:distributed_application_hive/app/app.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('userBox');
  runApp(const ProviderScope(child: MyApp()));
}