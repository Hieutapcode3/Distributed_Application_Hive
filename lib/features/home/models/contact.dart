class Contact {
  final String name;
  final String status;
  final String avatar;
  final String emoji;

  const Contact({
    required this.name,
    required this.status,
    required this.avatar,
    required this.emoji,
  });

  String get firstLetter => name.isNotEmpty ? name[0].toUpperCase() : '';
}
