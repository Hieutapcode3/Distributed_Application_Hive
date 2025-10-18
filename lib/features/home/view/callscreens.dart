import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import '../models/call_type.dart';
import '../widgets/call_item.dart';
import '../widgets/calls_app_bar.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CallsAppBar(),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Container bo góc trên - nền trắng
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<UserModel>('userBox').listenable(),
                  builder: (context, Box<UserModel> box, _) {
                    final users = box.values.toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề "Recent"
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              top: 8,
                            ),
                            child: Text(
                              "Recent",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Caros',
                              ),
                            ),
                          ),

                          // Danh sách cuộc gọi
                          Expanded(
                            child: ListView(
                              children: [
                                // Cuộc gọi nhỡ
                                CallItem(
                                  name: "Sabila Sayma",
                                  time: "Yesterday, 07:35 PM",
                                  callType: CallType.missed,
                                  avatar: "assets/image/mtp.jpg",
                                  user: users.firstWhere(
                                    (u) => u.name == "Sabila Sayma",
                                    orElse: () => UserModel(
                                      uid: '',
                                      name: "Sabila Sayma",
                                      email: '',
                                      isOnline: true,
                                    ),
                                  ),
                                ),

                                const Divider(),
                                // Cuộc gọi đi
                                CallItem(
                                  name: "Alex Linderson",
                                  time: "Monday, 09:30 AM",
                                  callType: CallType.outgoing,
                                  avatar: "assets/image/mtp.jpg",
                                  user: users.firstWhere(
                                    (u) => u.name == "Alex Linderson",
                                    orElse: () => UserModel(
                                      uid: '',
                                      name: "Alex Linderson",
                                      email: '',
                                      isOnline: false,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                // Cuộc gọi đi
                                CallItem(
                                  name: "Dang Vu",
                                  time: "Tuesday, 10:30 AM",
                                  callType: CallType.incoming,
                                  avatar: "assets/image/mtp.jpg",
                                  user: users.firstWhere(
                                    (u) => u.name == "Dang Vu",
                                    orElse: () => UserModel(
                                      uid: '',
                                      name: "Dang Vu",
                                      email: '',
                                      isOnline: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
