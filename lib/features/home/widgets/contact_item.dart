import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;

  const ContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(contact.avatar),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped on ${contact.name}')));
      },
    );
  }
}
