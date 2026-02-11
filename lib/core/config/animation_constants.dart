import 'package:flutter/animation.dart';

/// Centralized animation constants for consistent iOS-like animations
class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  // Curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  // Bar show/hide
  static const Duration barTransition = Duration(milliseconds: 350);
  static const Curve barCurve = Curves.easeOutCubic;

  // Modal
  static const Duration modalTransition = Duration(milliseconds: 400);
  static const Curve modalCurve = Curves.easeOutBack;

  // Button press
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const double buttonScaleDown = 0.95;
  static const double navButtonScaleDown = 0.9;

  // Profile/card taps
  static const double profileTapScaleDown = 0.97;
  static const double cardTapScaleDown = 0.98;
}
