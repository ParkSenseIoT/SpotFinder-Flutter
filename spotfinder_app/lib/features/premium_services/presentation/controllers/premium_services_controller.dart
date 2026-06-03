import 'package:flutter/foundation.dart';

import '../../domain/entities/premium_service_entity.dart';

/// US17 — keeps track of services the driver requested in the current session.
///
/// Currently local-only: the backend Wallet/Premium endpoints are still SS04.
/// When `/api/v1/premium-services` exists, replace this with a real repository
/// call (mirrors how vehicles_controller talks to the backend).
class PremiumServicesController extends ChangeNotifier {
  PremiumServicesController({required this.userId});

  final int userId;

  final List<PremiumServiceEntity> _catalog = List.of(kPremiumServiceCatalog);
  List<PremiumServiceEntity> get catalog => List.unmodifiable(_catalog);

  final List<_RequestedService> _requested = [];
  List<_RequestedService> get requested => List.unmodifiable(_requested);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> request({required PremiumServiceEntity service, String? note}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 280));
      _requested.add(_RequestedService(service: service, note: note, requestedAt: DateTime.now()));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'No se pudo registrar el servicio.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

class _RequestedService {
  _RequestedService({required this.service, required this.note, required this.requestedAt});

  final PremiumServiceEntity service;
  final String? note;
  final DateTime requestedAt;
}
