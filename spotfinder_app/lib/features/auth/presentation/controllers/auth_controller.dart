import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserEntity? _user;
  UserEntity? get user => _user;

  AuthController(this.loginUseCase);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulación de validación basada en los protocolos de SpotFinder
      _user = await loginUseCase.execute(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}