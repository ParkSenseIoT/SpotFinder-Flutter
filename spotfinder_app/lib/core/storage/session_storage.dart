abstract class SessionStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> saveUserId(int userId);
  Future<int?> readUserId();
  Future<void> saveUserEmail(String email);
  Future<String?> readUserEmail();
  Future<void> clear();
}
