import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/key_manager/presentation/ui/widgets/access_key_info_card.dart';
import 'package:near_social_mobile/features/key_manager/presentation/ui/widgets/key_adding_dialog_body.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';


class KeyManagerPage extends ConsumerWidget {
  const KeyManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInfo = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "key_manager.access_keys".tr(),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leadingWidth: kIsWeb ? 50.h : 0,
        leading: kIsWeb
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: REdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final key = authInfo.additionalStoredKeys.entries
                .elementAt(index);
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 5 : 0).r,
              child: AccessKeyInfoCard(
                keyName: key.key,
                privateKeyInfo: key.value,
                removeAble:
                    key.value.privateKey != authInfo.secretKey,
              ),
            );
          },
          itemCount: authInfo.additionalStoredKeys.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: REdgeInsets.symmetric(horizontal: 20),
                child: const KeyAddingDialogBody(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
