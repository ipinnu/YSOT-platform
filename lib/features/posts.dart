import 'package:flutter/material.dart';

class PostsBody extends StatelessWidget {
  const PostsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // 📝 Updated placeholder data with multiple tags
    final posts = [
      {
        'date': 'MONDAY 30 JUNE 2025',
        'title': 'The price of paralysis',
        'desc':
        'An in-depth analysis of how systemic inefficiencies, poor governance, and outdated bureaucratic processes are paralyzing Nigeria’s development...',
        'tags': ['Institutional Failure', 'Prof. Sunday E. Atawodi'],
        'image': 'https://picsum.photos/400/260?random=1',
      },
      {
        'date': 'TUESDAY 10 JUNE 2025',
        'title': 'China as a development model',
        'desc':
        'An insightful exploration of China’s state-led development model and how its principles...',
        'tags': ['Economic Development', 'Mr Ogie Eboigbe'],
        'image': 'https://picsum.photos/400/260?random=2',
      },
      {
        'date': 'Mar 05, 2025',
        'title': 'Theft of the Nigerian mind',
        'desc':
        'A powerful call for intellectual decolonisation in Nigeria, exploring pre-colonial knowledge systems...',
        'tags': ['Licensing', 'Dr. Richard Ikiebe'],
        'image': 'https://picsum.photos/400/260?random=3',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Articles',
            style: TextStyle(
              fontSize: isMobile ? 24 : 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 32,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(
                date: post['date'] as String,
                title: post['title'] as String,
                desc: post['desc'] as String,
                tags: post['tags'] as List<String>,
                imageUrl: post['image'] as String,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String date;
  final String title;
  final String desc;
  final List<String> tags;
  final String imageUrl;

  const _PostCard({
    required this.date,
    required this.title,
    required this.desc,
    required this.tags,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🖼️ Image placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          date,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // 🏷️ Multiple tags row
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: tags
              .map(
                (tag) => Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}
