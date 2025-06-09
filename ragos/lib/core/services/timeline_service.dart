// TimelineService – fetch only **today**’s events
//-------------------------------------------------
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../models/timeline_event.dart';

final _log = Logger();

class TimelineService {
  final String _base;
  TimelineService(this._base);

  Future<List<TimelineEvent>> fetchToday(String userId) async {
    // build ?day=YYYY-MM-DD query
    final now = DateTime.now();
    final day = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('$_base/timeline/$userId?day=$day');

    try {
      final res =
          await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        _log.e('Timeline HTTP ${res.statusCode}: ${res.body}');
        return [];
      }
      final data = json.decode(res.body)['data'] as List<dynamic>;
      _log.i('Timeline (today) loaded: ${data.length} items');
      return data
          .cast<Map<String, dynamic>>()
          .map(TimelineEvent.fromJson)
          .toList();
    } catch (e) {
      _log.e('Timeline fetch error: $e');
      return [];
    }
  }
}
