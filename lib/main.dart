import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:ysotplatform/routing/app_pages.dart';
import 'core/Theme/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  setPathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
