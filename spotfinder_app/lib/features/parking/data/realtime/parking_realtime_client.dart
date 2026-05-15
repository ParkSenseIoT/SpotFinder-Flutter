import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/api_config.dart';
import '../../domain/entities/occupancy_summary_entity.dart';
import '../../domain/entities/parking_slot_entity.dart';
import '../models/occupancy_summary_model.dart';

/// Lightweight push from the backend describing a slot status change.
/// Mirrors the payload broadcast on `/topic/slots`.
class SlotStatusPush {
  const SlotStatusPush({
    required this.slotId,
    required this.slotCode,
    required this.status,
    this.updatedAt,
  });

  final int slotId;
  final String slotCode;
  final SlotStatus status;
  final DateTime? updatedAt;

  static SlotStatusPush? tryParse(Map<String, dynamic> json) {
    final id = json['slotId'];
    if (id is! num) return null;
    return SlotStatusPush(
      slotId: id.toInt(),
      slotCode: (json['slotCode'] ?? '').toString(),
      status: SlotStatus.fromString(json['status'] as String?),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

/// Subscribes to the backend's STOMP topics and emits typed updates.
///
/// Topics (see `WebSocketBroadcaster` on the server):
///   * `/topic/slots`     — individual `SlotStatusPush`
///   * `/topic/occupancy` — overall `OccupancySummaryEntity`
class ParkingRealtimeClient {
  ParkingRealtimeClient();

  StompClient? _client;
  final _slotController = StreamController<SlotStatusPush>.broadcast();
  final _occupancyController = StreamController<OccupancySummaryEntity>.broadcast();

  Stream<SlotStatusPush> get slotUpdates => _slotController.stream;
  Stream<OccupancySummaryEntity> get occupancyUpdates => _occupancyController.stream;

  bool get isConnected => _client?.connected ?? false;

  /// Open the WebSocket and subscribe to the slot/occupancy topics.
  /// Safe to call multiple times — repeated calls are no-ops while connected.
  void connect() {
    if (isConnected) return;
    // Native STOMP-over-WebSocket endpoint registered in the backend
    // (see WebSocketConfiguration.registerStompEndpoints — no withSockJS()).
    final url = _toWebSocketUrl('${ApiConfig.baseUrl}/ws/parking');

    _client = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnect,
        onWebSocketError: (e) => debugPrint('STOMP error: $e'),
        onDisconnect: (_) => debugPrint('STOMP disconnected'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _client!.subscribe(
      destination: '/topic/slots',
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final push = SlotStatusPush.tryParse(json);
          if (push != null) _slotController.add(push);
        } catch (_) {
          /* ignore malformed payloads */
        }
      },
    );
    _client!.subscribe(
      destination: '/topic/occupancy',
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _occupancyController.add(OccupancySummaryModel.fromJson(json));
        } catch (_) {
          /* ignore */
        }
      },
    );
  }

  Future<void> disconnect() async {
    _client?.deactivate();
    _client = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _slotController.close();
    await _occupancyController.close();
  }

  /// Translate `http(s)://host/...` into `ws(s)://host/...` so STOMP can use it.
  static String _toWebSocketUrl(String httpUrl) {
    if (httpUrl.startsWith('https://')) {
      return 'wss://${httpUrl.substring('https://'.length)}';
    }
    if (httpUrl.startsWith('http://')) {
      return 'ws://${httpUrl.substring('http://'.length)}';
    }
    return httpUrl;
  }
}
