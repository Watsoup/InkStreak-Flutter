
import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

// Helper function to convert id from int or String to String
String _idFromJson(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is int) {
    return value.toString();
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

// Helper function to handle missing or null createdAt
DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  return DateTime.now();
}

// ============================================================================
// Auth Models
// ============================================================================

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
  final String token;
  final User? user;

  AuthResponse({
    required this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class CheckTokenRequest {
  final String username;
  final String token;

  CheckTokenRequest({
    required this.username,
    required this.token,
  });

  factory CheckTokenRequest.fromJson(Map<String, dynamic> json) => _$CheckTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckTokenRequestToJson(this);
}

@JsonSerializable()
class TokenValidResponse {
  final bool valid;

  TokenValidResponse({required this.valid});

  factory TokenValidResponse.fromJson(Map<String, dynamic> json) => _$TokenValidResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenValidResponseToJson(this);
}

// ============================================================================
// User Models
// ============================================================================

@JsonSerializable()
class User {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String username;
  final String? profilePicture;
  final String? bio;
  final List<String>? followers;
  final List<String>? following;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.profilePicture,
    this.bio,
    this.followers,
    this.following,
    required this.createdAt,
});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class FollowResponse {
  final bool success;
  final bool isFollowing;

  FollowResponse({
    required this.success,
    required this.isFollowing,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) => _$FollowResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FollowResponseToJson(this);
}

@JsonSerializable()
class IsFollowingResponse {
  final bool isFollowing;

  IsFollowingResponse({required this.isFollowing});

  factory IsFollowingResponse.fromJson(Map<String, dynamic> json) => _$IsFollowingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IsFollowingResponseToJson(this);
}

// ============================================================================
// Message & Conversation Models
// ============================================================================

@JsonSerializable()
class Message {
  final int id;
  final int conversationId;
  final String senderUsername;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderUsername,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class SendMessageRequest {
  final int conversationId;
  final String text;
  final String senderUsername;

  SendMessageRequest({
    required this.conversationId,
    required this.text,
    required this.senderUsername,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class Conversation {
  final int id;
  final List<String> participants;
  final DateTime createdAt;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class CreateConversationRequest {
  final List<String> participantUsernames;

  CreateConversationRequest({required this.participantUsernames});

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) => _$CreateConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

// ============================================================================
// Post Models
// ============================================================================

@JsonSerializable()
class AuthorInfo {
  final int id;
  final String username;
  final String? profilePicture;

  AuthorInfo({
    required this.id,
    required this.username,
    this.profilePicture,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) => _$AuthorInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorInfoToJson(this);
}

@JsonSerializable()
class Post {
  final int id;
  final AuthorInfo author;
  final String picture;
  final String? caption;
  final String? themeName;
  @JsonKey(defaultValue: 0)
  final int yeahCount;
  @JsonKey(defaultValue: [])
  final List<int> yeahs; // Array of user IDs who yeahed
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.picture,
    this.caption,
    this.themeName,
    this.yeahCount = 0,
    this.yeahs = const [],
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Comment {
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class AddCommentRequest {
  final String content;

  AddCommentRequest({required this.content});

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) => _$AddCommentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddCommentRequestToJson(this);
}

// ============================================================================
// Theme Models
// ============================================================================

@JsonSerializable()
class Theme {
  @JsonKey(name: 'themeText')
  final String name;
  final String? description;
  @JsonKey(name: 'createdAt')
  final DateTime startDate;
  final DateTime? endDate;

  Theme({
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeToJson(this);
}

// ============================================================================
// Profile Update Models
// ============================================================================

@JsonSerializable(includeIfNull: false)
class UpdateProfileRequest {
  final String? bio;
  final String? profilePicture;

  UpdateProfileRequest({
    this.bio,
    this.profilePicture,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class UpdateProfilePictureResponse {
  final bool success;
  final String message;
  final User user;

  UpdateProfilePictureResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UpdateProfilePictureResponse.fromJson(Map<String, dynamic> json) => _$UpdateProfilePictureResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfilePictureResponseToJson(this);
}

@JsonSerializable()
class UpdateProfileResponse {
  final bool success;
  final String message;
  final User user;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) => _$UpdateProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}

// ============================================================================
// Health Check Model
// ============================================================================

@JsonSerializable()
class HealthResponse {
  final String status;

  HealthResponse({required this.status});

  factory HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}