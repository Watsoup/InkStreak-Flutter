import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(const UploadInitial()) {
    on<UploadCheckStatus>(_onUploadCheckStatus);
    on<UploadImageSelected>(_onUploadImageSelected);
    on<UploadCaptionChanged>(_onUploadCaptionChanged);
    on<UploadSubmitted>(_onUploadSubmitted);
    on<UploadReset>(_onUploadReset);
  }

  Future<void> _onUploadCheckStatus(
    UploadCheckStatus event,
    Emitter<UploadState> emit,
  ) async {
    try {
      // Simulate checking if user posted today
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data - in real app, check from API
      final now = DateTime.now();
      const hasPostedToday = false; // Change to true to test posted state

      // Calculate time until next theme (midnight)
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final timeUntilNextTheme = tomorrow.difference(now);

      emit(UploadReady(
        hasPostedToday: hasPostedToday,
        // In real app, fetch actual post if hasPostedToday is true
        todaysPost: null,
        todaysTheme: "Spooky Creatures",
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
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilNextTheme = tomorrow.difference(now);

    emit(UploadImagePicked(
      image: event.image,
      caption: '',
      todaysTheme: "Spooky Creatures",
      timeUntilNextTheme: timeUntilNextTheme,
    ));
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
      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      // In real app, call API service here
      // final post = await apiService.createPost(image, caption);

      // Mock successful upload
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        username: 'You',
        imageUrl: currentState.image.path,
        caption: currentState.caption.isEmpty ? null : currentState.caption,
        theme: currentState.todaysTheme,
        yeahCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        streakDay: 1,
        isYeahed: false,
      );

      emit(UploadSuccess(post: post));
    } catch (e) {
      emit(UploadError(message: 'Failed to upload: $e'));
    }
  }

  Future<void> _onUploadReset(
    UploadReset event,
    Emitter<UploadState> emit,
  ) async {
    add(const UploadCheckStatus());
  }
}
