import 'dart:convert';

import '../../../core/network/api_client.dart';

/// Snapshot of the on-demand capture gate returned by the backend proxy.
class CaptureState {
  const CaptureState({
    required this.capturing,
    required this.recognized,
    this.plate,
  });

  /// Whether the camera is currently allowed to shoot.
  final bool capturing;

  /// Whether a plate has already been recognized in this capture round.
  final bool recognized;

  /// The recognized plate text, when [recognized] is true.
  final String? plate;

  factory CaptureState.fromJson(Map<String, dynamic> json) => CaptureState(
        capturing: json['capture'] == true,
        recognized: json['recognized'] == true,
        plate: json['plate'] as String?,
      );
}

/// Drives on-demand plate capture through the backend proxy
/// (`/api/v1/access/capture/*`), which forwards to the Edge Gateway that gates
/// the ESP32-CAM. Idle = the camera shoots nothing, so no ALPR quota is spent.
class PlateCaptureService {
  PlateCaptureService([ApiClient? client]) : _api = client ?? ApiClient();

  final ApiClient _api;

  static const String _base = '/api/v1/access/capture';

  /// User pressed "Verificar placa": turn the camera on.
  Future<CaptureState> start() async {
    final res = await _api.post('$_base/start');
    return CaptureState.fromJson(_asMap(res.data));
  }

  /// Cancel the verification and turn the camera off.
  Future<void> stop() async {
    await _api.post('$_base/stop');
  }

  /// Poll the gate: capturing? recognized? which plate?
  Future<CaptureState> status() async {
    final res = await _api.get(_base);
    return CaptureState.fromJson(_asMap(res.data));
  }

  /// The proxy replies with a JSON string body; Dio may hand it back already
  /// parsed as a Map or still as text, so normalize both.
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return data.cast<String, dynamic>();
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    }
    return const {};
  }
}
