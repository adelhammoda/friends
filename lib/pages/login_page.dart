import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/classes/get_device_info.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/models/user.dart';
import 'package:friends/pages/create_account_page.dart';
import 'package:friends/provider/auth_provider.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/utils/info.dart';
import 'package:friends/widgets/app_bar.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:friends/widgets/loader.dart';
import 'package:friends/widgets/text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

class LoginPage extends StatefulWidget {
  final bool unVerified;

  const LoginPage({Key? key, required this.unVerified}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late SettingProvider _settingProvider;
  late AuthProvider _provider;
  late final Responsive _responsive = Responsive(context);
  String _email = '';
  String _password = '';
  final ValueNotifier<bool> _hidePassword = ValueNotifier(true);
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  //
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CustomScaffoldController _controller = CustomScaffoldController();

  //

  void _loadInitialValue() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    User? user = await AuthenticationApi.readUserFromStorage();
    String? password = await storage.read(key: 'password');
    print("user is $user");
    print("password is $_password");
    if (user != null && password != null) {
      _emailController.text = user.email;
      _passwordController.text = password;
    }
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(widget.unVerified);
    print(AuthenticationApi.gitUserUid);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!this.widget.unVerified && AuthenticationApi.user != null) {
        ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(content: Text('Your account ${AuthenticationApi.user?.email} '
                'is not verified'), actions: [
              ElevatedButton(onPressed: (){
                Go.to(context, ChangeNotifierProvider(
                    create: (c)=>AuthProvider(),
                    child: CreateAccount(justVerify:true)));
              }, child: Text('Verify now'))
            ]));
      };
    });

    print(' i am in did update widget');
  }


  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  @override
  void dispose() {
    _loading.dispose();
    _hidePassword.dispose();
    _loading.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingProvider = SettingProvider(context);
    _provider = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _controller,
      appBar: buildAppBar(context,
          title: _settingProvider.setting.appLocalization?.login ?? 'Login'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                CustomTextField(
                  controller: _emailController,
                  hintText: _settingProvider.setting.appLocalization?.email ??
                      'Email',
                  validator: _provider.validateEmail,
                  onChanged: (value) {
                    if (value != null) {
                      _email = value;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _hidePassword,
                  builder: (context, value, child) =>
                      CustomTextField(
                        controller: _passwordController,
                        hideText: _hidePassword.value,
                        allowToolBar: true,
                        suffixIcon: InkWell(
                          onTap: () {
                            _hidePassword.value = !_hidePassword.value;
                          },
                          child: Icon(
                            value ? Icons.visibility_off_sharp : Icons
                                .remove_red_eye,
                            color: _settingProvider.setting.theme.bodyTextColor,
                          ),
                        ),
                        hintText:
                        _settingProvider.setting.appLocalization?.password ??
                            'password',
                        validator: _provider.validatePassword,
                        onChanged: (value) {
                          if (value != null) {
                            _password = value;
                          }
                        },
                      ),
                ),
                Row(
                  children: [
                    Checkbox(
                        value: _provider.rememberMe,
                        onChanged: (value) {
                          if (value != null) {
                            _provider.changeRememberMe(value);
                          }
                        }),
                    Text(_settingProvider.setting.appLocalization?.rememberMe ??
                        "remember me"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text((_settingProvider
                        .setting.appLocalization?.dontHaveAccount ??
                        "Don't have Account?") +
                        '?'),
                    TextButton(
                        onPressed: () {
                          buildInfo(context);
                          Go.to(context, ChangeNotifierProvider(
                              create: (c) => AuthProvider(),
                              child: const CreateAccount()));
                        },
                        child: Text((_settingProvider
                            .setting.appLocalization?.createOne ??
                            "Create one"), style: TextStyle(
                            color: _settingProvider.setting.theme.bodyTextColor
                        ),)),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, value, _) =>
                  value ? Loader(
                    size: _responsive.responsiveWidth(forUnInitialDevices: 20),
                  ) : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary:
                          _settingProvider.setting.theme.iconsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        _loading.value = true;
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            User? user = await AuthenticationApi
                                .fetchUserFromHisAccount(_emailController.text);
                            if (user != null) {
                              if (_provider.rememberMe) {
                                await FlutterSecureStorage().write(
                                    key: 'password', value: _passwordController.text);
                                await AuthenticationApi.writeUserToStorage(
                                    user);
                              }
                            } else {
                              await AuthenticationApi.login(
                                  email: _emailController.text, password: _passwordController.text);
                              _provider.switchLoading(false);
                              return;
                              // throw "Can't find this user. if there is any problem please connect to us";
                            }
                            if (user.userType == UserType.student) {
                              String uid = await DeviceInfo.getDeviceID() ??
                                  '-';
                              if (uid == user.id) {
                                await AuthenticationApi.login(
                                    email: _emailController.text, password: _passwordController.text);
                              } else {
                                throw "It seems that the user phone is not the current phone."
                                    "If Create your account as student then changed your phone "
                                    "please connect us to change your account privacy";
                              }
                            } else
                              await AuthenticationApi.login(
                                  email: _emailController.text, password: _passwordController.text);
                          } on FirebaseException catch (e) {
                            FlutterSecureStorage().delete(key: 'user');
                            _controller.showMSG(
                                e.message ?? "Some error happened.",
                                title: _settingProvider.setting.appLocalization
                                    ?.error ?? "Error",
                                prefix: Lottie.asset(
                                    'assets/lottie/error.json'),
                                // width: _responsive.responsiveWidth(forUnInitialDevices: 90),
                                titleStyle: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ));
                          }
                          catch (e) {
                            FlutterSecureStorage().delete(key: 'user');
                            _controller.showMSG('${e}',
                                title: _settingProvider.setting.appLocalization
                                    ?.error ?? "Error",
                                prefix: Lottie.asset(
                                    'assets/lottie/error.json'),
                                titleStyle: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ));
                          }
                          _loading.value = false;
                        }
                        _loading.value = false;
                      },
                      child: Text(_settingProvider
                          .setting.appLocalization?.submit ??
                          'Submit')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
