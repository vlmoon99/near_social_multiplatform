import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class P2PSettingsPanel extends StatelessWidget {
  final bool isDark;
  final bool isOpen;
  final TextEditingController wsUrlController;
  final TextEditingController stunController;
  final TextEditingController turnController;
  final TextEditingController turnUserController;
  final TextEditingController turnPassController;
  final VoidCallback onReconnect;

  const P2PSettingsPanel({
    super.key,
    required this.isDark,
    required this.isOpen,
    required this.wsUrlController,
    required this.stunController,
    required this.turnController,
    required this.turnUserController,
    required this.turnPassController,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      top: isOpen ? 120 : -500,
      left: 0,
      right: 0,
      child: Center(
      child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIGNALING & ICE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildField('WS URL', wsUrlController),
                const SizedBox(height: 8),
                _buildField('STUN', stunController),
                const SizedBox(height: 8),
                _buildField('TURN', turnController),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildField('User', turnUserController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField('Pass', turnPassController)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: onReconnect,
                    child: const Text('Reconnect'),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }
}
