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
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) => CourierModel(
        id: json['id'],
        userId: json['user_id'],
        idCardNumber: json['id_card_number'],
        driverLicenseNumber: json['driver_license_number'],
        activeVehicleId: json['active_vehicle_id'],
        photo: json['photo'],
        address: json['address'],
        status: json['status'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
      );
}
