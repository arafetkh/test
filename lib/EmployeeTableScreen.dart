import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/EmployeeProfileScreen.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'AddEmployeeScreen.dart';
import 'NotificationsScreen.dart';
import 'data/employees_data.dart';
import 'localization/app_localizations.dart';
import 'widget/SearchAndFilterBar.dart';
import 'widget/pagination_widgets.dart';

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
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _mainScrollController.offset <= 50;
    });
  }

  // Handle new employee addition
  void _addNewEmployee(Map<String, dynamic> newEmployee) {
    setState(() {
      // The employee is already added to the global employees list
      // Just update the state to reflect changes
      _currentPage = 1; // Go back to first page to show the new employee
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee ${newEmployee['name']} added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Handle viewing employee details
  void _viewEmployeeDetails(Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeProfileScreen(
          employee: employee,
        ),
      ),
    );
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
          'Project Manager',
          'Development',
          'IT',
          'Finance',
          'Marketing'
        ];

        final techSkills = ['Java', 'Python', 'React JS', 'Account', 'Node JS'];

        final workTypes = [
          'Office',
          'Remote',
          'Full-time',
          'Part-time',
          'Contract'
        ];

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
                      builder: (context) => AddEmployeeScreen(
                        onEmployeeAdded: _addNewEmployee,
                      )),
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
                    TwoDimensionalEmployeeTable(
                      employees: _paginatedEmployees,
                      onViewEmployee: _viewEmployeeDetails,
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
            ),
          ],
        ),
      ),
    );
  }
}

// Nouveau composant de tableau 2D pour les employés
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

    // Si aucun employé n'est trouvé
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

    // Liste des en-têtes de colonnes
    final headerTitles = [
      localizations.getString('employeeName'),
      localizations.getString('employeeId'),
      localizations.getString('department'),
      localizations.getString('designation'),
      localizations.getString('type'),
      localizations.getString('action')
    ];

    return Expanded(
      child: TableView.builder(
        // Configuration principale du tableau
        rowCount: employees.length + 1, // +1 pour l'en-tête
        columnCount: headerTitles.length,

        // Configuration des dimensions des cellules
        cellBuilder: (context, vicinity) {
          return TableViewCell(
            child: _buildCellWidget(context, vicinity, headerTitles),
          );
        },

        // Largeur des colonnes
        columnBuilder: (index) {
          // Définir des largeurs spécifiques pour chaque colonne
          double width;
          switch (index) {
            case 0: // Nom de l'employé
              width = screenWidth * 0.25;
              break;
            case 1: // ID
              width = screenWidth * 0.15;
              break;
            case 2: // Département
              width = screenWidth * 0.15;
              break;
            case 3: // Désignation
              width = screenWidth * 0.18;
              break;
            case 4: // Type
              width = screenWidth * 0.1;
              break;
            case 5: // Action
              width = screenWidth * 0.1;
              break;
            default:
              width = screenWidth * 0.15;
          }
          return TableSpan(
            extent: FixedTableSpanExtent(width),
          );
        },

        // Hauteur des lignes
        rowBuilder: (index) {
          double height = index == 0
              ? screenHeight * 0.08 // Hauteur de l'en-tête
              : screenHeight * 0.09; // Hauteur des lignes de données
          return TableSpan(
            extent: FixedTableSpanExtent(height),
          );
        },

        // Configuration des cellules fixes
        pinnedRowCount: 1,    // Fixer la première ligne (en-tête)
        pinnedColumnCount: 1, // Fixer la première colonne (nom de l'employé)
      ),
    );
  }

  // Construction des cellules individuelles
  Widget _buildCellWidget(BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final localizations = AppLocalizations.of(context);

    // En-tête (première ligne)
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

    // Index pour accéder aux données d'employé
    final employeeIndex = row - 1;
    final employee = employees[employeeIndex];

    // Première colonne - Nom de l'employé avec avatar
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
              backgroundColor: employee['avatarColor'],
              child: Text(
                employee['avatar'],
                style: TextStyle(
                  color: employee['textColor'],
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                employee['name'],
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

    // Colonne d'action (dernière colonne)
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
                // Implement edit functionality
              } else if (result == 'delete') {
                // Implement delete functionality
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

    // Autres colonnes - contenu dynamique
    String cellText = '';
    switch (column) {
      case 1:
        cellText = employee['id'];
        break;
      case 2:
        cellText = employee['department'];
        break;
      case 3:
        cellText = employee['designation'];
        break;
      case 4:
        cellText = employee['type'];
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

// UserHeader existant (inchangé)
class UserHeader extends StatelessWidget {
  final bool isHeaderVisible;

  const UserHeader({
    super.key,
    required this.isHeaderVisible,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final avatarSize = screenHeight * 0.035;
    final localizations = AppLocalizations.of(context);
    final isDarkMode = AdaptiveColors.isDarkMode(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isHeaderVisible ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          boxShadow: isHeaderVisible
              ? []
              : [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
              spreadRadius: screenWidth * 0.001,
              blurRadius: screenWidth * 0.003,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: const Color(0xFFFFD6EC),
              child: Text(
                "RA",
                style: TextStyle(
                  color: const Color(0xFFD355A8),
                  fontWeight: FontWeight.bold,
                  fontSize: avatarSize * 0.7,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getString('robertAllen'),
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    localizations.getString('juniorFullStackDeveloper'),
                    style: TextStyle(
                      fontSize: screenHeight * 0.021,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.008),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E4620)
                      : const Color(0xFFE5F5E5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AdaptiveColors.primaryGreen,
                      size: screenHeight * 0.032,
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