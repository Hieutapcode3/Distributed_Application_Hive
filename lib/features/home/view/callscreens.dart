import 'package:flutter/material.dart';
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề "Recent"
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 16, top: 8),
                        child: Text(
                          "Recent",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            // color: Colors.blue,
                            fontFamily: 'Caros',
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // Danh sách cuộc gọi
                      Expanded(
                        child: ListView(
                          children: [
                            // Cuộc gọi nhỡ
                            const CallItem(
                              name: "Sabila Sayma",
                              time: "Yesterday, 07:35 PM",
                              callType: CallType.missed,
                              avatar: "assets/image/mtp.jpg",
                            ),

                            const Divider(),
                            // Cuộc gọi đi
                            const CallItem(
                              name: "Alex Linderson",
                              time: "Monday, 09:30 AM",
                              callType: CallType.outgoing,
                              avatar: "assets/image/mtp.jpg",
                            ),
                            const Divider(),
                            // Cuộc gọi đi
                            const CallItem(
                              name: "Dang Vu",
                              time: "Tuesday, 10:30 AM",
                              callType: CallType.incoming,
                              avatar: "assets/image/mtp.jpg",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
