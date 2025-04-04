import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'NotificationsScreen.dart';
import 'localization/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<String> filterOptions = ['Day', 'Month', 'Year'];
  String selectedFilter = 'Month';
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

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
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  Widget _buildHeader(AppLocalizations localizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.06;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.04,
        horizontal: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        boxShadow: _isHeaderVisible
            ? []
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
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
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Robert Allen",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  localizations.getString('juniorFullStackDeveloper'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
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
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F5E5),
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: const Color(0xFF2E7D32),
            size: screenWidth * 0.05,
          ),
        ),
      ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    final padding = screenWidth * 0.04;

    filterOptions = [
      localizations.getString('day'),
      localizations.getString('month'),
      localizations.getString('year')
    ];
    if (!filterOptions.contains(selectedFilter)) {
      selectedFilter = localizations.getString('month');
    }

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        NavigationService.navigateToScreen(context, index);
      },
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Content
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(padding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Metrics Grid
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: screenWidth * 0.04,
                          mainAxisSpacing: screenWidth * 0.04,
                          shrinkWrap: true,
                          childAspectRatio: 2.2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildMetricCard(
                              Icons.people_outline,
                              localizations.getString('totalEmployee'),
                              "560",
                              screenWidth,
                            ),
                            _buildMetricCard(
                              Icons.calendar_today_outlined,
                              localizations.getString('todayAttendance'),
                              "470",
                              screenWidth,
                            ),
                            _buildMetricCard(
                              Icons.access_time_outlined,
                              localizations.getString('pendingTimeOff'),
                              "5",
                              screenWidth,
                            ),
                            _buildMetricCard(
                              Icons.business_outlined,
                              localizations.getString('totalDepartments'),
                              "20",
                              screenWidth,
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Attendance Overview Card
                        Container(
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.06),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localizations.getString('attendanceOverview'),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenWidth * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedFilter,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: screenWidth * 0.045,
                                      ),
                                      iconEnabledColor: Colors.grey.shade700,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      underline: Container(height: 0),
                                      isDense: true,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedFilter = newValue!;
                                        });
                                      },
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
                              SizedBox(height: screenHeight * 0.03),
                              SizedBox(
                                height: screenHeight * 0.2,
                                child: _buildAttendanceChart(screenWidth),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Recent Events
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.getString('recentEvents'),
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Text(
                                    localizations.getString('viewAll'),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: screenWidth * 0.03,
                                    color: Colors.grey.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        _buildEventItem(
                          localizations.getString('updatedServerLogs'),
                          localizations.getString('justNow'),
                          screenWidth,
                        ),
                        _buildEventItem(
                          localizations.getString('sendMailToHRAndAdmin'),
                          "2 ${localizations.getString('minAgo')}",
                          screenWidth,
                        ),
                        _buildEventItem(
                          localizations.getString('backupFilesEOD'),
                          "14:00",
                          screenWidth,
                        ),
                        _buildEventItem(
                          localizations.getString('sendMailToHRAndAdmin'),
                          "17:10",
                          screenWidth,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(double screenWidth) {
    final textSize = screenWidth * 0.025;
    final barWidth = screenWidth * 0.035;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => getBottomTitles(value, meta, textSize),
              reservedSize: screenWidth * 0.075,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => getLeftTitles(value, meta, textSize),
              reservedSize: screenWidth * 0.075,
              interval: 20,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            // Show line at y=0 (removed the condition that was hiding it)
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 0.8,
            );
          },
          checkToShowVerticalLine: (value) => false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: getBarGroups(barWidth),
        maxY: 100,
        minY: 0,
      ),
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta, double fontSize) {
    if (value == 0 || value == 20 || value == 40 || value == 60 || value == 80 || value == 100) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8, // Add some space between text and axis
        child: Text(
          '${value.toInt()}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: fontSize,
          ),
        ),
      );
    }
    return Container();
  }

  List<BarChartGroupData> getBarGroups(double barWidth) {
    final Map<String, List<Map<String, dynamic>>> filterData = {
      AppLocalizations.of(context).getString('day'): [
        {'name': 'Mon', 'present': 90, 'absent': 10},
        {'name': 'Tue', 'present': 70, 'absent': 30},
        {'name': 'Wed', 'present': 60, 'absent': 40},
        {'name': 'Thu', 'present': 80, 'absent': 20},
        {'name': 'Fri', 'present': 85, 'absent': 15},
        {'name': 'Sat', 'present': 60, 'absent': 40},
        {'name': 'Sun', 'present': 75, 'absent': 25},
      ],
      AppLocalizations.of(context).getString('month'): [
        {'name': 'Jan', 'present': 58, 'absent': 42},
        {'name': 'Feb', 'present': 80, 'absent': 20},
        {'name': 'Mar', 'present': 95, 'absent': 5},
        {'name': 'Apr', 'present': 70, 'absent': 30},
        {'name': 'May', 'present': 60, 'absent': 40},
        {'name': 'Jun', 'present': 85, 'absent': 15},
        {'name': 'Jul', 'present': 75, 'absent': 25},
      ],
      AppLocalizations.of(context).getString('year'): [
        {'name': '2019', 'present': 50, 'absent': 50},
        {'name': '2020', 'present': 60, 'absent': 40},
        {'name': '2021', 'present': 65, 'absent': 35},
        {'name': '2022', 'present': 75, 'absent': 25},
        {'name': '2023', 'present': 85, 'absent': 15},
        {'name': '2024', 'present': 80, 'absent': 20},
        {'name': '2025', 'present': 70, 'absent': 30},
      ],
    };

    final List<Map<String, dynamic>> data = filterData[selectedFilter]!;
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: 100, // Set the total height to 100%
            width: barWidth,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            rodStackItems: [
              // Present (green) from bottom
              BarChartRodStackItem(
                  0,
                  item['present'].toDouble(),
                  const Color(0xFF388E3C)
              ),
              // Absent (red) on top
              BarChartRodStackItem(
                  item['present'].toDouble(),
                  100, // Always go to 100
                  const Color(0xFFF44336)
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  Widget getBottomTitles(double value, TitleMeta meta, double fontSize) {
    final localizations = AppLocalizations.of(context);

    // Use localized keys instead of hardcoded English strings
    Map<String, List<String>> filterTitles = {
      localizations.getString('day'): ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      localizations.getString('month'): ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
      localizations.getString('year'): ['2019', '2020', '2021', '2022', '2023', '2024', '2025'],
    };

    final List<String> titles = filterTitles[selectedFilter]!;
    // Add null check to prevent errors
    if (value.toInt() >= titles.length || value.toInt() < 0) {
      return const SizedBox.shrink();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        titles[value.toInt()],
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String value, double screenWidth) {
    // Reducing sizes slightly to prevent overflow
    final iconSize = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.028;
    final valueFontSize = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,  // Added explicit maxLines
                ),
                SizedBox(height: screenWidth * 0.008),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String time, double screenWidth) {
    final localizations = AppLocalizations.of(context);
    final bool isRecent = time == localizations.getString('justNow') ||
        time.contains(localizations.getString('minAgo'));

    final titleFontSize = screenWidth * 0.035;
    final timeFontSize = screenWidth * 0.03;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: titleFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: isRecent ? const Color(0xFF2E7D32) : Colors.grey.shade600,
              fontSize: timeFontSize,
              fontWeight: isRecent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}