import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IncomingCallModal extends StatelessWidget {
  final String callerAccountId;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallModal({
    super.key,
    required this.callerAccountId,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.phone_fill,
                    size: 48,
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Incoming Call',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    callerAccountId,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(16),
                        color: CupertinoColors.systemRed,
                        borderRadius: BorderRadius.circular(50),
                        onPressed: onReject,
                        child: const Icon(
                          CupertinoIcons.phone_down_fill,
                          color: Colors.white,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(16),
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(50),
                        onPressed: onAccept,
                        child: const Icon(
                          CupertinoIcons.phone_fill,
                          color: Colors.white,
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
    );
  }
}
