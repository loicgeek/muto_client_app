import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muto_driver_app/app/ui/app_config.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;
  bool _isServiceRunning = false;

  Future<bool> initialize({
    bool? isOnline,
    String? currentDeliveryId,
  }) async {
    try {
      var hasPermission = await _requestPermissions();
      if (!hasPermission) {
        return false;
      }

      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'driver_location_service',
          channelName: 'Driver Location Service',
          channelDescription: 'Keeps track of driver location for deliveries',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(30000),
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );

      // await FlutterForegroundTask.saveData(key: 'auth_token', value: token);
      await FlutterForegroundTask.saveData(
        key: 'driver_is_online',
        value: isOnline == true,
      );
      if (currentDeliveryId != null) {
        await FlutterForegroundTask.saveData(
            key: 'current_delivery_id', value: currentDeliveryId);
      }

      return true;
    } catch (e) {
      debugPrint('Failed to initialize location service: $e');
      return false;
    }
  }

  Future<bool> startLocationService() async {
    if (_isServiceRunning) return true;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      final isStarted = await FlutterForegroundTask.startService(
        notificationTitle: 'Driver Location Service',
        notificationText: 'Tracking location for deliveries',
        callback: _startLocationCallback,
      );
      if (isStarted is ServiceRequestFailure) {
        throw Exception(isStarted.error);
      }

      if (isStarted is ServiceRequestSuccess) {
        _isServiceRunning = true;
      }
      return _isServiceRunning;
    } catch (e) {
      debugPrint('Failed to start location service: $e');
      return false;
    }
  }

  Future<bool> stopLocationService() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      final isStopped = await FlutterForegroundTask.stopService();
      _isServiceRunning = false;
      return isStopped is ServiceRequestSuccess;
    } catch (e) {
      debugPrint('Failed to stop location service: $e');
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }

    if (locationPermission == LocationPermission.deniedForever) {
      return false;
    }

    if (Platform.isAndroid) {
      final backgroundStatus = await Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        final result = await Permission.locationAlways.request();
        if (!result.isGranted) {
          return false;
        }
      }
      if ((await Permission.notification.status).isDenied) {
        await Permission.notification.request();
      }
    }

    return locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always;
  }
}

@pragma('vm:entry-point')
void _startLocationCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('Location task started at $timestamp');
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        // distanceFilter: 10,
      ),
    ).listen(_onLocationUpdate);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      if (_lastPosition == null ||
          _lastUpdateTime == null ||
          DateTime.now().difference(_lastUpdateTime!).inMinutes > 2) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );
        await _updateLocationToServer(position);
        _lastPosition = position;
        _lastUpdateTime = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error in location task event: $e');
    }

    FlutterForegroundTask.updateService(
        notificationTitle: 'Driver Location Service',
        notificationText: _lastPosition != null
            ? 'Last updated: ${DateTime.now().toLocal().toIso8601String()}'
            : 'Getting location...');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _positionStream?.cancel();
    _positionStream = null;
    debugPrint('Location task destroyed');
  }

  void _onLocationUpdate(Position position) async {
    if (_shouldUpdateLocation(position)) {
      await _updateLocationToServer(position);
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
    }
  }

  bool _shouldUpdateLocation(Position position) {
    if (_lastPosition == null || _lastUpdateTime == null) return true;
    final timeDiff = DateTime.now().difference(_lastUpdateTime!);
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    return timeDiff.inSeconds >= 30 || distance >= 50;
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      final token = await FlutterForegroundTask.getData<String>(key: 'token');
      final isOnline =
          await FlutterForegroundTask.getData<bool>(key: 'driver_is_online') ??
              false;
      final deliveryId = await FlutterForegroundTask.getData<String>(
        key: 'current_delivery_id',
      );

      if (token == null || !isOnline) return;

      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final body = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'type': deliveryId != null ? 'delivery' : 'general',
        if (deliveryId != null) 'id': deliveryId,
      };
      debugPrint('Updating location: $body');

      final response =
          await dio.post('/deliveries/update-location', data: body);
      debugPrint('Location update: ${response.statusCode}');
    } catch (e) {
      debugPrint('Failed to send location: $e');
    }
  }
}
