import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/widget/AddHolidayScreen.dart';
import 'package:intl/intl.dart';
import '../models/holiday_model.dart';
import '../services/holidayservice.dart';
import '../services/NavigationService.dart';
import '../theme/adaptive_colors.dart';
import '../widget/ResponsiveNavigationScaffold.dart';
import '../widget/UserProfileHeader.dart';
import '../widget/bottom_navigation_bar.dart';
import '../localization/app_localizations.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({Key? key}) : super(key: key);

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 5; // Index for holidays in the navigation
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

  final HolidayService _holidayService = HolidayService();
  List<Holiday> _holidays = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  TabController? _tabController;
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);

    // Set preferred orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize holiday service
    _initializeHolidays();
  }

  Future<void> _initializeHolidays() async {
    await _holidayService.initialize();
    _updateHolidaysList();

    // Add listener for updates
    _holidayService.addListener(_updateHolidaysList);
  }

  void _updateHolidaysList() {
    setState(() {
      _holidays = _holidayService.getHolidaysForYear(_selectedYear);
      _isLoading = false;
    });
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

  void _addNewHoliday(Map<String, dynamic> holidayData) async {
    await _holidayService.addHoliday(holidayData);

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).getString('holidayAddedSuccessfully'),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteHoliday(String id) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('confirmDelete')),
        content: Text(AppLocalizations.of(context).getString('deleteHolidayConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).getString('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _holidayService.deleteHoliday(id);

              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).getString('holidayDeletedSuccessfully'),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context).getString('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  List<Holiday> get _upcomingHolidays {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        _selectedYear,
        holiday.date.month,
        holiday.date.day,
      );
      return holidayDate.isAfter(now) ||
          holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day;
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(_selectedYear, a.date.month, a.date.day);
        final bDate = DateTime(_selectedYear, b.date.month, b.date.day);
        return aDate.compareTo(bDate);
      });
  }

  List<Holiday> get _pastHolidays {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        _selectedYear,
        holiday.date.month,
        holiday.date.day,
      );
      return holidayDate.isBefore(now) &&
          !(holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day);
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(_selectedYear, a.date.month, a.date.day);
        final bDate = DateTime(_selectedYear, b.date.month, b.date.day);
        return bDate.compareTo(aDate); // Reverse order for past holidays
      });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController?.dispose();
    _holidayService.removeListener(_updateHolidaysList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    _tabs = [
      localizations.getString('upcoming'),
      localizations.getString('pastHolidays')
    ];
    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.getString('holidays'),
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                      Text(
                        "${_selectedYear.toString()} ${localizations.getString('holidaysList')}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: AdaptiveColors.secondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddHolidayScreen(
                            onHolidayAdded: _addNewHoliday,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, size: screenWidth * 0.04),
                    label: Text(
                      localizations.getString('addHoliday'),
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                  // Year selector
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      color: AdaptiveColors.cardColor(context),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, size: screenWidth * 0.04),
                          onPressed: () {
                            setState(() {
                              _selectedYear--;
                              _updateHolidaysList();
                            });
                          },
                        ),
                        Text(
                          _selectedYear.toString(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04),
                          onPressed: () {
                            setState(() {
                              _selectedYear++;
                              _updateHolidaysList();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AdaptiveColors.cardColor(context),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.02),
                        topRight: Radius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                      labelColor: Colors.green.shade800,
                      unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
                      indicatorColor: Colors.green.shade800,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.04,
                    0,
                    screenWidth * 0.04,
                    screenWidth * 0.04
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming holidays tab
                    _buildHolidaysList(_upcomingHolidays),

                    // Past holidays tab
                    _buildHolidaysList(_pastHolidays),
                  ],
                ),
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

  Widget _buildHolidaysList(List<Holiday> holidays) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    if (holidays.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).getString('noHolidays'),
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidays[index];
        final holidayDate = DateTime(
          _selectedYear,
          holiday.date.month,
          holiday.date.day,
        );
        final isToday = DateTime.now().year == holidayDate.year &&
            DateTime.now().month == holidayDate.month &&
            DateTime.now().day == holidayDate.day;

        return _buildHolidayCard(holiday, isToday);
      },
    );
  }

  Widget _buildHolidayCard(Holiday holiday, bool isToday) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final holidayDate = DateTime(
      _selectedYear,
      holiday.date.month,
      holiday.date.day,
    );

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: isToday
            ? Border.all(color: Colors.green.shade800, width: 2)
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(screenWidth * 0.03),
        title: Row(
          children: [
            Text(
              holiday.name,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            if (isToday) ...[
              SizedBox(width: screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade800.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                ),
                child: Text(
                  AppLocalizations.of(context).getString('today'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (holiday.description.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.01),
              Text(
                holiday.description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: AdaptiveColors.secondaryTextColor(context),
                ),
              ),
            ],
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: holiday.type == 'Public'
                        ? Colors.blue.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(screenWidth * 0.01),
                  ),
                  child: Text(
                    holiday.type,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: holiday.type == 'Public'
                          ? Colors.blue.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                if (holiday.isRecurringYearly) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: Text(
                      AppLocalizations.of(context).getString('recurring'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: screenWidth * 0.04,
                  color: AdaptiveColors.secondaryTextColor(context),
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  DateFormat('MMMM d, yyyy').format(holidayDate),
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: screenWidth * 0.055,
          ),
          onPressed: () => _deleteHoliday(holiday.id),
        ),
      ),
    );
  }
}