import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/data/models/user_models.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Handle the message in the background
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  late ApiService _apiService;
  late StorageService _storage;
  bool _isInitialized = false;
  String? _fcmToken;

  // Android notification channel for high priority notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'inkstreak_notifications', // id
    'InkStreak Notifications', // name
    description: 'Notifications for InkStreak app',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _storage = await StorageService.getInstance();
    _apiService = ApiService(DioClient.createDio());

    // Initialize timezone database
    tz.initializeTimeZones();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permissions
    await _requestPermissions();

    // Get FCM token
    await _getFCMToken();

    // Setup message handlers
    _setupMessageHandlers();

    _isInitialized = true;
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        await _handleNotificationTap(response);
      },
    );

    // Create Android notification channel
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (kIsWeb) {
      // Web doesn't support local notifications in the same way
      return true;
    }

    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    // Android 13+ requires permission
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? true;
    }

    return true;
  }

  /// Get FCM token and register with backend
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _registerTokenWithBackend(_fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _registerTokenWithBackend(newToken);
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      String deviceId = 'unknown';
      if (kIsWeb) {
        deviceId = 'web';
      } else if (Platform.isAndroid) {
        deviceId = 'android';
      } else if (Platform.isIOS) {
        deviceId = 'ios';
      }

      final request = RegisterTokenRequest(
        token: token,
        deviceId: deviceId,
      );

      await _apiService.registerFCMToken(request);
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Error registering FCM token with backend: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      _showNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app from background: ${message.messageId}');
      _handleNotificationOpenedApp(message);
    });

    // Check if app was opened from a terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state: ${message.messageId}');
        _handleNotificationOpenedApp(message);
      }
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(NotificationResponse response) async {
    debugPrint('Notification tapped: ${response.payload}');
    // Parse payload string back to map (payload is stored as string)
    // For local notifications, we pass the RemoteMessage data as string
    // This is a simplified handler - in production you'd parse the payload properly
    // For now, we'll mainly rely on _handleNotificationOpenedApp for FCM messages
  }

  /// Handle notification that opened the app
  void _handleNotificationOpenedApp(RemoteMessage message) {
    debugPrint('Handling notification that opened app: ${message.data}');

    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigator context is null, cannot navigate');
      return;
    }

    final data = message.data;
    final type = data['type'] as String?;

    if (type == null) {
      debugPrint('Notification type is null, ignoring');
      return;
    }

    // Navigate based on notification type
    switch (type) {
      case 'follower':
        // Navigate to feed where user can see new follower
        // TODO: When UserProfileScreen is implemented, navigate to /profile/:username
        final fromUsername = data['fromUsername'] as String?;
        debugPrint('New follower notification from: $fromUsername');
        context.go('/feed');
        break;

      case 'yeah':
        // Navigate to feed to see the post that got a yeah
        final postId = data['postId'] as String?;
        debugPrint('Yeah notification for post: $postId');
        context.go('/feed');
        break;

      case 'comment':
        // Navigate to feed to see the post with new comment
        final postId = data['postId'] as String?;
        final commentId = data['commentId'] as String?;
        debugPrint('Comment notification for post: $postId, comment: $commentId');
        context.go('/feed');
        break;

      case 'daily_reminder':
        // Navigate to upload screen for daily reminder
        final reminderType = data['reminderType'] as String?;
        final themeName = data['themeName'] as String?;
        debugPrint('Daily reminder ($reminderType) for theme: $themeName');
        context.go('/upload');
        break;

      default:
        debugPrint('Unknown notification type: $type');
        context.go('/home');
    }
  }

  /// Schedule daily reminder notifications
  Future<void> scheduleDailyReminders({
    required String username,
    required String theme,
  }) async {
    // Check if daily reminders are enabled
    final dailyRemindersEnabled = await _storage.read(key: 'daily_reminders');
    if (dailyRemindersEnabled == 'false') return;

    // Schedule 8 AM notification
    await _scheduleDailyNotification(
      id: 1,
      hour: 8,
      minute: 0,
      title: 'Good morning, $username!',
      body: "Hope you slept well, today's theme is: $theme",
    );

    // Schedule 8 PM notification
    await _scheduleDailyNotification(
      id: 2,
      hour: 20,
      minute: 0,
      title: "Time's running out!",
      body: "You haven't uploaded your drawing for $theme yet!",
    );
  }

  /// Schedule a daily notification at a specific time
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily drawing reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancel daily reminders
  Future<void> cancelDailyReminders() async {
    await _localNotifications.cancel(1); // Morning reminder
    await _localNotifications.cancel(2); // Evening reminder
  }

  /// Update notification settings on backend
  Future<void> updateNotificationSettings({
    required bool dailyReminders,
    required bool yeahNotifications,
    required bool commentNotifications,
    required bool followerNotifications,
  }) async {
    try {
      final request = UpdateNotificationSettingsRequest(
        dailyReminders: dailyReminders,
        yeahNotifications: yeahNotifications,
        commentNotifications: commentNotifications,
        followerNotifications: followerNotifications,
      );

      await _apiService.updateNotificationSettings(request);
      debugPrint('Notification settings updated on backend');

      // Update local daily reminders
      if (!dailyReminders) {
        await cancelDailyReminders();
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  /// Unregister FCM token
  Future<void> unregisterToken() async {
    try {
      if (_fcmToken != null) {
        await _apiService.unregisterFCMToken({'token': _fcmToken!});
      }
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token unregistered');
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
