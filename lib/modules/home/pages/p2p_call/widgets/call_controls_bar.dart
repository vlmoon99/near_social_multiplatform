import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/models/p2p_call_state.dart';

class CallControlsBar extends StatelessWidget {
  final P2PCallState callState;
  final bool isDark;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onHangUp;

  const CallControlsBar({
    super.key,
    required this.callState,
    required this.isDark,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onToggleScreenShare,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    final inCall = callState.status == P2PCallStatus.connected ||
        callState.status == P2PCallStatus.negotiating ||
        callState.status == P2PCallStatus.calling;

    return buildGlassBar(
      340,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _controlButton(
            icon: callState.audioEnabled
                ? CupertinoIcons.mic_fill
                : CupertinoIcons.mic_off,
            active: !callState.audioEnabled,
            onPressed: inCall ? onToggleAudio : null,
          ),
          _controlButton(
            icon: callState.videoEnabled
                ? CupertinoIcons.video_camera_solid
                : CupertinoIcons.videocam_fill,
            active: !callState.videoEnabled,
            onPressed: inCall ? onToggleVideo : null,
          ),
          _controlButton(
            icon: CupertinoIcons.desktopcomputer,
            active: callState.isScreenSharing,
            onPressed: inCall ? onToggleScreenShare : null,
          ),
          _hangUpButton(onPressed: inCall ? onHangUp : null),
        ],
      ),
      isDark,
    );
  }

  Widget _controlButton({
    required IconData icon,
    required bool active,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? CupertinoColors.activeBlue
              : (isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onPressed == null
              ? (isDark ? Colors.white24 : Colors.black26)
              : active
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
          size: 20,
        ),
      ),
    );
  }

  Widget _hangUpButton({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: onPressed != null
              ? CupertinoColors.systemRed
              : CupertinoColors.systemRed.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          CupertinoIcons.phone_down_fill,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
