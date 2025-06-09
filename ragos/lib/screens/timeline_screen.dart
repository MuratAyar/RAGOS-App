import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/services/timeline_service.dart';
import '../models/timeline_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bottom_navigation.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  Future<List<TimelineEvent>>? _future;
  static const double _gap = 28;      // space between rows
  static const double _line = 60;     // inner line height

  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((_) => _loadEvents());
  }

  Future<void> _loadEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final service = TimelineService('http://10.0.2.2:8000');
    setState(() {
      _future = service.fetchToday(uid);   //  <-- assign here
    });
  }


  // ---------- helpers ----------
  Color _colorFor(TimelineEvent e) {
    if (e.abuse) return Colors.red.shade400;
    if (e.avgSentiment > 0.25) return Colors.green.shade400;
    if (e.avgSentiment < -0.25) return Colors.orange.shade400;
    return Colors.blueGrey.shade300;
  }

  IconData _iconFor(TimelineEvent e) {
    switch (e.group) {
      case 'Meals':               return Icons.restaurant;
      case 'Sleep':               return Icons.king_bed;
      case 'Hygiene':             return Icons.shower;
      case 'Location & Travel':   return Icons.directions_bus;
      case 'Emotions & Behaviour':return Icons.sentiment_satisfied;
      default:                    return Icons.circle;
    }
  }

  String _fmt(DateTime dt) => DateFormat('hh:mm a').format(dt).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final lineClr = AppColors.greyLine.withOpacity(
        Theme.of(context).brightness == Brightness.dark ? .6 : 1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: SafeArea(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            // go straight back to Home (bottom-nav index 1)
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/home'),
          ),
        ),
        title: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('Today', style: AppTextStyles.title),
          ),
        ),
      ),

      body: FutureBuilder<List<TimelineEvent>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(fontSize: 13)));
          }
          final events = snap.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events yet'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final lineHeight = (events.length - 1) * _gap + events.length * 40;

              return Stack(
                children: [
                  // ────────── Arka planda çizgi (sadece içerik kadar uzun) ──────────
                  Positioned(
                    left: 35, // DOT ortası
                    top: 24,
                    child: Container(
                      width: 2,
                      height: lineHeight.toDouble(),
                      color: lineClr,
                    ),
                  ),

                  // ────────── Üstte: DOT + METİN içeren liste ──────────
                  ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    itemCount: events.length,
                    itemBuilder: (_, i) {
                      final e = events[i];
                      final last = i == events.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(bottom: last ? 0 : _gap),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DOT (çizgi arkada zaten var)
                            SizedBox(
                              width: 40,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _colorFor(e),
                                  ),
                                  child: Icon(_iconFor(e),
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // metin
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title,
                                      style: AppTextStyles.timelineTitle),
                                  const SizedBox(height: 4),
                                  Text(_fmt(e.start),
                                      style: AppTextStyles.timelineTime),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),



      bottomNavigationBar: AppBottomNavigation(currentIndex: 3),
    );
  }
}
