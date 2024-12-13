import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/apis/models/private_key_info.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/subpages/key_manager/key_manager_page.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';

class ActivateAccountDialog extends StatefulWidget {
  const ActivateAccountDialog({super.key});

  @override
  State<ActivateAccountDialog> createState() => _ActivateAccountDialogState();
}

class _ActivateAccountDialogState extends State<ActivateAccountDialog> {
  final AuthController authController = Modular.get<AuthController>();

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
                      "Activate account",
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
                                  "To use NEAR Social you need to activate your account. For it provide us your "),
                          TextSpan(
                              text: "Full Access Key",
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
                    StreamBuilder(
                      stream: authController.stream,
                      builder: (context, snapshot) {
                        if (authController.state.additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= authController
                              .state.additionalStoredKeys.values
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
                                items: authController
                                    .state.additionalStoredKeys.entries
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
                                          final privateKey = await Modular.get<
                                                  NearBlockChainService>()
                                              .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
                                                  selectedKey!.privateKey
                                                      .split(":")
                                                      .last);
                                          await Modular.get<NearSocialApi>()
                                              .depositToStorage(
                                            accountId:
                                                authController.state.accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: privateKey,
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
                                      child: const Text(
                                        "Activate",
                                        style: TextStyle(
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
                              Navigator.of(Modular.routerDelegate.navigatorKey
                                      .currentContext!)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("Add Key"),
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
                      "Account Activated!",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        Modular.to.pop();
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(
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

class BuyStorageDialog extends StatefulWidget {
  const BuyStorageDialog({super.key});

  @override
  State<BuyStorageDialog> createState() => _BuyStorageDialogState();
}

class _BuyStorageDialogState extends State<BuyStorageDialog> {
  final AuthController authController = Modular.get<AuthController>();
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
                      "Lack of storage space!",
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
                                  "To continue use NEAR Social you need to buy some storage space. For it provide us your "),
                          TextSpan(
                              text: "Full Access Key",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " from NEAR Wallet to make transaction."),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    StreamBuilder(
                      stream: authController.stream,
                      builder: (context, snapshot) {
                        if (authController.state.additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= authController
                              .state.additionalStoredKeys.values
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
                                items: authController
                                    .state.additionalStoredKeys.entries
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
                                          final privateKey = await Modular.get<
                                                  NearBlockChainService>()
                                              .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
                                                  selectedKey!.privateKey
                                                      .split(":")
                                                      .last);
                                          await Modular.get<NearSocialApi>()
                                              .depositToStorage(
                                            accountId:
                                                authController.state.accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: privateKey,
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
                                      child: const Text(
                                        "Buy storage space",
                                        style: TextStyle(
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
                              Navigator.of(Modular.routerDelegate.navigatorKey
                                      .currentContext!)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("Add Key"),
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
                      "Storage space successfully bought!",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        Modular.to.pop();
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(
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

class WithdrawStorageDialog extends StatefulWidget {
  const WithdrawStorageDialog({super.key});

  @override
  State<WithdrawStorageDialog> createState() => _WithdrawStorageDialogState();
}

class _WithdrawStorageDialogState extends State<WithdrawStorageDialog> {
  final AuthController authController = Modular.get<AuthController>();
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
                      "Withdraw storage space?",
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
                                  "You can withdraw your remaining storage space back to NEAR. For it provide us your "),
                          TextSpan(
                              text: "Full Access Key",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " from NEAR Wallet to make transaction."),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    StreamBuilder(
                      stream: authController.stream,
                      builder: (context, snapshot) {
                        if (authController.state.additionalStoredKeys.values
                            .any(
                          (keyInfo) {
                            return keyInfo.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        )) {
                          selectedKey ??= authController
                              .state.additionalStoredKeys.values
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
                                items: authController
                                    .state.additionalStoredKeys.entries
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
                                          final privateKey = await Modular.get<
                                                  NearBlockChainService>()
                                              .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
                                                  selectedKey!.privateKey
                                                      .split(":")
                                                      .last);
                                          await Modular.get<NearSocialApi>()
                                              .withdrawFromStorage(
                                            accountId:
                                                authController.state.accountId,
                                            publicKey: selectedKey!.publicKey,
                                            privateKey: privateKey,
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
                                      child: const Text(
                                        "Withdraw",
                                        style: TextStyle(
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
                              Navigator.of(Modular.routerDelegate.navigatorKey
                                      .currentContext!)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const KeyManagerPage();
                                  },
                                ),
                              );
                            },
                            child: Text("Add Key"),
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
                      "Storage withdrawn successfully!",
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
                        Modular.to.pop();
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(
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
