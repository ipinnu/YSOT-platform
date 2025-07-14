import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/Theme/colors.dart';

class AboutBody extends StatelessWidget {
  const AboutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Title
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/idumota.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Now the text is centered inside the image
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "About Yaba School of Thought",
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Intro Tagline
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "An independent think‑tank promoting evidence‑based discourse and homegrown solutions for Nigeria.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 🧭 Mission Section in a card
          _sectionCard(
            title: "Our Mission",
            children: [
              _buildBullet("Bridge Nigeria’s intellectual leadership gap"),
              _buildBullet(
                "Deliver domestically rooted, actionable policy ideas",
              ),
              _buildBullet(
                "Foster collaborative leadership among top thinkers",
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 🧠 About Us Section — Full width, no card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 39),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading("Who We Are"),
                const SizedBox(height: 12),
                Text(
                  "The Yaba School of Thought stands at a critical juncture in Nigeria’s development. "
                  "Formed in 2025 in YABA, Lagos, it brings together 12–15 leading thinkers committed to "
                  "producing rigorous, consensus-driven, non-partisan policy research.",
                  style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "Our publications will be featured through media partnerships—like with BusinessDay—as we "
                  "champion transformative, evidence-based solutions tailored for local needs.",
                  style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 📊 Quick Stats — in a subtle card with grid look
          _sectionCard(
            title: "Quick Facts",
            children: [
              Wrap(
                spacing: 40,
                runSpacing: 20,
                children: [
                  _buildInfoTile("Founded", "2025"),
                  _buildInfoTile("Location", "YABA, Lagos"),
                  _buildInfoTile("Team Size", "12–15 thinkers"),
                  _buildInfoTile(
                    "Focus Areas",
                    "Philosophy, AI, Security, Media, Training, Arts & more",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 39),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading("Who We Are"),
                const SizedBox(height: 12),
                Text(
                  "The Yaba School of Thought stands at a critical juncture in Nigeria’s development. "
                  "Formed in 2025 in YABA, Lagos, it brings together 12–15 leading thinkers committed to "
                  "producing rigorous, consensus-driven, non-partisan policy research.",
                  style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "Our publications will be featured through media partnerships—like with BusinessDay—as we "
                  "champion transformative, evidence-based solutions tailored for local needs.",
                  style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: isMobile ? 200 : 300,
                color: Colors.grey[300],
                child: const Center(child: Text("Image or Illustration Here")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
  );

  Widget _buildBullet(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 20)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );

  Widget _buildInfoTile(String label, String value) => SizedBox(
    width: 160,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeading(title),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
