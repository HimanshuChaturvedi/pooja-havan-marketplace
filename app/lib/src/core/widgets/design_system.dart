import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showAppBar;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: true,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              backgroundColor: extendBodyBehindAppBar ? Colors.transparent : Colors.white,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        top: !extendBodyBehindAppBar,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkCharcoal,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.saffron,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final bool showShadow;

  const PrimaryCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.color = Colors.white,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.saffron.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.color,
  });

  bool get _isDisabled => onTap == null && !loading;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;

    if (_isDisabled) {
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey.shade500;
    } else if (loading) {
      bgColor = (color ?? AppColors.saffron).withOpacity(0.6);
      textColor = Colors.white;
    } else {
      bgColor = color ?? AppColors.saffron;
      textColor = Colors.white;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isDisabled || loading) ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
          foregroundColor: textColor,
          disabledForegroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isDisabled ? 0 : 2,
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.saffron.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.saffron,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
