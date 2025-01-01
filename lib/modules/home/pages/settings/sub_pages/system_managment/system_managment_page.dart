import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'package:near_social_mobile/services/cryptography/internal_cryptography_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcode_reader_web/qrcode_reader_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SystemModel {
  final String link;
  final String anonKey;

  SystemModel({required this.link, required this.anonKey});

  @override
  String toString() {
    return 'SystemModel(link: $link, anonKey: $anonKey)';
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'anonKey': anonKey,
    };
  }

  factory SystemModel.fromJson(Map<String, dynamic> json) {
    return SystemModel(
      link: json['link'] as String,
      anonKey: json['anonKey'] as String,
    );
  }
}

class SystemsManagmentPage extends StatefulWidget {
  const SystemsManagmentPage({super.key});

  @override
  State<SystemsManagmentPage> createState() => _SystemsManagmentPageState();
}

class _SystemsManagmentPageState extends State<SystemsManagmentPage> {
  SystemModel? mainSystem;

  final List<SystemModel> systems = [
    // SystemModel(
    //   link: SystemsManagmentConstans.secondarySystemLink,
    //   anonKey: SystemsManagmentConstans.secondarySystemAnonKey,
    // )
  ];

  void scanQRCode(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRReaderScreen(onProcess: (code) {
          try {
            setState(() {
              final res = jsonDecode(code);
              if (res is Map) {
                final SystemModel systemModel = SystemModel(
                  link: res['link'].toString(),
                  anonKey: res['anonKey'].toString(),
                );
                systems.add(systemModel);
                Modular.get<FlutterSecureStorage>().write(
                  key: "systems",
                  value: jsonEncode(
                    systems.map((system) => system.toJson()).toList(),
                  ),
                );
              }
            });
          } catch (e) {}
          Navigator.pop(context);
        }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initSystemsSettings();
  }

  Future<void> initSystemsSettings() async {
    final systemsFromStorage =
        (jsonDecode(await Modular.get<FlutterSecureStorage>().read(
                  key: "systems",
                ) ??
                '[]') as List<dynamic>)
            .map((system) => SystemModel.fromJson(system))
            .toList();

    systems.addAll(systemsFromStorage);

    final mainSystemFromLocalStorage = SystemModel.fromJson(
        jsonDecode(await Modular.get<FlutterSecureStorage>().read(
              key: "mainSystem",
            ) ??
            '{}'));
    setState(() {
      mainSystem = mainSystemFromLocalStorage;
    });
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
                      mainSystem?.link ?? "No main System",
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
                            ],
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
  final List<SystemModel> systems;
  final Function(int) onDelete;

  const NearStyledList({
    super.key,
    required this.systems,
    required this.onDelete,
  });

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
                onTap: () async {
                  final shouldSwitch = await showDialog<bool>(
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: NEARColors.purple,
                      title: const Text('Switch System'),
                      content: const Text(
                          'Are you sure that you want to switch to another system?'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NEARColors.red,
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'No',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: NEARColors.white,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NEARColors.blue,
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Yes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: NEARColors.white,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldSwitch == true) {
                    try {
                      final system = systems[index];
                      await Supabase.instance.client.auth.signOut();
                      await Supabase.instance.dispose();
                      await Supabase.initialize(
                        url: system.link,
                        anonKey: system.anonKey,
                      );

                      String signedMessagedForVerification =
                          await Modular.get<InternalCryptographyService>()
                              .encryptionRunner
                              .signMessageForVerification(
                                  Modular.get<AuthController>()
                                      .state
                                      .secretKey);

                      await Supabase.instance.client.auth.signInAnonymously();
                      final uuid =
                          Supabase.instance.client.auth.currentUser!.id;
                      final keys = KeyPair.fromJson(jsonDecode(
                          await Modular.get<FlutterSecureStorage>().read(
                                key: "session_keys",
                              ) ??
                              '{}'));

                      final base58PubKey =
                          await Modular.get<NearBlockChainService>()
                              .getBase58PubKeyFromHexValue(
                                  hexEncodedPubKey:
                                      Modular.get<AuthController>()
                                          .state
                                          .publicKey);

                      final res =
                          await Modular.get<AuthController>().verifyTransaction(
                        signature: signedMessagedForVerification,
                        encryptionPublicKey: keys.publicKey,
                        publicKeyStr: base58PubKey,
                        uuid: uuid,
                        accountId:
                            Modular.get<AuthController>().state.accountId,
                      );

                      if (!res) {
                        await Supabase.instance.client.auth.signOut();
                        throw Exception("Server authenticated error");
                      }
                    } catch (e) {
                      print("Error while switching,switch back");
                    }
                  }
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  systems[index].link,
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
                    color: Color(0xFFFF585D),
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
