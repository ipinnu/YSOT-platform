// admin_cms_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin controller.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticlesController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Articles'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadArticles,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.showCreateArticleDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Add Author",
            onPressed: () => controller.showCreateAuthorDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: "Add Category",
            onPressed: () => controller.showCreateCategoryDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Author')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Published')),
                        DataColumn(label: Text('Image')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Featured')),
                      ],
                      rows: List.generate(controller.articleList.length, (
                        index,
                      ) {
                        final a = controller.articleList[index];
                        return DataRow(
                          onSelectChanged: (_) {
                            controller.openDetailPanel(a);
                          },
                          cells: [
                            DataCell(Text('${index + 1}')), // 1
                            DataCell(Text(a['title'] ?? '')), // 2
                            DataCell(Text(a['author'] ?? '')), // 3
                            DataCell(
                              Text(
                                a['createdAt']?.toDate().toString().split(
                                      ' ',
                                    )[0] ??
                                    '',
                              ),
                            ), // 4
                            DataCell(
                              Text(a['published'] ?? ''),
                            ), // ✅ FIXED (now 5)
                            DataCell(
                              a['imageUrl'] != null
                                  ? SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Image.network(
                                        a['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ), // 6
                            DataCell(Text(a['category'] ?? '')), // 7
                            DataCell(
                              Switch(
                                value: a['featured'] ?? false,
                                onChanged: (val) {
                                  controller.toggleFeatured(a['id'], val);
                                },
                              ),
                            ), // 8
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                // Detail Panel
                Obx(() {
                  final selected = controller.selectedArticle.value;
                  if (selected == null) return const SizedBox.shrink();
                  return Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Article Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: controller.closeDetailPanel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  TextFormField(
                                    initialValue: selected['title'],
                                    decoration: const InputDecoration(
                                      labelText: 'Title',
                                    ),
                                    onChanged: (v) =>
                                        controller.updateField('title', v),
                                  ),
                                  const SizedBox(height: 8),
                                  // Author Dropdown
                                  Obx(() {
                                    final selectedAuthor = controller
                                        .selectedArticle
                                        .value?['author'];
                                    return DropdownButtonFormField<String>(
                                      value:
                                          controller.authorsList.any(
                                            (a) => a['name'] == selectedAuthor,
                                          )
                                          ? selectedAuthor
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Author',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: controller.authorsList
                                          .map<DropdownMenuItem<String>>(
                                            (author) =>
                                                DropdownMenuItem<String>(
                                                  value: author['name'],
                                                  child: Text(author['name']),
                                                ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.updateField(
                                            'author',
                                            value,
                                          );
                                        }
                                      },
                                      hint: const Text('Select an author'),
                                    );
                                  }),

                                  const SizedBox(height: 8),
                                  // Date
                                  TextFormField(
                                    initialValue: selected['createdAt']
                                        ?.toDate()
                                        .toString()
                                        .split(' ')[0],
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                    ),
                                    readOnly: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Image Upload Section with Better UI
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Article Image',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Image Preview
                                        Center(
                                          child: Obx(() {
                                            final imageUrl = controller
                                                .selectedArticle
                                                .value?['imageUrl'];
                                            return Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey.shade200,
                                              ),
                                              child:
                                                  imageUrl != null &&
                                                      imageUrl.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.image_outlined,
                                                          size: 60,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'No image uploaded',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            );
                                          }),
                                        ),

                                        const SizedBox(height: 12),

                                        // Upload Button with Progress
                                        Obx(() {
                                          final isUploading =
                                              controller.isUploadingImage.value;
                                          final progress =
                                              controller.uploadProgress.value;

                                          return Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed: isUploading
                                                      ? null
                                                      : controller
                                                            .pickAndUploadImage,
                                                  icon: isUploading
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons.upload,
                                                        ),
                                                  label: Text(
                                                    isUploading
                                                        ? "Uploading..."
                                                        : "Upload New Image",
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                ),
                                              ),

                                              if (isUploading) ...[
                                                const SizedBox(height: 8),
                                                LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${(progress * 100).toInt()}%',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  // Category Dropdown
                                  Obx(
                                    () => DropdownButtonFormField<String>(
                                      value: selected['category'],
                                      decoration: const InputDecoration(
                                        labelText: 'Category',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: controller.categoriesList.map((
                                        cat,
                                      ) {
                                        return DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.updateField(
                                            'category',
                                            value,
                                          );
                                        }
                                      },
                                      hint: const Text('Select a category'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Featured
                                  Row(
                                    children: [
                                      const Text('Featured'),
                                      Obx(
                                        () => Switch(
                                          value:
                                              controller
                                                  .selectedArticle
                                                  .value?['featured'] ??
                                              false,
                                          onChanged: (v) => controller
                                              .updateField('featured', v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Description
                                  TextFormField(
                                    initialValue: selected['summary'],
                                    decoration: const InputDecoration(
                                      labelText: 'Description',
                                    ),
                                    maxLines: 2,
                                    onChanged: (v) =>
                                        controller.updateField('summary', v),
                                  ),
                                  const SizedBox(height: 8),
                                  // Content
                                  TextFormField(
                                    initialValue: selected['content'],
                                    decoration: const InputDecoration(
                                      labelText: 'Content',
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    minLines: 10,
                                    maxLines: null,
                                    onChanged: (v) =>
                                        controller.updateField('content', v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1F44),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      }),
    );
  }
}
