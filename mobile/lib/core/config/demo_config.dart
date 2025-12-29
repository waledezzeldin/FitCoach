class DemoConfig {
  static const bool isDemo = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  static const String demoUserId = 'demo-user';
  static const String demoCoachId = 'demo-coach';
  static const String demoAdminId = 'demo-admin';
}
