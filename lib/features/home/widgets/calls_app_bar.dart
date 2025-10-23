import 'package:flutter/material.dart';

class CallsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CallsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Calls',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Caros',
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(180, 255, 255, 255),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/image/Search.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // TODO: Implement search functionality
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(180, 255, 255, 255),
                width: 1,
              ),
            ),
            child: Image.asset(
              'assets/image/call_user.png',
              width: 24,
              height: 24,
            ),
          ),
          onPressed: () {
            // TODO: Implement add call functionality
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
