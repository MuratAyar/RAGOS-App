import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/analysis_notification.dart';

class NotificationService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Ana koleksiyon path’i: users/{uid}/analysis_results
  Stream<List<AnalysisNotification>> streamNotifications({bool todayOnly = false}) {
    final uid = _auth.currentUser!.uid;
    final query = _db
        .collection('users')
        .doc(uid)
        .collection('analysis_results')
        .orderBy('timestamp', descending: true);

    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => AnalysisNotification.fromDoc(d.id, d.data()))
          .toList();

      if (!todayOnly) return list;

      final now = DateTime.now();
      return list.where((n) =>
          n.ts.year == now.year &&
          n.ts.month == now.month &&
          n.ts.day == now.day).toList();
    });
  }

}
