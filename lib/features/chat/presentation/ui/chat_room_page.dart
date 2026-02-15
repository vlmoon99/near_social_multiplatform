import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_state.dart';
import 'package:near_social_mobile/features/chat/presentation/logic/chat_events.dart';
import 'package:near_social_mobile/features/chat/presentation/providers/chat_controller.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.targetAccountId});

  final String targetAccountId;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late AnimationController _bgController;
  late List<BackgroundParticle> _particles;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatState = ref.read(chatControllerProvider);
      if (chatState.remotePeerId != widget.targetAccountId ||
          chatState.peerStatus == PeerConnectionStatus.disconnected) {
        ref.read(chatControllerProvider.notifier).onEvent(
              StartChatEvent(targetAccountId: widget.targetAccountId),
            );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyAccountId(String accountId) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: accountId));
    showAppToast(context, 'people.account_id_copied'.tr(namedArgs: {'accountId': accountId}));
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isInCall = chatState.peerStatus == PeerConnectionStatus.inCall;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(12, (i) => BackgroundParticle(screenSize));
      _lastSize = screenSize;
    }

    // Auto-scroll on new messages
    ref.listen(chatControllerProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Living background
          buildLivingBackground(
            controller: _bgController,
            particles: _particles,
            screenSize: screenSize,
            isDark: isDark,
          ),

          // Video views when in call
          if (isInCall) ...[
            if (controller.remoteRenderer != null)
              Positioned.fill(
                child: RTCVideoView(
                  controller.remoteRenderer!,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            if (controller.localRenderer != null && chatState.isVideoEnabled)
              Positioned(
                top: 100,
                right: 16,
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RTCVideoView(
                    controller.localRenderer!,
                    mirror: true,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
          ],

          // Main chat content
          if (!isInCall)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      _buildTopBar(chatState, controller, isDark),

                      // Messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.messages[index];
                            return _buildMessageBubble(
                                msg.text, msg.isMe, isDark);
                          },
                        ),
                      ),

                      // Input bar
                      _buildInputBar(controller, isDark, chatState),
                    ],
                  ),
                ),
              ),
            ),

          // Call controls overlay
          if (isInCall)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: _buildCallControls(chatState, controller),
                ),
              ),
            ),

          // Floating top bar during call
          if (isInCall)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: buildGlassBar(
                  360,
                  Row(
                    children: [
                      TappableScaleWidget(
                        scaleDown: AppAnimations.navButtonScaleDown,
                        onTap: () => Navigator.of(context).pop(),
                        child: buildCircleIcon(CupertinoIcons.back, isDark),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _copyAccountId(widget.targetAccountId),
                        child: Text(
                          widget.targetAccountId,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 32),
                    ],
                  ),
                  isDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      ChatState chatState, ChatController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          TappableScaleWidget(
            scaleDown: AppAnimations.navButtonScaleDown,
            onTap: () => Navigator.of(context).pop(),
            child: buildCircleIcon(CupertinoIcons.back, isDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _copyAccountId(widget.targetAccountId),
                  child: Text(
                    widget.targetAccountId,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  chatState.peerStatus == PeerConnectionStatus.connected
                      ? 'chat.connected'.tr()
                      : chatState.peerStatus == PeerConnectionStatus.connecting
                          ? 'chat.connecting'.tr()
                          : 'chat.disconnected'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          TappableScaleWidget(
            scaleDown: AppAnimations.navButtonScaleDown,
            onTap: () {
              controller.onEvent(StartCallEvent(
                targetAccountId: widget.targetAccountId,
                video: false,
              ));
            },
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.phone_fill,
                color: CupertinoColors.activeGreen,
                size: 22,
              ),
            ),
          ),
          TappableScaleWidget(
            scaleDown: AppAnimations.navButtonScaleDown,
            onTap: () {
              controller.onEvent(StartCallEvent(
                targetAccountId: widget.targetAccountId,
                video: true,
              ));
            },
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.video_camera_solid,
                color: CupertinoColors.activeBlue,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? CupertinoColors.activeBlue.withValues(alpha: 0.25)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.65)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMe
                      ? CupertinoColors.activeBlue.withValues(alpha: 0.3)
                      : (isDark ? Colors.white10 : Colors.white70),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(
      ChatController controller, bool isDark, ChatState chatState) {
    final canSend = chatState.peerStatus == PeerConnectionStatus.connected ||
        chatState.peerStatus == PeerConnectionStatus.inCall;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _messageController,
                    placeholder: 'chat.type_message'.tr(),
                    placeholderStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    onSubmitted:
                        canSend ? (_) => _sendMessage(controller) : null,
                  ),
                ),
                TappableScaleWidget(
                  scaleDown: AppAnimations.navButtonScaleDown,
                  onTap: canSend ? () => _sendMessage(controller) : () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canSend
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey,
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage(ChatController controller) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    controller.onEvent(SendMessageEvent(text: text));
    _messageController.clear();
  }

  Widget _buildCallControls(ChatState chatState, ChatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _callControlButton(
                  icon: chatState.isAudioEnabled
                      ? CupertinoIcons.mic_fill
                      : CupertinoIcons.mic_off,
                  color: chatState.isAudioEnabled
                      ? Colors.white
                      : CupertinoColors.systemRed,
                  onTap: () => controller.onEvent(ToggleAudioEvent()),
                ),
                _callControlButton(
                  icon: chatState.isVideoEnabled
                      ? CupertinoIcons.video_camera_solid
                      : CupertinoIcons.video_camera,
                  color: chatState.isVideoEnabled
                      ? Colors.white
                      : CupertinoColors.systemGrey,
                  onTap: () => controller.onEvent(ToggleVideoEvent()),
                ),
                _callControlButton(
                  icon: CupertinoIcons.desktopcomputer,
                  color: chatState.isScreenSharing
                      ? CupertinoColors.activeBlue
                      : Colors.white,
                  onTap: () {
                    if (chatState.isScreenSharing) {
                      controller.onEvent(StopScreenShareEvent());
                    } else {
                      controller.onEvent(StartScreenShareEvent());
                    }
                  },
                ),
                _callControlButton(
                  icon: CupertinoIcons.phone_down_fill,
                  color: CupertinoColors.systemRed,
                  onTap: () => controller.onEvent(EndCallEvent()),
                  isEndCall: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _callControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return TappableScaleWidget(
      scaleDown: AppAnimations.navButtonScaleDown,
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEndCall
              ? CupertinoColors.systemRed.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
