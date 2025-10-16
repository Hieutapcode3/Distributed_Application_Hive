// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatRoomModelAdapter extends TypeAdapter<ChatRoomModel> {
  @override
  final int typeId = 2;

  @override
  ChatRoomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatRoomModel(
      id: fields[0] as String,
      isGroup: fields[2] as bool,
      memberIds: (fields[3] as List).cast<String>(),
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatRoomModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isGroup)
      ..writeByte(3)
      ..write(obj.memberIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
