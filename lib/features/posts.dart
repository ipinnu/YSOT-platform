import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'Article_Page.dart';

class PostsBody extends StatelessWidget {
  const PostsBody({super.key});

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    final List<Map<String, dynamic>> posts = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // 🔒 Safely resolve image URL
      String imageUrl;
      if (data['imagePath'] != null &&
          (data['imagePath'] as String).isNotEmpty) {
        try {
          imageUrl = await FirebaseStorage.instance
              .ref(data['imagePath'])
              .getDownloadURL();
        } catch (e) {
          imageUrl =
              'https://via.placeholder.com/400x260.png?text=Image+Unavailable';
        }
      } else {
        imageUrl =
            data['imageUrl'] ??
            'https://via.placeholder.com/400x260.png?text=No+Image';
      }

      // 🧩 Add post object with null safety
      posts.add({
        'date': data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
            : 'Unknown Date',
        'title': data['title'] ?? 'Untitled Article',
        'desc':
            data['desc'] ??
            data['summary'] ??
            'No description available for this article.',
        'tags':
            (data['tags'] as List?)?.whereType<String>().toList() ??
            [
              if (data['author'] != null &&
                  (data['author'] as String).isNotEmpty)
                data['author'],
              if (data['category'] != null &&
                  (data['category'] as String).isNotEmpty)
                data['category'],
              if ((data['author'] == null ||
                      (data['author'] as String).isEmpty) &&
                  (data['category'] == null ||
                      (data['category'] as String).isEmpty))
                'General',
            ],

        'image': imageUrl,
        'authorName': data['author'] ?? '',
      });
    }

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

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

          // 🧠 Dynamic content with FutureBuilder
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading posts: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return const Center(child: Text('No articles available.'));
              }

              return GridView.builder(
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(article: post),
                        ),
                      );
                    },
                    child: _PostCard(
                      date: post['date'] ?? 'Unknown Date',
                      title: post['title'] ?? 'Untitled',
                      desc: post['desc'] ?? '',
                      tags: post['tags'] is List<String>
                          ? post['tags']
                          : [post['tags'].toString()],
                      imageUrl: post['image'] ?? '',
                    ),
                  );
                },
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 260,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
