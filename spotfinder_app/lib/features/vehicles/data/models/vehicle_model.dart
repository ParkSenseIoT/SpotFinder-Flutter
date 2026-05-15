import '../../domain/entities/vehicle_entity.dart';

/// JSON mapper for the backend's `VehicleResource`.
class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.plate,
    super.brand,
    super.model,
    super.color,
    super.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['createdAt'];
    if (raw is String && raw.isNotEmpty) {
      created = DateTime.tryParse(raw);
    }
    return VehicleModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      plate: (json['plate'] ?? '').toString(),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      createdAt: created,
    );
  }
}
