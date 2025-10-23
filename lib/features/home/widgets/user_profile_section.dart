import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  final String name;
  final String status;
  final String avatar;
  final String emoji;
  final String email;

  const UserProfileSection({
    super.key,
    required this.name,
    required this.status,
    required this.avatar,
    required this.emoji,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(radius: 30, backgroundImage: AssetImage(avatar)),
          const SizedBox(width: 16),
          // Thông tin user
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Caros',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Circular Std',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Circular Std',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // QR Code image (không có vòng tròn bao quanh)
          Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/image/Qr_code.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
