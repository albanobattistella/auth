import 'dart:io';

import 'package:ente_auth/models/code.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? totp;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: const [BarcodeFormat.qrcode],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (totp != null) ? Text(totp!) : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // h4ck to remove black screen on Android scanners: https://github.com/juliuscanute/qr_code_scanner/issues/560#issuecomment-1159611301
    if (Platform.isAndroid) {
      controller.pauseCamera();
      controller.resumeCamera();
    }
    controller.scannedDataStream.listen((scanData) {
      try {
        final code = Code.fromRawData(scanData.code!);
        controller.dispose();
        Navigator.of(context).pop(code);
      } catch (e) {
        // Log
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
