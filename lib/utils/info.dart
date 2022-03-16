


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:friends/models/theme.dart';
List<Map<String,String>> userTypes=[];


void buildInfo(BuildContext context){
  userTypes=[
    {"name":AppLocalizations.of(context)?.student ?? 'Student',"value":UserType.student.toString()},
    {"name":AppLocalizations.of(context)?.offerOwner ?? 'Offer Owner',"value":UserType.owner.toString()},
    {"name":AppLocalizations.of(context)?.manager ?? 'Manager',"value":UserType.manager.toString()},
    {"name":AppLocalizations.of(context)?.subCenter ?? 'Manager',"value":UserType.subscriptionCenter.toString()},
  ];

}


enum UserType{

  student,
  owner,
  manager,
  subscriptionCenter
}



 const List<AppTheme> themes=[
  const  AppTheme(
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
   )),
   const  AppTheme(
       name: 'mainLightTheme',
       appBarColor:  Color(0xffc0c5e7),
       primaryColor:  Color(0xff706a79),
       lightWhite: Color(0x52DB8282),
       bodyTextColor:Color(0xff4a4a17) ,
       bodyTextStyle: TextStyle(
           fontSize: 12,
           color:Color(0xff8d6c17) ),
       iconsColor:Color(0xff7fca2e) ,
       textFieldColor:Color(0xffa09b9b),
       appBarTextStyle: TextStyle(
         color: Colors.white,
         // fontFamily:
       )),


 ];