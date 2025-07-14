import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  @override
  void dispose() {
    ytController.dispose();
    super.dispose(); // ✅ not dispose() — use super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final screenWidth = MediaQuery.of(context).size.width;

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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(
                'assets/background_texture.png',
              ), // subtle background
              fit: BoxFit.cover,
            ),
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
              SizedBox(height: 16),
              Text(
                'We’re a strategy-first growth company. We help businesses move with purpose, powered by intuitive design and bold thinking.',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
        SizedBox(height: 36),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(width: 2, height: 48, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '20+',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Years of Experience',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 82),
              Column(
                children: [
                  Row(
                    children: [
                      Container(width: 2, height: 48, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '20+',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Years of Experience',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 82),
              Column(
                children: [
                  Row(
                    children: [
                      Container(width: 2, height: 48, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100+',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Projects Delivered',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Container(width: 2, height: 48, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '50+',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Happy Partners',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 45),
        const TopicsMarquee(),
        SizedBox(height: 145),

        Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacer to push blue container rightward
                SizedBox(width: 360),

                // Right section: Deep blue container with text
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 160),
                    decoration: BoxDecoration(
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
                          SizedBox(height: 32),
                          Wrap(
                            spacing: 40,
                            runSpacing: 32,
                            children: [
                              // RESEARCH
                              SizedBox(
                                width: 900,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'In a moment that called for more than commentary, the voices that matter showed up. Led by Ogie Eboigbe, with moderation by Oyinkan Teriba, the session featured deeply rooted insights from Prof. Francis Egbokhare and Dr. Richard Ikiebe each tackling Nigeria’s systemic gaps not with slogans, but with thought.From governance fatigue to policy paralysis, the conversation didn’t skirt around the complexity. Words like “laying state” weren’t dropped casually they carried weight, and the room understood it. While Nigeria might still be searching for its thinkers, that evening they didn’t just turn up they took the lead.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // DATA
                            ],
                          ),
                          SizedBox(height: 25),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton.icon(
                              onPressed: () {
                                // Navigate to event page
                                Navigator.pushNamed(
                                  context,
                                  '/events',
                                ); // Or use your preferred nav method
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
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
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

            // Top-left YouTube player
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
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: YoutubePlayer(
                  controller: ytController,
                  showVideoProgressIndicator: true,
                  progressColors: ProgressBarColors(
                    playedColor: Colors.redAccent,
                    handleColor: Colors.redAccent,
                  ),
                ),
              ),
            ),

            // Bottom-left poster overlay image
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
                style: TextStyle( color: AppColors.primary,
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
                icon: const Icon(FontAwesomeIcons.arrowRight, color: Colors.white),
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
                style: TextStyle( color: AppColors.primary,
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
            "assets/images/blog/governance-failure.png", // Use correct path
            fit: BoxFit.cover,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
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
          child: Text("Mr Ogie Eboigbe"),
        ),
      ],
    );
  }
}
