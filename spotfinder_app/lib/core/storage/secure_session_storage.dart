import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_storage.dart';

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage(this._storage);

  static const _tokenKey = 'spotfinder.auth.token';
  static const _userIdKey = 'spotfinder.auth.userId';
  static const _userEmailKey = 'spotfinder.auth.email';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> saveUserId(int userId) => _storage.write(key: _userIdKey, value: userId.toString());

  @override
  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _userIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  @override
  Future<void> saveUserEmail(String email) => _storage.write(key: _userEmailKey, value: email);

  @override
  Future<String?> readUserEmail() => _storage.read(key: _userEmailKey);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
  }
}
