// admin_controller.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
        return {...d.data(), 'id': d.id};
      }).toList();
      articleList.value = list;
      box.put('articles', list);
    } catch (e) {
      Get.snackbar('Error', 'Could not load articles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      final file = File(result.files.single.path!);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child(
        "articles/$fileName.jpg",
      );
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      // Update selected article immediately
      updateField("imageUrl", downloadUrl);

      Get.snackbar("Success", "Image uploaded successfully");
    } catch (e) {
      Get.snackbar("Error", "Image upload failed: $e");
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
    await FirebaseFirestore.instance.collection('articles').doc(id).update({
      'featured': value,
    });
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
    final updated = Map<String, dynamic>.from(art)..remove('id');
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
        content: SingleChildScrollView(child: Text(article['content'] ?? '')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> showCreateAuthorDialog(BuildContext context) async {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    String? imageUrl;
    bool isSaving = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Author'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descC,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Image"),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null && result.files.single.path != null) {
                        final file = result.files.single;
                        final ref = FirebaseStorage.instance.ref().child(
                          'authors/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                        );
                        await ref.putData(file.bytes!);
                        final url = await ref.getDownloadURL();
                        setState(() => imageUrl = url);
                        Get.snackbar("Image Uploaded", "Author image ready");
                      }
                    },
                  ),
                  if (imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.network(imageUrl!, height: 60),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (nameC.text.isEmpty) {
                          Get.snackbar("Error", "Name is required");
                          return;
                        }
                        setState(() => isSaving = true);
                        try {
                          final data = {
                            'name': nameC.text.trim(),
                            'description': descC.text.trim(),
                            'imageUrl': imageUrl,
                            'createdAt': Timestamp.now(),
                          };
                          await FirebaseFirestore.instance
                              .collection('authors')
                              .add(data);
                          Get.back();
                          Get.snackbar("Success", "Author created");
                        } catch (e) {
                          Get.snackbar("Error", "Could not save author: $e");
                        } finally {
                          setState(() => isSaving = false);
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------
  // 🔹 Category Dialog
  Future<void> showCreateCategoryDialog(BuildContext context) async {
    final catC = TextEditingController();
    bool isSaving = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Category'),
            content: TextField(
              controller: catC,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (catC.text.isEmpty) {
                          Get.snackbar("Error", "Category name is required");
                          return;
                        }
                        setState(() => isSaving = true);
                        try {
                          final data = {
                            'name': catC.text.trim(),
                            'createdAt': Timestamp.now(),
                          };
                          await FirebaseFirestore.instance
                              .collection('categories')
                              .add(data);
                          Get.back();
                          Get.snackbar("Success", "Category created");
                        } catch (e) {
                          Get.snackbar("Error", "Could not save category: $e");
                        } finally {
                          setState(() => isSaving = false);
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Dialog for creating new article
  void showCreateArticleDialog(BuildContext context) {
    final titleC = TextEditingController();
    final authorC = TextEditingController();
    final summaryC = TextEditingController();
    final contentC = TextEditingController();
    final categoryC = TextEditingController();

    bool featured = false;
    String? uploadedImageUrl; // store uploaded image here
    bool isSaving = false;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // dialogContext is the context for Navigator.of(...) inside the dialog
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create Article'),
                  // X close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // close dialog
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleC,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: authorC,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: summaryC,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Content - big multiline box
                    TextField(
                      controller: contentC,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 6,
                      maxLines: null,
                    ),
                    const SizedBox(height: 12),

                    // Image preview + upload
                    uploadedImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              uploadedImageUrl!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image, size: 60, color: Colors.grey),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              setState(() => isUploading = true);
                              try {
                                final url = await _pickAndUploadImage();
                                if (url != null) {
                                  setState(() => uploadedImageUrl = url);
                                  Get.snackbar('Upload', 'Image uploaded');
                                } else {
                                  Get.snackbar('Upload', 'No file selected');
                                }
                              } catch (e) {
                                Get.snackbar('Upload error', '$e');
                              } finally {
                                setState(() => isUploading = false);
                              }
                            },
                      icon: isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: categoryC,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Featured'),
                        Switch(
                          value: featured,
                          onChanged: (v) => setState(() => featured = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // Close/Cancel - always pop with Navigator
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),

                // Create button (disabled while saving)
                ElevatedButton(
                  onPressed: () async {
                    print("🟢 Create button pressed"); // sanity check

                    setState(() => isSaving = true);
                    try {
                      final data = {
                        'title': titleC.text.trim(),
                        'author': authorC.text.trim(),
                        'summary': summaryC.text.trim(),
                        'content': contentC.text,
                        'imageUrl': uploadedImageUrl,
                        'category': categoryC.text.trim(),
                        'featured': featured,
                        'createdAt': Timestamp.now(),
                      };

                      print("🚀 Trying to save article: $data");

                      final docRef = await FirebaseFirestore.instance
                          .collection('articles')
                          .add(data);

                      print("✅ Saved to Firestore with ID: ${docRef.id}");

                      articleList.insert(0, {'id': docRef.id, ...data});
                      await box.put('articles', articleList);

                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop(); // close dialog
                        print("🟢 Dialog closed");
                      } else {
                        print("⚠️ Dialog context could not pop");
                      }

                      Get.snackbar('Success', 'Article created');
                    } catch (e, st) {
                      print("❌ Firestore save error: $e");
                      print(st);
                      Get.snackbar('Error', 'Could not save article: $e');
                    } finally {
                      setState(() => isSaving = false);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Helper inside the same controller
  Future<String?> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return null;

      final file = File(result.files.single.path!);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child(
        "articles/$fileName.jpg",
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar("Error", "Image upload failed: $e");
      return null;
    }
  }
}
