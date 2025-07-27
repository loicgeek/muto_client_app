import 'dart:async';

import 'package:flutter/material.dart';
import 'package:muto_driver_app/app/core/service_locator.dart';
import 'package:muto_driver_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_driver_app/app/features/notifications/data/services/notification_service.dart';

void bootstrap({
  required FutureOr<Widget> Function() builder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  getIt.get<AuthenticationCubit>().checkAuth();
  await NotificationService.initializeRemoteNotifications(debug: true);

  runApp(await builder());
}
