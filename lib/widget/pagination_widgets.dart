import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

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
    final start = filteredEmployeesCount == 0 ? 0 : ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage) > filteredEmployeesCount
        ? filteredEmployeesCount
        : (currentPage * itemsPerPage);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018, // Reduced padding
        horizontal: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${localizations.getString('showing')} $start ${localizations.getString('to')} $end ${localizations.getString('outOf')} $filteredEmployeesCount ${localizations.getString('records')}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: screenHeight * 0.02, // Slightly smaller text
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

    // Determine which page numbers to show
    List<int> pagesToShow = [];

    if (totalPages <= 5) {
      // If 5 or fewer pages, show all
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
                color: Colors.grey.shade600,
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
                  width: screenHeight * 0.045, // Reduced width
                  height: screenHeight * 0.045, // Reduced height
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: currentPage == pagesToShow[i]
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(screenWidth * 0.004),
                    border: Border.all(
                      color: currentPage == pagesToShow[i]
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${pagesToShow[i]}',
                    style: TextStyle(
                      color: currentPage == pagesToShow[i] ? Colors.white : Colors.black87,
                      fontWeight: currentPage == pagesToShow[i] ? FontWeight.bold : FontWeight.normal,
                      fontSize: screenHeight * 0.02, // Smaller text
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
         width: screenHeight * 0.045, // Reduced width
         height: screenHeight * 0.045, // Reduced height
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
           size: screenHeight * 0.022, // Smaller icon
           color: onPressed == null ? Colors.grey.shade400 : Colors.black87,
         ),
       ),
     ),
   );
 }

}