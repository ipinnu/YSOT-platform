import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  final VoidCallback onViewPressed;
  final VoidCallback onDownloadPressed;

  const EventsPage({
    super.key,
    required this.onViewPressed,
    required this.onDownloadPressed,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Webinar Transcript Summaries.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001489), // Deep blue
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Intelligent, Simple.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            children: [
              ElevatedButton(
                onPressed: widget.onViewPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: StadiumBorder(),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onDownloadPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: StadiumBorder(),
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
