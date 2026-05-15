class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.environment});

  final String apiBaseUrl;
  final String environment;

  static const AppConfig dev = AppConfig(
    apiBaseUrl: 'http://10.0.2.2:8080/api/v1',
    environment: 'dev',
  );

  static const AppConfig prod = AppConfig(
    apiBaseUrl: 'https://api.spotfinder.app/api/v1',
    environment: 'prod',
  );
}
