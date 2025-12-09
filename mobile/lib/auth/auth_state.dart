import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  static const _kLoggedInKey = 'auth.logged_in';
  bool _loggedIn = false;
  String? _email;
  bool _loaded = false;

  bool get isLoggedIn => _loggedIn;
  String? get email => _email;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    _email = prefs.getString('auth.email');
    _loaded = true;
    notifyListeners();
  }

  Future<void> login(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = true;
    _email = email;
    await prefs.setBool(_kLoggedInKey, true);
    await prefs.setString('auth.email', email);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = false;
    _email = null;
    await prefs.remove(_kLoggedInKey);
    await prefs.remove('auth.email');
    notifyListeners();
  }
}
