import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/auth/pages/utils/encrypt_data_and_login.dart';
import 'package:near_social_mobile/modules/vms/core/models/authorization_credentials.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_wallet_selector/near_wallet_selector.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) {
      NearWalletSelector().init("mainnet", "social.near").then(
        (_) async {
          final account = await NearWalletSelector().getAccount();
          if (account == null) {
            return;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await encryptDataAndLogin(AuthorizationCredentials(
                account.accountId,
                account.privateKey,
              ));
              Modular.to.navigate(Routes.home.getModule());
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (kIsWeb)
            Row(
              children: [
                CustomButton(
                  primary: true,
                  onPressed: () async {
                    NearWalletSelector().showSelector().then(
                      (hideReason) async {
                        if (hideReason == "user-triggered") {
                          return;
                        }
                        final account = await NearWalletSelector().getAccount();
                        if (account == null) {
                          return;
                        } else {
                          await encryptDataAndLogin(AuthorizationCredentials(
                            account.accountId,
                            account.privateKey,
                          ));
                          Modular.to.navigate(Routes.home.getModule());
                        }
                      },
                    );
                  },
                  child: const Text(
                    "Login with Wallet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                IconButton(
                  onPressed: () async {
                    Modular.to.pushNamed(
                      Routes.auth.getRoute(Routes.auth.qrReader),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: NEARColors.black,
                    foregroundColor: NEARColors.white,
                    disabledForegroundColor: NEARColors.white,
                    disabledBackgroundColor: NEARColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8).r,
                      side: const BorderSide(
                        color: NEARColors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else ...[
            CustomButton(
              primary: true,
              onPressed: () async {
                NearWalletSelector().showSelector().then(
                  (hideReason) async {
                    if (hideReason == "user-triggered") {
                      return;
                    }
                    final account = await NearWalletSelector().getAccount();
                    if (account == null) {
                      return;
                    } else {
                      await encryptDataAndLogin(AuthorizationCredentials(
                        account.accountId,
                        account.privateKey,
                      ));
                      Modular.to.navigate(Routes.home.getModule());
                    }
                  },
                );
              },
              child: Row(
                children: [
                  const Text(
                    "Login with QR code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  const Icon(
                    Icons.qr_code,
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
