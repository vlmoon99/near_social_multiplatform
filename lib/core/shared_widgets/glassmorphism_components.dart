import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';

class BackgroundParticle {
  late Offset position;
  late Offset velocity;
  late double size;
  late double rotation;
  late double rotationSpeed;
  late double opacityPhase;
  late IconData? icon;
  late String? svgPath;

  BackgroundParticle(Size screenSize, {List<Object>? icons}) {
    final random = math.Random();
    position = Offset(random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height);
    velocity =
        Offset(random.nextDouble() * 0.4 - 0.2, random.nextDouble() * 0.4 - 0.2);
    size = 30 + random.nextDouble() * 90;
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.01;
    opacityPhase = random.nextDouble() * math.pi * 2;
    final List<Object> defaultIcons = [
      'assets/media/icons/near_social_logo.svg',
      CupertinoIcons.bell_fill,
      'assets/media/icons/near_social_logo.svg',
    ];
    final chosen = (icons ?? defaultIcons)[random.nextInt((icons ?? defaultIcons).length)];
    if (chosen is String) {
      svgPath = chosen;
      icon = null;
    } else {
      icon = chosen as IconData;
      svgPath = null;
    }
  }

  void update(Size screenSize) {
    position += velocity;
    rotation += rotationSpeed;
    opacityPhase += 0.005;

    if (position.dx < -size) position = Offset(screenSize.width + size, position.dy);
    if (position.dx > screenSize.width + size) position = Offset(-size, position.dy);
    if (position.dy < -size) position = Offset(position.dx, screenSize.height + size);
    if (position.dy > screenSize.height + size) position = Offset(position.dx, -size);
  }
}

/// Living animated background with floating particles
Widget buildLivingBackground({
  required AnimationController controller,
  required List<BackgroundParticle> particles,
  required Size screenSize,
  required bool isDark,
  Alignment gradientBegin = Alignment.topCenter,
  Alignment gradientEnd = Alignment.bottomCenter,
  List<Color>? darkColors,
  List<Color>? lightColors,
  Color? particleColor,
}) {
  // Pre-build the static gradient as child (won't rebuild)
  final gradientWidget = Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: gradientBegin,
        end: gradientEnd,
        colors: isDark
            ? (darkColors ??
                [const Color(0xFF000000), const Color(0xFF0A0A1F)])
            : (lightColors ??
                [const Color(0xFFE5E5EA), const Color(0xFFD1D1D6)]),
      ),
    ),
  );

  final pColor = particleColor ?? (isDark ? Colors.white : Colors.black45);

  return RepaintBoundary(
    child: AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        for (var p in particles) {
          p.update(screenSize);
        }
        return Stack(
          children: [
            child!,
            ...particles.map((p) => Positioned(
                  left: p.position.dx,
                  top: p.position.dy,
                  child: Opacity(
                    opacity:
                        (math.sin(p.opacityPhase) * 0.04 + 0.05).clamp(0.01, 0.1),
                    child: p.svgPath != null
                        ? SvgPicture.asset(
                            p.svgPath!,
                            width: p.size,
                            height: p.size,
                            colorFilter: ColorFilter.mode(pColor, BlendMode.srcIn),
                          )
                        : Icon(p.icon, size: p.size, color: pColor),
                  ),
                )),
          ],
        );
      },
      child: gradientWidget,
    ),
  );
}

/// Animated panel that slides in/out (for top and bottom bars)
Widget buildAnimatedPanel({
  required bool top,
  required bool showBars,
  required Widget child,
}) {
  return AnimatedPositioned(
    duration: AppAnimations.barTransition,
    curve: AppAnimations.barCurve,
    top: top ? (showBars ? 20 : -100) : null,
    bottom: top ? null : (showBars ? 16 : -100),
    left: 0,
    right: 0,
    child: Center(child: child),
  );
}

/// Glass bar container (used for top and bottom bars)
Widget buildGlassBar(double width, Widget child, bool isDark) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
          blurRadius: 35,
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
        child: Container(
          width: width,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04)
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.60)
                    ],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? Colors.white24
                  : Colors.black.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Circular icon button (used in top bar and bottom bar center button)
Widget buildCircleIcon(IconData icon, bool isDark, {double size = 32}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: isDark ? Colors.white : Colors.black,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
      ],
    ),
    child: Icon(icon,
        color: isDark ? Colors.black : Colors.white, size: size * 0.55),
  );
}

/// Glass container widget for cards and sections.
/// Set [useBlur] to true only for static overlays (modals, fixed bars).
/// For scrollable content, keep it false to avoid expensive BackdropFilter.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final bool useBlur;

  const GlassContainer({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.blurSigma = 20,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.white.withValues(alpha: 0.4)),
    );

    final inner = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration,
      child: child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: useBlur
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: inner,
              ),
            )
          : inner,
    );
  }
}

/// Glass search bar widget
/// Shows a glass-styled action sheet sliding up from bottom.
Future<T?> showGlassActionSheet<T>({
  required BuildContext context,
  required List<Widget> actions,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim1, child: child),
      );
    },
    pageBuilder: (ctx, anim1, anim2) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 12,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: actions,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Shows a glass-styled confirm dialog.
Future<bool> showGlassConfirmDialog({
  required BuildContext context,
  required String title,
  String? content,
  String confirmText = 'Yes',
  String cancelText = 'Cancel',
  Color? confirmColor,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0)
              .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
    pageBuilder: (ctx, anim1, anim2) {
      final effectiveConfirmColor = confirmColor ?? Colors.red;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Material(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (content != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            content,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(ctx, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cancelText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(ctx, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: effectiveConfirmColor.withValues(alpha: isDark ? 0.3 : 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: effectiveConfirmColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      confirmText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: effectiveConfirmColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isDark;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    this.placeholder = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)
          ],
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          placeholderStyle:
              TextStyle(color: isDark ? Colors.white38 : Colors.black45),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.search,
                size: 22, color: CupertinoColors.systemGrey),
          ),
          decoration: null,
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}

