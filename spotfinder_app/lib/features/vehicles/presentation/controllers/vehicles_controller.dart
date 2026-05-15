import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/vehicle_usecases.dart';

/// State holder for the Vehicles screens. One controller per logged-in user.
class VehiclesController extends ChangeNotifier {
  VehiclesController({required this.userId, VehicleRepository? repository})
      : _repository = repository ?? VehicleRepositoryImpl() {
    _listUseCase = ListVehiclesUseCase(_repository);
    _registerUseCase = RegisterVehicleUseCase(_repository);
    _deleteUseCase = DeleteVehicleUseCase(_repository);
  }

  final int userId;
  final VehicleRepository _repository;
  late final ListVehiclesUseCase _listUseCase;
  late final RegisterVehicleUseCase _registerUseCase;
  late final DeleteVehicleUseCase _deleteUseCase;

  List<VehicleEntity> _vehicles = const [];
  List<VehicleEntity> get vehicles => _vehicles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Refresh the list from the backend.
  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _vehicles = await _listUseCase.execute(userId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los vehículos.';
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new vehicle. Returns true on success.
  Future<bool> register({
    required String plate,
    String? brand,
    String? model,
    String? color,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final created = await _registerUseCase.execute(
        userId: userId,
        plate: plate,
        brand: brand,
        model: model,
        color: color,
      );
      _vehicles = [..._vehicles, created];
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado al registrar el vehículo.';
      _setLoading(false);
      return false;
    }
  }

  /// Delete a vehicle by id. Returns true on success.
  Future<bool> delete(int vehicleId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _deleteUseCase.execute(userId: userId, vehicleId: vehicleId);
      _vehicles = _vehicles.where((v) => v.id != vehicleId).toList(growable: false);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado al eliminar el vehículo.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
