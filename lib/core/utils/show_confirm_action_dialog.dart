import 'package:flutter/material.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';

Future<bool> askToConfirmAction(
    BuildContext context, {required String title, String? content}) async {
  return showGlassConfirmDialog(
    context: context,
    title: title,
    content: content,
  );
}
