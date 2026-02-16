import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_state.dart';
import 'package:near_social_mobile/features/chat/presentation/providers/chat_controller.dart';
import 'package:near_social_mobile/features/chat/presentation/ui/widgets/chat_security_info_dialog.dart';
import 'package:near_social_mobile/features/chat/presentation/ui/widgets/incoming_call_dialog.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/tee_attestation_badge.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _peerIdController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  @override
  void dispose() {
    _peerIdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chatState = ref.watch(chatControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show incoming call dialog
    ref.listen(chatControllerProvider, (prev, next) {
      if (next.incomingCallFrom != null && prev?.incomingCallFrom == null) {
        showIncomingCallDialog(context, ref, next.incomingCallFrom!);
      }
    });

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 90)),

            // Connection status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chatState.signalingConnected
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chatState.signalingConnected
                          ? 'chat.connected'.tr()
                          : 'chat.disconnected'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    const TeeAttestationBadge(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => showChatSecurityInfoDialog(context),
                      child: Icon(
                        CupertinoIcons.lock_shield_fill,
                        size: 18,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Start chat input
            SliverToBoxAdapter(
              child: GlassContainer(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CupertinoTextField(
                      controller: _peerIdController,
                      placeholder: 'chat.enter_account_id'.tr(),
                      placeholderStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      onPressed: chatState.signalingConnected
                          ? () {
                              final targetId = _peerIdController.text.trim();
                              if (targetId.isEmpty) return;
                              context.push(
                                '${AppRoutes.chatRoom}?targetAccountId=$targetId',
                              );
                            }
                          : null,
                      child: Text('chat.start_chat'.tr()),
                    ),
                  ],
                ),
              ),
            ),

            // Active chat indicator
            if (chatState.remotePeerId.isNotEmpty &&
                chatState.peerStatus != PeerConnectionStatus.disconnected)
              SliverToBoxAdapter(
                child: GlassContainer(
                  isDark: isDark,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push(
                        '${AppRoutes.chatRoom}?targetAccountId=${chatState.remotePeerId}',
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.chat_bubble_2_fill,
                          color: CupertinoColors.activeBlue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Clipboard.setData(
                                    ClipboardData(text: chatState.remotePeerId),
                                  );
                                  showAppToast(context, 'people.account_id_copied'.tr(namedArgs: {'accountId': chatState.remotePeerId}));
                                },
                                child: Text(
                                  chatState.remotePeerId,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                chatState.peerStatus.name,
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Empty state
            if (chatState.remotePeerId.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'chat.no_chats'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}
