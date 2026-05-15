import '../entities/vehicle_entity.dart';
import '../../data/repositories/vehicle_repository_impl.dart';

class ListVehiclesUseCase {
  ListVehiclesUseCase(this.repository);
  final VehicleRepository repository;

  Future<List<VehicleEntity>> execute(int userId) => repository.listForUser(userId);
}

class RegisterVehicleUseCase {
  RegisterVehicleUseCase(this.repository);
  final VehicleRepository repository;

  Future<VehicleEntity> execute({
    required int userId,
    required String plate,
    String? brand,
    String? model,
    String? color,
  }) =>
      repository.register(userId: userId, plate: plate, brand: brand, model: model, color: color);
}

class DeleteVehicleUseCase {
  DeleteVehicleUseCase(this.repository);
  final VehicleRepository repository;

  Future<void> execute({required int userId, required int vehicleId}) =>
      repository.delete(userId: userId, vehicleId: vehicleId);
}
