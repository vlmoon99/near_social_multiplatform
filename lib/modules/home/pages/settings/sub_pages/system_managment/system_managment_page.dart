import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcode_reader_web/qrcode_reader_web.dart';

class SystemsManagmentPage extends StatefulWidget {
  const SystemsManagmentPage({super.key});

  @override
  State<SystemsManagmentPage> createState() => _SystemsManagmentPageState();
}

class _SystemsManagmentPageState extends State<SystemsManagmentPage> {
  String? mainSystem = "https://main.system.com";
  final List<String> systems = ["https://example1.com", "https://example2.com"];

  void addNewSystem(String url) {
    if (url.isNotEmpty) {
      setState(() {
        systems.add(url);
      });
    }
  }

  void scanQRCode(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRReaderScreen(onProcess: (code) {
          addNewSystem(code);
          Navigator.pop(context);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Systems Management'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFF8F9FF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Main System",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      mainSystem ?? "No Main System",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            NearStyledList(
              systems: systems,
              onDelete: (index) {
                setState(() {
                  systems.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double modalWidth = MediaQuery.of(context).size.width * 0.8;
                    double modalHeight =
                        MediaQuery.of(context).size.height * 0.5;
                    modalWidth = modalWidth > 500 ? 500 : modalWidth;
                    modalHeight = modalHeight > 400 ? 400 : modalHeight;

                    return Container(
                      width: modalWidth,
                      height: modalHeight,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Add New System",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.blueAccent,
                                ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: "Scan QR Code",
                                child: InkWell(
                                  onTap: () => scanQRCode(context),
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.blueAccent,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              const Text("or"),
                              const SizedBox(width: 20.0),
                              Flexible(
                                child: SizedBox(
                                  width: 200,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Enter system URL",
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      addNewSystem(value);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Tooltip(
                            message: "Add new system",
                            child: InkWell(
                              onTap: () {
                                const String defaultLink =
                                    "https://default-system.com";
                                addNewSystem(defaultLink);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.blueAccent,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        backgroundColor: NEARColors.blue,
        foregroundColor: NEARColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class QRReaderScreen extends StatefulWidget {
  const QRReaderScreen({
    super.key,
    required this.onProcess,
  });
  final void Function(String) onProcess;

  @override
  State<QRReaderScreen> createState() => _QRReaderScreenState();
}

class _QRReaderScreenState extends State<QRReaderScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final StreamController<String> webQRReaderController = StreamController();

  @override
  void initState() {
    super.initState();
    webQRReaderController.stream.distinct().listen(widget.onProcess);
  }

  Future<void> _processQRCode(String code) async {
    try {
      print("code $code");
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar(error.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    webQRReaderController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: QRCodeReaderSquareWidget(
          borderRadius: BorderRadius.circular(10),
          targetColor: Theme.of(context).primaryColor,
          onDetect: (QRCodeCapture capture) =>
              webQRReaderController.add(capture.raw),
          size: 300.h,
        ),
      ),
    );
  }
}

class NearStyledList extends StatelessWidget {
  final List<String> systems;
  final Function(int) onDelete;

  const NearStyledList({
    Key? key,
    required this.systems,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: systems.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E8EB),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  systems[index],
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D1D1D),
                    letterSpacing: 0.15,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF585D), // Near's red
                  ),
                  onPressed: () => onDelete(index),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEEEE),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
