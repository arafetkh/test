import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:in_out/widget/translate_text.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF00F60D),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Iconify(MaterialSymbols.home, size: screenWidth * 0.06),
          label: 'home',
          tooltip: 'home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work, size: screenWidth * 0.06),
          label: 'calendar',
          tooltip: 'calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined, size: screenWidth * 0.06),
          label: 'add',
          tooltip: 'add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined, size: screenWidth * 0.06),
          label: 'messages',
          tooltip: 'messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: screenWidth * 0.06),
          label: 'settings',
          tooltip: 'settings',
        ),
      ],
    );
  }
}