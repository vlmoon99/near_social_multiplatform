import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/features/chat/presentation/logic/chat_events.dart';
import 'package:near_social_mobile/features/chat/presentation/providers/chat_controller.dart';

void showIncomingCallDialog(
    BuildContext context, WidgetRef ref, String callerId) {
  Timer? autoRejectTimer;

  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      autoRejectTimer = Timer(const Duration(seconds: 30), () {
        ref.read(chatControllerProvider.notifier).onEvent(RejectCallEvent());
        if (Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      });

      return CupertinoAlertDialog(
        title: Text('chat.incoming_call'.tr(namedArgs: {'accountId': callerId})),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              autoRejectTimer?.cancel();
              ref
                  .read(chatControllerProvider.notifier)
                  .onEvent(RejectCallEvent());
              Navigator.of(dialogContext).pop();
            },
            child: Text('chat.reject'.tr()),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              autoRejectTimer?.cancel();
              ref
                  .read(chatControllerProvider.notifier)
                  .onEvent(AcceptCallEvent());
              Navigator.of(dialogContext).pop();
            },
            child: Text('chat.accept'.tr()),
          ),
        ],
      );
    },
  ).then((_) {
    autoRejectTimer?.cancel();
  });
}
