import 'package:dio/dio.dart';
import 'package:muto_client_app/app/core/network/api_filter.dart';
import 'package:muto_client_app/app/core/network/pagination.dart';
import 'package:muto_client_app/app/features/home/data/models/delivery_model.dart';

class DeliveriesRepository {
  final Dio _dio;

  DeliveriesRepository({required Dio dio}) : _dio = dio;

  // Single method to fetch and filter deliveries with all options
  Future<PaginatedData<DeliveryModel>> fetchDeliveries(ApiFilter filter) async {
    try {
      final queryParams = filter.toQueryParameters();
      filter.withRelations(['courier', 'client', 'vehicle']);
      final response = await _dio.get(
        '/deliveries',
        queryParameters: queryParams,
      );
      return PaginatedData.fromJson(response.data, DeliveryModel.fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Single method to fetch and filter deliveries with all options
  Future<PaginatedData<DeliveryModel>> forCourier(ApiFilter filter) async {
    try {
      final queryParams = filter.toQueryParameters();
      filter.withRelations(['courier', 'client', 'vehicle']);
      final response = await _dio.get(
        '/deliveries',
        queryParameters: queryParams,
      );
      return PaginatedData.fromJson(response.data, DeliveryModel.fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<DeliveryModel> acceptDelivery(int deliveryId, int courierId) async {
    try {
      final response = await _dio.post('/deliveries/$deliveryId/assign', data: {
        'courier_id': courierId,
      });
      return DeliveryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<DeliveryModel> findOne(int deliveryId) async {
    try {
      final response = await _dio.get('/deliveries/$deliveryId');
      return DeliveryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<DeliveryModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/deliveries', data: data);
      return DeliveryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
}

// Helper method to handle Dio exceptions
Exception _handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Exception(
          'Connection timeout. Please check your internet connection.');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final message = e.response?.data['message'] ?? 'Server error occurred';
      return Exception('HTTP $statusCode: $message');
    case DioExceptionType.cancel:
      return Exception('Request was cancelled');
    case DioExceptionType.connectionError:
      return Exception('No internet connection');
    default:
      return Exception('An unexpected error occurred: ${e.message}');
  }
}
