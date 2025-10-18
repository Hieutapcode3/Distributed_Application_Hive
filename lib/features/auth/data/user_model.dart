import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  String? profilePictureUrl;

  @HiveField(4)
  bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    profilePictureUrl: json['profilePictureUrl'],
    isOnline: json['isOnline'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'profilePictureUrl': profilePictureUrl,
    'isOnline': isOnline,
  };
}
