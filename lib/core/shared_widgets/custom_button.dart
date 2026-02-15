import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    this.primary = false,
    super.key,
    required this.onPressed,
    required this.child,
  });

  final bool primary;
  final Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.black;
    final background = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white;
    final primaryFg = isDark ? Colors.black : Colors.white;
    final primaryBg = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white38 : Colors.black;

    return FilledButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed!();
        }
      },
      style: FilledButton.styleFrom(
        backgroundColor: primary ? primaryBg : background,
        foregroundColor: primary ? primaryFg : foreground,
        disabledForegroundColor: primary ? primaryFg : foreground,
        disabledBackgroundColor: primary ? primaryBg : background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8).r,
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
      ),
      child: child,
    );
  }
}
