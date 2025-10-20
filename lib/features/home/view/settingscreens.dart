import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import '../models/setting_item.dart';
import '../widgets/user_profile_section.dart';
import '../widgets/setting_item_widget.dart';
import '../widgets/settings_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<SettingItem> _settingItems = [
    SettingItem(
      title: "Account",
      subtitle: "Privacy, security, change number",
      iconPath: "key",
      onTap: null,
    ),
    SettingItem(
      title: "Chat",
      subtitle: "Chat history, theme, wallpapers",
      iconPath: "chat",
      onTap: null,
    ),
    SettingItem(
      title: "Notifications",
      subtitle: "Messages, group and others",
      iconPath: "notifications",
      onTap: null,
    ),
    SettingItem(
      title: "Help",
      subtitle: "Help center, contact us, privacy policy",
      iconPath: "help",
      onTap: null,
    ),
    SettingItem(
      title: "Storage and data",
      subtitle: "Network usage, storage usage",
      iconPath: "storage",
      onTap: null,
    ),
    SettingItem(
      title: "Invite a friend",
      subtitle: "",
      iconPath: "invite",
      onTap: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const SettingsAppBar(),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                  valueListenable: Hive.box<UserModel>(
                    'currentUserBox',
                  ).listenable(),
                  builder: (context, Box<UserModel> box, _) {
                    final currentUser = box.values.isNotEmpty
                        ? box.values.first
                        : null;
                    final userName = currentUser?.name ?? "User";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // User info
                          UserProfileSection(
                            name: userName,
                            status: "Never give up",
                            avatar: "assets/image/mtp.jpg",
                            emoji: "💪",
                          ),
                          const Divider(
                            height: 1,
                            color: Color.fromARGB(49, 158, 158, 158),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: _settingItems.map((item) {
                                  return SettingItemWidget(
                                    settingItem: SettingItem(
                                      title: item.title,
                                      subtitle: item.subtitle,
                                      iconPath: item.iconPath,
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${item.title} tapped!',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
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
