import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeProfileScreen({
    Key? key,
    required this.employee,
  }) : super(key: key);

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.getString('employeeProfile'),
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AdaptiveColors.primaryGreen, size: 20),
            onPressed: () {
              // Handle edit profile
            },
            tooltip: localizations.getString('edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Compact Employee Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: AdaptiveColors.cardColor(context),
                boxShadow: [
                  BoxShadow(
                    color: AdaptiveColors.shadowColor(context),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar (small)
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getAvatarColor(widget.employee['name']),
                    child: Text(
                      _getInitials(widget.employee['name']),
                      style: TextStyle(
                        color: widget.employee['textColor'] ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Employee info (compact)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Text(
                          widget.employee['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),

                        // Job title
                        Text(
                          widget.employee['designation'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AdaptiveColors.secondaryTextColor(context),
                          ),
                        ),

                        // Email with icon
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: AdaptiveColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${widget.employee['name'].toString().toLowerCase().replaceAll(' ', '.')}@example.com",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdaptiveColors.secondaryTextColor(
                                      context),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Tabs - Very compact
            Container(
              height: 40,
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
                controller: _tabController,
                labelColor: AdaptiveColors.primaryGreen,
                unselectedLabelColor:
                    AdaptiveColors.secondaryTextColor(context),
                indicatorColor: AdaptiveColors.primaryGreen,
                labelStyle: const TextStyle(fontSize: 12),
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    height: 40,
                    icon: Icon(Icons.person_outline, size: 16),
                    text: localizations.getString('profile'),
                  ),
                  Tab(
                    height: 40,
                    icon: Icon(Icons.calendar_today_outlined, size: 16),
                    text: localizations.getString('attendance'),
                  ),
                  Tab(
                    height: 40,
                    icon: Icon(Icons.event_note_outlined, size: 16),
                    text: localizations.getString('leave'),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
          ],
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
          // Personal/Professional tabs - Very compact
          Container(
            height: 40,
            color: AdaptiveColors.cardColor(context),
            child: TabBar(
              labelColor: AdaptiveColors.primaryGreen,
              unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
              indicatorColor: AdaptiveColors.primaryGreen,
              labelStyle: const TextStyle(fontSize: 12),
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  height: 40,
                  text: localizations.getString('personalInformation'),
                ),
                Tab(
                  height: 40,
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // First/Last Name row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('firstName'),
                              widget.employee['name'].toString().split(' ')[0],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('lastName'),
                              widget.employee['name']
                                          .toString()
                                          .split(' ')
                                          .length >
                                      1
                                  ? widget.employee['name']
                                      .toString()
                                      .split(' ')[1]
                                  : "",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Mobile/Email row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('mobileNumber'),
                              "(702) 555-0122", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('emailAddress'),
                              "${widget.employee['name'].toString().toLowerCase().replaceAll(' ', '.')}@example.com",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Other personal info fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('dateOfBirth'),
                              "July 14, 1995", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('maritalStatus'),
                              "Married", // Sample data
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // More personal info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('gender'),
                              "Female", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('nationality'),
                              "American", // Sample data
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildInfoField(
                        context,
                        localizations.getString('address'),
                        "2464 Royal Ln, Mesa, New Jersey", // Sample data
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('city'),
                              "California", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('state'),
                              "United State", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('zipCode'),
                              "35624", // Sample data
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Professional Information
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('employeeId'),
                              widget.employee['id'],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('userName'),
                              widget.employee['name']
                                  .toString()
                                  .toLowerCase()
                                  .replaceAll(' ', '_'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('type'),
                              widget.employee['type'],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('department'),
                              widget.employee['department'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('workingDays'),
                              "5 Days", // Sample data
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoField(
                              context,
                              localizations.getString('joiningDate'),
                              "July 10, 2022", // Sample data
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoField(
                        context,
                        localizations.getString('officeLocation'),
                        "2464 Royal Ln, Mesa, New Jersey", // Sample data
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        'date': 'July 08, 2023',
        'checkIn': '09:52 AM',
        'checkOut': '07:00 PM',
        'break': '00:45 Min',
        'workingHours': '08:23 Hrs',
        'status': 'Late',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    localizations.getString('date'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                      fontSize: 12,
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
                      fontSize: 12,
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
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AdaptiveColors.borderColor(context)),

          // Attendance rows
          ...attendanceData
              .map((attendance) => _buildAttendanceRow(context, attendance))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(
      BuildContext context, Map<String, dynamic> attendance) {
    final isLate = attendance['status'] == 'Late';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
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
              attendance['date'],
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              attendance['checkIn'],
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isLate
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                attendance['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLate ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
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
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Add new leave request button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle leave request
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                localizations.getString('requestLeave'),
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdaptiveColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    localizations.getString('date'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                      fontSize: 12,
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
                      fontSize: 12,
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
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AdaptiveColors.borderColor(context)),

          // Leave rows
          ...leaveData.map((leave) => _buildLeaveRow(context, leave)).toList(),
        ],
      ),
    );
  }

  Widget _buildLeaveRow(BuildContext context, Map<String, dynamic> leave) {
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
        horizontal: 12.0,
        vertical: 8.0,
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
              leave['date'],
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave['duration'],
                  style: TextStyle(
                    color: AdaptiveColors.primaryTextColor(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  leave['days'],
                  style: TextStyle(
                    color: AdaptiveColors.secondaryTextColor(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                leave['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: AdaptiveColors.isDarkMode(context)
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    // If employee already has an avatar defined, use it
    if (widget.employee.containsKey('avatar') &&
        widget.employee['avatar'] is String) {
      return widget.employee['avatar'];
    }

    // Otherwise, compute from name
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }
    return '';
  }

  Color _getAvatarColor(String name) {
    // If employee already has an avatarColor defined, use it
    if (widget.employee.containsKey('avatarColor') &&
        widget.employee['avatarColor'] is Color) {
      return widget.employee['avatarColor'];
    }

    // Otherwise, compute a color
    final colors = [
      Colors.blue.shade100,
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
    ];

    int hashCode = name.hashCode;
    return colors[hashCode.abs() % colors.length];
  }
}
