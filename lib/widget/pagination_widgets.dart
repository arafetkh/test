import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/adaptive_colors.dart';

class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int filteredEmployeesCount;
  final int itemsPerPage;
  final Function(int) onPageChanged;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.filteredEmployeesCount,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // Calculate start and end of displayed items
    final start = filteredEmployeesCount == 0 ? 0 : ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage) > filteredEmployeesCount
        ? filteredEmployeesCount
        : (currentPage * itemsPerPage);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AdaptiveColors.borderColor(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${localizations.getString('showing')} $start ${localizations.getString('to')} $end ${localizations.getString('outOf')} $filteredEmployeesCount ${localizations.getString('records')}',
            style: TextStyle(
              color: AdaptiveColors.secondaryTextColor(context),
              fontSize: screenHeight * 0.02,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton(
                context,
                icon: Icons.chevron_left,
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              ..._buildPageNumbers(context),
              _buildPaginationButton(
                context,
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    List<Widget> pageNumbers = [];
    List<int> pagesToShow = [];

    // Logic for which page numbers to show
    if (totalPages <= 5) {
      // Show all pages if there are 5 or fewer
      pagesToShow = List.generate(totalPages, (i) => i + 1);
    } else {
      // Always include first page
      pagesToShow.add(1);

      // Include current page and surrounding pages
      for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i > 1 && i < totalPages) {
          pagesToShow.add(i);
        }
      }

      // Always include last page
      pagesToShow.add(totalPages);

      // Add ellipses as needed
      pagesToShow = pagesToShow.toSet().toList()..sort();

      // Check if we need to add ellipsis after first page
      if (pagesToShow[0] + 1 != pagesToShow[1]) {
        pagesToShow.insert(1, -1); // -1 represents ellipsis
      }

      // Check if we need to add ellipsis before last page
      if (pagesToShow[pagesToShow.length - 2] + 1 != pagesToShow[pagesToShow.length - 1]) {
        pagesToShow.insert(pagesToShow.length - 1, -1); // -1 represents ellipsis
      }
    }

    // Create the widgets
    for (int i = 0; i < pagesToShow.length; i++) {
      if (pagesToShow[i] == -1) {
        // Ellipsis
        pageNumbers.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
            child: Text(
              localizations.getString('ellipsis'),
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
                fontSize: screenHeight * 0.024,
              ),
            ),
          ),
        );
      } else {
        // Page number
        pageNumbers.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
            child: InkWell(
              onTap: () => onPageChanged(pagesToShow[i]),
              child: Container(
                width: screenHeight * 0.045,
                height: screenHeight * 0.045,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: currentPage == pagesToShow[i]
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.004),
                  border: Border.all(
                    color: currentPage == pagesToShow[i]
                        ? const Color(0xFF2E7D32)
                        : AdaptiveColors.borderColor(context),
                  ),
                ),
                child: Text(
                  '${pagesToShow[i]}',
                  style: TextStyle(
                    color: currentPage == pagesToShow[i]
                        ? Colors.white
                        : AdaptiveColors.primaryTextColor(context),
                    fontWeight: currentPage == pagesToShow[i] ? FontWeight.bold : FontWeight.normal,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return pageNumbers;
  }

  Widget _buildPaginationButton(BuildContext context, {required IconData icon, required VoidCallback? onPressed}) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: screenHeight * 0.045,
          height: screenHeight * 0.045,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(screenWidth * 0.004),
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            size: screenHeight * 0.022,
            color: onPressed == null
                ? AdaptiveColors.tertiaryTextColor(context)
                : AdaptiveColors.primaryTextColor(context),
          ),
        ),
      ),
    );
  }
}