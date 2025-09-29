import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/data/models/user_models.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;
  
  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);
  
  @GET("/posts")
  Future<List<Post>> getPosts();
  
  @POST("/posts")
  @MultiPart()
  Future<Post> createPost(
    @Part(name: "image") File image,
    @Part(name: "description") String? description,
  );
  
  @GET("/users/{id}")
  Future<User> getUser(@Path("id") String userId);
  
  @POST("/messages")
  Future<Message> sendMessage(@Body() MessageRequest request);
}
