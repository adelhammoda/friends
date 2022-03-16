import 'package:flutter/material.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/widgets/app_bar.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../utils/info.dart';
import '../widgets/loader.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  final CustomScaffoldController _controller = CustomScaffoldController();
  late SettingProvider _setting = Provider.of<SettingProvider>(context);
  late final Animation<double> _animation;
  late final AnimationController _animationController;
  late final Responsive _responsive = Responsive(context);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween(begin: 0.0, end: 0.5).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_setting.setting.theme.name=='mainTheme'){
      _animationController.reverse();
    }else{
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: buildAppBar(
        context,
        actions: [
          InkWell(
            splashColor: null,
            splashFactory:null,
            radius: 0,
            onTap: () async {
              print(await AuthenticationApi.readUserFromStorage());
              _setting.changeTheme(_setting.setting.theme.name=='mainTheme'?themes[1]:themes[0]);
            },
            child: Lottie.asset('assets/lottie/switch.json',
                controller: _animation, animate: false),
          )
        ],
        title: _setting.setting.appLocalization?.setting ?? 'setting',
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (c, value, child) {
          return value
              ? Loader(
                  size: _responsive.responsiveWidth(forUnInitialDevices: 20),
                )
              : child!;
        },
        child: Column(
          children: [
            ListTile(
              leading:const Icon(Icons.delete),
              title: Text(_setting.setting.appLocalization?.deleteAccount ??
                  "Delete Account"),
              onTap: () async {
                try {
                  _loading.value = true;
                  await AuthenticationApi.deleteAccount(
                      _setting.user?.email ?? "", _setting);
                  _loading.value = false;
                  _controller.showMSG('deleted Successfully',
                  title: "Success",
                  prefix: Lottie.asset('assets/icons/lottie/success.json'));
                  Go.pop(context);
                } catch (e) {
                  _loading.value = false;
                  _controller.showMSG('$e',
                      title: _setting.setting.appLocalization?.error ?? "Error",
                      prefix: Lottie.asset('assets/lottie/error.json'),
                      titleStyle: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ));
                }
              },
            ),
            ListTile(
              title: Text("Log out"),
              leading: const Icon(Icons.logout),
              onTap: () async {
                try {
                  await AuthenticationApi.logOut(_setting);
                  Go.pop(context);
                } catch (e) {
                  _controller.showMSG('Some error happened',
                      title: _setting.setting.appLocalization?.error ?? "Error",
                      prefix: Lottie.asset('assets/lottie/error.json'),
                      titleStyle: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ));
                }
              },
            ),
            ExpansionTile(title: Text('Choose language'),
              children: [
              ListTile(title: Text('Arabic'),
                onTap: (){
                print(_setting.setting.appLocalization?.setting);
                  _setting.changeLanguage('ar');
                },
              ),
              ListTile(title: Text('English'),
                onTap: (){
                  _setting.changeLanguage('en');
                },),
            ],)
          ],
        ),
      ),
      controller: _controller,
    );
  }
}
