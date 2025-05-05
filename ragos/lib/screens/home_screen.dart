import 'package:flutter/material.dart';
import '../widgets/notification_navigation.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/analyse_indicator.dart';
import 'notification_categories_screen.dart';
import 'notification_detail_screen.dart';   // <-- NEW

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final GlobalKey<_NotificationStackState> _notificationKey = GlobalKey();

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'Positive',
      'title': 'Positive Notification',
      'content': 'Positive Notification! content here.',
      'color': Colors.green,
    },
    {
      'type': 'Normal',
      'title': 'Normal Notification',
      'content': 'Normal notification content here.',
      'color': Colors.yellow,
    },
    {
      'type': 'Negative',
      'title': 'Negative Notification',
      'content': 'Negative notification content here.',
      'color': Colors.red,
    },
    {
      'type': 'Normal',
      'title': 'Another Normal',
      'content': 'More normal notifications.',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media   = MediaQuery.of(context);
    final topPad  = media.padding.top;
    final botPad  = media.padding.bottom;
    final h       = media.size.height;
    

    // 50 spacer  + 200 indicator + 16 margin below it
    const analyseBlock = 50 + 200 + 16;

    final maxHeight = h - topPad - analyseBlock - 100;
    final minHeight = 200.0 + botPad;   // gap when collapsed

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,   // tap works on empty areas too
        onTap: () {
          final st = _notificationKey.currentState;
          if (st != null && st.isExpanded) {
            st.collapse();   // collapses when already expanded
          }
        },
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(height: 50),
                  AnalyseIndicator(),
                  Spacer(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NotificationStack(
                key: _notificationKey,
                notifications: _notifications,
                maxHeight: maxHeight,
                minHeight: minHeight,
              ),
            ),
            NotificationNavigation(
              unreadCount: _notifications.length,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationCategoriesScreen(
                    notificationCounts: {
                      'positive': _notifications.where((n) => n['type'] == 'Positive').length,
                      'normal'  : _notifications.where((n) => n['type'] == 'Normal').length,
                      'negative': _notifications.where((n) => n['type'] == 'Negative').length,
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}


// ───────────────────────────────────────────────────────── notification stack
class NotificationStack extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final double maxHeight;
  final double minHeight;

  const NotificationStack({
    Key? key,
    required this.notifications,
    required this.maxHeight,
    required this.minHeight,
  }) : super(key: key);

  @override
  State<NotificationStack> createState() => _NotificationStackState();
}

class _NotificationStackState extends State<NotificationStack> {
  late double _panelHeight;
  bool _isExpanded = false;
  final ScrollController _scroll = ScrollController();

  bool get isExpanded => _isExpanded;          // public read-only getter
  void collapse() => _collapse();              // public wrapper around the private _collapse

  @override
  void initState() {
    super.initState();
    _panelHeight = widget.minHeight;
  }

  // ───────── helpers
  void _expand() {
    setState(() {
      _panelHeight = widget.maxHeight;
      _isExpanded  = true;
    });
  }

  void _collapse() {
    setState(() {
      _panelHeight = widget.minHeight;
      _isExpanded  = false;
      _scroll.jumpTo(0);           // ensure list starts at top next time
    });
  }

  // ────────── UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) _expand();
      },
      onVerticalDragUpdate: (details) {
        // manual drag (works for both directions)
        setState(() {
          _panelHeight = (_panelHeight - details.delta.dy)
              .clamp(widget.minHeight, widget.maxHeight);
          _isExpanded = _panelHeight > widget.minHeight;
        });
      },
      onVerticalDragEnd: (details) {
        final threshold =
            widget.minHeight + (widget.maxHeight - widget.minHeight) * 0.2;
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {      // drag down fast
            _collapse();
            return;
          } else if (details.primaryVelocity! < 0) { // drag up fast
            _expand();
            return;
          }
        }
        // settle depending on where the panel stopped
        (_panelHeight <= threshold) ? _collapse() : _expand();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _panelHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: _isExpanded
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]
              : null,
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
        final rev = widget.notifications.length - 1 - idx;
        final item = widget.notifications[rev];
        final height  = (70.0 - rev * 5).clamp(80.0, 100.0);
        final topOff  = rev * 40.0;
        final opacity = (1 - rev * 0.2).clamp(0.6, 1.0);

        return Positioned(
          top: topOff,
          left: 16 + rev * 6,
          right: 16 + rev * 6,
          child: Opacity(
            opacity: opacity,
            child: _notificationCard(item, height),
          ),
        );
      }),
    );
  }

  // ───────── expanded
  Widget _buildExpanded() {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) {
        // if user pulls down beyond top by >20 px, collapse panel
        if (n.metrics.pixels <= -20) _collapse();
        return false;
      },
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.notifications.length,
        itemBuilder: (context, index) {
          final item = widget.notifications[index];

          //  ➜ tap navigates ONLY in expanded mode
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(notification: item),
                ),
              );
            },
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
  Widget _notificationCard(Map<String, dynamic> item, double height) {
    return Container(
      height: height,
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
                Text(item['title'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['content'],
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
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
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(40)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
