import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class KeyAddingDialogBody extends ConsumerStatefulWidget {
  const KeyAddingDialogBody({
    super.key,
  });

  @override
  ConsumerState<KeyAddingDialogBody> createState() => _KeyAddingDialogBodyState();
}

class _KeyAddingDialogBodyState extends ConsumerState<KeyAddingDialogBody> {
  final _formKey = GlobalKey<FormState>();

  bool addingKeyProcessLoading = false;

  String keyName = "";
  String key = "";

  Future<void> addKey() async {
    final nearSocialApi = ref.read(nearSocialApiProvider);
    final authInfo = ref.read(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() {
          addingKeyProcessLoading = true;
        });

        if (authInfo.additionalStoredKeys.values
            .any((element) => element.privateKey == key)) {
          setState(() {
            addingKeyProcessLoading = false;
          });
          throw Exception("Key already added");
        }

        final privateKeyInfo = await nearSocialApi.getAccessKeyInfo(
          accountId: authInfo.accountId,
          key: key,
        );

        await authController.addAccessKey(
          accessKeyName: keyName,
          privateKeyInfo: privateKeyInfo,
        );
        Navigator.of(context).pop();
      }
    } catch (err) {
      rethrow;
    } finally {
      setState(() {
        addingKeyProcessLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: RPadding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "key_manager.add_new_key".tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: const EdgeInsets.all(10).r,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: TextFormField(
              initialValue:
                  "MyKeyName ${DateFormat('hh:mm a MMM dd, yyyy').format(DateTime.now())}",
              decoration: InputDecoration.collapsed(
                hintText: "key_manager.write_key_name".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "key_manager.enter_key_name".tr();
                }
                return null;
              },
              onSaved: (newValue) {
                keyName = newValue!;
              },
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: const EdgeInsets.all(10).r,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: TextFormField(
              initialValue: "",
              decoration: InputDecoration.collapsed(
                hintText: "key_manager.private_key_hint".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "key_manager.enter_key".tr();
                }
                return null;
              },
              onSaved: (newValue) {
                key = newValue!;
              },
            ),
          ),
          SizedBox(height: 10.h),
          if (!addingKeyProcessLoading)
            CustomButton(
              primary: true,
              onPressed: addKey,
              child: Text(
                "key_manager.add".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Align(
              alignment: Alignment.center,
              child: SpinnerLoadingIndicator(),
            ),
        ]),
      ),
    );
  }
}
