import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onAddNewEmployee;
  final Function(BuildContext) onFilterTap; // Changed to pass BuildContext

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddNewEmployee,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: screenHeight * 0.065, // Reduced height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: localizations.getString('search'),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: screenHeight * 0.028),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018, // Center text vertically
                  ),
                  isDense: true, // Makes the field more compact
                ),
                style: TextStyle(
                  fontSize: screenHeight * 0.022, // Consistent font size
                ),
                textAlignVertical: TextAlignVertical.center, // Center text vertically
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.015),
          ElevatedButton.icon(
            onPressed: onAddNewEmployee,
            icon: Icon(Icons.add, color: Colors.white, size: screenHeight * 0.025),
            label: Text(
                localizations.getString('addNewEmployee'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.022,
                )
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.018, // Reduced height
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
              ),
              minimumSize: Size(0, screenHeight * 0.065), // Match search field height
            ),
          ),
          SizedBox(width: screenWidth * 0.015),
          // Changed from DropdownButton to a regular Container with InkWell
          InkWell(
            onTap: () => onFilterTap(context), // Pass the context to the onFilterTap function
            child: Container(
              height: screenHeight * 0.065, // Match search field height
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: screenHeight * 0.025),
                  SizedBox(width: screenWidth * 0.008),
                  Text(
                    localizations.getString('filter'),
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}