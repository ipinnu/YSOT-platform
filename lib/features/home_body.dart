import 'package:flutter/material.dart';

import '../core/Theme/colors.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

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
        ),SizedBox(height: 52),
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
              image: AssetImage('assets/background_texture.png'), // subtle background
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),       SizedBox(height: 36),Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 2,
                      height: 48,
                      color: Colors.blueAccent,
                    ),
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
            ), SizedBox(width: 82),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 2,
                        height: 48,
                        color: Colors.blueAccent,
                      ),
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
                      Container(
                        width: 2,
                        height: 48,
                        color: Colors.blueAccent,
                      ),
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
              SizedBox(width: 82),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 2,
                        height: 48,
                        color: Colors.blueAccent,
                      ),
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


        // Recent Blog Post (replacing Featured Articles)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 94),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recent Blog Post",
                style: TextStyle(
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

                label: const Text(
                  "Show More",
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
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
                      "assets/gallery${index + 1}.jpg",
                      alignment: Alignment.topCenter,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.black,
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
