import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              CustomButton(
                primary: true,
                onPressed: () async {
                  context.push(
                    AppRoutes.qrReader,
                  );
                },
                child: Text(
                  "auth.login_with_qr".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              IconButton(
                onPressed: () async {
                  context.push(
                    AppRoutes.qrReader,
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
          ),
        ],
      ),
    );
  }
}
