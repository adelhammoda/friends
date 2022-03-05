
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:friends/models/theme.dart';

class Setting{
  AppTheme theme;
  AppLocalizations? appLocalization;
  Setting(BuildContext context,{this.theme=const AppTheme(
    name: 'mainTheme',
    appBarColor:  Color(0xff232946),
    primaryColor:  Color(0xffb8c1ec),
    lightWhite: Color(0x52E2D8D8),
    bodyTextColor:Color(0xfffffffe) ,
    bodyTextStyle: TextStyle(
      fontSize: 12,
    color:Color(0xfffffffe) ),
    iconsColor:Color(0xffeebbc3) ,
    textFieldColor:Color(0xff121629),
    appBarTextStyle: TextStyle(
      color: Colors.white,
      // fontFamily:
    )
  )}){
    appLocalization=AppLocalizations.of(context);
  }


}