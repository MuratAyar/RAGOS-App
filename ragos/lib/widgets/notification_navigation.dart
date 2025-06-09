import 'package:flutter/material.dart';

class NotificationNavigation extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;

  const NotificationNavigation({
    super.key,
    required this.onTap,
    this.unreadCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      right: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main hanging container
            Container(
              width: 60,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            // Top knob
            Positioned(
              top: 0,
              left: 20,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Unread badge
            if (unreadCount > 0)
              Positioned(
                top: 85,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[900]!, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
