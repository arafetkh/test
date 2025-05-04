import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/holiday_model.dart';

class HolidayService {
  static final HolidayService _instance = HolidayService._internal();
  factory HolidayService() => _instance;
  HolidayService._internal();

  static const String _storageKey = 'holidays_data';
  final List<Holiday> _holidays = [];
  final _uuid = const Uuid();

  // Listeners for state changes
  final List<Function()> _listeners = [];

  // Get all holidays
  List<Holiday> get holidays => List.unmodifiable(_holidays);

  // Initialize the service with sample data if empty
  Future<void> initialize() async {
    await _loadHolidays();

    // If no holidays are loaded, add sample data
    if (_holidays.isEmpty) {
      _addSampleHolidays();
      await _saveHolidays();
    }
  }

  // Load holidays from storage
  Future<void> _loadHolidays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? holidaysJson = prefs.getString(_storageKey);

      if (holidaysJson != null) {
        final List<dynamic> decodedList = json.decode(holidaysJson);
        _holidays.clear();
        _holidays.addAll(
            decodedList.map((item) => Holiday.fromMap(item)).toList()
        );
      }
    } catch (e) {
      print('Error loading holidays: $e');
    }
  }

  // Save holidays to storage
  Future<void> _saveHolidays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(
          _holidays.map((holiday) => holiday.toMap()).toList()
      );
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      print('Error saving holidays: $e');
    }
  }

  // Add a new holiday
  Future<Holiday> addHoliday(Map<String, dynamic> holidayData) async {
    final newHoliday = Holiday(
      id: _uuid.v4(),
      name: holidayData['name'],
      description: holidayData['description'] ?? '',
      date: holidayData['date'],
      day: holidayData['day'],
      isRecurringYearly: holidayData['isRecurringYearly'] ?? false,
      type: holidayData['type'] ?? 'Public',
    );

    _holidays.add(newHoliday);
    await _saveHolidays();
    _notifyListeners();

    return newHoliday;
  }

  // Update an existing holiday
  Future<void> updateHoliday(String id, Map<String, dynamic> holidayData) async {
    final index = _holidays.indexWhere((holiday) => holiday.id == id);

    if (index >= 0) {
      _holidays[index] = _holidays[index].copyWith(
        name: holidayData['name'],
        description: holidayData['description'],
        date: holidayData['date'],
        day: holidayData['day'],
        isRecurringYearly: holidayData['isRecurringYearly'],
        type: holidayData['type'],
      );

      await _saveHolidays();
      _notifyListeners();
    }
  }

  // Delete a holiday
  Future<void> deleteHoliday(String id) async {
    _holidays.removeWhere((holiday) => holiday.id == id);
    await _saveHolidays();
    _notifyListeners();
  }

  // Get holidays for a specific year
  List<Holiday> getHolidaysForYear(int year) {
    return _holidays.where((holiday) {
      // Include recurring holidays from previous years
      if (holiday.isRecurringYearly && holiday.date.year <= year) {
        return true;
      }
      // Include non-recurring holidays for the specific year
      return holiday.date.year == year;
    }).toList();
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

  // Add sample holidays
  void _addSampleHolidays() {
    final currentYear = DateTime.now().year;

    _holidays.addAll([
      Holiday(
        id: _uuid.v4(),
        name: "New Year's Day",
        description: "First day of the year in the Gregorian calendar",
        date: DateTime(currentYear, 1, 1),
        day: "Monday",
        isRecurringYearly: true,
        type: "Public",
      ),
      Holiday(
        id: _uuid.v4(),
        name: "Independence Day",
        description: "National holiday",
        date: DateTime(currentYear, 7, 4),
        day: "Tuesday",
        isRecurringYearly: true,
        type: "Public",
      ),
      Holiday(
        id: _uuid.v4(),
        name: "Christmas Day",
        description: "Annual festival commemorating the birth of Jesus Christ",
        date: DateTime(currentYear, 12, 25),
        day: "Monday",
        isRecurringYearly: true,
        type: "Public",
      ),
      Holiday(
        id: _uuid.v4(),
        name: "Company Foundation Day",
        description: "Anniversary of the company's founding",
        date: DateTime(currentYear, 3, 15),
        day: "Wednesday",
        isRecurringYearly: true,
        type: "Company",
      ),
    ]);
  }
}