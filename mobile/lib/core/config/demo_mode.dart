const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

class DemoModeConfig {
  const DemoModeConfig();

  bool get isDemo => kDemoMode;
}
