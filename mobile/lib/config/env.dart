// env.dart placeholder
class Env {
  // Run with: flutter run --dart-define=DEMO=true
  static const bool demo = bool.fromEnvironment('DEMO', defaultValue: false);

  // Example API base (ignored in demo)
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:3000',
  );
}
