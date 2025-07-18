import 'package:flutter/material.dart';
import '../Theme/colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFFF7F5FF),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._buildFooterSections(isMobile),
              const SizedBox(height: 40),
              _footerBottomBar(),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildFooterSections(isMobile),
          ),
          if (!isMobile) const SizedBox(height: 40),
          if (!isMobile) _footerBottomBar(),
        ],
      ),
    );
  }

  List<Widget> _buildFooterSections(bool isMobile) {
    final spacing = isMobile ? const SizedBox(height: 32) : const SizedBox.shrink();

    return [
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Yaba School of Thought",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "You'll find various information to help you navigate and explore our content more conveniently. We're delighted that you've chosen to spend time with us.",
            ),
          ],
        ),
      ),
      spacing,
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Links", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Divider(thickness: 2, color: AppColors.primary),
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
      spacing,
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Recent Articles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Divider(thickness: 2, color: AppColors.primary),
            SizedBox(height: 8),
            Text("Countering Boko Haram's war economy: A strategic"),
            Text("Mar 19, 2025", style: TextStyle(color: AppColors.primary)),
            SizedBox(height: 12),
            Text("The delusion of Nigerian exceptionalism (1)"),
            Text("Mar 17, 2025", style: TextStyle(color: AppColors.primary)),
            SizedBox(height: 12),
            Text("Professor E. A. Ayandele: The historian who correctly"),
            Text("Mar 17, 2025", style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
      spacing,
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Join our Community!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(thickness: 2, color: AppColors.primary),
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text("Subscribe", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _footerBottomBar() {
    return Column(
      children: [
        const Text(
          "©iNSDEC 2025. All Rights Reserved",
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
