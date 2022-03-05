import 'package:flutter/material.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/widgets/app_bar.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final CustomScaffoldController _controller = CustomScaffoldController();
  late SettingProvider _setting;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setting = Provider.of<SettingProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: buildAppBar(

          context,
          actions:[
            IconButton(onPressed: (){
              AuthenticationApi().signOut();
            }, icon: const Icon(Icons.logout),)
          ],
          title: _setting.setting.appLocalization?.setting ?? 'Setting',

        ),
        child: Column(
          children: [
            ListTile(
              title: Text(_setting.setting.appLocalization?.deleteAccount??"Delete Account") ,
              onTap: ()async{

                print(await AuthenticationApi().deleteAccount(_setting));
              },
            ),
          ],
        ),
        controller: _controller,);
  }
}
