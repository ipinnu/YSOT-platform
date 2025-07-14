import 'dart:async';
import 'package:flutter/material.dart';

class TopicsMarquee extends StatefulWidget {
  const TopicsMarquee({Key? key}) : super(key: key);

  @override
  State<TopicsMarquee> createState() => _TopicsMarqueeState();
}

class _TopicsMarqueeState extends State<TopicsMarquee> {
  final ScrollController _controller = ScrollController();
  final double _scrollSpeed = 0.5; // pixels per tick
  Timer? _timer;

  // ✅ Initialized immediately, not `late`
  final List<Widget> _items = [];

  @override
  void initState() {
    super.initState();

    // Topics with styles
    final topics = [
      {'name': 'Leadership Pathology',   'bg': Color(0xFFE1F5FE), 'text': Colors.green},
      {'name': 'Social Crises',    'bg': Color(0xFFE1F5FE), 'text': Colors.blue},
      {'name': 'Ethnic Politics',        'bg': Color(0xFFFFF0F5), 'text': Colors.pink},
      {'name': 'National Identity',     'bg': Color(0xFFF3F2FF), 'text': Colors.indigo},
      {'name': 'Economic Development',   'bg': Color(0xFFFFF3E0), 'text': Colors.orange},
      {'name': 'Intellectual Crisis',  'bg': Color(0xFFE1F5FE), 'text': Colors.green},
      {'name': 'Institutional Failure', 'bg': Color(0xFFE0F7FA), 'text': Colors.teal},
      {'name': 'National Security',    'bg': Color(0xFFFFEBEE), 'text': Colors.red},
    ];

    // Build pill widgets
    final topicWidgets = topics.map((t) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: t['bg'] as Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            t['name'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t['text'] as Color,
            ),
          ),
        ),
      );
    }).toList();

    // ✅ Duplicate to ensure smooth looping
    _items.addAll(topicWidgets);
    _items.addAll(topicWidgets);

    // Auto-scroll animation
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_controller.hasClients) return;
      final maxScroll = _controller.position.maxScrollExtent;
      final nextScroll = _controller.offset + _scrollSpeed;
      _controller.jumpTo(nextScroll >= maxScroll ? 0 : nextScroll);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF011236), // deep blue bg
      height: 80,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (_, i) {
            return Center(child: _items[i]);
          },
        ),
      ),
    );
  }

}
