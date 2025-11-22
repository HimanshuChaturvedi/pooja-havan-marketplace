import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/shared/widgets/primary_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -20,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _BannerGraphic(offset: _animation.value);
              },
            ),
          ),

          // Bottom content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                children: [
                  Text(
                    "Book Pooja & Havan Easily",
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Subheading with icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        "Trusted pandits · Samagri · Temple services",
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  PrimaryButton(text: "Book Pooja", onPressed: () {}),
                  const SizedBox(height: 16),

                  PrimaryButton(text: "Book Havan", onPressed: () {}),
                  const SizedBox(height: 16),

                  PrimaryButton(text: "Explore Services", onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== BANNER (TOP SECTION) ==================== //

class _BannerGraphic extends StatelessWidget {
  final double offset;

  const _BannerGraphic({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft premium gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFE6E6), // Premium pink
                Color(0xFFFFCFEF), // Premium rose
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Floating circles (animation applied)
        Positioned(
          top: -40 + offset,
          left: -30,
          child: _circle(120, Colors.white.withOpacity(0.22)),
        ),
        Positioned(
          top: 110 - offset,
          right: -40,
          child: _circle(180, Colors.white.withOpacity(0.20)),
        ),
        Positioned(
          bottom: -20 + offset,
          left: 50,
          child: _circle(100, Colors.white.withOpacity(0.20)),
        ),

        // Devotional Icon - Diya / Temple-like glow
        Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.45),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department, // diya icon style
              size: 90,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
