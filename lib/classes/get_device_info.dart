


import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo{

  DeviceInfo();

  static Future<String?> getDeviceID()async{
    return await DeviceInfoPlugin().androidInfo.then((value) => value.id);
  }



}