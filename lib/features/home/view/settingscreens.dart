import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  late Box<UserModel> userBox;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _initCurrentUser();
  }

  Future<void> _initCurrentUser() async {
    userBox = await Hive.openBox<UserModel>('userBox');
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    // Lấy currentUser từ userBox
    currentUser = userBox.get(firebaseUser.uid);
    if (currentUser == null) {
      currentUser = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        profilePictureUrl: firebaseUser.photoURL ?? '',
      );
      await userBox.put(currentUser!.uid, currentUser!);
    }
    setState(() {});
  }

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
                  valueListenable: Hive.box<UserModel>('userBox').listenable(),
                  builder: (context, Box<UserModel> box, _) {
                    // realtime cập nhật currentUser từ userBox
                    final firebaseUser = FirebaseAuth.instance.currentUser;
                    if (firebaseUser == null) return const SizedBox.shrink();
                    currentUser = box.get(firebaseUser.uid);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          UserProfileSection(
                            name: currentUser?.name ?? "User",
                            email: currentUser?.email ?? "",
                            status: "Never give up",
                            avatar: "assets/image/mtp.jpg",
                            emoji: "💪",
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _settingItems.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: Colors.grey),
                              itemBuilder: (context, index) {
                                final item = _settingItems[index];
                                return SettingItemWidget(
                                  settingItem: SettingItem(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    iconPath: item.iconPath,
                                    onTap: () {
                                      // TODO: Implement ${item.title} functionality
                                    },
                                  ),
                                );
                              },
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
