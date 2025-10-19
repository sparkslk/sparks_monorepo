class ApiConfig {
  // Development URL - change this to your actual backend URL
  static const String developmentUrl = 'http://localhost:3000';

  // Production URL - update when you deploy
  static const String productionUrl = 'https://sparks.help';

  // Current environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Get the current base URL
  static String get baseUrl => isProduction ? productionUrl : developmentUrl;

  // API Endpoints
  static const String loginEndpoint = '/api/auth/mobile/credentials';
  static const String signupEndpoint = '/api/auth/signup';
  static const String googleSignInEndpoint = '/api/auth/signin/google';
  static const String logoutEndpoint = '/api/auth/signout';
  static const String profileEndpoint = '/api/profile';

  // Request timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}
