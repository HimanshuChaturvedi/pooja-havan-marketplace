import 'dart:math';
import 'package:flutter/material.dart';

class SpiritParticles extends StatefulWidget {
  final Color color;
  const SpiritParticles({super.key, this.color = Colors.white});

  @override
  State<SpiritParticles> createState() => _SpiritParticlesState();
}

class _SpiritParticlesState extends State<SpiritParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // Increased particle count for more "Glossy Dust"
  final List<_Particle> _particles = List.generate(40, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value, widget.color),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 3 + 0.5; // Varied sizes
  double speed = Random().nextDouble() * 0.08 + 0.03;
  double opacity = Random().nextDouble() * 0.6 + 0.1;
  double twinkleSpeed = Random().nextDouble() * 3 + 1; // Unique twinkle
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  final Color color;

  _ParticlePainter(this.particles, this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      // Slow upward drift
      double currentY = (p.y - (animationValue * p.speed)) % 1.0;
      
      double xPos = p.x * size.width;
      double yPos = currentY * size.height;

      // Twinkling logic (Sine wave based on individual speed)
      double twinkle = (sin(animationValue * 2 * pi * p.twinkleSpeed) + 1) / 2;
      double pOpacity = p.opacity * (0.3 + 0.7 * twinkle);
      
      paint.color = color.withOpacity(pOpacity.clamp(0.0, 1.0));
      
      // Draw main particle
      canvas.drawCircle(
        Offset(xPos, yPos),
        p.size,
        paint,
      );
      
      // Add a soft glow (Bloom) if the particle is "bright"
      if (twinkle > 0.8) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(xPos, yPos), p.size * 2.5, paint);
        paint.maskFilter = null;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
