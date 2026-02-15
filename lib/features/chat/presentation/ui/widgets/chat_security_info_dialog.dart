import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showChatSecurityInfoDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.lock_shield_fill,
                      size: 40,
                      color: isDark
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.activeGreen.darkColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'chat.security_title'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _section(
                      icon: CupertinoIcons.lock_fill,
                      text: 'chat.security_e2e'.tr(),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _section(
                      icon: CupertinoIcons.device_phone_portrait,
                      text: 'chat.security_local_storage'.tr(),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _section(
                      icon: CupertinoIcons.exclamationmark_triangle_fill,
                      text: 'chat.security_warning'.tr(),
                      isDark: isDark,
                      isWarning: true,
                    ),
                    const SizedBox(height: 14),
                    _section(
                      icon: CupertinoIcons.arrow_right_arrow_left,
                      text: 'chat.security_no_server'.tr(),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('common.close'.tr()),
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
  );
}

Widget _section({
  required IconData icon,
  required String text,
  required bool isDark,
  bool isWarning = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          icon,
          size: 18,
          color: isWarning
              ? CupertinoColors.systemOrange
              : (isDark ? Colors.white54 : Colors.black54),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isWarning
                ? CupertinoColors.systemOrange
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    ],
  );
}
