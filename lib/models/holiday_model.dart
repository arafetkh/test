class HolidayModel {
  final int id;
  final int month;
  final int day;
  final Map<String, String> label;
  final int count;
  final String type;
  final bool recurring;
  final String? description;

  HolidayModel({
    required this.id,
    required this.month,
    required this.day,
    required this.label,
    required this.count,
    required this.type,
    required this.recurring,
    this.description,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    // Log the incoming JSON for debugging
    print('Processing holiday: ${json['id']}');

    // Extract the label properly handling different formats
    Map<String, String> labelMap;
    if (json['label'] is Map) {
      labelMap = Map<String, String>.from(json['label']);
    } else {
      labelMap = {
        'en': json['label']?.toString() ?? '',
        'fr': json['label']?.toString() ?? '',
      };
    }

    // Extract date components
    int month, day;

    if (json['date'] != null) {
      // Parse the date string (format: "YYYY-MM-DD")
      final DateTime date = DateTime.parse(json['date']);
      month = date.month;
      day = date.day;
    } else {
      // Fallback to separate fields if available
      month = json['month'] ?? 1;
      day = json['day'] ?? 1;
    }

    // Extract and parse the ID
    int holidayId;
    if (json['id'] is int) {
      holidayId = json['id'];
    } else if (json['id'] is String) {
      holidayId = int.tryParse(json['id']) ?? 0;
    } else {
      holidayId = 0;
    }

    return HolidayModel(
      id: holidayId,
      month: month,
      day: day,
      label: labelMap,
      count: json['count'] ?? 1,
      type: json['type'] ?? 'Public',
      recurring: json['recurring'] ?? json['recurring'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateTime(DateTime.now().year, month, day).toIso8601String().substring(0, 10),
      'label': label,
      'count': count,
      'type': type,
      'recurring': recurring,
      if (description != null) 'description': description,
    };
  }

  // Get the name based on the current language
  String getName(String languageCode) {
    return label[languageCode] ?? label['en'] ?? '';
  }

  // Get date for a specific year
  DateTime getDateForYear(int year) {
    return DateTime(year, month, day);
  }
}