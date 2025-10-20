import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/features/home/widgets/avatar_with_online_status.dart';

class UserAvatarList extends StatelessWidget {
  const UserAvatarList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserModel>('userBox').listenable(),
      builder: (context, Box<UserModel> box, _) {
        final users = box.values.toList();

        if (users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Chưa có người dùng nào khác.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    AvatarWithOnlineStatus(
                      user: user,
                      radius: 30,
                      showOnlineStatus: true,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.name.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Caros',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
