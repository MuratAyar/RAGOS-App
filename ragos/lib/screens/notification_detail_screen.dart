// lib/screens/notification_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/analysis_notification.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AnalysisNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  // renk paleti
  Color _notifColor(String t) => switch (t) {
        'positive' => const Color(0xFF92C751),
        'negative' => const Color(0xFFE1011B),
        _          => const Color(0xFFFCC120),
      };

  // balon rengi
  Color _speakerColor(String s) =>
      s.toLowerCase().contains('care') ? Colors.blue : Colors.green;

  // transcript satırlarını (speaker, text) ikilisine ayır
  List<(String speaker, String text)> _parseTranscript(String t) {
    final regex = RegExp(r'^\s*\[\d+:\d+\]\s*(\w+):\s*(.*)$');
    return t
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) {
          final m = regex.firstMatch(l.trim());
          if (m != null) {
            return (m.group(1) ?? '', m.group(2) ?? '');
          }
          // eşleşmezse “?” konuşmacı
          return ('?', l.trim());
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final raw   = notification.raw;
    final trans = raw['transcript'] as String? ?? 'No transcript.';
    final bubbles = _parseTranscript(trans);

    final score  = raw['caregiver_score']?.toString() ?? '—';
    final empath = raw['empathy']?.toString() ?? '—';
    final tone   = raw['tone']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(notification.title),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // tür göstergesi
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: _notifColor(notification.type),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                notification.type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ----- metrik özet kartı -----------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _metric('Caregiver', score),
                  _metric('Empathy', empath),
                  _metric('Tone', tone),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ----- justification ---------------------------------
            if (notification.content.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Why this notification?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notification.content,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ----- transcript -------------------------------------
            if (bubbles.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Conversation:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: bubbles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final (speaker, text) = bubbles[i];
                    return _buildBubble(speaker, text);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// tek metrik kutusu
  Widget _metric(String label, String val) => Column(
        children: [
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      );

  /// konuşma balonu
  Widget _buildBubble(String speaker, String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            children: [
              TextSpan(
                text: '$speaker: ',
                style: TextStyle(
                  color: _speakerColor(speaker),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: text),
            ],
          ),
        ),
      );
}
