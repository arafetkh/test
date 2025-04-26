import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_out/EmployeeProfileScreen.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:in_out/auth/global.dart';

import 'AddEmployeeScreen.dart';
import 'EditEmployeeScreen.dart';
import 'NotificationsScreen.dart';
import 'localization/app_localizations.dart';
import 'models/employee_model.dart';
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
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  int _itemsPerPage = 10;
  String _searchQuery = '';

  // Variables pour le filtrage côté client
  List<Map<String, dynamic>> _allEmployees = []; // Stocke toutes les données
  List<Map<String, dynamic>> _displayedEmployees = []; // Données après filtrage et pagination
  bool _isLoading = true;
  String _errorMessage = '';
  bool _dataLoaded = false; // Pour savoir si les données initiales ont été chargées

  // Selected filters
  Set<String> _selectedDepartments = {};
  Set<String> _selectedWorkTypes = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchQuery);
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 0;
        });
        _applyFilters();
      }
    });

    // Maintenir l'orientation paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _mainScrollController.addListener(_scrollListener);

    // Charger toutes les données une seule fois
    _fetchAllEmployees();
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

  Future<void> _fetchAllEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String url = "${Global.baseUrl}/secure/users-management?size=10000";

      print("Fetching all employees: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: Global.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> employees = [];
        if (data.containsKey('content') && data['content'] is List) {
          for (var emp in data['content']) {
            Map<String, dynamic> employee = {
              'id': emp['id']?.toString() ?? '',
              'name': "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}",
              'avatar': _getInitials("${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}"),
              'avatarColor': Colors.blue.shade100,
              'textColor': Colors.blue.shade800,
              'department': emp['department'] ?? 'Unknown',
              'designation': emp['designation'] ?? 'Unknown',
              'type': emp['type'] ?? 'Unknown',
            };

            employees.add(employee);
          }
        }

        setState(() {
          _allEmployees = employees;
          _dataLoaded = true;
          _isLoading = false;
          _applyFilters();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load employees: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (!_dataLoaded) return;
    List<Map<String, dynamic>> filtered = List.from(_allEmployees);

    // Filtre de recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) =>
      emp['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp['department'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp['designation'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtres de département
    if (_selectedDepartments.isNotEmpty) {
      filtered = filtered.where((emp) =>
          _selectedDepartments.contains(emp['department'])).toList();
    }

    // Filtres de type
    if (_selectedWorkTypes.isNotEmpty) {
      filtered = filtered.where((emp) =>
          _selectedWorkTypes.contains(emp['type'])).toList();
    }

    // Appliquer la pagination
    _totalElements = filtered.length;
    _totalPages = (_totalElements / _itemsPerPage).ceil();

    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > filtered.length) endIndex = filtered.length;

    if (startIndex >= filtered.length) {
      // Si la page actuelle est vide, revenir à la première page
      _currentPage = 0;
      startIndex = 0;
      endIndex = startIndex + _itemsPerPage > filtered.length ? filtered.length : startIndex + _itemsPerPage;
    }

    setState(() {
      _displayedEmployees = filtered.sublist(startIndex, endIndex);
    });
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
    _fetchAllEmployees();
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
    );
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

        // Extraire les départements uniques des données
        Set<String> availableDepartments = _allEmployees
            .map((emp) => emp['department'].toString())
            .where((dept) => dept != 'Unknown')
            .toSet();

        // Option de fallback si aucun département n'est trouvé
        if (availableDepartments.isEmpty) {
          availableDepartments = {
            'Design',
            'HR',
            'Sales',
            'Business Analyst',
            'Project Manager',
            'Development',
            'IT',
            'Finance',
            'Marketing'
          };
        }

        // Compétences techniques - pour l'exemple
        final techSkills = ['Java', 'Python', 'React JS', 'Account', 'Node JS'];

        // Extraire les types d'emploi uniques des données
        Set<String> availableWorkTypes = _allEmployees
            .map((emp) => emp['type'].toString())
            .where((type) => type != 'Unknown')
            .toSet();

        // Option de fallback si aucun type n'est trouvé
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
                  // Titre du filtre
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
                              // Colonne gauche - Départements
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: availableDepartments.map((dept) => CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    activeColor: const Color(0xFF377D25),
                                    title: Text(
                                      dept,
                                      style: TextStyle(
                                        color: AdaptiveColors.primaryTextColor(context),
                                      ),
                                    ),
                                    value: selectedDepartments.contains(dept),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedDepartments.add(dept);
                                        } else {
                                          selectedDepartments.remove(dept);
                                        }
                                      });
                                    },
                                  )).toList(),
                                ),
                              ),

                              // Colonne droite - Compétences techniques
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: techSkills.map((skill) => CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    activeColor: const Color(0xFF377D25),
                                    title: Text(
                                      skill,
                                      style: TextStyle(
                                        color: AdaptiveColors.primaryTextColor(context),
                                      ),
                                    ),
                                    value: selectedDepartments.contains(skill),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedDepartments.add(skill);
                                        } else {
                                          selectedDepartments.remove(skill);
                                        }
                                      });
                                    },
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Section des types
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
                                      vertical: screenHeight * 0.01
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF377D25),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
          _currentPage = 0;
        });
        _applyFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    AppLocalizations.of(context);

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
                      )
                  ),
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
                      employees: _displayedEmployees,
                      onViewEmployee: _viewEmployeeDetails,
                    ),
                    PaginationFooter(
                      currentPage: _currentPage + 1,
                      totalPages: _totalPages,
                      filteredEmployeesCount: _totalElements,
                      itemsPerPage: _itemsPerPage,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page - 1;
                        });
                        _applyFilters();
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

  // Construire les cellules individuelles du tableau
  Widget _buildCellWidget(BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final localizations = AppLocalizations.of(context);

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

    // Lignes de données - Obtenir les données de l'employé
    final employeeIndex = row - 1;
    final employee = employees[employeeIndex];

    // Colonne du nom de l'employé avec avatar
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
      // Continuation de la méthode _buildCellWidget dans TwoDimensionalEmployeeTable
      // ...
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

    // Colonne d'action
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
            // Find this code in TwoDimensionalEmployeeTable
// Update the PopupMenuButton's onSelected handler
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
                              content: Text(AppLocalizations.of(context).getString('employeeUpdatedSuccessfully')),
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
                      title: Text(AppLocalizations.of(context).getString('confirmDelete')),
                      content: Text(AppLocalizations.of(context).getString('areYouSureDelete')),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).getString('cancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).getString('delete')),
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

    // Autres colonnes - contenu dynamique
    String cellText = '';
    switch (column) {
      case 1:
        cellText = employee['id'] ?? '';
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