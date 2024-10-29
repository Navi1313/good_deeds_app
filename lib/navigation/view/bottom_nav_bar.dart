import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigation Bar :->
class BottomNavbar extends StatelessWidget {
  // ignore: public_member_api_docs
  const BottomNavbar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final navigationBarItems = mainNavigationBarItems(
      homeLabel: 'homeLabel',
      searchLabel: 'searchLabel',
      createMediaLabel: 'createMediaLabel',
      reelsLabel: 'reelsLabel',
      userProfileLabel: 'userProfileLabel',
      userProfileAvatar: const Icon(Icons.person),
    );
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        if (index == 2) {
          
        } else {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        }
      },
      iconSize: 28,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: navigationBarItems
          .map(
            (e) => BottomNavigationBarItem(
              icon: e.child ?? Icon(e.icon),
              tooltip: e.tooltip,
              label: e.label,
            ),
          )
          .toList(),
    );
  }
}
