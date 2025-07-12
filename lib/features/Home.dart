import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: isMobile
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Title
                  Row(
                    children: [
                      Image.asset("images/ysothorizontal.png", height: 48),
                      const SizedBox(width: 8),

                    ],
                  ),
                  // Mobile menu button (drawer or bottom sheet can open here)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // TODO: Add drawer or modal for nav + socials
                    },
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Title
                  Row(
                    children: [
                      Image.asset("images/ysothorizontal.png", height:135),
                      const SizedBox(width: 12),

                    ],
                  ),
                  // Nav links
                  Row(
                    children: [
                      _navItem("Home"),
                      _navItem("About"),
                      _navItem("Events"),
                      _navItem("Gallery"),
                      _navItem("Contact"),
                    ],
                  ),
                  // Socials
                  Row(
                    children: [
                      _socialIcon(FontAwesomeIcons.facebook, "https://www.facebook.com/people/Yaba-School-of-Thought-YSoT/61574807115598/?_rdr"), // Facebook
                      const SizedBox(width: 8),
                      _socialIcon(FontAwesomeIcons.linkedin,"https://www.linkedin.com/showcase/yaba-school-of-thought-ysot/" ), // LinkedIn
                      const SizedBox(width: 8),
                      _socialIcon(FontAwesomeIcons.xTwitter, "https://x.com/YSoT_NG?t=2o_aSauZ3XBQwoJhBnae1Q&s=09"), // X (Twitter)
                      const SizedBox(width: 8),
                      _socialIcon(FontAwesomeIcons.instagram,"https://www.instagram.com/ysot_ng/profilecard/?igsh=MW1qaGYwajd0Zzhu"), // Instagram
                    ],
                  )


                ],
              ),
            ),

            // Hero Section
            Container(
              height: isMobile ? 400 : 600,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/hero.jpg",
                  ),    alignment: Alignment(0, -0.5),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32),
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Voices Of Change",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 32 : 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Stories that matter",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Articles
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Featured Articles",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: List.generate(3, (index) {
                      return SizedBox(
                        width: isMobile ? screenWidth * 0.9 : 300,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.asset("assets/article${index + 1}.jpg", height: 180, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Article Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text("A short summary or excerpt from the article goes here."),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Image Gallery
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    "Gallery",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(6, (index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          "assets/gallery${index + 1}.jpg",alignment: Alignment.topCenter,
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Call to Action
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Join the Movement",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Be a part of the voices shaping our generation’s future. Share your story, join our community.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.black,
                    ),
                    child: const Text("Get Involved", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              color: const Color(0xFFF7F5FF),
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      isMobile
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._footerTopContent(isMobile),
                          const SizedBox(height: 40),
                          _footerBottomBar(isMobile),
                        ],
                      )
                          : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _footerTopContent(isMobile),
                          ),
                          const SizedBox(height: 40),
                          _footerBottomBar(isMobile),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }Widget _navItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {},
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
          // You can handle this more gracefully in a real app
          debugPrint("Couldn't launch $url");
        }
      },
    );
  }


  List<Widget> _footerTopContent(bool isMobile) {
    return [
      // Left Column – YSoT Welcome
      Flexible(
        fit: FlexFit.tight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Yaba School of Thought",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 12),
            Text(
              "You'll find various information to help you navigate and explore our content more conveniently. We're delighted that you've chosen to spend time with us.",
            ),
          ],
        ),
      ),

      // Middle Left – Links
      Flexible(
        fit: FlexFit.tight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Links", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Divider(thickness: 2, color: Colors.deepPurple),
            SizedBox(height: 8),
            Text("Home"),
            Text("Events"),
            Text("Gallery"),
            Text("Authors"),
            Text("About"),
            Text("Posts"),
            Text("iNSDEC"),
          ],
        ),
      ),

      // Middle Right – Recent Articles
      Flexible(
        fit: FlexFit.tight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Recent Articles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Divider(thickness: 2, color: Colors.deepPurple),
            SizedBox(height: 8),
            Text("Countering Boko Haram's war economy: A strategic"),
            Text("Mar 19, 2025", style: TextStyle(color: Colors.deepPurple)),
            SizedBox(height: 12),
            Text("The delusion of Nigerian exceptionalism (1)"),
            Text("Mar 17, 2025", style: TextStyle(color: Colors.deepPurple)),
            SizedBox(height: 12),
            Text("Professor E. A. Ayandele: The historian who correctly"),
            Text("Mar 17, 2025", style: TextStyle(color: Colors.deepPurple)),
          ],
        ),
      ),

      // Right Column – Email Subscription
      Flexible(
        fit: FlexFit.tight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Join our Community!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(thickness: 2, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "name@email.com",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text("Subscribe", style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }


  Widget _footerBottomBar(bool isMobile) {
    return Column(
      children: [
        const Text(
          "Copyright © 2025. `All Right reserved Template made with Brainbox Studios",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          alignment: WrapAlignment.center,
          children: const [
            Text("Facebook"),
            Text("X"),
            Text("LinkedIn"),
            Text("Youtube"),
            Text("Instagram"),
          ],
        ),
      ],
    );
  }

}
