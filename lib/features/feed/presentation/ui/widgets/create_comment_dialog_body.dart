// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';

class CreateCommentDialog extends ConsumerStatefulWidget {
  const CreateCommentDialog({
    super.key,
    required this.post,
    required this.descriptionTitle,
    this.initialText = "",
    required this.postsViewMode,
    this.postsOfAccountId,
  });

  final Post post;
  final Widget descriptionTitle;
  final String initialText;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;

  @override
  ConsumerState<CreateCommentDialog> createState() => _CreateCommentDialogState();
}

class _CreateCommentDialogState extends ConsumerState<CreateCommentDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.initialText;
  }

  Future<bool?> askIfToLeave() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("feed.exit_confirm".tr(),
            textAlign: TextAlign.left, style: const TextStyle(fontSize: 22)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        content: Text("feed.comment_not_saved".tr(),
            style: const TextStyle(fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          CustomButton(
            primary: true,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              "Yes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              "No",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (imageData == null && _textEditingController.text.isEmpty) {
          Navigator.of(context).pop();
        } else {
          askIfToLeave().then(
            (value) {
              if (value == true) {
                Navigator.of(context).pop();
              }
            },
          );
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            (MediaQuery.of(context).padding.top + kToolbarHeight),
        child: RPadding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.descriptionTitle,
              SizedBox(height: 5.h),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10).r,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10).r,
                  ),
                  child: TextField(
                    controller: _textEditingController,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                      hintText: "feed.write_comment_here".tr(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      primary: true,
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? file =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (file == null) {
                          return;
                        }

                        file.readAsBytes().then((value) {
                          setState(() {
                            imageData = value;
                          });
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 5.h),
                          const Text(
                            "Add media",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    if (imageData != null)
                      SizedBox(
                        width: 60.h,
                        height: 60.h,
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 50.h,
                              width: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10).r,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.memory(
                                imageData!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SizedBox(
                                width: 30.h,
                                height: 30.h,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      imageData = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, color: Colors.red, size: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    primary: true,
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final nearSocialApi = ref.read(nearSocialApiProvider);
                      final authState = ref.read(authControllerProvider);
                      final authController = ref.read(authControllerProvider.notifier);
                      final String accountId = authState.accountId;
                      final String publicKey = authState.accountPublicKey;
                      final String privateKey = authState.devicePrivateKey;

                      String? cidOfMedia;
                      if (imageData != null) {
                        cidOfMedia =
                            await nearSocialApi.uploadFileToNearFileHosting(
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

                      try {
                        if (await authController.getActivationStatus() !=
                            AccountActivationStatus.activated) {
                          throw AccountNotActivatedException();
                        }
                        nearSocialApi
                            .commentThePost(
                          accountIdOfPost: widget.post.authorInfo.accountId,
                          blockHeight: widget.post.blockHeight,
                          accountId: accountId,
                          publicKey: publicKey,
                          privateKey: privateKey,
                          postBody: postBody,
                        )
                            .then(
                          (_) {
                            //we have to wait a little to update comments
                            Future.delayed(const Duration(seconds: 10), () {
                              ref.read(postsControllerProvider.notifier)
                                  .updateCommentsOfPost(
                                accountId: widget.post.authorInfo.accountId,
                                blockHeight: widget.post.blockHeight,
                                postsViewMode: widget.postsViewMode,
                                postsOfAccountId: widget.postsOfAccountId,
                              );
                            });
                          },
                        );
                        showAppToast(context, "feed.comment_added_soon".tr());
                        Navigator.of(context).pop();
                      } catch (err) {
                        if (err is Exception) {
                          throw Exception("Failed to like comment");
                        } else {
                          rethrow;
                        }
                      }
                    },
                    child: const Text(
                      "Send",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CustomButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (imageData == null &&
                          _textEditingController.text.isEmpty) {
                        Navigator.of(context).pop();
                      } else {
                        askIfToLeave().then(
                          (value) {
                            if (value == true) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
