// admin_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ArticlesController extends GetxController {
  // List of articles
  final articleList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // Currently selected article for detail panel
  final selectedArticle = Rxn<Map<String, dynamic>>();

  late Box box;

  @override
  void onInit() {
    super.onInit();
    _initHive();
    loadArticles();
  }

  Future<void> _initHive() async {
    box = await Hive.openBox('articlesBox');
  }

  /// Load list from Hive (offline) then Firebase, and cache
  Future<void> loadArticles() async {
    try {
      isLoading.value = true;
      final local = box.get('articles') as List<dynamic>?;
      if (local != null && local.isNotEmpty) {
        articleList.value = List<Map<String, dynamic>>.from(local);
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('articles')
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs.map((d) {
        return {
          ...d.data(),
          'id': d.id,
        };
      }).toList();
      articleList.value = list;
      box.put('articles', list);
    } catch (e) {
      Get.snackbar('Error', 'Could not load articles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Open detail panel for an article
  void openDetailPanel(Map<String, dynamic> article) {
    // Create a deep copy for editing
    selectedArticle.value = Map<String, dynamic>.from(article);
  }

  /// Close detail panel
  void closeArticleDetail() {
    selectedArticle.value = null;
  }

  /// Update a generic field in selected article
  void updateField(String key, dynamic value) {
    final art = selectedArticle.value;
    if (art != null) {
      art[key] = value;
      selectedArticle.value = Map<String, dynamic>.from(art);
    }
  }

  /// Toggle featured flag directly in database
  Future<void> toggleFeatured(String id, bool value) async {
    await FirebaseFirestore.instance
        .collection('articles')
        .doc(id)
        .update({'featured': value});
    // Reflect locally
    final idx = articleList.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      articleList[idx]['featured'] = value;
      articleList.refresh();
    }
  }
  void closeDetailPanel() {
    selectedArticle.value = null;
  }
  void updateDate(DateTime newDate) {
    selectedArticle.update((article) {
      if (article != null) {
        article['createdAt'] = Timestamp.fromDate(newDate);
      }
    });
  }

  /// Save all changes from detail panel back to Firestore
  Future<void> saveChanges() async {
    final art = selectedArticle.value;
    if (art == null) return;
    final id = art['id'] as String;
    final updated = Map<String, dynamic>.from(art)
      ..remove('id');
    try {
      await FirebaseFirestore.instance
          .collection('articles')
          .doc(id)
          .update(updated);
      // Update list locally
      final idx = articleList.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        articleList[idx] = {'id': id, ...updated};
        articleList.refresh();
      }
      Get.snackbar('Success', 'Changes saved');
      closeArticleDetail();
      box.put('articles', articleList);
    } catch (e) {
      Get.snackbar('Error', 'Could not save changes: $e');
    }
  }

  /// View article in dialog (read-only)
  void viewArticle(Map<String, dynamic> article) {
    Get.dialog(
      AlertDialog(
        title: Text(article['title'] ?? ''),
        content: SingleChildScrollView(
          child: Text(article['content'] ?? ''),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  /// Dialog for creating new article
  void showCreateArticleDialog() {
    final titleC = TextEditingController();
    final authorC = TextEditingController();
    final summaryC = TextEditingController();
    final contentC = TextEditingController();
    final imageC = TextEditingController();
    final categoryC = TextEditingController();
    bool featured = false;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Article'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: authorC, decoration: const InputDecoration(labelText: 'Author')),
              TextField(controller: summaryC, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: contentC, decoration: const InputDecoration(labelText: 'Content')),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'Image URL')),
              TextField(controller: categoryC, decoration: const InputDecoration(labelText: 'Category')),
              Row(
                children: [
                  const Text('Featured'),
                  StatefulBuilder(builder: (c, s) {
                    return Switch(
                      value: featured,
                      onChanged: (v) => s(() => featured = v),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleC.text,
                'author': authorC.text,
                'summary': summaryC.text,
                'content': contentC.text,
                'imageUrl': imageC.text,
                'category': categoryC.text,
                'featured': featured,
                'createdAt': Timestamp.now(),
              };
              final doc = await FirebaseFirestore.instance.collection('articles').add(data);
              articleList.insert(0, {'id': doc.id, ...data});
              box.put('articles', articleList);
              Get.back();
              Get.snackbar('Success', 'Article created');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
