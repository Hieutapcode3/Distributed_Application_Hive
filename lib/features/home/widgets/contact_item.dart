import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'avatar_with_online_status.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  final UserModel? user;

  const ContactItem({super.key, required this.contact, this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AvatarWithOnlineStatus(
        user: user,
        radius: 25,
        showOnlineStatus: true,
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Caros',
          fontSize: 18,
        ),
      ),
      subtitle: Row(
        children: [
          Text(contact.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            contact.status,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Circular Std',
            ),
          ),
        ],
      ),
      onTap: () {
        // TODO: Implement contact item tap functionality
      },
    );
  }
}
