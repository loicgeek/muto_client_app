import 'package:dio/dio.dart';

class ApiError {
  final String message;
  final Map<String, List<String>>? errors;
  final int? statusCode;

  ApiError({
    required this.message,
    this.errors,
    this.statusCode,
  });

  /// Factory constructor to parse from response data and status code
  factory ApiError.fromResponse(dynamic exception, {int? statusCode}) {
    String message = 'An unknown error occurred';
    Map<String, List<String>>? parsedErrors;
    var data;

    try {
      if (exception is DioException) {
        data = exception.response?.data;
        statusCode = exception.response?.statusCode;
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] is String) {
          message = data['message'];
        }

        if (data.containsKey('errors') &&
            data['errors'] is Map<String, dynamic>) {
          parsedErrors = data['errors'].map((key, value) {
            final List<String> messages = value is List
                ? value.map((e) => e.toString()).toList()
                : [value.toString()];
            return MapEntry(key, messages);
          });
        } else if (data['error'] is String) {
          message = data['error'];
        }
      } else if (data is String) {
        message = data;
      }
    } catch (e) {}

    return ApiError(
      message: message,
      errors: parsedErrors,
      statusCode: statusCode,
    );
  }

  /// Helper to get all errors as a flat list
  List<String> get allErrors {
    if (errors == null) return [];
    return errors!.values.expand((e) => e).toList();
  }

  /// Get the first validation error if any
  String? get firstError {
    return allErrors.isNotEmpty ? allErrors.first : null;
  }

  @override
  String toString() {
    return 'ApiError(message: $message, errors: $errors, statusCode: $statusCode)';
  }
}
