import 'package:flutter/material.dart';
import 'package:ragos/widgets/bottom_navigation.dart';
import 'package:ragos/widgets/notification_navigation.dart';
import 'package:ragos/screens/home_screen.dart';
import 'package:ragos/screens/notification_detail_screen.dart';

import '../core/services/notification_service.dart';
import '../models/analysis_notification.dart';

class NotificationsScreen extends StatelessWidget {
  final String? filterType;

  const NotificationsScreen({super.key, this.filterType});

  Color _notifColor(String t) => switch (t) {
        'positive' => const Color(0xFF92C751),
        'negative' => const Color(0xFFE1011B),
        _          => const Color(0xFFFCC120),
      };

  @override
  Widget build(BuildContext context) {
    final notifSvc = NotificationService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ----------------------------- MAIN CONTENT
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    filterType != null
                        ? filterType!.toUpperCase()
                        : 'ALL NOTIFICATIONS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<List<AnalysisNotification>>(
                    stream: notifSvc.streamNotifications(todayOnly: true),        // 🔴 canlı veri
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? [];
                      final list = filterType == null
                          ? all
                          : all
                              .where((n) => n.type == filterType)
                              .toList();

                      if (list.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationDetailScreen(notification: item),
                                ),
                              ),
                              child: _notificationCard(item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          /// ----------------------------- Notification Bell
          NotificationNavigation(
            unreadCount: 0,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),

          /// ----------------------------- BACK BUTTON
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

  Widget _notificationCard(AnalysisNotification n) {
    final timeStr =
        "${n.ts.hour.toString().padLeft(2, '0')}:${n.ts.minute.toString().padLeft(2, '0')}";

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // dikey ortalama
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 8,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _notifColor(n.type),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

}
