import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeProfileScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  late Color _statusColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _statusColor =
        widget.employee['type'] == 'Remote' ? Colors.blue : Colors.green;
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
    final screenHeight = size.height; // Get screen height

    final titleFontSize = screenHeight * 0.022;
    final subtitleFontSize = screenHeight * 0.016;
    final smallFontSize = screenHeight * 0.014;

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      body: NotificationListener<ScrollNotification>(
    // Add this NotificationListener
    onNotification: (ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollUpdateNotification) {
    _scrollListener();
    }
    return true;
    },
    child:NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AdaptiveColors.cardColor(context),
              pinned: true,
              floating: false, // Change from true to false
              snap: false,
              expandedHeight: 120, // Reduce from 160 to 120
              elevation: _isHeaderVisible ? 0 : 4,
              automaticallyImplyLeading: false,
              title: AnimatedOpacity(
                opacity: _isHeaderVisible ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.employee['name'],
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
                    // Handle edit profile
                  },
                  tooltip: localizations.getString('edit'),
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Calculate the top padding based on the constraints
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
                                    Hero(
                                      tag: 'avatar-${widget.employee['id']}',
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: _getAvatarColor(
                                            widget.employee['name']),
                                        child: Text(
                                          _getInitials(widget.employee['name']),
                                          style: TextStyle(
                                            color:
                                                widget.employee['textColor'] ??
                                                    Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
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
                                            widget.employee['name'],
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
                                                widget.employee['designation'],
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
                                                  "${widget.employee['name'].toString().toLowerCase().replaceAll(' ', '.')}@example.com",
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
                                            widget.employee['type'] == 'Remote'
                                                ? Icons.computer
                                                : Icons.business,
                                            size: 14,
                                            color: _statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.employee['type'],
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
                                            widget.employee['department'],
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
      )
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkMode = AdaptiveColors.isDarkMode(context);

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
    final isDarkMode = AdaptiveColors.isDarkMode(context);

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
                      widget.employee['name'].toString().split(' ')[0],
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('lastName'),
                      widget.employee['name'].toString().split(' ').length > 1
                          ? widget.employee['name'].toString().split(' ')[1]
                          : "",
                      Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mobile/Email row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('mobileNumber'),
                      "(702) 555-0122", // Sample data
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('emailAddress'),
                      "${widget.employee['name'].toString().toLowerCase().replaceAll(' ', '.')}@example.com",
                      Icons.email_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Other personal info fields
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('dateOfBirth'),
                      "July 14, 1995", // Sample data
                      Icons.cake_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('maritalStatus'),
                      "Married", // Sample data
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
                      "Female", // Sample data
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('nationality'),
                      "American", // Sample data
                      Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildInfoField(
                context,
                localizations.getString('address'),
                "2464 Royal Ln, Mesa, New Jersey", // Sample data
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('city'),
                      "California", // Sample data
                      Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('state'),
                      "United State", // Sample data
                      Icons.map_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('zipCode'),
                      "35624", // Sample data
                      Icons.pin_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInformation(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkMode = AdaptiveColors.isDarkMode(context);

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
                      widget.employee['id'],
                      Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('userName'),
                      widget.employee['name']
                          .toString()
                          .toLowerCase()
                          .replaceAll(' ', '_'),
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
                      widget.employee['type'],
                      Icons.business_center_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('department'),
                      widget.employee['department'],
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
                      localizations.getString('workingDays'),
                      "5 Days",
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      context,
                      localizations.getString('joiningDate'),
                      "July 10, 2022",
                      Icons.date_range_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoField(
                context,
                localizations.getString('officeLocation'),
                "2464 Royal Ln, Mesa, New Jersey", // Sample data
                Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
      BuildContext context, String label, String value, IconData icon) {
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

    // Sample attendance data - refined to match web version
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
