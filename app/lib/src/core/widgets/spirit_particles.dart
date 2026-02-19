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
  final List<_Particle> _particles = List.generate(25, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
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
  double size = Random().nextDouble() * 2 + 1;
  double speed = Random().nextDouble() * 0.1 + 0.05;
  double opacity = Random().nextDouble() * 0.5 + 0.2;
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

      // Subtle pulse effect
      double pOpacity = p.opacity * (0.8 + 0.2 * sin(animationValue * 2 * pi));
      
      paint.color = color.withOpacity(pOpacity.clamp(0.0, 1.0));
      
      canvas.drawCircle(
        Offset(xPos, yPos),
        p.size,
        paint,
      );
      
      // Add a tiny glow
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(xPos, yPos), p.size * 2, paint);
      paint.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
