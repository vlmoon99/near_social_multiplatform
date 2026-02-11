import 'package:flutter/material.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

Future<bool> askToConfirmAction(
    BuildContext context, {required String title, String? content}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: content == null
            ? null
            : Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          CustomButton(
            primary: true,
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text("Yes"),
          ),
          CustomButton(
            primary: false,
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text("No"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
      );
    },
  );

  return confirm ?? false;
}
