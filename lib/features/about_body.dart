import 'package:flutter/material.dart';

class AboutBody extends StatelessWidget {
  const AboutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Title
          Center(
            child: Text(
              "About Yaba School of Thought",
              style: TextStyle(
                fontSize: isMobile ? 28 : 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Intro Tagline
          Center(
            child: Text(
              "An independent think‑tank promoting evidence‑based discourse and homegrown solutions for Nigeria.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isMobile ? 16 : 20, height: 1.4),
            ),
          ),
          const SizedBox(height: 40),

          // Mission / Goals
          _buildSectionHeading("Our Mission"),
          const SizedBox(height: 12),
          _buildBullet("Bridge Nigeria’s intellectual leadership gap"),
          _buildBullet("Deliver domestically rooted, actionable policy ideas"),
          _buildBullet("Foster collaborative leadership among top thinkers"),
          const SizedBox(height: 40),

          // Long 'About Us' section
          _buildSectionHeading("Who We Are"),
          const SizedBox(height: 12),
          Text(
            "The Yaba School of Thought stands at a critical juncture in Nigeria’s development. "
                "Formed in 2025 in YABA, Lagos, it brings together 12–15 leading thinkers committed to "
                "producing rigorous, consensus-driven, non-partisan policy research. ",
            style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Our publications will be featured through media partnerships—like with BusinessDay—as we "
                "champion transformative, evidence-based solutions tailored for local needs.",
            style: TextStyle(fontSize: isMobile ? 14 : 18, height: 1.5),
          ),
          const SizedBox(height: 40),

          // Stats / Details grid
          Wrap(
            spacing: 40,
            runSpacing: 20,
            children: [
              _buildInfoTile("Founded", "2025"),
              _buildInfoTile("Location", "YABA, Lagos"),
              _buildInfoTile("Team Size", "12–15 thinkers"),
              _buildInfoTile("Focus Areas",
                  "Philosophy, AI, Security, Media, Training, Arts & more"),
            ],
          ),
          const SizedBox(height: 40),

          // Illustration placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: isMobile ? 200 : 300,
              color: Colors.grey[300],
              child: const Center(child: Text("Image or Illustration Here")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) => Text(
    title,
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
}
