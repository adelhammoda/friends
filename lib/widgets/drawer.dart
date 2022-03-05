


import 'package:flutter/material.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/pages/add_edit_offer.dart';
import 'package:friends/pages/setting.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late SettingProvider _setting;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setting=Provider.of<SettingProvider>(context);
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children:  [
          const DrawerHeader(child: Text('drawer Header')),
          ListTile(
            title:const Text('Scan QR code') ,
            onTap: (){
             Go.to(context,const AddEditOffer( ));
            },
          ),
          ListTile(
            title:const Text('Make new offer') ,
            onTap: (){
              Go.to(context,const AddEditOffer( ));
              },
          ),
          ListTile(
            title: Text(_setting.setting.appLocalization?.setting??"Setting") ,
            onTap: (){
              Go.to(context,const SettingPage());
            },
          ),
        ],
      ),
    );
  }
}
