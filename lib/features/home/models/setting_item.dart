import 'package:flutter/material.dart';

class SettingItem {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback? onTap;

  const SettingItem({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    this.onTap,
  });
}
