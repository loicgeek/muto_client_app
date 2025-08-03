import 'package:dio/dio.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({required Dio dio}) : _dio = dio;

  Future saveNotificationToken({
    required String token,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      await _dio.post(
        '/fcm-token',
        data: {
          'token': token,
          'device_id': deviceId,
          'device_name': deviceName,
        },
      );
    } catch (e) {
      throw e;
    }
  }
}
