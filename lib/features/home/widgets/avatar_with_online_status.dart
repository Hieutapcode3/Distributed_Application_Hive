import 'package:flutter/material.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';

class AvatarWithOnlineStatus extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final bool showOnlineStatus;

  const AvatarWithOnlineStatus({
    super.key,
    this.user,
    this.radius = 25,
    this.showOnlineStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = user?.isOnline ?? false;

    if (showOnlineStatus && isOnline) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: user?.profilePictureUrl != null
                ? NetworkImage(user!.profilePictureUrl!)
                : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundImage: user?.profilePictureUrl != null
            ? NetworkImage(user!.profilePictureUrl!)
            : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
      );
    }
  }
}
