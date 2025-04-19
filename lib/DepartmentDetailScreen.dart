import 'package:flutter/material.dart';
import 'package:in_out/EmployeeProfileScreen.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/localization/app_localizations.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String departmentName;
  final List<Map<String, dynamic>> employees;

  const DepartmentDetailScreen({
    super.key,
    required this.departmentName,
    required this.employees,
  });

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  late TextEditingController _searchController;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredEmployees {
    if (_searchQuery.isEmpty) {
      return widget.employees;
    }

    return widget.employees
        .where((employee) => employee['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
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

  void _viewEmployeeDetails(Map<String, dynamic> employee) {
    // Create a complete employee object with required fields for EmployeeProfileScreen
    final completeEmployee = {
      'name': employee['name'],
      'avatar': employee['avatar'],
      'avatarColor': Colors.blue.shade100,
      'textColor': Colors.blue.shade800,
      'id': '123456', // Sample ID
      'department': widget.departmentName.replaceAll(' Department', ''),
      'designation': employee['position'],
      'type': 'Full-time', // Default value since not provided
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeProfileScreen(
          employeeId: int.parse(employee['id']),
        ),
      ),
    );
  }

  Widget _buildEmployeeAvatar(Map<String, dynamic> employee) {
    final initials = employee['avatar'] ??
        employee['name'].toString().split(' ').map((e) => e[0]).take(2).join('');

    return CircleAvatar(
      radius: 20,
      backgroundColor: _getAvatarColor(employee['name']),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    // Simple hash function to get consistent colors
    final colors = [
      Colors.blue.shade300,
      Colors.red.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
      Colors.teal.shade300,
    ];

    int hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AdaptiveColors.cardColor(context),
        elevation: 0,
        title: Text(
          widget.departmentName,
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: AdaptiveColors.primaryTextColor(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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

            // Department members count
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              child: Row(
                children: [
                  Text(
                    "${widget.employees.length} ${localizations.getString('members')}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Employees list
            Expanded(
              child: _filteredEmployees.isEmpty
                  ? Center(
                child: Text(
                  localizations.getString('noEmployeesFound'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              )
                  : ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: _filteredEmployees.length,
                separatorBuilder: (context, index) => Divider(
                  color: AdaptiveColors.borderColor(context),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  return InkWell(
                    onTap: () => _viewEmployeeDetails(employee),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      child: Row(
                        children: [
                          _buildEmployeeAvatar(employee),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee['name'],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AdaptiveColors.primaryTextColor(context),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  employee['position'],
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
                            size: screenWidth * 0.04,
                          ),
                        ],
                      ),
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
}