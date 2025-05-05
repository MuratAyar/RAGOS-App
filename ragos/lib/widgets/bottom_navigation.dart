// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';

/// A reusable bottom navigation bar with optional selection.
/// If [currentIndex] is null, no tab is highlighted.
class AppBottomNavigation extends StatelessWidget {
  /// Currently selected tab index (0–3), or null for no selection.
  final int? currentIndex;

  const AppBottomNavigation({
    Key? key,
    this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = currentIndex != null;
    final int idx = currentIndex ?? 0;

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.black,
        shadowColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        elevation: 0,
        currentIndex: idx,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: hasSelection
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (index) {
          // no-op if tapping the already selected tab
          if (hasSelection && index == idx) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/account');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/config');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/report');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
