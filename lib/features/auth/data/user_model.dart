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
  final String? profilePictureUrl;

  @HiveField(4)
  final bool isOnline;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.isOnline = false,
  });

  // Thêm copyWith()
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePictureUrl,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }

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
