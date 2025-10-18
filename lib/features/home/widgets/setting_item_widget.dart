import 'package:flutter/material.dart';
import '../models/setting_item.dart';

class SettingItemWidget extends StatelessWidget {
  final SettingItem settingItem;

  const SettingItemWidget({super.key, required this.settingItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // border: Border.all(color: Colors.grey),
          color: const Color.fromARGB(38, 158, 158, 158),
        ),
        child: Image.asset(_getImagePath(settingItem.iconPath)),
      ),
      title: Text(
        settingItem.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Caros',
        ),
      ),
      subtitle: Text(
        settingItem.subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontFamily: 'Circular Std',
        ),
      ),
      onTap: settingItem.onTap,
    );
  }

  String _getImagePath(String iconPath) {
    switch (iconPath) {
      case 'key':
        return 'assets/image/account.png';
      case 'chat':
        return 'assets/image/message.jpg';
      case 'notifications':
        return 'assets/image/Notification.png';
      case 'help':
        return 'assets/image/Help.png';
      case 'storage':
        return 'assets/image/Data.png';
      case 'invite':
        return 'assets/image/Users.png';
      default:
        return 'assets/image/settings.jpg';
    }
  }
}
