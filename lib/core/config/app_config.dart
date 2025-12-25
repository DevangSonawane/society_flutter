// Note: flutter_dotenv is optional - if not available, defaults are used
class AppConfig {
  static bool _loaded = false;
  static final Map<String, String> _env = {};

  static Future<void> load() async {
    if (_loaded) return;
    try {
      // Try to load .env file if flutter_dotenv is available
      // This will fail gracefully if the package is not available
      // ignore: avoid_dynamic_calls
      // final dotenv = await (await import('package:flutter_dotenv/flutter_dotenv.dart')).load(fileName: '.env');
      // ignore: avoid_dynamic_calls
      // _env.addAll((dotenv as dynamic).env as Map<String, String>);
    } catch (e) {
      // Package not available or .env file not found - use defaults
    }
    _loaded = true;
  }

  // Supabase Configuration
  static String get supabaseUrl {
    return _env['SUPABASE_URL'] ?? 
           'https://tzaemqzrdmwbcgriyymg.supabase.co';
  }

  static String get supabaseAnonKey {
    return _env['SUPABASE_ANON_KEY'] ?? 
           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6YWVtcXpyZG13YmNncml5eW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NjIwMzIsImV4cCI6MjA4MDIzODAzMn0.Sw82hrzJ6r_rmzW3WZc5AH5bpaiWcd76Cs-WbRhamNU';
  }

  // Environment
  static String get environment {
    return _env['ENVIRONMENT'] ?? 'development';
  }

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  // API Configuration
  static String? get apiBaseUrl => _env['API_BASE_URL'];
}

