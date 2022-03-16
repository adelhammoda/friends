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

  static User? get user => _auth.currentUser;

  static Future<userModel.User> createUser(
      {required String deviceId,
      required String userType,
      required String phone_number,
      required String email,
      required String name,
      String? address,
      String? imageUrl}) async {
    if (userType != UserType.student.toString()) {
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
    print(userMap);
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
          .catchError((e) => throw e);

  static Future<bool?> emailIsExist(String email) async => await _auth
      .fetchSignInMethodsForEmail(email)
      .then((value) => true)
      .catchError((e) => throw e);

  static Future<UserCredential> login(
          {required String email, required String password}) =>
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((e) => throw e);

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
    _auth.signOut();
  }

  static Future<void>? get reloadUser => _auth.currentUser?.reload();

  static Future<Map?> fetchUser(String email) async {
    Map? res;
    return await _database
        .ref('users')
        .orderByChild('email')
        .startAt(email.substring(0,email.lastIndexOf('.')))
        .once()
        .then((value) {
          print(email);
          print(value.snapshot.value);
      if (value.snapshot.value == null) {
        return null;
      }
      (value.snapshot.value as Map).forEach((key, value) {
        if (email.contains(value['email'])  && (res?.isEmpty ?? true)) {
          res = {
            'email': email,
            'name': value['name'],
            'id': key,
              'imageUrl':value['imageUrl'],
            'phone_number':value['phone_number'],
            'userType':value['userType'],
            };
          return;
        } else if (value['email'] == email && (res?.isNotEmpty ?? false)) {
          throw "This user account have some problem. please contact  use to fix you problem";
        }
      });
      return res;
    });
  }

  static Future<bool> deleteUser(SettingProvider setting) async {
      String? deviceId = setting.user!.id;
        try {
          await logOut(setting).then((_) {
            _database.ref('users').child(deviceId).remove();
          });
          return true;
        } catch (e) {
          debugPrint(e.toString());
          throw "Can't delete this user at this moment";
        }
  }

  static Future<void> deleteAccount(
      String email, SettingProvider setting) async {
    try {
      userModel.User? user;
      if(setting.user == null)
       user = await fetchUserFromHisAccount(email);
      else
        user = setting.user;
      if (user == null) {
        throw 'Cant delete this user... an error occurred';
      } else {
        await deleteUser(setting);
        await _auth.currentUser?.delete();
        return;
      }
    } on FirebaseException catch (e) {
      throw e.message ?? "Error in happened will connection to server";
    } catch (e) {
      throw e;
    }
  }

  static Future<userModel.User?> fetchUserFromHisAccount(String email) async {
    String? deviceId = await DeviceInfo.getDeviceID();
    userModel.User? fetchingUser;
    try {
      if (email != '' && deviceId != null) {
        await fetchUser(email).then((value) {
          if (value != null) fetchingUser = userModel.User.fromJSON(value);
        });
        return fetchingUser;
      }
    } catch (e) {
      return null;
    }
    return null;
  }}
