import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../widgets/contact_item.dart';
import '../widgets/contacts_app_bar.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  // Dữ liệu mẫu cho danh bạ
  static const List<Contact> _contacts = [
    Contact(
      name: "Afrin Sabila",
      status: "Life is beautiful",
      avatar: "assets/image/mtp.jpg",
      emoji: "👍",
    ),
    Contact(
      name: "Adil Adnan",
      status: "Be your own hero",
      avatar: "assets/image/mtp.jpg",
      emoji: "💪",
    ),
    Contact(
      name: "Bristy Haque",
      status: "Keep working",
      avatar: "assets/image/mtp.jpg",
      emoji: "💪",
    ),
    Contact(
      name: "John Borino",
      status: "Make yourself proud",
      avatar: "assets/image/mtp.jpg",
      emoji: "😊",
    ),
    Contact(
      name: "Borsha Akther",
      status: "Flowers are beautiful",
      avatar: "assets/image/mtp.jpg",
      emoji: "🌸",
    ),
    Contact(
      name: "Sheik Sadi",
      status: "Stay positive",
      avatar: "assets/image/mtp.jpg",
      emoji: "✨",
    ),
    Contact(
      name: "Alice Johnson",
      status: "Living the dream",
      avatar: "assets/image/mtp.jpg",
      emoji: "🌟",
    ),
    Contact(
      name: "Bob Smith",
      status: "Work hard, play hard",
      avatar: "assets/image/mtp.jpg",
      emoji: "🎯",
    ),
    Contact(
      name: "Charlie Brown",
      status: "Every day is a gift",
      avatar: "assets/image/mtp.jpg",
      emoji: "🎁",
    ),
    Contact(
      name: "David Wilson",
      status: "Believe in yourself",
      avatar: "assets/image/mtp.jpg",
      emoji: "💫",
    ),
    Contact(
      name: "Emma Davis",
      status: "Spread kindness",
      avatar: "assets/image/mtp.jpg",
      emoji: "💝",
    ),
    Contact(
      name: "Frank Miller",
      status: "Never give up",
      avatar: "assets/image/mtp.jpg",
      emoji: "🔥",
    ),
    Contact(
      name: "Grace Lee",
      status: "Be grateful",
      avatar: "assets/image/mtp.jpg",
      emoji: "🙏",
    ),
    Contact(
      name: "Henry Taylor",
      status: "Dream big",
      avatar: "assets/image/mtp.jpg",
      emoji: "🚀",
    ),
    Contact(
      name: "Ivy Chen",
      status: "Stay curious",
      avatar: "assets/image/mtp.jpg",
      emoji: "🔍",
    ),
    Contact(
      name: "Jack Anderson",
      status: "Make it happen",
      avatar: "assets/image/mtp.jpg",
      emoji: "⚡",
    ),
    Contact(
      name: "Kate Martinez",
      status: "Choose happiness",
      avatar: "assets/image/mtp.jpg",
      emoji: "😄",
    ),
    Contact(
      name: "Liam Thompson",
      status: "Be authentic",
      avatar: "assets/image/mtp.jpg",
      emoji: "💎",
    ),
    Contact(
      name: "Maya Rodriguez",
      status: "Embrace change",
      avatar: "assets/image/mtp.jpg",
      emoji: "🦋",
    ),
    Contact(
      name: "Noah Garcia",
      status: "Stay focused",
      avatar: "assets/image/mtp.jpg",
      emoji: "🎯",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sắp xếp danh sách theo tên
    final sortedContacts = List<Contact>.from(_contacts)
      ..sort((a, b) => a.name.compareTo(b.name));

    // Nhóm danh sách theo chữ cái đầu
    final Map<String, List<Contact>> groupedContacts = {};
    for (final contact in sortedContacts) {
      final firstLetter = contact.firstLetter;
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const ContactsAppBar(),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Container bo góc trên - nền trắng
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề "My Contact"
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 16, top: 8),
                        child: Text(
                          "My Contact",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Caros',
                          ),
                        ),
                      ),

                      // Danh sách liên hệ được phân theo bảng chữ cái
                      Expanded(
                        child: ListView.builder(
                          itemCount: groupedContacts.length,
                          itemBuilder: (context, index) {
                            final sortedKeys = groupedContacts.keys.toList()
                              ..sort();
                            final letter = sortedKeys[index];
                            final contacts = groupedContacts[letter]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header chữ cái
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Caros',
                                    ),
                                  ),
                                ),
                                // Danh sách liên hệ trong nhóm
                                ...contacts.map(
                                  (contact) => ContactItem(contact: contact),
                                ),
                                // Khoảng cách giữa các nhóm
                                if (index < groupedContacts.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
