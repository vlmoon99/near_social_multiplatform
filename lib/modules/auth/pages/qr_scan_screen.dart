import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:near_social_mobile/formatters/qr_formatter.dart';
import 'package:near_social_mobile/modules/auth/pages/utils/encrypt_data_and_login.dart';
import 'package:near_social_mobile/routes/routes.dart';

class QRReaderScreen extends StatefulWidget {
  const QRReaderScreen({super.key});

  @override
  State<QRReaderScreen> createState() => _QRReaderScreenState();
}

class _QRReaderScreenState extends State<QRReaderScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isProcessing = true;
        await checkIfQRCodeIsValid(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> checkIfQRCodeIsValid(String code) async {
    try {
      final authorizationCredentials =
          QRFormatter.convertURLToAuthorizationCredentials(code);
      await encryptDataAndLogin(authorizationCredentials);
      Modular.to.navigate(Routes.home.getModule());
    } catch (err) {
      _isProcessing = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
            Center(
              child: Container(
                width: 300.h,
                height: 300.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
