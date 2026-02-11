import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WidgetsView extends StatelessWidget {
  const WidgetsView({super.key, required this.accountIdOfUser});
  final String accountIdOfUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("people.widget_removed".tr()),
    );
  }
}
