import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/no_full_access_key.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/core/utils/show_confirm_action_dialog.dart';
import 'package:near_social_mobile/core/utils/show_success_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';

class DonationDialog extends ConsumerStatefulWidget {
  const DonationDialog({super.key, required this.receiverId});
  final String receiverId;

  @override
  ConsumerState<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends ConsumerState<DonationDialog> {
  final formKey = GlobalKey<FormState>();
  String? balance;

  late final bool fullAccessKeyAvailable;
  PrivateKeyInfo? selectedKey;

  final TextEditingController _amountTextEditingController =
      TextEditingController()..text = "0.1";

  bool transactionLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    fullAccessKeyAvailable =
        authState.additionalStoredKeys.values.any(
      (storedKey) =>
          storedKey.privateKeyTypeInfo.type == PrivateKeyType.FullAccess,
    );

    if (fullAccessKeyAvailable) {
      selectedKey = authState.additionalStoredKeys.values.firstWhere(
        (storedKey) =>
            storedKey.privateKeyTypeInfo.type == PrivateKeyType.FullAccess,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      updateBalance();
    });
  }

  Future<void> updateBalance() async {
    final authState = ref.read(authControllerProvider);
    final actualBalance = await ref.read(nearRpcServiceProvider)
        .getWalletBalance(authState.accountId);
    if (!mounted) {
      return;
    }
    if (balance != null && balance == actualBalance) {
      await Future.delayed(const Duration(seconds: 3));
      updateBalance();
      return;
    }
    setState(() {
      balance = actualBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !transactionLoading,
      child: Dialog(
        insetPadding: REdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16).r,
          child: !fullAccessKeyAvailable
              ? const NoFullAccessKeyBannerBody()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Donating to ${widget.receiverId}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    const Text(
                      "Select a key to donate: ",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<PrivateKeyInfo>(
                        isExpanded: true,
                        value: selectedKey,
                        onChanged: (newKey) {
                          if (newKey == null || transactionLoading) return;
                          setState(() {
                            selectedKey = newKey;
                          });
                        },
                        items: ref.read(authControllerProvider).additionalStoredKeys.entries
                            .where(
                          (storedKey) {
                            return storedKey.value.privateKeyTypeInfo.type ==
                                PrivateKeyType.FullAccess;
                          },
                        ).map((keyInfo) {
                          return DropdownMenuItem<PrivateKeyInfo>(
                            alignment: Alignment.center,
                            value: keyInfo.value,
                            child: Text(
                              keyInfo.key,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    const Text(
                      "Amount to donate: ",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Container(
                        padding: const EdgeInsets.all(10).r,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10).r,
                        ),
                        child: TextFormField(
                          readOnly: transactionLoading,
                          style: const TextStyle(fontSize: 15),
                          controller: _amountTextEditingController,
                          decoration: InputDecoration.collapsed(
                            hintText: "people.amount".tr(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          onTapOutside: (event) {
                            if (WidgetsBinding
                                    .instance.window.viewInsets.bottom !=
                                0) {
                              return;
                            }
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 15),
                        children: [
                          const TextSpan(text: "You have "),
                          balance != null
                              ? TextSpan(text: balance)
                              : const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: SpinnerLoadingIndicator(size: 12),
                                ),
                          const TextSpan(text: " NEAR"),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    const Text(
                      "Service fee: ${EnterpriseVariables.amountOfServiceFeeForDonation} NEAR",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    if (transactionLoading)
                      const Align(
                        alignment: Alignment.center,
                        child: SpinnerLoadingIndicator(),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          primary: true,
                          onPressed: () async {
                            HapticFeedback.lightImpact();

                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final amountToSpend = double.parse(
                                  _amountTextEditingController.text,
                                ) +
                                double.parse(EnterpriseVariables
                                    .amountOfServiceFeeForDonation);

                            if (!await askToConfirmAction(
                              context,
                              title: "people.donate_confirm".tr(),
                              content:
                                  "You will spend ${amountToSpend.toStringAsFixed(5)} NEAR to donate to ${widget.receiverId}",
                            )) {
                              return;
                            }

                            setState(() {
                              transactionLoading = true;
                            });

                            final nearSocialApiService =
                                ref.read(nearSocialApiProvider);
                            final account = ref.read(authControllerProvider);
                            final privateKey = selectedKey!.privateKey;

                            try {
                              final txHash =
                                  await nearSocialApiService.donateToAccount(
                                accountId: account.accountId,
                                publicKey: account.publicKey,
                                privateKey: privateKey,
                                amountToSend: _amountTextEditingController.text,
                                receiverId: widget.receiverId,
                              );
                              showSuccessDialog(
                                context,
                                title: "people.donate_success".tr(),
                                txHash: txHash,
                              );
                            } catch (err) {
                              rethrow;
                            } finally {
                              setState(() {
                                transactionLoading = false;
                              });
                            }

                            updateBalance();
                          },
                          child: const Text(
                            "Donate",
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
