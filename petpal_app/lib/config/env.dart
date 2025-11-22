/// Environment configuration
/// In production, use environment variables or a config file
class Env {
  // Firebase configuration is handled by firebase_options.dart
  // This file can be used for other environment-specific settings
  
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  // Add other environment variables here as needed
  // Example: API endpoints, feature flags, etc.
}

