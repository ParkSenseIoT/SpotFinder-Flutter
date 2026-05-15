import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT (and a few minimal user fields) across app launches.
/// Wrapped so the rest of the app never touches `FlutterSecureStorage` directly.
class TokenStorage {
  static const _tokenKey = 'sf.jwt';
  static const _userIdKey = 'sf.userId';
  static const _emailKey = 'sf.email';
  static const _rolesKey = 'sf.roles';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
    required List<String> roles,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _rolesKey, value: roles.join(','));
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<int?> getUserId() async {
    final v = await _storage.read(key: _userIdKey);
    return v == null ? null : int.tryParse(v);
  }

  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<List<String>> getRoles() async {
    final v = await _storage.read(key: _rolesKey);
    if (v == null || v.isEmpty) return const [];
    return v.split(',');
  }

  Future<bool> hasSession() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _rolesKey);
  }
}
