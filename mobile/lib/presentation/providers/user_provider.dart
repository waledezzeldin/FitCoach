import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository;
  
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;
  
  UserProvider(this._repository);
  
  // Getters
  UserProfile? get profile => _profile;
  UserProfile? get user => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final profile = await _repository.getUserProfile();
      _profile = profile;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Replace 'userId' with the actual user ID or required argument
      final updatedProfileMap = await _repository.updateProfile(_profile?.id ?? '', updates);
      _profile = UserProfile.fromJson(updatedProfileMap);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Submit first intake
  Future<bool> submitFirstIntake(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedProfile = await _repository.submitFirstIntake(data);
      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Submit second intake
  Future<bool> submitSecondIntake(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedProfile = await _repository.submitSecondIntake(data);
      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update subscription tier
  Future<bool> updateSubscription(String tier) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedProfile = await _repository.updateSubscription(tier);
      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Set profile (for initial load)
  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }
}
