import 'package:flutter/material.dart';
import '../models/call_type.dart';
import 'avatar_with_online_status.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';

class CallItem extends StatelessWidget {
  final String name;
  final String time;
  final CallType callType;
  final String avatar;
  final UserModel? user;

  const CallItem({
    super.key,
    required this.name,
    required this.time,
    required this.callType,
    required this.avatar,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    String callIconPath;
    Color callColor;

    switch (callType) {
      case CallType.missed:
        callIconPath = 'assets/image/call_missed.png';
        callColor = Colors.red;
        break;
      case CallType.outgoing:
        callIconPath = 'assets/image/outgoing_call.png';
        callColor = Colors.purple;
        break;
      case CallType.incoming:
        callIconPath = 'assets/image/incoming_call.png';
        callColor = Colors.green;
        break;
    }

    return ListTile(
      leading: AvatarWithOnlineStatus(
        user: user,
        radius: 25,
        showOnlineStatus: true,
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Caros',
          fontSize: 18,
        ),
      ),
      subtitle: Row(
        children: [
          Image.asset(callIconPath, width: 16, height: 16, color: callColor),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Circular Std',
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Image.asset(
              'assets/image/call_back.png',
              width: 24,
              height: 24,
              color: Colors.grey[600],
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Calling $name...')));
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/image/video.png',
              width: 24,
              height: 24,
              color: Colors.grey[600],
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Video calling $name...')));
            },
          ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped on $name')));
      },
    );
  }
}
