import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/aggregation_service.dart';

class AnalyseIndicator extends StatefulWidget {
  final double height;
  const AnalyseIndicator({super.key, this.height = 200});

  @override
  State<AnalyseIndicator> createState() => _AnalyseIndicatorState();
}

class _AnalyseIndicatorState extends State<AnalyseIndicator> {
  late final PageController _pager;
  int _cur = 0;
  List<String> _images = const [          // yüklenene kadar placeholder
    'assets/images/hour_template.png',
    'assets/images/day_template.png',
    'assets/images/week_template.png',
  ];

  @override
  void initState() {
    super.initState();
    _pager = PageController();
    _loadAggregates();
  }

  Future<void> _loadAggregates() async {
    final uid  = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final service = AggregationService('http://10.0.2.2:8000');  // Android emulator
    final result  = await service.fetch(uid);
    if (result == null) return;

    setState(() {
      _images = [
        'assets/images/hour_${result.hourly.label}.png',
        'assets/images/day_${result.daily.label}.png',
        'assets/images/week_${result.weekly.label}.png',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pager,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _cur = i),
            itemBuilder: (_, i) => Image.asset(_images[i], fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _cur == i ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _cur == i ? Colors.white : Colors.white54,
              shape: BoxShape.circle,
            ),
          )),
        ),
      ],
    );
  }

  @override
  void dispose() { _pager.dispose(); super.dispose(); }
}
