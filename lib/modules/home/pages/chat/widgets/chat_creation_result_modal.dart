import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';

class ChatCreationResultModal extends StatelessWidget {
  final String result;
  final String operationMessage;

  const ChatCreationResultModal({
    super.key,
    required this.result,
    required this.operationMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: NEARColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTitle(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NEARColors.black,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Text(
              operationMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NEARColors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100.w, 50.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    if (result == 'ok') {
      return 'Chat Created Successfully';
    } else {
      return 'Chat Creation Failed';
    }
  }
}
