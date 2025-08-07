import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';

import 'package:muto_client_app/app/features/notifications/data/services/notification_service.dart';

void bootstrap({
  required FutureOr<Widget> Function() builder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  getIt.get<AuthenticationCubit>().checkAuth();
  FlutterForegroundTask.initCommunicationPort();
  await NotificationService.initializeRemoteNotifications(debug: kDebugMode);

  // Initialize on app start
  //await LocationService.instance.initialize(isOnline: true);

// // When driver goes online
// await LocationHelper.setDriverOnlineStatus(true);

// // When accepting delivery
// await LocationHelper.setCurrentDeliveryId('DEL-2024-001');

// // When completing delivery
// await LocationHelper.setCurrentDeliveryId(null);

// // When driver goes offline
// await LocationHelper.setDriverOnlineStatus(false);

  runApp(await builder());
}
