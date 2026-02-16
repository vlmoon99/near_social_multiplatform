import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Compact glass-style toast notification, max 550px wide.
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastWidget(
      message: message,
      isDark: isDark,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.isDark,
    required this.onDismiss,
  });

  final String message;
  final bool isDark;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white12
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: CupertinoColors.activeGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
