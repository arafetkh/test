import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/LandscapeUserProfileHeader.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/SearchAndFilterBar.dart';
import 'package:in_out/widget/pagination_widgets.dart';

import 'data/attendance_data.dart';
import 'localization/app_localizations.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 2;
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isHeaderVisible = true;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _searchQuery = '';
  String _selectedFilter = 'Month';

  List<Map<String, dynamic>> get _filteredAttendances {
    List<Map<String, dynamic>> filtered = attendances;

    // Appliquer le filtre de recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((attendance) =>
              attendance['employeeName']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              attendance['designation']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedAttendances {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage < _filteredAttendances.length
        ? startIndex + _itemsPerPage
        : _filteredAttendances.length;

    if (startIndex >= _filteredAttendances.length) {
      return [];
    }

    return _filteredAttendances.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredAttendances.length / _itemsPerPage).ceil();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchQuery);
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 1;
        });
      }
    });
    _mainScrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _mainScrollController.offset <= 50;
    });
  }

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).getString('selectFilter')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)
                      .getString('filterByMonth')),
                  onTap: () => _handleFilterChange('Month'),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)
                      .getString('filterByYear')),
                  onTap: () => _handleFilterChange('Year'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)
                  .getString('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête de profil utilisateur
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {},
            ),

            // Barre de recherche et de filtre
            SearchAndFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) {},
              onAddNewEmployee: () {
                // Fonction pour ajouter un nouvel employé
              },
              onFilterTap: (context) => _showFilterDialog(context),
            ),

            // Contenu de la table
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.015,
                  0,
                  screenWidth * 0.015,
                  screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: AdaptiveColors.cardColor(context),
                  borderRadius: BorderRadius.circular(screenWidth * 0.008),
                  boxShadow: [
                    BoxShadow(
                      color: AdaptiveColors.shadowColor(context),
                      spreadRadius: screenWidth * 0.001,
                      blurRadius: screenWidth * 0.003,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAttendanceTableHeader(context),
                    Expanded(
                      child: _buildAttendanceTable(context),
                    ),
                    // Widget de pagination
                    PaginationFooter(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      filteredEmployeesCount: _filteredAttendances.length,
                      itemsPerPage: _itemsPerPage,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTableHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.008),
          topRight: Radius.circular(screenWidth * 0.008),
        ),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            spreadRadius: screenWidth * 0.001,
            blurRadius: screenWidth * 0.003,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Employee Name Column
          Container(
            width: screenWidth * 0.25,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.015,
              vertical: screenHeight * 0.03,
            ),
            child: Text(
              localizations.getString('employeeName'),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: screenHeight * 0.025,
              ),
            ),
          ),

          // Other columns - scrollable area
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: [
                  _buildHeaderCell(
                      context, localizations.getString('designation'), 0.20),
                  _buildHeaderCell(
                      context, localizations.getString('type'), 0.15),
                  _buildHeaderCell(
                      context, localizations.getString('checkInTime'), 0.15),
                  _buildHeaderCell(
                      context, localizations.getString('status'), 0.15),
                  _buildHeaderCell(
                      context, localizations.getString('actions'), 0.10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      BuildContext context, String title, double widthPercent) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return SizedBox(
      width: screenWidth * widthPercent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.03,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.025,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTable(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_paginatedAttendances.isEmpty) {
      return Center(
        child: Text(
          localizations.getString('noAttendanceRecords'),
          style: TextStyle(
            fontSize: 16,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _mainScrollController,
      itemCount: _paginatedAttendances.length,
      itemBuilder: (context, index) {
        return AttendanceRow(
          attendance: _paginatedAttendances[index],
          horizontalScrollController: _horizontalScrollController,
        );
      },
    );
  }
}

class AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> attendance;
  final ScrollController horizontalScrollController;

  const AttendanceRow({
    super.key,
    required this.attendance,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final rowHeight = screenHeight * 0.09;
    final localizations = AppLocalizations.of(context);

    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final lightBorderColor =
        isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;

    Color statusColor;
    if (attendance['status'] == 'On Time') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed employee name column
        Container(
          width: screenWidth * 0.25,
          height: rowHeight,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: lightBorderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: screenHeight * 0.028,
                  backgroundImage: attendance['avatar'] != null
                      ? AssetImage(attendance['avatar'])
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: attendance['avatar'] == null
                      ? Text(
                          attendance['initials'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.02,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: screenWidth * 0.01),
                Expanded(
                  child: Text(
                    attendance['employeeName'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenHeight * 0.022,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable data cells
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: horizontalScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: rowHeight,
              width: screenWidth * (0.20 + 0.15 + 0.15 + 0.15 + 0.10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: lightBorderColor),
                ),
              ),
              child: Row(
                children: [
                  _buildDataCell(context, attendance['designation'], 0.20),
                  _buildDataCell(context, attendance['type'], 0.15),
                  _buildDataCell(context, attendance['checkInTime'], 0.15),
                  _buildStatusCell(
                      context, attendance['status'], statusColor, 0.15),
                  _buildActionCell(context, 0.10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(
      BuildContext context, String text, double widthPercent) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return SizedBox(
      width: screenWidth * widthPercent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.03,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.022,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(BuildContext context, String status,
      Color statusColor, double widthPercent) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // Traduire le statut "On Time" ou "Late"
    String translatedStatus = status;
    if (status == "On Time") {
      translatedStatus = localizations.getString("onTime");
    } else if (status == "Late") {
      translatedStatus = localizations.getString("late");
    }

    return SizedBox(
      width: screenWidth * widthPercent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.03,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Text(
            translatedStatus,
            style: TextStyle(
              color: statusColor,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, double widthPercent) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return SizedBox(
      width: screenWidth * widthPercent,
      child: Center(
        child: IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: AdaptiveColors.primaryTextColor(context),
            size: screenHeight * 0.03,
          ),
          onPressed: () {
            // Action for editing the attendance record
          },
        ),
      ),
    );
  }
}
