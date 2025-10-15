import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/presentation/blocs/upload/upload_bloc.dart';
import 'package:inkstreak/presentation/blocs/upload/upload_event.dart';
import 'package:inkstreak/presentation/blocs/upload/upload_state.dart';
import 'package:inkstreak/presentation/widgets/upload/countdown_timer.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';

class UploadScreen extends StatefulWidget {
  final bool isInPageView;

  const UploadScreen({super.key, this.isInPageView = false});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _captionController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        context.read<UploadBloc>().add(
              UploadImageSelected(image: File(image.path)),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            _confettiController.play();
            if (!widget.isInPageView) {
              Future.delayed(const Duration(seconds: 5), () {
                if (context.mounted) {
                  context.go('/home');
                }
              });
            }
          } else if (state is UploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: widget.isInPageView ? AppBar(
            title: const Text('Upload Drawing'),
            automaticallyImplyLeading: false,
          ) : AppBar(
            title: const Text('Upload Drawing'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: Stack(
            children: [
              BlocBuilder<UploadBloc, UploadState>(
                builder: (context, state) {
                  if (state is UploadInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UploadReady) {
                    return _buildReadyState(context, state);
                  } else if (state is UploadImagePicked) {
                    return _buildImagePickedState(context, state);
                  } else if (state is UploadInProgress) {
                    return _buildUploadingState(context);
                  } else if (state is UploadSuccess) {
                    return _buildSuccessState(context, state);
                  } else if (state is UploadError) {
                    return _buildErrorState(context, state);
                  }
                  return const SizedBox();
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildReadyState(BuildContext context, UploadReady state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Display
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "Today's theme",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.todaysTheme,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (state.themeDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.themeDescription!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status Indicator
          CountdownTimer(
            duration: state.timeUntilNextTheme,
            hasPostedToday: state.hasPostedToday,
          ),
          const SizedBox(height: 24),

          // Content based on post status
          if (state.hasPostedToday && state.todaysPost != null)
            _buildPostedContent(context, state)
          else
            _buildUploadOptions(context),
        ],
      ),
    );
  }

  Widget _buildPostedContent(BuildContext context, UploadReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your post today",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        PostCard(
          post: state.todaysPost!,
          onYeahTap: () {},
          onCommentTap: () {},
        ),
      ],
    );
  }

  Widget _buildUploadOptions(BuildContext context) {
    return Column(
      children: [
        Text(
          "Choose how to add your drawing",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                context,
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickedState(BuildContext context, UploadImagePicked state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme reminder
          Text(
            "Theme: ${state.todaysTheme}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          if (state.themeDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              state.themeDescription!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),

          // Timer
          CountdownTimer(
            duration: state.timeUntilNextTheme,
            hasPostedToday: false,
          ),
          const SizedBox(height: 24),

          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              state.image,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Change Image Button
          OutlinedButton.icon(
            onPressed: () {
              context.read<UploadBloc>().add(const UploadReset());
            },
            icon: const Icon(Icons.edit),
            label: const Text('Change Image'),
          ),
          const SizedBox(height: 24),

          // Caption Input
          TextField(
            controller: _captionController,
            maxLines: 3,
            maxLength: 280,
            decoration: InputDecoration(
              labelText: 'Caption (optional)',
              hintText: 'Add a caption to your drawing...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              context.read<UploadBloc>().add(
                    UploadCaptionChanged(caption: value),
                  );
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              context.read<UploadBloc>().add(const UploadSubmitted());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Post Drawing',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Uploading your drawing...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, UploadSuccess state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'Posted successfully!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Redirecting to home...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UploadError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Upload failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UploadBloc>().add(const UploadReset());
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
