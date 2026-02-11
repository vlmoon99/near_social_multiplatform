import 'dart:async';
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

/// Glass container widget for cards and sections
class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;

  const GlassContainer({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.blurSigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass search bar widget
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
        ),
      ),
    );
  }
}

/// Mixin providing common living background + auto-hide bar boilerplate
mixin LivingPageMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final ScrollController livingScrollController = ScrollController();
  late final AnimationController bgController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();
  bool showBars = true;
  Timer? hideTimer;
  late List<BackgroundParticle> particles = [];
  Size lastSize = Size.zero;

  void handleScroll() {
    if (showBars) setState(() => showBars = false);
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showBars = true);
    });
  }

  void initLivingPage() {
    livingScrollController.addListener(handleScroll);
  }

  void disposeLivingPage() {
    bgController.dispose();
    livingScrollController.dispose();
    hideTimer?.cancel();
  }

  void ensureParticles(Size screenSize, int count, {List<Object>? icons}) {
    if (particles.isEmpty || lastSize != screenSize) {
      particles = List.generate(
        count,
        (i) => BackgroundParticle(screenSize, icons: icons),
      );
      lastSize = screenSize;
    }
  }
}
