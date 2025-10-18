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
  // Dữ liệu mẫu cho các mục cài đặt
  static const List<SettingItem> _settingItems = [
    SettingItem(
      title: "Account",
      subtitle: "Privacy, security, change number",
      iconPath: "key",
      onTap: null, // Sẽ được xử lý trong widget
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
      body: Stack(
        children: [
          // Background
          Container(color: Colors.black, child: const SizedBox(height: 30)),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.975,
            minChildSize: 0.975, // Không thể kéo xuống dưới 0.975
            maxChildSize: 1, // Chỉ có thể kéo lên đến full screen
            snap: true, // Snap về các mức cố định
            snapSizes: const [0.975, 1.0], // Chỉ có 2 mức: 0.975 và 1.0
            builder: (context, scrollController) {
              return Container(
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
                    final currentUsers = box.values.toList();
                    final currentUser = currentUsers.isNotEmpty
                        ? currentUsers.first
                        : null;
                    final userName = currentUser?.name ?? "User";

                    return Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Profile Section
                        UserProfileSection(
                          name: userName,
                          status: "Never give up",
                          avatar: "assets/image/mtp.jpg",
                          emoji: "💪",
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          color: Color.fromARGB(49, 158, 158, 158),
                        ),

                        // Settings List với SingleChildScrollView
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            child: Column(
                              children: _settingItems.map((settingItem) {
                                return SettingItemWidget(
                                  settingItem: SettingItem(
                                    title: settingItem.title,
                                    subtitle: settingItem.subtitle,
                                    iconPath: settingItem.iconPath,
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${settingItem.title} tapped!',
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
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
