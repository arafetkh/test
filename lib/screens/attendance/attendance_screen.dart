import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/landscape_user_profile_header.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/search_and_filter_bar.dart';
import 'package:in_out/widget/pagination_widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../../data/attendance_data.dart';
import '../../localization/app_localizations.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 2;
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderVisible = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  String _selectedFilter = 'Month';

  List<Map<String, dynamic>> get _filteredAttendances {
    List<Map<String, dynamic>> filtered = attendances;
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
                  title: Text(
                      AppLocalizations.of(context).getString('filterByMonth')),
                  onTap: () => _handleFilterChange('Month'),
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context).getString('filterByYear')),
                  onTap: () => _handleFilterChange('Year'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).getString('close')),
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
                    TwoDimensionalAttendanceTable(
                      attendances: _paginatedAttendances,
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
    ) ;
  }
}

class TwoDimensionalAttendanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> attendances;

  const TwoDimensionalAttendanceTable({
    super.key,
    required this.attendances,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // Si aucune présence n'est trouvée
    if (attendances.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.5,
        child: Center(
          child: Text(
            localizations.getString('noAttendanceRecords'),
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
      localizations.getString('designation'),
      localizations.getString('type'),
      localizations.getString('checkInTime'),
      localizations.getString('status'),
      localizations.getString('actions')
    ];

    return Expanded(
      child: TableView.builder(
        // Configuration principale du tableau
        rowCount: attendances.length + 1, // +1 pour l'en-tête
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
            case 1: // Désignation
              width = screenWidth * 0.20;
              break;
            case 2: // Type
              width = screenWidth * 0.15;
              break;
            case 3: // Heure d'arrivée
              width = screenWidth * 0.15;
              break;
            case 4: // Statut
              width = screenWidth * 0.15;
              break;
            case 5: // Action
              width = screenWidth * 0.10;
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

    // Index pour accéder aux données d'attendance
    final attendanceIndex = row - 1;
    final attendance = attendances[attendanceIndex];

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
      );
    }

    // Colonne de statut
    if (column == 4) {
      String status = attendance['status'];
      Color statusColor = status == 'On Time' ? Colors.green : Colors.red;

      // Traduire le statut
      String translatedStatus = status;
      if (status == "On Time") {
        translatedStatus = localizations.getString("onTime");
      } else if (status == "Late") {
        translatedStatus = localizations.getString("late");
      }

      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
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
          child: IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AdaptiveColors.secondaryTextColor(context),
              size: screenHeight * 0.03,
            ),
            onPressed: () {
              // Action pour éditer l'enregistrement de présence
            },
          ),
        ),
      );
    }

    // Autres colonnes - contenu dynamique
    String cellText = '';
    switch (column) {
      case 1:
        cellText = attendance['designation'];
        break;
      case 2:
        cellText = attendance['type'];
        break;
      case 3:
        cellText = attendance['checkInTime'];
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
          right: BorderSide(color: borderColor, width: 1),
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
}