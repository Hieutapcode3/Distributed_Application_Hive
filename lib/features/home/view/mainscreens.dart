import 'package:distributed_application_hive/features/home/view/callscreens.dart';
import 'package:distributed_application_hive/features/home/view/contacts_screen.dart';
import 'package:distributed_application_hive/features/home/view/home.dart';
import 'package:distributed_application_hive/features/home/view/settingscreens.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CallsScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/image/message.jpg',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/image/message_active.jpg',
              width: 24,
              height: 24,
            ),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/call.jpg', width: 24, height: 24),
            activeIcon: Image.asset(
              'assets/image/call_active.jpg',
              width: 24,
              height: 24,
            ),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/user.jpg', width: 24, height: 24),
            activeIcon: Image.asset(
              'assets/image/user_active.jpg',
              width: 24,
              height: 24,
            ),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/image/settings.jpg',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/image/setting_active.jpg',
              width: 24,
              height: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
