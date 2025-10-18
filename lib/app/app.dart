import 'package:distributed_application_hive/features/auth/view/onboarding.dart';
import 'package:distributed_application_hive/features/home/view/mainscreens.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData.light(),
      home: MainScreen(),
    );
  }
}
