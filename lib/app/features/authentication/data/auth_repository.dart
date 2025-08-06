import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:muto_driver_app/app/features/authentication/data/models/courier_model.dart';
import 'package:muto_driver_app/app/features/authentication/data/models/document_upload.dart';
import 'package:muto_driver_app/app/features/authentication/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({required Dio dio}) : _dio = dio;
  Future<void> _saveSession({required String token}) async {
    var storage = const FlutterSecureStorage();
    await FlutterForegroundTask.saveData(key: 'token', value: token);
    storage.write(key: 'token', value: token);
  }

  Future<void> _removeSession() async {
    await FlutterForegroundTask.saveData(key: 'token', value: '');
    await const FlutterSecureStorage().delete(key: 'token');
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    await _saveSession(token: response.data['token']);
    return UserModel.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _removeSession();
  }

  Future<UserModel> getAuthenticatedUser() async {
    final response = await _dio.get('/auth/me',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ));
    return UserModel.fromJson(response.data);
  }

  Future<CourierModel> updateCourierOnlineStatus({
    required int id,
    required bool isOnline,
  }) async {
    final response = await _dio.put(
      '/couriers/$id',
      data: {
        'online': isOnline,
      },
    );
    return CourierModel.fromJson(response.data);
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String idCardNumber,
    required String driverLicenseNumber,
    required String address,
    List<DocumentUpload>? documents,
  }) async {
    final formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': "courier",
      'password': password,
      'password_confirmation': passwordConfirmation,
      'id_card_number': idCardNumber,
      'driver_license_number': driverLicenseNumber,
      'address': address,
    });

    // Add documents if provided
    if (documents != null) {
      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i];
        formData.fields.add(MapEntry('documents[$i][type]', doc.type));

        if (doc.file != null) {
          final multipartFile = await MultipartFile.fromFile(
            doc.file!.path,
            filename: doc.file!.path.split('/').last,
            contentType:
                MediaType('image', 'jpeg'), // Adjust based on file type
          );
          formData.files.add(MapEntry('documents[$i][file]', multipartFile));
        }
      }
    }

    final response = await _dio.post(
      '/auth/register',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response;
  }

  Future sendResetPasswordEmail({required String email}) async {
    final response = await _dio.post(
      '/auth/forgot-password',
      data: {
        'email': email,
      },
    );
    return response.data;
  }

  Future<dynamic> resetPassword({
    required String token,
    required String password,
    required String email,
  }) async {
    final response = await _dio.post(
      '/auth/reset-password',
      data: {
        'code': token,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    return response.data;
  }
}
