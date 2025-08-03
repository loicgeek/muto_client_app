// CourierModel class
class CourierModel {
  final int? id;
  final int? userId;
  final String? idCardNumber;
  final String? driverLicenseNumber;
  final int? activeVehicleId;
  final String? photo;
  final String? address;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? online;
  final String? lastLatitude;
  final String? lastLongitude;
  final DateTime? lastLocationUpdatedAt;

  CourierModel({
    this.id,
    this.userId,
    this.idCardNumber,
    this.driverLicenseNumber,
    this.activeVehicleId,
    this.photo,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.online,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationUpdatedAt,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'],
      userId: json['user_id'],
      idCardNumber: json['id_card_number'],
      driverLicenseNumber: json['driver_license_number'],
      activeVehicleId: int.tryParse("${json['active_vehicle_id']}") ?? 0,
      photo: json['photo'],
      address: json['address'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      online: json['online'],
      lastLatitude: json['last_latitude'],
      lastLongitude: json['last_longitude'],
      lastLocationUpdatedAt: json['last_location_updated_at'] != null
          ? DateTime.parse(json['last_location_updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'id_card_number': idCardNumber,
      'driver_license_number': driverLicenseNumber,
      'active_vehicle_id': activeVehicleId,
      'photo': photo,
      'address': address,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'online': online,
      'last_latitude': lastLatitude,
      'last_longitude': lastLongitude,
      'last_location_updated_at': lastLocationUpdatedAt?.toIso8601String(),
    };
  }
}
