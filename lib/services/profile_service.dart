import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/profile_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Get profile information
  Future<Map<String, dynamic>> getProfile() async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/profile");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          "success": true,
          "profile": ProfileModel.fromJson(responseData),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to get profile: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Update profile settings
  Future<Map<String, dynamic>> updateProfile(ProfileModel profile) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/profile");

    try {
      // Create complete payload with all required fields
      final Map<String, dynamic> updateData = {
        // Include all fields required by the API
        "personalEmail": profile.personalEmail,
        "address": profile.address,
        "phoneNumber": profile.phoneNumber,
        "gender": profile.gender,
        "maritalStatus": profile.maritalStatus,
        "birthDate": profile.birthDate,
        "locale": profile.locale,
        "secondFactorEnabled": profile.secondFactorEnabled
      };

      // For debugging - log what we're sending
      print("Updating profile with data: ${jsonEncode(updateData)}");

      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
        body: jsonEncode(updateData),
      );

      // For debugging - log the response
      print("Update profile response status: ${response.statusCode}");
      print("Update profile response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          "success": true,
          "profile": ProfileModel.fromJson(responseData),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update profile: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error updating profile: $e");
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }
// Update specific profile field
  Future<Map<String, dynamic>> updateProfileField(int profileId, String field, dynamic value) async {
    // First get current profile
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult; // Return the error
    }

    final ProfileModel currentProfile = profileResult["profile"];

    // Create updated profile with new field value
    ProfileModel updatedProfile;

    switch (field) {
      case 'secondFactorEnabled':
        updatedProfile = currentProfile.copyWith(secondFactorEnabled: value);
        print("Updating 2FA setting to: $value");
        break;
      case 'locale':
        updatedProfile = currentProfile.copyWith(locale: value);
        print("Updating language setting to: $value");
        break;
      case 'personalEmail':
        updatedProfile = currentProfile.copyWith(personalEmail: value);
        print("Updating personal email to: $value");
        break;
      case 'address':
        updatedProfile = currentProfile.copyWith(address: value);
        print("Updating address to: $value");
        break;
      case 'phoneNumber':
        updatedProfile = currentProfile.copyWith(phoneNumber: value);
        print("Updating phone number to: $value");
        break;
      case 'gender':
        updatedProfile = currentProfile.copyWith(gender: value);
        print("Updating gender to: $value");
        break;
      case 'maritalStatus':
        updatedProfile = currentProfile.copyWith(maritalStatus: value);
        print("Updating marital status to: $value");
        break;
      case 'birthDate':
        updatedProfile = currentProfile.copyWith(birthDate: value);
        print("Updating birth date to: $value");
        break;
      default:
        return {
          "success": false,
          "message": "Unsupported field: $field",
        };
    }

    // Send complete profile update request with all fields
    return updateProfile(updatedProfile);
  }
// Direct method to update language preference
  Future<Map<String, dynamic>> updateLanguage(String languageCode) async {
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult;
    }

    final ProfileModel currentProfile = profileResult["profile"];

    // Only update if language is actually different
    if (currentProfile.locale == languageCode) {
      return {
        "success": true,
        "profile": currentProfile,
        "message": "Language already set to $languageCode",
      };
    }

    // Create a new profile with updated locale
    final updatedProfile = currentProfile.copyWith(locale: languageCode);

    // Send the update to the API with all required fields
    return updateProfile(updatedProfile);
  }

  // Direct method to update 2FA setting
  Future<Map<String, dynamic>> updateTwoFactorAuth(bool enabled) async {
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult;
    }

    final ProfileModel currentProfile = profileResult["profile"];

    // Only update if setting is actually different
    if (currentProfile.secondFactorEnabled == enabled) {
      return {
        "success": true,
        "profile": currentProfile,
        "message": "2FA already ${enabled ? 'enabled' : 'disabled'}",
      };
    }

    // Create a new profile with updated 2FA setting
    final updatedProfile = currentProfile.copyWith(secondFactorEnabled: enabled);

    // Send the update to the API with all required fields
    return updateProfile(updatedProfile);
  }
}