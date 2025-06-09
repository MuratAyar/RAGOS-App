import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();


/// Sentiment etiketini (positive / neutral / negative) ve skoru tutar
class AggregateWindow {
  final String label;            // "positive" | "neutral" | "negative"
  final double score;
  AggregateWindow({required this.label, required this.score});
}

class AggregationResult {
  final AggregateWindow hourly, daily, weekly;
  AggregationResult({required this.hourly, required this.daily, required this.weekly});
}

class AggregationService {
  final String _baseUrl;   // ör. http://127.0.0.1:8000

  AggregationService(this._baseUrl);

  Future<AggregationResult?> fetch(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/aggregate/$userId');
      final res  = await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) {
        logger.e('❌ HTTP error: ${res.statusCode}');
        logger.e('Response body: ${res.body}');
        return null;
      }

      final decoded = json.decode(res.body);
      final data = decoded['data'];

      AggregateWindow w(String k) => AggregateWindow(
        label : data[k]['sentiment_label'] as String? ?? 'neutral',
        score : (data[k]['sentiment_score'] as num?)?.toDouble() ?? 0.0,
      );

      logger.i('✅ Aggregation loaded: $data');

      return AggregationResult(
        hourly : w('hourly'),
        daily  : w('daily'),
        weekly : w('weekly'),
      );
    } catch (e) {
      logger.e('🔥 Failed to fetch: $e');
      return null;
    }
  }
}
