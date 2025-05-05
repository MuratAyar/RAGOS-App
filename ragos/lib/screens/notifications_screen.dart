import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/notification_navigation.dart';
import 'home_screen.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String? filterType;

  const NotificationsScreen({
    Key? key,
    this.filterType,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<Map<String, dynamic>> _dummyNotifications = [
    {
      'type': 'Normal',
      'title': 'Reminder',
      'content': 'Don\'t forget to complete your daily tasks.',
      'color': Colors.yellow,
    },
    {
      'type': 'Positive',
      'title': 'Great News!',
      'content': 'Your system has been updated successfully.',
      'color': Colors.green,
    },
    {
      'type': 'Negative',
      'title': 'Warning',
      'content': 'Your storage is almost full.',
      'color': Colors.red,
    },
    {
      'type': 'Normal',
      'title': 'System Update',
      'content': 'New features available in the latest version.',
      'color': Colors.yellow,
    },
    {
      'type': 'Positive',
      'title': 'Completed',
      'content': 'Your task has been successfully processed.',
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (widget.filterType == null) return _dummyNotifications;
    return _dummyNotifications
        .where((notif) => notif['type'].toLowerCase() == widget.filterType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.filterType != null
                        ? '${widget.filterType!.toUpperCase()}'
                        : 'All Notifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Spacer between title and list
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notif = _filteredNotifications[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _notificationCard(notif),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          NotificationNavigation(
            unreadCount: _dummyNotifications.length,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
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
      bottomNavigationBar: AppBottomNavigation(currentIndex: null),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(notification: item),
          ),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['content'],
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Container(
                width: 8,
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
