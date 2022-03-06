import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/classes/get_device_info.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/widgets/custom_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/models/user.dart';
import 'package:friends/provider/auth_provider.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/utils/info.dart';
import 'package:friends/widgets/app_bar.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:friends/widgets/drop_down_menu.dart';
import 'package:friends/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  late Responsive _responsive;
  late SettingProvider _settingProvider;
  late AuthProvider _provider;
  final ValueNotifier<bool> _hidePassword = ValueNotifier(true);
  final ValueNotifier<bool> _hideConfirmPassword = ValueNotifier(true);
  final CustomScaffoldController _controller = CustomScaffoldController();
  final GlobalKey<FormState> _emailPasswordKey = GlobalKey();
  final GlobalKey<FormState> _otbKey = GlobalKey();
  CrossFadeState _crossFadeState = CrossFadeState.showFirst;
  bool _next = true;
  bool emailMethod = false;

  //
  String _email = '';
  String _password = '';
  String _name = '';
  String _phone_number = '';
  String _otp = '';
  String? _imageUrl = '';
  String? _address;

  //

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingProvider = SettingProvider(context);
    _provider = Provider.of(context);
    _responsive = Responsive(context);
  }

  Future<void> _createAccount() async {
    try {
      debugPrint('Start creating user');
      String? deviceId = await DeviceInfo.getDeviceID();
      debugPrint('device id is $deviceId');
      if (deviceId == null) {
        throw "Cant get all required info";
      }
      debugPrint('adding user to database');
      User user = await AuthenticationApi.createUser(
          deviceId: deviceId,
          userType: _provider.userType,
          phone_number: _phone_number,
          email: _email,
          address: _address,
          imageUrl: _imageUrl,
          name: _name);
      debugPrint('writing user to storage');
      AuthenticationApi.writeUserToStorage(user);
     await _verifyAccount();
    } catch (e) {
      debugPrint('we catch some error in _createUserFunction $e');
      _provider.switchLoading(false);
      _controller.showMSG(
        "Some error happened",
        title: "Failed",
      );
    }
  }

  Future<void> _verifyAccount() async {
    _provider.switchLoading(true);
    try {
      await AuthenticationApi.createUserWithEmailAndPassword(
          email: _email, password: _password);
    }  catch (e) {
      _controller.showMSG('error happened');
    }
    _provider.switchLoading(false);
    bool? choice = await showCustomDialog<bool>(context,
        barrierDismissible: false,
        child: Container(
          width: _responsive.responsiveWidth(forUnInitialDevices: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("use number phone "),
                onTap: () => Navigator.of(context).pop(true),
                subtitle: Text('$_phone_number'),
              ),
              ListTile(
                title: Text("use email "),
                onTap: () => Navigator.of(context).pop(false),
                subtitle: Text('$_email'),
              ),
            ],
          ),
        ));
    _provider.switchLoading(true);
    if (choice == true) {
      //phone number auth
    } else if (choice == false) {
      try {
        print('creating account');
        try{
          await AuthenticationApi.createUserWithEmailAndPassword(
              email: _email, password: _password);
        } on FirebaseException catch(e){
          _controller.showMSG('${e.message}');
        }catch(e){
          print(e);
          _controller.showMSG('cant create your account');
        }

        print('sending message');
        bool sent = await AuthenticationApi.sendEmailVerification();
        if (sent) {
          print('message sent');
          emailMethod = true;
          setState(() {
            _crossFadeState = CrossFadeState.showSecond;
          });
        } else {
          _controller.showMSG('For some reason cant send email authentication');
        }
      } catch (e) {
        print(e);
      }
    } else {
      _controller.showMSG('you stopped sign in process');
    }
    _provider.switchLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _controller,
      appBar: buildAppBar(context,
          title: _settingProvider.setting.appLocalization?.createAccount ??
              'Create Account'),
      child: WillPopScope(
        onWillPop: null,
        // onWillPop: ()async{
        //  bool result= await showCustomDialog<bool>(context,
        //      child: AlertDialog(
        //     title: Text("warning"),
        //     content: Text('you will lose all data'),
        //     actions: [
        //       TextButton(onPressed: (){
        //         Navigator.of(context).pop(true);
        //       }, child: Text('ok'))
        //     ],
        //   ))?? false;
        //
        //    return result;
        //
        // },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AnimatedCrossFade(
                    secondChild: Form(
                      key: _otbKey,
                      child: SizedBox(
                        width:
                        _responsive.responsiveWidth(forUnInitialDevices: 100),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: _responsive.responsiveWidth(
                                      forUnInitialDevices: 100),
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    emailMethod
                                        ? "We send link to your account.pleas open gmail and press on link to verify your account"
                                        : _settingProvider.setting
                                        .appLocalization
                                        ?.weSendOTb ??
                                        "We send otb to this email",
                                    style: TextStyle(
                                      color: _settingProvider
                                          .setting.theme.bodyTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    emailMethod
                                        ? _email
                                        : "+963 " + _phone_number.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _settingProvider
                                          .setting.theme.appBarColor,
                                      fontSize: 14,
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Visibility(
                                visible: !emailMethod,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      hintText: 'Enter OTB',
                                      validator: (otpValue) {
                                        if (otpValue != null) {
                                          return ' da ';
                                          // return _provider.verifyOTP(
                                          //     context, _email, otpValue,
                                          //     _settingProvider);
                                        } else {
                                          return _settingProvider
                                              .setting
                                              .appLocalization
                                              ?.thisFieldIsRequired ??
                                              "This field is required";
                                        }
                                      },
                                      onChanged: (value) {
                                        if (value != null) {
                                          _otp = value;
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                  ],
                                )),
                            TextButton(
                              onPressed: () {
                                if (!_provider.isLoading) {
                                  _provider.switchLoading(false);
                                  setState(() {
                                    _next = true;
                                    _crossFadeState = CrossFadeState.showFirst;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    _settingProvider
                                        .setting.appLocalization?.edit ??
                                        "Edit",
                                    style: TextStyle(
                                        color: _settingProvider
                                            .setting.theme.appBarColor,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.backspace,
                                    color: _settingProvider
                                        .setting.theme.textFieldColor,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    duration: const Duration(milliseconds: 400),
                    crossFadeState: _crossFadeState,
                    firstChild: Form(
                      key: _emailPasswordKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                              onChanged: (value) {
                                if (value != null) {
                                  _name = value;
                                }
                              },
                              validator: (name) {
                                if (name == '' || name == null) {
                                  return _settingProvider.setting
                                      .appLocalization
                                      ?.thisFieldIsRequired ??
                                      'This field is required';
                                } else {
                                  return null;
                                }
                              },
                              hintText: _settingProvider
                                  .setting.appLocalization?.name ??
                                  'Name'),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextField(
                              textInputType: TextInputType.emailAddress,
                              validator: _provider.validateEmail,
                              onChanged: (value) {
                                if (value != null) {
                                  _email = value;
                                }
                              },
                              hintText: _settingProvider
                                  .setting.appLocalization?.email ??
                                  'Email'),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextField(
                              textInputType: TextInputType.phone,
                              onChanged: (value) {
                                if (value != null &&
                                    double.tryParse(value) != null) {
                                  _phone_number = value;
                                }
                              },
                              validator: (number) {
                                if (number == '' || number == null) {
                                  return _settingProvider.setting
                                      .appLocalization
                                      ?.thisFieldIsRequired ??
                                      'This field is required';
                                } else if (double.tryParse(number) == null) {
                                  return "Invalid number phone";
                                } else if (number.length > 10 ||
                                    (number[0] != '0' && number[1] != '9')) {
                                  return "Invalid number phone";
                                }
                                {
                                  return null;
                                }
                              },
                              prefixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '+963',
                                    style: TextStyle(
                                        color: _settingProvider
                                            .setting.theme.iconsColor),
                                  )
                                ],
                              ),
                              hintText: 'phone number'),
                          const SizedBox(
                            height: 5,
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _hidePassword,
                            builder: (ctx, value, child) =>
                                CustomTextField(
                                    validator: _provider.validatePassword,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _password = value;
                                      }
                                    },
                                    allowToolBar: false,
                                    hideText: value,
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        _hidePassword.value =
                                        !_hidePassword.value;
                                      },
                                      child: Icon(
                                        value
                                            ? Icons.visibility_off_sharp
                                            : Icons.remove_red_eye,
                                        color: _settingProvider
                                            .setting.theme.bodyTextColor,
                                      ),
                                    ),
                                    hintText: _settingProvider
                                        .setting.appLocalization?.password ??
                                        'Password'),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _hideConfirmPassword,
                            builder: (ctx, value, child) =>
                                CustomTextField(
                                    validator: (password) {
                                      if (password?.compareTo(_password) != 0) {
                                        return _settingProvider
                                            .setting
                                            .appLocalization
                                            ?.thePasswordNotMatch ??
                                            "The password is not match";
                                      } else
                                      if (password == '' || password == null) {
                                        return _settingProvider
                                            .setting
                                            .appLocalization
                                            ?.thisFieldIsRequired ??
                                            "This Field is required";
                                      } else {
                                        return null;
                                      }
                                    },
                                    hideText: value,
                                    allowToolBar: false,
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        _hideConfirmPassword.value =
                                        !_hideConfirmPassword.value;
                                      },
                                      child: Icon(
                                        value
                                            ? Icons.visibility_off_sharp
                                            : Icons.remove_red_eye,
                                        color: _settingProvider
                                            .setting.theme.bodyTextColor,
                                      ),
                                    ),
                                    hintText: _settingProvider.setting
                                        .appLocalization
                                        ?.confirmPassword ??
                                        'Confirm Password'),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomDropDownMenu(
                            hintText: _settingProvider
                                .setting.appLocalization?.userType ??
                                "User Type",
                            data: userTypes,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _provider.isLoading
                      ? CircularProgressIndicator(
                    color: _settingProvider.setting.theme.textFieldColor,
                  )
                      : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: _settingProvider.setting.theme.iconsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        _provider.switchLoading(true);
                        if (_next) {
                          debugPrint('i am in next function');
                          print(_phone_number);
                          await _createAccount();
                          _provider.switchLoading(false);
                          return;
                        }else{
                          if (_provider.userType == '' && _next) {
                            _controller.showMSG(
                                _settingProvider.setting.appLocalization
                                    ?.youMustFillAllField ??
                                    "You must fill all field",
                                title: _settingProvider
                                    .setting.appLocalization?.error ??
                                    'Error',
                                prefix: Lottie.asset(
                                    'assets/lottie/38213-error.json',
                                    animate: true));
                            _provider.switchLoading(false);
                          }
                          else if ((_emailPasswordKey.currentState
                              ?.validate() ??
                              false) &&
                              _next) {
                            if(await AuthenticationApi.isUserVerified){
                              Navigator.of(context).pop();
                            }
                            _provider.switchLoading(false);
                          } else {
                            _provider.switchLoading(false);
                          }
                        }
                      },
                      child: _next
                          ? Text(_settingProvider
                          .setting.appLocalization?.next ??
                          'Next')
                          : Text(_settingProvider
                          .setting.appLocalization?.submit ??
                          'Submit'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
