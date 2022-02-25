



import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:offer_app/models/setting_model.dart';
import 'package:offer_app/models/user.dart';

class SettingProvider with ChangeNotifier{
 final BuildContext context;
  late Setting setting = Setting(context);
   User? user;
  SettingProvider(this.context){
   tryToLoadUser();
  }

  void tryToLoadUser()async{
   FlutterSecureStorage s=const  FlutterSecureStorage();
   String? uid=await s.read(key: 'uid');
   String? dId=await s.read(key: 'deviceId');
   String? userType=await s.read(key: 'userType');
   String? name=await s.read(key: 'name');
   if(uid!=null&&dId!=null&&userType!=null&&name!=null){
    user=User(id: dId, name: name, userType: userType);
   }
  }



}