// lib/services/holiday_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth/global.dart';
import '../models/holiday_model.dart';


class HolidayService {
  static final HolidayService _instance = HolidayService._internal();

  factory HolidayService() => _instance;

  HolidayService._internal();

  // Listeners for state changes
  final List<Function()> _listeners = [];

  // Cache for holidays
  List<HolidayModel> _holidays = [];
  bool _hasLoaded = false;

  // Get all holidays
  List<HolidayModel> get holidays => List.unmodifiable(_holidays);

  // Fetch holidays from API
  Future<List<HolidayModel>> fetchHolidays({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh && _holidays.isNotEmpty) {
      return _holidays;
    }

    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/holidays"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> holidaysJson = json.decode(response.body);
        _holidays = holidaysJson.map((json) => HolidayModel.fromJson(json)).toList();
        _hasLoaded = true;
        _notifyListeners();
        return _holidays;
      } else {
        throw Exception('Failed to load holidays: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching holidays: $e');
    }
  }

  // Add a new holiday
  Future<bool> addHoliday(Map<String, dynamic> holidayData) async {
    try {
      // Extract date data
      final DateTime date = holidayData['date'];

      // Create the API request payload with the required count attribute
      final Map<String, dynamic> apiHoliday = {
        'month': date.month,
        'day': date.day,
        'count': 1, // Adding the required count attribute with default value 1
        'label': {
          'en': holidayData['name']['en'],
          'fr': holidayData['name']['fr'],
        },
        'type': holidayData['type'],
        'isRecurringYearly': holidayData['isRecurringYearly'],
      };

      print('Sending holiday data: ${jsonEncode(apiHoliday)}');

      final response = await http.post(
        Uri.parse("${Global.baseUrl}/secure/holidays"),
        headers: {
          ...await Global.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(apiHoliday),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh the holiday list
        await fetchHolidays(forceRefresh: true);
        return true;
      } else {
        print('Failed to add holiday: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding holiday: $e');
      return false;
    }
  }

  // Delete a holiday
  Future<bool> deleteHoliday(int month, int day) async {
    try {
      final response = await http.delete(
        Uri.parse("${Global.baseUrl}/secure/holidays/$month/$day"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from cache and notify listeners
        _holidays.removeWhere((h) => h.month == month && h.day == day);
        _notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting holiday: $e');
      return false;
    }
  }

  // Get holidays for a specific year
  List<HolidayModel> getHolidaysForYear(int year) {
    return _holidays;
  }

  // Get upcoming holidays
  List<HolidayModel> getUpcomingHolidays(int year) {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        year,
        holiday.month,
        holiday.day,
      );
      return holidayDate.isAfter(now) ||
          (holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day);
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(year, a.month, a.day);
        final bDate = DateTime(year, b.month, b.day);
        return aDate.compareTo(bDate);
      });
  }

  // Get past holidays
  List<HolidayModel> getPastHolidays(int year) {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        year,
        holiday.month,
        holiday.day,
      );
      return holidayDate.isBefore(now) &&
          !(holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day);
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(year, a.month, a.day);
        final bDate = DateTime(year, b.month, b.day);
        return bDate.compareTo(aDate); // Reverse order for past holidays
      });
  }

  // Add a listener
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  // Remove a listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}