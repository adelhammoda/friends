import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'as auth;
import 'package:flutter/material.dart';
import 'package:friends/classes/get_device_info.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/pages/home_page.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/widgets/custom_dialog.dart';
import 'package:friends/widgets/loader.dart';
import 'package:lottie/lottie.dart';
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
  final bool justVerify;
  const CreateAccount({Key? key,this.justVerify = false}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  late Responsive _responsive;
  late SettingProvider _settingProvider;
  late AuthProvider _provider;
  final ValueNotifier<bool> _hidePassword = ValueNotifier(true);
  final ValueNotifier<bool> _hideConfirmPassword = ValueNotifier(true);
  final ValueNotifier<bool> _sendCodeAgain = ValueNotifier(false);
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
    if(widget.justVerify){
      _crossFadeState = CrossFadeState.showSecond;
      emailMethod =true;
      _sendCodeAgain.value = false;
      _email = AuthenticationApi.user!.email!;

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async{
        ScaffoldMessenger.of(context).clearMaterialBanners();
        _provider.switchLoading(true);
        await _sendVerification(false).catchError((e){
          _provider.switchLoading(false);
        });
        _provider.switchLoading(false);
      });}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingProvider = SettingProvider(context);
    _provider = Provider.of(context);
    _responsive = Responsive(context);
  }

  Future<void> _createAccountInFirebaseAuth() async{
    try{
      await AuthenticationApi.createUserWithEmailAndPassword(email: _email, password: _password);
    }on FirebaseException catch(e){
     throw e.message??"Some error happened while connection";
    }catch(e){
      print(e);
     throw 'Cant create your account at this moment';
    }
  }

  Future<bool?> _chooseVerificationMethod()async{
    return await showCustomDialog<bool>(context,
        barrierDismissible: false,
        child: Container(
          width: _responsive.responsiveWidth(forUnInitialDevices: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Choose the way to verify your account'),
              ),
              ListTile(
                title: Text("use number phone"),
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
  }


  Future<void> _completeCreate() async {
    User? user=await AuthenticationApi.fetchUserFromHisAccount(_email);
    if(user!= null) throw "The user account have some problem. please contact to us to solve your issue";
    await _createAccount();
    _provider.switchLoading(false);
    Go.pop(context);
    Go.to(context, const HomePage());
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
     await AuthenticationApi.writeUserToStorage(user);
    } catch (e) {
      debugPrint('we catch some error in _createUserFunction $e');
      throw 'we catch some error in _createUserFunction';
    }
  }


  Future<void> _sendVerification(bool? method)async{
    if(method==true){
      //phone number auth
    }else if(method == false){
      try{
        bool isSent = await AuthenticationApi.sendEmailVerification();
        if(isSent){
          _controller.showMSG('Email send successfully',title: "Success",
              prefix: Lottie.asset('assets/lottie/success.json'),
              titleStyle: TextStyle(
            fontSize: 16,
            color: Colors.green
          ));
          if(_crossFadeState!=CrossFadeState.showSecond) {
            _next = false;
            emailMethod = true;
            setState(() {
              _crossFadeState = CrossFadeState.showSecond;
            });
          }
          Timer(
            const Duration(seconds: 30),
              ()async{
              await AuthenticationApi.reloadUser;
              if(!AuthenticationApi.isUserVerified){
                _sendCodeAgain.value = true;
              }
              }
          );
          Timer.periodic(const Duration(seconds: 1),(timer)async{
            await auth.FirebaseAuth.instance.currentUser?.reload();
           bool res= AuthenticationApi.isUserVerified;
           if(res && !_provider.isLoading ){
             _provider.switchLoading(true);
             try{
              await _completeCreate();
             }catch(e){
               _controller.showMSG('Cant verify your account now',
               titleStyle: TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 16,
                 color: Colors.red,
               ),title: "Error",
               duration: const Duration(milliseconds: 1500),
               prefix: Lottie.asset('assets/lottie/error.json'));
             }
             _provider.switchLoading(false);
             timer.cancel();
             return ;
           }
          });
          return ;

        }else{
          throw FirebaseException(plugin: 'Error',message:'Error happened will sending the email' );
        }
      }on FirebaseException catch(e){
        throw e.message??"cant send email verification at this time";
      }catch(e){
        throw "Some error happened will sending the massage";
      }
    }

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
                                        ? "We send link to your email account.pleas open gmail and press on link to verify your account"
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
                            ),
                            ValueListenableBuilder<bool>(
                                valueListenable:_sendCodeAgain ,
                                builder: (c,value,child){
                                  return AnimatedCrossFade(
                                    firstChild: SizedBox(),
                                    secondChild: child!,
                                    duration: const Duration(milliseconds: 500),
                                    crossFadeState: value?CrossFadeState.showSecond:CrossFadeState.showFirst,
                                  );
                                },
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    primary: _settingProvider.setting.theme.iconsColor
                                  ),
                                    onPressed:_provider.isLoading? null: ()async{
                                  _provider.switchLoading(true);
                                  await _sendVerification(false);
                                  _provider.switchLoading(false);
                                  _sendCodeAgain.value=false;
                                }, icon: Icon(Icons.arrow_forward), label:Text( "Send email again")),)
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
                      ? Loader(
                    size: _responsive.responsiveWidth(forUnInitialDevices: 17),
                  )
                      : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: _settingProvider.setting.theme.iconsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        //break the function if the data isn't validate
                        if(!(_emailPasswordKey.currentState?.validate()??true)) return ;
                        if(_provider.userType=='') {
                              _controller.showMSG(
                                'User type filed must be filled',
                                duration: const Duration(milliseconds: 900),
                                prefix:
                                    Lottie.asset('assets/lottie/warning.json'),
                                title: "Warning",
                              );
                              return ;
                            }
                            print(_next);
                        // next true its mean create account and choose verification method then send code.
                        if(_next){
                          try {
                            _provider.switchLoading(true);
                            await _createAccountInFirebaseAuth();
                            // _provider.switchLoading(false);
                            // bool? method = await _chooseVerificationMethod();
                            // //throw error if the user didn't choose any way to verify
                            // if(method==null) throw "//hint//You didn't choose any thing, so the process will stop";
                            // _provider.switchLoading(true);
                            // print('the method bool value is $method');
                            await _sendVerification(false);
                            _provider.switchLoading(false);
                          }catch(e){
                            String errorMSG;
                            String title;
                            Color titleColor;
                            Widget prefix;
                            if(e.toString().contains('//hint//')){
                              title = 'Warning';
                              prefix = Lottie.asset('assets/lottie/warning.json');
                              titleColor = Colors.yellow;
                              errorMSG=e.toString().substring(9);
                            }else{
                              prefix = Lottie.asset('assets/lottie/error.json');
                              titleColor=Colors.red;
                              title = 'Error';
                              errorMSG=e.toString();
                            };

                            _provider.switchLoading(false);
                            _controller.showMSG(
                                errorMSG,
                                duration: const Duration(seconds: 2),
                                title: title,
                                prefix: prefix,
                                titleStyle: TextStyle(
                              color: titleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ));
                          }
                        }
                        else{
                          await auth.FirebaseAuth.instance.currentUser?.reload();
                          if(AuthenticationApi.isUserVerified){
                            try{
                              _provider.switchLoading(true);
                              _completeCreate();
                              // _provider.switchLoading(false);
                            } on FirebaseException catch(e){
                              _provider.switchLoading(false);
                              String errorMSG;
                              String title;
                              Color titleColor;
                              Widget prefix;
                              if(e.toString().contains('//hint//')){
                                title = 'Warning';
                                prefix = Lottie.asset('assets/lottie/warning.json');
                                titleColor = Colors.yellow;
                                errorMSG=e.toString().substring(9);
                              }else{
                                prefix = Lottie.asset('assets/lottie/error.json');
                                titleColor=Colors.red;
                                title = 'Error';
                                errorMSG=e.toString();
                              };
                              _provider.switchLoading(false);
                              _controller.showMSG(
                                  errorMSG,
                                  duration: const Duration(seconds: 2),
                                  title: title,
                                  prefix: prefix,
                                  titleStyle: TextStyle(
                                      color: titleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ));
                            }catch (e){
                              _provider.switchLoading(false);
                              String errorMSG;
                              String title;
                              Color titleColor;
                              Widget prefix;
                              if(e.toString().contains('//hint//')){
                                title = 'Warning';
                                prefix = Lottie.asset('assets/lottie/warning.json');
                                titleColor = Colors.yellow;
                                errorMSG=e.toString().substring(9);
                              }else{
                                prefix = Lottie.asset('assets/lottie/error.json');
                                titleColor=Colors.red;
                                title = 'Error';
                                errorMSG=e.toString();
                              };

                              _provider.switchLoading(false);
                              _controller.showMSG(
                                  errorMSG,
                                  duration: const Duration(seconds: 2),
                                  title: title,
                                  prefix: prefix,
                                  titleStyle: TextStyle(
                                      color: titleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ));
                            }
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
