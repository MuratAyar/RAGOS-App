// lib/screens/notification_categories_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/notification_navigation.dart';
import '../widgets/analyse_indicator.dart';
import 'notifications_screen.dart';

class NotificationCategoriesScreen extends StatefulWidget {
  final Map<String, int> notificationCounts;

  const NotificationCategoriesScreen({
    super.key,
    required this.notificationCounts,
  });

  @override
  State<NotificationCategoriesScreen> createState() =>
      _NotificationCategoriesScreenState();
}

class _NotificationCategoriesScreenState
    extends State<NotificationCategoriesScreen> {
  int? _selectedIndex; // nothing selected in bottom-nav for this screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ----------------------------- MAIN CONTENT
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                const SizedBox(height: 100),
                _buildCategoryCard(
                  context: context,
                  title: 'Positive',
                  count: widget.notificationCounts['positive'] ?? 0,
                  borderColor: const Color(0xFF92C751), // green
                ),
                const SizedBox(height: 20),
                _buildCategoryCard(
                  context: context,
                  title: 'Normal',
                  count: widget.notificationCounts['normal'] ?? 0,
                  borderColor: const Color(0xFFFCC120), // yellow
                ),
                const SizedBox(height: 20),
                _buildCategoryCard(
                  context: context,
                  title: 'Negative',
                  count: widget.notificationCounts['negative'] ?? 0,
                  borderColor: const Color(0xFFE1011B), // red
                ),
                const SizedBox(height: 60),
                const AnalyseIndicator(height: 200),
              ],
            ),
          ),

          /// ----------------------------- HANGING BELL
          NotificationNavigation(
            unreadCount: 10, // or pass a value you keep globally
              onTap:  () {},          // ← add an empty (or real) handler
          ),

          /// ----------------------------- BACK ARROW
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }

  /// ------------------------------------------------ category card
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required int count,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              NotificationsScreen(filterType: title.toLowerCase()),
        ),
      ),
      child: Row(
        children: [
          /// ---- label bar -------------------------------------------------
          Expanded(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(40),
                  right: const Radius.circular(40),
                ),
                border: Border.all(color: borderColor, width: 2),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// ---- unread badge ---------------------------------------------
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF3B3B3B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
