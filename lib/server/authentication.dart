import 'dart:convert';

import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/utils/info.dart';

import '../models/user.dart' as userModel;
import '../classes/get_device_info.dart';

class AuthenticationApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailAuth _emailAuth = EmailAuth(sessionName: 'Offer app');
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AuthenticationApi();

  String decodeDeviceId(String deviceId) {
    return deviceId
        .replaceAll('.', '')
        .replaceAll('#', '')
        .replaceAll('\$', '')
        .replaceAll('[', '')
        .replaceAll(']', '');
  }

  Future<bool> createUser(
      String deviceId, String userType, String email, String name,{bool push=false}) async {
    if(push){
      return await _database.ref('users').push().set({
        "userType": userType, "email": email, "name": name
      }).then((value) => true).catchError((e)=>false);
    }else {
      String deviceID = decodeDeviceId(deviceId);
      return await _database
          .ref('users/$deviceID')
          .set({"userType": userType, "email": email, "name": name})
          .then((value) => true)
          .catchError((e) {
        debugPrint(e);
        return false;
      });
    }
  }

  Future writeToStorage(
      String email, String password, String uid, String deviceId,String userType,String name) async {
    String idKey=userType==UserType.student.toString()||userType==UserType.manager.toString()?"deviceId":"id";
    await storage.write(key: 'uid', value: uid);
    await storage.write(key: idKey, value: deviceId);
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'userType', value: userType);
    await storage.write(key: 'name', value: name);
  }

  Future writeUserToStorage(userModel.User user)async{
    await storage.write(key: 'user', value:jsonEncode(user.toJSON()));
  }

  Future<userModel.User?> readUserFromStorage()async{
    Map? userMap= jsonDecode(await storage.read(key: 'user')?? "{}");
    if(userMap==null|| userMap.isEmpty){
      return null;
    }else{
     return userModel.User.fromJSON(userMap );
    }
  }

  static String? get gitUserUid => FirebaseAuth.instance.currentUser?.uid;

  Stream<User?> get gitUserState => _auth.userChanges();

  Future<UserCredential> createUserWithEmailAndPassword(
          {required String email, required String password}) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> login(
          {required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  bool? get isEmailVerification => _auth.currentUser?.emailVerified;

  bool verifyEmailOTP({required String email, required String userOtp}) {
    return _emailAuth.validateOtp(recipientMail: email, userOtp: userOtp);
  }

  Future<bool> sendEmailOTP(String email) {
    return _emailAuth.sendOtp(recipientMail: email, otpLength: 7);
  }

  Future<void> logOut(SettingProvider setting)async{
    setting.user=null;
    await storage.deleteAll();
    _auth.signOut();
  }

  Future<Map?> fetchUser(String deviceID,String email)async{
   Map? res= await _database.ref('users').child(decodeDeviceId(deviceID)).get().then((value) => value.value as Map?);
   if(res!=null) res.addAll({'id':decodeDeviceId(deviceID)});
    return res??=await _database.ref('users').orderByChild('email').equalTo(email).once().then((value) {
       if(value.snapshot.value==null){
         return null;
       }
       (value.snapshot.value as Map).forEach((key, value) {
         if(value['email']==email){
           res={
             'email':email,
             'name':value['name'],
             'id':key
           };
           return;
         }
       });
       return res;
     });


  }

  Future<bool> deleteAccount(SettingProvider setting)async {

    if(setting.user?.userType==UserType.manager.toString()||setting.user?.userType==UserType.student.toString()) {
      String? deviceId = await storage.read(key: 'deviceId');
      if (deviceId != null) {
        try {
          await logOut(setting).then((_) {
            _database.ref('users').child(deviceId).remove();
          });
          return true;
        } catch (e) {
          debugPrint(e.toString());
          return false;
        }
      }
      return false;
    }else{
      String? id=await storage.read(key: 'id');
      if(id!=null){
        try {
          await logOut(setting).then((_) {
            _database.ref('users').child(id).remove();
          });
          return true;
        } catch (_) {
          return false;
        }
      }else{
        return false;
      }

    }
  }


  Future<userModel.User?> fetchUserFromHisAccount()async{
    User? user = _auth.currentUser;
    userModel.User? fetchingUser;
    String? deviceId = await DeviceInfo.getDeviceID();
    if(user!=null && user.email!=null && deviceId!=null){
      await fetchUser(decodeDeviceId(deviceId), user.email!).then((value) {
        if(value != null)
         fetchingUser = userModel.User.fromJSON(value);
      });
      return fetchingUser;
    }
    return null;
  }
}
