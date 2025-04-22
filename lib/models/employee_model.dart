// lib/models/employee_model.dart

// lib/models/employee_model.dart
class Employee {
  final String? id;
  final String username;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final String role;
  final String? birthDate;
  final String? recruitmentDate;
  final String designation;
  final String gender;
  final String type;
  final String martialStatus; //
  final String? companyId;
  final Map<String, dynamic> attributes;
  final bool enabled;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? nationality;
  final String? workingDays;
  final String? officeLocation;

  Employee({
    this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.role,
    this.birthDate,
    this.recruitmentDate,
    required this.designation,
    required this.gender,
    required this.type,
    required this.martialStatus,
    this.companyId,
    this.attributes = const {},// Valeur par défaut de liste vide
    this.enabled = true,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.nationality,
    this.workingDays,
    this.officeLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'gender': gender,
      'martialStatus': martialStatus, // Attention, la clé pourrait être "maritalStatus" dans l'API
      'birthDate': birthDate,
      'recruitmentDate': recruitmentDate,
      'role': role,
      'type': type,
      'companyId': companyId,
      'designation': designation,
      'attributes': attributes,
      'enabled': enabled,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString(),
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      password: json['password'] ?? '',
      role: json['role'],
      birthDate: json['birthDate'],
      recruitmentDate: json['recruitmentDate'],
      designation: json['designation'],
      gender: json['gender'],
      type: json['type'],
      martialStatus: json['maritalStatus'],
      companyId: json['companyId'],
      attributes: json['attributes'] ?? [],
      enabled: json['enabled'] ?? true,
      address: null,
      city: null,
      state: null,
      zipCode: null,
      nationality: null,
      workingDays: null,
      officeLocation: null,
    );
  }
  // Méthode pour créer une version complète pour EmployeeProfileScreen
  Map<String, dynamic> toProfileFormat() {
    return {
      'id': id.toString(),
      'name': '$firstName $lastName',
      'avatar': '${firstName[0]}${lastName[0]}',
      'avatarColor': null,
      'textColor': null,
      'department': 'N/A',
      'designation': designation,
      'type': type,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'recruitmentDate': recruitmentDate,
      'gender': gender,
      'maritalStatus': martialStatus,
      'username': username,
      'companyId': companyId,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'nationality': nationality,
      'workingDays': workingDays,
      'officeLocation': officeLocation,
    };
  }
  String get fullName => '$firstName $lastName';

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}';
    } else if (firstName.isNotEmpty) {
      return firstName[0];
    } else if (lastName.isNotEmpty) {
      return lastName[0];
    } else {
      return '';
    }
  }
}