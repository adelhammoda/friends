import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_s/responsive_s.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final CustomScaffoldController _scaffoldController =
      CustomScaffoldController();
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context,listen: false);
  final ValueNotifier<bool> _showCode=ValueNotifier(false);
  final ValueNotifier<bool> _qrScanner=ValueNotifier(false);
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;


  void _showQRCode(){
    if(_setting.user!=null){
      _showCode.value=true;
    }
  }
  void _scanQRCode(){
    _qrScanner.value=true;
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
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
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _showCode,
              builder: (c,value,child){
                if(value){
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    width: _responsive.responsiveWidth(forUnInitialDevices: 100),
                    height: _responsive.responsiveHeight(forUnInitialDevices: 30),
                    child: QrImage(
                      data:_setting.user!.id,
                      padding: EdgeInsets.zero,
                      version: QrVersions.auto,
                      size: _responsive.responsiveValue(forUnInitialDevices: 50),
                    ),
                  );
                }else{
                  return child!;
                }
              },
              child: ListTile(
                title: Text('Generate code'),
                onTap: _showQRCode,
              ),
            ),
            ListTile(
              title: Text('Scan code'),
              onTap: _scanQRCode,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _qrScanner,
              builder: (c,value,child)=>value?child!:Container(),
              child: Expanded(
                child: QRView(
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
            ),

          ],
        ),
        controller: _scaffoldController,);
  }
}
