// ignore_for_file: use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/home/apis/models/post.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({
    super.key,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog>
    with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  Uint8List? imageData;
  bool _isSending = false;

  late final AnimationController _bgController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();
  List<BackgroundParticle> _particles = [];
  Size _lastSize = Size.zero;

  @override
  void dispose() {
    _textEditingController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<bool?> _askIfToLeave(bool isDark) async {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Discard post?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your draft will not be saved.',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Modular.to.pop(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Keep editing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Modular.to.pop(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.red
                                    .withValues(alpha: isDark ? 0.3 : 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  'Discard',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.red.shade300,
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Future<void> _sendPost(bool isDark) async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      HapticFeedback.lightImpact();
      final nearSocialApi = Modular.get<NearSocialApi>();
      final AuthController authController = Modular.get<AuthController>();

      final String accountId = authController.state.accountId;
      final String publicKey = authController.state.publicKey;
      final String privateKey = authController.state.privateKey;

      String? cidOfMedia;
      if (imageData != null) {
        cidOfMedia = await nearSocialApi.uploadFileToNearFileHosting(
          imageData: imageData!,
        );
      }

      final PostBody postBody = PostBody(
        text: _textEditingController.text,
        mediaLink: cidOfMedia,
      );

      if (postBody.text == "" && postBody.mediaLink == null) {
        throw Exception("Empty text and mediaLink");
      }

      if (await authController.getActivationStatus() !=
          AccountActivationStatus.activated) {
        throw AccountNotActivatedException();
      }

      nearSocialApi
          .createPost(
        accountId: accountId,
        publicKey: publicKey,
        privateKey: privateKey,
        postBody: PostBody(
          text: _textEditingController.text,
          mediaLink: cidOfMedia,
        ),
      )
          .then((_) {
        Future.delayed(const Duration(seconds: 10), () {
          Modular.get<PostsController>()
              .loadPosts(postsViewMode: PostsViewMode.main);
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text("Your post will be added soon."),
        ),
      );
      Modular.to.pop();
    } catch (err) {
      setState(() => _isSending = false);
      if (err.toString().contains('Not enough storage balance')) {
        throw NotEnoughStorageBalanceException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
          8,
          (i) => BackgroundParticle(screenSize,
              icons: [CupertinoIcons.pencil, CupertinoIcons.photo]));
      _lastSize = screenSize;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (imageData == null && _textEditingController.text.isEmpty) {
          Modular.to.pop();
        } else {
          _askIfToLeave(isDark).then((value) {
            if (value == true) Modular.to.pop();
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            buildLivingBackground(
              controller: _bgController,
              particles: _particles,
              screenSize: screenSize,
              isDark: isDark,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (imageData == null &&
                                _textEditingController.text.isEmpty) {
                              Modular.to.pop();
                            } else {
                              _askIfToLeave(isDark).then((value) {
                                if (value == true) Modular.to.pop();
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 18,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'New Post',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        // Send button
                        GestureDetector(
                          onTap: _isSending ? null : () => _sendPost(isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSending
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03))
                                  : (isDark ? Colors.white : Colors.black),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _isSending
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black38,
                                    ),
                                  )
                                : Text(
                                    'Post',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color:
                                          isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Text input area
                    Expanded(
                      child: GlassContainer(
                        isDark: isDark,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                            height: 1.5,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Media section
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final ImagePicker picker = ImagePicker();
                            final XFile? file = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (file == null) return;
                            file.readAsBytes().then((value) {
                              setState(() => imageData = value);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.photo,
                                    size: 20,
                                    color:
                                        isDark ? Colors.white70 : Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  'Add media',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (imageData != null) ...[
                          const SizedBox(width: 12),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  imageData!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => imageData = null);
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(CupertinoIcons.xmark,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
