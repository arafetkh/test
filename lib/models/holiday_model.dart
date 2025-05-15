class HolidayModel {
  final int month;
  final int day;
  final Map<String, String> label;
  final int count;
  final String type;
  final bool isRecurringYearly;

  HolidayModel({
    required this.month,
    required this.day,
    required this.label,
    required this.count,
    required this.type,
    required this.isRecurringYearly,
  });

  // Create a holiday from JSON (for API operations)
  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      month: json['month'] ?? 1,
      day: json['day'] ?? 1,
      label: (json['label'] is Map)
          ? Map<String, String>.from(json['label'])
          : {'en': json['label'].toString(), 'fr': json['label'].toString()},
      count: json['count'] ?? 1,
      type: json['type'] ?? 'Public',
      isRecurringYearly: json['isRecurringYearly'] ?? true,
    );
  }

  // Convert holiday to map (for API operations)
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'day': day,
      'label': label,
      'count': count,
      'type': type,
      'isRecurringYearly': isRecurringYearly,
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