import 'package:flutter/material.dart';

class AnalyseIndicator extends StatefulWidget {
  /// Height of the carousel
  final double height;

  /// Creates a swipeable image carousel with indicators
  const AnalyseIndicator({
    Key? key,
    this.height = 200,
  }) : super(key: key);

  /// Default images for the carousel
  static const List<String> _images = [
    'assets/images/hour_template.png',
    'assets/images/day_template.png',
    'assets/images/week_template.png',
  ];

  @override
  State<AnalyseIndicator> createState() => _AnalyseIndicatorState();
}

class _AnalyseIndicatorState extends State<AnalyseIndicator> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: AnalyseIndicator._images.length,
            itemBuilder: (context, index) => Image.asset(
              AnalyseIndicator._images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            AnalyseIndicator._images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}