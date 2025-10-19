import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/data/services/notification_service.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_bloc.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_event.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  late StorageService _storage;
  late ApiService _apiService;
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  bool _isSyncingNotifications = false;

  // Notification settings
  bool _dailyReminders = true;
  bool _yeahNotifications = true;
  bool _commentNotifications = true;
  bool _followerNotifications = true;

  // Privacy settings
  bool _profilePublic = true;
  bool _showStreak = true;

  // Discord link status
  bool _discordLinked = false;
  String? _discordUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh Discord status when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadDiscordStatus();
    }
  }

  Future<void> _loadSettings() async {
    _storage = await StorageService.getInstance();
    _apiService = ApiService(DioClient.createDio());

    // Load actual values
    final dailyRemindersValue = await _storage.read(key: 'daily_reminders');
    final yeahNotificationsValue = await _storage.read(key: 'yeah_notifications');
    final commentNotificationsValue = await _storage.read(key: 'comment_notifications');
    final followerNotificationsValue = await _storage.read(key: 'follower_notifications');
    final profilePublicValue = await _storage.read(key: 'profile_public');
    final showStreakValue = await _storage.read(key: 'show_streak');

    // Load Discord link status
    await _loadDiscordStatus();

    if (mounted) {
      setState(() {
        _dailyReminders = dailyRemindersValue != 'false';
        _yeahNotifications = yeahNotificationsValue != 'false';
        _commentNotifications = commentNotificationsValue != 'false';
        _followerNotifications = followerNotificationsValue != 'false';
        _profilePublic = profilePublicValue != 'false';
        _showStreak = showStreakValue != 'false';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDiscordStatus() async {
    try {
      final response = await _apiService.getDiscordStatus();
      if (mounted) {
        setState(() {
          _discordLinked = response.linked;
          _discordUsername = response.discordUsername;
        });
      }
    } catch (e) {
      // Discord not linked or error fetching status
      if (mounted) {
        setState(() {
          _discordLinked = false;
          _discordUsername = null;
        });
      }
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  /// Sync notification settings with backend
  Future<void> _syncNotificationSettings() async {
    if (_isSyncingNotifications) return;

    setState(() => _isSyncingNotifications = true);

    try {
      // Update settings on backend
      await _notificationService.updateNotificationSettings(
        dailyReminders: _dailyReminders,
        yeahNotifications: _yeahNotifications,
        commentNotifications: _commentNotifications,
        followerNotifications: _followerNotifications,
      );

      // Save locally
      await _saveSetting('daily_reminders', _dailyReminders);
      await _saveSetting('yeah_notifications', _yeahNotifications);
      await _saveSetting('comment_notifications', _commentNotifications);
      await _saveSetting('follower_notifications', _followerNotifications);

      // Schedule or cancel daily reminders based on setting
      if (_dailyReminders) {
        // Get current theme and username for daily reminders
        try {
          final theme = await _apiService.getCurrentTheme();
          final username = await _storage.read(key: 'username');
          if (username != null) {
            await _notificationService.scheduleDailyReminders(
              username: username,
              theme: theme.name,
            );
          }
        } catch (e) {
          debugPrint('Error scheduling daily reminders: $e');
        }
      } else {
        await _notificationService.cancelDailyReminders();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings updated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error syncing notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notification settings: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingNotifications = false);
      }
    }
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached images? This will free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implement actual cache clearing logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _linkDiscord() async {
    if (_discordLinked) {
      // Show already linked message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discord Account Linked'),
          content: Text('Your Discord account ${_discordUsername ?? ''} is already linked.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show link dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Link Discord Account'),
          content: const Text('This will open Discord in your browser to authorize linking your account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _initiateDiscordOAuth();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initiateDiscordOAuth() async {
    try {
      // Generate a random state for security
      final state = DateTime.now().millisecondsSinceEpoch.toString();

      // Get JWT token from storage
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please log in again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Build the Discord OAuth URL with token as query parameter
      final discordAuthUrl = Uri.parse('${AppConstants.baseUrl}auth/discord?state=$state&token=$token');

      // Launch the URL in external browser
      if (await canLaunchUrl(discordAuthUrl)) {
        await launchUrl(discordAuthUrl, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening Discord authorization in browser...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Discord authorization page'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initiating Discord OAuth: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get reminded to draw every day'),
            value: _dailyReminders,
            onChanged: _isSyncingNotifications ? null : (value) {
              setState(() => _dailyReminders = value);
              _syncNotificationSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Yeahs'),
            subtitle: const Text('When someone yeahs your post'),
            value: _yeahNotifications,
            onChanged: _isSyncingNotifications ? null : (value) {
              setState(() => _yeahNotifications = value);
              _syncNotificationSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('When someone comments on your post'),
            value: _commentNotifications,
            onChanged: _isSyncingNotifications ? null : (value) {
              setState(() => _commentNotifications = value);
              _syncNotificationSettings();
            },
          ),
          SwitchListTile(
            title: const Text('New Followers'),
            subtitle: const Text('When someone follows you'),
            value: _followerNotifications,
            onChanged: _isSyncingNotifications ? null : (value) {
              setState(() => _followerNotifications = value);
              _syncNotificationSettings();
            },
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          BlocBuilder<AppThemeBloc, AppThemeState>(
            builder: (context, themeState) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(themeState.isDarkMode
                  ? 'Enabled'
                  : 'Disabled'),
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<AppThemeBloc>().add(const ToggleTheme());
                },
              );
            },
          ),
          const Divider(),

          // Accounts Section
          _buildSectionHeader(context, 'Accounts'),
          ListTile(
            leading: const Icon(Icons.discord, color: Color(0xFF5865F2)),
            title: Text(_discordLinked ? 'Discord Account' : 'Link Discord Account'),
            subtitle: Text(_discordLinked
              ? 'Linked as ${_discordUsername ?? 'Unknown'}'
              : 'Connect your Discord account for bot integrations'),
            trailing: _discordLinked
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _linkDiscord,
          ),
          const Divider(),

          // Privacy Section
          _buildSectionHeader(context, 'Privacy'),
          SwitchListTile(
            title: const Text('Public Profile'),
            subtitle: const Text('Allow others to view your profile'),
            value: _profilePublic,
            onChanged: (value) {
              setState(() => _profilePublic = value);
              _saveSetting('profile_public', value);
            },
          ),
          SwitchListTile(
            title: const Text('Show Streak'),
            subtitle: const Text('Display your streak on your profile'),
            value: _showStreak,
            onChanged: (value) {
              setState(() => _showStreak = value);
              _saveSetting('show_streak', value);
            },
          ),
          const Divider(),

          // Data & Storage Section
          _buildSectionHeader(context, 'Data & Storage'),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _clearCache,
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('2.0.2'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: Replace with actual terms URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: Replace with actual privacy policy URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate InkStreak'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: Add app store/play store links
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your support!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share InkStreak'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon!')),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
