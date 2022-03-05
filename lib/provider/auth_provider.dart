import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friends/classes/get_device_info.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/utils/info.dart';
import 'package:friends/utils/validator.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier, Validator {
  final AuthenticationApi _server = AuthenticationApi();
  bool showError = false;
  bool isLoading = false;
  bool rememberMe = false;
  String errorMessage = '';
  String userType = '';

  void changeUserType(String selectedUserType) {
    if (userType == selectedUserType) {
      userType = '';
    } else {
      userType = selectedUserType;
    }
  }

  AuthProvider();

  // StreamSubscription listener(Function(String event) function){
  //  return _errorMSG.value=function;
  // }

  void changeRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<bool?> sendOTP(
      context, String email, CustomScaffoldController controller) async {
    if (email == '' || userType == '') {
      controller.showError(Provider.of<SettingProvider>(context)
              .setting
              .appLocalization
              ?.someFieldIsEmpty ??
          'Some field is empty');
    } else {
      return await _server.sendEmailOTP(email).then((value) => true);
    }
  }

  Future createAccount(
      BuildContext context,
      String email,
      String password,
      String otp,
      String name,
      CustomScaffoldController controller,
      SettingProvider settingProvider) async {
    String? deviceId = await DeviceInfo.getDeviceID();
    if (deviceId == null) {
      controller.showError(Provider.of<SettingProvider>(context)
              .setting
              .appLocalization
              ?.cantGetAllRequiredInfo ??
          "Cant get all data");
    } else {
      bool push;
      if (userType == UserType.student.toString()|| userType ==UserType.manager.toString()) {
        push=false;
      }else{
        push=true;
      }
        await _server.createUser(deviceId, userType, email, name,push: push).then((value) {
          print("creating user $value");
          if (value == false) {
            controller.showError(
                settingProvider.setting.appLocalization?.errorInCreate ??
                    "error will create");
          } else {
            _server
                .createUserWithEmailAndPassword(
                    email: email, password: password)
                .then((value) {
              debugPrintDone;
              debugPrint('User token  is ${value.user!.uid}');
              _server.writeToStorage(
                  email, password, value.user!.uid, deviceId, userType, name);
            }).catchError((e) {
              debugPrint(e.toString());
              controller.showError(
                  settingProvider.setting.appLocalization?.errorInCreate ??
                      "error will create");
            });
          }
        });
    }
  }

  String? verifyOTP(BuildContext context, String email, String otp,
      SettingProvider settingProvider) {
    return _server.verifyEmailOTP(email: email, userOtp: otp)
        ? null
        : settingProvider.setting.appLocalization?.incorrectOTP ??
            "This entry is wrong";
  }

  Future<void> login(String email,
      String password,
      CustomScaffoldController controller,
      SettingProvider _setting) async {
    print('i am in login function');
    String? deviceId = await DeviceInfo.getDeviceID();
    print('Device id is $deviceId');
    if (deviceId == null) {
      controller.showError(
          _setting.setting.appLocalization?.cantGetAllRequiredInfo ??
              "Cant get all data");
    } else {
      try {
        print('fetching user');
        Map? res = await _server.fetchUser(deviceId,email);
        print('user  map is $res');
        if (res == null) {
          controller.showError(
              _setting.setting.appLocalization?.thisUserIsNotFound ??
                  "This user is not found");
        } else {
          if (res['email'] == email) {
            await _server
                .login(email: email, password: password)
                .catchError((e) {
              controller.showError(
                  _setting.setting.appLocalization?.errorInCreate ??
                      "Error In authentication");
            }).then((value) async{
              if(value.user!=null&&rememberMe){
                print('Writing data in storage');
                await _server.writeToStorage(email, password, value.user!.uid, res['id'], userType, res['name']);
              }
            });

          } else {
            controller.showError(_setting.setting.appLocalization
                    ?.thisUserIsFoundWithAnotherAccount ??
                "This user is founded with another device" +
                    (_setting.setting.appLocalization?.ifChangeYourAccount ??
                        "If you change your account please tell us for ensure  access to your account"));
          }
        }
      } on FirebaseException catch (e) {
       controller.showError(e.code);
      } catch (e) {
        controller.showError(_setting.setting.appLocalization?.errorInLogin??"Some error happened when trying to login");
      }
    }
  }

  void switchLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  Stream<User?> get isAuth => _server.gitUserState;
}
