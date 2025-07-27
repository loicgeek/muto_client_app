import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
