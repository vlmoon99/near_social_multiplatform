import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class AccessKeyInfoCard extends ConsumerWidget {
  const AccessKeyInfoCard({
    super.key,
    required this.keyName,
    required this.privateKeyInfo,
    this.removeAble = true,
  });

  final String keyName;
  final PrivateKeyInfo privateKeyInfo;
  final bool removeAble;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0).r,
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          keyName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text.rich(
                          style: const TextStyle(fontSize: 15),
                          TextSpan(children: [
                            TextSpan(
                              text: "key_manager.type".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: privateKeyInfo.privateKeyTypeInfo.type ==
                                      PrivateKeyType.FunctionCall
                                  ? "key_manager.function_call".tr()
                                  : "key_manager.full_access".tr(),
                            )
                          ])),
                      SizedBox(height: 5.h),
                      Text.rich(
                        style: const TextStyle(fontSize: 15),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "key_manager.private_key".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            WidgetSpan(
                              child: SelectableText(
                                privateKeyInfo.privateKey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (privateKeyInfo.privateKeyTypeInfo.receiverId !=
                          null) ...[
                        SizedBox(height: 5.h),
                        Text.rich(
                            style: const TextStyle(fontSize: 15),
                            TextSpan(children: [
                              TextSpan(
                                text: "key_manager.receiver_id".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${privateKeyInfo.privateKeyTypeInfo.receiverId}",
                              )
                            ])),
                      ],
                      if (privateKeyInfo.privateKeyTypeInfo.methodNames !=
                              null &&
                          privateKeyInfo
                              .privateKeyTypeInfo.methodNames!.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text.rich(
                            style: const TextStyle(fontSize: 15),
                            TextSpan(children: [
                              TextSpan(
                                text: "key_manager.method_names".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${privateKeyInfo.privateKeyTypeInfo.methodNames}",
                              )
                            ])),
                      ],
                      if (removeAble) ...[
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            primary: true,
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "key_manager.remove_key_confirm".tr(),
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      CustomButton(
                                        primary: true,
                                        onPressed: () async {
                                          ref.read(authControllerProvider.notifier)
                                              .removeAccessKey(
                                                  accessKeyName: keyName);
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text("key_manager.remove".tr(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: NEARColors.red)),
                                      ),
                                      CustomButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(
                                          "common.cancel".tr(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ).then(
                                (removed) {
                                  if (removed) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            },
                            child: Text(
                              "key_manager.remove_key".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10).r,
                width: 40.h,
                height: 40.h,
                decoration: BoxDecoration(
                  color: NEARColors.black,
                  borderRadius: BorderRadius.circular(10).r,
                ),
                child: SvgPicture.asset(
                  "assets/media/icons/key-icon.svg",
                  color: privateKeyInfo.privateKeyTypeInfo.type ==
                          PrivateKeyType.FunctionCall
                      ? NEARColors.grey
                      : NEARColors.gold,
                ),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      privateKeyInfo.privateKeyTypeInfo.type ==
                              PrivateKeyType.FunctionCall
                          ? "key_manager.function_call".tr()
                          : "key_manager.full_access".tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
