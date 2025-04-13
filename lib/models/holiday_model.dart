class Holiday {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String day;
  final bool isRecurringYearly;
  final String type; // Public or Company

  Holiday({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.day,
    required this.isRecurringYearly,
    required this.type,
  });

  // Create a holiday from a map (for database operations)
  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] is DateTime ? map['date'] : DateTime.parse(map['date']),
      day: map['day'] ?? '',
      isRecurringYearly: map['isRecurringYearly'] ?? false,
      type: map['type'] ?? 'Public',
    );
  }

  // Convert holiday to map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'day': day,
      'isRecurringYearly': isRecurringYearly,
      'type': type,
    };
  }

  // Create a copy of the holiday with updated fields
  Holiday copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? day,
    bool? isRecurringYearly,
    String? type,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      day: day ?? this.day,
      isRecurringYearly: isRecurringYearly ?? this.isRecurringYearly,
      type: type ?? this.type,
    );
  }
}