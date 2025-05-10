import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_out/screens/employees/edit_employee_screen.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/services/employee_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:in_out/auth/global.dart';
import 'add_employee_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../localization/app_localizations.dart';
import '../../models/employee_model.dart';
import '../../widget/search_and_filter_bar.dart';
import '../../widget/pagination_widgets.dart';
import 'package:in_out/widget/landscape_user_profile_header.dart';

import 'employee_profile/employee_profile_screen.dart';

class EmployeeTableScreen extends StatefulWidget {
  const EmployeeTableScreen({super.key});

  @override
  State<EmployeeTableScreen> createState() => _EmployeeTableScreenState();
}

class _EmployeeTableScreenState extends State<EmployeeTableScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 1;
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderVisible = true;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  int _itemsPerPage = 10;
  String _searchQuery = '';

  // Employee data variables
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Selected filters
  Set<String> _selectedDepartments = {};
  Set<String> _selectedWorkTypes = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchQuery);

    // Don't use addListener as we'll handle search in the onSearchChanged callback

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _mainScrollController.addListener(_scrollListener);

    // Initial data fetch
    _fetchEmployees();
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
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _mainScrollController.offset <= 50;
    });
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Construct API URL with pagination parameters as query parameters
      final Uri url = Uri.parse("${Global.baseUrl}/secure/users-management/filter?page=$_currentPage&size=$_itemsPerPage");

      // Create filter body according to the API's expected format
      final Map<String, dynamic> filterBody = {};

      // Add search query if present
      if (_searchQuery.isNotEmpty) {
        filterBody['name'] = _searchQuery;
      }

      // Add department filter if selected
      if (_selectedDepartments.isNotEmpty) {
        // API expects an object with 'name' field containing an array
        filterBody['department'] = {
          "name": _selectedDepartments.toList()
        };
      }

      // Add work type filter if selected
      if (_selectedWorkTypes.isNotEmpty) {
        // API expects 'type' field with an array of work types
        filterBody['type'] = _selectedWorkTypes.toList();
      }

      print("Fetching employees with URL: $url and filter: $filterBody");

      final response = await http.post(
        url,
        headers: {
          ...Global.headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Update pagination info
        _totalElements = data['page']['totalElements'] ?? 0;
        _totalPages = data['page']['totalPages'] ?? 1;

        List<Map<String, dynamic>> employees = [];
        if (data.containsKey('content') && data['content'] is List) {
          for (var emp in data['content']) {
            // Extract department from attributes if available
            String department = 'Unknown';
            if (emp['attributes'] != null &&
                emp['attributes']['department'] != null &&
                emp['attributes']['department']['name'] != null) {
              department = emp['attributes']['department']['name'];
            } else if (emp['department'] != null) {
              // fallback to direct department field
              department = emp['department'];
            }

            Map<String, dynamic> employee = {
              'id': emp['id']?.toString() ?? '',
              'name': "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}",
              'avatar': _getInitials("${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}"),
              'avatarColor': Colors.blue.shade100,
              'textColor': Colors.blue.shade800,
              'department': department,
              'designation': emp['designation'] ?? 'Unknown',
              'type': emp['type'] ?? 'Unknown',
              'companyId': emp['companyId'] ?? 'N/A',
              'firstName': emp['firstName'],
              'lastName': emp['lastName'],
              'email': emp['email'],
              'personalEmail': emp['personalEmail'],
              'phoneNumber': emp['phoneNumber'],
              'attributes': emp['attributes'] ?? {},
              'active': emp['active'] ?? true,
              'role': emp['role'] ?? 'USER',
            };

            employees.add(employee);
          }
        }

        setState(() {
          _employees = employees;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load employees: ${response.statusCode}';
          _isLoading = false;
        });
        print("Error response body: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
      print("Exception in _fetchEmployees: $e");
    }
  }

  // Obtenir les initiales d'un nom
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }
    return '';
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  // Gérer l'ajout d'un nouvel employé
  void _addNewEmployee(Employee newEmployee) {
    // Recharger les données après l'ajout d'un nouvel employé
    _fetchEmployees();
  }

  // Gérer l'affichage des détails d'un employé
  void _viewEmployeeDetails(Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeProfileScreen(
          employeeId: int.parse(employee['id']),
        ),
      ),
    ).then((_) => _fetchEmployees()); // Refresh on return
  }

  void _showFilterDialog(BuildContext context) {
    final isDarkMode = AdaptiveColors.isDarkMode(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;

        // Variables d'état pour les sélections
        Set<String> selectedDepartments = Set.from(_selectedDepartments);
        Set<String> selectedWorkTypes = Set.from(_selectedWorkTypes);
        final localizations = AppLocalizations.of(context);

        // Get unique departments from current data
        Set<String> availableDepartments = _employees
            .map((emp) => emp['department'].toString())
            .where((dept) => dept != 'Unknown')
            .toSet();

        // Fallback departments if none found
        if (availableDepartments.isEmpty) {
          availableDepartments = {
            'Design',
            'HR',
            'Sales',
            'Marketing',
            'Development',
            'IT',
            'Finance',
          };
        }

        // Get unique work types from current data
        Set<String> availableWorkTypes = _employees
            .map((emp) => emp['type'].toString())
            .where((type) => type != 'Unknown')
            .toSet();

        // Fallback work types if none found
        if (availableWorkTypes.isEmpty) {
          availableWorkTypes = {'OFFICE', 'REMOTE', 'HYBRID'};
        }

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

                  // Filter options
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Department filters
                          Text(
                            localizations.getString('department'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: availableDepartments.map((dept) {
                              return FilterChip(
                                label: Text(dept),
                                selected: selectedDepartments.contains(dept),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedDepartments.add(dept);
                                    } else {
                                      selectedDepartments.remove(dept);
                                    }
                                  });
                                },
                                backgroundColor: AdaptiveColors.cardColor(context),
                                selectedColor: const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0),
                                checkmarkColor: const Color(0xFF377D25),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Work type filters
                          Text(
                            localizations.getString('selectType'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: availableWorkTypes.map((type) {
                              return FilterChip(
                                label: Text(type),
                                selected: selectedWorkTypes.contains(type),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedWorkTypes.add(type);
                                    } else {
                                      selectedWorkTypes.remove(type);
                                    }
                                  });
                                },
                                backgroundColor: AdaptiveColors.cardColor(context),
                                selectedColor: const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0),
                                checkmarkColor: const Color(0xFF377D25),
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
                            borderRadius: BorderRadius.circular(screenWidth * 0.004),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.024,
                              vertical: screenHeight * 0.012
                          ),
                        ),
                        child: Text(localizations.getString('apply')),
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
          _currentPage = 0; // Reset to first page when filters change
        });
        _fetchEmployees(); // Fetch with new filters
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
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            SearchAndFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 0; // Reset to first page on search
                });
                _fetchEmployees();
              },
              onAddNewEmployee: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEmployeeScreen(
                        onEmployeeAdded: _addNewEmployee,
                      )
                  ),
                ).then((_) => _fetchEmployees()); // Refresh on return
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
                    _isLoading
                        ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.green.shade800,
                        ),
                      ),
                    )
                        : _errorMessage.isNotEmpty
                        ? Expanded(
                      child: Center(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: screenWidth * 0.02,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                        : TwoDimensionalEmployeeTable(
                      employees: _employees,
                      onViewEmployee: _viewEmployeeDetails,
                    ),
                    PaginationFooter(
                      currentPage: _currentPage + 1,
                      totalPages: _totalPages > 0 ? _totalPages : 1,
                      filteredEmployeesCount: _totalElements,
                      itemsPerPage: _itemsPerPage,
                      onPageChanged: (page) {
                        if (page != _currentPage + 1) { // Only fetch if page actually changed
                          setState(() {
                            _currentPage = page - 1; // API uses 0-based indexing
                          });
                          _fetchEmployees();
                          print("Changing to page: $page, API page: ${page-1}");
                        }
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
}

class TwoDimensionalEmployeeTable extends StatelessWidget {
  final List<Map<String, dynamic>> employees;
  final Function(Map<String, dynamic>) onViewEmployee;

  const TwoDimensionalEmployeeTable({
    super.key,
    required this.employees,
    required this.onViewEmployee,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    if (employees.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.5,
        child: Center(
          child: Text(
            localizations.getString('noEmployeesFound'),
            style: TextStyle(
              fontSize: 16,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    // Table headers
    final headerTitles = [
      localizations.getString('employeeName'),
      'Company ID', // Using companyId consistently
      localizations.getString('department'),
      localizations.getString('designation'),
      localizations.getString('type'),
      localizations.getString('action')
    ];

    return Expanded(
      child: TableView.builder(
        rowCount: employees.length + 1,
        columnCount: headerTitles.length,
        cellBuilder: (context, vicinity) {
          return TableViewCell(
            child: _buildCellWidget(context, vicinity, headerTitles),
          );
        },

        columnBuilder: (index) {
          double width;
          switch (index) {
            case 0:
              width = screenWidth * 0.25;
              break;
            case 1:
              width = screenWidth * 0.15;
              break;
            case 2:
              width = screenWidth * 0.15;
              break;
            case 3:
              width = screenWidth * 0.18;
              break;
            case 4:
              width = screenWidth * 0.1;
              break;
            case 5:
              width = screenWidth * 0.1;
              break;
            default:
              width = screenWidth * 0.15;
          }
          return TableSpan(
            extent: FixedTableSpanExtent(width),
          );
        },

        rowBuilder: (index) {
          double height = index == 0
              ? screenHeight * 0.08
              : screenHeight * 0.09;
          return TableSpan(
            extent: FixedTableSpanExtent(height),
          );
        },

        pinnedRowCount: 1,
        pinnedColumnCount: 1,
      ),
    );
  }

  Widget _buildCellWidget(BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final localizations = AppLocalizations.of(context);

    // Header Row
    if (row == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: column > 0 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
          ),
        ),
        child: Text(
          headerTitles[column],
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.025,
          ),
        ),
      );
    }

    // Data rows
    final employeeIndex = row - 1;
    final employee = employees[employeeIndex];

    // Employee name column with avatar
    if (column == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: screenHeight * 0.028,
              backgroundColor: employee['avatarColor'] ?? Colors.blue.shade100,
              child: Text(
                employee['avatar'] ?? '',
                style: TextStyle(
                  color: employee['textColor'] ?? Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                employee['name'] ?? '',
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
      );
    }

    // Action column
    if (column == 5) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Center(
          child: PopupMenuButton<String>(
            icon: Icon(
                Icons.more_vert,
                size: screenHeight * 0.035,
                color: AdaptiveColors.secondaryTextColor(context)
            ),
            padding: EdgeInsets.zero,
            color: AdaptiveColors.cardColor(context),
            onSelected: (String result) {
              if (result == 'view') {
                onViewEmployee(employee);
              } else if (result == 'edit') {
                // Navigate to edit employee screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEmployeeScreen(
                      employeeData: employee,
                      onEmployeeUpdated: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.getString('employeeUpdatedSuccessfully') ?? 'Employee updated successfully' ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              } else if (result == 'delete') {
                // Handle delete action
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(localizations.getString('confirmDelete')),
                      content: Text(localizations.getString('areYouSureDelete') ?? 'Are you sure you want to delete this employee?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(localizations.getString('cancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteEmployee(context, employee['id']);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            localizations.getString('delete'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupItem(context, 'view', Icons.visibility_outlined, 'view'),
              _buildPopupItem(context, 'edit', Icons.edit_outlined, 'edit'),
              _buildPopupItem(context, 'delete', Icons.delete_outline, 'delete', isDelete: true),
            ],
          ),
        ),
      );
    }

    // Other columns - dynamic content based on column index
    String cellText = '';
    switch (column) {
      case 1:
        cellText = employee['companyId'] ?? 'N/A';
        break;
      case 2:
        cellText = employee['department'] ?? '';
        break;
      case 3:
        cellText = employee['designation'] ?? '';
        break;
      case 4:
        cellText = employee['type'] ?? '';
        break;
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
          right: column < 5 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: Text(
        cellText,
        style: TextStyle(
          color: AdaptiveColors.primaryTextColor(context),
          fontSize: screenHeight * 0.022,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _deleteEmployee(BuildContext context, String employeeId) async {
    try {
      final result = await EmployeeService.deleteEmployee(int.parse(employeeId));

      if (result["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the page
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeTableScreen(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result["message"]}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  PopupMenuItem<String> _buildPopupItem(
      BuildContext context, String value, IconData icon, String textKey,
      {bool isDelete = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: screenHeight * 0.035,
            color: isDelete
                ? Colors.red
                : AdaptiveColors.secondaryTextColor(context),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.008),
          Text(
            localizations.getString(textKey),
            style: TextStyle(
              color: isDelete
                  ? Colors.red
                  : AdaptiveColors.primaryTextColor(context),
              fontSize: screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }
}