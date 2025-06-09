import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisNotification {
  final String id;
  final String title;
  final String content;
  final String type;   // positive / normal / negative
  final DateTime ts;   // cihaz saat diliminde
  final Map<String, dynamic> raw;

  AnalysisNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.ts,
    required this.raw,
  });

  factory AnalysisNotification.fromDoc(String id, Map<String, dynamic> d) {
    //------------------------------------------------------------------
    // 1. Bildirim tipini seç (aynen kalıyor)
    //------------------------------------------------------------------
    final primary = (d['primary_category'] ?? '').toString().toLowerCase();

    final sentScore = (d['sentiment_score'] ?? 0.0) as num;
    final cgScore   = (d['caregiver_score'] ?? 6)   as num;
    final toxScore  = (d['toxicity']       ?? 0.0) as num;

    late final String notifType;
    if (toxScore >= 0.4 || cgScore <= 3 || sentScore <= -0.2) {
      notifType = 'negative';
    } else if (sentScore > 0.2 && cgScore >= 7) {
      notifType = 'positive';
    } else {
      notifType = 'normal';
    }

    //------------------------------------------------------------------
    // 2. Zaman damgası -> yerel saat ( **YENİ** )
    //------------------------------------------------------------------
    final rawTs = d['timestamp'];
    late final DateTime parsedTs;

    const turkeyOffset = Duration(hours: 3);

    if (rawTs is Timestamp) {
      parsedTs = rawTs.toDate().toUtc().add(turkeyOffset);
    } else if (rawTs is String) {
      parsedTs = DateTime.parse(rawTs).toUtc().add(turkeyOffset);
    }


    //------------------------------------------------------------------
    // 3. Özet / justification (aynen kalıyor)
    //------------------------------------------------------------------
    final String content =
        (d['summary'] ?? d['justification'] ?? '').toString().trim();

    return AnalysisNotification(
      id: id,
      title: primary.isNotEmpty ? primary.capitalize() : 'Analysis',
      content: content,
      type: notifType,
      ts: parsedTs,
      raw: d,
    );
  }
}

extension StringCap on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
