import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/models/p2p_call_state.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/p2p_call_controller.dart';

import 'widgets/chat_surface.dart';
import 'widgets/incoming_call_modal.dart';
import 'widgets/settings_panel.dart';

class P2PCallPage extends StatefulWidget {
  final String? targetAccountId;

  const P2PCallPage({super.key, this.targetAccountId});

  @override
  State<P2PCallPage> createState() => _P2PCallPageState();
}

class _P2PCallPageState extends State<P2PCallPage>
    with TickerProviderStateMixin, LivingPageMixin {
  late final P2PCallController _controller;
  final TextEditingController _chatInputController = TextEditingController();

  late final TextEditingController _wsUrlController;
  late final TextEditingController _stunController;
  late final TextEditingController _turnController;
  late final TextEditingController _turnUserController;
  late final TextEditingController _turnPassController;

  bool _showSettings = false;
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    initLivingPage();
    _controller = Modular.get<P2PCallController>();

    _wsUrlController =
        TextEditingController(text: 'wss://p2ptest1.duckdns.org/ws');
    _stunController =
        TextEditingController(text: 'stun:stun.l.google.com:19302');
    _turnController =
        TextEditingController(text: 'turn:p2ptest1.duckdns.org:3478');
    _turnUserController = TextEditingController(text: 'myuser');
    _turnPassController = TextEditingController(text: 'mypassword');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure signaling is connected (no-op if already connected)
      if (_controller.state.status == P2PCallStatus.idle) {
        await _controller.connectSignaling(wsUrl: _wsUrlController.text);
      }
      // Only auto-call if navigated from another user's profile
      if (widget.targetAccountId != null &&
          widget.targetAccountId!.isNotEmpty) {
        await _controller.requestCall(widget.targetAccountId!);
      }
    });
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _wsUrlController.dispose();
    _stunController.dispose();
    _turnController.dispose();
    _turnUserController.dispose();
    _turnPassController.dispose();
    disposeLivingPage();
    super.dispose();
  }

  void _handleReconnect() {
    setState(() => _showSettings = false);
    _controller.disconnectAll().then((_) {
      _controller.connectSignaling(wsUrl: _wsUrlController.text);
    });
  }

  void _handleSendChat() {
    final text = _chatInputController.text.trim();
    if (text.isNotEmpty) {
      _controller.sendChatMessage(text);
      _chatInputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    ensureParticles(screenSize, 15, icons: [
      CupertinoIcons.infinite,
      CupertinoIcons.phone_fill,
      CupertinoIcons.bolt_fill,
    ]);

    return Scaffold(
      body: StreamBuilder<P2PCallState>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          final state = _controller.state;

          return Stack(
            children: [
              // Layer 1: Animated background
              buildLivingBackground(
                controller: bgController,
                particles: particles,
                screenSize: screenSize,
                isDark: isDark,
              ),

              // Layer 2: Centered mobile-first container
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(44),
                    child: Stack(
                      children: [
                        // Main video canvas (Remote Feed)
                        _buildMainVideoFeed(
                            _controller.remoteRenderer, isDark),

                        // PiP local video (top-right)
                        _buildPiPVideoFeed(
                            _controller.localRenderer, isDark),

                        // Chat surface overlay (bottom area)
                        if (_showChat)
                          Positioned(
                            bottom: 110,
                            left: 16,
                            right: 16,
                            child: ChatSurface(
                              messages: state.chatMessages,
                              isDark: isDark,
                              textController: _chatInputController,
                              onSend: _handleSendChat,
                            ),
                          ),

                        // Top status panel (Dynamic Island style)
                        _buildTopStatusPanel(state, isDark),

                        // Bottom call controls
                        _buildBottomControls(state, isDark),
                      ],
                    ),
                  ),
                ),
              ),

              // Settings panel (overlays everything)
              P2PSettingsPanel(
                isDark: isDark,
                isOpen: _showSettings,
                wsUrlController: _wsUrlController,
                stunController: _stunController,
                turnController: _turnController,
                turnUserController: _turnUserController,
                turnPassController: _turnPassController,
                onReconnect: _handleReconnect,
              ),

              // Incoming call modal
              if (state.status == P2PCallStatus.incomingCall)
                Positioned.fill(
                  child: IncomingCallModal(
                    callerAccountId: state.remoteUserId,
                    onAccept: () => _controller.acceptCall(),
                    onReject: () => _controller.rejectCall(),
                  ),
                ),

              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _controller.hangUp();
                    Navigator.of(context).maybePop();
                  },
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Full-screen remote video ---
  Widget _buildMainVideoFeed(RTCVideoRenderer renderer, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
      ),
      child: Stack(
        children: [
          if (renderer.srcObject != null)
            RTCVideoView(
              renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Center(
              child: Icon(
                CupertinoIcons.videocam_fill,
                size: 80,
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
              ),
            ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Remote Feed',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PiP local video (top-right) ---
  Widget _buildPiPVideoFeed(RTCVideoRenderer renderer, bool isDark) {
    return Positioned(
      top: 130,
      right: 20,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? Colors.black45
              : Colors.white.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: renderer.srcObject != null
                ? RTCVideoView(
                    renderer,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Center(
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 32,
                      color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.24),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // --- Dynamic Island-style top status ---
  Widget _buildTopStatusPanel(P2PCallState state, bool isDark) {
    final isOnline = state.status == P2PCallStatus.connected ||
        state.status == P2PCallStatus.registered;

    return Positioned(
      top: 30,
      left: 20,
      right: 20,
      child: Center(
        child: _glassCapsule(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusDot(isOnline),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _statusText(state),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => setState(() => _showChat = !_showChat),
                child: Icon(
                  CupertinoIcons.chat_bubble_fill,
                  size: 18,
                  color: _showChat
                      ? CupertinoColors.activeBlue
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () =>
                    setState(() => _showSettings = !_showSettings),
                child: Icon(
                  CupertinoIcons.settings,
                  size: 18,
                  color: _showSettings
                      ? CupertinoColors.activeBlue
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
          isDark: isDark,
        ),
      ),
    );
  }

  // --- Bottom call controls ---
  Widget _buildBottomControls(P2PCallState state, bool isDark) {
    final inCall = state.status == P2PCallStatus.connected ||
        state.status == P2PCallStatus.negotiating ||
        state.status == P2PCallStatus.calling;

    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Center(
        child: _glassCapsule(
          height: 72,
          padding: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleToggle(
                CupertinoIcons.mic_fill,
                !state.audioEnabled,
                inCall
                    ? () {
                        HapticFeedback.lightImpact();
                        _controller.toggleAudio();
                      }
                    : null,
                isDark,
              ),
              _circleToggle(
                CupertinoIcons.video_camera_solid,
                !state.videoEnabled,
                inCall
                    ? () {
                        HapticFeedback.lightImpact();
                        _controller.toggleVideo();
                      }
                    : null,
                isDark,
              ),
              _circleToggle(
                CupertinoIcons.desktopcomputer,
                state.isScreenSharing,
                inCall
                    ? () {
                        HapticFeedback.lightImpact();
                        _controller.toggleScreenShare();
                      }
                    : null,
                isDark,
              ),
              GestureDetector(
                onTap: inCall
                    ? () {
                        HapticFeedback.heavyImpact();
                        _controller.hangUp();
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: inCall
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemRed
                            .withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.phone_down_fill,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          isDark: isDark,
        ),
      ),
    );
  }

  // --- Utility widgets ---

  Widget _glassCapsule({
    required Widget child,
    required bool isDark,
    double height = 56,
    double padding = 16,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _circleToggle(
      IconData icon, bool active, VoidCallback? onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? CupertinoColors.systemRed.withValues(alpha: 0.2)
              : (isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? (isDark ? Colors.white24 : Colors.black26)
              : active
                  ? CupertinoColors.systemRed
                  : (isDark ? Colors.white : Colors.black87),
          size: 22,
        ),
      ),
    );
  }

  Widget _statusDot(bool online) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: online
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: online ? Colors.greenAccent : Colors.redAccent,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  String _statusText(P2PCallState state) {
    switch (state.status) {
      case P2PCallStatus.idle:
        return 'Offline';
      case P2PCallStatus.connecting:
        return 'Connecting...';
      case P2PCallStatus.registered:
        return 'Secure P2P Channel';
      case P2PCallStatus.calling:
        return 'Calling...';
      case P2PCallStatus.incomingCall:
        return 'Incoming call...';
      case P2PCallStatus.negotiating:
        return 'Establishing...';
      case P2PCallStatus.connected:
        return 'Connected';
      case P2PCallStatus.disconnected:
        return 'Disconnected';
      case P2PCallStatus.failed:
        return 'Connection Failed';
    }
  }
}
