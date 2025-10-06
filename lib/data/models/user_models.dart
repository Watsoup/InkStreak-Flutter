
import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String? profilePicture;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.profilePicture,
    this.bio,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String username;
  final String hashedPassword;

  LoginRequest({
    required this.username,
    required this.hashedPassword,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String? description;
  final DateTime createdAt;
  final User user;
  final int likesCount;
  final int commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.description,
    required this.createdAt,
    required this.user,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessageRequest {
  final String receiverId;
  final String content;

  MessageRequest({
    required this.receiverId,
    required this.content,
  });

  factory MessageRequest.fromJson(Map<String, dynamic> json) => _$MessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MessageRequestToJson(this);
}