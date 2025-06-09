class TimelineEvent {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;          // “Ate”, “Left Home”
  final String group;          // “Meals” …
  final double avgSentiment;
  final double maxToxicity;
  final bool abuse;

  TimelineEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.group,
    required this.avgSentiment,
    required this.maxToxicity,
    required this.abuse,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> j) {
    return TimelineEvent(
      id            : j['id'],
      start         : DateTime.parse(j['start_time']),
      end           : DateTime.parse(j['end_time']),
      title         : j['primary_category'],
      group         : j['category_group'],
      avgSentiment  : (j['metrics']['avg_sentiment'] as num).toDouble(),
      maxToxicity   : (j['metrics']['max_toxicity'] as num).toDouble(),
      abuse         : j['abuse_flag'] as bool,
    );
  }
}
