import 'package:get/get.dart';
import '../core/Layout/LayoutPage.dart';
import '../features/Admin/Admin login.dart';
import '../features/Admin/Admin.dart';
import '../features/Admin/admin controller.dart';
import '../features/about_body.dart';
import '../features/ Home/home_body.dart';
import '../features/gallery.dart';
import '../features/posts.dart';
import '../features/events.dart'; // ✅
// features/Admin/AdminBinding.dart

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ArticlesController());
  }
}

class AppRoutes {
  static const home = '/';
  static const about = '/about';
  static const posts = '/posts';
  static const gallery = '/gallery';
  static const events = '/events';
  static const admin = '/admin';
  static const adminLogin = '/admin-login';
}

final List<GetPage> appPages = [
  GetPage(
    name: AppRoutes.home,
    page: () => LayoutPage(child: const HomeBody(), title: 'Home'),
  ),
  GetPage(
    name: AppRoutes.about,
    page: () => LayoutPage(title: 'About YSoT', child: const AboutBody()),
  ),
  GetPage(
    name: AppRoutes.posts,
    page: () => LayoutPage(title: 'All Posts', child: const PostsBody()),
  ),
  GetPage(
    name: AppRoutes.gallery,
    page: () => LayoutPage(title: 'Gallery', child: GalleryPage()),
  ),
  GetPage(
    name: AppRoutes.events,
    page: () => LayoutPage(
      title: 'Events',
      child: EventsPage(onViewPressed: () {}, onDownloadPressed: () {}),
    ),
  ),
  GetPage(
    name: AppRoutes.admin,
    page: () => AdminPage(),
    binding: AdminBinding(),
  ),
  GetPage(name: AppRoutes.adminLogin, page: () => AdminLogin()),
];
