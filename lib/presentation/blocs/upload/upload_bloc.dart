import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/core/utils/universal_file.dart' show createFileFromXFile;
import 'package:inkstreak/core/constants/constants.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final ApiService _apiService;

  UploadBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const UploadInitial()) {
    on<UploadCheckStatus>(_onUploadCheckStatus);
    on<UploadImageSelected>(_onUploadImageSelected);
    on<UploadCaptionChanged>(_onUploadCaptionChanged);
    on<UploadSubmitted>(_onUploadSubmitted);
    on<UploadReset>(_onUploadReset);
    on<UploadSuccessAcknowledged>(_onUploadSuccessAcknowledged);
  }

  Future<void> _onUploadCheckStatus(
    UploadCheckStatus event,
    Emitter<UploadState> emit,
  ) async {
    try {
      // Fetch current theme from API
      final theme = await _apiService.getCurrentTheme();

      // Calculate time until next theme (midnight)
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final timeUntilNextTheme = tomorrow.difference(now);

      // Check if user has posted today
      bool hasPostedToday = false;
      Post? todaysPost;

      try {
        // Get current user from storage
        final storage = await StorageService.getInstance();
        final userJson = await storage.read(key: AppConstants.userKey);

        if (userJson != null) {
          final user = api_models.User.fromJson(json.decode(userJson));

          // Try to fetch today's post
          final apiPost = await _apiService.getTodayPost(user.username);

          // Convert API post to UI post
          final currentUserId = int.tryParse(user.id);
          final isYeahed = currentUserId != null && apiPost.yeahs.contains(currentUserId);

          todaysPost = Post(
            id: apiPost.id.toString(),
            userId: apiPost.author.id.toString(),
            username: apiPost.author.username,
            avatarUrl: apiPost.author.profilePicture,
            imageUrl: apiPost.picture,
            caption: apiPost.caption,
            theme: apiPost.themeName,
            yeahCount: apiPost.yeahCount,
            commentCount: 0,
            createdAt: apiPost.createdAt,
            streakDay: apiPost.artistStreak,
            isYeahed: isYeahed,
          );

          hasPostedToday = true;
        }
      } on DioException catch (e) {
        // 404 means no post today, which is fine
        if (e.response?.statusCode == 404) {
          hasPostedToday = false;
          todaysPost = null;
        } else {
          debugPrint('Error checking today\'s post: ${e.message}');
        }
      } catch (e) {
        debugPrint('Error checking today\'s post: $e');
      }

      emit(UploadReady(
        hasPostedToday: hasPostedToday,
        todaysPost: todaysPost,
        todaysTheme: theme.name,
        themeDescription: theme.description,
        timeUntilNextTheme: timeUntilNextTheme,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading theme: ${e.message}');
      // Fallback to default theme
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final timeUntilNextTheme = tomorrow.difference(now);

      emit(UploadReady(
        hasPostedToday: false,
        todaysPost: null,
        todaysTheme: "Daily Theme",
        themeDescription: null,
        timeUntilNextTheme: timeUntilNextTheme,
      ));
    } catch (e) {
      emit(UploadError(message: 'Failed to load status: $e'));
    }
  }

  Future<void> _onUploadImageSelected(
    UploadImageSelected event,
    Emitter<UploadState> emit,
  ) async {
    try {
      // Fetch current theme from API
      final theme = await _apiService.getCurrentTheme();

      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final timeUntilNextTheme = tomorrow.difference(now);

      emit(UploadImagePicked(
        image: event.image,
        caption: '',
        todaysTheme: theme.name,
        themeDescription: theme.description,
        timeUntilNextTheme: timeUntilNextTheme,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading theme: ${e.message}');
      // Fallback to default theme
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final timeUntilNextTheme = tomorrow.difference(now);

      emit(UploadImagePicked(
        image: event.image,
        caption: '',
        todaysTheme: "Daily Theme",
        themeDescription: null,
        timeUntilNextTheme: timeUntilNextTheme,
      ));
    }
  }

  Future<void> _onUploadCaptionChanged(
    UploadCaptionChanged event,
    Emitter<UploadState> emit,
  ) async {
    if (state is UploadImagePicked) {
      final currentState = state as UploadImagePicked;
      emit(currentState.copyWith(caption: event.caption));
    }
  }

  Future<void> _onUploadSubmitted(
    UploadSubmitted event,
    Emitter<UploadState> emit,
  ) async {
    if (state is! UploadImagePicked) return;

    final currentState = state as UploadImagePicked;
    emit(UploadInProgress(
      image: currentState.image,
      caption: currentState.caption,
    ));

    try {
      // Get current user info from storage to check if post is yeahed
      final storage = await StorageService.getInstance();
      final userJson = await storage.read(key: AppConstants.userKey);

      int? currentUserId;
      if (userJson != null) {
        final user = api_models.User.fromJson(json.decode(userJson));
        // Convert user.id (String) to int if needed
        currentUserId = int.tryParse(user.id);
      }

      // Call API service to create post
      // Handle web and mobile platforms differently for file upload
      final api_models.Post apiPost;
      if (kIsWeb) {
        // For web, manually create FormData with bytes
        final bytes = await currentState.image.readAsBytes();
        final formData = FormData.fromMap({
          'picture': MultipartFile.fromBytes(
            bytes,
            filename: currentState.image.name,
          ),
          if (currentState.caption.isNotEmpty)
            'caption': currentState.caption,
        });

        // Make direct Dio call
        final dio = DioClient.createDio();
        final response = await dio.post(
          '${AppConstants.baseUrl}/posts',
          data: formData,
        );
        apiPost = api_models.Post.fromJson(response.data);
      } else {
        // For mobile, use the regular File-based approach with dart:io File
        final imageFile = createFileFromXFile(currentState.image);
        apiPost = await _apiService.createPost(
          imageFile as io.File,
          currentState.caption.isEmpty ? null : currentState.caption,
        );
      }

      // Convert API post to UI post
      // API now returns: author{id, username, profilePicture}, themeName, yeahs[]
      final isYeahed = currentUserId != null && apiPost.yeahs.contains(currentUserId);

      final post = Post(
        id: apiPost.id.toString(),
        userId: apiPost.author.id.toString(),
        username: apiPost.author.username,
        avatarUrl: apiPost.author.profilePicture,
        imageUrl: apiPost.picture,
        caption: apiPost.caption,
        theme: apiPost.themeName,
        yeahCount: apiPost.yeahCount,
        commentCount: 0, // New posts have no comments yet
        createdAt: apiPost.createdAt,
        streakDay: apiPost.artistStreak,
        isYeahed: isYeahed,
      );

      emit(UploadSuccess(post: post));
    } on DioException catch (e) {
      String errorMessage = 'Failed to upload post';
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 401:
            errorMessage = 'Your session has expired. Please login again.';
            debugPrint('Upload failed: 401 Unauthorized - ${e.response!.data}');
            break;
          case 400:
            errorMessage = 'Invalid image or missing theme';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'Upload failed. Please try again.';
        }
      } else {
        debugPrint('Upload failed with no response: ${e.message}');
        errorMessage = 'Network error. Please check your connection.';
      }
      emit(UploadError(message: errorMessage));
    } catch (e) {
      debugPrint('Upload failed with unexpected error: $e');
      emit(UploadError(message: 'Failed to upload: $e'));
    }
  }

  Future<void> _onUploadReset(
    UploadReset event,
    Emitter<UploadState> emit,
  ) async {
    add(const UploadCheckStatus());
  }

  Future<void> _onUploadSuccessAcknowledged(
    UploadSuccessAcknowledged event,
    Emitter<UploadState> emit,
  ) async {
    // Reset to ready state and fetch updated status
    add(const UploadCheckStatus());
  }
}
