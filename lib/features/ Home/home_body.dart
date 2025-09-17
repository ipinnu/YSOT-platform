import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/Theme/colors.dart';
import 'TopicsTicker.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late YoutubePlayerController ytController;

  @override
  void initState() {
    super.initState();

    ytController = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          ) ??
          '', // ✅ fallback to empty string to avoid crash
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  Widget _statsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final stats = [
      {'value': '20+', 'label': 'Years of Experience'},
      {'value': '20+', 'label': 'Industry Awards'},
      {'value': '10+', 'label': 'Projects Delivered'},
      {'value': '50+', 'label': 'Happy Partners'},
    ];

    Widget _statItem(String value, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 2, height: 48, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      );
    }

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140, // 🔥 enforce equal width
                  child: _statItem(stats[0]['value']!, stats[0]['label']!),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 140,
                  child: _statItem(stats[1]['value']!, stats[1]['label']!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: _statItem(stats[2]['value']!, stats[2]['label']!),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 140,
                  child: _statItem(stats[3]['value']!, stats[3]['label']!),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Desktop → single row with spacing
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats
            .map((s) => _statItem(s['value']!, s['label']!))
            .toList(),
      );
    }
  }

  @override
  void dispose() {
    ytController.dispose();
    super.dispose(); // ✅ not dispose() — use super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        // Hero Section
        Container(
          height: isMobile ? 400 : 600,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/hero.jpg"),
              alignment: Alignment(0, -0.5),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Voices Of Change",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 32 : 62,
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
        SizedBox(height: 52),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 40 : 150),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/background_texture.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      """The Yaba School of Thought (YSoT) is an independent, non-partisan community of Nigerian thinkers, scholars, and innovators dedicated to building a stronger intellectual foundation for the nation. Founded in 2025 and based in Yaba, Lagos — a historic hub of education and innovation — YSoT brings together leading voices across diverse fields to tackle Nigeria’s most pressing governance, cohesion, and development challenges.""",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 96),
        _statsSection(context),
        SizedBox(height: 95),
        const TopicsMarquee(),
        SizedBox(height: 145),

        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster image first
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'images/ysotposter.jpg',
                      width: double.infinity,
                      height: isMobile ? 200 : 300,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Main deep blue container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF011236),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Talk of the Town',
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          'Yaba School of Thought Inaugural Webinar',
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Body text
                        Text(
                          'In a moment that called for more than commentary, the voices that matter showed up. Led by Ogie Eboigbe, with moderation by Oyinkan Teriba, the session featured deeply rooted insights from Prof. Francis Egbokhare and Dr. Richard Ikiebe each tackling Nigeria’s systemic gaps not with slogans, but with thought.From governance fatigue to policy paralysis, the conversation didn’t skirt around the complexity. Words like “laying state” weren’t dropped casually they carried weight, and the room understood it. While Nigeria might still be searching for its thinkers, that evening they didn’t just turn up they took the lead.',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            height: 1.6,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // See what happened button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/events');
                            },
                            icon: Icon(
                              FontAwesomeIcons.arrowRight,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            label: Text(
                              'See what happened',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Optional: small YouTube preview (not dominant)
                  GestureDetector(
                    onTap: () async {
                      const url =
                          'https://www.youtube.com/watch?v=YOUR_VIDEO_ID';
                      if (await canLaunchUrl(url as Uri)) {
                        await launchUrl(url as Uri);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'images/yt_preview.png',
                            width: isMobile ? 220 : 320,
                            height: isMobile ? 124 : 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Dark overlay
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: isMobile ? 220 : 320,
                            height: isMobile ? 124 : 180,
                            color: Colors.black26, // semi-transparent overlay
                          ),
                        ),
                        // Play icon
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: isMobile ? 40 : 60,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  // Same desktop layout you already have
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 360),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 160),
                          decoration: const BoxDecoration(
                            color: Color(0xFF011236),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Talk of the Town',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                                Text(
                                  'Yaba School of Thought Inaugural Webinar ',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: 900,
                                  child: Text(
                                    'In a moment that called for more than commentary, the voices that matter showed up. Led by Ogie Eboigbe, with moderation by Oyinkan Teriba, the session featured deeply rooted insights from Prof. Francis Egbokhare and Dr. Richard Ikiebe each tackling Nigeria’s systemic gaps not with slogans, but with thought.From governance fatigue to policy paralysis, the conversation didn’t skirt around the complexity. Words like “laying state” weren’t dropped casually they carried weight, and the room understood it. While Nigeria might still be searching for its thinkers, that evening they didn’t just turn up they took the lead.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/events'),
                                    icon: Icon(
                                      FontAwesomeIcons.arrowRight,
                                      color: AppColors.secondary,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'See what happened',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Top-left video
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 320,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: YoutubePlayer(controller: ytController),
                    ),
                  ),

                  // Bottom-left poster
                  Positioned(
                    bottom: -130,
                    left: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'images/ysotposter.jpg',
                        width: 520,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
        SizedBox(height: 185),
        // Recent Blog Post (replacing Featured Articles)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 94),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recent Blog Post",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BlogImage(),
                          const SizedBox(height: 24),
                          _BlogText(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _BlogImage()),
                          const SizedBox(width: 32),
                          Expanded(flex: 3, child: _BlogText()),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.white,
                ),
                label: const Text(
                  "Show More",
                  style: TextStyle(color: Colors.white),
                ),

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.primary, // fill color
                  foregroundColor: Colors.white, // icon & text color
                  side: BorderSide.none, // removes default border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Gallery Section (unchanged)

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
                  color: AppColors.primary,
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Be a part of the voices shaping our generation’s future. Share your story, join our community.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Get Involved",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlogImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            "images/The price of paralysis.jpg", // Use correct path
            fit: BoxFit.cover,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(3),
          child: Text(
            "Jun 30, 2025",
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _BlogText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "The price of paralysis: How governance failure is strangling the Nigeria promise",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          "\"Picture this: A nation where it takes 21 days to clear goods from ports while neighbouring Ghana manages it in 48 hours. Where N17 trillion worth of federal projects lie abandoned like graveyards of broken promises. Where obtaining a simple passport becomes an odyssey of months, forcing citizens to choose between bribery and bureaucratic purgatory.\"",
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: null,
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            foregroundColor: MaterialStatePropertyAll(Colors.black),
            elevation: MaterialStatePropertyAll(0),
            side: MaterialStatePropertyAll(BorderSide(color: Colors.black87)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            padding: MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          child: Text("Prof. Sunday E. Atawodi"),
        ),
      ],
    );
  }
}
