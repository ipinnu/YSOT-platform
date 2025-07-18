import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<String> images = [
    'images/1.jpg',
    'images/2.jpg',
    'images/3.jpg',
    'images/4.jpg',
    'images/5.jpg',
    'images/7.jpg',
    'images/6.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive row item count
    int itemsPerRow = 2;
    if (width < 700) itemsPerRow = 1;

    // Separate images
    final firstTwo = images.take(2).toList();
    final middleImages = images.sublist(2, images.length - 1);
    final lastImage = images.last;

    // Helper to style each image
    Widget styledImage(String path) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(path, fit: BoxFit.cover),
      );
    }

    // Helper to build rows from a list of images
    List<Widget> buildImageRows(List<String> imageList) {
      List<Widget> rows = [];
      for (int i = 0; i < imageList.length; i += itemsPerRow) {
        final rowImages = imageList.skip(i).take(itemsPerRow).toList();
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: rowImages.map((img) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: styledImage(img),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }
      return rows;
    }

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gallery",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            // First two stacked vertically
            Column(
              children: firstTwo.map((img) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: styledImage(img),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Middle images in rows
            ...buildImageRows(middleImages),

            const SizedBox(height: 20),

            // Centered last image
            Center(
              child: Container(
                width: width < 700 ? double.infinity : width * 0.5,
                child: styledImage(lastImage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}