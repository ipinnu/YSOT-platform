import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: isMobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("images/ysothorizontal.png", height: 48),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // TODO: Add drawer or bottom sheet for nav + socials
                  },
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("images/ysothorizontal.png", height: 135),
                Row(
                  children: [
                    _navItem("Home"),
                    _navItem("About"),
                    _navItem("Posts"),
                    _navItem("Events"),
                    _navItem("Gallery"),
                  ],
                ),
                Row(
                  children: [
                    _socialIcon(
                      FontAwesomeIcons.facebook,
                      "https://www.facebook.com/people/Yaba-School-of-Thought-YSoT/61574807115598/?_rdr",
                    ),
                    const SizedBox(width: 8),
                    _socialIcon(
                      FontAwesomeIcons.linkedin,
                      "https://www.linkedin.com/showcase/yaba-school-of-thought-ysot/",
                    ),
                    const SizedBox(width: 8),
                    _socialIcon(
                      FontAwesomeIcons.xTwitter,
                      "https://x.com/YSoT_NG?t=2o_aSauZ3XBQwoJhBnae1Q&s=09",
                    ),
                    const SizedBox(width: 8),
                    _socialIcon(
                      FontAwesomeIcons.instagram,
                      "https://www.instagram.com/ysot_ng/profilecard/?igsh=MW1qaGYwajd0Zzhu",
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  final Map<String, String> routeMap = {
    'Home': '/home',
    'About': '/about',
    'Events': '/events',
    'Gallery': '/gallery',
    'Contact': '/contact',
  };
  Widget _navItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          final route = routeMap[label];
          if (route != null) {
            Get.toNamed(route);
          } else {
            debugPrint('No route found for $label');
          }
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          debugPrint("Couldn't launch $url");
        }
      },
    );
  }
}
