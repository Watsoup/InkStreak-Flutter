// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      username: json['username'] as String,
      hashedPassword: json['hashedPassword'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'hashedPassword': instance.hashedPassword,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: json['token'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
    };

CheckTokenRequest _$CheckTokenRequestFromJson(Map<String, dynamic> json) =>
    CheckTokenRequest(
      username: json['username'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$CheckTokenRequestToJson(CheckTokenRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'token': instance.token,
    };

TokenValidResponse _$TokenValidResponseFromJson(Map<String, dynamic> json) =>
    TokenValidResponse(
      valid: json['valid'] as bool,
    );

Map<String, dynamic> _$TokenValidResponseToJson(TokenValidResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
    };

DiscordCallbackResponse _$DiscordCallbackResponseFromJson(
        Map<String, dynamic> json) =>
    DiscordCallbackResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      discordId: json['discordId'] as String?,
      discordUsername: json['discordUsername'] as String?,
    );

Map<String, dynamic> _$DiscordCallbackResponseToJson(
        DiscordCallbackResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'discordId': instance.discordId,
      'discordUsername': instance.discordUsername,
    };

DiscordStatusResponse _$DiscordStatusResponseFromJson(
        Map<String, dynamic> json) =>
    DiscordStatusResponse(
      linked: json['linked'] as bool,
      discordId: json['discordId'] as String?,
      discordUsername: json['discordUsername'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$DiscordStatusResponseToJson(
        DiscordStatusResponse instance) =>
    <String, dynamic>{
      'linked': instance.linked,
      'discordId': instance.discordId,
      'discordUsername': instance.discordUsername,
      'message': instance.message,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: _idFromJson(json['id']),
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      followers: (json['followers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      following: (json['following'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: _dateTimeFromJson(json['createdAt']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'followers': instance.followers,
      'following': instance.following,
      'createdAt': instance.createdAt.toIso8601String(),
    };

FollowResponse _$FollowResponseFromJson(Map<String, dynamic> json) =>
    FollowResponse(
      success: json['success'] as bool,
      isFollowing: json['isFollowing'] as bool,
    );

Map<String, dynamic> _$FollowResponseToJson(FollowResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isFollowing': instance.isFollowing,
    };

IsFollowingResponse _$IsFollowingResponseFromJson(Map<String, dynamic> json) =>
    IsFollowingResponse(
      isFollowing: json['isFollowing'] as bool,
    );

Map<String, dynamic> _$IsFollowingResponseToJson(
        IsFollowingResponse instance) =>
    <String, dynamic>{
      'isFollowing': instance.isFollowing,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      senderUsername: json['senderUsername'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderUsername': instance.senderUsername,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
    };

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      conversationId: (json['conversationId'] as num).toInt(),
      text: json['text'] as String,
      senderUsername: json['senderUsername'] as String,
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'text': instance.text,
      'senderUsername': instance.senderUsername,
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: (json['id'] as num).toInt(),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastMessage': instance.lastMessage,
    };

CreateConversationRequest _$CreateConversationRequestFromJson(
        Map<String, dynamic> json) =>
    CreateConversationRequest(
      participantUsernames: (json['participantUsernames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateConversationRequestToJson(
        CreateConversationRequest instance) =>
    <String, dynamic>{
      'participantUsernames': instance.participantUsernames,
    };

AuthorInfo _$AuthorInfoFromJson(Map<String, dynamic> json) => AuthorInfo(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$AuthorInfoToJson(AuthorInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'profilePicture': instance.profilePicture,
    };

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: (json['id'] as num).toInt(),
      author: AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
      picture: json['picture'] as String,
      caption: json['caption'] as String?,
      themeName: json['themeName'] as String?,
      yeahCount: (json['yeahCount'] as num?)?.toInt() ?? 0,
      yeahs: (json['yeahs'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      artistStreak: (json['artistStreak'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'picture': instance.picture,
      'caption': instance.caption,
      'themeName': instance.themeName,
      'yeahCount': instance.yeahCount,
      'yeahs': instance.yeahs,
      'createdAt': instance.createdAt.toIso8601String(),
      'artistStreak': instance.artistStreak,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      username: json['username'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'username': instance.username,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AddCommentRequest _$AddCommentRequestFromJson(Map<String, dynamic> json) =>
    AddCommentRequest(
      content: json['content'] as String,
    );

Map<String, dynamic> _$AddCommentRequestToJson(AddCommentRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

Theme _$ThemeFromJson(Map<String, dynamic> json) => Theme(
      name: json['themeText'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['createdAt'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$ThemeToJson(Theme instance) => <String, dynamic>{
      'themeText': instance.name,
      'description': instance.description,
      'createdAt': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequest(
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UpdateProfileRequestToJson(
    UpdateProfileRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bio', instance.bio);
  writeNotNull('profilePicture', instance.profilePicture);
  return val;
}

UpdateProfilePictureResponse _$UpdateProfilePictureResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateProfilePictureResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfilePictureResponseToJson(
        UpdateProfilePictureResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
    };

UpdateProfileResponse _$UpdateProfileResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfileResponseToJson(
        UpdateProfileResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      currentStreak: (json['currentStreak'] as num).toInt(),
      maxStreak: (json['maxStreak'] as num).toInt(),
      totalPosts: (json['totalPosts'] as num).toInt(),
      totalYeahs: (json['totalYeahs'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'totalPosts': instance.totalPosts,
      'totalYeahs': instance.totalYeahs,
    };

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

RegisterTokenRequest _$RegisterTokenRequestFromJson(
        Map<String, dynamic> json) =>
    RegisterTokenRequest(
      fcmToken: json['fcmToken'] as String,
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$RegisterTokenRequestToJson(
        RegisterTokenRequest instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'platform': instance.platform,
    };

RegisterTokenResponse _$RegisterTokenResponseFromJson(
        Map<String, dynamic> json) =>
    RegisterTokenResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RegisterTokenResponseToJson(
        RegisterTokenResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

UpdateNotificationSettingsRequest _$UpdateNotificationSettingsRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateNotificationSettingsRequest(
      dailyReminders: json['dailyReminders'] as bool,
      yeahNotifications: json['yeahNotifications'] as bool,
      commentNotifications: json['commentNotifications'] as bool,
      followerNotifications: json['followerNotifications'] as bool,
    );

Map<String, dynamic> _$UpdateNotificationSettingsRequestToJson(
        UpdateNotificationSettingsRequest instance) =>
    <String, dynamic>{
      'dailyReminders': instance.dailyReminders,
      'yeahNotifications': instance.yeahNotifications,
      'commentNotifications': instance.commentNotifications,
      'followerNotifications': instance.followerNotifications,
    };

UpdateNotificationSettingsResponse _$UpdateNotificationSettingsResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateNotificationSettingsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$UpdateNotificationSettingsResponseToJson(
        UpdateNotificationSettingsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
