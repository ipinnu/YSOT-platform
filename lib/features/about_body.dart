import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/Theme/colors.dart';

class AboutBody extends StatelessWidget {
  const AboutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        Padding(
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
                      "The Yaba School of Thought (YSoT) is a non-partisan collective of Nigerian scholars, public "
                      "intellectuals, and policy thinkers committed to addressing the country’s deep-rooted governance "
                      "and development challenges through rigorous, context-specific research.\n\n"
                      "Founded in 2025 and based in Yaba, Lagos — a historic hub of education and innovation — YSoT "
                      "brings together 12–15 leading voices from diverse fields to generate high-impact, locally grounded ideas. "
                      "We believe that meaningful national transformation requires more than borrowed models; it demands a renewal "
                      "of intellectual leadership rooted in Nigeria’s unique realities.\n\n"
                      "Our work focuses on critical areas including governance, national cohesion, education, and institutional reform. "
                      "We aim to influence public discourse, support evidence-based policymaking, and rebuild the intellectual infrastructure "
                      "needed for long-term national development.YSoT exists to ask the hard questions, challenge outdated assumptions, and foster the kind of deep thinking necessary for Nigeria to chart a more coherent and inclusive future."
                      ,

                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Our publications will be featured through media partnerships—like with BusinessDay—as we "
                      "champion transformative, evidence-based solutions tailored for local needs.",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        height: 1.5,
                      ),
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
                      _buildInfoTile("Team Size", "12 thinkers"),
                      _buildInfoTile(
                        "Focus Areas",
                        "Nationality, Social Order, Security, Intellectual Crises, Economic Solutions, Policies & more",
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Why Yaba \nSchool of \nThought",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 20 : 45,
                              height: 1.5,
                            ),
                          ),
                          _buildSectionHeading(
                            "The time for intellectual complacency is OVER",
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "For far too long, Nigeria’s national direction has been shaped by fragmented visions — "
                            "regional, ethnic, and religious interests pulling in opposite directions. As a result, the "
                            "dream of a unified, progressive Nigeria has been compromised by outdated frameworks, tribal "
                            "loyalty, and narrow advocacy that ignore the bigger picture of our shared future. "
                            "Yaba School of Thought (YSoT) was born from the urgent need to reverse this trend. We are an "
                            "independent, self-motivated community of thinkers, scholars, innovators, and problem-solvers, "
                            "united by one goal: to forge a new intellectual foundation for Nigeria — one that puts critical "
                            "thought, unity of purpose, and bold, innovative leadership at the heart of our national conversation. ",
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 18,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "The spectre of balkanisation — the slow but steady tearing apart of a country along ethnic, "
                            "religious, and regional lines — is no longer just a distant threat; it is a creeping reality. "
                            "If left unchecked, it threatens to produce chaos of historic proportions, worse than the traumatic "
                            "partitions witnessed in places like India and Pakistan. "
                            "But we believe in the possibility of something greater. We believe that Nigeria can be more than "
                            "the sum of its parts. We believe that the Nigerian mind can be awakened again to serve a larger, "
                            "unified vision. ",
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 18,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "That is why YSoT exists.",
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 18,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        width: isMobile ? 80 : 520,
                        height: isMobile ? 80 : 320,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.school,
                          size: 70,
                          color: AppColors.primary,
                        ), // Replace with Image.asset(...) or Image.network(...) when ready
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 86),
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Meet our Thinkers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop - show full image
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/Author.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            } else {
              // Mobile - split image into top and bottom halves
              return Column(
                children: [
                  Image.asset(
                    'images/Author1.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    'images/Author2.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ],
              );

            }
          },
        ),
      ],
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
