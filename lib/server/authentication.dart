import 'dart:convert';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/utils/info.dart';

import '../models/user.dart' as userModel;
import '../classes/get_device_info.dart';

class AuthenticationApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthenticationApi();

  static String decodeDeviceId(String deviceId) {
    return deviceId
        .replaceAll('.', '')
        .replaceAll('#', '')
        .replaceAll('\$', '')
        .replaceAll('[', '')
        .replaceAll(']', '');
  }

  static Future<userModel.User> createUser(
      {required String deviceId,
      required String userType,
      required String phone_number,
      required String email,
      required String name,
      String? address,
      String? imageUrl}) async {
    if (userType!=UserType.student.toString()) {
      DatabaseReference ref = _database.ref('users').push();
      print(ref.key);
      if (ref.key == null) {
        throw 'error';
      }
      return await ref
          .set({
            "userType": userType,
            "email": email,
            "name": name,
            'address': address,
            'imageUrl': imageUrl,
            "phone_number": phone_number
          })
          .then((value) => userModel.User(
              email: email,
              name: name,
              id: ref.key!,
              phoneNumber: phone_number,
              userType: userType,
              address: address,
              imageUrl: imageUrl))
          .catchError((e) => throw e);
    } else {
      String deviceID = decodeDeviceId(deviceId);
      return await _database
          .ref('users/$deviceID')
          .set({
            "userType": userType,
            "email": email,
            "name": name,
            'address': address,
            'imageUrl': imageUrl,
            "phone_number": phone_number
          })
          .then((value) => userModel.User(
              id: deviceID,
              name: name,
              email: email,
              userType: userType,
              imageUrl: imageUrl,
              address: address,
              phoneNumber: phone_number))
          .catchError((e) {
            debugPrint('we have this error during creating user $e');
            throw e;
          });
    }
  }

  static Future writeUserToStorage(userModel.User user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJSON()));
  }

  static Future<userModel.User?> readUserFromStorage() async {
    Map? userMap = jsonDecode(await _storage.read(key: 'user') ?? "{}");
    if (userMap == null || userMap.isEmpty) {
      return null;
    } else {
      return userModel.User.fromJSON(userMap);
    }
  }

  static bool get isUserVerified =>
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;

  static String? get gitUserUid => FirebaseAuth.instance.currentUser?.uid;

  Stream<User?> get gitUserState => _auth.userChanges();

  static Future<UserCredential> createUserWithEmailAndPassword(
          {required String email, required String password}) =>
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError((e) => throw "cant create your account");

  Future<UserCredential> login(
          {required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  bool? get isEmailVerification => _auth.currentUser?.emailVerified;

  static Future<bool> sendEmailVerification() async {
    return await _auth.currentUser
            ?.sendEmailVerification()
            .then((value) => true)
            .catchError((e) => false) ??
        false;
  }

  static Future<void> logOut(SettingProvider setting) async {
    setting.user = null;
    await _storage.deleteAll();
    _auth.signOut();
  }

  static Future<Map?> fetchUser(String deviceID, String email) async {
    Map? res = await _database
        .ref('users')
        .child(decodeDeviceId(deviceID))
        .get()
        .then((value) => value.value as Map?);
    if (res != null) res.addAll({'id': decodeDeviceId(deviceID)});
    return res ??= await _database
        .ref('users')
        .orderByChild('email')
        .equalTo(email)
        .once()
        .then((value) {
      if (value.snapshot.value == null) {
        return null;
      }
      (value.snapshot.value as Map).forEach((key, value) {
        if (value['email'] == email) {
          res = {'email': email, 'name': value['name'], 'id': key};
          return;
        }
      });
      return res;
    });
  }

  static Future<bool> deleteUser(SettingProvider setting) async {
    if (setting.user?.userType == UserType.manager.toString() ||
        setting.user?.userType == UserType.student.toString()) {
      String? deviceId = await _storage.read(key: 'deviceId');
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
    } else {
      String? id = await _storage.read(key: 'id');
      if (id != null) {
        try {
          await logOut(setting).then((_) {
            _database.ref('users').child(id).remove();
          });
          return true;
        } catch (_) {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  static Future<bool> deleteAccount(String email) async {
    return await _auth.currentUser
            ?.delete()
            .then((value) => true)
            .catchError((e) => throw 'error') ??
        false;
  }

  static Future<userModel.User?> fetchUserFromHisAccount() async {
    User? user = _auth.currentUser;
    userModel.User? fetchingUser;
    String? deviceId = await DeviceInfo.getDeviceID();
    if (user != null && user.email != null && deviceId != null) {
      await fetchUser(decodeDeviceId(deviceId), user.email!).then((value) {
        if (value != null) fetchingUser = userModel.User.fromJSON(value);
      });
      return fetchingUser;
    }
    return null;
  }
}
