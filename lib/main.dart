// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysotplatform/routing/app_pages.dart';

import 'core/Theme/colors.dart';

void main() {
  runApp(const YSoTApp());
}

class YSoTApp extends StatelessWidget {
  const YSoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'YSoT',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      getPages: appPages,
      theme: appTheme,
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
    );
  }
}
