import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/services/employee_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../auth/global.dart';
import 'edit_employee_screen.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeProfileScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _employeeData;
  String _errorMessage = '';
  late Color _statusColor;
  Map<String, dynamic> _employeeMap = {};

  // Attendance data
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoadingAttendance = true;
  String _attendanceError = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statusColor = Colors.green;
    _loadEmployeeDetails();

    // Listen for tab changes to load data when needed
    _tabController.addListener(() {
      if (_tabController.index == 1 && _attendances.isEmpty && !_isLoadingAttendance) {
        _loadAttendanceData();
      }
    });
  }

  Future<void> _loadEmployeeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await EmployeeService.getEmployeeById(widget.employeeId);

      if (result["success"]) {
        // Store the raw data
        _employeeData = result["employee"];

        // Extract department from attributes
        String department = 'Department';
        if (_employeeData?['attributes'] != null &&
            _employeeData?['attributes']['department'] != null &&
            _employeeData?['attributes']['department']['name'] != null) {
          department = _employeeData!['attributes']['department']['name'];
        } else if (_employeeData?['department'] != null) {
          // Fallback to old structure if available
          department = _employeeData!['department'];
        } else if (_employeeData?['designation'] != null &&
            _employeeData!['designation'].contains(' ')) {
          // Legacy fallback to splitting designation
          department = _employeeData!['designation'].split(' ').last;
        }

        setState(() {
          _employeeMap = {
            'id': _employeeData?['id']?.toString() ?? 'N/A',
            'name':
            '${_employeeData?['firstName'] ?? ''} ${_employeeData?['lastName'] ?? ''}'
                .trim(),
            'firstName': _employeeData?['firstName'] ?? 'N/A',
            'lastName': _employeeData?['lastName'] ?? 'N/A',
            'username': _employeeData?['username'] ?? 'N/A',
            'email': _employeeData?['email'] ?? 'N/A',
            'personalEmail': _employeeData?['personalEmail'] ?? 'N/A',
            'phoneNumber': _employeeData?['phoneNumber'] ?? 'N/A',
            'avatar': _employeeData?['firstName'] != null &&
                _employeeData?['firstName'].isNotEmpty &&
                _employeeData?['lastName'] != null &&
                _employeeData?['lastName'].isNotEmpty
                ? '${_employeeData!['firstName'][0]}${_employeeData!['lastName'][0]}'
                : 'NA',
            'avatarColor': Colors.blue.shade100,
            'textColor': Colors.blue.shade800,
            'department': department,
            'designation': _employeeData?['designation'] ?? 'N/A',
            'type': _employeeData?['type'] ?? 'N/A',
            'birthDate': _employeeData?['birthDate'] ?? 'N/A',
            'recruitmentDate': _employeeData?['recruitmentDate'] ?? 'N/A',
            'gender': _employeeData?['gender'] ?? 'N/A',
            'maritalStatus': _employeeData?['maritalStatus'] ?? 'N/A',
            'address': _employeeData?['address'] ?? 'N/A',
            'city': _employeeData?['city'] ?? 'N/A',
            'state': _employeeData?['state'] ?? 'N/A',
            'zipCode': _employeeData?['zipCode'] ?? 'N/A',
            'nationality': _employeeData?['nationality'] ?? 'N/A',
            'workingDays': _employeeData?['workingDays'] ?? 'N/A',
            'officeLocation': _employeeData?['officeLocation'] ?? 'N/A',
            'companyId': _employeeData?['companyId'] ?? 'N/A',
            'active': _employeeData?['active'] ?? 'N/A',
            'role': _employeeData?['role'] ?? 'N/A',
            'attributes': _employeeData?['attributes'] ?? {},
            'departmentKey': _employeeData?['attributes']?['department']?['key']
                ?.toString() ??
                'N/A',
          };

          final type = _employeeData?['type'] ?? '';
          if (type == 'REMOTE') {
            _statusColor = Colors.blue;
          } else if (type == 'HYBRID') {
            _statusColor = Colors.orange;
          } else {
            _statusColor = Colors.green;
          }

          _isLoading = false;
        });

        // Load attendance data if we're on that tab
        if (_tabController.index == 1) {
          _loadAttendanceData();
        }
      } else {
        setState(() {
          _errorMessage = result["message"];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception in _loadEmployeeDetails: $e");
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    if (_employeeMap.isEmpty || _employeeMap['id'] == 'N/A') {
      // Can't load attendance without employee ID
      return;
    }

    setState(() {
      _isLoadingAttendance = true;
      _attendanceError = '';
    });

    try {
      final String userId = _employeeMap['id'];
      final Uri url = Uri.parse("${Global.baseUrl}/secure/attendance-management?userId=$userId");

      print("Fetching attendance data: $url");

      final response = await http.get(
        url,
        headers: Global.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Map<String, dynamic>> processedAttendances = [];

        for (var attendance in responseData) {
          // Default end time for calculations
          final String endWorkTime = "18:00:00";

          final String localDate = attendance['localDate'] ?? '';
          final List<dynamic> entries = attendance['entries'] ?? [];
          final String type = attendance['type'] ?? 'OFFICE';
          final bool isLate = attendance['late'] ?? false;
          final bool isComplete = attendance['complete'] ?? false;
          final bool isImpaired = attendance['impaired'] ?? false;

          // Format date to a nice display format
          DateTime? parsedDate;
          String displayDate = localDate;
          try {
            parsedDate = DateTime.parse(localDate);
            displayDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
          } catch (e) {
            // Keep original format if parsing fails
          }

          // Process check-in/check-out times
          String checkInTime = entries.isNotEmpty ? entries.first : '';

          // Format to AM/PM format
          String displayCheckIn = '';
          if (checkInTime.isNotEmpty) {
            try {
              final timeParts = checkInTime.split(':');
              final hour = int.parse(timeParts[0]);
              final minutes = timeParts[1];
              displayCheckIn = '${hour > 12 ? hour - 12 : hour}:$minutes ${hour >= 12 ? 'PM' : 'AM'}';
            } catch (e) {
              displayCheckIn = checkInTime;
            }
          }

          // Calculate breaks and working hours
          String breakTime = '00:00 Min';
          String workingHours = '00:00 Hrs';

          if (entries.length >= 2) {
            try {
              // Calculate breaks - assume even entries are check-ins, odd entries are check-outs
              Duration totalBreak = Duration.zero;

              for (int i = 1; i < entries.length - 1; i += 2) {
                final checkOut = _parseTimeToMinutes(entries[i]);
                final nextCheckIn = _parseTimeToMinutes(entries[i + 1]);
                totalBreak += Duration(minutes: nextCheckIn - checkOut);
              }

              // Format break time
              final breakHours = totalBreak.inHours;
              final breakMinutes = totalBreak.inMinutes % 60;
              breakTime = '${breakHours.toString().padLeft(2, '0')}:${breakMinutes.toString().padLeft(2, '0')} Min';

              // Calculate working hours
              final firstCheckIn = _parseTimeToMinutes(entries.first);

              // Use last entry as checkout or default end time if impaired
              int lastCheckOut;
              if (isImpaired && entries.length % 2 != 0) {
                // Odd number of entries and impaired - use default end time
                lastCheckOut = _parseTimeToMinutes(endWorkTime);
              } else {
                // Use the last entry or default end time for incomplete days
                lastCheckOut = entries.length > 0 && entries.length % 2 == 0
                    ? _parseTimeToMinutes(entries.last)
                    : _parseTimeToMinutes(endWorkTime);
              }

              final totalWorkMinutes = lastCheckOut - firstCheckIn - totalBreak.inMinutes;
              final workHours = totalWorkMinutes ~/ 60;
              final workMinutes = totalWorkMinutes % 60;
              workingHours = '${workHours.toString().padLeft(2, '0')}:${workMinutes.toString().padLeft(2, '0')} Hrs';
            } catch (e) {
              print("Error calculating times: $e");
            }
          } else if (entries.length == 1) {
            // Just checked in - assume working until end of day
            try {
              final checkIn = _parseTimeToMinutes(entries.first);
              final checkOut = _parseTimeToMinutes(endWorkTime);
              final totalWorkMinutes = checkOut - checkIn;
              final workHours = totalWorkMinutes ~/ 60;
              final workMinutes = totalWorkMinutes % 60;
              workingHours = '${workHours.toString().padLeft(2, '0')}:${workMinutes.toString().padLeft(2, '0')} Hrs';
            } catch (e) {
              print("Error calculating times with single entry: $e");
            }
          }

          // Add to processed attendances
          processedAttendances.add({
            'date': displayDate,
            'checkIn': displayCheckIn,
            'break': breakTime,
            'workingHours': workingHours,
            'status': isLate ? 'Late' : 'On Time',
            'isLate': isLate,
            'rawData': attendance, // Store original data for debugging
          });
        }

        // Sort by date descending (most recent first)
        processedAttendances.sort((a, b) {
          final aDate = a['rawData']['localDate'];
          final bDate = b['rawData']['localDate'];
          return bDate.compareTo(aDate);
        });

        setState(() {
          _attendances = processedAttendances;
          _isLoadingAttendance = false;
        });
      } else {
        setState(() {
          _attendanceError = 'Failed to load attendance data: ${response.statusCode}';
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      print("Exception in _loadAttendanceData: $e");
      setState(() {
        _attendanceError = "Error loading attendance: $e";
        _isLoadingAttendance = false;
      });
    }
  }

  // Helper to parse time string to minutes since midnight
  int _parseTimeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);


    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('employeeProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AdaptiveColors.cardColor(context),
          elevation: 0,
          title: Text(
            _employeeMap['name'] ?? 'Employee Profile',
            style: TextStyle(
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AdaptiveColors.primaryTextColor(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _loadEmployeeDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_employeeMap.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('employeeProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(localizations.getString('employeeNotFound') ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _employeeMap['name'] ?? '',
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AdaptiveColors.primaryTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Enable/Disable button
          IconButton(
            icon: Icon(
              _employeeMap['active'] == true
                  ? Icons.toggle_on_outlined
                  : Icons.toggle_off_outlined,
              color: _employeeMap['active'] == true
                  ? Colors.green
                  : Colors.red,
              size: 24,
            ),
            onPressed: _isLoading ? null : _toggleUserActiveStatus,
            tooltip: _employeeMap['active'] == true
                ? 'Disable User'
                : 'Enable User',
          ),
          // Edit button
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AdaptiveColors.primaryGreen,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEmployeeScreen(
                    employeeData: _employeeMap,
                    onEmployeeUpdated: () {
                      _loadEmployeeDetails();
                    },
                  ),
                ),
              );
            },
            tooltip: localizations.getString('edit'),
          ),
        ],
        // Rest of the app bar code remains the same
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person_outline, size: 18),
              text: localizations.getString('profile'),
            ),
            Tab(
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              text: localizations.getString('attendance'),
            ),
            Tab(
              icon: const Icon(Icons.event_note_outlined, size: 18),
              text: localizations.getString('leave'),
            ),
          ],
          labelColor: AdaptiveColors.primaryGreen,
          unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
          indicatorColor: AdaptiveColors.primaryGreen,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      // Content remains the same
      body: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          // Profile tab content
          _buildProfileTab(context),

          // Attendance tab content
          _buildAttendanceTab(context),

          // Leave tab content
          _buildLeaveTab(context),
        ],
      ),
    );
  }

  // ... [Profile tab implementation remains the same] ...

  Widget _buildProfileTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Personal/Professional tabs
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              border: Border(
                bottom: BorderSide(
                  color: AdaptiveColors.borderColor(context),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              labelColor: AdaptiveColors.primaryGreen,
              unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
              indicatorColor: AdaptiveColors.primaryGreen,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  text: localizations.getString('personalInformation'),
                ),
                Tab(
                  text: localizations.getString('professionalInformation'),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                // Personal Information
                _buildPersonalInformation(context),

                // Professional Information
                _buildProfessionalInformation(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserActiveStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current active status and user ID
      final bool isCurrentlyActive = _employeeMap['active'] == true;
      final String userId = _employeeMap['id'].toString();

      // Determine which endpoint to use based on current status
      final String endpoint = isCurrentlyActive
          ? "/secure/users-management/disable/$userId"
          : "/secure/users-management/enable/$userId";

      // Make API call
      final Uri url = Uri.parse("${Global.baseUrl}$endpoint");
      final response = await http.put(
        url,
        headers: Global.headers,
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyActive
                ? 'User disabled successfully'
                : 'User enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload employee data to reflect the changes
        _loadEmployeeDetails();
      } else {
        // Show error message
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to update user status: ${response.statusCode}";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating user status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPersonalInformation(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      primary: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        color: AdaptiveColors.cardColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First/Last Name row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('firstName'),
                      _employeeMap['firstName'] ?? '',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('lastName'),
                      _employeeMap['lastName'] ?? '',
                      Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Primary Email field
              _buildInfoField(
                context,
                localizations.getString('emailAddress'),
                _employeeMap['email'] ?? '',
                Icons.email_outlined,
              ),
              const SizedBox(height: 24),

              // Personal Email field (new)
              _buildInfoField(
                context,
                'Personal Email', // Add to localizations if needed
                _employeeMap['personalEmail'] ?? 'N/A',
                Icons.alternate_email,
              ),
              const SizedBox(height: 24),

              // Mobile Number field
              _buildInfoField(
                context,
                localizations.getString('mobileNumber'),
                _employeeMap['phoneNumber'] ?? '',
                Icons.phone_outlined,
              ),
              const SizedBox(height: 24),

              // Other personal info fields
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('dateOfBirth'),
                      _employeeMap['birthDate'] ?? '',
                      Icons.cake_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('maritalStatus'),
                      _employeeMap['maritalStatus'] ??
                          '', // Updated from martialStatus
                      Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // More personal info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('gender'),
                      _employeeMap['gender'] ?? '',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('nationality'),
                      _employeeMap['nationality'] ?? '',
                      Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Address field
              _buildInfoField(
                context,
                localizations.getString('address'),
                _employeeMap['address'] ?? 'N/A',
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              // Active status field
              _buildInfoField(
                context,
                'Account Status',
                _employeeMap['active'] == true ? 'Active' : 'Inactive',
                Icons.verified_user_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInformation(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.all(12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        color: AdaptiveColors.cardColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('employeeId'),
                      _employeeMap['id'] ?? 'N/A',
                      Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('userName'),
                      _employeeMap['username'] ?? 'N/A',
                      Icons.account_circle_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('type'),
                      _employeeMap['type'] ?? 'N/A',
                      Icons.business_center_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('department'),
                      _employeeMap['department'] ?? 'N/A',
                      Icons.domain_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      'Company ID',
                      _employeeMap['companyId'] ?? 'N/A',
                      Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('joiningDate'),
                      _employeeMap['recruitmentDate'] ?? 'N/A',
                      Icons.date_range_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      'Role',
                      _employeeMap['role'] ?? 'N/A',
                      Icons.verified_user_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('workingDays'),
                      _employeeMap['workingDays'] ?? 'N/A',
                      Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoField(
                context,
                localizations.getString('officeLocation'),
                _employeeMap['officeLocation'] ?? 'N/A',
                Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
      BuildContext context, String label, String value, IconData icon)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: AdaptiveColors.isDarkMode(context)
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AdaptiveColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Show loading state
    if (_isLoadingAttendance) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading attendance data...',
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    // Show error if any
    if (_attendanceError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_attendanceError',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAttendanceData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state if no data
    if (_attendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 16,
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        color: AdaptiveColors.cardColor(context),
        child: Column(
          children: [
            // Refresh button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh attendance data',
                onPressed: _loadAttendanceData,
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AdaptiveColors.borderColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      localizations.getString('date'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      localizations.getString('checkInTime'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Break',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Work Hours',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      localizations.getString('status'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Attendance list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _attendances.length,
                itemBuilder: (context, index) {
                  final attendance = _attendances[index];
                  final isLate = attendance['isLate'] == true;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AdaptiveColors.borderColor(context),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            attendance['date'] ?? '',
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['checkIn'] ?? '',
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['break'] ?? '',
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['workingHours'] ?? '',
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isLate
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                attendance['status'] ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isLate ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Sample leave data
    final leaveData = [
      {
        'date': 'July 01, 2023',
        'duration': 'July 05 - July 08',
        'days': '3 Days',
        'manager': 'Mark Willians',
        'status': 'Pending',
      },
      {
        'date': 'Apr 05, 2023',
        'duration': 'Apr 06 - Apr 10',
        'days': '4 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Mar 12, 2023',
        'duration': 'Mar 14 - Mar 16',
        'days': '2 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Feb 01, 2023',
        'duration': 'Feb 02 - Feb 10',
        'days': '8 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Jan 01, 2023',
        'duration': 'Jan 16 - Jan 19',
        'days': '3 Days',
        'manager': 'Mark Willians',
        'status': 'Reject',
      },
    ];

    return Column(
      children: [
        // Add new leave request button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle leave request
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              localizations.getString('requestLeave'),
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdaptiveColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ),

        // Leave list in a card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              color: AdaptiveColors.cardColor(context),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AdaptiveColors.borderColor(context),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            localizations.getString('date'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            localizations.getString('duration'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Days',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            localizations.getString('status'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Leave list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        Color statusColor;
                        switch (leave['status']) {
                          case 'Approved':
                            statusColor = Colors.green;
                            break;
                          case 'Pending':
                            statusColor = Colors.orange;
                            break;
                          case 'Reject':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AdaptiveColors.borderColor(context),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  leave['date']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  leave['duration']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  leave['days']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      leave['status']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) {
      return Colors.grey;
    }

    // List of pastel colors for avatars
    final colors = [
      Colors.blue.shade100,
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
    ];

    // Generate a consistent index based on the name
    int hashCode = name.hashCode;
    return colors[hashCode.abs() % colors.length];
  }
}