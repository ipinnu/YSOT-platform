import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  bool menuOpen = false;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // offscreen to the right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void toggleMenu() {
    setState(() {
      menuOpen = !menuOpen;
      if (menuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  final Map<String, String> routeMap = {
    'Home': '/home',
    'About': '/about',
    'Events': '/events',
    'Gallery': '/gallery',
    'Posts': '/posts',
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Stack(
      children: [
        // Main NavBar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("images/ysothorizontal.png", height: isMobile ? 48 : 135),
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: toggleMenu,
                )
              else
                Row(
                  children: [
                    _navItem("Home"),
                    _navItem("About"),
                    _navItem("Posts"),
                    _navItem("Events"),
                    _navItem("Gallery"),
                    const SizedBox(width: 16),
                    _socialIcon(FontAwesomeIcons.facebook,
                        "https://www.facebook.com/people/Yaba-School-of-Thought-YSoT/61574807115598/?_rdr"),
                    _socialIcon(FontAwesomeIcons.linkedin,
                        "https://www.linkedin.com/showcase/yaba-school-of-thought-ysot/"),
                    _socialIcon(FontAwesomeIcons.xTwitter,
                        "https://x.com/YSoT_NG?t=2o_aSauZ3XBQwoJhBnae1Q&s=09"),
                    _socialIcon(FontAwesomeIcons.instagram,
                        "https://www.instagram.com/ysot_ng/profilecard/?igsh=MW1qaGYwajd0Zzhu"),
                  ],
                ),
            ],
          ),
        ),

        // Side panel mobile menu
        if (isMobile)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: const Color(0xFF011236),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: toggleMenu,
                        ),
                        const SizedBox(height: 24),
                        ...['Home', 'About', 'Posts', 'Events', 'Gallery'].map(
                              (label) => ListTile(
                            title: Text(label, style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              Get.toNamed(routeMap[label]!);
                              toggleMenu();
                            },
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialIcon(FontAwesomeIcons.facebook,
                                "https://www.facebook.com/people/Yaba-School-of-Thought-YSoT/61574807115598/?_rdr"),
                            _socialIcon(FontAwesomeIcons.linkedin,
                                "https://www.linkedin.com/showcase/yaba-school-of-thought-ysot/"),
                            _socialIcon(FontAwesomeIcons.xTwitter,
                                "https://x.com/YSoT_NG?t=2o_aSauZ3XBQwoJhBnae1Q&s=09"),
                            _socialIcon(FontAwesomeIcons.instagram,
                                "https://www.instagram.com/ysot_ng/profilecard/?igsh=MW1qaGYwajd0Zzhu"),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _navItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => Get.toNamed(routeMap[label]!),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Colors.white),
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


