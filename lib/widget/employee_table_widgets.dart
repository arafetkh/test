import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class EmployeeTableHeader extends StatelessWidget {
  final ScrollController horizontalScrollController;

  const EmployeeTableHeader({
    super.key,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.008),
          topRight: Radius.circular(screenWidth * 0.008),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: screenWidth * 0.001,
            blurRadius: screenWidth * 0.003,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fixed name column header
          SizedBox(
            width: screenWidth * 0.25,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.03,
              ),
              child: Text(
                localizations.getString('employeeName'),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: screenHeight * 0.025,
                ),
              ),
            ),
          ),
          // Scrollable headers
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: Row(
                children: [
                  _buildHeaderCell(context, localizations.getString('employeeId'), 0.15),
                  _buildHeaderCell(context, localizations.getString('department'), 0.15),
                  _buildHeaderCell(context, localizations.getString('designation'), 0.18),
                  _buildHeaderCell(context, localizations.getString('type'), 0.1),
                  _buildHeaderCell(context, localizations.getString('action'), 0.1),
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
            color: Colors.black87,
            fontSize: screenHeight * 0.025,
          ),
        ),
      ),
    );
  }
}

class EmployeeTableView extends StatelessWidget {

  final List<Map<String, dynamic>> employees;
  final ScrollController mainScrollController;
  final ScrollController horizontalScrollController;

  const EmployeeTableView({
    super.key,
    required this.employees,
    required this.mainScrollController,
    required this.horizontalScrollController,
  });


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: mainScrollController,
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final rowHeight = screenHeight * 0.09;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.25,
              height: rowHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
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
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: horizontalScrollController,
                child: Container(
                  height: rowHeight,
                  width: screenWidth * 0.68,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildDataCell(context, employee['id'], 0.15),
                      _buildDataCell(context, employee['department'], 0.15),
                      _buildDataCell(context, employee['designation'], 0.18),
                      _buildDataCell(context, employee['type'], 0.1),
                      SizedBox(
                        width: screenWidth * 0.1,
                        child: Center(
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                size: screenHeight * 0.035,
                                color: Colors.grey.shade700),
                            padding: EdgeInsets.zero,
                            onSelected: (String result) {},
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              _buildPopupItem(context, 'view', Icons.visibility_outlined, 'view'),
                              _buildPopupItem(context, 'edit', Icons.edit_outlined, 'edit'),
                              _buildPopupItem(context, 'delete', Icons.delete_outline, 'delete', isDelete: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
            color: Colors.black87,
            fontSize: screenHeight * 0.022,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(BuildContext context, String value, IconData icon, String textKey, {bool isDelete = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: screenHeight * 0.035,
            color: isDelete ? Colors.red : null,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.008),
          Text(
            localizations.getString(textKey),
            style: TextStyle(
              color: isDelete ? Colors.red : null,
              fontSize: screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }
}

class PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const PaginationButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: screenHeight * 0.056,
          height: screenHeight * 0.056,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(screenWidth * 0.004),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            size: screenHeight * 0.032,
            color: onPressed == null ? Colors.grey.shade400 : Colors.black87,
          ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isHeaderVisible ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          boxShadow: isHeaderVisible
              ? []
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    localizations.getString('juniorFullStackDeveloper'),
                    style: TextStyle(
                      fontSize: screenHeight * 0.021,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.008),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F5E5),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: const Color(0xFF2E7D32),
                size: screenHeight * 0.032,
              ),
            ),
          ],
        ),
      ),
    );
  }
}