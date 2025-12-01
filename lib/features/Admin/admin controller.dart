// admin_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ArticlesController extends GetxController {
  final articleList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedArticle = Rxn<Map<String, dynamic>>();

  // Image upload state
  final isUploadingImage = false.obs;
  final uploadProgress = 0.0.obs;

  // Categories list
  final categoriesList = <String>[].obs;
  final isLoadingCategories = false.obs;

  // Authors list
  final authorsList = <Map<String, dynamic>>[].obs;
  final isLoadingAuthors = false.obs;

  late Box box;

  // ImageKit configuration
  static const String imagekitPublicKey = 'public_i4ViE4HiviiA9DOFl/qW1ae2Elg=';
  static const String imagekitPrivateKey = 'private_sSpdnkydwo4zFpT1Dd+wxZdIz4Y=';
  static const String imagekitUploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';

  @override
  void onInit() {
    super.onInit();
    _initHive();
    loadArticles();
    loadCategories();
  }

  Future<void> _initHive() async {
    box = await Hive.openBox('articlesBox');
  }

  /// Load categories from Firestore
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();

      categoriesList.value = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();

      print("✅ Loaded ${categoriesList.length} categories");
    } catch (e) {
      print("❌ Error loading categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Load articles from Firestore and cache locally
  Future<void> loadArticles() async {
    try {
      isLoading.value = true;

      // Load from local cache first for instant display
      final local = box.get('articles') as List<dynamic>?;
      if (local != null && local.isNotEmpty) {
        articleList.value = List<Map<String, dynamic>>.from(local);
      }

      // Then fetch fresh data from Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('articles')
          .orderBy('createdAt', descending: true)
          .get();

      final list = snapshot.docs.map((d) {
        return {...d.data(), 'id': d.id};
      }).toList();

      articleList.value = list;

      // Update cache
      await box.put('articles', list);

      print("✅ Loaded ${list.length} articles from Firebase");
    } catch (e) {
      print("❌ Error loading articles: $e");
      Get.snackbar(
        'Error',
        'Could not load articles: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Enhanced ImageKit upload - returns URL but doesn't save to Firebase yet
  Future<String?> pickAndUploadImage() async {
    try {
      print("🔵 Starting image picker...");
      isUploadingImage.value = true;
      uploadProgress.value = 0.0;

      // Pick file - works on both web and mobile
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        withData: true, // IMPORTANT: Get bytes for web support
      );

      if (result == null || result.files.isEmpty) {
        print("⚠️ No file selected");
        isUploadingImage.value = false;
        return null;
      }

      final pickedFile = result.files.first;
      print("✅ File picked: ${pickedFile.name}, size: ${pickedFile.size} bytes");

      // Get file bytes (works on web and mobile)
      final fileBytes = pickedFile.bytes;
      if (fileBytes == null) {
        throw Exception("Could not read file data");
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      uploadProgress.value = 0.3;

      print("🚀 Uploading to ImageKit...");

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(imagekitUploadUrl));

      request.fields['fileName'] = fileName;
      request.fields['useUniqueFileName'] = 'true';
      request.fields['publicKey'] = imagekitPublicKey;

      // Add Basic Authentication header
      final credentials = base64Encode(utf8.encode('$imagekitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $credentials';

      // Add file from bytes (works on web)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      uploadProgress.value = 0.5;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      uploadProgress.value = 0.8;

      print("📥 Response status: ${response.statusCode}");

      final resJson = jsonDecode(resBody);

      if (response.statusCode == 200) {
        final imageUrl = resJson['url'];
        uploadProgress.value = 1.0;

        print("✅ ImageKit URL: $imageUrl");

        Get.snackbar(
          "Success",
          "Image uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Update selected article imageUrl temporarily (will be saved when user clicks Save)
        if (selectedArticle.value != null) {
          updateField('imageUrl', imageUrl);
        }

        return imageUrl;
      } else {
        throw Exception(resJson['message'] ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      print("❌ Upload exception: $e");

      Get.snackbar(
        "Upload Error",
        "Failed to upload image: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } finally {
      isUploadingImage.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void openDetailPanel(Map<String, dynamic> article) {
    selectedArticle.value = Map<String, dynamic>.from(article);
    print("📖 Opened article: ${article['title']}");
  }

  void closeDetailPanel() {
    selectedArticle.value = null;
  }

  void updateField(String key, dynamic value) {
    final art = selectedArticle.value;
    if (art != null) {
      art[key] = value;
      selectedArticle.value = Map<String, dynamic>.from(art);
      print("✏️ Updated field '$key' to: $value");
    }
  }

  Future<void> toggleFeatured(String id, bool value) async {
    try {
      await FirebaseFirestore.instance.collection('articles').doc(id).update({
        'featured': value,
      });

      final idx = articleList.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        articleList[idx]['featured'] = value;
        articleList.refresh();
        await box.put('articles', articleList);
      }

      print("⭐ Toggled featured for article $id to $value");
    } catch (e) {
      print("❌ Error toggling featured: $e");
      Get.snackbar('Error', 'Could not update featured status: $e');
    }
  }

  /// Show date picker and update date
  Future<void> pickDate(BuildContext context) async {
    final currentDate = selectedArticle.value?['createdAt']?.toDate() ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A1F44), // Deep blue color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0A1F44),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      updateField('createdAt', Timestamp.fromDate(picked));
    }
  }

  /// Save changes - This is when image URL is saved to Firebase
  Future<void> saveChanges() async {
    final art = selectedArticle.value;
    if (art == null) return;

    final id = art['id'] as String;
    final updated = Map<String, dynamic>.from(art)..remove('id');

    try {
      print("💾 Saving changes for article: $id");
      print("📸 Image URL being saved: ${updated['imageUrl']}");

      await FirebaseFirestore.instance
          .collection('articles')
          .doc(id)
          .update(updated);

      // Update local list
      final idx = articleList.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        articleList[idx] = {'id': id, ...updated};
        articleList.refresh();
      }

      // Update cache
      await box.put('articles', articleList);

      print("✅ Changes saved successfully to Firebase");

      Get.snackbar(
        'Success',
        'Changes saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      closeDetailPanel();
    } catch (e) {
      print("❌ Error saving changes: $e");
      Get.snackbar('Error', 'Could not save changes: $e');
    }
  }

  Future<void> showCreateAuthorDialog(BuildContext context) async {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    String? imageUrl;
    bool isSaving = false;
    bool isUploading = false;

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
                  const SizedBox(height: 8),
                  TextField(
                    controller: descC,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Image preview
                  if (imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imageUrl!, height: 100),
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    icon: isUploading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.upload_file),
                    label: Text(isUploading ? "Uploading..." : "Upload Image"),
                    onPressed: isUploading ? null : () async {
                      setState(() => isUploading = true);
                      try {
                        final url = await pickAndUploadImage();
                        if (url != null) {
                          setState(() => imageUrl = url);
                        }
                      } finally {
                        setState(() => isUploading = false);
                      }
                    },
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
                onPressed: (isSaving || isUploading)
                    ? null
                    : () async {
                  if (nameC.text.trim().isEmpty) {
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
                    Get.snackbar("Success", "Author created successfully");
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1F44),
                  foregroundColor: Colors.white,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                  if (catC.text.trim().isEmpty) {
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

                    // Reload categories
                    await loadCategories();

                    Get.back();
                    Get.snackbar("Success", "Category created successfully");
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

  void showCreateArticleDialog(BuildContext context) {
    final titleC = TextEditingController();
    final authorC = TextEditingController();
    final summaryC = TextEditingController();
    final contentC = TextEditingController();
    String? selectedCategory;

    bool featured = false;
    String? uploadedImageUrl;
    bool isSaving = false;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create Article'),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: authorC,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: summaryC,
                        decoration: const InputDecoration(
                          labelText: 'Summary/Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 16),

                      // Image upload section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            if (uploadedImageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    uploadedImageUrl!,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                                ),
                              ),

                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A1F44),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: isUploading
                                    ? null
                                    : () async {
                                  setState(() => isUploading = true);
                                  try {
                                    final url = await pickAndUploadImage();
                                    if (url != null) {
                                      setState(() => uploadedImageUrl = url);
                                    }
                                  } finally {
                                    setState(() => isUploading = false);
                                  }
                                },
                                icon: isUploading
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Icon(Icons.upload),
                                label: Text(isUploading ? "Uploading..." : "Upload Image"),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Category Dropdown
                      Obx(() => DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categoriesList.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedCategory = value);
                        },
                        hint: const Text('Select a category'),
                      )),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Featured Article'),
                          const Spacer(),
                          Switch(
                            value: featured,
                            activeColor: const Color(0xFF0A1F44),
                            onChanged: (v) => setState(() => featured = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1F44),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (isSaving || isUploading)
                      ? null
                      : () async {
                    if (titleC.text.trim().isEmpty) {
                      Get.snackbar("Error", "Title is required");
                      return;
                    }

                    setState(() => isSaving = true);
                    try {
                      final data = {
                        'title': titleC.text.trim(),
                        'author': authorC.text.trim(),
                        'summary': summaryC.text.trim(),
                        'content': contentC.text.trim(),
                        'imageUrl': uploadedImageUrl, // Saved to Firebase here
                        'category': selectedCategory ?? '',
                        'featured': featured,
                        'createdAt': Timestamp.now(),
                      };

                      print("🚀 Creating article: ${data['title']}");
                      print("📸 Image URL: ${data['imageUrl']}");

                      final docRef = await FirebaseFirestore.instance
                          .collection('articles')
                          .add(data);

                      print("✅ Article created with ID: ${docRef.id}");

                      // Update local list
                      articleList.insert(0, {'id': docRef.id, ...data});
                      await box.put('articles', articleList);

                      Navigator.of(dialogContext).pop();

                      Get.snackbar(
                        'Success',
                        'Article created successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      print("❌ Error creating article: $e");
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
}