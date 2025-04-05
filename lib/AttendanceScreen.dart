import 'package:flutter/material.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'localization/app_localizations.dart';
import 'data/attendance_data.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 0; // Nous pouvons ajuster cet index selon la position dans la navigation
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
      filtered = filtered.where((attendance) =>
      attendance['employeeName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          attendance['designation'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtres supplémentaires peuvent être ajoutés ici

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
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {},
            ),

            // Search and Filter Bar
            _buildSearchAndFilterBar(context),

            // Table Content
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
                    _buildPaginationFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    List<String> filterOptions = ['Day', 'Month', 'Year'];

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: Container(
              height: screenHeight * 0.065,
              decoration: BoxDecoration(
                color: AdaptiveColors.cardColor(context),
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
                border: Border.all(color: AdaptiveColors.borderColor(context)),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AdaptiveColors.primaryTextColor(context),
                  fontSize: screenHeight * 0.022,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AdaptiveColors.secondaryTextColor(context),
                    size: screenHeight * 0.028,
                  ),
                  hintStyle: TextStyle(
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                  ),
                  isDense: true,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.015),

          // Filter Dropdown
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.01,
            ),
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              borderRadius: BorderRadius.circular(screenWidth * 0.006),
              border: Border.all(color: AdaptiveColors.borderColor(context)),
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AdaptiveColors.secondaryTextColor(context),
              ),
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: screenHeight * 0.022,
              ),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _handleFilterChange(newValue);
                }
              },
              dropdownColor: AdaptiveColors.cardColor(context),
              items: filterOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTableHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

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
              'Employee Name',
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
                  _buildHeaderCell(context, 'Designation', 0.20),
                  _buildHeaderCell(context, 'Type', 0.15),
                  _buildHeaderCell(context, 'Check-In Time', 0.15),
                  _buildHeaderCell(context, 'Status', 0.15),
                  _buildHeaderCell(context, 'Actions', 0.10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title, double widthPercent) {
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
    if (_paginatedAttendances.isEmpty) {
      return Center(
        child: Text(
          'No attendance records found',
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

  Widget _buildPaginationFooter(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AdaptiveColors.borderColor(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Showing x to y of z records" text
          Text(
            'Showing ${(_currentPage - 1) * _itemsPerPage + 1} to ${_currentPage * _itemsPerPage > _filteredAttendances.length ? _filteredAttendances.length : _currentPage * _itemsPerPage} out of ${_filteredAttendances.length} records',
            style: TextStyle(
              color: AdaptiveColors.secondaryTextColor(context),
              fontSize: screenHeight * 0.02,
            ),
          ),

          // Pagination controls
          Row(
            children: [
              _buildPaginationButton(
                context,
                Icons.chevron_left,
                _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
              ),
              ..._buildPageNumbers(context),
              _buildPaginationButton(
                context,
                Icons.chevron_right,
                _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    List<Widget> pageNumbers = [];
    List<int> pagesToShow = [];

    if (_totalPages <= 5) {
      pagesToShow = List.generate(_totalPages, (i) => i + 1);
    } else {
      pagesToShow.add(1);

      for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
        if (i > 1 && i < _totalPages) {
          pagesToShow.add(i);
        }
      }

      pagesToShow.add(_totalPages);
      pagesToShow = pagesToShow.toSet().toList()..sort();

      if (pagesToShow[0] + 1 != pagesToShow[1]) {
        pagesToShow.insert(1, -1); // -1 represents ellipsis
      }

      if (pagesToShow[pagesToShow.length - 2] + 1 != pagesToShow[pagesToShow.length - 1]) {
        pagesToShow.insert(pagesToShow.length - 1, -1);
      }
    }

    for (int i = 0; i < pagesToShow.length; i++) {
      if (pagesToShow[i] == -1) {
        pageNumbers.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
            child: Text(
              '...',
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
                fontSize: screenHeight * 0.024,
              ),
            ),
          ),
        );
      } else {
        pageNumbers.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
            child: InkWell(
              onTap: () => _changePage(pagesToShow[i]),
              child: Container(
                width: screenHeight * 0.045,
                height: screenHeight * 0.045,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentPage == pagesToShow[i]
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.004),
                  border: Border.all(
                    color: _currentPage == pagesToShow[i]
                        ? const Color(0xFF2E7D32)
                        : AdaptiveColors.borderColor(context),
                  ),
                ),
                child: Text(
                  '${pagesToShow[i]}',
                  style: TextStyle(
                    color: _currentPage == pagesToShow[i]
                        ? Colors.white
                        : AdaptiveColors.primaryTextColor(context),
                    fontWeight: _currentPage == pagesToShow[i] ? FontWeight.bold : FontWeight.normal,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return pageNumbers;
  }

  Widget _buildPaginationButton(BuildContext context, IconData icon, VoidCallback? onPressed) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: screenHeight * 0.045,
          height: screenHeight * 0.045,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(screenWidth * 0.004),
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            size: screenHeight * 0.022,
            color: onPressed == null
                ? AdaptiveColors.tertiaryTextColor(context)
                : AdaptiveColors.primaryTextColor(context),
          ),
        ),
      ),
    );
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }
}

class AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> attendance;
  final ScrollController horizontalScrollController;

  const AttendanceRow({
    Key? key,
    required this.attendance,
    required this.horizontalScrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final rowHeight = screenHeight * 0.09;

    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final lightBorderColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;

    // Détermine la couleur du statut
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
                  backgroundImage: attendance['avatar'] != null ? AssetImage(attendance['avatar']) : null,
                  backgroundColor: Colors.grey.shade300,
                  child: attendance['avatar'] == null ? Text(
                    attendance['initials'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.02,
                    ),
                  ) : null,
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
                  _buildStatusCell(context, attendance['status'], statusColor, 0.15),
                  _buildActionCell(context, 0.10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(BuildContext context, String text, double widthPercent) {
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

  Widget _buildStatusCell(BuildContext context, String status, Color statusColor, double widthPercent) {
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
            status,
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