// lib/routes/app_pages.dart
import 'package:get/get.dart';

import '../core/Layout/LayoutPage.dart';
import '../features/about_body.dart';
import '../features/ Home/home_body.dart';

class AppRoutes {
  static const home = '/';
  static const about = '/about';
}

final List<GetPage> appPages = [
  GetPage(
    name: AppRoutes.home,
    page: () => LayoutPage(child: const HomeBody(),title: 'Home',),
  ),
  GetPage(
    name: AppRoutes.about,
    page: () => LayoutPage(
      title: 'About YSoT',
      child: const AboutBody(),
    ),
  ),
];
