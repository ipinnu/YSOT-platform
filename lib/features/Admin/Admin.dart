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
            onPressed: controller.showCreateArticleDialog,
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
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Image')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Featured')),
                      ],
                      rows: List.generate(controller.articleList.length, (index) {
                        final a = controller.articleList[index];
                        return DataRow(
                          onSelectChanged: (_) {
                            controller.openDetailPanel(a);
                          },
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(a['title'] ?? '')),
                            DataCell(Text(a['author'] ?? '')),
                            DataCell(Text(
                                a['createdAt']?.toDate().toString().split(' ')[0] ?? '')),
                            DataCell(a['imageUrl'] != null
                                ? SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(a['imageUrl'], fit: BoxFit.cover),
                            )
                                : const Icon(Icons.image_not_supported)),
                            DataCell(Text(a['category'] ?? '')),
                            DataCell(Switch(
                              value: a['featured'] ?? false,
                              onChanged: (val) {
                                controller.toggleFeatured(a['id'], val);
                              },
                            )),
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
                              const Text('Article Details',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: controller.closeDetailPanel,
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Title
                          TextFormField(
                            initialValue: selected['title'],
                            decoration: const InputDecoration(labelText: 'Title'),
                            onChanged: (v) => controller.updateField('title', v),
                          ),
                          const SizedBox(height: 8),
                          // Author
                          TextFormField(
                            initialValue: selected['author'],
                            decoration: const InputDecoration(labelText: 'Author'),
                            onChanged: (v) => controller.updateField('author', v),
                          ),
                          const SizedBox(height: 8),
                          // Date
                          TextFormField(
                            initialValue: selected['createdAt']
                                ?.toDate()
                                .toString()
                                .split(' ')[0],
                            decoration: const InputDecoration(labelText: 'Date'),
                            onChanged: (v) => controller.updateDate(v as DateTime),
                          ),
                          const SizedBox(height: 8),
                          // Image URL
                          TextFormField(
                            initialValue: selected['imageUrl'],
                            decoration: const InputDecoration(labelText: 'Image URL'),
                            onChanged: (v) => controller.updateField('imageUrl', v),
                          ),
                          const SizedBox(height: 8),
                          // Category
                          TextFormField(
                            initialValue: selected['category'],
                            decoration: const InputDecoration(labelText: 'Category'),
                            onChanged: (v) => controller.updateField('category', v),
                          ),
                          const SizedBox(height: 8),
                          // Featured
                          Row(
                            children: [
                              const Text('Featured'),
                              Obx(() => Switch(
                                value: controller.selectedArticle.value?['featured'] ?? false,
                                onChanged: (v) => controller.updateField('featured', v),
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Description
                          TextFormField(
                            initialValue: selected['summary'],
                            decoration: const InputDecoration(labelText: 'Description'),
                            maxLines: 2,
                            onChanged: (v) => controller.updateField('summary', v),
                          ),
                          const SizedBox(height: 8),
                          // Content
                          Expanded(
                            child: TextFormField(
                              initialValue: selected['content'],
                              decoration: const InputDecoration(labelText: 'Content'),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onChanged: (v) => controller.updateField('content', v),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.saveChanges,
                            child: const Text('Save Changes'),
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
