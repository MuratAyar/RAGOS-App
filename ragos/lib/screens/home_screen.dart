// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/notification_navigation.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/analyse_indicator.dart';
import 'notification_categories_screen.dart';
import 'notification_detail_screen.dart';

import '../core/services/notification_service.dart';
import '../models/analysis_notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 1;
  final GlobalKey<_NotificationStackState> _notificationKey = GlobalKey();
  final _notifSvc = NotificationService();

  @override
  Widget build(BuildContext context) {
    final media   = MediaQuery.of(context);
    final topPad  = media.padding.top;
    final botPad  = media.padding.bottom;
    final h       = media.size.height;

    const analyseBlock = 50 + 200 + 16;                // spacer + indicator
    final maxHeight = h - topPad - analyseBlock - 100; // expanded panel
    final minHeight = 200.0 + botPad;                  // collapsed panel

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<AnalysisNotification>>(
        stream: _notifSvc.streamNotifications(todayOnly: true),        // 🔴 canlı veri
        builder: (context, snap) {
          final notifs = snap.data ?? [];

          final unread = notifs.length;
          final counts = {
            'positive': notifs.where((n) => n.type == 'positive').length,
            'normal'  : notifs.where((n) => n.type == 'normal').length,
            'negative': notifs.where((n) => n.type == 'negative').length,
          };

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _notificationKey.currentState?.collapse(),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: const [
                      SizedBox(height: 50),
                      AnalyseIndicator(),
                      Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: NotificationStack(
                    key: _notificationKey,
                    notifications: notifs,             // 🔴 model list
                    maxHeight: maxHeight,
                    minHeight: minHeight,
                  ),
                ),
                NotificationNavigation(
                  unreadCount: unread,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationCategoriesScreen(
                        notificationCounts: counts,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}

// ───────────────────────────────────────────────────────── notification stack
class NotificationStack extends StatefulWidget {
  final List<AnalysisNotification> notifications;   // 🔴 yeni tip
  final double maxHeight;
  final double minHeight;

  const NotificationStack({
    super.key,
    required this.notifications,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  State<NotificationStack> createState() => _NotificationStackState();
}

class _NotificationStackState extends State<NotificationStack> {
  late double _panelHeight;
  bool _isExpanded = false;
  final ScrollController _scroll = ScrollController();

  bool get isExpanded => _isExpanded;
  void collapse() => _collapse();

  @override
  void initState() {
    super.initState();
    _panelHeight = widget.minHeight;
  }

  // ───────── helpers
  void _expand()  => setState(() { _panelHeight = widget.maxHeight; _isExpanded = true; });
  void _collapse() => setState(() { _panelHeight = widget.minHeight; _isExpanded = false; _scroll.jumpTo(0); });

  Color _notifColor(String t) => switch (t) {
        'positive' => const Color(0xFF92C751),
        'negative' => const Color(0xFFE1011B),
        _          => const Color(0xFFFCC120),
      };

  // ───────── UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { if (!_isExpanded) _expand(); },
      onVerticalDragUpdate: (d) => setState(() {
        _panelHeight = (_panelHeight - d.delta.dy).clamp(widget.minHeight, widget.maxHeight);
        _isExpanded  = _panelHeight > widget.minHeight;
      }),
      onVerticalDragEnd: (d) {
        final th = widget.minHeight + (widget.maxHeight - widget.minHeight) * 0.2;
        if (d.primaryVelocity != null) {
          d.primaryVelocity! > 0  ? _collapse()
                                  : d.primaryVelocity! < 0 ? _expand() : null;
        }
        if (_panelHeight <= th) _collapse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _panelHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: _isExpanded ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)] : null,
        ),
        child: _isExpanded ? _buildExpanded() : _buildCollapsed(),
      ),
    );
  }

  // ───────── collapsed
  Widget _buildCollapsed() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: List.generate(widget.notifications.length, (idx) {
        final rev   = widget.notifications.length - 1 - idx;
        final item  = widget.notifications[rev];
        final h     = (70.0 - rev * 5).clamp(80.0, 100.0);
        final top   = rev * 40.0;
        final opac  = (1 - rev * 0.2).clamp(0.6, 1.0);

        return Positioned(
          top: top,
          left: 16 + rev * 6,
          right: 16 + rev * 6,
          child: Opacity(opacity: opac, child: _notificationCard(item, h)),
        );
      }),
    );
  }

  // ───────── expanded
  Widget _buildExpanded() {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) { if (n.metrics.pixels <= -20) _collapse(); return false; },
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.notifications.length,
        itemBuilder: (context, index) {
          final item = widget.notifications[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: item)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _notificationCard(item, 80),
            ),
          );
        },
      ),
    );
  }

  // ───────── single card
  Widget _notificationCard(AnalysisNotification n, double height) {
    final timeStr = "${n.ts.hour.toString().padLeft(2, '0')}:${n.ts.minute.toString().padLeft(2, '0')}";

    return Container(
      height: height >= 100 ? height : 100,
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
                mainAxisAlignment: MainAxisAlignment.center,
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
