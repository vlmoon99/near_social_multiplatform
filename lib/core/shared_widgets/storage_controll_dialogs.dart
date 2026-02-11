import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';
import 'package:near_social_mobile/features/key_manager/presentation/ui/key_manager_page.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';

class ActivateAccountDialog extends ConsumerStatefulWidget {
  const ActivateAccountDialog({super.key});

  @override
  ConsumerState<ActivateAccountDialog> createState() => _ActivateAccountDialogState();
}

class _ActivateAccountDialogState extends ConsumerState<ActivateAccountDialog> {

  PrivateKeyInfo? selectedKey;

  bool isLoading = false;
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        insetPadding: REdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: !isDone
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.activate_account".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  "storage.activate_message".tr()),
                          TextSpan(
                              text: "common.full_access_key".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  " from NEAR Wallet to make transaction. It will be cost "),
                          TextSpan(
                            text:
                                "${EnterpriseVariables.accountActivationCost} NEAR.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Builder(
                      builder: (context) {
                        if (ref.watch(authControllerProvider).additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= ref.read(authControllerProvider)
                              .additionalStoredKeys.values
                              .firstWhere(
                            (keyInfo) =>
                                keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess,
                          );
                          return Column(
                            children: [
                              DropdownButton<PrivateKeyInfo>(
                                isExpanded: true,
                                value: selectedKey,
                                onChanged: (newKey) {
                                  if (newKey == null) return;
                                  setState(() {
                                    selectedKey = newKey;
                                  });
                                },
                                items: ref.read(authControllerProvider)
                                    .additionalStoredKeys.entries
                                    .where((element) =>
                                        element.value.privateKeyTypeInfo.type ==
                                        PrivateKeyType.FullAccess)
                                    .map((keyInfo) {
                                  return DropdownMenuItem<PrivateKeyInfo>(
                                    alignment: Alignment.center,
                                    value: keyInfo.value,
                                    child: Text(
                                      keyInfo.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 15.h),
                              isLoading
                                  ? const Align(
                                      alignment: Alignment.center,
                                      child: SpinnerLoadingIndicator(),
                                    )
                                  : CustomButton(
                                      primary: true,
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await ref.read(nearSocialApiProvider)
                                              .depositToStorage(
                                            accountId:
                                                ref.read(authControllerProvider).accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: selectedKey!.privateKey,
                                            amount: EnterpriseVariables
                                                .accountActivationCost,
                                          );
                                          setState(() {
                                            isDone = true;
                                          });
                                        } catch (err) {
                                          rethrow;
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Text(
                                        "storage.activate".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        } else {
                          return CustomButton(
                            primary: true,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("common.add_key".tr()),
                          );
                        }
                      },
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.account_activated".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "common.close".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class BuyStorageDialog extends ConsumerStatefulWidget {
  const BuyStorageDialog({super.key});

  @override
  ConsumerState<BuyStorageDialog> createState() => _BuyStorageDialogState();
}

class _BuyStorageDialogState extends ConsumerState<BuyStorageDialog> {
  final List<double> amountsToBuyInStorage = [0.05, 0.2, 1];
  PrivateKeyInfo? selectedKey;
  late double amountToBuy = amountsToBuyInStorage.first;

  bool isLoading = false;
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        insetPadding: REdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: !isDone
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.lack_of_space".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  "storage.buy_message".tr()),
                          TextSpan(
                              text: "common.full_access_key".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " from NEAR Wallet to make transaction."),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Builder(
                      builder: (context) {
                        if (ref.watch(authControllerProvider).additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= ref.read(authControllerProvider)
                              .additionalStoredKeys.values
                              .firstWhere(
                            (keyInfo) =>
                                keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess,
                          );
                          return Column(
                            children: [
                              DropdownButton<PrivateKeyInfo>(
                                isExpanded: true,
                                value: selectedKey,
                                onChanged: (newKey) {
                                  if (newKey == null) return;
                                  setState(() {
                                    selectedKey = newKey;
                                  });
                                },
                                items: ref.read(authControllerProvider)
                                    .additionalStoredKeys.entries
                                    .where((element) =>
                                        element.value.privateKeyTypeInfo.type ==
                                        PrivateKeyType.FullAccess)
                                    .map((keyInfo) {
                                  return DropdownMenuItem<PrivateKeyInfo>(
                                    alignment: Alignment.center,
                                    value: keyInfo.value,
                                    child: Text(
                                      keyInfo.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10.h),
                              SegmentedButton(
                                style: SegmentedButton.styleFrom(
                                  selectedBackgroundColor: NEARColors.black,
                                  selectedForegroundColor: NEARColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8).r,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 10,
                                  ).r,
                                ),
                                showSelectedIcon: false,
                                segments: amountsToBuyInStorage
                                    .map(
                                      (val) => ButtonSegment<double>(
                                        label: Text(
                                            "$val NEAR (${val * 100} Kb)",
                                            textAlign: TextAlign.center),
                                        value: val,
                                      ),
                                    )
                                    .toList(),
                                selected: {amountToBuy},
                                onSelectionChanged: (segment) {
                                  setState(() {
                                    amountToBuy = segment.first;
                                  });
                                },
                              ),
                              SizedBox(height: 15.h),
                              isLoading
                                  ? const Align(
                                      alignment: Alignment.center,
                                      child: SpinnerLoadingIndicator(),
                                    )
                                  : CustomButton(
                                      primary: true,
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await ref.read(nearSocialApiProvider)
                                              .depositToStorage(
                                            accountId:
                                                ref.read(authControllerProvider).accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: selectedKey!.privateKey,
                                            amount: amountToBuy.toString(),
                                          );
                                          setState(() {
                                            isDone = true;
                                          });
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Text(
                                        "storage.buy_space".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        } else {
                          return CustomButton(
                            primary: true,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("common.add_key".tr()),
                          );
                        }
                      },
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.space_bought".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "common.close".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class WithdrawStorageDialog extends ConsumerStatefulWidget {
  const WithdrawStorageDialog({super.key});

  @override
  ConsumerState<WithdrawStorageDialog> createState() => _WithdrawStorageDialogState();
}

class _WithdrawStorageDialogState extends ConsumerState<WithdrawStorageDialog> {
  final List<double> amountsToBuyInStorage = [0.05, 0.2, 1];
  PrivateKeyInfo? selectedKey;

  bool isLoading = false;
  bool isDone = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        insetPadding: REdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: !isDone
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.withdraw_space".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  "storage.withdraw_message".tr()),
                          TextSpan(
                              text: "common.full_access_key".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " from NEAR Wallet to make transaction."),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Builder(
                      builder: (context) {
                        if (ref.watch(authControllerProvider).additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= ref.read(authControllerProvider)
                              .additionalStoredKeys.values
                              .firstWhere(
                            (keyInfo) =>
                                keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess,
                          );
                          return Column(
                            children: [
                              DropdownButton<PrivateKeyInfo>(
                                isExpanded: true,
                                value: selectedKey,
                                onChanged: (newKey) {
                                  if (newKey == null) return;
                                  setState(() {
                                    selectedKey = newKey;
                                  });
                                },
                                items: ref.read(authControllerProvider)
                                    .additionalStoredKeys.entries
                                    .where((element) =>
                                        element.value.privateKeyTypeInfo.type ==
                                        PrivateKeyType.FullAccess)
                                    .map((keyInfo) {
                                  return DropdownMenuItem<PrivateKeyInfo>(
                                    alignment: Alignment.center,
                                    value: keyInfo.value,
                                    child: Text(
                                      keyInfo.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 15.h),
                              isLoading
                                  ? const Align(
                                      alignment: Alignment.center,
                                      child: SpinnerLoadingIndicator(),
                                    )
                                  : CustomButton(
                                      primary: true,
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await ref.read(nearSocialApiProvider)
                                              .withdrawFromStorage(
                                            accountId:
                                                ref.read(authControllerProvider).accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: selectedKey!.privateKey,
                                          );
                                          setState(() {
                                            isDone = true;
                                          });
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Text(
                                        "storage.withdraw".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        } else {
                          return CustomButton(
                            primary: true,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("common.add_key".tr()),
                          );
                        }
                      },
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "storage.withdrawn_success".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "common.close".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
