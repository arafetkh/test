import 'package:flutter/material.dart';
import 'CustomSideNavigationBar.dart';
import 'bottom_navigation_bar.dart';

class ResponsiveNavigationScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const ResponsiveNavigationScaffold({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            CustomSideNavigationBar(
              selectedIndex: selectedIndex,
              onItemTapped: onItemTapped,
            ),
            Expanded(child: body),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar ?? CustomBottomNavigationBar(
          selectedIndex: selectedIndex,
          onItemTapped: onItemTapped,
        ),
      );
    }
  }
}