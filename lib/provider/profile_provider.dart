import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  ProfileModel? _userProfile;
  bool _isLoading = false;
  String _error = '';
  final ProfileService _profileService = ProfileService();

  ProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize and load profile data
  Future<void> initialize() async {
    if (_userProfile != null) return; // Already initialized
    await loadProfile();
  }

  // Load or reload profile data
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _profileService.getProfile();

      if (result["success"]) {
        _userProfile = result["profile"];
        _error = '';
      } else {
        _error = result["message"];
      }
    } catch (e) {
      _error = "Error loading profile: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update two-factor authentication setting
  Future<bool> updateTwoFactorAuthentication(bool enabled) async {
    if (_userProfile == null) return false;

    try {
      // Use the dedicated method for updating 2FA
      final result = await _profileService.updateTwoFactorAuth(enabled);

      if (result["success"]) {
        _userProfile = result["profile"];
        notifyListeners();
        return true;
      } else {
        _error = result["message"];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error updating two-factor authentication: $e";
      notifyListeners();
      return false;
    }
  }

  // Update language preference
  Future<bool> updateLanguage(String languageCode) async {
    if (_userProfile == null) return false;

    try {
      // Use the dedicated method for updating language
      final result = await _profileService.updateLanguage(languageCode);

      if (result["success"]) {
        _userProfile = result["profile"];
        notifyListeners();
        return true;
      } else {
        _error = result["message"];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error updating language: $e";
      notifyListeners();
      return false;
    }
  }
  // Clear profile when logging out
  void clearProfile() {
    _userProfile = null;
    _error = '';
    notifyListeners();
  }
}