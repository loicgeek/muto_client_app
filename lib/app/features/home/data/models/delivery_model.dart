// Main Delivery class
import 'package:muto_client_app/app/features/authentication/data/models/courier_model.dart';

class DeliveryModel {
  final int? id;
  final int? clientId;
  final int? courierId;
  final int? vehicleId;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final DateTime? pickupScheduledAt;
  final DateTime? pickupActualAt;
  final String? dropoffAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final DateTime? dropoffScheduledAt;
  final DateTime? dropoffActualAt;
  final String? weightKg;
  final String? lengthCm;
  final String? widthCm;
  final String? heightCm;
  final int? packageCount;
  final String? contentType;
  final String? handlingInstructions;
  final double? distanceKm;
  final int? durationMinutes;
  final String? price;
  final String? courierFee;
  final String? status;
  final String? notes;
  final DateTime? assignedAt;
  final DateTime? deliveredAt;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? vehicleType;
  final CourierModel? courier;
  final Client? client;
  final Vehicle? vehicle;
  final DeliveryRoute? route;

  DeliveryModel({
    this.id,
    this.clientId,
    this.courierId,
    this.vehicleId,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupScheduledAt,
    this.pickupActualAt,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.dropoffScheduledAt,
    this.dropoffActualAt,
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.packageCount,
    this.contentType,
    this.handlingInstructions,
    this.distanceKm,
    this.durationMinutes,
    this.price,
    this.courierFee,
    this.status,
    this.notes,
    this.assignedAt,
    this.deliveredAt,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.vehicleType,
    this.courier,
    this.client,
    this.vehicle,
    this.route,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      clientId: json['client_id'],
      courierId: json['courier_id'],
      vehicleId: json['vehicle_id'],
      pickupAddress: json['pickup_address'],
      pickupLatitude: double.tryParse("${json['pickup_latitude']}"),
      pickupLongitude: double.tryParse("${json['pickup_longitude']}"),
      pickupScheduledAt: json['pickup_scheduled_at'] != null
          ? DateTime.parse(json['pickup_scheduled_at'])
          : null,
      pickupActualAt: json['pickup_actual_at'] != null
          ? DateTime.parse(json['pickup_actual_at'])
          : null,
      dropoffAddress: json['dropoff_address'],
      dropoffLatitude: double.tryParse("${json['dropoff_latitude']}"),
      dropoffLongitude: double.tryParse("${json['dropoff_longitude']}"),
      dropoffScheduledAt: json['dropoff_scheduled_at'] != null
          ? DateTime.parse(json['dropoff_scheduled_at'])
          : null,
      dropoffActualAt: json['dropoff_actual_at'] != null
          ? DateTime.parse(json['dropoff_actual_at'])
          : null,
      weightKg: json['weight_kg'],
      lengthCm: json['length_cm'],
      widthCm: json['width_cm'],
      heightCm: json['height_cm'],
      packageCount: json['package_count'],
      contentType: json['content_type'],
      handlingInstructions: json['handling_instructions'],
      distanceKm: json['distance_km']?.toDouble(),
      durationMinutes: json['duration_minutes'],
      price: json['price'],
      courierFee: json['courier_fee'],
      status: json['status'],
      notes: json['notes'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      vehicleType: json['vehicle_type'],
      courier: json['courier'] != null
          ? CourierModel.fromJson(json['courier'])
          : null,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      route:
          json['route'] != null ? DeliveryRoute.fromJson(json['route']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'courier_id': courierId,
      'vehicle_id': vehicleId,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_scheduled_at': pickupScheduledAt?.toIso8601String(),
      'pickup_actual_at': pickupActualAt?.toIso8601String(),
      'dropoff_address': dropoffAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'dropoff_scheduled_at': dropoffScheduledAt?.toIso8601String(),
      'dropoff_actual_at': dropoffActualAt?.toIso8601String(),
      'weight_kg': weightKg,
      'length_cm': lengthCm,
      'width_cm': widthCm,
      'height_cm': heightCm,
      'package_count': packageCount,
      'content_type': contentType,
      'handling_instructions': handlingInstructions,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'price': price,
      'courier_fee': courierFee,
      'status': status,
      'notes': notes,
      'assigned_at': assignedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'vehicle_type': vehicleType,
      'courier': courier?.toJson(),
      'client': client?.toJson(),
      'vehicle': vehicle?.toJson(),
      'route': route?.toJson(),
    };
  }
}

// Client class
class Client {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime? emailVerifiedAt;
  final String? fcmToken;
  final String? deviceTokens;
  final String? preferredLanguage;
  final String? role;
  final DateTime? lastLoginAt;
  final DateTime? verificationCodeExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.fcmToken,
    this.deviceTokens,
    this.preferredLanguage,
    this.role,
    this.lastLoginAt,
    this.verificationCodeExpiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      fcmToken: json['fcm_token'],
      deviceTokens: json['device_tokens'],
      preferredLanguage: json['preferred_language'],
      role: json['role'],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      verificationCodeExpiresAt: json['verification_code_expires_at'] != null
          ? DateTime.parse(json['verification_code_expires_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'device_tokens': deviceTokens,
      'preferred_language': preferredLanguage,
      'role': role,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'verification_code_expires_at':
          verificationCodeExpiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Vehicle class
class Vehicle {
  final int? id;
  final int? courierId;
  final String? make;
  final int? year;
  final String? model;
  final String? licensePlate;
  final String? color;
  final String? type;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vehicle({
    this.id,
    this.courierId,
    this.make,
    this.year,
    this.model,
    this.licensePlate,
    this.color,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      courierId: json['courier_id'],
      make: json['make'],
      year: json['year'],
      model: json['model'],
      licensePlate: json['license_plate'],
      color: json['color'],
      type: json['type'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courier_id': courierId,
      'make': make,
      'year': year,
      'model': model,
      'license_plate': licensePlate,
      'color': color,
      'type': type,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DeliveryRoute {
  List<List<num>>? geometry;
  DeliveryRoute({
    this.geometry,
  });
  factory DeliveryRoute.fromJson(Map<String, dynamic> json) {
    return DeliveryRoute(
      geometry: json['geometry'] != null
          ? (List<List<num>>.from(
              json['geometry'].map((x) => List<num>.from(x))))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geometry': geometry,
    };
  }
}
