import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Callback for handling notification actions from background
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Background notification action: ${notificationResponse.actionId}');
  NotificationService.handleNotificationAction(notificationResponse);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService.showNotification(message);
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  ///  *********************************************
  ///     INITIALIZATION METHODS
  ///  *********************************************
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notification actions
  static final _actionStreamController =
      StreamController<NotificationAction>.broadcast();
  static Stream<NotificationAction> get actionStream =>
      _actionStreamController.stream;

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        print(
            'Foreground notification action: ${notificationResponse.actionId}');
        handleNotificationAction(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Only show our custom notification, suppress Firebase default
      showNotification(message);
      print('Received foreground message: ${message.messageId}');
    });

    // Handle notification opened when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.messageId}');
      // Handle app opening from notification
      _handleMessageOpenedApp(message);
    });

    // Handle notification when app is launched from terminated state
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.messageId}');
      _handleMessageOpenedApp(initialMessage);
    }
  }

  static showNotification(RemoteMessage message) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'SPEEDLOG_CLIENT_CHANNEL',
      'SpeedLog Client',
      channelDescription: 'Channel for SpeedLog client notifications',
      importance: Importance.max, // Changed to max for heads-up
      priority: Priority.max, // Changed to max for heads-up
      category: AndroidNotificationCategory.call, // Makes it heads-up eligible
      fullScreenIntent: true, // Forces heads-up display
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      usesChronometer: false,
      timeoutAfter: 30000, // Auto-dismiss after 30 seconds
      // actions: <AndroidNotificationAction>[
      //   AndroidNotificationAction(
      //     'id_1',
      //     'Accepter',
      //     icon: DrawableResourceAndroidBitmap('@android:drawable/ic_menu_send'),
      //   ),
      //   AndroidNotificationAction(
      //     'id_2',
      //     'Refuser',
      //     icon:
      //         DrawableResourceAndroidBitmap('@android:drawable/ic_menu_delete'),
      //   ),
      // ],
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
      message.data['title'] ?? message.notification?.title ?? 'SpeedLog',
      message.data['body'] ?? message.notification?.body ?? 'New notification',
      notificationDetails,
      payload: message.data.toString(), // Pass data as payload
    );
  }

  // Handle notification actions
  static void handleNotificationAction(
      NotificationResponse notificationResponse) {
    final actionId = notificationResponse.actionId;
    final payload = notificationResponse.payload;

    if (actionId != null) {
      final action = NotificationAction(
        actionId: actionId,
        payload: payload,
        notificationId: notificationResponse.id!,
      );

      // Add to stream for listeners
      _actionStreamController.add(action);

      // Handle specific actions
      switch (actionId) {
        case 'id_1': // Accepter
          _handleAcceptAction(action);
          break;
        case 'id_2': // Refuser
          _handleRefuseAction(action);
          break;
        default:
          _handleDefaultAction(action);
          break;
      }
    }
  }

  static void _handleAcceptAction(NotificationAction action) {
    print('User accepted the notification');
    // Add your accept logic here
    // For example: API call to accept a ride request
    // acceptRideRequest(action.payload);

    // Cancel the notification
    cancelNotification(action.notificationId);
  }

  static void _handleRefuseAction(NotificationAction action) {
    print('User refused the notification');
    // Add your refuse logic here
    // For example: API call to refuse a ride request
    // refuseRideRequest(action.payload);

    // Cancel the notification
    cancelNotification(action.notificationId);
  }

  static void _handleDefaultAction(NotificationAction action) {
    print('Default notification action: ${action.actionId}');
    // Handle any other actions or default tap
  }

  // Handle when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Add your navigation logic here
    print('App opened from notification: ${message.data}');
    // Example: Navigate to specific screen based on message data
    // if (message.data['type'] == 'ride_request') {
    //   Navigator.pushNamed(context, '/ride-request', arguments: message.data);
    // }
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Dispose resources
  static void dispose() {
    _actionStreamController.close();
  }
}

// Data class for notification actions
class NotificationAction {
  final String actionId;
  final String? payload;
  final int notificationId;

  NotificationAction({
    required this.actionId,
    this.payload,
    required this.notificationId,
  });

  @override
  String toString() {
    return 'NotificationAction{actionId: $actionId, payload: $payload, notificationId: $notificationId}';
  }
}

// Usage example in your main app
class NotificationActionHandler {
  late StreamSubscription<NotificationAction> _actionSubscription;

  void initialize() {
    // Listen to notification actions
    _actionSubscription = NotificationService.actionStream.listen((action) {
      print('Received action: ${action.actionId}');

      // Handle actions in your app
      switch (action.actionId) {
        case 'id_1':
          // Navigate to accept screen or perform accept action
          handleAccept(action.payload);
          break;
        case 'id_2':
          // Navigate to refuse screen or perform refuse action
          handleRefuse(action.payload);
          break;
      }
    });
  }

  void handleAccept(String? payload) {
    // Your accept logic here
    print('Handling accept action with payload: $payload');
    // Example: Navigate to ride details screen
    // Navigator.pushNamed(context, '/ride-details', arguments: payload);
  }

  void handleRefuse(String? payload) {
    // Your refuse logic here
    print('Handling refuse action with payload: $payload');
    // Example: Show confirmation dialog
    // showRefuseConfirmationDialog();
  }

  void dispose() {
    _actionSubscription.cancel();
  }
}
