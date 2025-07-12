// layout_page.dart
import 'package:flutter/material.dart';
import '../Theme/colors.dart';
import 'footer.dart';
import 'navbar.dart';

class LayoutPage extends StatelessWidget {
  final Widget child;
  final String? title;
  const LayoutPage({super.key, required this.child,required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            NavBar(), // shared
            child,          // dynamic
            const Footer(), // shared
          ],
        ),
      ),
    );
  }
}
