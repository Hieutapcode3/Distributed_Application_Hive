import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 3)
class MessageModel extends HiveObject {
  @HiveField(0)
  String id; 

  @HiveField(1)
  String? roomId; // Nếu null → là chat 1:1

  @HiveField(2)
  String senderId;

  @HiveField(3)
  String? receiverId; // Nếu null → là tin nhắn group

  @HiveField(4)
  String content;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  String senderName;

  @HiveField(7)
  bool isGroup; 

  @HiveField(8)
  List<String>? readBy; 

  MessageModel({
    required this.id,
    this.roomId,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.timestamp,
    required this.senderName,
    this.isGroup = false,
    this.readBy,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      senderName: json['senderName'],
      isGroup: json['isGroup'] ?? false,
      readBy: (json['readBy'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
      'isGroup': isGroup,
      'readBy': readBy ?? [],
    };
  }

  MessageModel copyWith({
  String? id,
  String? senderId,
  String? receiverId,
  bool? isGroup,
  String? senderName,
  DateTime? timestamp,
  String? roomId,
  String? content,
}) {
  return MessageModel(
    id: id ?? this.id,
    senderId: senderId ?? this.senderId,
    receiverId: receiverId ?? this.receiverId,
    isGroup: isGroup ?? this.isGroup,
    senderName: senderName ?? this.senderName,
    timestamp: timestamp ?? this.timestamp,
    roomId: roomId ?? this.roomId,
    content: content ?? this.content,
  );
}

}
