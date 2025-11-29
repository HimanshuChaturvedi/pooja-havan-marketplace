import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _elevationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _elevationAnim = Tween<double>(
      begin: 6,
      end: 14,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSecondary ? AppColors.gold : AppColors.saffron;
    final fg = widget.isSecondary ? AppColors.saffronDark : AppColors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _elevationAnim,
        builder: (context, child) {
          return Material(
            elevation: _elevationAnim.value,
            shadowColor: bg.withOpacity(0.35),
            borderRadius: BorderRadius.circular(30),
            color: bg,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              alignment: Alignment.center,
              child: Text(
                widget.text,
                style: AppTextStyles.button.copyWith(color: fg),
              ),
            ),
          );
        },
      ),
    );
  }
}
