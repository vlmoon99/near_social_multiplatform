import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/models/p2p_call_state.dart';

class P2PStatusBar extends StatelessWidget {
  final P2PCallState callState;
  final bool isDark;
  final VoidCallback onSettingsToggle;
  final VoidCallback onChatToggle;

  const P2PStatusBar({
    super.key,
    required this.callState,
    required this.isDark,
    required this.onSettingsToggle,
    required this.onChatToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = callState.status == P2PCallStatus.connected ||
        callState.status == P2PCallStatus.registered;

    return buildGlassBar(
      380,
      Row(
        children: [
          _statusDot(isOnline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onChatToggle,
            child: Icon(
              CupertinoIcons.chat_bubble_fill,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 4),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onSettingsToggle,
            child: Icon(
              CupertinoIcons.settings,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
      isDark,
    );
  }

  String get _statusText {
    switch (callState.status) {
      case P2PCallStatus.idle:
        return 'Offline';
      case P2PCallStatus.connecting:
        return 'Connecting...';
      case P2PCallStatus.registered:
        return 'Secure P2P Channel';
      case P2PCallStatus.calling:
        return 'Calling ${callState.remoteUserId}...';
      case P2PCallStatus.incomingCall:
        return 'Incoming call...';
      case P2PCallStatus.negotiating:
        return 'Establishing connection...';
      case P2PCallStatus.connected:
        return 'Connected - ${callState.remoteUserId}';
      case P2PCallStatus.disconnected:
        return 'Disconnected';
      case P2PCallStatus.failed:
        return 'Connection Failed';
    }
  }

  Widget _statusDot(bool online) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: online
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: online ? Colors.greenAccent : Colors.redAccent,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
