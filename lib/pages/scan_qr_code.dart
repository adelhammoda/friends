

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:responsive_s/responsive_s.dart';

import '../provider/setting_provider.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({Key? key}) : super(key: key);

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  final CustomScaffoldController _controller=CustomScaffoldController();
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context,listen: false);
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
        result = scanData;
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result?.code??"Wrong data")));

    });
  }

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
  void dispose() {
    print("disposeing scanner");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _controller,
      child: Expanded(
        child:  QRView(
          key: qrKey,
          overlay: QrScannerOverlayShape(
            borderRadius: 12,
            borderColor: _setting.setting.theme.primaryColor,
            borderLength: 12,
            borderWidth: 10,
            cutOutBottomOffset: 10,
            cutOutHeight: _responsive.responsiveWidth(forUnInitialDevices: 80),
            cutOutWidth:_responsive.responsiveWidth(forUnInitialDevices: 80) ,
            overlayColor: _setting.setting.theme.bodyTextColor.withOpacity(0.8),
          ),
          onQRViewCreated: _onQRViewCreated,
          formatsAllowed: [
            BarcodeFormat.qrcode
          ],
        ),
      ),

    );
  }
}
