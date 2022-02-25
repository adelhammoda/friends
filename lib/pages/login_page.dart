import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:offer_app/classes/navigator.dart';
import 'package:offer_app/pages/create_account_page.dart';
import 'package:offer_app/provider/auth_provider.dart';
import 'package:offer_app/provider/setting_provider.dart';
import 'package:offer_app/utils/info.dart';
import 'package:offer_app/widgets/app_bar.dart';
import 'package:offer_app/widgets/custom_scaffold.dart';
import 'package:offer_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late SettingProvider _settingProvider;
  late AuthProvider _provider;
  String _email = '';
  String _password = '';
  final ValueNotifier<bool> _hidePassword=ValueNotifier(true);
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ValueNotifier<bool> _loading=ValueNotifier(false);
  //
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  final CustomScaffoldController _controller=CustomScaffoldController();
  //

  void _loadInitialValue()async{
   const FlutterSecureStorage storage= FlutterSecureStorage();
   String? email=await storage.read(key: 'email');
   String? password =await storage.read(key: 'password');
    if(email!=null&&password!=null){
      _emailController.text=email;
      _passwordController.text=password;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialValue();
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
                  builder:(context,value,child)=> CustomTextField(
                    controller: _passwordController,
                    hideText: _hidePassword.value,
                    allowToolBar: true,
                    suffixIcon: InkWell(
                      onTap: (){
                        _hidePassword.value=!_hidePassword.value;
                      },
                      child: Icon(
                        value? Icons.panorama_fish_eye:Icons.remove_red_eye,
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
                        onChanged: (value){
                          if(value!=null) {
                            _provider.changeRememberMe(value);
                          }
                        }),
                    Text(_settingProvider.setting.appLocalization?.rememberMe??"remember me"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text((_settingProvider
                        .setting.appLocalization?.dontHaveAccount ??
                        "Dont have Account?") +
                        '?'),
                    TextButton(

                        onPressed: (){
                          buildInfo(context);
                          Go.to(context,ChangeNotifierProvider.value(
                              value:_provider,
                              child: const CreateAccount()));
                        },
                        child: Text((_settingProvider
                            .setting.appLocalization?.createOne ??
                            "Create one"),style: TextStyle(
                            color: _settingProvider.setting.theme.bodyTextColor
                        ),)),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder:(context,value,_)=>value? CircularProgressIndicator(
                    color: _settingProvider.setting.theme.appBarColor,
                  ): ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary:
                          _settingProvider.setting.theme.iconsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () async{
                        _loading.value=true;
                        if(_formKey.currentState?.validate()??false) {
                          await _provider.login(_email, _password,_controller,_settingProvider);
                          _loading.value=false;
                        }
                        _loading.value=false;
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
