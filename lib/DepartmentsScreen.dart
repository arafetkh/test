import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/DepartmentDetailScreen.dart';
import 'package:in_out/NotificationsScreen.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'localization/app_localizations.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  int _selectedIndex = 1; // Index for departments/employees in the navigation
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;
  String _searchQuery = '';

  // Sample departments data
  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Design Department',
      'members': 20,
      'employees': [
        {'name': 'Dianne Russell', 'position': 'Lead UI/UX Designer', 'avatar': 'DR'},
        {'name': 'Arlene McCoy', 'position': 'Sr. UI/UX Designer', 'avatar': 'AM'},
        {'name': 'Cody Fisher', 'position': 'Sr. UI/UX Designer', 'avatar': 'CF'},
        {'name': 'Theresa Webb', 'position': 'UI/UX Designer', 'avatar': 'TW'},
        {'name': 'Ronald Richards', 'position': 'UI/UX Designer', 'avatar': 'RR'},
      ]
    },
    {
      'name': 'Sales Department',
      'members': 14,
      'employees': [
        {'name': 'Darrell Steward', 'position': 'Sr. Sales Manager', 'avatar': 'DS'},
        {'name': 'Kristin Watson', 'position': 'Sr. Sales Manager', 'avatar': 'KW'},
        {'name': 'Courtney Henry', 'position': 'BDM', 'avatar': 'CH'},
        {'name': 'Kathryn Murphy', 'position': 'BDE', 'avatar': 'KM'},
        {'name': 'Albert Flores', 'position': 'Sales', 'avatar': 'AF'},
      ]
    },
    {
      'name': 'Project Manager Department',
      'members': 18,
      'employees': [
        {'name': 'Leslie Alexander', 'position': 'Sr. Project Manager', 'avatar': 'LA'},
        {'name': 'Ronald Richards', 'position': 'Sr. Project Manager', 'avatar': 'RR'},
        {'name': 'Savannah Nguyen', 'position': 'Project Manager', 'avatar': 'SN'},
        {'name': 'Eleanor Pena', 'position': 'Project Manager', 'avatar': 'EP'},
        {'name': 'Esther Howard', 'position': 'Project Manager', 'avatar': 'EH'},
      ]
    },
    {
      'name': 'Marketing Department',
      'members': 10,
      'employees': [
        {'name': 'Wade Warren', 'position': 'Sr. Marketing Manager', 'avatar': 'WW'},
        {'name': 'Brooklyn Simmons', 'position': 'Sr. Marketing Manager', 'avatar': 'BS'},
        {'name': 'Kristin Watson', 'position': 'Marketing Coordinator', 'avatar': 'KW'},
        {'name': 'Jacob Jones', 'position': 'Marketing Coordinator', 'avatar': 'JJ'},
        {'name': 'Cody Fisher', 'position': 'Marketing', 'avatar': 'CF'},
      ]
    },
    {
      'name': 'Development Department',
      'members': 25,
      'employees': [
        {'name': 'Marvin McKinney', 'position': 'Sr. Developer', 'avatar': 'MM'},
        {'name': 'Jacob Jones', 'position': 'React Developer', 'avatar': 'JJ'},
        {'name': 'Devon Lane', 'position': 'Full Stack Developer', 'avatar': 'DL'},
        {'name': 'Floyd Miles', 'position': 'PHP Developer', 'avatar': 'FM'},
        {'name': 'Kathryn Murphy', 'position': 'React JS Developer', 'avatar': 'KM'},
      ]
    },
    {
      'name': 'Human Resources',
      'members': 8,
      'employees': [
        {'name': 'Kristin Watson', 'position': 'HR Executive', 'avatar': 'KW'},
        {'name': 'Brooklyn Simmons', 'position': 'HR Manager', 'avatar': 'BS'},
        {'name': 'Eleanor Pena', 'position': 'HR Assistant', 'avatar': 'EP'},
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredDepartments {
    if (_searchQuery.isEmpty) {
      return _departments;
    }

    return _departments.where((department) =>
        department['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _scrollController.addListener(_scrollListener);

    // Set preferred orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  void _navigateToDepartmentDetail(Map<String, dynamic> department) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartmentDetailScreen(
          departmentName: department['name'],
          employees: department['employees'],
        ),
      ),
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
            // User profile header
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: localizations.getString('search'),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: AdaptiveColors.cardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.green.shade800),
                  ),
                ),
              ),
            ),

            // Department title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              child: Row(
                children: [
                  Text(
                    localizations.getString('departments'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Departments list
            Expanded(
              child: _filteredDepartments.isEmpty
                  ? Center(
                child: Text(
                  localizations.getString('noDepartmentsFound'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: _filteredDepartments.length,
                itemBuilder: (context, index) {
                  final department = _filteredDepartments[index];
                  return _buildDepartmentCard(
                    context,
                    department,
                    screenWidth,
                    screenHeight,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDepartmentCard(
      BuildContext context,
      Map<String, dynamic> department,
      double screenWidth,
      double screenHeight,
      ) {
    return GestureDetector(
      onTap: () => _navigateToDepartmentDetail(department),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department['name'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${department['members']} ${AppLocalizations.of(context).getString('members')}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AdaptiveColors.secondaryTextColor(context),
                size: screenWidth * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}