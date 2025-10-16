import 'package:hive/hive.dart';

part 'chat_room_model.g.dart';

@HiveType(typeId: 2)
class ChatRoomModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; 

  @HiveField(2)
  bool isGroup; 

  @HiveField(3)
  List<String> memberIds; 

  ChatRoomModel({
    required this.id,
    required this.isGroup,
    required this.memberIds,
    this.name = '',
  });
}
