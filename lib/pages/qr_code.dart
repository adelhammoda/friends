import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:lottie/lottie.dart';
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
  late final SettingProvider _setting =
      Provider.of<SettingProvider>(context, listen: false);
  final ValueNotifier<bool> _showCode = ValueNotifier(false);
  final ValueNotifier<String?> _timeListener = ValueNotifier(null);
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _animate = false;


  @override
  void initState() {
    super.initState();

      print(mounted);
      print(_showCode.value);
  }

  @override
  void dispose() {
    _showCode.dispose();
    _timeListener.dispose();
    controller?.dispose();
    super.dispose();
  }

  void _showQRCode() {
    if (_setting.user != null) {
      setState(() {
        _animate = true;
      });
      Timer(const Duration(seconds: 2), () {
        _showCode.value = true;
      });
      Timer.periodic(const Duration(seconds: 1), (timer) {
        _showCode.value = true;
        if(!mounted){
          return ;
        }
        if(timer.tick>=120){
          timer.cancel();
          _hideQRCode();
        }
        print(timer.tick%60);
        _timeListener.value='${(timer.tick~/60).toString().padLeft(2,'0')}:${(timer.tick%60).toString().padLeft(2,'0')}';
      });
    } else {
      _scaffoldController.showMSG('some error happened');
    }
  }

  void _hideQRCode() {
    setState(() {
      _animate = false;
    });
    _showCode.value = false;
  }



  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                width: _responsive.responsiveWidth(forUnInitialDevices: 90),
                height: _responsive.responsiveHeight(forUnInitialDevices: 10),
                decoration: BoxDecoration(
                    color: _setting.setting.theme.bodyTextColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Press on button to generate your code',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontSize: 15),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showCode,
            builder: (c, value, child) {
              if (value) {
                return Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width:
                          _responsive.responsiveWidth(forUnInitialDevices: 100),
                      height:
                          _responsive.responsiveHeight(forUnInitialDevices: 30),
                      child: QrImage(
                        data: _setting.user!.id,
                        padding: EdgeInsets.zero,
                        version: QrVersions.auto,
                        size: _responsive.responsiveValue(
                            forUnInitialDevices: 50),
                      ),
                    ),
                    ValueListenableBuilder<String?>(
                        valueListenable: _timeListener,
                        builder: (c, value, child) {
                          return Visibility(
                            visible: value != null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("The code will expire in 2 minutes ",style: TextStyle(
                                  fontSize: 15,
                                  color: _setting.setting.theme.appBarColor
                                ),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    value ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: _setting.setting.theme.bodyTextColor
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                  ],
                );
              } else {
                return child!;
              }
            },
            child: InkWell(
              onTap: _showQRCode,
              child: SizedBox(
                  height: _responsive.responsiveHeight(forUnInitialDevices: 60),
                  child: Lottie.asset('assets/lottie/start_button.json',
                      animate: _animate)),
            ),
          ),
        ],
      ),
      controller: _scaffoldController,
    );
  }
}
