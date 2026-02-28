import 'package:flutter/material.dart';
import '../../theme/components/app_colors.dart';

/// ✅ DEVICE-SAFE Glass Card
/// BackdropFilter was causing SOLID GRAY on many Android devices.
/// Replaced with solid semi-opaque white that looks great and works everywhere.
class DivineGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showShine;

  const DivineGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.showShine = true,
  });

  @override
  State<DivineGlassCard> createState() => _DivineGlassCardState();
}

class _DivineGlassCardState extends State<DivineGlassCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.white.withOpacity(0.82), // ✅ SOLID – works on all devices
            border: Border.all(
              color: AppColors.saffron.withOpacity(0.25),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
