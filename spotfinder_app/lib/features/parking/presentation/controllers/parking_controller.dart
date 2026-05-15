import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/realtime/parking_realtime_client.dart';
import '../../data/repositories/parking_repository_impl.dart';
import '../../domain/entities/occupancy_summary_entity.dart';
import '../../domain/entities/parking_slot_entity.dart';

/// Holds the slot map state. Two sources of truth merged into one view:
///   1. REST `GET /parking-slots` on initial load + pull-to-refresh.
///   2. STOMP push at `/topic/slots` + `/topic/occupancy` for live updates.
class ParkingController extends ChangeNotifier {
  ParkingController({
    ParkingRepository? repository,
    ParkingRealtimeClient? realtime,
  })  : _repository = repository ?? ParkingRepositoryImpl(),
        _realtime = realtime ?? ParkingRealtimeClient();

  final ParkingRepository _repository;
  final ParkingRealtimeClient _realtime;

  StreamSubscription<SlotStatusPush>? _slotSub;
  StreamSubscription<OccupancySummaryEntity>? _occSub;

  List<ParkingSlotEntity> _slots = const [];
  List<ParkingSlotEntity> get slots => _slots;

  OccupancySummaryEntity _summary = OccupancySummaryEntity.empty();
  OccupancySummaryEntity get summary => _summary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLive = false;
  bool get isLive => _isLive;

  int? _facilityId;
  int? get facilityId => _facilityId;

  /// Initial load + start STOMP subscription.
  Future<void> start({int? facilityId}) async {
    _facilityId = facilityId;
    await refresh();
    _attachRealtime();
  }

  /// REST refresh, useful for pull-to-refresh or if the user changes facility.
  Future<void> refresh() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.listSlots(facilityId: _facilityId),
        _repository.occupancySummary(facilityId: _facilityId),
      ]);
      _slots = results[0] as List<ParkingSlotEntity>;
      _summary = results[1] as OccupancySummaryEntity;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudo cargar el mapa de espacios.';
    } finally {
      _setLoading(false);
    }
  }

  void _attachRealtime() {
    _slotSub ??= _realtime.slotUpdates.listen(_applySlotPush);
    _occSub ??= _realtime.occupancyUpdates.listen(_applyOccupancyPush);
    _realtime.connect();
    _isLive = true;
    notifyListeners();
  }

  void _applySlotPush(SlotStatusPush push) {
    final idx = _slots.indexWhere((s) => s.id == push.slotId);
    if (idx == -1) {
      // We don't have this slot yet — silently ignore. A pull-to-refresh will pick it up.
      return;
    }
    final updated = _slots[idx].copyWith(status: push.status, lastUpdated: push.updatedAt);
    final mutable = [..._slots];
    mutable[idx] = updated;
    _slots = mutable;
    notifyListeners();
  }

  void _applyOccupancyPush(OccupancySummaryEntity summary) {
    _summary = summary;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _slotSub?.cancel();
    _occSub?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}
