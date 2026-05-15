/// Plain data carrier for a vehicle registered by a driver.
/// The UI uses this; never the JSON form directly.
class VehicleEntity {
  final int id;
  final int userId;
  final String plate;
  final String? brand;
  final String? model;
  final String? color;
  final DateTime? createdAt;

  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.plate,
    this.brand,
    this.model,
    this.color,
    this.createdAt,
  });

  /// Short label for list items, e.g. `"Toyota Yaris · Plata"` or just `"Plata"` when brand is unknown.
  String get descriptiveLabel {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    final left = parts.join(' ');
    if (left.isEmpty && (color == null || color!.isEmpty)) return '—';
    if (left.isEmpty) return color!;
    if (color == null || color!.isEmpty) return left;
    return '$left · $color';
  }
}
