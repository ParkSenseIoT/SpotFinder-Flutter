import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Mirror of the backend `SlotStatus` enum.
enum SlotStatus {
  available,
  occupied,
  outOfService,
  evacuation;

  static SlotStatus fromString(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'AVAILABLE':
        return SlotStatus.available;
      case 'OCCUPIED':
        return SlotStatus.occupied;
      case 'OUT_OF_SERVICE':
        return SlotStatus.outOfService;
      case 'EVACUATION':
        return SlotStatus.evacuation;
      default:
        return SlotStatus.outOfService;
    }
  }

  Color get color {
    switch (this) {
      case SlotStatus.available:
        return const Color(0xFF22C55E); // green
      case SlotStatus.occupied:
        return const Color(0xFFEF4444); // red
      case SlotStatus.outOfService:
        return AppColors.textGray;
      case SlotStatus.evacuation:
        return Colors.orange;
    }
  }

  String get label {
    switch (this) {
      case SlotStatus.available:
        return 'Available';
      case SlotStatus.occupied:
        return 'Occupied';
      case SlotStatus.outOfService:
        return 'Out of service';
      case SlotStatus.evacuation:
        return 'Evacuation';
    }
  }
}

/// Domain object for a parking slot displayed in the grid.
class ParkingSlotEntity {
  final int id;
  final String slotCode;
  final SlotStatus status;
  final String? sensorId;
  final int? facilityId;
  final DateTime? lastUpdated;

  const ParkingSlotEntity({
    required this.id,
    required this.slotCode,
    required this.status,
    this.sensorId,
    this.facilityId,
    this.lastUpdated,
  });

  ParkingSlotEntity copyWith({SlotStatus? status, DateTime? lastUpdated}) {
    return ParkingSlotEntity(
      id: id,
      slotCode: slotCode,
      status: status ?? this.status,
      sensorId: sensorId,
      facilityId: facilityId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
