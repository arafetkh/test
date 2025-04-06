import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'AddEmployeeScreen.dart';
import 'data/employees_data.dart';
import 'widget/employee_table_widgets.dart';
import 'widget/pagination_widgets.dart';
import 'localization/app_localizations.dart';
import 'widget/SearchAndFilterBar.dart';


class EmployeeTableScreen extends StatefulWidget {
  const EmployeeTableScreen({super.key});

  @override
  State<EmployeeTableScreen> createState() => _EmployeeTableScreenState();
}

class _EmployeeTableScreenState extends State<EmployeeTableScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 1;
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isHeaderVisible = true;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredEmployees {
    List<Map<String, dynamic>> filtered = employees;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employee) =>
      employee['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['department'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['designation'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply department filters
    if (_selectedDepartments.isNotEmpty) {
      filtered = filtered.where((employee) =>
          _selectedDepartments.contains(employee['department'])).toList();
    }

    // Apply work type filters
    if (_selectedWorkTypes.isNotEmpty) {
      filtered = filtered.where((employee) =>
          _selectedWorkTypes.contains(employee['type'])).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedEmployees {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage < _filteredEmployees.length
        ? startIndex + _itemsPerPage
        : _filteredEmployees.length;

    if (startIndex >= _filteredEmployees.length) {
      return [];
    }

    return _filteredEmployees.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredEmployees.length / _itemsPerPage).ceil();

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
    // Set up listener to update _searchQuery when controller changes
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 1;
        });
      }
    });
    // Maintain landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _mainScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

  Set<String> _selectedDepartments = {};
  Set<String> _selectedWorkTypes = {};
  void _showFilterDialog(BuildContext context) {
    final isDarkMode = AdaptiveColors.isDarkMode(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;

        // State variables for selections
        Set<String> selectedDepartments = Set.from(_selectedDepartments);
        Set<String> selectedWorkTypes = Set.from(_selectedWorkTypes);
        final localizations = AppLocalizations.of(context);

        final departments = [
          'Design',
          'HR',
          'Sales',
          'Business Analyst',
          'Project Manager'
        ];

        final techSkills = ['Java', 'Python', 'React JS', 'Account', 'Node JS'];

        final workTypes = ['Office', 'Remote'];

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: AdaptiveColors.cardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.012),
            ),
            child: Container(
              width: screenWidth * 0.85,
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.85,
                maxHeight: screenHeight * 0.8,
              ),
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter title
                  Text(
                    localizations.getString('filter'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.018,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF377D25),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column - Departments
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: departments
                                      .map((dept) => CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                    ListTileControlAffinity.leading,
                                    activeColor:
                                    const Color(0xFF377D25),
                                    title: Text(
                                      dept,
                                      style: TextStyle(
                                        color: AdaptiveColors.primaryTextColor(context),
                                      ),
                                    ),
                                    value: selectedDepartments
                                        .contains(dept),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedDepartments.add(dept);
                                        } else {
                                          selectedDepartments
                                              .remove(dept);
                                        }
                                      });
                                    },
                                  ))
                                      .toList(),
                                ),
                              ),

                              // Right column - Tech Skills
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: techSkills
                                      .map((skill) => CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                    ListTileControlAffinity.leading,
                                    activeColor:
                                    const Color(0xFF377D25),
                                    title: Text(
                                      skill,
                                      style: TextStyle(
                                        color: AdaptiveColors.primaryTextColor(context),
                                      ),
                                    ),
                                    value: selectedDepartments
                                        .contains(skill),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedDepartments
                                              .add(skill);
                                        } else {
                                          selectedDepartments
                                              .remove(skill);
                                        }
                                      });
                                    },
                                  ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Type section
                          Text(
                            localizations.getString('selectType'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // Work type options - using Wrap for responsiveness
                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: workTypes.map((type) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedWorkTypes.contains(type)) {
                                      selectedWorkTypes.remove(type);
                                    } else {
                                      selectedWorkTypes.add(type);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.016,
                                      vertical: screenHeight * 0.01),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF377D25),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                    color: selectedWorkTypes.contains(type)
                                        ? const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0)
                                        : AdaptiveColors.cardColor(context),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedDepartments.clear();
                            selectedWorkTypes.clear();
                          });
                        },
                        child: Text(
                          localizations.getString('clearFilters'),
                          style: const TextStyle(
                            color: Color(0xFF377D25),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'departments': selectedDepartments,
                            'workTypes': selectedWorkTypes,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF377D25),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(screenWidth * 0.004),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.024,
                              vertical: screenHeight * 0.012),
                        ),
                        child: Text(localizations.getString('filter')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          _selectedDepartments = result['departments'];
          _selectedWorkTypes = result['workTypes'];
          _currentPage = 1; // Reset to first page when filters change
        });

        print('Selected departments: ${result['departments']}');
        print('Selected work types: ${result['workTypes']}');
      }
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
            UserHeader(isHeaderVisible: _isHeaderVisible),
            SearchAndFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) {},
              onAddNewEmployee: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEmployeeScreen()),
                );
              },
              onFilterTap: (context) => _showFilterDialog(context),
            ),
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
                    EmployeeTableHeader(horizontalScrollController: _horizontalScrollController),
                    Expanded(
                      child: EmployeeTableView(
                        employees: _paginatedEmployees,
                        mainScrollController: _mainScrollController,
                        horizontalScrollController: _horizontalScrollController,
                      ),
                    ),
                    PaginationFooter(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      filteredEmployeesCount: _filteredEmployees.length,
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
            )
          ],
        ),
      ),
    );
  }
}