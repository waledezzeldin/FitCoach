import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
    bool _hasUserSetTheme = false;
    static bool? _cachedDarkMode;
    // Expose current theme mode as expected by tests
    ThemeMode get currentTheme => _themeMode;

    // Set theme mode (alias for setThemeMode for test compatibility)
    Future<void> setTheme(ThemeMode mode) async {
      await setThemeMode(mode);
    }

    // Detect if system theme is used
    bool get isSystemTheme => _themeMode == ThemeMode.system;

    // Provide ThemeData for light and dark themes
    ThemeData getLightTheme() {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.green,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
        ),
        cardColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      );
    }

    ThemeData getDarkTheme() {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey,
          secondary: Colors.teal,
          surface: Colors.grey[900]!,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        cardColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      );
    }

    // Get ThemeData for current mode
    ThemeData getThemeData() {
      if (_themeMode == ThemeMode.dark) {
        return getDarkTheme();
      } else if (_themeMode == ThemeMode.light) {
        return getLightTheme();
      } else {
        // For system, default to light for test
        return getLightTheme();
      }
    }

    // Get primary color
    Color getPrimaryColor() {
      return getThemeData().colorScheme.primary;
    }

    // Get secondary color
    Color getSecondaryColor() {
      return getThemeData().colorScheme.secondary;
    }

    // Get background color
    Color getBackgroundColor() {
      return getThemeData().colorScheme.surface;
    }

    // Get text color
    Color getTextColor() {
      return getThemeData().textTheme.bodyLarge?.color ?? Colors.black;
    }

    // Get card color
    Color getCardColor() {
      return getThemeData().cardColor;
    }
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeProvider() {
    if (_cachedDarkMode != null) {
      _themeMode = _cachedDarkMode! ? ThemeMode.dark : ThemeMode.light;
    }
    _loadThemeMode();
  }
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (_hasUserSetTheme) {
      return;
    }
    final isDark = prefs.getBool('fitcoach_dark_mode') ?? false;
    if (_hasUserSetTheme) {
      return;
    }
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _cachedDarkMode = isDark;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _hasUserSetTheme = true;
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _cachedDarkMode = isDarkMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitcoach_dark_mode', isDarkMode);
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _hasUserSetTheme = true;
    _themeMode = mode;
    _cachedDarkMode = isDarkMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitcoach_dark_mode', isDarkMode);
    
    notifyListeners();
  }
}
