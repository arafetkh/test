import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/services/employee_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';

import 'EditEmployeeScreen.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  bool _isLoading = true;
  Map<String, dynamic>? _employeeData;
  String _errorMessage = '';
  late Color _statusColor;
  Map<String, dynamic> _employeeMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _statusColor = Colors.green;
    _loadEmployeeDetails();
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

        // Print for debugging
        print("Employee data received: $_employeeData");

        setState(() {
          _employeeMap = {
            'id': _employeeData?['id']?.toString() ?? 'N/A',
            'name': '${_employeeData?['firstName'] ?? ''} ${_employeeData?['lastName'] ?? ''}'.trim(),
            'firstName': _employeeData?['firstName'] ?? 'N/A',
            'lastName': _employeeData?['lastName'] ?? 'N/A',
            'username': _employeeData?['username'] ?? 'N/A',
            'email': _employeeData?['email'] ?? 'N/A',
            'phoneNumber': _employeeData?['phoneNumber'] ?? 'N/A',
            'avatar': _employeeData?['firstName'] != null && _employeeData?['firstName'].isNotEmpty &&
                _employeeData?['lastName'] != null && _employeeData?['lastName'].isNotEmpty
                ? '${_employeeData!['firstName'][0]}${_employeeData!['lastName'][0]}'
                : 'NA',
            'avatarColor': Colors.blue.shade100,
            'textColor': Colors.blue.shade800,
            'department': _employeeData?['designation'] != null && _employeeData!['designation'].contains(' ')
                ? _employeeData!['designation'].split(' ').last
                : 'Department',
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
            'officeLocation': _employeeData?['officeLocation'] ??'N/A',
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final newHeaderVisible = _scrollController.offset <= 50;
    if (_isHeaderVisible != newHeaderVisible) {
      setState(() {
        _isHeaderVisible = newHeaderVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

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
          title: Text(localizations.getString('employeeProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
          child: Text(localizations.getString('employeeNotFound') ?? 'Employee not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollUpdateNotification) {
            _scrollListener();
          }
          return true;
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AdaptiveColors.cardColor(context),
                pinned: true,
                floating: false,
                snap: false,
                expandedHeight: 120,
                elevation: _isHeaderVisible ? 0 : 4,
                automaticallyImplyLeading: false,
                title: AnimatedOpacity(
                  opacity: _isHeaderVisible ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _employeeMap['name'] ?? '',
                    style: TextStyle(
                      color: AdaptiveColors.primaryTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AdaptiveColors.primaryTextColor(context),
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AdaptiveColors.primaryGreen,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEmployeeScreen(
                            employeeData: _employeeMap,
                            onEmployeeUpdated: () {
                              // Reload employee data after update
                              _loadEmployeeDetails();
                            },
                          ),
                        ),
                      );
                    },
                    tooltip: localizations.getString('edit'),
                  ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height > 80 ? 60.0 : 0.0;

                    return FlexibleSpaceBar(
                      background: _isHeaderVisible
                          ? Container(
                        padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
                        decoration: BoxDecoration(
                          color: AdaptiveColors.cardColor(context),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Employee Avatar
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: _getAvatarColor(
                                      _employeeMap['name'] ?? ''),
                                  child: Text(
                                    _employeeMap['avatar'] ?? 'NA',
                                    style: TextStyle(
                                      color:
                                      _employeeMap['textColor'] ??
                                          Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _employeeMap['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.022,
                                          fontWeight: FontWeight.bold,
                                          color: AdaptiveColors
                                              .primaryTextColor(context),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.work_outline,
                                            size: 14,
                                            color:
                                            AdaptiveColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _employeeMap['designation'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AdaptiveColors
                                                  .secondaryTextColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                            color:
                                            AdaptiveColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _employeeMap['email'] ??
                                                  "${_employeeMap['name']?.toString().toLowerCase().replaceAll(' ', '.')}@example.com",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AdaptiveColors
                                                    .secondaryTextColor(
                                                    context),
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Work Status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _employeeMap['type'] == 'REMOTE'
                                            ? Icons.computer
                                            : Icons.business,
                                        size: 14,
                                        color: _statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _employeeMap['type'] ?? 'OFFICE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.work,
                                        size: 14,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _employeeMap['department'] ?? 'Department',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          : Container(color: AdaptiveColors.cardColor(context)),
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(42),
                  child: Container(
                    color: AdaptiveColors.cardColor(context),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AdaptiveColors.primaryGreen,
                      unselectedLabelColor:
                      AdaptiveColors.secondaryTextColor(context),
                      indicatorColor: AdaptiveColors.primaryGreen,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.person_outline, size: 18),
                          text: localizations.getString('profile'),
                        ),
                        Tab(
                          icon:
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          text: localizations.getString('attendance'),
                        ),
                        Tab(
                          icon: const Icon(Icons.event_note_outlined, size: 18),
                          text: localizations.getString('leave'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
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
        ),
      ),
    );
  }

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
                      _employeeMap['maritalStatus'] ?? '', // Updated from martialStatus
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

              // Address field (updated to use the new direct address field)
              _buildInfoField(
                context,
                localizations.getString('address'),
                _employeeMap['address'] ?? 'N/A',
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              // Active status field (new)
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
                _employeeMap['officeLocation'] ?? '',
                Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value, IconData icon) {
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

    // Sample attendance data
    final attendanceData = [
      {
        'date': 'July 01, 2023',
        'checkIn': '09:28 AM',
        'checkOut': '07:00 PM',
        'break': '00:30 Min',
        'workingHours': '09:02 Hrs',
        'status': 'On Time',
      },
      {
        'date': 'July 02, 2023',
        'checkIn': '09:20 AM',
        'checkOut': '07:00 PM',
        'break': '00:20 Min',
        'workingHours': '09:20 Hrs',
        'status': 'On Time',
      },
      {
        'date': 'July 03, 2023',
        'checkIn': '09:25 AM',
        'checkOut': '07:00 PM',
        'break': '00:30 Min',
        'workingHours': '09:05 Hrs',
        'status': 'On Time',
      },
      {
        'date': 'July 06, 2023',
        'checkIn': '09:28 AM',
        'checkOut': '07:00 PM',
        'break': '00:30 Min',
        'workingHours': '09:02 Hrs',
        'status': 'On Time',
      },
      {
        'date': 'July 07, 2023',
        'checkIn': '09:30 AM',
        'checkOut': '07:00 PM',
        'break': '00:15 Min',
        'workingHours': '09:15 Hrs',
        'status': 'On Time',
      },
      {
        'date': 'July 08, 2023',
        'checkIn': '09:52 AM',
        'checkOut': '07:00 PM',
        'break': '00:45 Min',
        'workingHours': '08:23 Hrs',
        'status': 'Late',
      },
      {
        'date': 'July 09, 2023',
        'checkIn': '09:10 AM',
        'checkOut': '07:00 PM',
        'break': '00:30 Min',
        'workingHours': '09:20 Hrs',
        'status': 'On Time',
      }
    ];

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
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final attendance = attendanceData[index];
                  final isLate = attendance['status'] == 'Late';

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
                            attendance['date']!,
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['checkIn']!,
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['break']!,
                            style: TextStyle(
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            attendance['workingHours']!,
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
                                attendance['status']!,
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

    // Sample leave data - refined to match web version
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

  String _getInitials(String name) {
    if (name.isEmpty) {
      return 'NA';
    }

    // Split by space to get name parts
    List<String> nameParts = name.split(' ');

    if (nameParts.length > 1) {
      // If we have at least first and last name
      String firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
      String lastInitial = nameParts[1].isNotEmpty ? nameParts[1][0] : '';
      return '$firstInitial$lastInitial';
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      // If we only have one name part
      return nameParts[0][0];
    }

    return 'NA';
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