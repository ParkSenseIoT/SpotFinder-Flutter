/// SpotFinder backend configuration.
///
/// Override [baseUrl] at run time with:
/// `flutter run --dart-define=SPOTFINDER_API_URL=http://10.0.2.2:8080`
///
/// Default values target a local backend:
///   * Android emulator → `10.0.2.2` is the host machine
///   * iOS simulator    → `localhost`
///   * Physical device  → use your machine's LAN IP
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'SPOTFINDER_API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
