import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  //
  String _email = '';
  String _password = '';
  String _name = '';
  String _otp = '';

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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _controller,
      appBar: buildAppBar(context,
          title: _settingProvider.setting.appLocalization?.createAccount ??
              'Create Account'),
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
                      width: _responsive.responsiveWidth(forUnInitialDevices: 100),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: _responsive.responsiveWidth(forUnInitialDevices: 100),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  _settingProvider
                                          .setting.appLocalization?.weSendOTb ??
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
                              Text(_email,
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
                          CustomTextField(
                            hintText: 'Enter OTB',
                            validator: (otpValue) {
                              if (otpValue != null) {
                                return _provider.verifyOTP(
                                    context, _email, otpValue,_settingProvider);
                              } else {
                                return _settingProvider.setting.appLocalization
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
                                return _settingProvider.setting.appLocalization
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
                        ValueListenableBuilder<bool>(
                          valueListenable: _hidePassword,
                          builder: (ctx, value, child) => CustomTextField(
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
                                  _hidePassword.value = !_hidePassword.value;
                                },
                                child: Icon(
                                  value
                                      ? Icons.panorama_fish_eye
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
                          builder: (ctx, value, child) => CustomTextField(
                              validator: (password) {
                                if (password?.compareTo(_password) != 0) {
                                  return _settingProvider
                                          .setting
                                          .appLocalization
                                          ?.thePasswordNotMatch ??
                                      "The password is not match";
                                } else if (password == '' || password == null) {
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
                                      ? Icons.panorama_fish_eye
                                      : Icons.remove_red_eye,
                                  color: _settingProvider
                                      .setting.theme.bodyTextColor,
                                ),
                              ),
                              hintText: _settingProvider.setting.appLocalization
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
                          _provider.switchLoading(true);
                          if (!_next &&
                              (_otbKey.currentState?.validate() ?? false)) {
                            await _provider.createAccount(context, _email, _password,
                                _otp, _name, _controller,_settingProvider).then((value)async {
                              FlutterSecureStorage s=const  FlutterSecureStorage();
                              String? uid=await s.read(key: 'uid');
                              String? dId=await s.read(key: 'deviceID');
                              if(uid!=null&&dId!=null) {
                                _settingProvider.user=User(
                                  email: _email,
                                 name: _name,
                                 id: dId,
                                 userType: _provider.userType,
                               );
                              }
                            });
                            _provider.switchLoading(false);
                            return;
                          }
                          bool? validate =
                              _emailPasswordKey.currentState?.validate();
                          if (_provider.userType == ''&&_next) {
                            _controller.showError(_settingProvider.setting
                                    .appLocalization?.youMustFillAllField ??
                                "You must fill all field",title: _settingProvider.setting.appLocalization?.error??'Error',prefix: Lottie.asset('assets/lottie/38213-error.json',animate: true));
                            _provider.switchLoading(false);
                          } else if ((validate ?? false)&&_next) {
                            await _provider
                                .sendOTP(context, _email, _controller)
                                .then((value) {
                              _provider.switchLoading(false);
                              if (value == true) {
                                setState(() {
                                  _next = false;
                                  _crossFadeState = CrossFadeState.showSecond;
                                });
                              }
                            });
                          } else {
                            _provider.switchLoading(false);
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
    );
  }
}
