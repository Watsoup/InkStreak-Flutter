import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/data/models/user_models.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ============================================================================
  // Auth Endpoints
  // ============================================================================

  /// POST /auth/login - Login or create a new user account
  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);

  /// POST /auth/checkToken - Check if JWT token matches stored user token
  @POST("/auth/checkToken")
  Future<TokenValidResponse> checkToken(@Body() CheckTokenRequest request);

  // ============================================================================
  // Chat/Messages Endpoints
  // ============================================================================

  /// GET /messages/{conversationId} - Get all messages for a conversation
  @GET("/messages/{conversationId}")
  Future<List<Message>> getMessages(@Path("conversationId") String conversationId);

  /// GET /messages/username/{username} - Get all messages sent by a user
  @GET("/messages/username/{username}")
  Future<List<Message>> getMessagesByUsername(@Path("username") String username);

  /// POST /messages/send - Send a message in a conversation
  @POST("/messages/send")
  Future<Message> sendMessage(@Body() SendMessageRequest request);

  // ============================================================================
  // Conversations Endpoints
  // ============================================================================

  /// GET /conversations/{usernameReceiver} - Get all conversations for a user
  @GET("/conversations/{usernameReceiver}")
  Future<List<Conversation>> getConversations(@Path("usernameReceiver") String usernameReceiver);

  /// POST /conversations/create - Create new conversation with participants
  @POST("/conversations/create")
  Future<Conversation> createConversation(@Body() CreateConversationRequest request);

  // ============================================================================
  // Posts Endpoints
  // ============================================================================

  /// POST /posts - Create a new post with image and caption
  @POST("/posts")
  @MultiPart()
  Future<Post> createPost(
    @Part(name: "picture") File picture,
    @Part(name: "caption") String? caption,
  );

  /// GET /posts - Get all posts (for today's feed)
  @GET("/posts/all")
  Future<List<Post>> getAllPosts();

  /// GET /posts/followed/{username} - Get posts from users followed by specified user
  @GET("/posts/followed/{username}")
  Future<List<Post>> getFollowedPosts(@Path("username") String username);

  /// POST /posts/{id}/yeah - Toggle a "yeah" (like) for a post
  @POST("/posts/{id}/yeah")
  Future<Post> toggleYeah(@Path("id") int id);

  /// POST /posts/{id}/comment - Add a comment to a post
  @POST("/posts/{id}/comment")
  Future<Post> addComment(
    @Path("id") int id,
    @Body() AddCommentRequest request,
  );

  // ============================================================================
  // Theme Endpoints
  // ============================================================================

  /// GET /theme/current - Retrieve current active theme
  @GET("/theme/current")
  Future<Theme> getCurrentTheme();

  // ============================================================================
  // Users Endpoints
  // ============================================================================

  /// GET /users - Get all users
  @GET("/users")
  Future<List<User>> getAllUsers();

  /// GET /users/{username} - Get user details by username
  @GET("/users/{username}")
  Future<User> getUser(@Path("username") String username);

  /// GET /users/search/{username} - Search users by username (partial match)
  @GET("/users/search/{username}")
  Future<List<User>> searchUsers(@Path("username") String username);

  /// POST /users/{followedUsername}/follow - Follow or unfollow a user
  @POST("/users/{followedUsername}/follow")
  Future<FollowResponse> followUser(@Path("followedUsername") String followedUsername);

  /// GET /users/{followedUsername}/is-following - Check if auth user follows another user
  @GET("/users/{followedUsername}/is-following")
  Future<IsFollowingResponse> isFollowing(@Path("followedUsername") String followedUsername);

  /// PATCH /users/profile/picture - Update profile picture
  @PATCH("/users/profile/picture")
  @MultiPart()
  Future<UpdateProfilePictureResponse> updateProfilePicture(
    @Part(name: "picture") File picture,
  );

  /// PATCH /users/profile - Update profile (bio, profilePicture URL)
  @PATCH("/users/profile")
  Future<UpdateProfileResponse> updateProfile(@Body() UpdateProfileRequest request);

  // ============================================================================
  // Health Check Endpoint
  // ============================================================================

  /// GET /health - Health check endpoint
  @GET("/health")
  Future<HealthResponse> healthCheck();
}
